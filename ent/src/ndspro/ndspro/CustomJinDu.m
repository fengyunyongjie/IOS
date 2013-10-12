//
//  CustomJinDu.m
//  NetDisk
//
//  Created by Yangsl on 13-7-30.
//
//

#import "CustomJinDu.h"

#import <QuartzCore/QuartzCore.h>

@implementation CustomJinDu
@synthesize backColor,currColor,currFloat,customSize;

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        CGRect backLabelRect = CGRectMake(0, 0, frame.size.width, frame.size.height);
        backLabel = [[UILabel alloc] initWithFrame:backLabelRect];
        backLabel.layer.borderWidth = 0.5;
        backLabel.layer.borderColor = [[UIColor blackColor] CGColor];
        [backLabel setTextColor:[UIColor colorWithRed:180.0/255.0 green:181.0/255.0 blue:181.0/255.0 alpha:1]];
        [backLabel setFont:[UIFont systemFontOfSize:12]];
        CGRect currLabelRect = CGRectMake(0.1f, 0.1f, 0, frame.size.height-0.2f);
        [self addSubview:backLabel];
        
        currLabel = [[UILabel alloc] initWithFrame:currLabelRect];
        [self addSubview:currLabel];
        [self setBackColor:[UIColor whiteColor]];
        [self setCurrColor:[UIColor colorWithRed:0.0/255.0 green:160.0/255.0 blue:230.0/255.0 alpha:1]];
    }
    return self;
}


-(void)setBackColor:(UIColor *)backColor_
{
    [backLabel setBackgroundColor:backColor_];
}

-(void)setCurrColor:(UIColor *)currColor_
{
    [currLabel setBackgroundColor:currColor_];
}

-(void)setCurrFloat:(float)currFloat_
{
    CGRect backLabelRect = CGRectMake(0, 0, self.frame.size.width, self.frame.size.height);
    [backLabel setFrame:backLabelRect];
    [backLabel setHidden:NO];
    [backLabel setText:nil];
    backLabel.layer.borderWidth = 0.5;
    backLabel.layer.borderColor = [[UIColor blackColor] CGColor];
    [currLabel setHidden:NO];
    float width = currFloat_*self.frame.size.width-0.2;
    if(width>(self.frame.size.width-0.2))
    {
        width = self.frame.size.width-0.2;
    }
    CGRect currLabelRect = CGRectMake(0.1f, 0.1f, width, self.frame.size.height-0.2);
    [currLabel setFrame:currLabelRect];
}

-(void)showText:(NSString *)text
{
    [currLabel setHidden:YES];
    [backLabel setFont:[UIFont systemFontOfSize:12]];
    [backLabel setText:text];
    [backLabel setBackgroundColor:[UIColor clearColor]];
    CGRect backLabelRect = CGRectMake(0, -5, self.frame.size.width, 20);
    [backLabel setFrame:backLabelRect];
    [backLabel.layer setBorderWidth:0];
}

-(void)showDate:(NSString *)date
{
    [currLabel setHidden:YES];
    [backLabel setFont:[UIFont systemFontOfSize:11]];
    [backLabel setText:date];
    [backLabel setBackgroundColor:[UIColor clearColor]];
    CGRect backLabelRect = CGRectMake(0, -5, self.frame.size.width, 20);
    [backLabel setFrame:backLabelRect];
    [backLabel.layer setBorderWidth:0];
}

@end
