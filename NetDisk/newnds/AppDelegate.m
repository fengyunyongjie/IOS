
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
#import "LoginViewController.h"
#import "SettingViewController.h"
#import "MyndsViewController.h"
//#import "PhotoViewController.h"
#import "FavoritesViewController.h"
//#import "UploadViewController.h"
#import "IPhotoViewController.h"
#import "MainViewController.h"
#import "ChangeUploadViewController.h"
#import "UserInfo.h"
#import "APService.h"
#import "MessagePushController.h"
#import "YNFunctions.h"
#import "BackgroundRunner.h"
#import "SCBSession.h"
#import "NSString+Format.h"
#import "DownImage.h"
#import "DBSqlite3.h"
#import "YNNavigationController.h"
#import "SCBFileManager.h"

@implementation AppDelegate
@synthesize user_name;
@synthesize isUnUpload;
@synthesize upload_all;
@synthesize maticUpload;
@synthesize isAutomicUpload;
@synthesize title_string;
@synthesize moveUpload;
@synthesize autoUpload;
@synthesize musicPlayer;
@synthesize isShareUpload;
@synthesize downImageArray;
@synthesize isHomeLoad;
@synthesize imagePath;

@class UploadAll;
- (void)dealloc
{
    [_window release];
    [_myTabBarController release];
    [user_name release];
//    [upload_all release];
    [super dealloc];
}

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    //开启推送功能！
    [[UIApplication sharedApplication] registerForRemoteNotificationTypes:(UIRemoteNotificationTypeAlert |    UIRemoteNotificationTypeBadge |UIRemoteNotificationTypeSound)];
    NSNotificationCenter *defaultCenter = [NSNotificationCenter defaultCenter];
    [defaultCenter addObserver:self selector:@selector(reachabilityChanged:) name:kReachabilityChangedNotification object:nil];
    if ([YNFunctions isAlertMessage]) {
        [APService
         registerForRemoteNotificationTypes:(UIRemoteNotificationTypeBadge |
                                             UIRemoteNotificationTypeSound |
                                             UIRemoteNotificationTypeAlert)];
    }
    // Required
    
    // Required
    [APService setupWithOption:launchOptions];
    [defaultCenter addObserver:self selector:@selector(networkDidReceiveMessage:) name:kAPNetworkDidReceiveMessageNotification object:nil];
    //开启推送结束
    
    
    [[DBSqlite3 alloc] updateVersion];
    upload_all = [[UploadAll alloc] init];
    maticUpload = [[AutomaticUpload alloc] init];
    moveUpload = [[MoveUpload alloc] init];
    autoUpload = [[NewAutoUpload alloc] init];
    downImageArray = [[NSMutableArray alloc] init];

    //网络监听
    hostReach = [Reachability reachabilityWithHostName:@"www.baidu.com"];
    [hostReach startNotifier]; 
    
    self.window = [[[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]] autorelease];
    
    if ([self isLogin]) {
        [self finishLogin];
    }else
    {
        [self finishLogout];
    }
    
    if ([launchOptions objectForKey:UIApplicationLaunchOptionsLocalNotificationKey]) {
        NSLog(@"应用程序从通知中心启动：%@",[launchOptions objectForKey:UIApplicationLaunchOptionsLocalNotificationKey]);
    }else
    {
        NSLog(@"应用程序正常启动");
    }
    
    
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
    //设置背景音乐
    musicPlayer = [[MusicPlayerViewController alloc] init];
//    //设置屏幕常亮
//    [[UIApplication sharedApplication] setIdleTimerDisabled:YES];
    return YES;
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
    [self initMyTabBarCtrl];
    self.window.rootViewController=self.myTabBarController;
    [NSTimer scheduledTimerWithTimeInterval:0.5 target:self selector:@selector(openAutomic) userInfo:self repeats:NO];
    [[UIApplication sharedApplication] setStatusBarHidden:NO];
    
    SCBFileManager *fm=[[SCBFileManager alloc] init];
    fm.delegate=self;
    [fm requestOpenFamily:@""];
}

