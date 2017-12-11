//
//  RecordVideoViewController.m
//  FaceMe
//
//  Created by SiyangLiu on 2017/12/10.
//  Copyright © 2017年 SiyangLiu. All rights reserved.
//

#import <opencv2/opencv.hpp>
#import <opencv2/videoio/cap_ios.h>

#import "RecordVideoViewController.h"
#import "ProcessImage.h"

using namespace cv;

@interface RecordVideoViewController () <CvVideoCameraDelegate>

@property (weak, nonatomic) IBOutlet UIImageView *imageView;
@property (nonatomic, strong) CvVideoCamera *videoCamera;
@property (nonatomic, strong) ProcessImage *processer;

@end

@implementation RecordVideoViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.imageView.layer.borderColor = [UIColor.blackColor CGColor];
    self.imageView.layer.borderWidth = 1.0;
    
    self.videoCamera = [[CvVideoCamera alloc] initWithParentView:self.imageView];
    self.videoCamera.delegate = self;
    self.videoCamera.defaultAVCaptureDevicePosition = AVCaptureDevicePositionFront;
    self.videoCamera.defaultAVCaptureSessionPreset = AVCaptureSessionPresetiFrame1280x720;
    self.videoCamera.defaultAVCaptureVideoOrientation = AVCaptureVideoOrientationPortrait;
    //    NSLog(@"%d", self.videoCamera.defaultFPS);
    self.videoCamera.defaultFPS = 25;   // Default 15
    self.videoCamera.grayscaleMode = NO;
    self.videoCamera.recordVideo = YES;
    
    self.processer = [[ProcessImage alloc] init];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)startButtonClick:(UIButton *)sender {
    [self.videoCamera start];
}

- (IBAction)stopButtonClick:(UIButton *)sender {
    dispatch_queue_t queue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 0);
    dispatch_async(queue, ^{
        [self.videoCamera stop];
        if (UIVideoAtPathIsCompatibleWithSavedPhotosAlbum([[self.videoCamera videoFileURL] absoluteURL].path)) {
            UISaveVideoAtPathToSavedPhotosAlbum([[self.videoCamera videoFileURL] absoluteURL].path, self, @selector(video:didFinishSavingWithError:contextInfo:), NULL);
        }
    });
}

#pragma mark 视频保存完毕的回调
- (void)video:(NSString *)videoPath didFinishSavingWithError:(NSError *)error contextInfo:(void *)contextInf{
    if (error) {
        NSLog(@"保存视频过程中发生错误，错误信息:%@",error.localizedDescription);
    }
}

- (UIInterfaceOrientationMask)supportedInterfaceOrientations {
    // Only portrait orientation
    return UIInterfaceOrientationMaskPortrait;
}

- (void)processImage:(cv::Mat &)image {
    if (self.stickerIndex == 0) {
        [self.processer addEarAndBeard:image];
    } else if (self.stickerIndex == 1) {
        [self.processer addSmileFace:image];
    }
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    [self.videoCamera stop];
}

@end
