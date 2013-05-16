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
#import "DBSqlite.h"
#import "UserInfo.h"


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
    //把用户信息存储到数据库
    NSString *user_name = _userNameTextField.text;
    NSString *user_passwor = _passwordTextField.text;
    NSLog(@"user_name;%@,user_password:%@",user_name,user_passwor);
    DBSqlite *sqlite3 = [[DBSqlite alloc] init];
    if([sqlite3 initDatabase])
    {
        FMDatabase *dataBase = [sqlite3 getDatabase];
        UserInfo *info = [[UserInfo alloc] init];
        info.database = dataBase;
        info.user_name = user_name;
        info.user_password = user_passwor;
        AppDelegate *app_delegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
        [app_delegate setUser_name:user_name];
        [info insertUserinfo];
        [info release];
        [dataBase close];
    }
    
    [[SCBAccountManager sharedManager] setDelegate:self];
    [[SCBAccountManager sharedManager] UserLoginWithName:self.userNameTextField.text Password:self.passwordTextField.text];
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
    AppDelegate *app_delegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
    [app_delegate setLogin];
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
