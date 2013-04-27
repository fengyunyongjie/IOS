//
//  AppDelegate.m
//  newnds
//
//  Created by fengyongning on 13-4-26.
//
//

#import "AppDelegate.h"

@implementation AppDelegate

- (void)dealloc
{
    [_window release];
    [_myTabBarController release];
    [super dealloc];
}

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    self.window = [[[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]] autorelease];
    // Override point for customization after application launch.
    
    UINavigationController *viewController1,*viewController2,*viewController3,*viewController4,*viewController5,*viewController6;
    viewController1=[[[UINavigationController alloc] init] autorelease];
    viewController1.title=@"First";
    UITableViewController *rootView1=[[[UITableViewController alloc] init ]autorelease];
    rootView1.title=@"我的网盘";
    [viewController1 pushViewController:rootView1 animated:YES];
    
    
    viewController2=[[[UINavigationController alloc] init] autorelease];
    viewController2.title=@"Second";
    UIViewController * rootView2=[[[UIViewController alloc] init] autorelease];
    rootView2.title=@"收藏";
    [viewController2 pushViewController:rootView2 animated:YES];
    
    viewController3=[[[UINavigationController alloc] init] autorelease];
    viewController3.title=@"Third";
    UIViewController * rootView3=[[[UIViewController alloc] init] autorelease];
    rootView3.title=@"照片";
    [viewController3 pushViewController:rootView3 animated:YES];
    
    viewController4=[[[UINavigationController alloc] init] autorelease];
    viewController4.title=@"fourth";
    UIViewController * rootView4=[[[UIViewController alloc] init] autorelease];
    rootView4.title=@"上传";
    [viewController4 pushViewController:rootView4 animated:YES];
    
    viewController5=[[[UINavigationController alloc] init] autorelease];
    viewController5.title=@"fifth";
    UIViewController * rootView5=[[[UIViewController alloc] init] autorelease];
    rootView5.title=@"设置";
    [viewController5 pushViewController:rootView5 animated:YES];
    
    viewController6=[[[UINavigationController alloc] init] autorelease];
    viewController6.title=@"sixth";
    
    self.myTabBarController=[[[UITabBarController alloc] init] autorelease];
    self.myTabBarController.delegate=self;
    self.myTabBarController.viewControllers=[NSArray arrayWithObjects:viewController1,viewController2,viewController3,viewController4,viewController5, nil];

    
    self.window.rootViewController=self.myTabBarController;
    
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
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
}

@end
