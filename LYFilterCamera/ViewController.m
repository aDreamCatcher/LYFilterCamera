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
    _cameraView.frame = [UIScreen mainScreen].bounds;
    [self.view addSubview:_cameraView];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (BOOL)shouldAutorotate
{
    return YES;
}

- (UIInterfaceOrientationMask)supportedInterfaceOrientations
{
    return UIInterfaceOrientationMaskPortrait;
}

- (BOOL)prefersStatusBarHidden
{
    return YES;
}

#pragma mark - Utility


@end
