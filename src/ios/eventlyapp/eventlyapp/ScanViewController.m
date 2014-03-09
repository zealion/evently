//
//  ScanViewController.m
//  eventlyapp
//
//  Created by Lingfei Song on 14-3-5.
//  Copyright (c) 2014年 Lingfei Song. All rights reserved.
//

#import "ScanViewController.h"

@interface ScanViewController ()

@property (strong, nonatomic) AVCaptureDevice* device;
@property (strong, nonatomic) AVCaptureDeviceInput* input;
@property (strong, nonatomic) AVCaptureMetadataOutput* output;
@property (strong, nonatomic) AVCaptureSession* session;
@property (strong, nonatomic) AVCaptureVideoPreviewLayer* preview;

@property (strong, nonatomic) UIButton *btnRescan;
@property (strong, nonatomic) UIButton *btnNext;
@property (strong, nonatomic) UILabel *lblName;
@property (strong, nonatomic) UILabel *lblCompany;
@property (strong, nonatomic) UILabel *lblEmail;
@property (strong, nonatomic) UILabel *lblMessage;
@property (strong, nonatomic) UIView *container;

@end

@implementation ScanViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
    }
    return self;
}

- (void)viewWillAppear:(BOOL)animated;
{
    [super viewWillAppear:animated];
    if(![self isCameraAvailable]) {
        [self setupNoCameraView];
    }
}

- (void) viewDidAppear:(BOOL)animated;
{
    [super viewDidAppear:animated];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    if([self isCameraAvailable]) {
        [self setupScanner];
        [self setupUI]; // label container is on top of the scanning preview
        
        [self startScanning];
    }
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)touchesBegan:(NSSet*)touches withEvent:(UIEvent*)evt
{
    if(self.touchToFocusEnabled) {
        UITouch *touch=[touches anyObject];
        CGPoint pt= [touch locationInView:self.view];
        [self focus:pt];
    }
}

#pragma mark -
#pragma mark UI

- (void) setupUI
{
    self.btnNext = [UIButton buttonWithType:UIButtonTypeRoundedRect];
    [self.btnNext addTarget:self action:@selector(clickBtnNext:withEvent:) forControlEvents:UIControlEventTouchUpInside];
    [self.btnNext setTitle:@"Next" forState:UIControlStateNormal];
    self.btnNext.frame = CGRectMake(400.0, 700.0, 80.0, 80.0);
    [self.view addSubview:self.btnNext];
    [self.btnNext setHidden:YES];
    
    self.btnRescan = [UIButton buttonWithType:UIButtonTypeRoundedRect];
    [self.btnRescan addTarget:self action:@selector(clickBtnRescan:withEvent:) forControlEvents:UIControlEventTouchUpInside];
    [self.btnRescan setTitle:@"Rescan" forState:UIControlStateNormal];
    self.btnRescan.frame = CGRectMake(400.0, 800.0, 80.0, 80.0);
    [self.view addSubview:self.btnRescan];
    [self.btnRescan setHidden:YES];
    
    [self.view addSubview:self.btnNext];
    [self.view addSubview:self.btnRescan];
    
    self.container = [[UIView alloc] initWithFrame:CGRectMake(0,0, 400, 400)];
    self.container.center = self.view.center;
    self.container.backgroundColor = [UIColor whiteColor];
    [self.container setHidden:YES];
    
    self.lblMessage = [[UILabel alloc]initWithFrame:CGRectMake(30, 30, 300, 30)];
    self.lblMessage.font = [UIFont fontWithName:@"hei" size:12];
    self.lblMessage.numberOfLines = 1;
    self.lblMessage.baselineAdjustment = UIBaselineAdjustmentAlignBaselines; // or UIBaselineAdjustmentAlignCenters, or UIBaselineAdjustmentNone
    self.lblMessage.adjustsFontSizeToFitWidth = YES;
    self.lblMessage.minimumScaleFactor = 10.0f/12.0f;
    self.lblMessage.clipsToBounds = YES;
    self.lblMessage.backgroundColor = [UIColor clearColor];
    self.lblMessage.textColor = [UIColor blackColor];
    self.lblMessage.textAlignment = NSTextAlignmentLeft;
    [self.container addSubview:self.lblMessage];
    
    self.lblName = [[UILabel alloc]initWithFrame:CGRectMake(100, 90, 270, 30)];
    self.lblName.font = [UIFont fontWithName:@"hei" size:12];
    self.lblName.numberOfLines = 1;
    self.lblName.baselineAdjustment = UIBaselineAdjustmentAlignBaselines; // or UIBaselineAdjustmentAlignCenters, or UIBaselineAdjustmentNone
    self.lblName.adjustsFontSizeToFitWidth = YES;
    self.lblName.minimumScaleFactor = 10.0f/12.0f;
    self.lblName.clipsToBounds = YES;
    self.lblName.backgroundColor = [UIColor clearColor];
    self.lblName.textColor = [UIColor blackColor];
    self.lblName.textAlignment = NSTextAlignmentLeft;
    [self.container addSubview:self.lblName];
    
    self.lblCompany = [[UILabel alloc]initWithFrame:CGRectMake(100, 150, 270, 30)];
    self.lblCompany.font = [UIFont fontWithName:@"hei" size:12];
    self.lblCompany.numberOfLines = 1;
    self.lblCompany.baselineAdjustment = UIBaselineAdjustmentAlignBaselines; // or UIBaselineAdjustmentAlignCenters, or UIBaselineAdjustmentNone
    self.lblCompany.adjustsFontSizeToFitWidth = YES;
    self.lblCompany.minimumScaleFactor = 10.0f/12.0f;
    self.lblCompany.clipsToBounds = YES;
    self.lblCompany.backgroundColor = [UIColor clearColor];
    self.lblCompany.textColor = [UIColor blackColor];
    self.lblCompany.textAlignment = NSTextAlignmentLeft;
    [self.container addSubview:self.lblCompany];
    
    self.lblEmail = [[UILabel alloc]initWithFrame:CGRectMake(100, 210, 270, 30)];
    self.lblEmail.font = [UIFont fontWithName:@"hei" size:12];
    self.lblEmail.numberOfLines = 1;
    self.lblEmail.baselineAdjustment = UIBaselineAdjustmentAlignBaselines; // or UIBaselineAdjustmentAlignCenters, or UIBaselineAdjustmentNone
    self.lblEmail.adjustsFontSizeToFitWidth = YES;
    self.lblEmail.minimumScaleFactor = 10.0f/12.0f;
    self.lblEmail.clipsToBounds = YES;
    self.lblEmail.backgroundColor = [UIColor clearColor];
    self.lblEmail.textColor = [UIColor blackColor];
    self.lblEmail.textAlignment = NSTextAlignmentLeft;
    [self.container addSubview:self.lblEmail];
    
    //[self.lblMessage setText:@"二维码验证成功！"];
    //[self.lblName setText:@"好看好看哈理工联合国"];
    //[self.lblCompany setText:@"苦哈哈给客户考虑更好"];
    //[self.lblEmail setText:@"hkhk@gkaga.com"];
    
    [self.view addSubview:self.container];
}

