//
//  ViewController.m
//  LYFilterCamera
//
//  Created by kuner on 16/8/25.
//  Copyright © 2016年 kuner. All rights reserved.
//

#import "ViewController.h"
#import "LYCameraCollectionView.h"

@interface ViewController (){
    LYCameraCollectionView *_cameraView;
}

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    
    _cameraView = [[LYCameraCollectionView alloc] init];
    
    [self.view addSubview:_cameraView];
}

- (void)viewDidLayoutSubviews
{
    [super viewDidLayoutSubviews];
    
    _cameraView.frame = self.view.bounds;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Utility


@end
