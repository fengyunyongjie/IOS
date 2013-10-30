//
//  MyTabBarViewController.m
//  ndspro
//
//  Created by fengyongning on 13-9-26.
//  Copyright (c) 2013年 fengyongning. All rights reserved.
//

#import "MyTabBarViewController.h"
#import "MainViewController.h"
#import "SettingViewController.h"
#import "UpDownloadViewController.h"
#import "EmailListViewController.h"

@interface MyTabBarViewController ()

@end

@implementation MyTabBarViewController
@synthesize imageView,label;

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
    
    UINavigationController *vc1=[[UINavigationController alloc] init];
    [vc1.navigationBar setBackgroundImage:[UIImage imageNamed:@"title_bk_ti.png"] forBarMetrics:UIBarMetricsDefault];
    [vc1.navigationBar setTitleTextAttributes:[NSDictionary dictionaryWithObject:[UIColor whiteColor] forKey:UITextAttributeTextColor]];
//    [vc1.navigationBar setBackgroundColor:[UIColor colorWithRed:102/255.0f green:163/255.0f blue:222/255.0f alpha:1]];
    [vc1.navigationBar setTintColor:[UIColor whiteColor]];
    MainViewController * vc11=[[MainViewController alloc] init];
    [vc1 pushViewController:vc11 animated:YES];
    vc11.title=@"文件管理";
    vc1.title=@"文件管理";
    //vc1.tabBarItem=[[UITabBarItem alloc] initWithTabBarSystemItem:UITabBarSystemItemBookmarks tag:0];
    [vc1.tabBarItem setFinishedSelectedImage:[UIImage imageNamed:@"nav_file_se.png"] withFinishedUnselectedImage:[UIImage imageNamed:@"nav_file_nor.png"]];
