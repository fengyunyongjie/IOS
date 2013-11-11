//
//  BootViewController.m
//  NetDisk
//
//  Created by fengyongning on 13-11-11.
//
//

#import "BootViewController.h"
#import "LoginViewController.h"
#import "RegistViewController.h"
@interface BootViewController ()

@end

@implementation BootViewController

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
    [self.navigationController setNavigationBarHidden:YES];
    // Do any additional setup after loading the view from its nib.
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
-(IBAction)toLogVc:(id)sender
{
    LoginViewController *vc=[[LoginViewController alloc] initWithNibName:@"LoginViewController" bundle:nil];
    [self.navigationController pushViewController:vc animated:YES];
}
-(IBAction)toRegistVc:(id)sender
{
    RegistViewController *vc=[[RegistViewController alloc] initWithNibName:@"RegistViewController" bundle:nil];
    [self.navigationController pushViewController:vc animated:YES];
}
@end
