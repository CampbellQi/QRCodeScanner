//
//  WQQRScanViewController.m
//  QRCodeScanner
//
//  Created by 冯万琦 on 2017/1/12.
//  Copyright © 2017年 yidian. All rights reserved.
//

#import "WQQRScanViewController.h"
#import <AVFoundation/AVFoundation.h>
#import "WQScanRectDrawView.h"
#import "WQAlertView.h"

static const char *kScanQRCodeQueueName = "ScanQRCodeQueue";
@interface WQQRScanViewController ()<AVCaptureMetadataOutputObjectsDelegate,UIAlertViewDelegate,UIImagePickerControllerDelegate,UINavigationControllerDelegate, WQScanRectDrawViewDelegate>
{
    //扫描框边长比例
    float _squareScale;
    //扫描框位置
    float _squareX;
    float _squareY;
    //扫描框边长
    float _squareLength;
}
@property (nonatomic) AVCaptureSession *captureSession;
@property (nonatomic) AVCaptureVideoPreviewLayer *videoPreviewLayer;
@property (nonatomic) BOOL lastResult;
//扫描线
@property (nonatomic,strong)UIImageView *scanningLine;
//扫描框
@property (nonatomic,strong)WQScanRectDrawView *scanRectDrawView;

@end

@implementation WQQRScanViewController

#pragma mark Life Circle
- (void)viewDidLoad {
    [super viewDidLoad];
    self.title = @"扫一扫";
    
    [self setUpData];
    [self setUpView];
    [self startReading];
}

- (void)setUpView {
    self.view.backgroundColor = [UIColor clearColor];
    //计算扫描框位置、大小
    _squareScale = 0.6;
    _squareX = self.view.layer.bounds.size.width*(1-_squareScale) / 2;
    _squareY = self.view.layer.bounds.size.height * (1-_squareScale) / 2;
    _squareLength = self.view.layer.bounds.size.width * _squareScale;
    
    //矩形框
    _scanRectDrawView = [[WQScanRectDrawView alloc]initWithFrame:self.view.bounds DrawRect:CGRectMake(_squareX, _squareY, _squareLength, _squareLength)];
    _scanRectDrawView.backgroundColor = [UIColor colorWithRed:0 green:0 blue:0 alpha:0.5];
    //    _drawView.alpha = 0.5;
    _scanRectDrawView.delegate = self;
    
    
    //扫描线
    UIImage *image = [UIImage imageNamed:@"scanning_line"];
    _scanningLine = [[UIImageView alloc]initWithFrame:CGRectMake(_squareX, _squareY-image.size.height/2, _squareLength, image.size.height)];
    _scanningLine.image = image;
    
}

- (void)setUpData {
    
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    _lastResult = YES;
//    [_captureSession startRunning];
}

- (void)viewDidDisappear:(BOOL)animated {
    [super viewDidDisappear:animated];
//    [_captureSession stopRunning];
}
#pragma mark Private Function
//打开本地图库
- (void)openLocalPhoto
{
    UIImagePickerController *picker = [[UIImagePickerController alloc] init];
    
    picker.sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
    
    picker.delegate = self;
    
    picker.allowsEditing = YES;
    
    
    [self presentViewController:picker animated:YES completion:nil];
}

