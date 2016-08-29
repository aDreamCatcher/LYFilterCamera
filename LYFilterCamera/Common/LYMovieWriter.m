//
//  LYMovieWriter.m
//  LYFilterCamera
//
//  Created by kuner on 16/8/29.
//  Copyright © 2016年 kuner. All rights reserved.
//

#import "LYMovieWriter.h"
#import <CoreImage/CoreImage.h>
#import <AVFoundation/AVFoundation.h>
#import <AssetsLibrary/AssetsLibrary.h>
#import <Photos/PHPhotoLibrary.h>
#import "LYContextManager.h"
#import "LYPhotoFilter.h"


@interface LYMovieWriter ()

@property (nonatomic, strong) NSDictionary  *videoSettings;
@property (nonatomic, strong) NSDictionary  *audioSettings;

@property (nonatomic, strong) dispatch_queue_t   dispatchQueue;
@property (nonatomic, strong) CIContext         *ciContext;
@property (nonatomic, assign) CGColorSpaceRef    colorSpace;

@property (nonatomic, strong) CIFilter          *filter;

@property (nonatomic, strong) AVAssetWriter     *assetWriter;
@property (nonatomic, strong) AVAssetWriterInput    *assetWriterVideoInput;
@property (nonatomic, strong) AVAssetWriterInput    *assetWriterAudioInput;

// 拼接样本适配器
@property (nonatomic, strong) AVAssetWriterInputPixelBufferAdaptor  *assetWriterInputPixelBufferAdaptor;

// 是否第一次取样
@property (nonatomic, assign) BOOL  isFirstSample;
@property (nonatomic, assign) BOOL  isWriting;

@end


@implementation LYMovieWriter

- (instancetype)initWithVideoSettings:(NSDictionary *)videoSettings audioSettings:(NSDictionary *)audioSettings dispatchQueue:(dispatch_queue_t)dispatchQueue
{
    self = [super init];
    if (self) {
        
        _videoSettings = videoSettings;
        _audioSettings = audioSettings;
        _dispatchQueue = dispatchQueue;
        _ciContext     = [LYContextManager shareManager].ciContext;
        _colorSpace    = CGColorSpaceCreateDeviceRGB();
        _filter        = [LYPhotoFilter defaultFilter];
        _isFirstSample = YES;
        
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(filterDidChange:) name:kLYCameraFilterDidChangeNotification object:nil];
    }
    
    return self;
}

