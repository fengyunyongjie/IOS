//
//  MYTabBarController.m
//  NetDisk
//
//  Created by fengyongning on 13-4-28.
//
//

#import "MYTabBarController.h"
#import "LoginViewController.h"
#import "SettingViewController.h"
#import "MyndsViewController.h"
#import "PhotoViewController.h"

@interface MYTabBarController ()

@end

@implementation MYTabBarController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}
-(id)init
{
    self=[super init];
    if (self) {
        UINavigationController *viewController1,*viewController2,*viewController3,*viewController4,*viewController5,*viewController6;
        viewController1=[[[UINavigationController alloc] init] autorelease];
        MyndsViewController *rootView1=[[[MyndsViewController alloc] init ]autorelease];
        rootView1.f_id=@"1";
        rootView1.myndsType=kMyndsTypeDefault;
        rootView1.title=@"我的空间";
        [rootView1.tabBarItem setImage:[UIImage imageNamed:@"tab_btn_myroom.png"]];
        [viewController1 pushViewController:rootView1 animated:YES];
        [viewController1.navigationBar setBarStyle:UIBarStyleBlack];
        //[viewController1.navigationBar insertSubview:[[UIImageView alloc] initWithImage:[UIImage imageNamed:@"nav_bg.png"]] atIndex:1];
        
        
        viewController2=[[[UINavigationController alloc] init] autorelease];
        viewController2.title=@"Second";
        UIViewController * rootView2=[[[UIViewController alloc] init] autorelease];
        rootView2.title=@"收藏";
        [rootView2.tabBarItem setImage:[UIImage imageNamed:@"tab_btn_favorite.png"]];
        [viewController2 pushViewController:rootView2 animated:YES];
        
        viewController3=[[[UINavigationController alloc] init] autorelease];
        viewController3.title=@"Third";
        PhotoViewController * rootView3=[[[PhotoViewController alloc] init] autorelease];
        rootView3.title=@"照片";
        [rootView3.tabBarItem setImage:[UIImage imageNamed:@"tab_btn_photo.png"]];
        [viewController3 pushViewController:rootView3 animated:YES];
        
        viewController4=[[[UINavigationController alloc] init] autorelease];
        viewController4.title=@"fourth";
        UIViewController * rootView4=[[[UIViewController alloc] init] autorelease];
        rootView4.title=@"上传";
        [rootView4.tabBarItem setImage:[UIImage imageNamed:@"tab_btn_upload.png"]];
        [viewController4 pushViewController:rootView4 animated:YES];
        
        viewController5=[[[UINavigationController alloc] init] autorelease];
        viewController5.title=@"fifth";
        SettingViewController * rootView5=[[[SettingViewController alloc] init] autorelease];
        [rootView5 setRootViewController:self];
        rootView5.title=@"设置";
        [rootView5.tabBarItem setImage:[UIImage imageNamed:@"tab_btn_setting.png"]];
        [viewController5 pushViewController:rootView5 animated:YES];
        
        viewController6=[[[UINavigationController alloc] init] autorelease];
        viewController6.title=@"sexth";
        UIViewController * rootView6=[[[UIViewController alloc] init] autorelease];
        rootView6.title=@"共享空间";
        [viewController6 pushViewController:rootView6 animated:YES];
        
        
        self.viewControllers=[NSArray arrayWithObjects:viewController1,viewController2,viewController3,viewController4,viewController5, nil];
    }
    return self;
}
-(void)presendLoginViewController
{
    NSString *userName = [[NSUserDefaults standardUserDefaults] objectForKey:@"usr_name"];
    NSString *userPwd  = [[NSUserDefaults standardUserDefaults] objectForKey:@"usr_pwd"];
    if (userName==nil&&userPwd==nil) {
        LoginViewController *lv=[[[LoginViewController alloc] initWithNibName:@"LoginViewController" bundle:nil] autorelease];
        [self presentViewController:lv animated:YES completion:^(void){}];
    }
}
- (void)viewDidLoad
{
    [super viewDidLoad];
    [self.tabBar insertSubview:[[UIImageView alloc] initWithImage:[UIImage imageNamed:@"tab_bg.png"]] atIndex:1];
	// Do any additional setup after loading the view.
}
-(void)viewWillAppear:(BOOL)animated
{
}
-(void)viewDidAppear:(BOOL)animated
{
    [self presendLoginViewController];
    self.selectedIndex=1;
    self.selectedIndex=0;
}
- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
