/**
 
  预览图层必须启动会话才有效
 
  关闭Xcode8自动打印，印象NSLog打印，误以为代理不回调
 
  设置输出代理回调线程为全局并发线程 导致扫面时CAShapeLayer绘制矩形框延迟过高(刷新UI必须在主线程)
 
 */

#import "QRViewController.h"
#import "QRAnimationView.h"
#import <AVFoundation/AVFoundation.h>
#define ANIMATION_FRAME self.animationView.frame
#define PREVIEW_SIZE self.previewLayer.frame.size

@interface QRViewController ()<UITabBarDelegate, AVCaptureMetadataOutputObjectsDelegate>

@property (weak, nonatomic) IBOutlet UITabBar *tabbar;

@property (weak, nonatomic) IBOutlet QRAnimationView *animationView;

@property (nonatomic, weak) AVCaptureVideoPreviewLayer * previewLayer;

@property (strong, nonatomic) AVCaptureDeviceInput * inputSource;
@property (strong, nonatomic) AVCaptureSession * captureSession;
@property (strong, nonatomic) AVCaptureMetadataOutput * outputSource;

@end

@implementation QRViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    // 监听应用推出后台通知
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(resignActive) name:@"ResignActive" object:nil];
    // 监听应用即将进入前台
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(enterForeground) name:@"EnterForeground" object:nil];
    
    // 初始化设置
    [self initailSettings];
    
    // 容错判断
    if (![self.captureSession canAddInput:self.inputSource]) return;
    if (![self.captureSession canAddOutput:self.outputSource]) return;
    
    // 输入、输出对象添加到会话中
    [self.captureSession addInput:self.inputSource];
    [self.captureSession addOutput:self.outputSource];
    
    // 设置输出类型
//    self.outputSource.metadataObjectTypes = @[AVMetadataObjectTypeQRCode];
    self.outputSource.metadataObjectTypes = self.outputSource.availableMetadataObjectTypes;
    
    // 设置输出代理
    [self.outputSource setMetadataObjectsDelegate:self queue:dispatch_get_main_queue()];
    
    [self.view.layer insertSublayer:self.previewLayer atIndex:0];
    
    // 设置显示二维码矩形框区域
    [self settingrectOfInterest];
    
    // 启动会话
    [self.captureSession startRunning];
}

//
- (void)settingrectOfInterest
{
    // 设置兴趣区域
    CGFloat rectX = ANIMATION_FRAME.origin.y / PREVIEW_SIZE.height;
    CGFloat rectY = ANIMATION_FRAME.origin.x / PREVIEW_SIZE.width;
    CGFloat rectW = ANIMATION_FRAME.size.height / PREVIEW_SIZE.height;
    CGFloat rectH = ANIMATION_FRAME.size.width / PREVIEW_SIZE.width;
    self.outputSource.rectOfInterest = CGRectMake(rectX, rectY, rectW, rectH);
}

- (void)initailSettings
{
    _tabbar.delegate = self;
    _tabbar.tintColor = [UIColor orangeColor];
    _tabbar.selectedItem = _tabbar.items[0];
}

- (IBAction)closeQR:(UIBarButtonItem *)sender {
    
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    [_animationView beginAnimation];
    
}

#pragma mark - NSNotification

// 应用程序将要失去焦点通知方法
- (void)resignActive
{
    [self.animationView stopAnimation];
}

// 应用程序将要进入前台
- (void)enterForeground
{
    [self.animationView beginAnimation];
}

#pragma mark - < UITabBarDelegate >

- (void)tabBar:(UITabBar *)tabBar didSelectItem:(UITabBarItem *)item
{
    if (1 == item.tag) {
        _animationView.heightCons.constant = 100;
        [self updateQRAnimations];
        [self cleanBorderLayers];
        [self settingrectOfInterest];
        self.navigationItem.title = @"条形码扫描";
    } else {
        _animationView.heightCons.constant = 200;
        [self updateQRAnimations];
        [self cleanBorderLayers];
        [self settingrectOfInterest];
        self.navigationItem.title = @"二维码扫描";
    }
}

- (void)updateQRAnimations
{
    [_animationView stopAnimation];
    [_animationView beginAnimation];
}

- (void)viewDidDisappear:(BOOL)animated
{
    [super viewDidDisappear:animated];
    [self.animationView stopAnimation];
}

#pragma mark - lazy

- (AVCaptureDeviceInput *)inputSource
{
    if (!_inputSource) {
        AVCaptureDevice * device = [AVCaptureDevice defaultDeviceWithMediaType:AVMediaTypeVideo];
        _inputSource = [[AVCaptureDeviceInput alloc] initWithDevice:device error:nil];
    }
    return _inputSource;
}

- (AVCaptureMetadataOutput *)outputSource
{
    if (!_outputSource) {
        _outputSource = [[AVCaptureMetadataOutput alloc] init];
    }
    return _outputSource;
}

- (AVCaptureSession *)captureSession
{
    if (!_captureSession) {
        _captureSession = [[AVCaptureSession alloc] init];
    }
    return _captureSession;
}

- (AVCaptureVideoPreviewLayer *)previewLayer
{
    if (!_previewLayer) {
        _previewLayer = [AVCaptureVideoPreviewLayer layerWithSession:self.captureSession];
        _previewLayer.frame = self.view.bounds;
    }
    return _previewLayer;
}

#pragma mark - < AVCaptureMetadataOutputObjectsDelegate >

- (void)cleanBorderLayers
{
    NSMutableArray *layers = [NSMutableArray array];
    for (id sublayer in self.previewLayer.sublayers) {
        if ([sublayer isKindOfClass:[CAShapeLayer class]]) {
            [layers addObject:sublayer];
        }
    }
    [layers makeObjectsPerformSelector:@selector(removeFromSuperlayer)];
}

// 扫描到数据代理回调
- (void)captureOutput:(AVCaptureOutput *)captureOutput didOutputMetadataObjects:(NSArray *)metadataObjects fromConnection:(AVCaptureConnection *)connectio
{
    
    // 移除原先的二维码矩形框
    [self cleanBorderLayers];
    
    for (AVMetadataMachineReadableCodeObject *obj in metadataObjects) {
        // 转换corner坐标
        AVMetadataMachineReadableCodeObject *metadataObject = (AVMetadataMachineReadableCodeObject *)[self.previewLayer transformedMetadataObjectForMetadataObject:obj];
        // 绘制边框
        [self drawBorderWith:metadataObject];
    }
}

- (void)drawBorderWith:(AVMetadataMachineReadableCodeObject *)metadataObject
{
    if (0 == metadataObject.corners.count || nil == metadataObject.corners) return;
    
    // 创建二维码绘图框Layer
    CAShapeLayer *borderLayer = [CAShapeLayer layer];
    borderLayer.lineWidth = 3;
    borderLayer.strokeColor = [UIColor redColor].CGColor;
    borderLayer.fillColor = [UIColor clearColor].CGColor;
    
    // 创建路径
    UIBezierPath *drawPath = [UIBezierPath bezierPath];
    CGPoint point = CGPointZero;
    NSInteger index = 0;
    
    CGPointMakeWithDictionaryRepresentation((CFDictionaryRef)metadataObject.corners[index++], &point);
    [drawPath moveToPoint:point];
    
    while (index < metadataObject.corners.count) {
        CGPointMakeWithDictionaryRepresentation((CFDictionaryRef)metadataObject.corners[index++], &point);
        [drawPath addLineToPoint:point];
    }
    [drawPath closePath];
    // 刷新UI
    [_previewLayer addSublayer:borderLayer];
    borderLayer.path = drawPath.CGPath;
    
}

@end
