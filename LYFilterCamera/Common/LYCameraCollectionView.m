//
//  LYCameraItem.m
//  LYFilterCamera
//
//  Created by kuner on 16/8/25.
//  Copyright © 2016年 kuner. All rights reserved.
//

#import "LYCameraCollectionView.h"
#import "LYPreviewView.h"
#import "LYContextManager.h"
#import "LYCameraManager.h"
#import "LYPhotoFilter.h"
#import <pthread.h>


@interface LYCameraCollectionView ()<LYImageTransport>{
    
    NSInteger       _cameraNumber;
    
    NSMutableArray *_cameraMArray;
    
    pthread_mutex_t _mutex;
}

@property (nonatomic, strong) LYCameraManager *cameraManager;

@end


@implementation LYCameraCollectionView


- (instancetype)init
{
    self = [super init];
    if (self) {
        
        pthread_mutex_init(&_mutex, NULL);
        
        _cameraNumber = 9;
        _cameraMArray = [NSMutableArray array];
        
        [self setupPreview];
        
        [self setupCameraManager];
        
        self.backgroundColor = [UIColor yellowColor];
    }
    
    return self;
}

- (void)dealloc
{
    [_cameraManager stopCaptureSession];
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

#pragma mark - UI

- (void)setupPreview
{
    LYContextManager *contextManager = [LYContextManager shareManager];
    
    for (int i = 0; i < _cameraNumber; i++) {
        
        LYPreviewView *previewView = [[LYPreviewView alloc] initWithFrame:[self rectByIndex:i] context:contextManager.eaglContext];
        previewView.filter = [self filterByIndex:i];
        previewView.coreImageContext = contextManager.ciContext;
        previewView.tag = i;
        [self addSubview:previewView];
        
        UITapGestureRecognizer *tapGes = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(previewTapAction:)];
        [previewView addGestureRecognizer:tapGes];
        
        [_cameraMArray addObject:previewView];
    }
}

- (void)setupCameraManager
{
    _cameraManager = [[LYCameraManager alloc] init];
    _cameraManager.delegate = self;
    
    [_cameraManager setupCaptureSesstion];
    [_cameraManager startCaptureSesstion];
}

#pragma mark - Action

- (void)previewTapAction:(id)sender
{
    UITapGestureRecognizer *tapGes = (UITapGestureRecognizer *)sender;
    
    [self previewAnimationBig:tapGes.view.tag];
}

#pragma mark - LYImageTransport

- (void)setImage:(CIImage *)image
{
    pthread_mutex_lock(&_mutex);
    
    for (id obj in _cameraMArray) {
        if ([obj respondsToSelector:@selector(setImage:)]) {
            [obj setImage:image];
        }
    }
    
    pthread_mutex_unlock(&_mutex);
}

#pragma mark - Utlity

- (CIFilter *)filterByIndex:(int)index
{
    NSString *filterName = [LYPhotoFilter filterNames][index];
    return [LYPhotoFilter filterWithName:filterName];
}

- (CGRect)rectByIndex:(int)index
{
    CGRect bounds = [UIScreen mainScreen].bounds;
    CGFloat width = bounds.size.width;
    CGFloat height = bounds.size.height;
    
    CGFloat space = 10;
    CGFloat itemWidth = (width-space*4)/3;
    CGFloat itemHeight = (height-64-80-space*2)/3;
    
    CGFloat oriX = space + (itemWidth+space)*(index/3);
    CGFloat oriY = 64 + (itemHeight+space)*(index%3);
    
    if (index == -1) {
        return CGRectMake(0, 64, width, height-64.0-80.0);
    }
    
    return CGRectMake(oriX, oriY, itemWidth, itemHeight);
}

- (void)previewAnimationBig:(NSInteger)tag
{
    if (tag < _cameraMArray.count) {
        
        LYPreviewView *curPreview = _cameraMArray[tag];
        [self bringSubviewToFront:curPreview];
        
        CGRect endFrame = [self rectByIndex:-1];
        
        __weak typeof(self) weakSelf = self;
        [UIView animateWithDuration:0.2
                         animations:^{
                             curPreview.frame = endFrame;
                         }
                         completion:^(BOOL finished) {
                             [weakSelf removeExceptPreview:curPreview];
                             [curPreview setDrawImageFrame:endFrame];
                         }];
    }
    
}

- (void)removeExceptPreview:(LYPreviewView *)preview
{
    pthread_mutex_lock(&_mutex);
    
    NSMutableArray *delMArray = [NSMutableArray array];
    
    for (id obj in _cameraMArray) {
        if (![obj isEqual:preview]) {
            
            [obj removeFromSuperview];
            
            [delMArray addObject:obj];
        }
    }
    
    [_cameraMArray removeObjectsInArray:delMArray];
    
    pthread_mutex_unlock(&_mutex);
}

@end
