//
//  SnapViewController.m
//  eventlyapp
//
//  Created by Lingfei Song on 14-3-8.
//  Copyright (c) 2014年 Lingfei Song. All rights reserved.
//

#import "SnapViewController.h"
#import <AFNetworking.h>

@interface SnapViewController ()

@property (strong, nonatomic) AVCaptureDevice* device;
@property (strong, nonatomic) AVCaptureDeviceInput* backCameraInput;
@property (strong, nonatomic) AVCaptureDeviceInput* frontCameraInput;
@property (strong, nonatomic) AVCaptureStillImageOutput* output;
@property (strong, nonatomic) AVCaptureSession* session;
@property (strong, nonatomic) AVCaptureVideoPreviewLayer* preview;
@property (strong, nonatomic) UIImageView *capturedPhotoView;

@property (strong, nonatomic) UIButton *btnBack;
@property (strong, nonatomic) UIButton *btnTake;
@property (strong, nonatomic) UIButton *btnRetake;
@property (strong, nonatomic) UIButton *btnConfirm;
@property (strong, nonatomic) UIActivityIndicatorView *indicator;

@end

@implementation SnapViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    if(![self isCameraAvailable]) {
        [self setupNoCameraView];
    }
    [self recapture];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    if([self isCameraAvailable]) {
        [self setupUI];
        [self setupCapture];
        [self startPreview];
    }
}

- (void)viewWillDisappear:(BOOL)animated
{
    [self.indicator stopAnimating];
    [self.indicator setHidden:YES];
    
    [self.session stopRunning];
}

- (NSUInteger)supportedInterfaceOrientations;
{
    return UIInterfaceOrientationMaskPortrait;
}

