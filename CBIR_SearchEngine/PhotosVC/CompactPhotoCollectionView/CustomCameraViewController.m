//
//  CustomCameraViewController.m
//  TestAboutALL
//
//  Created by Zac on 2017/6/1.
//  Copyright © 2017年 周桐. All rights reserved.
//

#import "CustomCameraViewController.h"
#import <AVFoundation/AVFoundation.h>

@interface CustomCameraViewController ()
//捕获设备，通常是前置摄像头，后置摄像头，麦克风（音频输入）
@property (nonatomic, strong) AVCaptureDevice *device;

//AVCaptureDeviceInput 代表输入设备，他使用AVCaptureDevice 来初始化
@property (nonatomic, strong) AVCaptureDeviceInput *input;

//输出图片
@property (nonatomic ,strong) AVCaptureStillImageOutput *imageOutput;

//session：由他把输入输出结合在一起，并开始启动捕获设备（摄像头）
@property (nonatomic, strong) AVCaptureSession *session;

//图像预览层，实时显示捕获的图像
@property (nonatomic ,strong) AVCaptureVideoPreviewLayer *previewLayer;

@property (nonatomic, strong) UIImage *image;


- (IBAction)btn:(id)sender;
@property (weak, nonatomic) IBOutlet UIImageView *cameraImageView;


@end

@implementation CustomCameraViewController

// 初始化各个对象
- (void)cameraDistrict
{
    //    AVCaptureDevicePositionBack  后置摄像头
    //    AVCaptureDevicePositionFront 前置摄像头
    self.device = [self cameraWithPosition:AVCaptureDevicePositionBack];
    self.input = [[AVCaptureDeviceInput alloc] initWithDevice:self.device error:nil];
    
    self.imageOutput = [[AVCaptureStillImageOutput alloc] init];
    
    self.session = [[AVCaptureSession alloc] init];
    //     拿到的图像的大小可以自行设定
    //    AVCaptureSessionPreset320x240
    //    AVCaptureSessionPreset352x288
    //    AVCaptureSessionPreset640x480
    //    AVCaptureSessionPreset960x540
    //    AVCaptureSessionPreset1280x720
    //    AVCaptureSessionPreset1920x1080
    //    AVCaptureSessionPreset3840x2160
    self.session.sessionPreset = AVCaptureSessionPreset352x288;
    //输入输出设备结合
    if ([self.session canAddInput:self.input]) {
        [self.session addInput:self.input];
    }
    if ([self.session canAddOutput:self.imageOutput]) {
        [self.session addOutput:self.imageOutput];
    }
    //预览层的生成
    self.previewLayer = [[AVCaptureVideoPreviewLayer alloc] initWithSession:self.session];
    self.previewLayer.frame = self.cameraImageView.bounds;
    self.previewLayer.videoGravity = AVLayerVideoGravityResizeAspectFill;
    [self.cameraImageView.layer addSublayer:self.previewLayer];
    //设备取景开始
    [self.session startRunning];
    if ([_device lockForConfiguration:nil]) {
        //自动闪光灯，
        if ([_device isFlashModeSupported:AVCaptureFlashModeAuto]) {
            [_device setFlashMode:AVCaptureFlashModeAuto];
        }
        //自动白平衡,但是好像一直都进不去
        if ([_device isWhiteBalanceModeSupported:AVCaptureWhiteBalanceModeAutoWhiteBalance]) {
            [_device setWhiteBalanceMode:AVCaptureWhiteBalanceModeAutoWhiteBalance];
        }
        [_device unlockForConfiguration];
    }
    
}
//根据相应位置拿到摄像头
- (AVCaptureDevice *)cameraWithPosition:(AVCaptureDevicePosition)position{
    NSArray *devices = [AVCaptureDevice devicesWithMediaType:AVMediaTypeVideo];
    for ( AVCaptureDevice *device in devices )
        if ( device.position == position ){
            return device;
        }
    return nil;
}
//点击拍照拿到相应照片
- (void)photoBtnDidClick
{
    AVCaptureConnection *conntion = [self.imageOutput connectionWithMediaType:AVMediaTypeVideo];
    if (!conntion)
    {
        NSLog(@"拍照失败!");
        return;
    }
    [self.imageOutput captureStillImageAsynchronouslyFromConnection:conntion completionHandler:^(CMSampleBufferRef imageDataSampleBuffer, NSError *error) {
        if (imageDataSampleBuffer == nil)
        {
            return ;
        }
        NSData *imageData = [AVCaptureStillImageOutput jpegStillImageNSDataRepresentation:imageDataSampleBuffer];
        self.image = [UIImage imageWithData:imageData];
        [self.session stopRunning];
        [self.view addSubview:self.cameraImageView];
    }];
}

//#pragma - 保存至相册
- (void)saveImageToPhotoAlbum:(UIImage*)savedImage
{
        UIImageWriteToSavedPhotosAlbum(savedImage, self, @selector(image:didFinishSavingWithError:contextInfo:), NULL);
}
// 指定回调方法
- (void)image: (UIImage *) image didFinishSavingWithError: (NSError *) error contextInfo: (void *) contextInfo
{
    NSString *msg = nil ;
    if(error != NULL){
        msg = @"保存图片失败" ;
    }else{
        msg = @"保存图片成功";
    }
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"保存图片结果提示"
                                                        message:msg
                                                       delegate:self
                                              cancelButtonTitle:@"确定"
                                              otherButtonTitles:nil];
    [alert show];
}
     

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
//    self.cameraImageView;
    
    [self cameraDistrict];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}



- (IBAction)btn:(id)sender {
    [self photoBtnDidClick];
}
@end
