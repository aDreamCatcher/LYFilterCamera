//
//  LYPreviewView.h
//  LYFilterCamera
//
//  Created by kuner on 16/8/25.
//  Copyright © 2016年 kuner. All rights reserved.
//

#import <GLKit/GLKit.h>
#import "LYImageTransport.h"

@interface LYPreviewView : GLKView <LYImageTransport>

/**
 *  当前滤镜
 */
@property (nonatomic, strong) CIFilter *filter;

/**
 *  coreImage 绘制的上下文
 */
@property (nonatomic, strong) CIContext *coreImageContext;

@end
