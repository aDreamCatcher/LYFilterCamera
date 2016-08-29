//
//  LYMovieWriter.h
//  LYFilterCamera
//
//  Created by kuner on 16/8/29.
//  Copyright © 2016年 kuner. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreMedia/CoreMedia.h>

@interface LYMovieWriter : NSObject

- (instancetype)initWithVideoSettings:(NSDictionary *)videoSettings
                        audioSettings:(NSDictionary *)audioSettings
                        dispatchQueue:(dispatch_queue_t)dispatchQueue;

- (void)processSampleBuffer:(CMSampleBufferRef)sampleBuffer;    // 实时采样

- (void)startWriting;
- (void)stopWriting;

@end
