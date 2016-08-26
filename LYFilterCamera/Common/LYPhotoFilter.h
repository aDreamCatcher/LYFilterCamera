//
//  LYPhotoFilter.h
//  LYFilterCamera
//
//  Created by kuner on 16/8/25.
//  Copyright © 2016年 kuner. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreImage/CoreImage.h>

@interface LYPhotoFilter : NSObject

+ (NSArray *)filterNames;
+ (NSArray *)filterDisplayNames;

+ (CIFilter *)defaultFilter;
+ (CIFilter *)filterWithName:(NSString *)filterName;

@end
