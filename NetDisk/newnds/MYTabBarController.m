//
//  MYTabBarController.m
//  NetDisk
//
//  Created by fengyongning on 13-4-28.
//
//
#define TabBarS_Width 50
#define TabBarWidth (320-TabBarS_Width)
#define ImageViewBorder 3
#define LabelViewBorder 20
#define TabBarHeight 60

#import "MYTabBarController.h"
#import "YNFunctions.h"
#import "LoginViewController.h"
#import "SettingViewController.h"
#import "MyndsViewController.h"
#import "FavoritesViewController.h"
#import "UploadViewController.h"
#import "MainViewController.h"
#import "PConfig.h"

@interface MYTabBarController ()

@end

@implementation MYTabBarController
@synthesize show_style,need_to_custom,normal_image,select_image,tab_bar_bg,delegate_custom,tab_delegate;
@synthesize font_color,font,hidesBottomBarWhenPushed,hilighted_color,current_selected_tab_index;

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
        need_to_custom = NO;
        delegate_custom = NO;
        is_did_load = NO;
        show_style = 0;
        show_way = 0;
        default_selected_index = 0;
        UIFont *default_font = [UIFont boldSystemFontOfSize:14.0];
        font = default_font;
        UIColor *default_color = [UIColor whiteColor];
        font_color = default_color;
        tab_btn = [[NSMutableArray alloc] initWithCapacity:0];
        view_manager = [[NSMutableArray alloc] initWithCapacity:0];
    }
    return self;
}
-(id)init
{
    self.view.hidden=YES;
    allHeight = self.view.frame.size.height;
    NSLog(@"frame:%@",NSStringFromCGRect(self.view.frame));
    self=[super init];
    if (self) {
        need_to_custom = NO;
        delegate_custom = NO;
        is_did_load = NO;
        show_style = 0;
        show_way = 0;
        default_selected_index = 0;
        UIFont *default_font = [UIFont boldSystemFontOfSize:14.0];
        font = default_font;
        UIColor *default_color = [UIColor whiteColor];
        font_color = default_color;
        tab_btn = [[NSMutableArray alloc] initWithCapacity:0];
        view_manager = [[NSMutableArray alloc] initWithCapacity:0];
//        [self resetData];
        CGRect r=self.tabBar.frame;
        r.size.height=60;
    }
    return self;
}
-(void)presendLoginViewController
{
    NSString *version=[[NSUserDefaults standardUserDefaults] objectForKey:VERSION];
    if (version==nil) {
        [[NSUserDefaults standardUserDefaults] setObject:nil forKey:@"usr_name"];
        [[NSUserDefaults standardUserDefaults] setObject:nil  forKey:@"usr_pwd"];
        [[NSUserDefaults standardUserDefaults] setObject:nil forKey:@"switch_flag"];
        [[NSUserDefaults standardUserDefaults] setObject:nil forKey:@"isAutoUpload"];
        [[NSUserDefaults standardUserDefaults] setObject:@"version" forKey:VERSION];
        [[NSUserDefaults standardUserDefaults] setObject:nil forKey:@"showHelpInMSB"];
        [[NSUserDefaults standardUserDefaults] setObject:nil forKey:@"showHelpInHS"];
        [[NSUserDefaults standardUserDefaults] synchronize];
    }
    
    NSString *userName = [[NSUserDefaults standardUserDefaults] objectForKey:@"usr_name"];
    NSString *userPwd  = [[NSUserDefaults standardUserDefaults] objectForKey:@"usr_pwd"];
    if (userName==nil&&userPwd==nil) {
        LoginViewController *lv=[[[LoginViewController alloc] initWithNibName:@"LoginViewController" bundle:nil] autorelease];
        lv.delegate=self;
        [self presentViewController:lv animated:NO completion:^(void){}];
    }
    else
    {
        [self performSelector:@selector(aabbcc) withObject:nil afterDelay:0.1f];
    }
}
-(void)aabbcc
{
    if([YNFunctions isAutoUpload])
    {
        [self.tab_delegate  automicUpload];
    }
}
-(void)resetData
{
    self.selectedIndex = 0;
    
    [self when_tabbar_is_selected:0];
//    UINavigationController *viewController1,*viewController2,*viewController3,*viewController4,*viewController5,*viewController6,*viewController7,*viewController8;
//    viewController1=[[[UINavigationController alloc] init] autorelease];
//    MainViewController *rootView1=[[[MainViewController alloc] init ]autorelease];
//    //rootView1.f_id=@"1";
//    //rootView1.myndsType=kMyndsTypeDefault;
//    rootView1.title=@"我的文件";
//    [rootView1.tabBarItem setImage:[UIImage imageNamed:@"tab_btn_myroom.png"]];
//    [viewController1 pushViewController:rootView1 animated:YES];
//    
//    
//    viewController2=[[[UINavigationController alloc] init] autorelease];
//    viewController2.title=@"Second";
//    FavoritesViewController * rootView2=[[[FavoritesViewController alloc] init] autorelease];
//    rootView2.title=@"收藏";
//    [rootView2.tabBarItem setImage:[UIImage imageNamed:@"tab_btn_favorite.png"]];
//    [viewController2 pushViewController:rootView2 animated:YES];
//    
//    viewController3=[[[UINavigationController alloc] init] autorelease];
//    viewController3.title=@"Third";
//    PhotoViewController * rootView3=[[[PhotoViewController alloc] init] autorelease];
//    rootView3.title=@"照片";
//    [rootView3.tabBarItem setImage:[UIImage imageNamed:@"tab_btn_photo.png"]];
//    [viewController3 pushViewController:rootView3 animated:YES];
//    
//    viewController4=[[[UINavigationController alloc] init] autorelease];
//    viewController4.title=@"fourth";
//    UploadViewController * rootView4=[[[UploadViewController alloc] initWithNibName:@"UploadViewController" bundle:nil] autorelease];
//    rootView4.title=@"上传";
//    [rootView4.tabBarItem setImage:[UIImage imageNamed:@"tab_btn_upload.png"]];
//    [viewController4 pushViewController:rootView4 animated:YES];
//    
//    viewController5=[[[UINavigationController alloc] init] autorelease];
//    viewController5.title=@"fifth";
//    SettingViewController * rootView5=[[[SettingViewController alloc] init] autorelease];
//    [rootView5 setRootViewController:self];
//    rootView5.title=@"设置";
//    [rootView5.tabBarItem setImage:[UIImage imageNamed:@"tab_btn_setting.png"]];
//    [viewController5 pushViewController:rootView5 animated:YES];
//    
//    viewController6=[[[UINavigationController alloc] init] autorelease];
//    viewController6.title=@"sexth";
//    UIViewController * rootView6=[[[UIViewController alloc] init] autorelease];
//    rootView6.title=@"共享空间";
//    [rootView6.tabBarItem setImage:[UIImage imageNamed:@"tab_btn_myroom.png"]];
//    [viewController6 pushViewController:rootView6 animated:YES];
//    
//    viewController7=[[[UINavigationController alloc] init] autorelease];
//    viewController7.title=@"seven";
//    UIViewController * rootView7=[[[UIViewController alloc] init] autorelease];
//    rootView7.title=@"回收站";
//    [rootView7.tabBarItem setImage:[UIImage imageNamed:@"tab_btn_myroom.png"]];
//    [viewController7 pushViewController:rootView7 animated:YES];
//    
//    viewController8=[[[UINavigationController alloc] init] autorelease];
//    viewController8.title=@"eight";
//    UIViewController * rootView8=[[[UIViewController alloc] init] autorelease];
//    rootView8.title=@"我的好友";
//    [rootView8.tabBarItem setImage:[UIImage imageNamed:@"tab_btn_myroom.png"]];
//    [viewController8 pushViewController:rootView8 animated:YES];
//    
//    [viewController1.navigationBar setBarStyle:UIBarStyleBlack];
//    [viewController2.navigationBar setBarStyle:UIBarStyleBlack];
//    [viewController3.navigationBar setBarStyle:UIBarStyleBlack];
//    [viewController4.navigationBar setBarStyle:UIBarStyleBlack];
//    [viewController5.navigationBar setBarStyle:UIBarStyleBlack];
//    [viewController6.navigationBar setBarStyle:UIBarStyleBlack];
//    [viewController7.navigationBar setBarStyle:UIBarStyleBlack];
//    [viewController8.navigationBar setBarStyle:UIBarStyleBlack];
//    if ([YNFunctions isUnlockFeature]) {
//        self.viewControllers=[NSArray arrayWithObjects:viewController1,viewController2,viewController3,viewController4,viewController5,viewController6,viewController7,viewController8, nil];
//    }else
//    {
//        self.viewControllers=[NSArray arrayWithObjects:viewController1,viewController2,viewController3,viewController4,viewController5, nil];
//    }
//    self.selectedIndex=0;
//    [self.moreNavigationController.navigationBar setBarStyle:UIBarStyleBlack];
}