-(void)finishLogout
{
    self.loginVC=[[YNNavigationController alloc] initWithRootViewController:[[BootViewController alloc] init]];
    self.window.rootViewController=self.loginVC;
    [[UIApplication sharedApplication] setStatusBarHidden:YES];
}

-(void)initMyTabBarCtrl
{
    self.myTabBarController=[[[MYTabBarController alloc] init] autorelease];
    [self.myTabBarController setNeed_to_custom:YES];
    [self.myTabBarController setTab_bar_bg:[UIImage imageNamed:@"Bk_Nav.png"]];
    [self.myTabBarController setNormal_image:[NSArray arrayWithObjects:@"Bt_MySpaceDef.png",@"Bt_FamilyDef.png",@"Bt_TransferDef.png",@"Bt_UsercentreDef.png", nil]];
    [self.myTabBarController setSelect_image:[NSArray arrayWithObjects:@"Bt_MySpaceCh.png",@"Bt_FamilyCh.png",@"Bt_TransferCh.png",@"Bt_UsercentreCh.png",nil]];
    [self.myTabBarController setShow_style:UItabbarControllerShowStyleIconAndText];
    [self.myTabBarController setShow_way:UItabbarControllerHorizontal Rect:CGRectMake(0, 431, 320, TabBarHeight)];
    [self.myTabBarController setFont:[UIFont boldSystemFontOfSize:12.0]];
    [self.myTabBarController setFont_color:[UIColor whiteColor]];
    [self.myTabBarController setHilighted_color:hilighted_color];
    self.myTabBarController.tab_delegate = self;
    [self addTabBarView];
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
            if(![YNFunctions isOnlyWifi])
            {
                if(self.moveUpload.isOpenedUpload)
                {
                    [self.moveUpload start];
                }
                if(self.autoUpload.isOpenedUpload)
                {
                    [self.autoUpload start];
                }
            }
        }
            break;
        case 2://WiFi
        {
            if(self.moveUpload.isOpenedUpload)
            {
                [self.moveUpload start];
            }
            if(self.autoUpload.isOpenedUpload)
            {
                [self.autoUpload start];
            }
        }
            break;
        default:
            break;
    }
}

//进入主界面
-(void)uploadFinish
{
    
}
- (void)networkDidReceiveMessage:(NSNotification *)notification {
    NSDictionary * userInfo = [notification userInfo];
    NSLog(@"%@",userInfo);
//    NSString *content = [userInfo valueForKey:@"content"];
//    NSString *extras = [userInfo valueForKey:@"extras"];
//    NSString *customizeField1 = [extras valueForKey:@"customizeField1"]; //自定义参数，key是自己定义的
    
}

-(BOOL)isFirstLoad
{
    UserInfo *info = [[[UserInfo alloc] init] autorelease];
    NSArray *array = [info selectIsHaveUser];
    if([array count]>0)
    {
        return NO;
    }
    else
    {
        return YES;
    }
}

-(BOOL)isNewUser
{
    UserInfo *info = [[[UserInfo alloc] init] autorelease];
    info.user_name = [NSString formatNSStringForOjbect:[[SCBSession sharedSession] userName]];
    NSArray *array = [info selectAllUserinfo];
    if([array count]>0)
    {
        return NO;
    }
    else
    {
        return YES;
    }
}

