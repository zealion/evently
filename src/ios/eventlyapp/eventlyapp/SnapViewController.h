//
//  SnapViewController.h
//  eventlyapp
//
//  Created by Lingfei Song on 14-3-8.
//  Copyright (c) 2014年 Lingfei Song. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <AVFoundation/AVFoundation.h>

@interface SnapViewController : UIViewController

- (BOOL) isCameraAvailable;
- (void) startPreview;
- (void) stopPreview;
- (void) capture;

@end
