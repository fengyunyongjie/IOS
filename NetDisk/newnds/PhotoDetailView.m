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
@synthesize bgImageView,topButton,topView,leftButton,bottonView,addressLabel,centerButton,clientLabel,dateTimeLabel,dayTimeLabel,lineImageView,pagLabel,rightButton,weatherLabel;

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        bgImageView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, frame.size.width, frame.size.height)];
        [self addSubview:bgImageView];
        
        CGRect topRect = CGRectMake(0, 0, 320, 44);
        topView = [[UIView alloc] initWithFrame:topRect];
        [self addSubview:topView];
        
        CGRect topButtonRect = CGRectMake(5, 5, 60, 25);
        topButton = [[UIButton alloc] initWithFrame:topButtonRect];
        [topButton.titleLabel setFont:[UIFont systemFontOfSize:14]];
        [topButton.titleLabel setTextColor:[UIColor whiteColor]];
        topButton.layer.cornerRadius = 5;
        [topButton setBackgroundColor:[UIColor blackColor]];
        //设置那个圆角的有多圆
//        topButton.layer.borderWidth = 10;//设置边框的宽度，当然可以不要
//        topButton.layer.borderColor = [[UIColor redColor] CGColor];//设置边框的颜色
//        topButton.layer.masksToBounds = YES;//设为NO去试试
        
        [self addSubview:topButton];
        
        CGRect pageRect = CGRectMake(130, 7, 60, 20);
        pagLabel = [[UILabel alloc] initWithFrame:pageRect];
        [pagLabel setBackgroundColor:[UIColor clearColor]];
        [pagLabel setTextColor:[UIColor blackColor]];
        [pagLabel setTextAlignment:NSTextAlignmentCenter];
        [self addSubview:pagLabel];
        
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
        topView = [[UIView alloc] initWithFrame:bottonRect];
        [self addSubview:topView];
        
        CGRect leftRect = CGRectMake(0, 300, 107, 44);
        leftButton = [[UIButton alloc] initWithFrame:leftRect];
        [leftButton.titleLabel setFont:[UIFont systemFontOfSize:14]];
        [leftButton.titleLabel setTextColor:[UIColor blackColor]];
        [self addSubview:leftButton];
        
        CGRect centerRect = CGRectMake(50, 300, 106, 44);
        centerButton = [[UIButton alloc] initWithFrame:centerRect];
        [centerButton.titleLabel setFont:[UIFont systemFontOfSize:14]];
        [centerButton.titleLabel setTextColor:[UIColor blackColor]];
        [self addSubview:centerButton];
        
        CGRect rightRect = CGRectMake(100, 300, 107, 44);
        rightButton = [[UIButton alloc] initWithFrame:rightRect];
        [rightButton.titleLabel setFont:[UIFont systemFontOfSize:14]];
        [rightButton.titleLabel setTextColor:[UIColor blackColor]];
        [self addSubview:rightButton];
        
    }
    return self;
}

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect
{
    // Drawing code
}
*/

-(void)dealloc
{
    [bgImageView release];
    [topView release];
    [topButton release];
    [pagLabel release];
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
