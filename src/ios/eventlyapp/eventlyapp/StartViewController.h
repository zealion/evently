//
//  RootViewController.h
//  eventlyapp
//
//  Created by Lingfei Song on 14-3-9.
//  Copyright (c) 2014年 Lingfei Song. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol StartViewControllerDelegate;

@interface StartViewController : UIViewController

@property (nonatomic, weak) id<StartViewControllerDelegate> delegate;

- (void) enable;

@end

@protocol StartViewControllerDelegate <NSObject>

@optional

- (void) startViewController:(StartViewController *) vc didClickStartButton:(UIButton*) btn;

@end
