//
//  PhotoCell.m
//  NetDisk
//
//  Created by Yangsl on 13-5-13.
//
//

#import "PhotoCell.h"

@implementation PhotoCell
@synthesize imageViewButton1,imageViewButton2,imageViewButton3,imageViewButton4;

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        CGRect backRect = CGRectMake(4, 4, 75, 75);
        imageViewButton1 = [[PhotoImageButton alloc] initWithFrame:backRect];
        backRect.origin.x += 79;
        [self addSubview:imageViewButton1];
        imageViewButton2 = [[PhotoImageButton alloc] initWithFrame:backRect];
        [self addSubview:imageViewButton2];
        backRect.origin.x += 79;
        imageViewButton3 = [[PhotoImageButton alloc] initWithFrame:backRect];
        [self addSubview:imageViewButton3];
        backRect.origin.x += 79;
        imageViewButton4 = [[PhotoImageButton alloc] initWithFrame:backRect];
        [self addSubview:imageViewButton4];
    }
    return self;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

-(void)dealloc
{
    [imageViewButton1 release];
    [imageViewButton2 release];
    [imageViewButton3 release];
    [imageViewButton4 release];
    [super dealloc];
}

@end
