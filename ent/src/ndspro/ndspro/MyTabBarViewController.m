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
    //[vc1.navigationBar setBackgroundImage:[UIImage imageNamed:@"title_se.png"] forBarMetrics:UIBarMetricsDefault];
    [vc1.navigationBar setBarStyle:UIBarStyleBlackTranslucent];
    [vc1.navigationBar setBackgroundColor:[UIColor blueColor]];
//    [vc1.navigationBar setTintColor:[UIColor blueColor]];
    MainViewController * vc11=[[MainViewController alloc] init];
    [vc1 pushViewController:vc11 animated:YES];
    vc11.title=@"工作区";
    vc1.title=@"文件管理";
    //vc1.tabBarItem=[[UITabBarItem alloc] initWithTabBarSystemItem:UITabBarSystemItemBookmarks tag:0];
    [vc1.tabBarItem setFinishedSelectedImage:[UIImage imageNamed:@"Bt_UsercentreCh.png"] withFinishedUnselectedImage:[UIImage imageNamed:@"Bt_UsercentreNo.png"]];
    //[vc1.tabBarItem set]
    UINavigationController *vc2=[[UINavigationController alloc] init];
    UpDownloadViewController *vc22=[[UpDownloadViewController alloc] init];
    [vc2 pushViewController:vc22 animated:YES];
    vc2.title=@"文件传输";
    //vc2.tabBarItem=[[UITabBarItem alloc] initWithTabBarSystemItem:UITabBarSystemItemContacts tag:0];
    [vc2.tabBarItem setFinishedSelectedImage:[UIImage imageNamed:@"Bt_UsercentreCh.png"] withFinishedUnselectedImage:[UIImage imageNamed:@"Bt_UsercentreNo.png"]];
    UINavigationController *vc3=[[UINavigationController alloc] init];
    EmailListViewController * vc33=[[EmailListViewController alloc] init];
    [vc3 pushViewController:vc33 animated:YES];
    vc3.title=@"文件收发";
    //vc3.tabBarItem=[[UITabBarItem alloc] initWithTabBarSystemItem:UITabBarSystemItemDownloads tag:0];
    [vc3.tabBarItem setFinishedSelectedImage:[UIImage imageNamed:@"Bt_UsercentreCh.png"] withFinishedUnselectedImage:[UIImage imageNamed:@"Bt_UsercentreNo.png"]];
    SettingViewController *vc44=[[SettingViewController alloc] init];
    UINavigationController *vc4=[[UINavigationController alloc] initWithRootViewController:vc44];
    vc44.title=@"设置中心";
    vc4.title=@"系统设置";
    //vc4.tabBarItem=[[UITabBarItem alloc] initWithTabBarSystemItem:UITabBarSystemItemFeatured tag:0];
    //[vc4.tabBarItem setImage:[UIImage imageNamed:@"Bt_UsercentreCh.png"]];
    [vc4.tabBarItem setFinishedSelectedImage:[UIImage imageNamed:@"Bt_UsercentreCh.png"] withFinishedUnselectedImage:[UIImage imageNamed:@"Bt_UsercentreNo.png"]];
    self.viewControllers=@[vc1,vc2,vc3,vc4];
    self.selectedIndex=0;
    //[self.tabBar setBackgroundImage:[UIImage imageNamed:@"Bt_UsercentreCh.png"]];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
