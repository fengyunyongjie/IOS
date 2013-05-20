//
//  RegistViewController.m
//  NetDisk
//
//  Created by fengyongning on 13-5-20.
//
//

#import "RegistViewController.h"
#import "MBProgressHUD.h"

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
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
- (IBAction) regitst:(id)sender
{
    if ([self registAssert]) {
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
@end
