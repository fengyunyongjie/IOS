//
//  WelcomeViewController.m
//  ndspro
//
//  Created by fengyongning on 13-10-18.
//  Copyright (c) 2013年 fengyongning. All rights reserved.
//

#import "WelcomeViewController.h"
#import "PConfig.h"
__strong static WelcomeViewController *_welcommeVC;
@interface WelcomeViewController ()<UIScrollViewDelegate>
@property (strong,nonatomic) UIScrollView *scrollView;
@property (strong,nonatomic) UIPageControl *pageCtrl;
@end

@implementation WelcomeViewController
//<ios 6.0
- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation
{
    return NO;
}

//>ios 6.0
- (BOOL)shouldAutorotate{
    return NO;
}

+(WelcomeViewController *)sharedUser
{
    if (_welcommeVC) {
        return _welcommeVC;
    }else
    {
        _welcommeVC=[[WelcomeViewController alloc] init];
        return _welcommeVC;
    }
}
-(void)showWelCome
{
    [[UIApplication sharedApplication].keyWindow addSubview: self.view];
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
    self.view.frame=[[UIScreen mainScreen] bounds];
    [self.view setBackgroundColor:[UIColor whiteColor]];
    UIScrollView *scroll_view=[[UIScrollView alloc] initWithFrame:self.view.frame];
    [scroll_view setContentSize:CGSizeMake(self.view.frame.size.width*3, self.view.frame.size.height)];
    [scroll_view setPagingEnabled:YES];
    [scroll_view setDelegate:self];
    [scroll_view setShowsHorizontalScrollIndicator:NO];
    [self.view addSubview:scroll_view];
    
    //加载图片
    for (int i=1; i<=3; i++) {
        if ([[UIScreen mainScreen] bounds].size.height>480) {
            //iphone5
            NSString *fileName=[NSString stringWithFormat:@"guide_%d@iPhone5.png",i];
            UIImageView *imageView=[[UIImageView alloc] initWithImage:[UIImage imageNamed:fileName]];
            imageView.frame=CGRectMake((i-1)*self.view.frame.size.width, 0, self.view.frame.size.width, self.view.frame.size.height);
            [scroll_view addSubview:imageView];
        }else
        {
            NSString *fileName=[NSString stringWithFormat:@"guide_%d.png",i];
            UIImageView *imageView=[[UIImageView alloc] initWithImage:[UIImage imageNamed:fileName]];
            imageView.frame=CGRectMake((i-1)*self.view.frame.size.width, 0, self.view.frame.size.width, self.view.frame.size.height);
            [scroll_view addSubview:imageView];
        }
    }
//    UIImageView *pageBg=[[UIImageView alloc] initWithFrame:CGRectMake((self.view.frame.size.width-200)/2, self.view.frame.size.height-100, 200, 49)];
//    pageBg.image=[UIImage imageNamed:@"guide_gray.png"];
//    [self.view addSubview:pageBg];
    UIPageControl *pageCtrl=[[UIPageControl alloc] initWithFrame:CGRectMake((self.view.frame.size.width-200)/2, 10, 200, 49)];
    
    [pageCtrl setNumberOfPages:3];
    [pageCtrl addTarget:self action:@selector(clicked_page:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:pageCtrl];
    self.pageCtrl=pageCtrl;
    self.scrollView=scroll_view;
    
    UIButton *button=[[UIButton alloc] initWithFrame:CGRectMake(320*3-41, self.view.frame.size.height-41, 41, 41)];
    [button setBackgroundImage:[UIImage imageNamed:@"guide_bt_nor.png"] forState:UIControlStateNormal];
    [button setBackgroundImage:[UIImage imageNamed:@"guide_bt_se.png"] forState:UIControlStateHighlighted];
    [button addTarget:self action:@selector(toHideView) forControlEvents:UIControlEventTouchUpInside];
    [self.scrollView addSubview:button];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
-(void)clicked_page:(id)sender
{
    UIPageControl *page = sender;
    if([page isKindOfClass:[UIPageControl class]])
    {
        [self.scrollView setContentOffset:CGPointMake(self.view.frame.size.width * page.currentPage, 0) animated:YES];
    }
}
-(void)toHideView
{
    [[NSUserDefaults standardUserDefaults] setObject:VERSION forKey:VERSION];
    [self.view removeFromSuperview];
}
-(void)scrollViewDidScroll:(UIScrollView *)scrollView
{
    NSInteger page = scrollView.contentOffset.x/self.view.frame.size.width;
    if(scrollView.contentOffset.x > self.view.frame.size.width * 2 )
    {
        [self.pageCtrl setHidden:YES];
    }
    else
    {
        [self.pageCtrl setHidden:NO];
    }
    [self.pageCtrl setCurrentPage:page];
}
@end
