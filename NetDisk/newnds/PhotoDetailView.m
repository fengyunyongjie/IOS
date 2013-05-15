//
//  PhotoDetailView.m
//  NetDisk
//
//  Created by Yangsl on 13-5-6.
//
//

#import "PhotoDetailView.h"
#import <QuartzCore/QuartzCore.h>

@implementation PhotoDetailView
@synthesize bgImageView,leftButton,bottonView,addressLabel,centerButton,clientLabel,dateTimeLabel,dayTimeLabel,lineImageView,rightButton,weatherLabel,clickButton;

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        bgImageView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, frame.size.width, frame.size.height)];
        [self addSubview:bgImageView];
        
        clickButton = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, frame.size.width, frame.size.height)];
        [clickButton setBackgroundColor:[UIColor clearColor]];
        [self addSubview:clickButton];
        
        CGRect addressRect = CGRectMake(5, bgImageView.frame.size.height-130, 310, 30);
        addressLabel = [[UILabel alloc] initWithFrame:addressRect];
        [addressLabel setBackgroundColor:[UIColor clearColor]];
        [self addSubview:addressLabel];
        
        
        CGRect weatherRect = CGRectMake(5, bgImageView.frame.size.height-100, 150, 25);
        weatherLabel = [[UILabel alloc] initWithFrame:weatherRect];
        [weatherLabel setBackgroundColor:[UIColor clearColor]];
        [self addSubview:weatherLabel];
        
        CGRect dayTimeRect = CGRectMake(150, bgImageView.frame.size.height-100, 150, 25);
        dayTimeLabel = [[UILabel alloc] initWithFrame:dayTimeRect];
        [dayTimeLabel setBackgroundColor:[UIColor clearColor]];
        [self addSubview:dayTimeLabel];
        
        CGRect lineRect = CGRectMake(5, bgImageView.frame.size.height-75, 310, 2);
        lineImageView = [[UIImageView alloc] initWithFrame:lineRect];
        [lineImageView setBackgroundColor:[UIColor clearColor]];
        [self addSubview:lineImageView];
        
        CGRect dateLineRect = CGRectMake(5, bgImageView.frame.size.height-69, 150, 25);
        dateTimeLabel = [[UILabel alloc] initWithFrame:dateLineRect];
        [dateTimeLabel setBackgroundColor:[UIColor clearColor]];
        [self addSubview:dateTimeLabel];
        
        CGRect clientRect = CGRectMake(155, bgImageView.frame.size.height-69, 150, 25);
        clientLabel = [[UILabel alloc] initWithFrame:clientRect];
        [clientLabel setBackgroundColor:[UIColor clearColor]];
        [self addSubview:clientLabel];
        
        CGRect bottonRect = CGRectMake(0, bgImageView.frame.size.height-44, 320, 44);
        bottonView = [[UIView alloc] initWithFrame:bottonRect];
        CGRect bottonImageRect = CGRectMake(0, 0, 320, 44);
        UIImageView *bottonImage = [[UIImageView alloc] initWithFrame:bottonImageRect];
        [bottonImage setImage:[UIImage imageNamed:@"u8_normal.png"]];
        [bottonView addSubview:bottonImage];
        [bottonImage release];
        [self addSubview:bottonView];
        
        CGRect leftRect = CGRectMake(36, bgImageView.frame.size.height-39, 35, 33);
        leftButton = [[UIButton alloc] initWithFrame:leftRect];
        [leftButton.titleLabel setFont:[UIFont systemFontOfSize:14]];
        [leftButton.titleLabel setTextColor:[UIColor blackColor]];
        [leftButton setBackgroundImage:[UIImage imageNamed:@"u10_normal.png"] forState:UIControlStateNormal];
        [self addSubview:leftButton];
        
        CGRect centerRect = CGRectMake(107+36, bgImageView.frame.size.height-39, 35, 33);
        centerButton = [[UIButton alloc] initWithFrame:centerRect];
        [centerButton.titleLabel setFont:[UIFont systemFontOfSize:14]];
        [centerButton.titleLabel setTextColor:[UIColor blackColor]];
        [centerButton setBackgroundImage:[UIImage imageNamed:@"u12_normal.png"] forState:UIControlStateNormal];
        [self addSubview:centerButton];
        
        CGRect rightRect = CGRectMake(213+36, bgImageView.frame.size.height-39, 35, 33);
        rightButton = [[UIButton alloc] initWithFrame:rightRect];
        [rightButton.titleLabel setFont:[UIFont systemFontOfSize:14]];
        [rightButton.titleLabel setTextColor:[UIColor blackColor]];
        [rightButton setBackgroundImage:[UIImage imageNamed:@"u14_normal.png"] forState:UIControlStateNormal];
        [self addSubview:rightButton];
        
        [self hiddenNewview];
        
    }
    return self;
}

#pragma mark 隐藏信息
-(void)hiddenNewview
{
    [leftButton setHidden:YES];
    [bottonView setHidden:YES];
    [addressLabel setHidden:YES];
    [centerButton setHidden:YES];
    [clientLabel setHidden:YES];
    [dateTimeLabel setHidden:YES];
    [dayTimeLabel setHidden:YES];
    [lineImageView setHidden:YES];
    [rightButton setHidden:YES];
    [weatherLabel setHidden:YES];
}

#pragma mark 显示信息
-(void)showNewview
{
    [leftButton setHidden:NO];
    [bottonView setHidden:NO];
//    [addressLabel setHidden:NO];
    [centerButton setHidden:NO];
//    [clientLabel setHidden:NO];
//    [dateTimeLabel setHidden:NO];
//    [dayTimeLabel setHidden:NO];
//    [lineImageView setHidden:NO];
    [rightButton setHidden:NO];
//    [weatherLabel setHidden:NO];
}

- (void)initImageView
{
    [self setContentSize:CGSizeMake(bgImageView.frame.size.width, bgImageView.frame.size.height)];
}

-(void)dealloc
{
    [bgImageView release];
    [clickButton release];
    [addressLabel release];
    [weatherLabel release];
    [dayTimeLabel release];
    [lineImageView release];
    [dateTimeLabel release];
    [clientLabel release];
    [bottonView release];
    [leftButton release];
    [centerButton release];
    [rightButton release];
    [super dealloc];
}

@end
