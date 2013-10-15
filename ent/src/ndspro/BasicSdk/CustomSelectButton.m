//
//  CustomSelectButton.m
//  ndspro
//
//  Created by Yangsl on 13-10-11.
//  Copyright (c) 2013年 fengyongning. All rights reserved.
//

#import "CustomSelectButton.h"

@implementation CustomSelectButton
@synthesize left_backimage,left_button,left_botton_image,right_backimage,right_button,right_botton_image,delegate;

- (id)initWithFrame:(CGRect)frame leftText:(NSString *)left_title rightText:(NSString *)right_title isShowLeft:(BOOL)bl 
{
    self = [super initWithFrame:frame];
    if (self) {
        [self firstLoadAllView:frame];
        [self showLeftWithIsSelected:YES];
        [self.left_button addTarget:self action:@selector(left_click:) forControlEvents:UIControlEventTouchDown];
        [self.right_button addTarget:self action:@selector(right_click:) forControlEvents:UIControlEventTouchDown];
        [self updateCount:left_title downCount:right_title];
    }
    return self;
}

//是否显示左边视图
-(void)showLeftWithIsSelected:(BOOL)bl
{
    if(bl)
    {
        [self.left_button.titleLabel setFont:[UIFont boldSystemFontOfSize:14]];
        [self.left_botton_image setHidden:NO];
        [self.right_button.titleLabel setFont:[UIFont systemFontOfSize:14]];
        [self.right_botton_image setHidden:YES];
    }
    else
    {
        [self.left_button.titleLabel setFont:[UIFont systemFontOfSize:14]];
        [self.left_botton_image setHidden:YES];
        [self.right_button.titleLabel setFont:[UIFont boldSystemFontOfSize:14]];
        [self.right_botton_image setHidden:NO];
    }
    [delegate isSelectedLeft:bl];
}

//首次加载视图
-(void)firstLoadAllView:(CGRect)rect
{
    if(self.left_backimage == nil)
    {
        //添加左边视图
        CGRect left_baceRect = CGRectMake(0, 0, rect.size.width/2, rect.size.height);
        self.left_backimage = [[UIImageView alloc] initWithFrame:left_baceRect];
        [self addSubview:self.left_backimage];
        
        self.left_button = [[UIButton alloc] initWithFrame:left_baceRect];
        [self.left_button setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
        [self.left_button.titleLabel setFont:[UIFont systemFontOfSize:14]];
        [self.left_button setBackgroundColor:[UIColor clearColor]];
        [self addSubview:self.left_button];
        
        CGRect left_buttonRect = CGRectMake(0, rect.size.height-2, rect.size.width/2, 2);
        self.left_botton_image = [[UIImageView alloc] initWithFrame:left_buttonRect];
        [self.left_botton_image setHidden:YES];
        [self addSubview:self.left_botton_image];
        
        //添加右边视图
        CGRect right_baceRect = CGRectMake(rect.size.width/2, 0, rect.size.width/2, rect.size.height);
        self.right_backimage = [[UIImageView alloc] initWithFrame:right_baceRect];
        [self addSubview:self.right_backimage];
        
        self.right_button = [[UIButton alloc] initWithFrame:right_baceRect];
        [self.right_button setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
        [self.right_button.titleLabel setFont:[UIFont systemFontOfSize:14]];
        [self.right_button setBackgroundColor:[UIColor clearColor]];
        [self addSubview:self.right_button];
        
        CGRect right_buttonRect = CGRectMake(rect.size.width/2, rect.size.height-2, rect.size.width/2, 2);
        self.right_botton_image = [[UIImageView alloc] initWithFrame:right_buttonRect];
        [self.right_botton_image setHidden:YES];
        [self addSubview:self.right_botton_image];
    }
}

-(void)left_click:(id)sender
{
    [self showLeftWithIsSelected:YES];
}

-(void)updateCount:(NSString *)upload_count downCount:(NSString *)down_count
{
    [self.left_button setTitle:upload_count forState:UIControlStateNormal];
    [self.right_button setTitle:down_count forState:UIControlStateNormal];
}

-(void)right_click:(id)sender
{
    [self showLeftWithIsSelected:NO];
}

@end