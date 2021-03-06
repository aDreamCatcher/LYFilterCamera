//
//  LYPhotoFilter.m
//  LYFilterCamera
//
//  Created by kuner on 16/8/25.
//  Copyright © 2016年 kuner. All rights reserved.
//

#import "LYPhotoFilter.h"

@implementation LYPhotoFilter

+ (NSArray *)filterNames
{
    return @[
             @"CIPhotoEffectChrome",// 铬黄
             @"CIPhotoEffectFade",// 褪色
             @"CIPhotoEffectInstant",// 怀旧
             @"CIPhotoEffectMono",// 单色
             @"CIPhotoEffectNoir",// 暗色
             @"CIPhotoEffectProcess",// 冲印
             @"CIPhotoEffectTonal",// 色调
             @"CIPhotoEffectTransfer",// 岁月
             @"CILinearToSRGBToneCurve",// 曲线
             @"CISRGBToneCurveToLinear",// 直线
             @"CIColorMonochrome",// 单色画
             @"CIColorPosterize",// 海报
             @"CISepiaTone"// 褐色
             
             ];
}

+ (NSArray *)filterDisplayNames
{
    return @[
             @"铬黄",
             @"褪色",
             @"怀旧",
             @"单色",
             @"暗色",
             @"冲印",
             @"色调",
             @"岁月",
             @"曲线",
             @"直线",
             @"单色画",
             @"海报",
             @"褐色"
             ];
}

+ (CIFilter *)defaultFilter
{
    return [CIFilter filterWithName:[self filterNames][0]];
}

+ (CIFilter *)filterWithName:(NSString *)filterName
{
    for (NSString *name in [self filterNames]) {
        if ([name containsString:filterName]) {
            return [CIFilter filterWithName:filterName];
        }
    }
    
    return nil;
}

@end