//    [vc1.tabBarItem setSelectedImage:[UIImage imageNamed:@"nav_selected.png"]];
    [vc1.tabBarItem setTitleTextAttributes:[NSDictionary dictionaryWithObject:[UIColor whiteColor] forKey:UITextAttributeTextColor] forState:UIControlStateSelected];
    [vc1.tabBarItem setTitleTextAttributes:[NSDictionary dictionaryWithObject:[UIColor colorWithRed:35/255.0f green:73/255.0f blue:127/255.0f alpha:1] forKey:UITextAttributeTextColor] forState:UIControlStateNormal];
    //[vc1.tabBarItem setImage:[UIImage imageNamed: @"nav_selected.png"]];
    UINavigationController *vc2=[[UINavigationController alloc] init];
    UpDownloadViewController *vc22=[[UpDownloadViewController alloc] init];
    vc22.title=@"文件传输";
    [vc2 pushViewController:vc22 animated:YES];
    vc2.title=@"文件传输";
    [vc2.navigationBar setBackgroundImage:[UIImage imageNamed:@"title_bk_ti.png"] forBarMetrics:UIBarMetricsDefault];
    [vc2.navigationBar setTitleTextAttributes:[NSDictionary dictionaryWithObject:[UIColor whiteColor] forKey:UITextAttributeTextColor]];
     [vc2.navigationBar setTintColor:[UIColor whiteColor]];
    //vc2.tabBarItem=[[UITabBarItem alloc] initWithTabBarSystemItem:UITabBarSystemItemContacts tag:0];
    [vc2.tabBarItem setFinishedSelectedImage:[UIImage imageNamed:@"nav_trans_se.png"] withFinishedUnselectedImage:[UIImage imageNamed:@"nav_trans_nor.png"]];
    [vc2.tabBarItem setTitleTextAttributes:[NSDictionary dictionaryWithObject:[UIColor whiteColor] forKey:UITextAttributeTextColor] forState:UIControlStateSelected];
    [vc2.tabBarItem setTitleTextAttributes:[NSDictionary dictionaryWithObject:[UIColor colorWithRed:35/255.0f green:73/255.0f blue:127/255.0f alpha:1] forKey:UITextAttributeTextColor] forState:UIControlStateNormal];
    UINavigationController *vc3=[[UINavigationController alloc] init];
    EmailListViewController * vc33=[[EmailListViewController alloc] init];
    [vc3 pushViewController:vc33 animated:YES];
    vc33.title=@"文件收发";
    vc3.title=@"文件收发";
    [vc3.navigationBar setBackgroundImage:[UIImage imageNamed:@"title_bk_ti.png"] forBarMetrics:UIBarMetricsDefault];
    [vc3.navigationBar setTitleTextAttributes:[NSDictionary dictionaryWithObject:[UIColor whiteColor] forKey:UITextAttributeTextColor]];
     [vc3.navigationBar setTintColor:[UIColor whiteColor]];
    //vc3.tabBarItem=[[UITabBarItem alloc] initWithTabBarSystemItem:UITabBarSystemItemDownloads tag:0];
    [vc3.tabBarItem setFinishedSelectedImage:[UIImage imageNamed:@"nav_send_se.png"] withFinishedUnselectedImage:[UIImage imageNamed:@"nav_send_nor.png"]];
    [vc3.tabBarItem setTitleTextAttributes:[NSDictionary dictionaryWithObject:[UIColor whiteColor] forKey:UITextAttributeTextColor] forState:UIControlStateSelected];
    [vc3.tabBarItem setTitleTextAttributes:[NSDictionary dictionaryWithObject:[UIColor colorWithRed:35/255.0f green:73/255.0f blue:127/255.0f alpha:1] forKey:UITextAttributeTextColor] forState:UIControlStateNormal];
    SettingViewController *vc44=[[SettingViewController alloc] init];
    UINavigationController *vc4=[[UINavigationController alloc] initWithRootViewController:vc44];
    vc44.title=@"系统设置";
    vc4.title=@"系统设置";
    [vc4.navigationBar setBackgroundImage:[UIImage imageNamed:@"title_bk_ti.png"] forBarMetrics:UIBarMetricsDefault];
    [vc4.navigationBar setTitleTextAttributes:[NSDictionary dictionaryWithObject:[UIColor whiteColor] forKey:UITextAttributeTextColor]];
     [vc4.navigationBar setTintColor:[UIColor whiteColor]];
    //vc4.tabBarItem=[[UITabBarItem alloc] initWithTabBarSystemItem:UITabBarSystemItemFeatured tag:0];
    //[vc4.tabBarItem setImage:[UIImage imageNamed:@"Bt_UsercentreCh.png"]];
    [vc4.tabBarItem setFinishedSelectedImage:[UIImage imageNamed:@"nav_set_se.png"] withFinishedUnselectedImage:[UIImage imageNamed:@"nav_set_nor.png"]];
    [vc4.tabBarItem setTitleTextAttributes:[NSDictionary dictionaryWithObject:[UIColor whiteColor] forKey:UITextAttributeTextColor] forState:UIControlStateSelected];
    [vc4.tabBarItem setTitleTextAttributes:[NSDictionary dictionaryWithObject:[UIColor colorWithRed:35/255.0f green:73/255.0f blue:127/255.0f alpha:1] forKey:UITextAttributeTextColor] forState:UIControlStateNormal];
    //2013年10月29日，隐掉“文件收发”模块; by FengYN
    self.viewControllers=@[vc1,vc2,vc4];
    self.selectedIndex=0;
    [self.tabBar setBackgroundImage:[UIImage imageNamed:@"bk_nav.png"]];
    //[self.tabBar setTranslucent:NO];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void)addUploadNumber:(NSInteger)count
{
    if(!imageView)
    {
        CGRect imageRect = CGRectMake(165, -10, 35, 35);
        imageView = [[UIImageView alloc] initWithFrame:imageRect];
        [imageView setImage:[UIImage imageNamed:@"icon_checked_grid.png"]];
        CGRect labelRect = CGRectMake(5, 2, 25, 30);
        label = [[UILabel alloc] initWithFrame:labelRect];
        [label setBackgroundColor:[UIColor clearColor]];
        [label setTextColor:[UIColor whiteColor]];
        [label setFont:[UIFont boldSystemFontOfSize:11]];
        [label setTextAlignment:NSTextAlignmentCenter];
        [label setLineBreakMode:NSLineBreakByTruncatingTail];
        [imageView addSubview:label];
        [self.tabBar addSubview:imageView];
    }
    if(count>0)
    {
        [label setText:[NSString stringWithFormat:@"%i",count]];
    }
    else
    {
        [label setText:@""];
        [imageView setHidden:YES];
    }
}

@end
