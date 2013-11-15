//
//  PhotoScrollView.m
//  NetDisk
//
//  Created by Yangsl on 13-11-13.
//
//

#import "PhotoScrollView.h"

@implementation PhotoScrollView
@synthesize bookImageView,delegate;

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        self.alpha = 0.8;
        CGRect bookRect = CGRectMake(0, 0, 35, 25);
        self.bookImageView = [[UIImageView alloc] initWithFrame:bookRect];
        [self.bookImageView setImage:[UIImage imageNamed:@"btn_updown_on.png"]];
        [self addSubview:self.bookImageView];
    }
    return self;
}

-(void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{
    UITouch *touch = [touches anyObject];
    CGPoint point = [touch locationInView:self];
    [delegate updateScrollView:point];
    if(point.y<0)
    {
        point.y = 0;
    }
    if(point.y>self.frame.size.height-20)
    {
        point.y = self.frame.size.height-20;
    }
    
    [UIView animateWithDuration:0.2 animations:^{
        CGRect bookRect = CGRectMake(0, point.y, 30, 25);
        [self.bookImageView setFrame:bookRect];
    }];
}

-(void)touchesMoved:(NSSet *)touches withEvent:(UIEvent *)event
{
    UITouch *touch = [touches anyObject];
    CGPoint point = [touch locationInView:self];
    [delegate updateScrollView:point];
    if(point.y<0)
    {
        point.y = 0;
    }
    if(point.y>self.frame.size.height-25)
    {
        point.y = self.frame.size.height-25;
    }
    
    [UIView animateWithDuration:0.2 animations:^{
        CGRect bookRect = CGRectMake(0, point.y, 30, 25);
        [self.bookImageView setFrame:bookRect];
    }];
}

-(void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event
{
    UITouch *touch = [touches anyObject];
    CGPoint point = [touch locationInView:self];
    [delegate updateScrollView:point];
    if(point.y<0)
    {
        point.y = 0;
    }
    if(point.y>self.frame.size.height-25)
    {
        point.y = self.frame.size.height-25;
    }
    
    [UIView animateWithDuration:0.2 animations:^{
        CGRect bookRect = CGRectMake(0, point.y, 30, 25);
        [self.bookImageView setFrame:bookRect];
    }];
}

-(void)updateScrollView:(float)height
{
    if(height<0)
    {
        height = 0;
    }
    if(height>self.frame.size.height-25)
    {
        height = self.frame.size.height-25;
    }
    
    [UIView animateWithDuration:0.2 animations:^{
        CGRect bookRect = CGRectMake(0, height, 30, 25);
        [self.bookImageView setFrame:bookRect];
    }];
}

@end
