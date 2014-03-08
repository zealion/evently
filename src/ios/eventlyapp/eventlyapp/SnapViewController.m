//
//  SnapViewController.m
//  eventlyapp
//
//  Created by Lingfei Song on 14-3-8.
//  Copyright (c) 2014年 Lingfei Song. All rights reserved.
//

#import "SnapViewController.h"

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
    NSDictionary *outputSettings = @{ AVVideoCodecKey : AVVideoCodecJPEG};
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
         //[self stopPreview];
         
         NSData *imageData = [AVCaptureStillImageOutput jpegStillImageNSDataRepresentation:imageSampleBuffer];
         UIImage *image = [[UIImage alloc] initWithData:imageData];
         
         [self.capturedPhotoView setHidden:NO];
         self.capturedPhotoView.image = image;
         
         //UIImageWriteToSavedPhotosAlbum(image, nil, nil, nil);
     }];
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
