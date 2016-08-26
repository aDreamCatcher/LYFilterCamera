//
//  LYContextManager.m
//  LYFilterCamera
//
//  Created by kuner on 16/8/25.
//  Copyright © 2016年 kuner. All rights reserved.
//

#import "LYContextManager.h"

static LYContextManager *instance;

@implementation LYContextManager

+ (instancetype)shareManager
{
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        instance = [[self alloc] init];
    });
    
    return instance;
}

+ (instancetype)allocWithZone:(struct _NSZone *)zone
{
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        instance = [super allocWithZone:zone];
    });
    
    return instance;
}

- (instancetype)init
{
    self = [super init];
    if (self) {
        
        // OpenGLES2
        _eaglContext = [[EAGLContext alloc] initWithAPI:kEAGLRenderingAPIOpenGLES2];
        
        NSDictionary *options = @{kCIContextWorkingColorSpace:[NSNull null]};
        _ciContext = [CIContext contextWithEAGLContext:_eaglContext options:options];
    }
    
    return self;
}

@end
