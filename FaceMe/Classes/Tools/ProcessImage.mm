//
//  ProcessImage.m
//  FaceMe
//
//  Created by SiyangLiu on 2017/12/10.
//  Copyright © 2017年 SiyangLiu. All rights reserved.
//

#import "ProcessImage.h"
#import <vector>

using std::vector;

@interface ProcessImage () {
    CascadeClassifier cascade;
    Mat earLeft;
    Mat earRight;
    Mat beardLeft;
    Mat beardRight;
    Mat faceLeft;
    Mat faceRight;
    double scale;
}

@end

@implementation ProcessImage

- (instancetype)init {
    if (self = [super init]) {
        scale = 2.5;
        
        NSString *path = [[NSBundle mainBundle] pathForResource:@"haarcascade_frontalface_alt2.xml" ofType:nil];
        cascade.load(path.UTF8String);
        
        path = [[NSBundle mainBundle] pathForResource:@"ear_left.png" ofType:nil];
        earLeft = imread(path.UTF8String, -1);
        
        path = [[NSBundle mainBundle] pathForResource:@"ear_right.png" ofType:nil];
        earRight = imread(path.UTF8String, -1);
        
        path = [[NSBundle mainBundle] pathForResource:@"beard_left.png" ofType:nil];
        beardLeft = imread(path.UTF8String, -1);
        
        path = [[NSBundle mainBundle] pathForResource:@"beard_right.png" ofType:nil];
        beardRight = imread(path.UTF8String, -1);
        
        path = [[NSBundle mainBundle] pathForResource:@"face_left.png" ofType:nil];
        faceLeft = imread(path.UTF8String, -1);
        
        path = [[NSBundle mainBundle] pathForResource:@"face_right.png" ofType:nil];
        faceRight = imread(path.UTF8String, -1);
    }
    return self;
}

