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

#import "StartViewController.h"
#import "ScanViewController.h"
#import "SnapViewController.h"

@interface AppDelegate ()

@property (strong, nonatomic) StartViewController *vc1;
@property (strong, nonatomic) ScanViewController *vc2;
@property (strong, nonatomic) SnapViewController *vc3;
@property (strong, nonatomic) NSArray *guests;
@property (strong, nonatomic) NSDictionary *currentGuest;

@end

@implementation AppDelegate

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    // settings must present to start app
    NSUserDefaults * standardUserDefaults = [NSUserDefaults standardUserDefaults];
    NSMutableString * server_url = [[standardUserDefaults objectForKey:@"server_url"] mutableCopy];
    NSString * event_id = [standardUserDefaults objectForKey:@"event_id"];
    if (!server_url || !event_id || [server_url isEqualToString:@"http://"]) {
        
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"错误" message:@"请检查App设置是否正确" delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil];
        [alert show];
        return NO;
    }

    self.vc1 = [[StartViewController alloc] init];
    self.vc2 = [[ScanViewController alloc] init];
    self.vc3 = [[SnapViewController alloc] init];
    
    self.window = [[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
    self.window.backgroundColor = [UIColor whiteColor];
    
    [self step1];
    
    [self.window makeKeyAndVisible];
    
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
    NSString * event_id = [standardUserDefaults objectForKey:@"event_id"];

    // get all guests
    if (![server_url hasSuffix:@"/"]) {
        [[server_url mutableCopy] appendFormat:@"%c", '/'];
    }
    [server_url appendFormat:@"event/%@/guests", event_id];
    
    [UIApplication sharedApplication].networkActivityIndicatorVisible = TRUE;
    
    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    [manager GET:server_url parameters:nil success:^(AFHTTPRequestOperation *operation, id responseObject) {
        BOOL success = [responseObject objectForKey:@"status"];
        if(success){
            self.guests = [responseObject objectForKey:@"body"];
            
            [self.vc1 enable];
            
            [UIApplication sharedApplication].networkActivityIndicatorVisible = FALSE;
            
            NSLog(@"got %tu guests", [self.guests count]);
        }
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        
        [[[UIAlertView alloc] initWithTitle:@"错误" message:@"嘉宾数据读取失败，请退出重试！" delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil] show];
        
        NSLog(@"Error: %@", error);
    }];

}

- (void) step2
{
    self.window.rootViewController = self.vc2;
    self.vc2.delegate = self;
}

- (void) step3
{
    self.window.rootViewController = self.vc3;
    self.vc3.delegate = self;
}

#pragma mark -
#pragma mark ViewController delegates

- (void) startViewController:(StartViewController *) vc didClickStartButton:(UIButton*) btn
{
    [btn setHidden:YES];
    [self step2];
}

- (void) scanViewController:vc didSuccessfullyScan:(NSString *)scannedId {
    NSLog(@"ID: %@", scannedId);
    
    __block BOOL found = NO;
    __block NSDictionary *dict = nil;
    
    [self.guests enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
        dict = (NSDictionary *)obj;
        NSString *qrcode_id = [dict valueForKey:@"qrcode_id"];
        if ([qrcode_id isEqualToString:scannedId]) {
            found = YES;
            *stop = YES;
        }
    }];
    
    if (found) {
        NSString *name = [NSString stringWithFormat:@"姓名/Name:  %@", [[dict objectForKey:@"name"] isEqual:[NSNull null]]?@"":[dict valueForKey:@"name"]];
        NSString *company = [NSString stringWithFormat:@"公司/Company:  %@", [[dict objectForKey: @"company"] isEqual:[NSNull null]]?@"":[dict valueForKey: @"company"]];
        NSString *email = [NSString stringWithFormat:@"邮箱/Email:  %@", [[dict valueForKey: @"email"] isEqual:[NSNull null]]?@"":[dict valueForKey: @"email"]];
        [vc scanValidated:YES withName:name company:company email:email];
        
        self.currentGuest = dict;
    }
    else
    {
        [vc scanValidated:NO withName:nil company:nil email:nil];
    }
}

- (void) scanViewController:(ScanViewController *) vc didClickBackButton:(UIButton*) btn
{
    [self step1];
}

- (void) snapViewController:(ScanViewController *) vc didClickBackButton:(UIButton*) btn
{
    [self step2];
}

- (void) scanViewController:(ScanViewController *) vc didClickNextButton:(UIButton*) btn
{
    [btn setHidden:YES];
    [self step3];
}

- (void) snapViewController:(SnapViewController *) vc didClickConfirmButton:(UIButton *)btn withJpegData:(NSData *)data
{
    if(self.currentGuest==nil) return;
    
    NSString *event_id = [[NSUserDefaults standardUserDefaults] stringForKey:@"event_id"];
    NSMutableString *server_url = [[[NSUserDefaults standardUserDefaults] stringForKey:@"server_url"] mutableCopy];
    if (![server_url hasSuffix:@"/"]) {
        [[server_url mutableCopy] appendFormat:@"%c", '/'];
    }
    
    NSString *qrcode_id = [self.currentGuest valueForKey:@"qrcode_id"];
    
    [server_url appendFormat:@"event/%@/guest/%@", event_id, qrcode_id];
    
    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    NSDictionary *parameters = @{@"qrcode_id": qrcode_id, @"is_arrived": @1};
    
    [UIApplication sharedApplication].networkActivityIndicatorVisible = TRUE;
    [manager POST:server_url parameters:parameters constructingBodyWithBlock:^(id<AFMultipartFormData> formData) {
        [formData appendPartWithFileData:data name:@"pic_data" fileName:@"test.jpg" mimeType:@"image/jpg"];
    } success:^(AFHTTPRequestOperation *operation, id responseObject) {
        NSLog(@"Success: %@", responseObject);
        
        [UIApplication sharedApplication].networkActivityIndicatorVisible = FALSE;

        [self step1];
        
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        NSLog(@"Error: %@", error);
    }];
}

@end
