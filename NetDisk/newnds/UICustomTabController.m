//
//  UICustomTabController.m
//  CustomTab
//
//  Created by user on 12-2-7.
//  Copyright (c) 2012年 ITMG zhaoxiaopeng. All rights reserved.
//

#import "UICustomTabController.h"
#import <QuartzCore/QuartzCore.h>

@implementation UICustomTabController
@synthesize show_style,need_to_custom,normal_image,select_image,tab_bar_bg,delegate_custom,tab_delegate;
@synthesize font_color,font,hidesBottomBarWhenPushed,hilighted_color,current_selected_tab_index;

- (id)init
{
    if (self = [super init])
    {
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
    [super viewDidAppear:animated];
    if (need_to_custom && !is_did_load)
    {
        is_did_load = YES;
        tab_num = [self.viewControllers count];
        [self add_custom_view_layer];
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
        animation.duration = 0.45f;
        animation.timingFunction = UIViewAnimationCurveEaseInOut;
        animation.fillMode = kCAFillModeForwards;
        animation.type = kCATransitionPush;
        animation.subtype = kCATransitionFromBottom;
        
        CGRect frame = [custom_view frame];
        frame.origin.y = 480;
        [custom_view setFrame:frame];
        [custom_view.layer removeAllAnimations];
        [custom_view.layer addAnimation:animation forKey:@"animated"];
        IsTabBarHidden = YES;
    }
    else
    {
        CATransition *animation = [CATransition animation];
        animation.duration = 0.45f;
        animation.timingFunction = UIViewAnimationCurveEaseInOut;
        animation.fillMode = kCAFillModeForwards;
        animation.type = kCATransitionPush;
        animation.subtype = kCATransitionFromTop;

        CGRect frame = [custom_view frame];
        frame.origin.y = 431;
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
                [view setFrame:CGRectMake(0, 0, 320,480-show_size)];
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
        rect = CGRectMake(0, 480-show_size, 320, show_size);
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
                rect = CGRectMake(i*320/tab_num, 0, 320/tab_num, show_size);
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
                CGRect frame = CGRectMake((rect.size.width - image.size.width*height/image.size.height)/2, 5, image.size.width*height/image.size.height, height);
                [top_image setFrame:frame];
                [tools_view addSubview:top_image];
                if (i == [self selectedIndex])
                {
//                    [top_image setImage:[UIImage get_image_in_main_bundle:[select_image objectAtIndex:i]]];
                }
                [top_image release];
                
                frame = CGRectMake(rect.origin.x, rect.origin.y+rect.size.height-15, rect.size.width, 13);
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
        
//        UIImage *image_normal = [UIImage get_image_in_main_bundle:[normal_image objectAtIndex:i]];
//        UIImage *image_selected = [UIImage get_image_in_main_bundle:[select_image objectAtIndex:i]];
        if (i == tag)
        {
//            [image_view setImage:image_selected];
            [label setTextColor:hilighted_color];
            [[tab_btn objectAtIndex:i] setSelected:YES];
        }
        else
        {
            [label setTextColor:font_color];
//            [image_view setImage:image_normal];
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

@end
