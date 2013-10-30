//
//  AppDelegate.h
//  ndspro
//
//  Created by fengyongning on 13-9-25.
//  Copyright (c) 2013年 fengyongning. All rights reserved.
//
#import "DownManager.h"
#import "UploadManager.h"
#import "MusicPlayerViewController.h"
#import "Reachability.h"

#define TabBarHeight 60
#define hilighted_color [UIColor colorWithRed:255.0/255.0 green:180.0/255.0 blue:94.0/255.0 alpha:1.0]

#import <UIKit/UIKit.h>
@class LoginViewController,MyTabBarViewController;
@interface AppDelegate : UIResponder <UIApplicationDelegate>
{
    Reachability *hostReach;
}

@property (strong, nonatomic) UIWindow *window;
@property (strong, nonatomic) LoginViewController *loginVC;
@property (strong, nonatomic) MyTabBarViewController *myTabBarVC;
@property (strong, nonatomic) DownManager *downmange;
@property (strong, nonatomic) UploadManager *uploadmanage;
@property (assign, nonatomic) BOOL isStopUpload;
@property (nonatomic, strong) MusicPlayerViewController *musicPlayer;
@property (strong, nonatomic) NSString *file_url;
@property (assign, nonatomic) BOOL isConnection;


-(void)finishLogin;
-(void)finishLogout;
@end
