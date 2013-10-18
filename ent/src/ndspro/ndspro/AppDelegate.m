//
//  AppDelegate.m
//  ndspro
//
//  Created by fengyongning on 13-9-25.
//  Copyright (c) 2013年 fengyongning. All rights reserved.
//

#import "AppDelegate.h"
#import "LoginViewController.h"
#import "MyTabBarViewController.h"
#import "APService.h"
#import "DDASLLogger.h"
#import "DDTTYLogger.h"
#import "LTHPasscodeViewController.h"
#import "DBSqlite3.h"

@implementation AppDelegate
@synthesize downmange,myTabBarVC,loginVC,uploadmanage,isStopUpload;

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    //初始化数据
    downmange = [[DownManager alloc] init];
    uploadmanage = [[UploadManager alloc] init];
    DBSqlite3 *sql = [[DBSqlite3 alloc] init];
    [sql updateVersion];
    self.window = [[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
    // Override point for customization after application launch.
    self.window.backgroundColor = [UIColor whiteColor];
    [self.window makeKeyAndVisible];
    if ([self isLogin]) {
        [self finishLogin];
    }else
    {
        [self finishLogout];
    }
    
    // Required
    [APService registerForRemoteNotificationTypes:(UIRemoteNotificationTypeBadge |
                                                   UIRemoteNotificationTypeSound |
                                                   UIRemoteNotificationTypeAlert)];
    // Required
    [APService setupWithOption:launchOptions];
    //给程序添加日志
    [DDLog addLogger:[DDASLLogger sharedInstance]];
    [DDLog addLogger:[DDTTYLogger sharedInstance]];
    if ([LTHPasscodeViewController passcodeExistsInKeychain]) {
		// Init the singleton
		[LTHPasscodeViewController sharedUser];
		if ([LTHPasscodeViewController didPasscodeTimerEnd])
			[[LTHPasscodeViewController sharedUser] showLockscreen];
	}
    return YES;
}

- (void)applicationWillResignActive:(UIApplication *)application {
	if ([LTHPasscodeViewController passcodeExistsInKeychain]) {
		[LTHPasscodeViewController saveTimerStartTime];
		if ([LTHPasscodeViewController timerDuration] == 0)
			[[LTHPasscodeViewController sharedUser] showLockscreen];
	}
}

-(void)applicationWillEnterForeground:(UIApplication *)application {
	if ([LTHPasscodeViewController passcodeExistsInKeychain] && [LTHPasscodeViewController didPasscodeTimerEnd]) {
		[[LTHPasscodeViewController sharedUser] showLockscreen];
	}
}

-(BOOL)isLogin
{
    NSString *userName = [[NSUserDefaults standardUserDefaults] objectForKey:@"usr_name"];
    NSString *userPwd  = [[NSUserDefaults standardUserDefaults] objectForKey:@"usr_pwd"];
    if (userName==nil&&userPwd==nil) {
        return NO;
    }
    return YES;
}
-(void)finishLogin
{
    self.myTabBarVC=[[MyTabBarViewController alloc] initWithNibName:@"MyTabBarViewController" bundle:nil];
    self.window.rootViewController=self.myTabBarVC;
}
-(void)finishLogout
{
    self.loginVC=[[LoginViewController alloc] initWithNibName:@"LoginViewController" bundle:nil];
    self.window.rootViewController=self.loginVC;
}

- (void)applicationDidEnterBackground:(UIApplication *)application
{
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later. 
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
}

- (void)applicationDidBecomeActive:(UIApplication *)application
{
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
}

- (void)applicationWillTerminate:(UIApplication *)application
{
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
}
- (void)application:(UIApplication *)application didRegisterForRemoteNotificationsWithDeviceToken:(NSData *)deviceToken {
    
    // Required
    [APService registerDeviceToken:deviceToken];
}

- (void)application:(UIApplication *)application didReceiveRemoteNotification:(NSDictionary *)userInfo {
    // Required
    [APService handleRemoteNotification:userInfo];
}

@end
