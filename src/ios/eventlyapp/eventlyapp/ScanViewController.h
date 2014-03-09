//
//  ScanViewController.h
//  eventlyapp
//
//  Created by Lingfei Song on 14-3-5.
//  Copyright (c) 2014年 Lingfei Song. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <AVFoundation/AVFoundation.h>

@protocol ScanViewControllerDelegate;

@interface ScanViewController : UIViewController <AVCaptureMetadataOutputObjectsDelegate>

@property (nonatomic, weak) id<ScanViewControllerDelegate> delegate;

@property (assign, nonatomic) BOOL touchToFocusEnabled;

- (BOOL) isCameraAvailable;
- (void) startScanning;
- (void) stopScanning;
- (void) rescan;
- (void) scanValidated:(BOOL)valid withName:(NSString*)name company:(NSString*)company email:(NSString*)email;
- (void) setTourch:(BOOL) aStatus;

@end

@protocol ScanViewControllerDelegate <NSObject>

@optional

- (void) scanViewController:(ScanViewController *) aCtler didTabToFocusOnPoint:(CGPoint) aPoint;
- (void) scanViewController:(ScanViewController *) aCtler didSuccessfullyScan:(NSString *) aScannedValue;

- (void) scanViewController:(ScanViewController *) vc didClickNextButton:(UIButton*) btn;

@end