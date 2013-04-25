//
//  NDLoginViewController.m
//  NetDisk
//
//  Created by jiangwei on 12-11-12.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import "NDLoginViewController.h"
#import "SCBAccountManager.h"

void callBackFunc(Value &jsonValue,void *s_pv);

@implementation NDLoginViewController
@synthesize m_userNameTextField,m_passwordTextField,m_commitButton;
@synthesize m_imageView,m_view;
@synthesize delegate;
- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        isRegistComeBack = NO;
    }
    return self;
}
- (void)dealloc
{
    [m_passwordTextField release];
    [m_userNameTextField release];
    [m_hud release];
    [m_commitButton release];
    [super dealloc];
}
- (void)didReceiveMemoryWarning
{
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
    
    // Release any cached data, images, etc that aren't in use.
}
- (IBAction)userRegister:(id)sender
{
    
    NDRegistViewController *regist=[[NDRegistViewController alloc]initWithNibName:@"NDRegistViewController" bundle:nil];
    regist.delegate = self;
    [self presentModalViewController:regist animated:YES];
    [regist release];
   

}

- (IBAction)login:(id)sender
{
/*    [self popSelf];
    return;
*/    
    [m_userNameTextField resignFirstResponder];
    [m_passwordTextField resignFirstResponder];
    NSLog(@"--1--User Login.");
    NSString *loginName=m_userNameTextField.text;
    NSString *password =m_passwordTextField.text;
    
    if ([loginName length]<1||[password length]<1) {
        [m_hud setCaption:@"请输入用户名和密码！"];
        [m_hud setActivity:NO];
        [m_hud show];
        [m_hud hideAfter:1.2f];
        return;
    }
    [m_hud setCaption:@"正在登陆"];
    [m_hud setActivity:YES];
    [m_hud show];
    
    SevenCBoxClient scBox;
//    NSLog(@"--1,1--");
//    NSLog(@"username:%s",[loginName cStringUsingEncoding:NSUTF8StringEncoding]);
//    NSLog(@"password:%s",[password cStringUsingEncoding:NSUTF8StringEncoding]);
    [[SCBAccountManager sharedManager] UserLoginWithName:loginName Password:password];
    scBox.UserLogin([loginName cStringUsingEncoding:NSUTF8StringEncoding],[password cStringUsingEncoding:NSUTF8StringEncoding],callBackFunc,self);
 /*   string name= "deyangdianzi@qq.com";
    string password1="1234567";
 //   SevenCBoxClient::SetServerUrl("http://deyangtech.xicp.net:8080/RestAPI/");
    SevenCBoxClient::UserLogin(name,password1,callBackFunc);*/
}
#pragma mark - View lifecycle

