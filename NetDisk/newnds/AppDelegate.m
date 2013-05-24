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
    [self.myTabBarController setNeed_to_custom:NO];
    [self.myTabBarController setTab_bar_bg:[UIImage imageNamed:@"tab_bg.png"]];
    [self.myTabBarController setNormal_image:[NSArray arrayWithObjects:@"tab_btn_myroom@2x.png",@"tab_btn_favorite@2x.png",@"tab_btn_photo@2x.png",@"tab_btn_upload@2x.png",@"tab_btn_setting@2x.png", nil]];
    [self.myTabBarController setSelect_image:[NSArray arrayWithObjects:@"tab_btn_myroom_h@2x.png",@"tab_btn_favorite_h@2x.png",@"tab_btn_photo_h@2x.png",@"tab_btn_upload_h@2x.png",@"tab_btn_setting_h@2x.png",nil]];
    [self.myTabBarController setShow_style:UItabbarControllerShowStyleIconAndText];
    [self.myTabBarController setShow_way:UItabbarControllerHorizontal Rect:CGRectMake(0, 431, 320, 49)];
    [self.myTabBarController setFont:[UIFont boldSystemFontOfSize:10.0]];
    [self.myTabBarController setFont_color:[UIColor colorWithRed:153.0/255.0 green:153.0/255.0 blue:153.0/255.0 alpha:1.0]];
    [self.myTabBarController setHilighted_color:[UIColor colorWithRed:153.0/255.0 green:153.0/255.0 blue:153.0/255.0 alpha:1.0]];
    
    //    UINavigationController *root=[[UINavigationController alloc] initWithRootViewController:self.myTabBarController];
        self.window.rootViewController=self.myTabBarController;
    //！！！程序启动时不需要每次都进入登录窗口，只有注销和第一次启动时才进入登录窗口，所以我所这儿注释掉，在MyTabBarController判断！是否显示登录页面
    
    //LoginViewController *lv=[[[LoginViewController alloc] initWithNibName:@"LoginViewController" bundle:nil] autorelease];
    //    [self.window.rootViewController presentViewController:lv animated:YES completion:^(void){}];
    //self.window.rootViewController = lv;
    //程序启动时，在代码中向微信终端注册你的id
    [WXApi registerApp:@"wxdcc0186c9f173352"];
    //启动时注册微博
    [WeiboSDK enableDebugMode:YES];
    [WeiboSDK registerApp:kAppKey];
    
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
        NSLog(@"strMSg：%@",strMsg);
    }
}

//获取图片路径
- (NSString*)get_image_save_file_path:(NSString*)image_path
{
    NSArray *path_array = NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES);
    NSString *documentDir = [path_array objectAtIndex:0];
    NSArray *array=[image_path componentsSeparatedByString:@"/"];
    NSString *path=[NSString stringWithFormat:@"%@/%@",documentDir,[array lastObject]];
    return path;
}

