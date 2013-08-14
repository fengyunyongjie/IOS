//
//  ReportViewController.m
//  NetDisk
//
//  Created by fengyongning on 13-8-12.
//
//
#import "MBProgressHUD.h"
#import "SCBReportManager.h"
#import "ReportViewController.h"

@interface ReportViewController ()
@property(strong,nonatomic)MBProgressHUD *hud;
@property(strong,nonatomic)SCBReportManager *rm;
@end

@implementation ReportViewController

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
}
-(void)viewWillUnload
{
    [self.rm callAllTask];
    self.rm=nil;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
-(IBAction)back:(id)sender
{
    [self.navigationController popViewControllerAnimated:YES];
}
-(IBAction)send:(id)sender
{
    self.rm=[[SCBReportManager alloc] init];
    self.rm.delegate=self;
    [self.rm sendReport:self.reportView.text];
    if (self.hud) {
        [self.hud removeFromSuperview];
    }
    self.hud=nil;
    self.hud=[[MBProgressHUD alloc] initWithView:self.view];
    [self.view addSubview:self.hud];
    self.hud.labelText=@"正在提交...";
    self.hud.mode=MBProgressHUDModeIndeterminate;
    [self.hud show:YES];
}
- (IBAction)endEdit:(id)sender
{
    [self.reportView endEditing:YES];
}
-(void)sendReportSucceed
{
    if (self.hud) {
        [self.hud removeFromSuperview];
    }
    self.hud=nil;
    self.hud=[[MBProgressHUD alloc] initWithView:self.view];
    [self.view addSubview:self.hud];
    [self.hud show:NO];
    self.hud.labelText=@"提交成功！";
    self.hud.mode=MBProgressHUDModeText;
    self.hud.margin=10.f;
    [self.hud show:YES];
    [self.hud hide:YES afterDelay:1.0f];
    [self performSelector:@selector(back:) withObject:self afterDelay:1.0f];
}
-(void)sendReportUnsucceed
{
    if (self.hud) {
        [self.hud removeFromSuperview];
    }
    self.hud=nil;
    self.hud=[[MBProgressHUD alloc] initWithView:self.view];
    [self.view addSubview:self.hud];
    [self.hud show:NO];
    self.hud.labelText=@"提交失败！";
    self.hud.mode=MBProgressHUDModeText;
    self.hud.margin=10.f;
    [self.hud show:YES];
    [self.hud hide:YES afterDelay:1.0f];
}
@end
