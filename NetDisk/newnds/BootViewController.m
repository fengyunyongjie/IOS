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
@interface BootViewController ()<UIScrollViewDelegate>

@end

@implementation BootViewController
- (BOOL)shouldAutorotate{
    return NO;
}
- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation
{
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
    [self.navigationController setNavigationBarHidden:YES];
    // Do any additional setup after loading the view from its nib.
    //加载图片
    self.scrollView.delegate=self;
    //self.scrollView.frame=self.view.frame;
    //self.scrollView.frame=CGRectMake(0, 0, [UIScreen mainScreen].bounds.size.width, [UIScreen mainScreen].bounds.size.height);
    for (int i=1; i<=3; i++) {
        if ([[UIScreen mainScreen] bounds].size.height>480) {
            //iphone5
            NSString *fileName=[NSString stringWithFormat:@"guide_bk_%d@iPhone5.png",i];
            UIImageView *imageView=[[UIImageView alloc] initWithImage:[UIImage imageNamed:fileName]];
            imageView.frame=CGRectMake((i-1)*self.view.frame.size.width, 0, self.view.frame.size.width, 568);
            [self.scrollView setContentSize:CGSizeMake(self.scrollView.frame.size.width*3, 568)];
            [self.scrollView addSubview:imageView];
        }else
        {
            [self.scrollView setContentSize:CGSizeMake(self.scrollView.frame.size.width*3, 480)];
            NSString *fileName=[NSString stringWithFormat:@"guide_bk_%d.png",i];
            UIImageView *imageView=[[UIImageView alloc] initWithImage:[UIImage imageNamed:fileName]];
            imageView.frame=CGRectMake((i-1)*self.view.frame.size.width, 0, self.view.frame.size.width, 480);
            [self.scrollView addSubview:imageView];
        }
    }
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
-(void)scrollViewDidScroll:(UIScrollView *)scrollView
{
    NSInteger page = scrollView.contentOffset.x/self.view.frame.size.width;
    [self.pageCtrl setCurrentPage:page];
}
@end