- (BOOL)shouldAutorotate;
{
    return NO;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark -
#pragma mark UI

- (void) setupUI
{
    self.view.layer.contents = (id)[[UIImage imageNamed:@"snap_bg"] CGImage];
    self.btnBack = [UIButton buttonWithType:UIButtonTypeCustom];
    self.btnBack.frame = CGRectMake(50.0, 50.0, 65.0, 65.0);
    [self.btnBack setBackgroundImage:[UIImage imageNamed:@"btn_back"] forState:UIControlStateNormal];
    [self.btnBack addTarget:self action:@selector(clickBtnBack) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:self.btnBack];
    
    self.btnTake = [UIButton buttonWithType:UIButtonTypeCustom];
    self.btnTake.frame = CGRectMake(500.0, 870.0, 65.0, 65.0);
    [self.btnTake setBackgroundImage:[UIImage imageNamed:@"btn_take"] forState:UIControlStateNormal];
    [self.btnTake addTarget:self action:@selector(capture) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:self.btnTake];
    
    self.btnRetake = [UIButton buttonWithType:UIButtonTypeCustom];
    self.btnRetake.frame = CGRectMake(500.0, 870.0, 65.0, 65.0);
    [self.btnRetake setBackgroundImage:[UIImage imageNamed:@"btn_retake"] forState:UIControlStateNormal];
    [self.btnRetake addTarget:self action:@selector(clickBtnRetake:withEvent:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:self.btnRetake];
    [self.btnRetake setHidden:YES];
    
    self.btnConfirm = [UIButton buttonWithType:UIButtonTypeCustom];
    self.btnConfirm.frame = CGRectMake(580, 870, 65.0, 65.0);
    [self.btnConfirm setBackgroundImage:[UIImage imageNamed:@"btn_confirm"] forState:UIControlStateNormal];
    [self.btnConfirm addTarget:self action:@selector(clickBtnConfirm:withEvent:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:self.btnConfirm];
    [self.btnConfirm setHidden:YES];
    
    self.indicator = [[UIActivityIndicatorView alloc]initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
    self.indicator.color = [UIColor whiteColor];
    self.indicator.frame = CGRectMake(600.0, 600.0, 40.0, 40.0);
    self.indicator.center = self.view.center;
    [self.view addSubview:self.self.indicator];
    [self.indicator bringSubviewToFront:self.view];
    [self.indicator setHidden:YES];
}

- (void) recapture
{
    [self.preview setHidden:NO];
    [self.capturedPhotoView setHidden:YES];
    [self.btnRetake setHidden:YES];
    [self.btnConfirm setHidden:YES];
    [self startPreview];
    [self.btnTake setHidden:NO];
}

- (void) clickBtnBack
{
    if([self.delegate respondsToSelector:@selector(snapViewController:didClickBackButton:)]) {
        [self.delegate snapViewController:self didClickBackButton:self.btnBack];
    }
}

- (void) clickBtnRetake:(UIButton*)btn withEvent:(UIEvent*)event
{
    [self.btnRetake setHidden:YES];
    [self.btnConfirm setHidden:YES];
    [self performSelector:@selector(startPreview) withObject:nil afterDelay:0.001];
    [self performSelector:@selector(recapture) withObject:nil afterDelay:0.002];
}

- (void) clickBtnConfirm:(UIButton*)btn withEvent:(UIEvent*)event
{
    [self.btnRetake setHidden:YES];
    [self.btnConfirm setHidden:YES];
    [self.indicator setHidden:NO];
    [self.indicator startAnimating];
    
    NSData *imageToUpload = UIImageJPEGRepresentation(self.capturedPhotoView.image, 0.9);
    
    if(self.delegate && [self.delegate respondsToSelector:@selector(snapViewController:didClickConfirmButton:withJpegData:)])
    {
        [self.delegate snapViewController:self didClickConfirmButton:btn withJpegData:imageToUpload];
    }
}

- (void) setupNoCameraView;
{
    UILabel *labelNoCam = [[UILabel alloc] init];
    labelNoCam.text = @"No Camera available";
    labelNoCam.textColor = [UIColor whiteColor];
    [self.view addSubview:labelNoCam];
    [labelNoCam sizeToFit];
    labelNoCam.center = self.view.center;
}

#pragma mark -
#pragma mark AVFoundationSetup

- (void) setupCapture;
{
    self.device = [AVCaptureDevice defaultDeviceWithMediaType:AVMediaTypeVideo];
    
    
    NSArray *cameras = [AVCaptureDevice devicesWithMediaType:AVMediaTypeVideo];
    for (AVCaptureDevice *device in cameras)
    {
        if (device.position == AVCaptureDevicePositionFront){
            self.device = device ;
            break;
        }
    }

    self.backCameraInput = [AVCaptureDeviceInput deviceInputWithDevice:self.device error:nil];
    
    self.output = [[AVCaptureStillImageOutput alloc] init];
    NSDictionary *outputSettings = @{ AVVideoCodecKey : AVVideoCodecJPEG, AVVideoQualityKey : @0.9 };
    [self.output setOutputSettings:outputSettings];
    
    self.session = [[AVCaptureSession alloc] init];
    self.session.sessionPreset = AVCaptureSessionPresetPhoto;

    [self.session addOutput:self.output];
    [self.session addInput:self.backCameraInput];
    
    self.preview = [AVCaptureVideoPreviewLayer layerWithSession:self.session];
    self.preview.videoGravity = AVLayerVideoGravityResizeAspectFill;
    self.preview.frame = CGRectMake(140, 205, 480, 640);
    
    AVCaptureConnection *con = self.preview.connection;
    con.videoOrientation = AVCaptureVideoOrientationPortrait;
    
    [self.view.layer addSublayer:self.preview];
    
    self.capturedPhotoView = [[UIImageView alloc] initWithFrame:self.preview.frame];
    [self.capturedPhotoView setHidden:YES];
    self.capturedPhotoView.contentMode = UIViewContentModeScaleAspectFill;
    [self.capturedPhotoView setClipsToBounds:YES];
    [self.view addSubview:self.capturedPhotoView];
}

#pragma mark -
#pragma mark Helper Methods

- (BOOL) isCameraAvailable;
{
    NSArray *videoDevices = [AVCaptureDevice devicesWithMediaType:AVMediaTypeVideo];
    return [videoDevices count] > 0;
}

- (void) startPreview;
{
    [self.capturedPhotoView setHidden:YES];
    [self.session startRunning];
}

- (void) stopPreview;
{
    [self.session stopRunning];
}

- (void) toggleCamera
{
    [self.session beginConfiguration];
    //[self.session removeInput:frontFacingCameraDeviceInput];
    //[self.session addInput:backFacingCameraDeviceInput];
    [self.session commitConfiguration];
}

- (void) capture
{
    [self.btnTake setHidden:YES];
    [self.indicator setHidden:NO];
    [self.indicator startAnimating];
    
    AVCaptureConnection *videoConnection = nil;
    for (AVCaptureConnection *connection in self.output.connections)
    {
        for (AVCaptureInputPort *port in [connection inputPorts])
        {
            if ([[port mediaType] isEqual:AVMediaTypeVideo] )
            {
                videoConnection = connection;
                break;
            }
        }
        if (videoConnection)
        {
            break;
        }
    }
    
    NSLog(@"about to request a capture from: %@", self.output);
    [self.output captureStillImageAsynchronouslyFromConnection:videoConnection completionHandler:
     ^(CMSampleBufferRef imageSampleBuffer, NSError *error)
     {
         /*
         CFDictionaryRef exifAttachments = CMGetAttachment( imageSampleBuffer, kCGImagePropertyExifDictionary, NULL);
         if (exifAttachments)
         {
             // Do something with the attachments.
             NSLog(@"attachements: %@", exifAttachments);
         } else {
             NSLog(@"no attachments");
         }
          */
         [self stopPreview];
         
         NSData *imageData = [AVCaptureStillImageOutput jpegStillImageNSDataRepresentation:imageSampleBuffer];
         UIImage *image = [[UIImage alloc] initWithData:imageData];
         
         UIImage *image1 = [self scaleAndRotateImage:image];
         
         /* crop to square */
         CGFloat x = 0, y = 0, width = image1.size.width;

         if(image1.size.width>image1.size.height){
             x = (image1.size.width - image1.size.height)/2.0;
             width = image1.size.height;
         }
         else{
             y = (image1.size.height - image1.size.width)/2.0;
         }
         CGImageRef imageRef = CGImageCreateWithImageInRect(image1.CGImage, CGRectMake(x, y, width, width));

         UIImage *image2 = [UIImage imageWithCGImage:imageRef];
         CGImageRelease(imageRef);
         
         // display the image
         [self.capturedPhotoView setHidden:NO];
         self.capturedPhotoView.image = image1;
         
         // test save to album
         //UIImageWriteToSavedPhotosAlbum(image2, nil, nil, nil);
         
         [self.btnConfirm setHidden:NO];
         [self.btnRetake setHidden:NO];
         [self.indicator stopAnimating];
         [self.indicator setHidden:YES];
     }];
}

- (UIImage *)scaleAndRotateImage:(UIImage *)image {
    int kMaxResolution = 640;
    
    CGImageRef imgRef = image.CGImage;
    
    CGFloat width = CGImageGetWidth(imgRef);
    CGFloat height = CGImageGetHeight(imgRef);
    
    
    CGAffineTransform transform = CGAffineTransformIdentity;
    CGRect bounds = CGRectMake(0, 0, width, height);
    if (width > kMaxResolution || height > kMaxResolution) {
        CGFloat ratio = width/height;
        if (ratio > 1) {
            bounds.size.width = kMaxResolution;
            bounds.size.height = roundf(bounds.size.width / ratio);
        }
        else {
            bounds.size.height = kMaxResolution;
            bounds.size.width = roundf(bounds.size.height * ratio);
        }
    }
    
    CGFloat scaleRatio = bounds.size.width / width;
    CGSize imageSize = CGSizeMake(CGImageGetWidth(imgRef), CGImageGetHeight(imgRef));
    CGFloat boundHeight;
    UIImageOrientation orient = image.imageOrientation;
    switch(orient) {

        case UIImageOrientationUp: //EXIF = 1

            transform = CGAffineTransformIdentity;
            break;
            
        case UIImageOrientationUpMirrored: //EXIF = 2
            transform = CGAffineTransformMakeTranslation(imageSize.width, 0.0);
            transform = CGAffineTransformScale(transform, -1.0, 1.0);
            break;
            
        case UIImageOrientationDown: //EXIF = 3
            transform = CGAffineTransformMakeTranslation(imageSize.width, imageSize.height);
            transform = CGAffineTransformRotate(transform, M_PI);
            break;
            
        case UIImageOrientationDownMirrored: //EXIF = 4
            transform = CGAffineTransformMakeTranslation(0.0, imageSize.height);
            transform = CGAffineTransformScale(transform, 1.0, -1.0);
            break;
            
        case UIImageOrientationLeftMirrored: //EXIF = 5
            boundHeight = bounds.size.height;
            bounds.size.height = bounds.size.width;
            bounds.size.width = boundHeight;
            transform = CGAffineTransformMakeTranslation(imageSize.height, imageSize.width);
            transform = CGAffineTransformScale(transform, -1.0, 1.0);
            transform = CGAffineTransformRotate(transform, 3.0 * M_PI / 2.0);
            break;
            
        case UIImageOrientationLeft: //EXIF = 6
            boundHeight = bounds.size.height;
            bounds.size.height = bounds.size.width;
            bounds.size.width = boundHeight;
            transform = CGAffineTransformMakeTranslation(0.0, imageSize.width);
            transform = CGAffineTransformRotate(transform, 3.0 * M_PI / 2.0);
            break;
            
        case UIImageOrientationRightMirrored: //EXIF = 7
            boundHeight = bounds.size.height;
            bounds.size.height = bounds.size.width;
            bounds.size.width = boundHeight;
            transform = CGAffineTransformMakeScale(-1.0, 1.0);
            transform = CGAffineTransformRotate(transform, M_PI / 2.0);
            break;
            
        case UIImageOrientationRight: //EXIF = 8
            boundHeight = bounds.size.height;
            bounds.size.height = bounds.size.width;
            bounds.size.width = boundHeight;
            transform = CGAffineTransformMakeTranslation(imageSize.height, 0.0);
            transform = CGAffineTransformRotate(transform, M_PI / 2.0);
            break;
            
        default:
            [NSException raise:NSInternalInconsistencyException format:@"Invalid image orientation"];
            
    }
    
    UIGraphicsBeginImageContext(bounds.size);
    
    CGContextRef context = UIGraphicsGetCurrentContext();
    
//    if (orient == UIImageOrientationRight || orient == UIImageOrientationLeft) {
//        CGContextScaleCTM(context, -scaleRatio, scaleRatio);
//        CGContextTranslateCTM(context, -height, 0);
//    }
//    else {
//        CGContextScaleCTM(context, scaleRatio, -scaleRatio);
//        CGContextTranslateCTM(context, 0, -height);
//    }
    
    CGContextConcatCTM(context, transform);
    
    CGContextDrawImage(UIGraphicsGetCurrentContext(), CGRectMake(0, 0, width, height), imgRef);
    UIImage *imageCopy = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    return imageCopy;
}

@end
