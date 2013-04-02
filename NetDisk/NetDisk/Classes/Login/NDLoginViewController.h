//
//  NDLoginViewController.h
//  NetDisk
//
//  Created by jiangwei on 12-11-12.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Commonfile.h"
#import <QuartzCore/QuartzCore.h>
#import "clientlib/SevenCBoxClient.h"
#import "NDRegistViewController.h"
#import "ATMHud.h"
#import "SevenCBoxConfig.h"

#import "Function.h"
@protocol NDLoginViewControllerDelegate <NSObject>

@optional
- (void)getMainData;
@end

@interface NDLoginViewController : UIViewController<NDRegistViewControllerDelegate>
{
    id <NDLoginViewControllerDelegate> delegate;
    UITextField *m_userNameTextField;
    UITextField *m_passwordTextField;
    
    UIImageView *m_imageView;
    UIView *m_view;
    ATMHud *m_hud;
    UINavigationController *m_nav;
    BOOL isRegistComeBack;//YES 通过注册界面成功后返回到登陆页。
    UIButton *m_commitButton;
}
@property (nonatomic,assign) id <NDLoginViewControllerDelegate> delegate;
@property (nonatomic,retain) IBOutlet UITextField *m_userNameTextField;
@property (nonatomic,retain) IBOutlet UITextField *m_passwordTextField;

@property (nonatomic,retain) IBOutlet UIImageView *m_imageView;
@property (nonatomic,retain) IBOutlet UIView *m_view;
@property (nonatomic,retain) IBOutlet UIButton *m_commitButton;

- (IBAction)login:(id)sender;
- (IBAction)userRegister:(id)sender;
- (void)setNav:(UINavigationController *)theNav;
@end