- (void) sendImageContentIsFiends:(BOOL)bl path:(NSString *)path
{
    WXMediaMessage *message = [WXMediaMessage message];
    NSString *filePath = [self get_image_save_file_path:path];
    [message setThumbImage:[UIImage imageWithContentsOfFile:filePath]];
    WXImageObject *ext = [WXImageObject object];
    ext.imageData = [NSData dataWithContentsOfFile:filePath];
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

- (BOOL)application:(UIApplication *)application handleOpenURL:(NSURL *)url
{
    return  [WXApi handleOpenURL:url delegate:self];
}
- (BOOL)application:(UIApplication *)application openURL:(NSURL *)url sourceApplication:(NSString *)sourceApplication annotation:(id)annotation
{
    return  [WXApi handleOpenURL:url delegate:self] || [WeiboSDK handleOpenURL:url delegate:self];;
}

-(void)setLogin
{
    self.window.rootViewController=self.myTabBarController;
    self.myTabBarController.selectedIndex = 2;
    self.myTabBarController.selectedIndex = 1;
    self.myTabBarController.selectedIndex = 0;
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

#pragma mark 新浪微博模块

//微博授权
- (void)ssoButtonPressed
{
    WBAuthorizeRequest *request = [WBAuthorizeRequest request];
    request.redirectURI = @"http://";
    request.scope = @"email,direct_messages_write";
    request.userInfo = @{@"SSO_From": @"newnds",
                         @"Other_Info_1": [NSNumber numberWithInt:123],
                         @"Other_Info_2": @[@"obj1", @"obj2"],
                         @"Other_Info_3": @{@"key1": @"obj1", @"key2": @"obj2"}};
    [WeiboSDK sendRequest:request];
}

- (void)didReceiveWeiboRequest:(WBBaseRequest *)request
{
    if ([request isKindOfClass:WBProvideMessageForWeiboRequest.class])
    {
//        ProvideMessageForWeiboViewController *controller = [[[ProvideMessageForWeiboViewController alloc] init] autorelease];
//        [self.viewController presentModalViewController:controller animated:YES];
        NSLog(@"ProvideMessageForWeiboViewController");
    }
}

//授权成功后的回调
- (void)didReceiveWeiboResponse:(WBBaseResponse *)response
{
    if ([response isKindOfClass:WBSendMessageToWeiboResponse.class])
    {
        NSString *title = @"发送结果";
        NSString *message = [NSString stringWithFormat:@"响应状态: %d\n响应UserInfo数据: %@\n原请求UserInfo数据: %@",
                             response.statusCode, response.userInfo, response.requestUserInfo];
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:title
                                                        message:message
                                                       delegate:nil
                                              cancelButtonTitle:@"确定"
                                              otherButtonTitles:nil];
        [alert show];
        [alert release];
    }
    else if ([response isKindOfClass:WBAuthorizeResponse.class])
    {
        NSString *title = @"认证结果";
        NSString *message = [NSString stringWithFormat:@"响应状态: %d\nresponse.userId: %@\nresponse.accessToken: %@\n响应UserInfo数据: %@\n原请求UserInfo数据: %@",
                             response.statusCode, [(WBAuthorizeResponse *)response userID], [(WBAuthorizeResponse *)response accessToken], response.userInfo, response.requestUserInfo];
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:title
                                                        message:message
                                                       delegate:nil
                                              cancelButtonTitle:@"确定"
                                              otherButtonTitles:nil];
        [alert show];
        [alert release];
    }
}

//微博分享
- (void)shareButtonPressed
{
    WBSendMessageToWeiboRequest *request = [WBSendMessageToWeiboRequest requestWithMessage:[self messageToShare:1]];
    request.userInfo = @{@"ShareMessageFrom": @"SendMessageToWeiboViewController",
                         @"Other_Info_1": [NSNumber numberWithInt:123],
                         @"Other_Info_2": @[@"obj1", @"obj2"],
                         @"Other_Info_3": @{@"key1": @"obj1", @"key2": @"obj2"}};
    //    request.shouldOpenWeiboAppInstallPageIfNotInstalled = NO;
    
    [WeiboSDK sendRequest:request];
}

//分享信息
- (WBMessageObject *)messageToShare:(int)type //type 0是text，1是image，2是多媒体
{
    WBMessageObject *message = [WBMessageObject message];
    
    if (type == 1)
    {
        message.text = @"测试通过WeiboSDK发送文字到微博!";
    }
    
    if (type == 2)
    {
        WBImageObject *image = [WBImageObject object];
        image.imageData = [NSData dataWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"image_1" ofType:@"jpg"]];
        message.imageObject = image;
    }
    
    if (type == 3)
    {
        WBWebpageObject *webpage = [WBWebpageObject object];
        webpage.objectID = @"identifier1";
        webpage.title = @"分享网页标题";
        webpage.description = [NSString stringWithFormat:@"分享网页内容简介-%.0f", [[NSDate date] timeIntervalSince1970]];
        webpage.thumbnailData = [NSData dataWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"image_2" ofType:@"jpg"]];
        webpage.webpageUrl = @"http://sina.cn?a=1";
        message.mediaObject = webpage;
    }
    return message;
}

@end
