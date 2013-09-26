//
//  AppDelegate.h
//  ndspro
//
//  Created by fengyongning on 13-9-25.
//  Copyright (c) 2013年 fengyongning. All rights reserved.
//

#import <UIKit/UIKit.h>
@class LoginViewController,MyTabBarViewController;
@interface AppDelegate : UIResponder <UIApplicationDelegate>

@property (strong, nonatomic) UIWindow *window;
@property (strong, nonatomic) LoginViewController *loginVC;
@property (strong, nonatomic) MyTabBarViewController *myTabBarVC;
-(void)finishLogin;
-(void)finishLogout;
@end