- (void)viewDidLoad
{
    [super viewDidLoad];
    [self.tabBar insertSubview:[[UIImageView alloc] initWithImage:[UIImage imageNamed:@"tab_bg.png"]] atIndex:1];
    CGRect r=self.tabBar.frame;
    r.size.height=60;
    self.tabBar.frame=r;
    [self.tabBar setHidden:YES];
	// Do any additional setup after loading the view.
}

//-(void)viewDidAppear:(BOOL)animated
//{
//    [self presendLoginViewController];
//    if (self.selectedIndex==0) {
//        self.selectedIndex=1;
//        self.selectedIndex=0;
//    }
//}




- (void)setNeed_to_custom:(BOOL)flag style:(int)style
{
    need_to_custom = flag;
    show_style = style;
}


- (void)loadView
{
    [super loadView];
    [self show_custom_view_layer];
}

- (void)viewDidAppear:(BOOL)animated
{
    CGRect r=self.tabBar.frame;
    
    [self presendLoginViewController];
    self.view.hidden=NO;
    [super viewDidAppear:animated];
    if (self.selectedIndex==0) {
        if (need_to_custom && !is_did_load)
        {
            is_did_load = YES;
            tab_num = [self.viewControllers count];
            [self add_custom_view_layer];
        }
    }
}



