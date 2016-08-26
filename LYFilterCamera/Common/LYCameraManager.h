//
//  LYCameraManager.h
//  LYFilterCamera
//
//  Created by kuner on 16/8/25.
//  Copyright © 2016年 kuner. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "LYImageTransport.h"

@interface LYCameraManager : NSObject

@property (nonatomic, strong, readonly) dispatch_queue_t  captureQueue;
@property (nonatomic, assign, readonly) BOOL              isRecorded;
@property (nonatomic, strong)           NSArray<LYImageTransport>  *imageTargets;

- (void)setupCaptureSesstion;
- (void)startCaptureSesstion;
- (void)stopCaptureSession;

- (void)startRecorded;
- (void)stopRecorded;

@end
