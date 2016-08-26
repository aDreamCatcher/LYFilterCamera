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


@interface LYCameraCollectionView (){
    
    NSInteger       _cameraNumber;
    
    NSMutableArray *_cameraMArray;
}

@property (nonatomic, strong) LYCameraManager *cameraManager;

@end


@implementation LYCameraCollectionView


- (instancetype)init
{
    self = [super init];
    if (self) {
        
        _cameraNumber = 9;
        _cameraMArray = [NSMutableArray array];
        
        [self setupPreview];
        
        [self setupCameraManager];
        
    }
    
    return self;
}

- (void)layoutSubviews
{
    [super layoutSubviews];
    
    for (int i=0; i < _cameraNumber; i++) {
        LYPreviewView *preview = _cameraMArray[i];
        
        preview.frame = [self rectByIndex:i];
    }
    
}

- (void)dealloc
{
    [_cameraManager stopCaptureSession];
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

#pragma mark - Utlity

- (void)setupPreview
{
    LYContextManager *contextManager = [LYContextManager shareManager];
    
    for (int i = 0; i < _cameraNumber; i++) {
        LYPreviewView *previewView = [[LYPreviewView alloc] initWithFrame:self.bounds context:contextManager.eaglContext];
        previewView.filter = [self filterByIndex:i];
        previewView.coreImageContext = contextManager.ciContext;
        [self addSubview:previewView];
        
        [_cameraMArray addObject:previewView];
    }
}

- (void)setupCameraManager
{
    _cameraManager = [[LYCameraManager alloc] init];
    _cameraManager.imageTargets = _cameraMArray;
    [_cameraManager setupCaptureSesstion];
    [_cameraManager startCaptureSesstion];
}

- (CIFilter *)filterByIndex:(int)index
{
    NSString *filterName = [LYPhotoFilter filterNames][index];
    return [LYPhotoFilter filterWithName:filterName];
}

- (CGRect)rectByIndex:(int)index
{
    CGFloat width = self.frame.size.width;
    CGFloat height = self.frame.size.height;
    
    
    CGFloat space = 10;
    CGFloat itemWidth = (width-space*2)/3;
    CGFloat itemHeight = (height-64-80)/3;
    
    CGFloat oriX = space + itemWidth*(index/3);
    CGFloat oriY = 64 + itemHeight*(index%3);
    
    return CGRectMake(oriX, oriY, itemWidth, itemHeight);
}

@end
