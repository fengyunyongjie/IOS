//
//  NDRegistViewController.m
//  NetDisk
//
//  Created by jiangwei on 13-1-6.
//  Copyright (c) 2013年 __MyCompanyName__. All rights reserved.
//

#import "NDRegistViewController.h"
void callBackRegisterFunc(Value &jsonValue,void *s_pv);

@implementation NDRegistViewController
@synthesize delegate;
@synthesize m_passwordTextField,m_userNameTextField,m_passwordAgainTextField;
- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}
- (void)dealloc
{
    [m_passwordTextField release];
    [m_userNameTextField release];
    [m_passwordAgainTextField release];
    [super dealloc];
}
- (void)didReceiveMemoryWarning
{
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
    
    // Release any cached data, images, etc that aren't in use.
}

#pragma mark - View lifecycle

- (void)viewDidLoad
{
    [super viewDidLoad];
    m_hud = [[ATMHud alloc] initWithDelegate:self];
	[self.view addSubview:m_hud.view];
}

- (void)viewDidUnload
{
    [super viewDidUnload];
    
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    // Return YES for supported orientations
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}
- (IBAction)comeBack:(id)sender
{
    [self dismissModalViewControllerAnimated:YES];
}
- (IBAction)regist:(id)sender
{ 
    SevenCBoxClient scBox;
    NSString *loginName = m_userNameTextField.text;
    NSString *password = m_passwordTextField.text;
    NSString *passwordA = m_passwordAgainTextField.text;

    if ([self registAssert]) {
        scBox.UserRegister([loginName cStringUsingEncoding:NSUTF8StringEncoding],[password cStringUsingEncoding:NSUTF8StringEncoding],"3",callBackRegisterFunc,self);
    }
    
}
- (BOOL)registAssert
{
    BOOL rt = YES;
    NSString *loginName = m_userNameTextField.text;
    if (loginName==nil||[loginName isEqualToString:@""]) {
        [m_hud setCaption:@"请输入合法的用户名"];
        rt=NO;
    }
    else
    { 
        NSRange rang  = [loginName rangeOfString:@"@"];
        if (rang.location==NSNotFound) {
            [m_hud setCaption:@"请输入合法的用户名"];
            rt=NO;
        }
        else
        {
            NSString *password = m_passwordTextField.text;
            NSString *passwordA = m_passwordAgainTextField.text;
            if ([password isEqualToString:@""]) {
                [m_hud setCaption:@"密码不得为空"];
                rt=NO;
            }
            else if ([password length]<6||[password length]>16) {
                [m_hud setCaption:@"输入密码在6-16位"];
                rt=NO;
            }else if(![password isEqualToString:passwordA])
            {
                [m_hud setCaption:@"两次输入的密码不一致"];
                rt=NO;
            }
        }
        
        
        
    }
    [m_hud setActivity:NO];
    [m_hud show];
    [m_hud hideAfter:1.2f];
    return rt;
    
}
void  callBackRegisterFunc(Value &jsonValue,void *s_pv)
{

    int code = jsonValue["code"].asInt();
    if (code==0) {
        [s_pv restoreUser];

    }
    else
    {
        UIAlertView *alertView  = [[UIAlertView alloc]initWithTitle:@"注册失败" message:nil delegate:nil cancelButtonTitle:@"确定" otherButtonTitles:nil, nil];
        [alertView show];
        [alertView release];
    }
    
    
}
- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    
    if (self.delegate&&[self.delegate respondsToSelector:@selector(popLoginView)]) {
        [self.delegate popLoginView];
    }
    [self dismissModalViewControllerAnimated:YES];
}
- (void)restoreUser
{
    NSString *loginName=m_userNameTextField.text;
    NSString *password =m_passwordTextField.text;
    [[NSUserDefaults standardUserDefaults] setObject:loginName forKey:@"usr_name"];
    [[NSUserDefaults standardUserDefaults] setObject:password  forKey:@"usr_pwd"];
    UIAlertView *alertView  = [[UIAlertView alloc]initWithTitle:@"注册成功" message:nil delegate:nil cancelButtonTitle:@"确定" otherButtonTitles:nil, nil];
    alertView.delegate = self;
    [alertView show];
    [alertView release];
    
}
@end