- (void)addEarAndBeard:(Mat &)img{
    double t = 0;
    vector<cv::Rect> faces;
    
    Mat gray, smallImg(cvRound(img.rows / scale), cvRound(img.cols / scale), CV_8UC1);//将图片缩小，加快检测速度
    
    cvtColor(img, gray, CV_BGR2GRAY);//因为用的是类haar特征，所以都是基于灰度图像的，这里要转换成灰度图像
    resize(gray, smallImg, smallImg.size(), 0, 0, INTER_LINEAR);//将尺寸缩小到1/scale,用线性插值
    equalizeHist(smallImg, smallImg);//直方图均衡
    
    t = (double)cvGetTickCount();//用来计算算法执行时间
    //检测人脸
    //detectMultiScale函数中smallImg表示的是要检测的输入图像为smallImg，faces表示检测到的人脸目标序列，1.1表示
    //每次图像尺寸减小的比例为1.1，2表示每一个目标至少要被检测到3次才算是真的目标(因为周围的像素和不同的窗口大
    //小都可以检测到人脸),CV_HAAR_SCALE_IMAGE表示不是缩放分类器来检测，而是缩放图像，Size(30, 30)为目标的
    //最小最大尺寸
    cascade.detectMultiScale(smallImg, faces,
                             1.1, 2, 0
                             //|CV_HAAR_FIND_BIGGEST_OBJECT
                             //|CV_HAAR_DO_ROUGH_SEARCH
                             | CV_HAAR_SCALE_IMAGE
                             ,
                             cv::Size(30, 30));
    
    t = (double)cvGetTickCount() - t;//相减为算法执行的时间
    printf("detection time = %g ms\n", t / ((double)cvGetTickFrequency() * 1000.0));
    for (int i = 0; i < faces.size(); i++)
    {
        Mat smallImgROI;
        vector<cv::Rect> nestedObjects;
        cv::Point center;
        //还原成原来的大小
        cv::Rect faceRect = faces[i];
        faceRect.x *= scale;
        faceRect.y *= scale;
        faceRect.width *= scale;
        faceRect.height *= scale;
//        rectangle(img, faceRect, color, 2, 8, 0);
        // 添加左耳朵
        Mat srcImage = earLeft.clone();
        double widthScaleFactor = 0.000609;
        double heightScaleFactor = 0.000609;
        int oldWidth = srcImage.cols;
        int oldHeight = srcImage.rows;
        int newWidth = oldWidth * widthScaleFactor * faceRect.width;
        int newHeight = oldHeight * heightScaleFactor * faceRect.height;
        resize(srcImage, srcImage, cv::Size(newWidth, newHeight));
        double xPositionFactor = 0.09136;
        int x = faceRect.x + faceRect.width * xPositionFactor;
        int yOffset = -210;
        int y = faceRect.y + widthScaleFactor * faceRect.width * yOffset;
        cv::Point point(x, y);
        [self addImage:srcImage to:img at:point];
        // 添加右耳朵
        srcImage = earRight.clone();
        widthScaleFactor = 0.000609;
        heightScaleFactor = 0.000609;
        oldWidth = srcImage.cols;
        oldHeight = srcImage.rows;
        newWidth = oldWidth * widthScaleFactor * faceRect.width;
        newHeight = oldHeight * heightScaleFactor * faceRect.height;
        resize(srcImage, srcImage, cv::Size(newWidth, newHeight));
        xPositionFactor = 0.78563;
        x = faceRect.x + faceRect.width * xPositionFactor;
        yOffset = -210;
        y = faceRect.y + widthScaleFactor * faceRect.width * yOffset;
        point = cv::Point(x, y);
        [self addImage:srcImage to:img at:point];
        // 添加左胡子
        srcImage = beardLeft.clone();
        widthScaleFactor = 0.000609;
        heightScaleFactor = 0.000609;
        oldWidth = srcImage.cols;
        oldHeight = srcImage.rows;
        newWidth = oldWidth * widthScaleFactor * faceRect.width;
        newHeight = oldHeight * heightScaleFactor * faceRect.height;
        resize(srcImage, srcImage, cv::Size(newWidth, newHeight));
        xPositionFactor = 0.10353;
        x = faceRect.x + faceRect.width * xPositionFactor;
        double yPositionFactor = 0.56638;
        y = faceRect.y + faceRect.height * yPositionFactor;
        point = cv::Point(x, y);
        [self addImage:srcImage to:img at:point];
        // 添加右胡子
        srcImage = beardRight.clone();
        widthScaleFactor = 0.00051156;
        heightScaleFactor = 0.000482125;
        oldWidth = srcImage.cols;
        oldHeight = srcImage.rows;
        newWidth = oldWidth * widthScaleFactor * faceRect.width;
        newHeight = oldHeight * heightScaleFactor * faceRect.height;
        resize(srcImage, srcImage, cv::Size(newWidth, newHeight));
        xPositionFactor = 0.81608;
        x = faceRect.x + faceRect.width * xPositionFactor;
        yPositionFactor = 0.55420;
        y = faceRect.y + faceRect.height * yPositionFactor;
        point = cv::Point(x, y);
        [self addImage:srcImage to:img at:point];
    }
}

