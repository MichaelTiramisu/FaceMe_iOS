//
//  TakePictureViewController.m
//  FaceMe
//
//  Created by SiyangLiu on 2017/12/10.
//  Copyright © 2017年 SiyangLiu. All rights reserved.
//

#import <opencv2/opencv.hpp>
#import <opencv2/videoio/cap_ios.h>

#import "TakePictureViewController.h"

using namespace cv;

@interface TakePictureViewController () <CvVideoCameraDelegate>

@property (weak, nonatomic) IBOutlet UIImageView *imageView;
@property (nonatomic, strong) CvVideoCamera *videoCamera;

@end

@implementation TakePictureViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.imageView.layer.borderColor = [UIColor.blackColor CGColor];
    self.imageView.layer.borderWidth = 1.0;
    
    self.videoCamera = [[CvVideoCamera alloc] initWithParentView:self.imageView];
    self.videoCamera.delegate = self;
    self.videoCamera.defaultAVCaptureDevicePosition = AVCaptureDevicePositionFront;
    self.videoCamera.defaultAVCaptureSessionPreset = AVCaptureSessionPreset1280x720;
    self.videoCamera.defaultAVCaptureVideoOrientation = AVCaptureVideoOrientationPortrait;
//    NSLog(@"%d", self.videoCamera.defaultFPS);
    self.videoCamera.defaultFPS = 25;   // Default 15
    self.videoCamera.grayscaleMode = NO;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)takePictureButtonClick:(UIButton *)sender {
    [self.videoCamera start];
}

- (void)processImage:(cv::Mat &)image {
//    cvtColor(image, image, CV_BGR2);
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    [self.videoCamera stop];
}

@end
