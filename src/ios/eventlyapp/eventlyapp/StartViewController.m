//
//  RootViewController.m
//  eventlyapp
//
//  Created by Lingfei Song on 14-3-9.
//  Copyright (c) 2014年 Lingfei Song. All rights reserved.
//

#import "StartViewController.h"
#import <AFNetworking.h>

@interface StartViewController ()

@property (strong, nonatomic) UIButton *btnStart;
@property (strong, nonatomic) UIActivityIndicatorView *indicator;

@end

@implementation StartViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];

    self.btnStart = [UIButton buttonWithType:UIButtonTypeRoundedRect];
    [self.btnStart addTarget:self action:@selector(clickBtnStart:withEvent:) forControlEvents:UIControlEventTouchUpInside];
    [self.btnStart setTitle:@"Start" forState:UIControlStateNormal];
    self.btnStart.frame = CGRectMake(0.0, 0.0, 80.0, 80.0);
    self.btnStart.center = self.view.center;
    [self.view addSubview:self.btnStart];
    [self.btnStart setHidden:YES];
    
    self.indicator = [[UIActivityIndicatorView alloc]initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
    self.indicator.frame = CGRectMake(0.0, 0.0, 40.0, 40.0);
    self.indicator.center = self.view.center;
    [self.view addSubview:self.self.indicator];
    [self.indicator bringSubviewToFront:self.view];
    [self.indicator startAnimating];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark -
#pragma mark UI

- (void) enable
{
    [self.indicator stopAnimating];
    [self.indicator setHidden:YES];
    [self.btnStart setHidden:NO];
}

- (void) clickBtnStart: (UIButton*)button withEvent:(UIEvent*)event
{
    if([self.delegate respondsToSelector:@selector(startViewController:didClickStartButton:)]) {
        [self.delegate startViewController:self didClickStartButton:self.btnStart];
    }
}

@end
