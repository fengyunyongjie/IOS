//
//  LoginViewController.h
//  ndspro
//
//  Created by fengyongning on 13-9-26.
//  Copyright (c) 2013年 fengyongning. All rights reserved.
//

#import <UIKit/UIKit.h>
@interface LoginViewController : UIViewController<UITextFieldDelegate>
@property (strong,nonatomic)IBOutlet UITextField *userNameTextField;
@property (strong,nonatomic)IBOutlet UITextField *passwordTextField;
- (IBAction)login:(id)sender;
- (IBAction)endEdit:(id)sender;
@end