- (void) rescan
{
    [self.lblMessage setText:@""];
    [self.lblName setText:@""];
    [self.lblCompany setText:@""];
    [self.lblEmail setText:@""];
    [self.container setHidden:YES];
    [self.btnRescan setHidden:YES];
    [self.btnNext setHidden:YES];
    [self.preview setHidden:NO];
    [self startScanning];
}

- (void) scanValidated:(BOOL)valid withName:(NSString*)name company:(NSString*)company email:(NSString*)email
{
    [self.btnRescan setHidden:NO]; // can always rescan

    if(valid)
    {
        [self.lblMessage setText:@"二维码验证成功！"];
        [self.lblName setText:name];
        [self.lblCompany setText:company];
        [self.lblEmail setText:email];
        [self.container setHidden:NO];
        [self.btnNext setHidden:NO];
    }
    else{
        
        [self.lblMessage setText:@"无效的二维码！"];
        [self.lblName setText:@""];
        [self.lblCompany setText:@""];
        [self.lblEmail setText:@""];
        [self.btnNext setHidden:YES];
        [self.container setHidden:NO];
    }
}

- (void) clickBtnRescan: (UIButton*)button withEvent:(UIEvent*)event
{
    [self rescan];
}

- (void) clickBtnNext: (UIButton*)button withEvent:(UIEvent*)event
{
    if([self.delegate respondsToSelector:@selector(scanViewController:didClickNextButton:)]) {
        [self.delegate scanViewController:self didClickNextButton:self.btnNext];
    }
}

#pragma mark -
#pragma mark NoCamAvailable

- (void) setupNoCameraView;
{
    UILabel *labelNoCam = [[UILabel alloc] init];
    labelNoCam.text = @"No Camera available";
    labelNoCam.textColor = [UIColor blackColor];
    [self.view addSubview:labelNoCam];
    [labelNoCam sizeToFit];
    labelNoCam.center = self.view.center;
}

- (NSUInteger)supportedInterfaceOrientations;
{
    return UIInterfaceOrientationMaskPortrait;
}

- (BOOL)shouldAutorotate;
{
    //return (UIDeviceOrientationIsPortrait([[UIDevice currentDevice] orientation]));
    return NO;
}

