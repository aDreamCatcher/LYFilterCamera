//
//  LYCameraManager.m
//  LYFilterCamera
//
//  Created by kuner on 16/8/25.
//  Copyright © 2016年 kuner. All rights reserved.
//

#import "LYCameraManager.h"
#import <AVFoundation/AVFoundation.h>
#import "LYMovieWriter.h"

@interface LYCameraManager()<AVCaptureVideoDataOutputSampleBufferDelegate,AVCaptureAudioDataOutputSampleBufferDelegate>

@property (nonatomic, strong) AVCaptureSession  *captureSession;
@property (nonatomic, strong) AVCaptureDeviceInput  *videoInput;
@property (nonatomic, strong) AVCaptureVideoDataOutput  *videoDataOutput;
@property (nonatomic, strong) LYMovieWriter             *movieWriter;

@end


@implementation LYCameraManager

- (instancetype)init
{
    self = [super init];
    if (self) {
        _captureQueue = dispatch_queue_create("com.camera.CaptureDispatchQueue", DISPATCH_QUEUE_SERIAL);
    }
    
    return self;
}

- (void)setupCaptureSesstion
{
    _captureSession = [[AVCaptureSession alloc] init];
    _captureSession.sessionPreset = AVCaptureSessionPresetMedium;
    
    NSError *error;
    AVCaptureDevice *videoDevice = [AVCaptureDevice defaultDeviceWithMediaType:AVMediaTypeVideo];
    
    // video input
    _videoInput = [AVCaptureDeviceInput deviceInputWithDevice:videoDevice error:&error];
    
    if (_videoInput) {
        if ([_captureSession canAddInput:_videoInput]) {
            [_captureSession addInput:_videoInput];
        }
    }
    
    // audio input
    AVCaptureDevice *audioDevide = [AVCaptureDevice defaultDeviceWithMediaType:AVMediaTypeAudio];
    AVCaptureDeviceInput *audioInput = [AVCaptureDeviceInput deviceInputWithDevice:audioDevide error:nil];
    
    if (audioInput) {
        if ([_captureSession canAddInput:audioInput]) {
            [_captureSession addInput:audioInput];
        }
    }
    
    
    // video data output
    _videoDataOutput = [[AVCaptureVideoDataOutput alloc] init];
    
    // 在OpenGL ES上，苹果建议使用kCVPixelFormatType_32BGRA
    NSDictionary *videoOutputSetting = @{(NSString *)kCVPixelBufferPixelFormatTypeKey:@(kCVPixelFormatType_32BGRA)};
    _videoDataOutput.videoSettings = videoOutputSetting;
    
    // 捕捉全部可用帧，保持实时性， 会带来一定内存消耗
    _videoDataOutput.alwaysDiscardsLateVideoFrames = NO;
    [_videoDataOutput setSampleBufferDelegate:self queue:_captureQueue];
    
    if ([_captureSession canAddOutput:_videoDataOutput]) {
        [_captureSession addOutput:_videoDataOutput];
    }
    
    // audio data output
    AVCaptureAudioDataOutput *audioDataOutput = [[AVCaptureAudioDataOutput alloc] init];
    [audioDataOutput setSampleBufferDelegate:self queue:_captureQueue];
    
    if ([_captureSession canAddOutput:audioDataOutput]) {
        [_captureSession addOutput:audioDataOutput];
    }
    
    // asset writer
    // 将videoOutput 和 audioOutput的配置传送给assetWriter
    NSDictionary *videoSettings = [_videoDataOutput recommendedVideoSettingsForAssetWriterWithOutputFileType:AVFileTypeQuickTimeMovie];
    NSDictionary *audioSettings = [audioDataOutput recommendedAudioSettingsForAssetWriterWithOutputFileType:AVFileTypeQuickTimeMovie];
    
    _movieWriter = [[LYMovieWriter alloc] initWithVideoSettings:videoSettings audioSettings:audioSettings dispatchQueue:_captureQueue];
    
}

- (void)startCaptureSesstion
{
    dispatch_async(_captureQueue, ^{
        if (![_captureSession isRunning]) {
            [_captureSession startRunning];
        }
    });
}

- (void)stopCaptureSession
{
    dispatch_async(_captureQueue, ^{
        if ([_captureSession isRunning]) {
            [_captureSession stopRunning];
        }
    });
}

- (void)startRecorded
{
    _isRecorded = YES;
    [_movieWriter startWriting];
}

- (void)stopRecorded
{
    _isRecorded = NO;
    [_movieWriter stopWriting];
}

#pragma mark - AVCaptureVideoDataOutputSampleBufferDelegate

- (void)captureOutput:(AVCaptureOutput *)captureOutput didOutputSampleBuffer:(CMSampleBufferRef)sampleBuffer fromConnection:(AVCaptureConnection *)connection
{
    // 实时采样(保存录制视频)
    [_movieWriter processSampleBuffer:sampleBuffer];
    
    // 展示
    if (captureOutput == _videoDataOutput) {
        // 实时采样滤镜处理
        @synchronized (self) {
            CVPixelBufferRef imageBuffer = CMSampleBufferGetImageBuffer(sampleBuffer);
            
            CIImage *sourceImage = [CIImage imageWithCVImageBuffer:imageBuffer options:NULL];
            
            if ([_delegate respondsToSelector:@selector(setImage:)]) {
                [_delegate setImage:sourceImage];
            }
        }
    }
}

- (void)dealloc
{
    if ([_captureSession isRunning]) {
        [_captureSession stopRunning];
    }
}


@end
