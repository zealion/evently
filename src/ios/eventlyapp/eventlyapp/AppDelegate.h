//
//  AppDelegate.h
//  eventlyapp
//
//  Created by Lingfei Song on 14-3-5.
//  Copyright (c) 2014年 Lingfei Song. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ScanViewController.h"

@interface AppDelegate : UIResponder <UIApplicationDelegate, ScanViewControllerDelegate>

@property (strong, nonatomic) UIWindow *window;

@property (readonly, strong, nonatomic) NSManagedObjectContext *managedObjectContext;
@property (readonly, strong, nonatomic) NSManagedObjectModel *managedObjectModel;
@property (readonly, strong, nonatomic) NSPersistentStoreCoordinator *persistentStoreCoordinator;

- (void)saveContext;
- (NSURL *)applicationDocumentsDirectory;

@end
