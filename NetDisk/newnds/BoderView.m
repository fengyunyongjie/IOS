//
//  BoderView.m
//  NetDisk
//
//  Created by Yangsl on 13-7-1.
//
//

#import "BoderView.h"
#import <QuartzCore/QuartzCore.h>

@implementation BoderView
@synthesize boderImageView,boderView;

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        self.boderView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, frame.size.width, frame.size.height)];
        self.boderView.layer.borderWidth = 1.5;
        self.boderView.layer.borderColor = [[UIColor colorWithRed:149.0/255.0 green:149.0/255.0 blue:149.0/255.0 alpha:1] CGColor];
//        [self.boderView.layer setShadowOffset:CGSizeMake(10, 10)];
//        [self.boderView.layer setShadowRadius:6];
//        [self.boderView.layer setShadowOpacity:1];
//        [self.boderView.layer setShadowColor:[UIColor grayColor].CGColor];
        
        
        [self addSubview:self.boderView];
        
        self.boderImageView = [[UIImageView alloc] initWithFrame:CGRectMake(5, 5, frame.size.width-10, frame.size.height-10)];
        boderImageView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, frame.size.width, frame.size.height)];
        boderImageView.layer.borderWidth = 1.5;
        boderImageView.layer.borderColor = [[UIColor colorWithRed:170.0/255.0 green:170.0/255.0 blue:170.0/255.0 alpha:1] CGColor];
        [self addSubview:boderImageView];
    }
    return self;
}

-(void)setFrame:(CGRect)frame
{
    [self.boderView setFrame:CGRectMake(0, 0, frame.size.width, frame.size.height)];
    [self.boderImageView setFrame:CGRectMake(10, 10, frame.size.width-20, frame.size.height-20)];
    [super setFrame:frame];
}

-(void)dealloc
{
    [boderImageView release];
    [super dealloc];
}

@end
