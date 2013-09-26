//
//  SettingViewController.m
//  ndspro
//
//  Created by fengyongning on 13-9-26.
//  Copyright (c) 2013年 fengyongning. All rights reserved.
//

#import "SettingViewController.h"
#import "AppDelegate.h"
typedef enum{
    kActionSheetTypeExit,
    kActionSheetTypeClear,
    kActionSheetTypeWiFi,
    kActionSheetTypeAuto,
    kActionSheetTypeHideFeature,
}kActionSheetType;
@interface SettingViewController ()

@end

@implementation SettingViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
}
- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
- (IBAction)exitAccount:(id)sender
{
    //    UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@""
    //                                                        message:@"确定要退出登录"
    //                                                       delegate:self
    //                                              cancelButtonTitle:@"取消"
    //                                              otherButtonTitles:@"退出", nil];
    //    [alertView show];
    //    [alertView setTag:kAlertTypeExit];
    //    [alertView release];
    UIActionSheet *actionSheet=[[UIActionSheet alloc]  initWithTitle:@"确定要退出登录" delegate:self cancelButtonTitle:@"取消" destructiveButtonTitle:@"退出" otherButtonTitles: nil];
    [actionSheet setTag:kActionSheetTypeExit];
    [actionSheet setActionSheetStyle:UIActionSheetStyleBlackOpaque];
    [actionSheet showInView:[[UIApplication sharedApplication] keyWindow]];
}
#pragma mark - UIActionSheetDelegate
- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex
{
    switch ([actionSheet tag]) {
        case kActionSheetTypeExit:
            if (buttonIndex == 0) {
                //scBox.UserLogout(callBackLogoutFunc,self);

                
                [[NSUserDefaults standardUserDefaults] setObject:nil forKey:@"usr_name"];
                [[NSUserDefaults standardUserDefaults] setObject:nil  forKey:@"usr_pwd"];
                [[NSUserDefaults standardUserDefaults] setObject:nil forKey:@"switch_flag"];
                [[NSUserDefaults standardUserDefaults] setObject:nil forKey:@"isAutoUpload"];
                [[NSUserDefaults standardUserDefaults] synchronize];
                
                AppDelegate *appDelegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
                [appDelegate finishLogout];
            }
            break;
        case kActionSheetTypeClear:
            break;
        case kActionSheetTypeWiFi:
            break;
        case kActionSheetTypeAuto:
            break;
        case kActionSheetTypeHideFeature:
            break;
        default:
            break;
    }
    
}

@end