- (BOOL)IsTabBarHiden
{
    return IsTabBarHidden;
}


- (void)NeedToHiddenSpecialView:(int)view_index
{
    UIViewController *controller = [[[self.viewControllers objectAtIndex:view_index] childViewControllers] objectAtIndex:0];
    NSArray *child_array = [[controller navigationController] childViewControllers];
    //    NSLog(@"child_array count is %d",[child_array count]);
    int index = [child_array count]-1;
    while (index > 0)
    {
        UIViewController *view_controller = [child_array objectAtIndex:index];
        if (![view_controller isKindOfClass:[UIViewController class]])
        {
            [view_controller.navigationController popViewControllerAnimated:NO];
        }
        index--;
    }
}

- (void)setHidesTabBarWithAnimate:(BOOL)hide
{
    if (hide)
    {
        CATransition *animation = [CATransition animation];
        animation.duration = 0.35f;
        animation.timingFunction = UIViewAnimationCurveEaseInOut;
        animation.fillMode = kCAFillModeForwards;
        animation.type = kCATransitionPush;
        animation.subtype = kCATransitionFromBottom;
        
        CGRect frame = [custom_view frame];
        frame.origin.y = allHeight;
        [custom_view setFrame:frame];
        [custom_view.layer removeAllAnimations];
        [custom_view.layer addAnimation:animation forKey:@"animated"];
        IsTabBarHidden = YES;
    }
    else
    {
        CATransition *animation = [CATransition animation];
        animation.duration = 0.35f;
        animation.timingFunction = UIViewAnimationCurveEaseInOut;
        animation.fillMode = kCAFillModeForwards;
        animation.type = kCATransitionPush;
        animation.subtype = kCATransitionFromTop;
        
        CGRect frame = [custom_view frame];
        frame.origin.y = allHeight-TabBarHeight;
        [custom_view setFrame:frame];
        [custom_view.layer removeAllAnimations];
        [custom_view.layer addAnimation:animation forKey:@"animated"];
        IsTabBarHidden = NO;
    }
}

- (void)show_custom_view_layer
{
    for(UIView*view in self.view.subviews)
    {
        //        NSLog(@"view class is %@",[view class]);
        if([view isKindOfClass:[UITabBar class]])
        {
            //            [view removeFromSuperview];
            view.hidden = YES;
            break;
        }
        
        if ([view isKindOfClass:NSClassFromString(@"UITransitionView")])
        {
            if (show_way == UItabbarControllerHorizontal)
            {
                float show_size = show_rect.size.height;
                [view setFrame:CGRectMake(0, 0, 320,allHeight-show_size)];
            }
            else
            {
                [view setFrame:CGRectMake(show_rect.origin.x, 0, 320,self.view.frame.size.height)];
            }
        }
    }
}


