//
//  AppDelegate.h
//  eventlyapp
//
//  Created by Lingfei Song on 14-3-5.
//  Copyright (c) 2014年 Lingfei Song. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "StartViewController.h"
#import "ScanViewController.h"
#import "SnapViewController.h"

@interface AppDelegate : UIResponder <UIApplicationDelegate, ScanViewControllerDelegate, StartViewControllerDelegate, SnapViewControllerDelegate>

@property (strong, nonatomic) UIWindow *window;

@end
