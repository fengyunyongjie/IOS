//
//  CustomScrollView.m
//  NetDisk
//
//  Created by Yangsl on 13-11-11.
//
//

#import "CustomScrollView.h"

@implementation CustomScrollView
@synthesize scrollViewSize,moveLabel,back_image;

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        back_image = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, 50, 50)];
    }
    return self;
}

@end
