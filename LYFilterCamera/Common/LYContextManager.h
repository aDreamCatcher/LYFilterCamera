//
//  LYContextManager.h
//  LYFilterCamera
//
//  Created by kuner on 16/8/25.
//  Copyright © 2016年 kuner. All rights reserved.
//

#import <GLKit/GLKit.h>

@interface LYContextManager : NSObject

+ (instancetype)shareManager;

// GL绘图上下文
@property (nonatomic, strong) EAGLContext *eaglContext;

// coreImage绘图上下文
@property (nonatomic, strong) CIContext   *ciContext;

@end
