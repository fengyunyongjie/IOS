//
//  LoginViewController.m
//  ndspro
//
//  Created by fengyongning on 13-9-26.
//  Copyright (c) 2013年 fengyongning. All rights reserved.
//

#import "LoginViewController.h"
#import "MBProgressHUD.h"
#import "SCBAccountManager.h"
#import "AppDelegate.h"
#import "APService.h"
#import "SCBSession.h"

@interface LoginViewController ()<SCBAccountManagerDelegate>
@property(strong,nonatomic) MBProgressHUD *hud;
@end

@implementation LoginViewController

//<ios 6.0
- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation
{
    return NO;
}

//>ios 6.0
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
    // Do any additional setup after loading the view from its nib.
    if ([UIScreen mainScreen].bounds.size.height<=480) {
        self.bgview.frame=CGRectMake(0, 0, 320, 480);
        self.bgview.image=[UIImage imageNamed:@"Bk_Login.png"];
    }
    self.userNameTextField.delegate=self;
    self.passwordTextField.delegate=self;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
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

#pragma mark - SCBAccountManagerDelegate Methods
-(void)networkError
{
    if (self.hud) {
        [self.hud removeFromSuperview];
    }
    self.hud=nil;
    self.hud=[[MBProgressHUD alloc] initWithView:self.view];
    [self.view addSubview:self.hud];
    
    [self.hud show:NO];
    self.hud.labelText=@"链接失败，请检查网络";
    self.hud.mode=MBProgressHUDModeText;
    self.hud.margin=10.f;
    [self.hud show:YES];
    [self.hud hide:YES afterDelay:1.0f];
//    [self doneLoadingTableViewData];
}
-(void)loginSucceed:(id)manager
{
    NSString *alias=[NSString stringWithFormat:@"%@",[[SCBSession sharedSession] entjpush]];
    [APService setTags:nil alias:alias];
    NSLog(@"设置别名成功：%@",alias);
    
    [[NSUserDefaults standardUserDefaults] setObject:_userNameTextField.text forKey:@"usr_name"];
    [[NSUserDefaults standardUserDefaults] setObject:_passwordTextField.text forKey:@"usr_pwd"];
    [[NSUserDefaults standardUserDefaults] synchronize];
//    }
//    [self dismissViewControllerAnimated:YES completion:^(void){}];
    [self.hud show:NO];
    if (self.hud) {
        [self.hud removeFromSuperview];
    }
    self.hud=nil;
    self.hud=[[MBProgressHUD alloc] initWithView:self.view];
    [self.view addSubview:self.hud];
    [self.hud show:NO];
    self.hud.labelText=@"登录成功！";
    self.hud.mode=MBProgressHUDModeText;
    self.hud.margin=10.f;
    [self.hud show:YES];
    [self.hud hide:YES afterDelay:1.0f];
    AppDelegate *app_delegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
    [app_delegate finishLogin];
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
    self.hud.labelText=@"用户名或密码错误";
    self.hud.mode=MBProgressHUDModeText;
    self.hud.margin=10.f;
    [self.hud show:YES];
    [self.hud hide:YES afterDelay:1.0f];
}
#pragma mark - UITextFieldDelegate
- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string;
{
    if (textField==self.userNameTextField) {
        //NSLog(@"UserName");
        NSMutableString *text = [textField.text mutableCopy];
        [text replaceCharactersInRange:range withString:string];
        return [text length] <= 32;
        //        if (range.length>=32) {
        //            return NO;
        //        }
    }else if(textField==self.passwordTextField)
    {
        //NSLog(@"passwd");
        NSMutableString *text = [textField.text mutableCopy];
        [text replaceCharactersInRange:range withString:string];
        return [text length] <= 16;
        //        if (range.length>=16) {
        //            return NO;
        //        }
    }
    return YES;
}
- (BOOL)textFieldShouldReturn:(UITextField*)textField {
    BOOL retValue = NO;
    // see if we're on the username or password fields
    if (textField == self.userNameTextField)//当是 “帐号”输入框时
    {
//        if ([textField.text length]  == 11)//输入的号码完整时
//        {
        [self.passwordTextField becomeFirstResponder];// “会员密码”输入框 作为 键盘的第一 响应者，光标 进入此输入框中
        retValue = NO;
//        }
    }
    else
    {
//        [self.userPass resignFirstResponder];//如果 现在 是 第二个输入框，那么 键盘 隐藏
        [textField resignFirstResponder];
    }
    return retValue;
    //返回值为NO，即 忽略 按下此键；若返回为YES则 认为 用户按下了此键，并去调用TextFieldDoneEditint方法，在此方法中，你可以继续 写下 你想做的事
}
@end
