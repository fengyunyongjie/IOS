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
#import "TaskDemo.h"
#import "YNFunctions.h"
#import "OpenViewController.h"
#import "DefaultViewController.h"
#import "sys/utsname.h"
#import "UploadViewController.h"

@implementation AppDelegate
@synthesize user_name;
@synthesize isUnUpload;


- (void)dealloc
{
    [_window release];
    [_myTabBarController release];
    [user_name release];
    [super dealloc];
}
- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    self.window = [[[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]] autorelease];
    self.myTabBarController=[[[MYTabBarController alloc] init] autorelease];
    DefaultViewController *viewController=[[[DefaultViewController alloc] init] autorelease];
    self.window.rootViewController=viewController;
    //程序启动时，在代码中向微信终端注册你的id
    [WXApi registerApp:@"wxdcc0186c9f173352"];
    [self.window makeKeyAndVisible];
    //处理其它程序调用本程序打开文件
    if ([YNFunctions isUnlockFeature]) {
        NSURL *url=[launchOptions objectForKey:UIApplicationLaunchOptionsURLKey];
        if (url) {
            NSLog(@"the URL:%@",url);
            OpenViewController *viewController=[[[OpenViewController alloc] initWithNibName:@"OpenViewController" bundle:nil] autorelease];
            [viewController setTitle:[url description]];
            [self.window.rootViewController presentViewController:viewController animated:YES completion:nil];
        }
    }
    [self performSelector:@selector(goMainViewController) withObject:self afterDelay:1.0f];
    return YES;
}
-(void)goMainViewController
{
    [[UIApplication sharedApplication] setStatusBarHidden:NO];
    self.window.rootViewController=self.myTabBarController;
}
- (void) onReq:(BaseReq*)req
{

}

- (void) onResp:(BaseResp*)resp
{
    if([resp isKindOfClass:[SendMessageToWXResp class]])
    {
        NSString *strMsg = [NSString stringWithFormat:@"发送消息结果:%d",resp.errCode];
        NSLog(@"strMSg：%@",strMsg);
    }
}

//获取图片路径
- (NSString*)get_image_save_file_path:(NSString*)image_path
{
    NSString *documentDir = [YNFunctions getProviewCachePath];
    NSArray *array=[image_path componentsSeparatedByString:@"/"];
    NSString *path=[NSString stringWithFormat:@"%@/%@",documentDir,[array lastObject]];
    return path;
}

- (void) sendImageContentIsFiends:(BOOL)bl path:(NSString *)path
{
    BOOL isSuccess =[WXApi isWXAppInstalled]; 
    if(!isSuccess)
    {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"提示" message:@"你的手机还没有安装微信客户端" delegate:nil cancelButtonTitle:@"取消" otherButtonTitles:nil, nil];
        [alert show];
        [alert release];
        return;
    }
    WXMediaMessage *message = [WXMediaMessage message];
    NSString *filePath = [self get_image_save_file_path:path];
    NSLog(@"filePath:%@",filePath);
    NSData *data = [[NSData alloc] initWithContentsOfFile:filePath];
    NSLog(@"data:%i",[data length]/1024);
    UIImage *imageV = [UIImage imageWithContentsOfFile:filePath];
    if([data length]>=32)
    {
        imageV = [self scaleFromImage:imageV toSize:CGSizeMake(200, 200)];
    }    
    [message setThumbImage:imageV];
    WXImageObject *ext = [WXImageObject object];
    
    ext.imageData = UIImagePNGRepresentation(imageV);
    NSLog(@"data:%i",[ext.imageData length]/1024);
    [data release];
    message.mediaObject = ext;
    SendMessageToWXReq* req = [[[SendMessageToWXReq alloc] init]autorelease];
    req.bText = NO;
    req.message = message;
    if(bl)
    {
        req.scene = WXSceneTimeline;  //选择发送到朋友圈，默认值为WXSceneSession，发送到会话
    }
    [WXApi sendReq:req];
}

