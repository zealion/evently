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

- (void) viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    [self.indicator setHidden:NO];
    [self.indicator startAnimating];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    [self.view addSubview:[[UIImageView alloc] initWithImage:[UIImage imageNamed:@"bg"]]];
    [self.view addSubview:[[UIImageView alloc] initWithImage:[UIImage imageNamed:@"title1"]]];

    self.btnStart = [UIButton buttonWithType:UIButtonTypeCustom];
    self.btnStart.frame = CGRectMake(550.0, 550.0, 108.0, 108.0);
    [self.btnStart setBackgroundImage:[UIImage imageNamed:@"btnStart"] forState:UIControlStateNormal];
    [self.btnStart addTarget:self action:@selector(clickBtnStart:withEvent:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:self.btnStart];
    [self.btnStart setHidden:YES];
    
    self.indicator = [[UIActivityIndicatorView alloc]initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
    self.indicator.frame = CGRectMake(0.0, 0.0, 40.0, 40.0);
    self.indicator.color = [UIColor whiteColor];
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
