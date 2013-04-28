//
//  LoginViewController.h
//  NetDisk
//
//  Created by fengyongning on 13-4-27.
//
//

#import <UIKit/UIKit.h>

@interface LoginViewController : UIViewController
@property (strong,nonatomic)IBOutlet UITextField *userNameTextField;
@property (strong,nonatomic)IBOutlet UITextField *passwordTextField;
- (IBAction)login:(id)sender;
- (IBAction)userRegister:(id)sender;
@end
