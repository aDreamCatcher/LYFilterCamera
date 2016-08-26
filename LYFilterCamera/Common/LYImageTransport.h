//
//  LYImageTransport.h
//  LYFilterCamera
//
//  Created by kuner on 16/8/25.
//  Copyright © 2016年 kuner. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol LYImageTransport <NSObject>

- (void)setImage:(CIImage *)image;
- (void)setDrawImageFrame:(CGRect)frame;

@end
