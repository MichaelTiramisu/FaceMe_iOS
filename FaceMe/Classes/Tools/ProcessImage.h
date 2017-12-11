//
//  ProcessImage.h
//  FaceMe
//
//  Created by SiyangLiu on 2017/12/10.
//  Copyright © 2017年 SiyangLiu. All rights reserved.
//

#import <opencv2/opencv.hpp>
#import <opencv2/videoio/cap_ios.h>

#import <Foundation/Foundation.h>

using namespace cv;

@interface ProcessImage : NSObject

- (void)addEarAndBeard:(Mat &)img;
- (void)addSmileFace:(Mat &)img;

@end