- (void)viewDidLoad
{
    [super viewDidLoad];
    m_hud = [[ATMHud alloc] initWithDelegate:self];
	[self.view addSubview:m_hud.view];
}
- (void)viewWillAppear:(BOOL)animated
{
    
    NSString *userName = [[NSUserDefaults standardUserDefaults] objectForKey:@"usr_name"];
    NSString *userPwd  = [[NSUserDefaults standardUserDefaults] objectForKey:@"usr_pwd"];
    self.m_userNameTextField.text = userName;
    self.m_passwordTextField.text = userPwd;

    [super viewWillAppear:animated];
/*    
    CABasicAnimation *animation=[CABasicAnimation animationWithKeyPath:@"transform.translation.y"];
    animation.fromValue = [NSNumber numberWithFloat:400.0];
    animation.toValue = [NSNumber numberWithFloat:0];
    [animation setDuration:1.0f];
    [animation setTimingFunction:[CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseIn]];
    [m_view.layer addAnimation:animation forKey:@"m_imageView_Reveal"];
    
    CABasicAnimation *animation1=[CABasicAnimation animationWithKeyPath:@"transform.translation.y"];
    animation1.fromValue = [NSNumber numberWithFloat:400.0];
    animation1.toValue = [NSNumber numberWithFloat:0];
    [animation1 setDuration:0.7f];
    [animation1 setTimingFunction:[CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseIn]];
    [m_imageView.layer addAnimation:animation1 forKey:@"m_View_Reveal"];
*/
    m_commitButton.enabled = YES;
    if (isRegistComeBack&&userName!=nil&&userPwd!=nil) {
        m_commitButton.enabled = NO;
        [self performSelector:@selector(popSelf) withObject:nil afterDelay:1.0f];
    }
    
}
- (void)initSomeFilesPath
{
    NSArray*paths=NSSearchPathForDirectoriesInDomains(NSDocumentDirectory,NSUserDomainMask,YES);
    NSString *documentsDirectory=[paths objectAtIndex:0]; 
    NSString *dbPath=[NSString stringWithFormat:@"%@/",documentsDirectory]; 
    SevenCBoxClient::Config.SetDbFilePath([dbPath cStringUsingEncoding:NSUTF8StringEncoding]);
    NSString *logPath = [documentsDirectory stringByAppendingPathComponent:@"7cboxLog.txt"];
    SevenCBoxClient::Config.SetLogFile([logPath cStringUsingEncoding:NSUTF8StringEncoding]);
    
    NSString *uploadTempPath = [NSString stringWithFormat:@"%@/",[Function getUploadTempPath]]; 
    SevenCBoxClient::Config.SetTempFolder([uploadTempPath cStringUsingEncoding:NSUTF8StringEncoding]);
}
- (void)popSelf
{
    [m_hud hideAfter:0.2f];
    
    [self performSelector:@selector(initSomeFilesPath) withObject:nil afterDelay:0.2f];
    
   /** 
    UIAlertView *al = [[UIAlertView alloc]initWithTitle:[Function getUploadTempPath] message:nil delegate:nil cancelButtonTitle:nil otherButtonTitles:nil, nil];
    [al show];
  */ 
    NSString *loginName=m_userNameTextField.text;
    NSString *password =m_passwordTextField.text;
    [[NSUserDefaults standardUserDefaults] setObject:loginName forKey:@"usr_name"];
    [[NSUserDefaults standardUserDefaults] setObject:password  forKey:@"usr_pwd"];
    [[NSUserDefaults standardUserDefaults] synchronize];
   
    if (self.delegate&&[self.delegate respondsToSelector:@selector(getMainData)]) {
        [self.delegate getMainData];
    } 
   
    //SevenCBoxClient::StartTaskMonitor();
    CTaskManager * taskManager = SevenCBoxClient::GetTaskManager();
  //  taskManager->StartTaskMonitor();
    [self dismissModalViewControllerAnimated:YES];
}
- (void)viewDidUnload
{
    [super viewDidUnload];
    
    
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}

-(void)loginFaile
{
    [m_hud setCaption:@"登陆失败，请重试！"];
    [m_hud setActivity:NO];
    [m_hud show];
    [m_hud hideAfter:1.2f];
}

void callBackFunc(Value &jsonValue,void *s_pv)
{
    
 //   jsonValue["code"].asInt();
 //   NSLog(@"%s",jsonValue["code"].asCString());
 //   printf(jsonValue.asCString(),nil);
 /*   bool rtc = jsonValue.isMember("code");
    Value::Members dd = jsonValue.getMemberNames();*/

    int a = jsonValue["code"].asInt();
    string err = jsonValue["error"].asString();
    if (a==0) {
        [s_pv popSelf];
    }
    else
    {
        [s_pv loginFaile];
    }
}
- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    // Return YES for supported orientations
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}
- (void)setNav:(UINavigationController *)theNav
{
    m_nav = theNav;
}

- (void)popLoginView
{
/*    if (self.delegate&&[self.delegate respondsToSelector:@selector(getMainData)]) {
        [self.delegate getMainData];
    } 
*/
  //  isRegistComeBack = YES;
}
@end
