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
    
    UIButton *btnTake = [UIButton buttonWithType:UIButtonTypeRoundedRect];
    [btnTake addTarget:self action:@selector(capture) forControlEvents:UIControlEventTouchUpInside];
    [btnTake setTitle:@"Capture" forState:UIControlStateNormal];
    btnTake.frame = CGRectMake(400.0, 400.0, 80.0, 80.0);
    [self.view addSubview:btnTake];

    UIButton *btnRetake = [UIButton buttonWithType:UIButtonTypeRoundedRect];
    [btnRetake addTarget:self action:@selector(recapture) forControlEvents:UIControlEventTouchUpInside];
    [btnRetake setTitle:@"Re-Take" forState:UIControlStateNormal];
    btnRetake.frame = CGRectMake(400.0, 500.0, 80.0, 80.0);
    [self.view addSubview:btnRetake];
    
    UIButton *btnConfirm = [UIButton buttonWithType:UIButtonTypeRoundedRect];
    [btnConfirm addTarget:self action:@selector(confirm) forControlEvents:UIControlEventTouchUpInside];
    [btnConfirm setTitle:@"Confirm" forState:UIControlStateNormal];
    btnConfirm.frame = CGRectMake(400.0, 600.0, 80.0, 80.0);
    [self.view addSubview:btnConfirm];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    if([self isCameraAvailable]) {
        [self setupCapture];
    }
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
#pragma mark AVFoundationSetup

- (void) setupCapture;
{
    self.device = [AVCaptureDevice defaultDeviceWithMediaType:AVMediaTypeVideo];
    self.backCameraInput = [AVCaptureDeviceInput deviceInputWithDevice:self.device error:nil];
    
    self.output = [[AVCaptureStillImageOutput alloc] init];
    NSDictionary *outputSettings = @{ AVVideoCodecKey : AVVideoCodecJPEG, AVVideoQualityKey : @0.9 };
    [self.output setOutputSettings:outputSettings];
    
    self.session = [[AVCaptureSession alloc] init];
    self.session.sessionPreset = AVCaptureSessionPresetPhoto;

    [self.session addOutput:self.output];
    [self.session addInput:self.backCameraInput];
    
    
    //[self.output setMetadataObjectsDelegate:self queue:dispatch_get_main_queue()];
    //self.output.metadataObjectTypes = @[AVMetadataObjectTypeQRCode];
    
    self.preview = [AVCaptureVideoPreviewLayer layerWithSession:self.session];
    self.preview.videoGravity = AVLayerVideoGravityResizeAspectFill;
    self.preview.frame = CGRectMake(100, 100, 300, 300);
    
    AVCaptureConnection *con = self.preview.connection;
    con.videoOrientation = AVCaptureVideoOrientationPortrait;
    
    [self.view.layer insertSublayer:self.preview atIndex:0];
    
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

- (void) recapture
{
    [self.capturedPhotoView setHidden:NO];
    [self startPreview];
}

- (void) capture
{
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
         self.capturedPhotoView.image = image2;
         
         UIImageWriteToSavedPhotosAlbum(image2, nil, nil, nil);
     }];
}

- (void) confirm
{
    NSData *imageToUpload = UIImageJPEGRepresentation(self.capturedPhotoView.image, 0.9);
    
    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    NSDictionary *parameters = @{@"qrcode_id": @"UNIP2014010002", @"is_arrived": @1};
    [manager POST:@"http://192.168.0.104:4000/event/UNIP/guests/" parameters:parameters constructingBodyWithBlock:^(id<AFMultipartFormData> formData) {
        [formData appendPartWithFileData:imageToUpload name:@"pic_data" fileName:@"test.jpg" mimeType:@"image/jpg"];
    } success:^(AFHTTPRequestOperation *operation, id responseObject) {
        NSLog(@"Success: %@", responseObject);
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        NSLog(@"Error: %@", error);
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
    
    if (orient == UIImageOrientationRight || orient == UIImageOrientationLeft) {
        CGContextScaleCTM(context, -scaleRatio, scaleRatio);
        CGContextTranslateCTM(context, -height, 0);
    }
    else {
        CGContextScaleCTM(context, scaleRatio, -scaleRatio);
        CGContextTranslateCTM(context, 0, -height);
    }
    
    CGContextConcatCTM(context, transform);
    
    CGContextDrawImage(UIGraphicsGetCurrentContext(), CGRectMake(0, 0, width, height), imgRef);
    UIImage *imageCopy = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    return imageCopy;
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

@end
