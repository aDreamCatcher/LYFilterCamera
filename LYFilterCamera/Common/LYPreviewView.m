//
//  LYPreviewView.m
//  LYFilterCamera
//
//  Created by kuner on 16/8/25.
//  Copyright © 2016年 kuner. All rights reserved.
//

#import "LYPreviewView.h"

@interface LYPreviewView ()

@property (nonatomic, assign) CGRect drawableBounds;

@end


@implementation LYPreviewView

- (instancetype)initWithFrame:(CGRect)frame context:(EAGLContext *)context
{
    self = [super initWithFrame:frame context:context];
    
    if (self) {
        
        self.enableSetNeedsDisplay = NO;
        
        self.backgroundColor = [UIColor blackColor];
        
        self.opaque = YES;
        
        self.transform = CGAffineTransformMakeRotation(M_PI_2);
        
        [self bindDrawable];
        
        _drawableBounds = self.bounds;
        _drawableBounds.size.width = self.drawableWidth;
        _drawableBounds.size.height = self.drawableHeight;
    }
    
    return self;
}

- (void)layoutSubviews
{
    [super layoutSubviews];
    
    [self bindDrawable];
    
    _drawableBounds = self.bounds;
    _drawableBounds.size.width = self.drawableWidth;
    _drawableBounds.size.height = self.drawableHeight;
}


#pragma mark - LYImageTransport

- (void)setImage:(CIImage *)sourceImage
{
    // 绑定上下文
    [self bindDrawable];
    
    // 设置滤镜图片
    [_filter setValue:sourceImage forKey:kCIInputImageKey];
    
    CIImage *filteredImage = self.filter.outputImage;
    if (filteredImage) {
        CGRect rect = LYCenterCropImageRect(filteredImage.extent, _drawableBounds);
        
        [_coreImageContext drawImage:filteredImage inRect:_drawableBounds fromRect:rect];
    }
    
    // 开始绘制
    [self display];
    
    [_filter setValue:nil forKey:kCIInputImageKey];
    
}

CGRect LYCenterCropImageRect(CGRect sourceRect , CGRect previewRect) {
    
    // 宽高比
    
    CGFloat sourceAspectRatio = sourceRect.size.width / sourceRect.size.height;
    
    CGFloat previewAspectRatio = previewRect.size.width / previewRect.size.height;
    
    CGRect drawRect = sourceRect;
    
    if (sourceAspectRatio > previewAspectRatio) {
        // sourceRect的height相对比较小，以height为基准
        CGFloat scaleWidth = drawRect.size.height * previewAspectRatio;
        drawRect.origin.x += (drawRect.size.width - scaleWidth) * 0.5;
        drawRect.size.width = scaleWidth;
    } else {
        // sourceRect的width相对比较小， 以width为基准
        CGFloat scaleHeight = drawRect.size.width / previewAspectRatio;
        drawRect.origin.y += (drawRect.size.height - drawRect.size.width / previewAspectRatio) * 0.5;
        drawRect.size.height = scaleHeight;
    }
    return drawRect;
}




@end