//初始化输入输出流
- (BOOL)startReading
{
    // 获取 AVCaptureDevice 实例
    NSError * error;
    AVCaptureDevice *captureDevice = [AVCaptureDevice defaultDeviceWithMediaType:AVMediaTypeVideo];
    // 初始化输入流
    AVCaptureDeviceInput *input = [AVCaptureDeviceInput deviceInputWithDevice:captureDevice error:&error];
    
    if (!input) {
        NSLog(@"%@", [error localizedDescription]);
        return NO;
    }
    // 创建会话
    _captureSession = [[AVCaptureSession alloc] init];
    // 添加输入流
    [_captureSession addInput:input];
    // 初始化输出流
    AVCaptureMetadataOutput *captureMetadataOutput = [[AVCaptureMetadataOutput alloc] init];
    //设置扫描区域 注:这里CGRectMake中填写的数字是0-1,并且x与y互换,height与width互换
    [captureMetadataOutput setRectOfInterest:CGRectMake(_squareY/self.view.layer.bounds.size.height, _squareX/self.view.layer.bounds.size.width,  _squareScale, _squareScale)];
    
    
    // 添加输出流
    [_captureSession addOutput:captureMetadataOutput];
    
    // 创建dispatch queue.
    dispatch_queue_t dispatchQueue;
    dispatchQueue = dispatch_queue_create(kScanQRCodeQueueName, NULL);
    [captureMetadataOutput setMetadataObjectsDelegate:self queue:dispatchQueue];
    // 设置元数据类型 AVMetadataObjectTypeQRCode
    [captureMetadataOutput setMetadataObjectTypes:[NSArray arrayWithObject:AVMetadataObjectTypeQRCode]];
    
    // 创建输出对象
    _videoPreviewLayer = [[AVCaptureVideoPreviewLayer alloc] initWithSession:_captureSession];
    [_videoPreviewLayer setVideoGravity:AVLayerVideoGravityResizeAspectFill];
    
    [_videoPreviewLayer setFrame:self.view.layer.bounds];
    [self.view.layer addSublayer:_videoPreviewLayer];
    
    
    [self.view addSubview:_scanRectDrawView];
    [self.view addSubview:_scanningLine];
    
    //选定一块区域,设置不同的透明度
    UIBezierPath *path = [UIBezierPath bezierPathWithRect:CGRectMake(0, 0,  self.view.bounds.size.width,  self.view.bounds.size.height)];
    
    [path appendPath:[[UIBezierPath bezierPathWithRoundedRect:CGRectMake(_squareX, _squareY, _squareLength, _squareLength) cornerRadius:0] bezierPathByReversingPath]];
    CAShapeLayer *shapeLayer = [CAShapeLayer layer];
    shapeLayer.path = path.CGPath;
    [_scanRectDrawView.layer setMask:shapeLayer];
    
    // 开始会话
    [_captureSession startRunning];
    [self stepAnimation];
    
    return YES;
}
//扫描线动画
- (void)stepAnimation
{
    float height = CGRectGetHeight(_scanningLine.frame);
    float x = CGRectGetMinX(_scanningLine.frame);
    CGRect frame = CGRectMake(x, _squareY-height/2, _squareLength, height);
    
    _scanningLine.frame = frame;
    
    _scanningLine.alpha = 1.0;
    
    __weak __typeof(self) weakSelf = self;
    
    [UIView animateWithDuration:2.0 animations:^{
        _scanningLine.frame = CGRectMake(x, _squareY+_squareLength-height/2, _squareLength, height);
        
    } completion:^(BOOL finished)
     {
         _scanningLine.alpha = 1.0;
         [weakSelf performSelector:@selector(stepAnimation) withObject:nil afterDelay:0.3];
     }];
}
//处理扫描结果
- (void)reportScanResult:(NSString *)result
{
    if (!_lastResult) {
        return;
    }
    _lastResult = NO;
    
    WQAlertView *alert = [[WQAlertView alloc] init];
    [alert showAlertWithCurrentViewController:self Title:@"提示" Message:result ConfirmName:nil CancelName:@"取消" ConfirmBlock:nil CancelBlock:nil];
    _lastResult = YES;
}

//正则判断网址
+ (BOOL)validateURL:(NSString *) textString
{
    NSString* url=@"^(http://|https://)?((?:[A-Za-z0-9]+-[A-Za-z0-9]+|[A-Za-z0-9]+)\.)+([A-Za-z]+)[/\?\:]?.*$";
    NSPredicate *numberPre = [NSPredicate predicateWithFormat:@"SELF MATCHES %@",url];
    return [numberPre evaluateWithObject:textString];
}
#pragma mark WQScanRectDrawViewDelegate
- (void)pickImageFromPhotoLibrary {
    [self openLocalPhoto];
}
/*!
 *  打开本地照片，选择图片识别
 */

#pragma mark- UIImagePickerControllerDelegate
//当选择一张图片后进入这里
-(void)imagePickerController:(UIImagePickerController*)picker didFinishPickingMediaWithInfo:(NSDictionary *)info
{
    [picker dismissViewControllerAnimated:YES completion:nil];
    
    __block UIImage* image = [info objectForKey:UIImagePickerControllerEditedImage];
    
    if (!image){
        image = [info objectForKey:UIImagePickerControllerOriginalImage];
    }
    //系统自带识别方法
    
    CIDetector *detector = [CIDetector detectorOfType:CIDetectorTypeQRCode context:nil options:@{ CIDetectorAccuracy : CIDetectorAccuracyHigh }];
    CGImageRef ref = (CGImageRef)image.CGImage;
    CIImage *cii = [CIImage imageWithCGImage:ref];
    NSArray *features = [detector featuresInImage:cii];
    
    if (features.count >=1)
    {
        CIQRCodeFeature *feature = [features objectAtIndex:0];
        NSString *scanResult = feature.messageString;
        
        [self performSelectorOnMainThread:@selector(reportScanResult:) withObject:scanResult waitUntilDone:NO];
    }else {
        NSLog(@"不是二维码");
    }
    
    
}
- (void)imagePickerControllerDidCancel:(UIImagePickerController *)picker
{
    NSLog(@"cancel");
    
    [picker dismissViewControllerAnimated:YES completion:nil];
}
#pragma mark AVCaptureMetadataOutputObjectsDelegate
-(void)captureOutput:(AVCaptureOutput *)captureOutput didOutputMetadataObjects:(NSArray *)metadataObjects
      fromConnection:(AVCaptureConnection *)connection
{
    if (metadataObjects != nil && [metadataObjects count] > 0) {
        AVMetadataMachineReadableCodeObject *metadataObj = [metadataObjects objectAtIndex:0];
        NSString *result;
        if ([[metadataObj type] isEqualToString:AVMetadataObjectTypeQRCode]) {
            result = metadataObj.stringValue;
            [self performSelectorOnMainThread:@selector(reportScanResult:) withObject:result waitUntilDone:NO];
        } else {
            NSLog(@"不是二维码");
        }
        
    }
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
