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
//新浪微博微博
#define kAppKey         @"706445160"
#define kRedirectURI    @"http://www.7cbox.cn"
#define TabBarHeight 60
#define hilighted_color [UIColor colorWithRed:255.0/255.0 green:180.0/255.0 blue:94.0/255.0 alpha:1.0]

@interface AppDelegate : UIResponder <UIApplicationDelegate,UITabBarControllerDelegate,WXApiDelegate>
{
    NSString *user_name;
}

@property (strong, nonatomic) UIWindow *window;
@property (strong, nonatomic) MYTabBarController *myTabBarController;
@property (retain, nonatomic) NSString *user_name;
@property (assign, nonatomic) BOOL isUnUpload;

-(void)setLogin;
-(void) sendImageContentIsFiends:(BOOL)bl path:(NSString *)path;
//微博授权
- (void)ssoButtonPressed;
+ (NSString*)deviceString;
@end