-(UIImage *)imageFromImage:(UIImage *)image inRect:(CGRect)rect{
	CGImageRef sourceImageRef = [image CGImage];
	CGImageRef newImageRef = CGImageCreateWithImageInRect(sourceImageRef, rect);
	UIImage *newImage = [UIImage imageWithCGImage:newImageRef];
    CGImageRelease(newImageRef);
	return newImage;
}


-(UIImage *)scaleFromImage:(UIImage *)image toSize:(CGSize)size
{
    UIGraphicsBeginImageContext(size);
    [image drawInRect:CGRectMake(0, 0, size.width, size.height)];
    UIImage *newImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return newImage;
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
    self.myTabBarController.selectedIndex = 2;
    self.myTabBarController.selectedIndex = 1;
    self.myTabBarController.selectedIndex = 0;
}

#pragma mark 判断设备号

+ (NSString *)deviceString
{
    // 需要
    struct utsname systemInfo;
    uname(&systemInfo);
    NSString *deviceString = [NSString stringWithCString:systemInfo.machine encoding:NSUTF8StringEncoding];
    
    if ([deviceString isEqualToString:@"iPhone1,1"])    return @"iPhone 1G";
    if ([deviceString isEqualToString:@"iPhone1,2"])    return @"iPhone 3G";
    if ([deviceString isEqualToString:@"iPhone2,1"])    return @"iPhone 3GS";
    if ([deviceString isEqualToString:@"iPhone3,1"])    return @"iPhone 4";
    if ([deviceString isEqualToString:@"iPhone4,1"])    return @"iPhone 4S";
    if ([deviceString isEqualToString:@"iPhone5,2"])    return @"iPhone 5";
    if ([deviceString isEqualToString:@"iPhone3,2"])    return @"iPhone 4";
    if ([deviceString isEqualToString:@"iPod1,1"])      return @"iPod Touch 1G";
    if ([deviceString isEqualToString:@"iPod2,1"])      return @"iPod Touch 2G";
    if ([deviceString isEqualToString:@"iPod3,1"])      return @"iPod Touch 3G";
    if ([deviceString isEqualToString:@"iPod4,1"])      return @"iPod Touch 4G";
    if ([deviceString isEqualToString:@"iPad1,1"])      return @"iPad";
    if ([deviceString isEqualToString:@"iPad2,1"] || [deviceString isEqualToString:@"iPad2,4"])      return @"iPad 2 (WiFi)";
    if ([deviceString isEqualToString:@"iPad2,2"])      return @"iPad 2 (GSM)";
    if ([deviceString isEqualToString:@"iPad2,3"])      return @"iPad 2 (CDMA)";
    if ([deviceString isEqualToString:@"i386"])         return @"Simulator";
    if ([deviceString isEqualToString:@"x86_64"])       return @"Simulator";
    NSLog(@"NOTE: Unknown device type: %@", deviceString);
    return deviceString;
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
    if(self.myTabBarController.selectedIndex == 3)
    {
        if([YNFunctions isAutoUpload])
        {
            UINavigationController *NavigationController = [[self.myTabBarController viewControllers] objectAtIndex:3];
            UploadViewController *uploadView = (UploadViewController *)[NavigationController.viewControllers objectAtIndex:0];
            [uploadView startSouStart];
        }
    }
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
}

- (void)applicationWillTerminate:(UIApplication *)application
{
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
}
//- (NSUInteger)application:(UIApplication *)application supportedInterfaceOrientationsForWindow:(UIWindow *)window
//{
//    NSUInteger orientations = UIInterfaceOrientationMaskAll;
//    
//    if (self.window.rootViewController) {
//        UIViewController* presented = [[(UINavigationController *)self.window.rootViewController viewControllers] lastObject];
//        orientations = [presented supportedInterfaceOrientations];
//    }
//    return orientations;
//}
@end
