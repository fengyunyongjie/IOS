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
#import "WelcomeViewController.h"
#import "PConfig.h"
#import "YNFunctions.h"

@implementation AppDelegate
@synthesize downmange,myTabBarVC,loginVC,uploadmanage,isStopUpload,musicPlayer,file_url,isConnection;

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    isConnection = YES;
    //初始化数据
    downmange = [[DownManager alloc] init];
    uploadmanage = [[UploadManager alloc] init];
    UIApplication *app = [UIApplication sharedApplication];
    app.applicationIconBadgeNumber = [uploadmanage.uploadArray count];
    
    //监听网络
    NSNotificationCenter *defaultCenter = [NSNotificationCenter defaultCenter];
    [defaultCenter addObserver:self selector:@selector(reachabilityChanged:) name:kReachabilityChangedNotification object:nil];
    hostReach = [Reachability reachabilityWithHostName:@"www.baidu.com"];
    [hostReach startNotifier];
    
    [[DBSqlite3 alloc] updateVersion];
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
    
    if ([launchOptions objectForKey:UIApplicationLaunchOptionsLocalNotificationKey]) {
        NSLog(@"应用程序从知道中心启动：%@",[launchOptions objectForKey:UIApplicationLaunchOptionsLocalNotificationKey]);
    }else
    {
        NSLog(@"应用程序正常启动");
    }
//屏蔽掉消息推送！
//    if ([YNFunctions isMessageAlert]) {
//        // Required
//        [APService registerForRemoteNotificationTypes:(UIRemoteNotificationTypeBadge |
//                                                       UIRemoteNotificationTypeSound |
//                                                       UIRemoteNotificationTypeAlert)];
//    }
//
//    // Required
//    [APService setupWithOption:launchOptions];
    //给程序添加日志
    [DDLog addLogger:[DDASLLogger sharedInstance]];
    [DDLog addLogger:[DDTTYLogger sharedInstance]];
    if ([LTHPasscodeViewController passcodeExistsInKeychain]) {
		// Init the singleton
		[LTHPasscodeViewController sharedUser];
		if ([LTHPasscodeViewController didPasscodeTimerEnd])
			[[LTHPasscodeViewController sharedUser] showLockscreen];
	}
    NSString *vinfo=[[NSUserDefaults standardUserDefaults]objectForKey:VERSION];
    if (!vinfo) {
        [[WelcomeViewController sharedUser] showWelCome];
//        [[NSUserDefaults standardUserDefaults] setObject:VERSION forKey:VERSION];
    }
    //设置背景音乐
    musicPlayer = [[MusicPlayerViewController alloc] init];
    
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
    [musicPlayer stopPlay];
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
    if(self.downmange.isStart || self.uploadmanage.isStart)
    {
        [musicPlayer startPlay];
    }
    else
    {
        [musicPlayer stopPlay];
    }
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
    //屏蔽掉消息推送！
    [APService registerDeviceToken:deviceToken];
}

- (void)application:(UIApplication *)application didReceiveRemoteNotification:(NSDictionary *)userInfo {
    // Required
    //屏蔽掉消息推送！
    [APService handleRemoteNotification:userInfo];
    NSLog(@"接收到通知，内容：%@",userInfo);
    NSLog(@"应用程序状态：%@",@"");
    
}


//网络链接改变时会调用的方法
-(void)reachabilityChanged:(NSNotification *)note
{
    Reachability *currReach = [note object];
    NSParameterAssert([currReach isKindOfClass:[Reachability class]]);
    
    //对连接改变做出响应处理动作
    NetworkStatus status = [currReach currentReachabilityStatus];
    NSLog(@"status:%i",status);
    switch (status) {
        case 0://无网络
        {
            
        }
            break;
        case 1://WLAN
        {
            isConnection = YES;
            if(![YNFunctions isOnlyWifi])
            {
                if([self.uploadmanage isAutoStart])
                {
                    [self.uploadmanage start];
                }
                if([self.downmange isAutoStart])
                {
                    [self.downmange start];
                }
            }
        }
            break;
        case 2://WiFi
        {
            isConnection = YES;
            if([self.uploadmanage isAutoStart])
            {
                [self.uploadmanage start];
            }
            if([self.downmange isAutoStart])
            {
                [self.downmange start];
            }
        }
            break;
        default:
            break;
    }
}

@end
