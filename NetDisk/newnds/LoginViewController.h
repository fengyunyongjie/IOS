//
//  LoginViewController.h
//  NetDisk
//
//  Created by fengyongning on 13-4-27.
//
//

#import <UIKit/UIKit.h>

@interface LoginViewController : UIViewController<UITextFieldDelegate>
@property (strong,nonatomic)IBOutlet UITextField *userNameTextField;
@property (strong,nonatomic)IBOutlet UITextField *passwordTextField;
@property (assign,nonatomic)id delegate;
- (IBAction)login:(id)sender;
- (IBAction)userRegister:(id)sender;
- (IBAction)endEdit:(id)sender;
- (IBAction)forgetPswd:(id)sender;
- (IBAction)goBack:(id)sender;
@end