- (void)addSmileFace:(Mat &)img {
    double t = 0;
    vector<cv::Rect> faces;
    
    Mat gray, smallImg(cvRound(img.rows / scale), cvRound(img.cols / scale), CV_8UC1);//将图片缩小，加快检测速度
    
    cvtColor(img, gray, CV_BGR2GRAY);//因为用的是类haar特征，所以都是基于灰度图像的，这里要转换成灰度图像
    resize(gray, smallImg, smallImg.size(), 0, 0, INTER_LINEAR);//将尺寸缩小到1/scale,用线性插值
    equalizeHist(smallImg, smallImg);//直方图均衡
    
    t = (double)cvGetTickCount();//用来计算算法执行时间
    //检测人脸
    //detectMultiScale函数中smallImg表示的是要检测的输入图像为smallImg，faces表示检测到的人脸目标序列，1.1表示
    //每次图像尺寸减小的比例为1.1，2表示每一个目标至少要被检测到3次才算是真的目标(因为周围的像素和不同的窗口大
    //小都可以检测到人脸),CV_HAAR_SCALE_IMAGE表示不是缩放分类器来检测，而是缩放图像，Size(30, 30)为目标的
    //最小最大尺寸
    cascade.detectMultiScale(smallImg, faces,
                             1.1, 2, 0
                             //|CV_HAAR_FIND_BIGGEST_OBJECT
                             //|CV_HAAR_DO_ROUGH_SEARCH
                             | CV_HAAR_SCALE_IMAGE
                             ,
                             cv::Size(30, 30));
    
    t = (double)cvGetTickCount() - t;//相减为算法执行的时间
    printf("detection time = %g ms\n", t / ((double)cvGetTickFrequency() * 1000.0));
    for (int i = 0; i < faces.size(); i++)
    {
        Mat smallImgROI;
        vector<cv::Rect> nestedObjects;
        cv::Point center;
        //还原成原来的大小
        cv::Rect faceRect = faces[i];
        faceRect.x *= scale;
        faceRect.y *= scale;
        faceRect.width *= scale;
        faceRect.height *= scale;
//        rectangle(img, faceRect, color, 2, 8, 0);
        // 添加笑脸
        Mat srcImage = faceLeft.clone();
        double widthScaleFactor = 0.000516020;
        double heightScaleFactor = 0.000526893;
        int oldWidth = srcImage.cols;
        int oldHeight = srcImage.rows;
        int newWidth = oldWidth * widthScaleFactor * faceRect.width;
        int newHeight = oldHeight * heightScaleFactor * faceRect.height;
        resize(srcImage, srcImage, cv::Size(newWidth, newHeight));
        double xPositionFactor = 0.082803;
        int x = faceRect.x + faceRect.width * xPositionFactor;
        double yPositionFactor = 0.55096;
        int y = faceRect.y + faceRect.height * yPositionFactor;
        cv::Point point = cv::Point(x, y);
        [self addImage:srcImage to:img at:point];
        // 添加左胡子
        srcImage = faceRight.clone();
        widthScaleFactor = 0.00052830;
        heightScaleFactor = 0.000538234;
        oldWidth = srcImage.cols;
        oldHeight = srcImage.rows;
        newWidth = oldWidth * widthScaleFactor * faceRect.width;
        newHeight = oldHeight * heightScaleFactor * faceRect.height;
        resize(srcImage, srcImage, cv::Size(newWidth, newHeight));
        xPositionFactor = 0.74098;
        x = faceRect.x + faceRect.width * xPositionFactor;
        yPositionFactor = 0.51911;
        y = faceRect.y + faceRect.height * yPositionFactor;
        point = cv::Point(x, y);
        [self addImage:srcImage to:img at:point];
    }
}

void addImageToImage(Mat& srcImage, Mat& destImage, cv::Point& position) {
    //【2】定义一个Mat类型并给其设定ROI区域
    Mat imageROI = destImage(cv::Rect(position.x, position.y, srcImage.cols, srcImage.rows));    //450，20为自定义起始点坐标
    //【3】加载掩模（必须是灰度图）
    Mat mask;
    cvtColor(srcImage.clone(), mask, COLOR_BGR2GRAY);
    threshold(mask, mask, 254, 255, CV_THRESH_BINARY);
    Mat mask1 = 255 - mask;
    //【4】将掩模复制到ROI
    srcImage.copyTo(imageROI, mask1);
}

//- (void)addImage:(Mat &)srcImage to:(Mat &)destImage at:(cv::Point &)position {
//    //【2】定义一个Mat类型并给其设定ROI区域
//    Mat imageROI = destImage(cv::Rect(position.x, position.y, srcImage.cols, srcImage.rows));    //450，20为自定义起始点坐标
//    //【3】加载掩模（必须是灰度图）
//    Mat mask;
//    cvtColor(srcImage.clone(), mask, COLOR_BGR2GRAY);
//    threshold(mask, mask, 254, 255, CV_THRESH_BINARY);
//    Mat mask1 = 255 - mask;
//    //【4】将掩模复制到ROI
//    srcImage.copyTo(imageROI, mask1);
//}

- (void)addImage:(Mat &)srcImage to:(Mat &)destImage at:(cv::Point &)position {
    int xStart = position.x;
    int yStart = position.y;
    for (int i = 0; i < srcImage.rows; i++) {
        for (int j = 0; j < srcImage.cols; j++) {
            Vec4b channels = srcImage.at<Vec4b>(i, j);
            if (channels[3] != 0) {
                destImage.at<Vec4b>(i + yStart, j + xStart) = channels;
            }
        }
    }
}

@end
