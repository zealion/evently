//
//  SnapViewController.h
//  eventlyapp
//
//  Created by Lingfei Song on 14-3-8.
//  Copyright (c) 2014年 Lingfei Song. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <AVFoundation/AVFoundation.h>

@protocol SnapViewControllerDelegate;

@interface SnapViewController : UIViewController

@property (nonatomic, weak) id<SnapViewControllerDelegate> delegate;
- (BOOL) isCameraAvailable;
- (void) startPreview;
- (void) stopPreview;
- (void) capture;

@end

@protocol SnapViewControllerDelegate <NSObject>

- (void) snapViewController:(SnapViewController *) vc didClickBackButton:(UIButton*) btn;
- (void) snapViewController:(SnapViewController *) vc didClickConfirmButton:(UIButton*) btn withJpegData:(NSData*)data;

@end