- (void)setShow_way:(UItabbarControllerHorizontalVertical)index Rect:(CGRect)Rect
{
    show_way = index;
    show_rect = Rect;
}

-(void)add_custom_view_layer
{
    float show_size = show_rect.size.height;
    CGRect rect;
    if (show_way == UItabbarControllerHorizontal)
    {
        rect = CGRectMake(0, allHeight-show_size, 320, show_size);
    }
    else
    {
        rect = CGRectMake(show_rect.origin.x,show_rect.origin.y,show_rect.size.width,show_rect.size.width);
    }
    
    custom_view = [[UIView alloc] initWithFrame:rect];
    [self.view addSubview:custom_view];
    
    rect = CGRectMake(0, 0, 320, rect.size.height);
    UIImageView *tabbar_bg = [[UIImageView alloc] initWithFrame:rect];
    [tabbar_bg setTag:-20];
    [tabbar_bg setImage:tab_bar_bg];
    [custom_view addSubview:tabbar_bg];
    [tabbar_bg release];
    
    float height = 30;
    
    if (delegate_custom)
    {
        [tab_delegate custom_tabbar_view_by_delegate:custom_view];
    }
    else
    {
        for (int i = 0; i < tab_num; i++)
        {
            if (show_way == UItabbarControllerHorizontal)
            {
                rect = CGRectMake(TabBarS_Width/2+i*TabBarWidth/tab_num, ImageViewBorder, TabBarWidth/tab_num, show_size);
            }
            else
            {
                rect = CGRectMake(show_rect.origin.x,show_rect.origin.y+i*show_rect.size.height/tab_num,show_rect.size.width,show_rect.size.height/tab_num);
            }
            if (show_style == UItabbarControllerShowStyleOnlyText)
            {
                UIButton *btn = [UIButton buttonWithType:UIButtonTypeCustom];
                [btn setFrame:rect];
                NSString *text = [[[self.viewControllers objectAtIndex:i] tabBarItem] title];
                [btn setTitle:text forState:UIControlStateNormal];
                [btn.titleLabel setFont:font];
                [btn.titleLabel setTextColor:font_color];
                if (i == default_selected_index)
                {
                    [btn setSelected:YES];
                }
                [btn setTag:i];
                [tab_btn addObject:btn];
                [self.view addSubview:btn];
                [btn addTarget:self action:@selector(button_clicked_tag:) forControlEvents:UIControlEventTouchUpInside];
            }
            else if (show_style == UItabbarControllerShowStyleOnlyIcon)
            {
                UIButton *btn = [UIButton buttonWithType:UIButtonTypeCustom];
                [btn setFrame:rect];
                if (i == default_selected_index)
                {
                    [btn setSelected:YES];
                }
                [btn setTag:i];
                [tab_btn addObject:btn];
                [btn setBackgroundColor:[UIColor clearColor]];
                [btn addTarget:self action:@selector(button_clicked_tag:) forControlEvents:UIControlEventTouchUpInside];
                [self.view addSubview:btn];
                
                UIImage *image = [[[self.viewControllers objectAtIndex:i] tabBarItem] image];
                UIImageView *top_image = [[UIImageView alloc] initWithImage:image];
                CGRect frame = CGRectMake(rect.origin.x+ (rect.size.width - image.size.width)/2, rect.origin.y+ (rect.size.height - image.size.height)/2, image.size.width, image.size.height);
                
                [top_image setFrame:frame];
                [self.view addSubview:top_image];
                [top_image release];
            }
            else if (show_style == UItabbarControllerShowStyleIconAndText)
            {
                UIView *tools_view = [[UIView alloc] initWithFrame:rect];
                UIButton *btn = [UIButton buttonWithType:UIButtonTypeCustom];
                rect = CGRectMake(0, 0, rect.size.width, rect.size.height);
                [btn setFrame:rect];
                [btn setTag:i];
                [tab_btn addObject:btn];
                [btn setBackgroundColor:[UIColor clearColor]];
                [btn addTarget:self action:@selector(button_clicked_tag:) forControlEvents:UIControlEventTouchUpInside];
                [tools_view addSubview:btn];
                
                UIImage *image = [[[self.viewControllers objectAtIndex:i] tabBarItem] image];
                UIImageView *top_image = [[UIImageView alloc] initWithImage:image];
                [top_image setTag:tab_num+1];
                CGRect frame = CGRectMake((rect.size.width - image.size.width*height/image.size.height)/2, ImageViewBorder, image.size.width*height/image.size.height, height);
                NSLog(@"top_image:%@",NSStringFromCGRect(frame));
                [top_image setFrame:frame];
                [tools_view addSubview:top_image];
                if (i == [self selectedIndex])
                {
                    [top_image setImage:[UIImage imageNamed:[select_image objectAtIndex:i]]];
                }
                [top_image release];
                
                frame = CGRectMake(rect.origin.x, rect.origin.y+rect.size.height-LabelViewBorder, rect.size.width, 13);
                NSString *item_text = [[[self.viewControllers objectAtIndex:i] tabBarItem] title];
                if ([item_text length] > 0)
                {
                    UILabel *item_label = [[UILabel alloc] initWithFrame:rect];
                    [item_label setTag:tab_num+2];
                    [item_label setFrame:frame];
                    [item_label setFont:font];
                    if (i == default_selected_index)
                    {
                        [item_label setTextColor:hilighted_color];
                    }
                    else
                    {
                        [item_label setTextColor:font_color];
                    }
                    [item_label setText:item_text];
                    [item_label setTextAlignment:UITextAlignmentCenter];
                    [item_label setBackgroundColor:[UIColor clearColor]];
                    [tools_view addSubview:item_label];
                    [item_label release];
                }
                [view_manager addObject:tools_view];
                [custom_view addSubview:tools_view];
                [tools_view release];
            }
            else if (show_style == UItabbarControllerShowStyleIconLeftAndTextRigth)
            {
                
            }
            else//UItabbarControllerShowStyleIconRightAndTextLeft
            {
                
            }
        }
    }
}

