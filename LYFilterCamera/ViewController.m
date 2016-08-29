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
    
    UIView                  *_bgView;
    UIActivityIndicatorView *_indicatorView;
    UILabel                 *_resultLab;
    
    //
    LYCameraCollectionView *_cameraView;
}

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self setupUI];
    
    [self registerNotification];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - UI

- (void)setupUI
{
    _cameraView = [[LYCameraCollectionView alloc] init];
    _cameraView.frame = [UIScreen mainScreen].bounds;
    [self.view addSubview:_cameraView];
    
    // loading
    _bgView = [[UIView alloc] init];
    
    _bgView.backgroundColor = [UIColor colorWithWhite:0 alpha:0.2];
    
    _indicatorView = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhiteLarge];
    _indicatorView.hidesWhenStopped = YES;
    [_bgView addSubview:_indicatorView];
    
    _resultLab = [[UILabel alloc] init];
    _resultLab.backgroundColor = [UIColor clearColor];
    _resultLab.textAlignment = NSTextAlignmentCenter;
    _resultLab.text = @"完成";
    [_bgView addSubview:_resultLab];
    
    _resultLab.alpha = 0.0;
    
    // setFrame
    [self setupUIFrame];
}

- (void)setupUIFrame
{
    _bgView.frame = [UIScreen mainScreen].bounds;
    _indicatorView.frame = CGRectMake((_bgView.frame.size.width-50)*0.5, 300, 50, 50);
    _resultLab.frame = CGRectMake((_bgView.frame.size.width - 200)*0.5, 350, 200, 50);
}

- (void)startLoading
{
    if (_bgView.superview == nil) {
        dispatch_async(dispatch_get_main_queue(), ^{
            [[UIApplication sharedApplication].keyWindow addSubview:_bgView];
            
            [_indicatorView startAnimating];
        });
    }
    
}

- (void)endLoading
{
    dispatch_async(dispatch_get_main_queue(), ^{
        [_indicatorView stopAnimating];
        
        [self showResultLab];
    });
}

- (void)showResultLab
{
    [UIView animateWithDuration:1.0 animations:^{
        _resultLab.alpha = 1.0;
    } completion:^(BOOL finished) {
        _resultLab.alpha = 0.0;
        [_bgView removeFromSuperview];
    }];
}

#pragma mark - rotate

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

- (void)registerNotification
{
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(startLoading) name:kLYCameraWillWriteVideoNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(endLoading) name:kLYCameraDidWriteVideoNotification object:nil];
}


@end