- (void)didRotateFromInterfaceOrientation:(UIInterfaceOrientation)fromInterfaceOrientation;
{
    return;
    if([[UIDevice currentDevice] orientation] == UIDeviceOrientationLandscapeLeft) {
        AVCaptureConnection *con = self.preview.connection;
        con.videoOrientation = AVCaptureVideoOrientationLandscapeRight;
    } else {
        AVCaptureConnection *con = self.preview.connection;
        con.videoOrientation = AVCaptureVideoOrientationLandscapeLeft;
    }
}

#pragma mark -
#pragma mark AVFoundationSetup

- (void) setupScanner;
{
    self.device = [AVCaptureDevice defaultDeviceWithMediaType:AVMediaTypeVideo];
    
    self.input = [AVCaptureDeviceInput deviceInputWithDevice:self.device error:nil];
    
    self.session = [[AVCaptureSession alloc] init];
    
    self.output = [[AVCaptureMetadataOutput alloc] init];
    [self.session addOutput:self.output];
    [self.session addInput:self.input];
    
    [self.output setMetadataObjectsDelegate:self queue:dispatch_get_main_queue()];
    self.output.metadataObjectTypes = @[AVMetadataObjectTypeQRCode];
    
    self.preview = [AVCaptureVideoPreviewLayer layerWithSession:self.session];
    self.preview.videoGravity = AVLayerVideoGravityResizeAspectFill;
    self.preview.frame = CGRectMake(self.view.center.x-200, self.view.center.y-200, 400, 400);
    
    AVCaptureConnection *con = self.preview.connection;
    
    con.videoOrientation = AVCaptureVideoOrientationPortrait;
    
    [self.view.layer insertSublayer:self.preview atIndex:0];
}

#pragma mark -
#pragma mark Helper Methods

- (BOOL) isCameraAvailable;
{
    NSArray *videoDevices = [AVCaptureDevice devicesWithMediaType:AVMediaTypeVideo];
    return [videoDevices count] > 0;
}

- (void)startScanning;
{
    [self.session startRunning];
    
}

- (void) stopScanning;
{
    [self.session stopRunning];
}

- (void) setTourch:(BOOL) aStatus;
{
  	AVCaptureDevice *device = [AVCaptureDevice defaultDeviceWithMediaType:AVMediaTypeVideo];
    [device lockForConfiguration:nil];
    if ( [device hasTorch] ) {
        if ( aStatus ) {
            [device setTorchMode:AVCaptureTorchModeOn];
        } else {
            [device setTorchMode:AVCaptureTorchModeOff];
        }
    }
    [device unlockForConfiguration];
}

- (void) focus:(CGPoint) aPoint;
{
    AVCaptureDevice *device = [AVCaptureDevice defaultDeviceWithMediaType:AVMediaTypeVideo];
    if([device isFocusPointOfInterestSupported] &&
       [device isFocusModeSupported:AVCaptureFocusModeAutoFocus]) {
        CGRect screenRect = [[UIScreen mainScreen] bounds];
        double screenWidth = screenRect.size.width;
        double screenHeight = screenRect.size.height;
        double focus_x = aPoint.x/screenWidth;
        double focus_y = aPoint.y/screenHeight;
        if([device lockForConfiguration:nil]) {
            if([self.delegate respondsToSelector:@selector(scanViewController:didTabToFocusOnPoint:)]) {
                [self.delegate scanViewController:self didTabToFocusOnPoint:aPoint];
            }
            [device setFocusPointOfInterest:CGPointMake(focus_x,focus_y)];
            [device setFocusMode:AVCaptureFocusModeAutoFocus];
            if ([device isExposureModeSupported:AVCaptureExposureModeAutoExpose]){
                [device setExposureMode:AVCaptureExposureModeAutoExpose];
            }
            [device unlockForConfiguration];
        }
    }
}

#pragma mark -
#pragma mark AVCaptureMetadataOutputObjectsDelegate

- (void)captureOutput:(AVCaptureOutput *)captureOutput didOutputMetadataObjects:(NSArray *)metadataObjects
       fromConnection:(AVCaptureConnection *)connection
{
    for(AVMetadataObject *current in metadataObjects) {
        if([current isKindOfClass:[AVMetadataMachineReadableCodeObject class]]) {
            if([self.delegate respondsToSelector:@selector(scanViewController:didSuccessfullyScan:)]) {
                NSString *scannedValue = [((AVMetadataMachineReadableCodeObject *) current) stringValue];
                [self stopScanning];
                [self.delegate scanViewController:self didSuccessfullyScan:scannedValue];
            }
        }
    }
}
@end