- (void)setHidesBottomBarWhenPushed:(BOOL)flag
{
    //[super setHidesBottomBarWhenPushed:flag];
    for(int i = 0;i <tab_num;i++)
    {
        //这里需要根据用户的需求修改
        [[view_manager objectAtIndex:i] setHidden:flag];
    }
    [[self.view viewWithTag:-20] setHidden:flag];
}

- (void)setSelectedIndex:(int)index
{
    [super setSelectedIndex:index];
    default_selected_index = index;
}


- (void)button_clicked_tag:(id)sender
{
	int tagNum = [sender tag];
    if (tagNum != 2)
    {
        current_selected_tab_index = tagNum;
    }
    if (tagNum != 1)
    {
        [self NeedToHiddenSpecialView:1];
    }
	[self when_tabbar_is_selected:tagNum];
}

- (void)when_tabbar_is_selected:(int)tabID
{
    int tag = tabID;
	for (int i = 0; i < tab_num; i++)
    {
        UIView *view = (UIView*)[view_manager objectAtIndex:i];
        UIImageView *image_view = (UIImageView *)[view viewWithTag:tab_num+1];
        UILabel *label = (UILabel *)[view viewWithTag:tab_num+2];
        
        UIImage *image_normal = [UIImage imageNamed:[normal_image objectAtIndex:i]];
        UIImage *image_selected = [UIImage imageNamed:[select_image objectAtIndex:i]];
        if (i == tag)
        {
            [image_view setImage:image_selected];
            [label setTextColor:hilighted_color];
            [[tab_btn objectAtIndex:i] setSelected:YES];
        }
        else
        {
            [label setTextColor:font_color];
            [image_view setImage:image_normal];
            [[tab_btn objectAtIndex:i] setSelected:false];
        }
    }
	self.selectedIndex = tabID;
}

- (void)rechange_the_selected_index:(int)index
{
    [self when_tabbar_is_selected:index];
}

- (void)dealloc {
	[normal_image release];
	[select_image release];
	[tab_bar_bg release];
	[tab_btn release];
    [font_color release];
    [font release];
    [hilighted_color release];
    [view_manager release];
    [custom_view release];
    [super dealloc];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
//-(BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
//{
//    // You do not need this method if you are not supporting earlier iOS Versions
//    return [self.selectedViewController shouldAutorotateToInterfaceOrientation:interfaceOrientation];
//}
//
//-(NSUInteger)supportedInterfaceOrientations
//{
//    if (self.selectedViewController)
//        return [self.selectedViewController supportedInterfaceOrientations];
//    
//    return UIInterfaceOrientationMaskPortrait;
//}
//
//-(BOOL)shouldAutorotate
//{
//    return YES;
//}
@end
