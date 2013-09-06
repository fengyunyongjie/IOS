//
//  LoginViewController.m
//  NetDisk
//
//  Created by fengyongning on 13-4-27.
//
//

#import "LoginViewController.h"
#import "AppDelegate.h"
#import "SCBAccountManager.h"
#import "MBProgressHUD.h"
#import "RegistViewController.h"
#import "APService.h"
#import "SCBSession.h"


@interface LoginViewController ()
@property(strong,nonatomic) UIAlertView *av;
@property(strong,nonatomic) MBProgressHUD *hud;
@end

@implementation LoginViewController

- (BOOL)shouldAutorotate{
    return NO;
}

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
    self.hud=[[MBProgressHUD alloc] initWithView:self.view];
    [self.view addSubview:self.hud];
    self.userNameTextField.delegate=self;
    self.passwordTextField.delegate=self;
    // Do any additional setup after loading the view from its nib.
    
    // observe keyboard hide and show notifications to resize the text view appropriately
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(keyboardWillShow:)
                                                 name:UIKeyboardWillShowNotification
                                               object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(keyboardWillHide:)
                                                 name:UIKeyboardWillHideNotification
                                               object:nil];
    //self.passwordTextField.tag=-1;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
- (IBAction)forgetPswd:(id)sender
{
    [[UIApplication sharedApplication] openURL:[NSURL URLWithString:@"http://www.7cbox.cn"]];
}
- (IBAction)userRegister:(id)sender
{
    RegistViewController *regist=[[[RegistViewController alloc] initWithNibName:@"RegistViewController" bundle:nil] autorelease];
    regist.delegate=self;
    [self presentViewController:regist animated:YES completion:nil];
}
- (BOOL)registAssert
{
    if (self.hud) {
        [self.hud removeFromSuperview];
    }
    self.hud=nil;
    self.hud=[[MBProgressHUD alloc] initWithView:self.view];
    [self.view addSubview:self.hud];
    
    BOOL rt = YES;
    NSString *loginName = self.userNameTextField.text;
    if (loginName==nil||[loginName isEqualToString:@""]) {
        self.hud.labelText=@"请输入合法的用户名";
        rt=NO;
    }
    else
    {
        NSRange rang  = [loginName rangeOfString:@"@"];
        if (rang.location==NSNotFound) {
            self.hud.labelText=@"请输入合法的用户名";
            //rt=NO;
        }
        else
        {
            NSString *password = self.passwordTextField.text;
            if ([password isEqualToString:@""]) {
                self.hud.labelText=@"密码不得为空";
                rt=NO;
            }
            else if ([password length]<6||[password length]>16) {
                self.hud.labelText=@"输入密码在6-16位";
                rt=NO;
            }
        }
    }
    [self.hud show:NO];
    self.hud.mode=MBProgressHUDModeText;
    self.hud.margin=10.f;
    [self.hud show:YES];
    [self.hud hide:YES afterDelay:1.0f];
    return rt;
}
- (IBAction)login:(id)sender
{
    [self.userNameTextField endEditing:YES];
    [self.passwordTextField endEditing:YES];
    if ([self registAssert]) {
        //把用户信息存储到数据库
        NSString *user_name = _userNameTextField.text;
        NSString *user_passwor = _passwordTextField.text;
        NSLog(@"user_name;%@,user_password:%@",user_name,user_passwor);    
        [[SCBAccountManager sharedManager] setDelegate:self];
        [[SCBAccountManager sharedManager] UserLoginWithName:self.userNameTextField.text Password:self.passwordTextField.text];
        if (self.hud) {
            [self.hud removeFromSuperview];
        }
        self.hud=nil;
        self.hud=[[MBProgressHUD alloc] initWithView:self.view];
        [self.view addSubview:self.hud];
        self.hud.labelText=@"正在登录...";
        self.hud.mode=MBProgressHUDModeIndeterminate;
        [self.hud show:YES];
    }
}
- (IBAction)endEdit:(id)sender
{
    [self.userNameTextField endEditing:YES];
    [self.passwordTextField endEditing:YES];
}
#pragma mark - UIAlertViewDelegate Methods
- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if (buttonIndex == 0) {
    }
}
#pragma mark - SCBAccountManagerDelegate Methods
-(void)loginSucceed:(id)manager
{
    NSString *alias=[NSString stringWithFormat:@"%@",[[SCBSession sharedSession] spaceID]];
    [APService setTags:nil alias:alias];
    NSLog(@"设置别名成功：%@",alias);
    AppDelegate *app_delegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
    [app_delegate setLogin];
    [[NSUserDefaults standardUserDefaults] setObject:_userNameTextField.text forKey:@"usr_name"];
    [[NSUserDefaults standardUserDefaults] setObject:_passwordTextField.text forKey:@"usr_pwd"];
    [[NSUserDefaults standardUserDefaults] synchronize];
    if (self.delegate&&[self.delegate respondsToSelector:@selector(resetData)]) {
        [self.delegate resetData];
    }
    [self dismissViewControllerAnimated:YES completion:^(void){}];
    [self.hud show:NO];
}
-(void)resetData
{
    if (self.delegate&&[self.delegate respondsToSelector:@selector(resetData)]) {
        [self.delegate resetData];
    }
//    AppDelegate *delegate=(AppDelegate *)[[UIApplication sharedApplication] delegate];
//    if ([delegate respondsToSelector:@selector(addTabBarView)])
//    {
//        [delegate addTabBarView];
//    }
}
-(void)loginUnsucceed:(id)manager
{
    if (self.hud) {
        [self.hud removeFromSuperview];
    }
    self.hud=nil;
    self.hud=[[MBProgressHUD alloc] initWithView:self.view];
    [self.view addSubview:self.hud];
    [self.hud show:NO];
    self.hud.labelText=@"登录失败！";
    self.hud.mode=MBProgressHUDModeText;
    self.hud.margin=10.f;
    [self.hud show:YES];
    [self.hud hide:YES afterDelay:1.0f];
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
#pragma mark - UITextFieldDelegate
- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string;
{
    if (textField==self.userNameTextField) {
        NSLog(@"UserName");
        NSMutableString *text = [[textField.text mutableCopy] autorelease];
        [text replaceCharactersInRange:range withString:string];
        return [text length] <= 32;
//        if (range.length>=32) {
//            return NO;
//        }
    }else if(textField==self.passwordTextField)
    {
        NSLog(@"passwd");
        NSMutableString *text = [[textField.text mutableCopy] autorelease];
        [text replaceCharactersInRange:range withString:string];
        return [text length] <= 16;
//        if (range.length>=16) {
//            return NO;
//        }
    }
    return YES;
}
@end
