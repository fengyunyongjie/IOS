//
//  AppDelegate.m
//  newnds
//
//  Created by fengyongning on 13-4-26.
//
//
//#import "MobClick.h"
#import "AppDelegate.h"
//#import "LoginViewController.h"
#import "MYTabBarController.h"

@implementation AppDelegate
@synthesize user_name;

- (void)dealloc
{
    [_window release];
    [_myTabBarController release];
    [user_name release];
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
    
    //！！！程序启动时不需要每次都进入登录窗口，只有注销和第一次启动时才进入登录窗口，所以我所这儿注释掉，在MyTabBarController判断！是否显示登录页面
    
    //LoginViewController *lv=[[[LoginViewController alloc] initWithNibName:@"LoginViewController" bundle:nil] autorelease];
    //    [self.window.rootViewController presentViewController:lv animated:YES completion:^(void){}];
    //self.window.rootViewController = lv;
    
    //程序启动时，在代码中向微信终端注册你的id
    
    [WXApi registerApp:@"wxd930ea5d5a258f4f"];
    [self.window makeKeyAndVisible];
    return YES;
}

- (void) onReq:(BaseReq*)req
{

}

- (void) onResp:(BaseResp*)resp
{
    if([resp isKindOfClass:[SendMessageToWXResp class]])
    {
        NSString *strMsg = [NSString stringWithFormat:@"发送消息结果:%d",resp.errCode];
    }
}

- (void) sendImageContent
{
    WXMediaMessage *message = [WXMediaMessage message];
    [message setThumbImage:[UIImage imageNamed:@"footbtn.png"]];
    WXImageObject *ext = [WXImageObject object];
    NSString *filePath = [[NSBundle mainBundle] pathForResource:@"footbtn" ofType:@"png"];
    ext.imageData = [NSData dataWithContentsOfFile:filePath] ;
    message.mediaObject = ext;
    SendMessageToWXReq* req = [[[SendMessageToWXReq alloc] init]autorelease];
    req.bText = NO;
    req.message = message;
    //req.scene = WXSceneTimeline;  //选择发送到朋友圈，默认值为WXSceneSession，发送到会话
    [WXApi sendReq:req];
}

- (BOOL)application:(UIApplication *)application handleOpenURL:(NSURL *)url
{
    return  [WXApi handleOpenURL:url delegate:self];
}
- (BOOL)application:(UIApplication *)application openURL:(NSURL *)url sourceApplication:(NSString *)sourceApplication annotation:(id)annotation
{
    return  [WXApi handleOpenURL:url delegate:self];
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
