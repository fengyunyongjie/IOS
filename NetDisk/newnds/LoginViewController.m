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


@interface LoginViewController ()
@property(strong,nonatomic) UIAlertView *av;
@property(strong,nonatomic) MBProgressHUD *hud;
@end

@implementation LoginViewController

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
    // Do any additional setup after loading the view from its nib.
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
- (IBAction)login:(id)sender
{
    [[SCBAccountManager sharedManager] setDelegate:self];
    [[SCBAccountManager sharedManager] UserLoginWithName:self.userNameTextField.text Password:self.passwordTextField.text];
//    self.av=[[[UIAlertView alloc] initWithTitle:@"  \n" message:@"正在登录..." delegate:self cancelButtonTitle:@"取消" otherButtonTitles: nil] autorelease];
//    [self.av show];
    self.hud.labelText=@"正在登录...";
    self.hud.mode=MBProgressHUDModeIndeterminate;
    [self.hud show:YES];
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
    [[NSUserDefaults standardUserDefaults] setObject:@"fengyn@16feng.com" forKey:@"usr_name"];
    [[NSUserDefaults standardUserDefaults] setObject:@"fengyn"  forKey:@"usr_pwd"];
    [[NSUserDefaults standardUserDefaults] synchronize];
    [self dismissViewControllerAnimated:YES completion:^(void){}];
    [self.hud show:NO];
}
-(void)loginUnsucceed:(id)manager
{
    [self.hud show:NO];
    self.hud.labelText=@"登录失败！";
    self.hud.mode=MBProgressHUDModeText;
    self.hud.margin=10.f;
    [self.hud show:YES];
    [self.hud hide:YES afterDelay:0.5f];
    
}
@end
