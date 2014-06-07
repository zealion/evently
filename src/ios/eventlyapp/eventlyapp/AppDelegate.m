//
//  AppDelegate.m
//  eventlyapp
//
//  Created by Lingfei Song on 14-3-5.
//  Copyright (c) 2014年 Lingfei Song. All rights reserved.
//

#import "AppDelegate.h"
#import <AFHTTPRequestOperationManager.h>
#import <Foundation/Foundation.h>
#import <MessageUI/MFMailComposeViewController.h>

#import "StartViewController.h"
#import "SnapViewController.h"

@interface AppDelegate ()

@property (strong, nonatomic) StartViewController *vc1;
@property (strong, nonatomic) SnapViewController *vc2;
@property (strong, nonatomic) NSData *picData;

@end

@implementation AppDelegate

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    // settings must present to start app
    NSUserDefaults * standardUserDefaults = [NSUserDefaults standardUserDefaults];
    NSMutableString * server_url = [[standardUserDefaults objectForKey:@"server_url"] mutableCopy];
    if ([server_url isEqualToString:@"http://"]) {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"错误" message:@"请检查App设置是否正确" delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil];
        [alert show];
        return NO;
    }

    self.vc1 = [[StartViewController alloc] init];
    self.vc2 = [[SnapViewController alloc] init];
    
    self.window = [[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
    self.window.backgroundColor = [UIColor whiteColor];
    
    [self.window makeKeyAndVisible];
    [self step1];
    return YES;
}

- (void)applicationWillResignActive:(UIApplication *)application
{
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
}

- (void)applicationDidEnterBackground:(UIApplication *)application
{
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later. 
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
}

- (void)applicationWillEnterForeground:(UIApplication *)application
{
    // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
}

- (void)applicationDidBecomeActive:(UIApplication *)application
{
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
}

- (void)applicationWillTerminate:(UIApplication *)application
{
}

#pragma mark -
#pragma mark viewcontroller transitions

- (void) step1
{
    self.window.rootViewController = self.vc1;
    self.vc1.delegate = self;
    
    NSUserDefaults * standardUserDefaults = [NSUserDefaults standardUserDefaults];
    NSMutableString * server_url = [[standardUserDefaults objectForKey:@"server_url"] mutableCopy];

    // get all guests
    if (![server_url hasSuffix:@"/"]) {
        [[server_url mutableCopy] appendFormat:@"%c", '/'];
    }
    [server_url appendFormat:@"touch"];
    
    [UIApplication sharedApplication].networkActivityIndicatorVisible = TRUE;
    
    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    [manager GET:server_url parameters:nil success:^(AFHTTPRequestOperation *operation, id responseObject) {
        BOOL success = [responseObject objectForKey:@"status"];
        if(success){
            [self.vc1 enable];
            [UIApplication sharedApplication].networkActivityIndicatorVisible = FALSE;
        }
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        
        [[[UIAlertView alloc] initWithTitle:@"错误" message:@"服务器链接失败，请退出重试！" delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil] show];
        NSLog(@"Error: %@", error);
    }];

}

- (void) step2
{
    self.window.rootViewController = self.vc2;
    self.vc2.delegate = self;
}


#pragma mark -
#pragma mark ViewController delegates

- (void) startViewController:(StartViewController *) vc didClickStartButton:(UIButton*) btn
{
    [btn setHidden:YES];
    [self step2];
}


- (void) snapViewController:(SnapViewController *)vc didClickBackButton:(UIButton *)btn
{
    [self step1];
}
- (void) snapViewController:(SnapViewController *) vc didClickConfirmButton:(UIButton *)btn withJpegData:(NSData *)data
{
    [self setPicData:data];
    NSMutableString *server_url = [[[NSUserDefaults standardUserDefaults] stringForKey:@"server_url"] mutableCopy];
    if (![server_url hasSuffix:@"/"]) {
        [[server_url mutableCopy] appendFormat:@"%c", '/'];
    }
    
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"提示" message:@"是否发送照片至邮箱" delegate:self cancelButtonTitle:@"否" otherButtonTitles:@"是",nil];



    [server_url appendFormat:@"upload"];
    
    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    NSDictionary *parameters = @{};
    
    [UIApplication sharedApplication].networkActivityIndicatorVisible = TRUE;
    [manager POST:server_url parameters:parameters constructingBodyWithBlock:^(id<AFMultipartFormData> formData) {
        [formData appendPartWithFileData:data name:@"pic_data" fileName:@"test.jpg" mimeType:@"image/jpg"];
    } success:^(AFHTTPRequestOperation *operation, id responseObject) {
        NSLog(@"Success: %@", responseObject);
        [alert show]; //照片发送完毕后 询问发送照片
        [UIApplication sharedApplication].networkActivityIndicatorVisible = FALSE;
        
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        NSLog(@"Error: %@", error);
        
    }];
    

}

-(void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if (buttonIndex == 1) {
        MFMailComposeViewController *mail = [[MFMailComposeViewController alloc] init];
        mail.mailComposeDelegate = self;
        [mail setSubject:@"2014延峰江森家庭日"];
        [mail setMessageBody:@"" isHTML:NO];
        [mail addAttachmentData:self.picData mimeType:@"image/jpg" fileName:@"test.jpg"];
        [self.window.rootViewController presentViewController:mail animated:YES completion:nil];
    } else {
        [self step1];
    }
}

- (void)mailComposeController:(MFMailComposeViewController *)controller didFinishWithResult:(MFMailComposeResult)result error:(NSError *)error
{
    //关闭邮件发送窗口
    [self.window.rootViewController dismissModalViewControllerAnimated:YES];
    NSString *msg;
    switch (result) {
        case MFMailComposeResultCancelled:
            msg = @"用户取消编辑邮件";
            break;
        case MFMailComposeResultSaved:
            msg = @"用户成功保存邮件";
            break;
        case MFMailComposeResultSent:
            msg = @"用户点击发送，将邮件放到队列中，还没发送";
            break;
        case MFMailComposeResultFailed:
            msg = @"用户试图保存或者发送邮件失败";
            break;
        default:
            msg = @"";
            break;
    }
    [self step1];
    
}

@end
