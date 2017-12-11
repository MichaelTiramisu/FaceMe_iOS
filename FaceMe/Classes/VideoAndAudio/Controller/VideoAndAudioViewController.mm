//
//  VideoAndAudioViewController.m
//  FaceMe
//
//  Created by SiyangLiu on 2017/12/11.
//  Copyright © 2017年 SiyangLiu. All rights reserved.
//

#import <opencv2/opencv.hpp>
#import <opencv2/videoio/cap_ios.h>

#import "VideoAndAudioViewController.h"
#import "ProcessImage.h"
#import "MediaManager.h"

using namespace cv;

@interface VideoAndAudioViewController () <CvVideoCameraDelegate>

@property (weak, nonatomic) IBOutlet UIImageView *imageView;
@property (nonatomic, strong) CvVideoCamera *videoCamera;
@property (nonatomic, strong) ProcessImage *processer;

@end

@implementation VideoAndAudioViewController

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
//        if (UIVideoAtPathIsCompatibleWithSavedPhotosAlbum([[self.videoCamera videoFileURL] absoluteURL].path)) {
//            UISaveVideoAtPathToSavedPhotosAlbum([[self.videoCamera videoFileURL] absoluteURL].path, self, @selector(video:didFinishSavingWithError:contextInfo:), NULL);
//        }
        if (UIVideoAtPathIsCompatibleWithSavedPhotosAlbum([[self.videoCamera videoFileURL] absoluteURL].path)) {
            AVURLAsset * asset = [AVURLAsset assetWithURL:[[self.videoCamera videoFileURL] absoluteURL]];
#pragma mark - 这地方是可以优化时间的, 精确到mm
            CMTime time = [asset duration];
            int seconds = ceil(time.value/time.timescale);
            NSURL *audioUrl = [[NSBundle mainBundle] URLForResource:@"pikachu_sounds.mp3" withExtension:nil];
            [MediaManager addBackgroundMiusicWithVideoUrlStr:[[self.videoCamera videoFileURL] absoluteURL] audioUrl:audioUrl andCaptureVideoWithRange:NSMakeRange(0, seconds) completion:^{
                NSLog(@"视频合并完成");
                NSString *mediaFileName = @"MixVideo.mov";
                NSString *outPutPath = [NSTemporaryDirectory() stringByAppendingPathComponent:mediaFileName];
                if ([[NSFileManager defaultManager] fileExistsAtPath:outPutPath]) {
                    UISaveVideoAtPathToSavedPhotosAlbum(outPutPath, self, @selector(video:didFinishSavingWithError:contextInfo:), NULL);
                }
            }];
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
    [self.processer addPikachu:image];
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    dispatch_queue_t queue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0);
    dispatch_async(queue, ^{
        [self.videoCamera stop];
    });
}

@end
