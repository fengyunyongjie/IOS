//
//  RegistViewController.h
//  NetDisk
//
//  Created by fengyongning on 13-5-20.
//
//

#import <UIKit/UIKit.h>

@interface RegistViewController : UIViewController<UITextFieldDelegate>
@property (strong,nonatomic) IBOutlet UITextField *m_userNameTextField;
@property (strong,nonatomic) IBOutlet UITextField *m_passwordTextField;
@property (strong,nonatomic) IBOutlet UITextField *m_passwordAgainTextField;
@property (assign,nonatomic) id delegate;
- (IBAction) regitst:(id)sender;
- (IBAction) comeBack:(id)sender;
- (BOOL)registAssert;
- (IBAction)endEdit:(id)sender;
- (IBAction)showPasswd:(id)sender;
- (IBAction)lookXY:(id)sender;
- (IBAction)goBack:(id)sender;
@end