-(void)goMainViewController
{
    self.window.rootViewController=self.myTabBarController;
//    if([YNFunctions isAutoUpload])
//    {
//        [maticUpload isHaveData];
//    }
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

- (void) sendImageContentIsFiends:(BOOL)bl title:(NSString *)title text:(NSString *)text path:(NSString *)path imagePath:(NSString *)imagePaths
{
    if(path == nil)
    {
        WXMediaMessage *message = [WXMediaMessage message];
        
        NSData *data = [[NSData alloc] initWithContentsOfFile:imagePaths];
        UIImage *imageV = [UIImage imageWithContentsOfFile:imagePaths];
        if([data length]>=32)
        {
            imageV = [self scaleFromImage:imageV toSize:CGSizeMake(200, 200)];
        }
        [message setThumbImage:imageV];
        
        WXImageObject *ext = [WXImageObject object];
        ext.imageData = [NSData dataWithContentsOfFile:imagePaths];
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
    else
    {
        WXMediaMessage *message = [WXMediaMessage message];
        message.title = title;
        message.description = text;
        
        NSData *data = [[NSData alloc] initWithContentsOfFile:imagePaths];
        UIImage *imageV = [UIImage imageWithContentsOfFile:imagePaths];
        if([data length]>=32)
        {
            imageV = [self scaleFromImage:imageV toSize:CGSizeMake(400, 400)];
        }
        [message setThumbImage:imageV];
        
        WXWebpageObject *ext = [WXWebpageObject object];
        ext.webpageUrl = path;
        
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
    return YES;
}
- (BOOL)application:(UIApplication *)application openURL:(NSURL *)url sourceApplication:(NSString *)sourceApplication annotation:(id)annotation
{
    NSString *path = [[[url path] componentsSeparatedByString:@"."] lastObject];
    path = [path lowercaseString];
    if([path isEqualToString:@"png"]||
     [path isEqualToString:@"jpg"]||
     [path isEqualToString:@"jpeg"]||
     [path isEqualToString:@"bmp"]||
     [path isEqualToString:@"gif"])
    {
        NSString *documentDir = [YNFunctions getProviewCachePath];
        NSArray *array=[[url path] componentsSeparatedByString:@"/"];
        NSString *filePath=[NSString stringWithFormat:@"%@/%@",documentDir,[array lastObject]];
        [[NSData dataWithContentsOfURL:url] writeToFile:filePath atomically:YES];
        NSLog(@"filePath:%@",filePath);
        imagePath = [[NSString alloc] initWithFormat:@"%@",filePath];
        UIActionSheet *sheetView = [[UIActionSheet alloc] initWithTitle:@"是否保存到虹盘" delegate:self cancelButtonTitle:@"取消" destructiveButtonTitle:nil otherButtonTitles:@"确定", nil];
        [sheetView showInView:self.window];
    }
    return  YES;
}

- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if(buttonIndex == 0)
    {
//        [self.moveUpload ];
        [self clicked_changeMyFile];
    }
}

-(void)clicked_changeMyFile
{
    QBImageFileViewController *qbImage_fileView = [[QBImageFileViewController alloc] init];
    if(self.myTabBarController.selectedIndex == 0)
    {
        qbImage_fileView.space_id = [[SCBSession sharedSession] spaceID];
    }
    else if(self.myTabBarController.selectedIndex == 1)
    {
        qbImage_fileView.space_id = [[SCBSession sharedSession] homeID];
    }
    else
    {
        self.myTabBarController.selectedIndex = 0;
        qbImage_fileView.space_id = [[SCBSession sharedSession] spaceID];
    }
    qbImage_fileView.f_id = @"1";
    qbImage_fileView.f_name=@"选择上传位置";
    space_ID = qbImage_fileView.space_id;
    [qbImage_fileView setQbDelegate:self];
    
    UINavigationController *nagation = [[UINavigationController alloc] initWithRootViewController:qbImage_fileView];
    [nagation setNavigationBarHidden:YES];
    [self.myTabBarController presentModalViewController:nagation animated:YES];
    [nagation release];
    [qbImage_fileView release];
}

#pragma qbDelegate

-(void)uploadFileder:(NSString *)deviceName
{
    device_name = deviceName;
}

-(void)uploadFiledId:(NSString *)f_id_
{
    f_ID = f_id_;
    NSLog(@"imagePath:%@",imagePath);
    [self.moveUpload addUpload:imagePath changeDeviceName:device_name changeFileId:f_ID changeSpaceId:space_ID];
}

-(void)setLogin
{
    self.window.rootViewController=self.myTabBarController;
    [self addTabBarView];
    self.myTabBarController.selectedIndex = 0;
    //[self.myTabBarController.selectedViewController.navigationController popToRootViewControllerAnimated:NO];
    [self.myTabBarController when_tabbar_is_selected:0];
    //询问是否开始自动上传
    [NSTimer scheduledTimerWithTimeInterval:0.5 target:self selector:@selector(openAutomic) userInfo:self repeats:NO];
}
-(void)showHelpView
{
//    [[NSUserDefaults standardUserDefaults] setObject:nil forKey:@"showHelpInMSB"];
//    [[NSUserDefaults standardUserDefaults] setObject:nil forKey:@"showHelpInHS"];
    NSString *ttag=[[NSUserDefaults standardUserDefaults]objectForKey:@"showHelpInMSB"];
    if (ttag) {
        return;
    }
    self.helpController=[[[HelpViewController alloc] init] autorelease];
    self.helpController.thisType=kTypeMySB;
    [self.window addSubview:self.helpController.view];
}
-(void)showHomeSpaceView
{
    NSString *ttag=[[NSUserDefaults standardUserDefaults]objectForKey:@"showHelpInHS"];
    if (ttag) {
        return;
    }
    self.helpController=[[[HelpViewController alloc] init] autorelease];
    self.helpController.thisType=kTypeHomeSpace;
    [self.window addSubview:self.helpController.view];
}
-(void)finished
{
    [self.helpController.view removeFromSuperview];
    self.helpController=nil;
}
-(void)openAutomic
{
    if([self isNewUser])
    {
        [[NSUserDefaults standardUserDefaults] setObject:nil forKey:@"showHelpInMSB"];
        [[NSUserDefaults standardUserDefaults] setObject:nil forKey:@"showHelpInHS"];
        //判断是否显示帮助指南页面 ［我的虹盘］
        [NSTimer scheduledTimerWithTimeInterval:0.1 target:self selector:@selector(showHelpView) userInfo:self repeats:NO];
        
        UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"提示" message:@"是否现在就开启自动上传" delegate:self cancelButtonTitle:@"暂不开启" otherButtonTitles:@"开启", nil];
        [alertView setDelegate:self];
        [alertView show];
        [alertView release];
    }
    UserInfo *info = [[[UserInfo alloc] init] autorelease];
    info.user_name = [NSString formatNSStringForOjbect:[[SCBSession sharedSession] userName]];
    NSMutableArray *tableArray = [info selectAllUserinfo];
    if([tableArray count]>0)
    {
        UserInfo *userInfo = [tableArray objectAtIndex:0];
        info.space_id = userInfo.space_id;
        info.auto_url = userInfo.auto_url;
        info.f_id = userInfo.f_id;
        info.is_oneWiFi = userInfo.is_oneWiFi;
        info.is_autoUpload = userInfo.is_autoUpload;
    }
    else
    {
        info.auto_url = [NSString stringWithFormat:@"手机照片/来自于-%@",[AppDelegate deviceString]];
        info.space_id = [NSString formatNSStringForOjbect:[[SCBSession sharedSession] spaceID]];
        info.f_id = -1;
        info.is_autoUpload = NO;
        info.is_oneWiFi = YES;
    }
    [info insertUserinfo];
    
    UINavigationController *NavigationController = [[self.myTabBarController viewControllers] objectAtIndex:1];
    IPhotoViewController *uploadView = (IPhotoViewController *)[NavigationController.viewControllers objectAtIndex:0];
    if([uploadView isKindOfClass:[IPhotoViewController class]])
    {
        [uploadView clearTableData];
    }
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
//    //设置屏幕锁屏
//    [[UIApplication sharedApplication] setIdleTimerDisabled:NO];
    if(self.autoUpload.isGoOn || self.moveUpload.isStart)
    {
        [musicPlayer startPlay];
    }
    else
    {
        [musicPlayer stopPlay];
    }
    
//    [self.window.rootViewController dismissModalViewControllerAnimated:YES];
//    if ([[UIDevice currentDevice] isMultitaskingSupported]) {
//        [[BackgroundRunner shared] run];
//    }
}

- (void)applicationWillEnterForeground:(UIApplication *)application
{
//    //设置屏幕常亮
//    [[UIApplication sharedApplication] setIdleTimerDisabled:YES];
    [musicPlayer stopPlay];
//    [[BackgroundRunner shared] stop];
    
    if([YNFunctions isAutoUpload])
    {
        [self.autoUpload start];
    }
    if ([self isLogin]) {
        if ([YNFunctions isAlertMessage]) {
            SCBFileManager *fm=[[SCBFileManager alloc] init];
            fm.delegate=self;
            [fm requestOpenFamily:@""];
        }
    }
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

- (void)application:(UIApplication *)app didFailToRegisterForRemoteNotificationsWithError:(NSError *)err {
    //[self alertNotice:@"" withMSG:[NSString stringWithFormat:@"Error in registration. Error: %@", err] cancleButtonTitle:@"Ok" otherButtonTitle:@""];
    NSLog(@"Error in registration. Error: %@", err);
}
- (void)application:(UIApplication *)app didRegisterForRemoteNotificationsWithDeviceToken:(NSData *)deviceToken {
    // Required
    [APService registerDeviceToken:deviceToken];
    
    NSLog(@"devToken=%@",deviceToken);
    //[self alertNotice:@"" withMSG:[NSString stringWithFormat:@"devToken=%@",deviceToken] cancleButtonTitle:@"Ok" otherButtonTitle:@""];
}

-(void)application:(UIApplication *)application didReceiveLocalNotification:(UILocalNotification *)notification
{
    NSLog(@"didReceiveLocalNotification");
}

- (void)application:(UIApplication *)application didReceiveRemoteNotification:(NSDictionary *)userInfo {
//    if (self.hud) {
//        [self.hud removeFromSuperview];
//    }
//    self.hud=nil;
//    self.hud=[[MBProgressHUD alloc] initWithView:self.window];
//    [self.window addSubview:self.hud];
//    [self.hud show:NO];
//    self.hud.labelText=[userInfo description];
//    self.hud.mode=MBProgressHUDModeText;
//    self.hud.margin=10.f;
//    [self.hud show:YES];
//    [self.hud hide:YES afterDelay:10.0f];
//    UIAlertView *alert=[[UIAlertView alloc] initWithTitle:nil message:[userInfo objectForKey:@"alert"] delegate:self cancelButtonTitle:nil otherButtonTitles:nil, nil];
//    [alert show];
    
    // Required
    [APService handleRemoteNotification:userInfo];
    NSLog(@"userInfo:%@",userInfo);
    if ([UIApplication sharedApplication].applicationState!=UIApplicationStateActive) {
        MessagePushController *messagePush = [[MessagePushController alloc] init];
        messagePush.isPushMessage = YES;
        [self.window.rootViewController presentModalViewController:messagePush animated:YES];
        [messagePush release];
    }
}
-(void)addTabBarView
{
    UINavigationController *viewController1,*viewController2,*viewController3,*viewController4;
   
//    MyndsViewController *rootView1=[[[MyndsViewController alloc] init ]autorelease];
//    rootView1.f_id=@"1";
//    rootView1.myndsType=kMyndsTypeDefault;
    MainViewController *rootView1=[[[MainViewController alloc] init] autorelease];
    rootView1.title=@"我的空间";
    rootView1.tabBarItem.title=@"我的空间";
    [rootView1.tabBarItem setImage:[UIImage imageNamed:@"Bt_MySpaceDef.png"]];
    viewController1=[[[UINavigationController alloc] initWithRootViewController:rootView1] autorelease];
    
//    PhotoViewController * rootView2=[[[PhotoViewController alloc] init] autorelease];
    IPhotoViewController *rootView2 = [[[IPhotoViewController alloc] init] autorelease];
    rootView2.tabBarItem.title=@"家庭空间";
    rootView2.isPhoto = YES;
    [rootView2.tabBarItem setImage:[UIImage imageNamed:@"Bt_FamilyDef.png"]];
    [rootView2 setF_id:@"1"];
    viewController2=[[[UINavigationController alloc] initWithRootViewController:rootView2] autorelease];
    
//    UploadViewController * rootView3=[[[UploadViewController alloc] initWithNibName:@"UploadViewController" bundle:nil] autorelease];
    ChangeUploadViewController *rootView3 = [[[ChangeUploadViewController alloc] init] autorelease];
    //UIViewController * rootView3=[[[UIViewController alloc] init] autorelease];
    rootView3.tabBarItem.title=@"传输管理";
    [rootView3.tabBarItem setImage:[UIImage imageNamed:@"Bt_TransferDef.png"]];
    viewController3=[[[UINavigationController alloc] initWithRootViewController:rootView3] autorelease];
    
    SettingViewController * rootView4=[[[SettingViewController alloc] init] autorelease];
    //UIViewController * rootView4=[[[UIViewController alloc] init] autorelease];
    rootView4.title=@"个人中心";
    rootView4.tabBarItem.title=@"个人中心";
    [rootView4.tabBarItem setImage:[UIImage imageNamed:@"Bt_UsercentreDef.png"]];
    rootView4.rootViewController=self.myTabBarController;
    viewController4=[[[UINavigationController alloc] initWithRootViewController:rootView4] autorelease];
    
    [viewController1.navigationBar setBarStyle:UIBarStyleBlack];
    [viewController2.navigationBar setBarStyle:UIBarStyleBlack];
    [viewController3.navigationBar setBarStyle:UIBarStyleBlack];
    [viewController4.navigationBar setBarStyle:UIBarStyleBlack];
    self.myTabBarController.viewControllers=[NSArray arrayWithObjects:viewController1,viewController2,viewController3,viewController4, nil];
    self.myTabBarController.selectedIndex=0;
    [self.myTabBarController.moreNavigationController.navigationBar setBarStyle:UIBarStyleBlack];
}

-(void)myRoom
{
    [self.myTabBarController setSelectedIndex:0];
}

-(void)isHiddenTabbar:(BOOL)bl
{
    if (bl) {
        //隐藏
    }
    else
    {
        //显示
    }
}

#pragma mark UIAlertViewDelegate

-(void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if(buttonIndex == 1)
    {
        [YNFunctions setIsAutoUpload:YES];
        [self automicUpload];
    }
}

#pragma mark UICustomTabControllerDelegate ------------

- (void)custom_tabbar_view_by_delegate:(UIView*)custom_view
{
    
}

- (void)automicUpload
{
    [autoUpload start];
}

//删除下载进程
- (void)clearDown
{
    NSLog(@"停止图片加载");
    for (int i=0;i<downImageArray.count;i++){
        DownImage *downImage = [downImageArray objectAtIndex:i];
        [downImage cancelDownload];
    }
}
#pragma mark - SCBFileManagerDelegate
//打开家庭成员
-(void)getOpenFamily:(NSDictionary *)dictionary
{
    NSLog(@"dictionary:%@",dictionary);
    NSArray *array = [dictionary objectForKey:@"spaces"];
    if([array count] > 0)
    {
        NSMutableArray *marray=[NSMutableArray array];
        for (NSDictionary *dic in array) {
            NSString *str=[dic objectForKey:@"space_id"];
            if (str) {
                [marray addObject:str];
            }
        }
        [YNFunctions setAllFamily:marray];
        
        if ([YNFunctions isAlertMessage]) {
            [APService
             registerForRemoteNotificationTypes:(UIRemoteNotificationTypeBadge |
                                                 UIRemoteNotificationTypeSound |
                                                 UIRemoteNotificationTypeAlert)];
            NSString *alias=[NSString stringWithFormat:@"%@",[[SCBSession sharedSession] spaceID]];
            NSSet *tags=[NSSet setWithArray:[YNFunctions selectFamily]];
            
            [APService setTags:tags alias:alias];
            NSLog(@"设置标签和别名成功,\n别名：%@\n标签：%@",alias,tags);
        }
    }
}
@end
