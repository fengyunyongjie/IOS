//
//  CustomViewController.m
//  ndspro
//
//  Created by Yangsl on 13-10-21.
//  Copyright (c) 2013年 fengyongning. All rights reserved.
//

#import "CustomViewController.h"

@interface CustomViewController ()

@end

@implementation CustomViewController
@synthesize cutomDelegate;

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
        [self.navigationBar setBackgroundImage:[UIImage imageNamed:@"title_bk_ti.png"] forBarMetrics:UIBarMetricsDefault];
        [self.navigationBar setTitleTextAttributes:[NSDictionary dictionaryWithObject:[UIColor whiteColor] forKey:UITextAttributeTextColor]];
    }
    return self;
}

-(NSArray *)popToViewController:(UIViewController *)viewController animated:(BOOL)animated
{
    viewController = [cutomDelegate popToViewController];
    return [super popToViewController:viewController animated:YES];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view.
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
