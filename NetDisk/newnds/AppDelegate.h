//
//  AppDelegate.h
//  newnds
//
//  Created by fengyongning on 13-4-26.
//
//

#import <UIKit/UIKit.h>
#import "WXApi.h"
#import "MYTabBarController.h"
#import "FirstLoadViewController.h"
#import "AutomaticUpload.h"
#import "UploadAll.h"
#import "HelpViewController.h"
#import "MoveUpload.h"
#import "Reachability.h"
#import "NewAutoUpload.h"
#import "MusicPlayerViewController.h"
#import "BootViewController.h"
#import "QBImageFileViewController.h"
#import "MBProgressHUD.h"

//新浪微博微博
#define kAppKey         @"706445160"
#define kRedirectURI    @"http://www.7cbox.cn"
#define TabBarHeight 60
#define hilighted_color [UIColor colorWithRed:255.0/255.0 green:180.0/255.0 blue:94.0/255.0 alpha:1.0]
@interface AppDelegate : UIResponder <UIApplicationDelegate,UICustomTabControllerDelegate,WXApiDelegate,FirstLoadDelegate,UIAlertViewDelegate,UIActionSheetDelegate,QBImageFileViewDelegate>
{
    NSString *user_name;
    UploadAll *upload_all;
    FirstLoadViewController *firstLoadView;
    AutomaticUpload *maticUpload;
    MoveUpload *moveUpload;
    BOOL isAutomicUpload;
    NSMutableArray *title_string;
    Reachability *hostReach;
    NewAutoUpload *autoUpload;
    MusicPlayerViewController *musicPlayer;
    BOOL isShareUpload;
    NSMutableArray *downImageArray;
    BOOL isHomeLoad;
    NSString *device_name;
    NSString *f_ID;
    NSString *space_ID;
}
@property (strong,nonatomic) MBProgressHUD *hud;
@property (strong, nonatomic) UIWindow *window;
@property (strong, nonatomic) MYTabBarController *myTabBarController;
@property (strong, nonatomic) UIViewController *loginVC;
@property (retain, nonatomic) NSString *user_name;
@property (assign, nonatomic) BOOL isUnUpload;
@property (nonatomic,retain) UploadAll *upload_all;
@property (nonatomic,retain) MoveUpload *moveUpload;
@property (nonatomic,retain) AutomaticUpload *maticUpload;
@property (nonatomic,assign) BOOL isAutomicUpload;
@property (nonatomic,retain) NSMutableArray *title_string;
@property (strong,nonatomic) HelpViewController *helpController;
@property (nonatomic,retain) NewAutoUpload *autoUpload;
@property (nonatomic,retain) MusicPlayerViewController *musicPlayer;
@property (nonatomic,assign) BOOL isShareUpload;
@property (nonatomic,retain) NSMutableArray *downImageArray;
@property (nonatomic,assign) BOOL isHomeLoad;
@property (nonatomic,retain) NSString *imagePath;

-(void)finishLogout;
-(void)finishLogin;
-(void)setLogin;
//分享图片
- (void) sendImageContentIsFiends:(BOOL)bl title:(NSString *)title text:(NSString *)text path:(NSString *)path imagePath:(NSString *)imagePath;
//分享文字
- (void) sendImageContentIsFiends:(BOOL)bl text:(NSString *)text;
//微博授权
- (void)ssoButtonPressed;
+ (NSString*)deviceString;
//删除下载进程
- (void)clearDown;

@end