- (void)dealloc
{
    CGColorSpaceRelease(_colorSpace);
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

#pragma mark - 

- (void)filterDidChange:(NSNotification *)note
{
    CIFilter *filter = note.object;
    _filter = filter;
}

- (NSURL *)outputURL
{
    NSString *filePath = [NSTemporaryDirectory() stringByAppendingPathComponent:@"movie.mov"];
    NSURL    *url = [NSURL fileURLWithPath:filePath];
    
    if ([[NSFileManager defaultManager] fileExistsAtPath:url.path]) {
        [[NSFileManager defaultManager] removeItemAtURL:url error:nil];
    }
    
    return url;
}

- (void)startWriting
{
    
    dispatch_async(_dispatchQueue, ^{
        
        NSError *error;
        
        // asset writer AVFileTypeQuickTimeMOvie
        _assetWriter = [AVAssetWriter assetWriterWithURL:[self outputURL] fileType:AVFileTypeQuickTimeMovie error:&error];
        
        if (!_assetWriter || error) {
            NSLog(@"error could not create AVAssetWriter");
            return ;
        }
        
        // video input AVMediaTypeVideo
        _assetWriterVideoInput = [[AVAssetWriterInput alloc] initWithMediaType:AVMediaTypeVideo outputSettings:_videoSettings];
        
        // 实时调整输入
        _assetWriterVideoInput.expectsMediaDataInRealTime = YES;
        
        UIDeviceOrientation orientation = [UIDevice currentDevice].orientation;
        _assetWriterVideoInput.transform = LYTransformForDeviceOrientation(orientation);
        
        // buffer adaptor
        
        NSDictionary *attributes = @{(NSString *)kCVPixelBufferPixelFormatTypeKey:@(kCVPixelFormatType_32BGRA),
                                     (NSString *)kCVPixelBufferWidthKey:_videoSettings[AVVideoWidthKey],
                                     (NSString *)kCVPixelBufferWidthKey:_videoSettings[AVVideoHeightKey],
                                     (NSString *)kCVPixelFormatOpenGLESCompatibility:(id)kCFBooleanTrue};
        _assetWriterInputPixelBufferAdaptor = [[AVAssetWriterInputPixelBufferAdaptor alloc] initWithAssetWriterInput:_assetWriterVideoInput sourcePixelBufferAttributes:attributes];
        
        if ([_assetWriter canAddInput:_assetWriterVideoInput]) {
            [_assetWriter addInput:_assetWriterVideoInput];
        }
        else
        {
            NSLog(@"error could not add AVAssetWriterInput");
            return;
        }
            
        // audio input AVMediaTypeAudio
        _assetWriterAudioInput = [[AVAssetWriterInput alloc] initWithMediaType:AVMediaTypeAudio outputSettings:_audioSettings];
        _assetWriterAudioInput.expectsMediaDataInRealTime = YES;
        
        if ([self.assetWriter canAddInput:_assetWriterAudioInput]) {
            [self.assetWriter addInput:_assetWriterAudioInput];
        }
        else
        {
            NSLog(@"error could not add AVAssetWriterInput");
        }
        
        self.isFirstSample = YES;
        self.isWriting = YES;
        
    });
    
}

- (void)stopWriting
{
    _isWriting = NO;
    
    LYWeakSelf(self)
    
    dispatch_async(_dispatchQueue, ^{
        [_assetWriter finishWritingWithCompletionHandler:^{
            
            if (_assetWriter.status == AVAssetWriterStatusCompleted) {
                [weakself writeMovieAtURL:_assetWriter.outputURL];
            };
            
        }];
    });
    
}

- (void)writeMovieAtURL:(NSURL *)outputURL
{
    [[NSNotificationCenter defaultCenter] postNotificationName:kLYCameraWillWriteVideoNotification object:nil];
    
    ALAssetsLibrary *library = [[ALAssetsLibrary alloc] init];
    
    if ([library videoAtPathIsCompatibleWithSavedPhotosAlbum:outputURL]) {
        
        [library writeVideoAtPathToSavedPhotosAlbum:outputURL completionBlock:^(NSURL *assetURL, NSError *error) {
            if (error) {
                NSLog(@"write video error");
            }
            else
            {
                [[NSNotificationCenter defaultCenter] postNotificationName:kLYCameraDidWriteVideoNotification object:nil];
            }
        }];
    }
}

- (void)processSampleBuffer:(CMSampleBufferRef)sampleBuffer
{
    if (!_isWriting) {
        return ;
    }
    
    // 获取样本的媒体类型
    
    CMFormatDescriptionRef formatRef = CMSampleBufferGetFormatDescription(sampleBuffer);
    
    CMMediaType mediaType = CMFormatDescriptionGetMediaType(formatRef);
    
    if (mediaType == kCMMediaType_Video) {
        
        //
        CMTime timeStamp = CMSampleBufferGetPresentationTimeStamp(sampleBuffer);
        
        if (_isFirstSample) {
            
            // 第一次写入，设置开始时间
            if ([_assetWriter startWriting]) {
                [_assetWriter startSessionAtSourceTime:timeStamp];
            }
            else
            {
                NSLog(@"error failed to start writing");
            }
            
            _isFirstSample = NO;
        }
        
        // 容器
        CVPixelBufferRef outputRenderBuffer = NULL;
        
        // 像素缓冲池
        CVPixelBufferPoolRef pixelBufferPool = _assetWriterInputPixelBufferAdaptor.pixelBufferPool;
        
        // 创建像素容器
        CVReturn code = CVPixelBufferPoolCreatePixelBuffer(NULL, pixelBufferPool, &outputRenderBuffer);
        
        if (code != kCVReturnSuccess) {
            NSLog(@"error to get pixel buffer from pool");
            return;
        }
        
        // 获取每一帧
        CVPixelBufferRef imageBuffer = CMSampleBufferGetImageBuffer(sampleBuffer);
        CIImage *sourceImage = [CIImage imageWithCVPixelBuffer:imageBuffer];
        
        // 添加滤镜
        [_filter setValue:sourceImage forKey:kCIInputImageKey];
        
        CIImage *filteredImg = _filter.outputImage;
        
        if (!filteredImg) {
            filteredImg = sourceImage;
        }
        
        // 开始拼接滤镜图片
        [_ciContext render:filteredImg toCVPixelBuffer:outputRenderBuffer bounds:filteredImg.extent colorSpace:_colorSpace];
        
        BOOL isReady = _assetWriterVideoInput.readyForMoreMediaData;
        
        if (isReady) {
            // 视频器拼接处理结果
            BOOL result = [_assetWriterInputPixelBufferAdaptor appendPixelBuffer:outputRenderBuffer withPresentationTime:timeStamp];
            if (!result) {
                NSLog(@"error appending pixel buffer");
            }
        }
        
        CVPixelBufferRelease(outputRenderBuffer);
    }
    else if (!_isFirstSample && mediaType == kCMMediaType_Audio)
    { // 直接拼接音频
        BOOL isReady = _assetWriterAudioInput.isReadyForMoreMediaData;
        if (isReady) {
            // 直接从样本中拼接音频
            BOOL result = [_assetWriterAudioInput appendSampleBuffer:sampleBuffer];
            if (!result) {
                NSLog(@"error appending audio sample buffer");
            }
        }
    }
    
}



CGAffineTransform LYTransformForDeviceOrientation(UIDeviceOrientation orientation) {
    
    CGAffineTransform result;
    
    switch (orientation) {
            
        case UIDeviceOrientationLandscapeRight:
            result = CGAffineTransformMakeRotation(M_PI);
            break;
            
        case UIDeviceOrientationPortraitUpsideDown:
            result = CGAffineTransformMakeRotation((M_PI_2 * 3));
            break;
            
        case UIDeviceOrientationPortrait:
        case UIDeviceOrientationFaceUp:
        case UIDeviceOrientationFaceDown:
            result = CGAffineTransformMakeRotation(M_PI_2);
            break;
            
        default: // UIDeviceOrientationLandscapeLeft
            result = CGAffineTransformIdentity;
            break;
    }
    
    return result;
}


@end
