//
//  NDRegistViewController.h
//  NetDisk
//
//  Created by jiangwei on 13-1-6.
//  Copyright (c) 2013年 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ATMHud.h"
#import "clientlib/SevenCBoxClient.h"
@protocol NDRegistViewControllerDelegate <NSObject>

@optional
- (void)popLoginView;
@end

@interface NDRegistViewController : UIViewController<UIAlertViewDelegate>
{
    id<NDRegistViewControllerDelegate> delegate;
    UITextField *m_userNameTextField;
    UITextField *m_passwordTextField;
    UITextField *m_passwordAgainTextField;
    ATMHud *m_hud;
}
@property (nonatomic,assign) id <NDRegistViewControllerDelegate> delegate;
@property (nonatomic,retain) IBOutlet UITextField *m_userNameTextField;
@property (nonatomic,retain) IBOutlet UITextField *m_passwordTextField;
@property (nonatomic,retain) IBOutlet UITextField *m_passwordAgainTextField;
- (IBAction)regist:(id)sender;
- (IBAction)comeBack:(id)sender;
- (BOOL)registAssert;
@end
