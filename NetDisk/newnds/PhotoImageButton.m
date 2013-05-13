//
//  PhotoImageButton.m
//  NetDisk
//
//  Created by Yangsl on 13-5-8.
//
//

#import "PhotoImageButton.h"

@implementation PhotoImageButton
@synthesize timeLine,timeIndex,demo,isShowImage;

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
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
    [timeLine release];
    [demo release];
    [super dealloc];
}

@end
