//
//  PhotoDetailView.m
//  NetDisk
//
//  Created by Yangsl on 13-5-6.
//
//

#import "PhotoDetailView.h"

@implementation PhotoDetailView
@synthesize bgImageView;

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        bgImageView = [[UIImageView alloc] initWithFrame:frame];
        [self addSubview:bgImageView];
        
        CGRect topRect = CGRectMake(0, 0, 320, 44);
        topView = [[UIView alloc] initWithFrame:topRect];
        [self addSubview:topView];
        
        CGRect pageRect = CGRectMake(130, 12, 60, 20);
        pagLabel = [[UILabel alloc] initWithFrame:pageRect];
        [self addSubview:pagLabel];
        
        CGRect addressRect = CGRectMake(5, 300, 310, 30);
        addressLabel = [[UILabel alloc] initWithFrame:addressRect];
        [self addSubview:addressLabel];
        
        
        CGRect weatherRect = CGRectMake(5, 334, 150, 25);
        weatherLabel = [[UILabel alloc] initWithFrame:weatherRect];
        [self addSubview:weatherLabel];
        
        CGRect dayTimeRect = CGRectMake(150, 334, 150, 25);
        dayTimeLabel = [[UILabel alloc] initWithFrame:dayTimeRect];
        [self addSubview:dayTimeLabel];
        
        CGRect lineRect = CGRectMake(5, 363, 310, 2);
        lineImageView = [[UIImageView alloc] initWithFrame:lineRect];
        [self addSubview:lineImageView];
        
        CGRect dateLineRect = CGRectMake(5, 370, 150, 25);
        dateTimeLabel = [[UILabel alloc] initWithFrame:dateLineRect];
        [self addSubview:dateTimeLabel];
        
        CGRect bottonRect = CGRectMake(0, 395, 320, 44);
        topView = [[UIView alloc] initWithFrame:bottonRect];
        [self addSubview:topView];
        
        CGRect leftRect = CGRectMake(20, 395, 80, 44);
        leftButton = [[UIButton alloc] initWithFrame:leftRect];
        [self addSubview:leftButton];
        
        CGRect centerRect = CGRectMake(120, 395, 80, 44);
        centerButton = [[UIButton alloc] initWithFrame:centerRect];
        [self addSubview:centerButton];
        
        CGRect rightRect = CGRectMake(220, 395, 80, 44);
        rightButton = [[UIButton alloc] initWithFrame:rightRect];
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
