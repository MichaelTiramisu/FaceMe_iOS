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
#import "ProcessImage.h"

using namespace cv;

@interface TakePictureViewController () <CvVideoCameraDelegate>

@property (weak, nonatomic) IBOutlet UIImageView *imageView;
@property (nonatomic, strong) CvVideoCamera *videoCamera;
@property (nonatomic, strong) ProcessImage *processer;

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
    self.videoCamera.defaultAVCaptureSessionPreset = AVCaptureSessionPresetiFrame1280x720;
    self.videoCamera.defaultAVCaptureVideoOrientation = AVCaptureVideoOrientationPortrait;
//    NSLog(@"%d", self.videoCamera.defaultFPS);
    self.videoCamera.defaultFPS = 25;   // Default 15
    self.videoCamera.grayscaleMode = NO;
    
    self.processer = [[ProcessImage alloc] init];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)startButtonClick:(UIButton *)sender {
    [self.videoCamera start];
}

- (IBAction)takePictureButtonClick:(UIButton *)sender {
    dispatch_queue_t queue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 0);
    dispatch_async(queue, ^{
        UIImage *image = [self imageWithUIView:self.imageView];
        [self.videoCamera stop];
        UIImageWriteToSavedPhotosAlbum(image, nil, nil, NULL);
        dispatch_async(dispatch_get_main_queue(), ^{
            [self.imageView setImage:image];
        });
//        if (UIVideoAtPathIsCompatibleWithSavedPhotosAlbum([[self.videoCamera videoFileURL] absoluteURL].path)) {
//            UISaveVideoAtPathToSavedPhotosAlbum([[self.videoCamera videoFileURL] absoluteURL].path, self, @selector(video:didFinishSavingWithError:contextInfo:), NULL);
//        }
    });
//    [self.videoCamera saveVideo];
//    NSString* relativePath = [self.videoCamera.videoFileURL relativePath];
//    if (UIVideoAtPathIsCompatibleWithSavedPhotosAlbum(relativePath)) {
//        dispatch_queue_t queue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_LOW, 0);
//        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(10 * NSEC_PER_SEC)), queue, ^{
//            
////            UISaveVideoAtPathToSavedPhotosAlbum(relativePath, self, @selector(video:didFinishSavingWithError:contextInfo:), nil);
//        });
////        dispatch_async(queue, ^{
//////            NSString *temp = NSTemporaryDirectory();
//////            NSFileManager *manager = [NSFileManager defaultManager];
//////            if ([manager fileExistsAtPath:temp]) {
//////                [manager removeItemAtPath:temp error:nil];
//////            }
////        });
//    }
////    if (UIVideoAtPathIsCompatibleWithSavedPhotosAlbum([[self.videoCamera videoFileURL] absoluteURL].path)) {
////        UISaveVideoAtPathToSavedPhotosAlbum([[self.videoCamera videoFileURL] absoluteURL].path, self, @selector(video:didFinishSavingWithError:contextInfo:), NULL);
////    }
}

- (UIImage *)imageWithUIView:(UIView*) view {
    UIGraphicsBeginImageContext(view.bounds.size);
    CGContextRef context = UIGraphicsGetCurrentContext();
    [view.layer renderInContext:context];
    UIImage* tImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return tImage;
}

#pragma mark 视频保存完毕的回调
- (void)video:(NSString *)videoPath didFinishSavingWithError:(NSError *)error contextInfo:(void *)contextInf{
    if (error) {
        NSLog(@"保存视频过程中发生错误，错误信息:%@",error.localizedDescription);
    }
}

//- (void)video:(NSString *)videoPath didFinishSavingWithError:(NSError *)error contextInfo:(void *) contextInfo {
//    NSLog(@"%@", error);
//}

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
