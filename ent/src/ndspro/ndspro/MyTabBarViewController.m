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
    [vc1.navigationBar setBackgroundImage:[UIImage imageNamed:@"Bt_UsercentreCh.png"] forBarMetrics:UIBarMetricsDefault];
    MainViewController * vc11=[[MainViewController alloc] init];
    [vc1 pushViewController:vc11 animated:YES];
    vc11.title=@"工作区";
    vc1.title=@"view1";
    vc1.tabBarItem=[[UITabBarItem alloc] initWithTabBarSystemItem:UITabBarSystemItemBookmarks tag:0];
    //[vc1.tabBarItem set]
    UIViewController *vc2=[[UIViewController alloc] init];
    vc2.title=@"view2";
    vc2.tabBarItem=[[UITabBarItem alloc] initWithTabBarSystemItem:UITabBarSystemItemContacts tag:0];
    UIViewController *vc3=[[UIViewController alloc] init];
    vc3.title=@"view3";
    vc3.tabBarItem=[[UITabBarItem alloc] initWithTabBarSystemItem:UITabBarSystemItemDownloads tag:0];
    SettingViewController *vc4=[[SettingViewController alloc] initWithNibName:@"SettingViewController" bundle:nil];
    vc4.title=@"系统设置";
    //vc4.tabBarItem=[[UITabBarItem alloc] initWithTabBarSystemItem:UITabBarSystemItemFeatured tag:0];
    //[vc4.tabBarItem setImage:[UIImage imageNamed:@"Bt_UsercentreCh.png"]];
    [vc4.tabBarItem setFinishedSelectedImage:[UIImage imageNamed:@"Bt_UsercentreCh.png"] withFinishedUnselectedImage:[UIImage imageNamed:@"Bt_UsercentreNo.png"]];
    self.viewControllers=@[vc1,vc2,vc3,vc4];
    self.selectedIndex=0;
    [self.tabBar setBackgroundImage:[UIImage imageNamed:@"Bt_UsercentreCh.png"]];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
