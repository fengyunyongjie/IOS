//
//  AppDelegate.m
//  newnds
//
//  Created by fengyongning on 13-4-26.
//
//
//#import "MobClick.h"
#import "AppDelegate.h"
#import "LoginViewController.h"
#import "MYTabBarController.h"

@implementation AppDelegate

- (void)dealloc
{
    [_window release];
    [_myTabBarController release];
    [super dealloc];
}

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
//    [MobClick startWithAppkey:@"5158f8f056240bb70c030e97"];
    self.window = [[[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]] autorelease];
    // Override point for customization after application launch.
    self.myTabBarController=[[[MYTabBarController alloc] init] autorelease];
//    UINavigationController *root=[[UINavigationController alloc] initWithRootViewController:self.myTabBarController];
    self.window.rootViewController=self.myTabBarController;
    
//    LoginViewController *lv=[[[LoginViewController alloc] initWithNibName:@"LoginViewController" bundle:nil] autorelease];
//    [self.window.rootViewController presentViewController:lv animated:YES completion:^(void){}];
    
    [self.window makeKeyAndVisible];
    return YES;
}
-(void)setLogin
{
    self.window.rootViewController=self.myTabBarController;
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
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
}

@end
