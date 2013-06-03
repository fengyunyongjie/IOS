//
//  RegistViewController.m
//  NetDisk
//
//  Created by fengyongning on 13-5-20.
//
//

#import "RegistViewController.h"
#import "MBProgressHUD.h"
#import "SCBAccountManager.h"

@interface RegistViewController ()
@property (strong ,nonatomic) MBProgressHUD *m_hud;
@end

@implementation RegistViewController

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
    self.m_hud=[[MBProgressHUD alloc] initWithView:self.view];
    [self.view addSubview:self.m_hud];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(keyboardWillShow:)
                                                 name:UIKeyboardWillShowNotification
                                               object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(keyboardWillHide:)
                                                 name:UIKeyboardWillHideNotification
                                               object:nil];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
-(void)registSucceed
{
     [self.m_hud removeFromSuperview];
    [self dismissViewControllerAnimated:NO completion:^(void){
        if (self.delegate && [self.delegate respondsToSelector:@selector(dismissViewControllerAnimated:completion:)]) {
            [[NSUserDefaults standardUserDefaults] setObject:self.m_userNameTextField.text forKey:@"usr_name"];
            [[NSUserDefaults standardUserDefaults] setObject:self.m_passwordAgainTextField.text forKey:@"usr_pwd"];
            [[NSUserDefaults standardUserDefaults] synchronize];
            if (self.delegate&&[self.delegate respondsToSelector:@selector(resetData)]) {
                [self.delegate resetData];
            }
            [self.delegate dismissViewControllerAnimated:NO completion:nil];
        }
    }];
}
-(void)registUnsucceed:(id)manager
{
    [self.m_hud show:NO];
    self.m_hud.labelText=@"失败(帐号被使用或格式不正确)";
    self.m_hud.mode=MBProgressHUDModeText;
    self.m_hud.margin=10.f;
    [self.m_hud show:YES];
    [self.m_hud hide:YES afterDelay:0.5f];
}
- (IBAction) regitst:(id)sender
{
    if ([self registAssert]) {
        
        [[SCBAccountManager sharedManager] UserRegisterWithName:self.m_userNameTextField.text Password:self.m_passwordTextField.text];
        [[SCBAccountManager sharedManager] setDelegate:self];
        
        [self.m_hud removeFromSuperview];
        self.m_hud=[[MBProgressHUD alloc] initWithView:self.view];
        [self.view addSubview:self.m_hud];
        self.m_hud.labelText=@"正在注册...";
        self.m_hud.mode=MBProgressHUDModeIndeterminate;
        [self.m_hud show:YES];
    }
}
- (IBAction) comeBack:(id)sender
{
    [self dismissModalViewControllerAnimated:YES];
}
- (BOOL)registAssert
{
    BOOL rt = YES;
    NSString *loginName = self.m_userNameTextField.text;
    if (loginName==nil||[loginName isEqualToString:@""]) {
        self.m_hud.labelText=@"请输入合法的用户名";
        rt=NO;
    }
    else
    {
        NSRange rang  = [loginName rangeOfString:@"@"];
        if (rang.location==NSNotFound) {
            self.m_hud.labelText=@"请输入合法的用户名";
            rt=NO;
        }
        else
        {
            NSString *password = self.m_passwordTextField.text;
            NSString *passwordA = self.m_passwordAgainTextField.text;
            if ([password isEqualToString:@""]) {
                self.m_hud.labelText=@"密码不得为空";
                rt=NO;
            }
            else if ([password length]<6||[password length]>16) {
                self.m_hud.labelText=@"输入密码在6-16位";
                rt=NO;
            }else if(![password isEqualToString:passwordA])
            {
                self.m_hud.labelText=@"两次输入的密码不一致";
                rt=NO;
            }
        }
    }
    [self.m_hud show:NO];
    self.m_hud.mode=MBProgressHUDModeText;
    self.m_hud.margin=10.f;
    [self.m_hud show:YES];
    [self.m_hud hide:YES afterDelay:0.5f];
    return rt;
}
- (IBAction)endEdit:(id)sender
{
    [self.m_userNameTextField endEditing:YES];
    [self.m_passwordAgainTextField endEditing:YES];
    [self.m_passwordTextField endEditing:YES];
}
#pragma mark - Responding to keyboard events

- (void)keyboardWillShow:(NSNotification *)notification {
    
    /*
     Reduce the size of the text view so that it's not obscured by the keyboard.
     Animate the resize so that it's in sync with the appearance of the keyboard.
     */
    
    [UIView beginAnimations:@"MoveUp" context:nil];
    [UIView setAnimationDuration:0.2f];
    [UIView setAnimationCurve:UIViewAnimationCurveEaseInOut];
    CGRect r=self.view.frame;
    r.origin.y=-100;
    [self.view setFrame:r];
    [UIView commitAnimations];
}

- (void)keyboardWillHide:(NSNotification *)notification {
    [UIView beginAnimations:@"MoveUp" context:nil];
    [UIView setAnimationDuration:0.2f];
    [UIView setAnimationCurve:UIViewAnimationCurveEaseInOut];
    CGRect r=self.view.frame;
    r.origin.y=20;
    [self.view setFrame:r];
    [UIView commitAnimations];
}

@end
