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

@interface AppDelegate : UIResponder <UIApplicationDelegate,UITabBarControllerDelegate,WXApiDelegate>
{
    NSString *user_name;
}

@property (strong, nonatomic) UIWindow *window;
@property (strong, nonatomic) MYTabBarController *myTabBarController;
@property (retain, nonatomic) NSString *user_name;
-(void)setLogin;
-(void) sendImageContent;
@end
