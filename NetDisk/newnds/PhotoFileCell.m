//
//  PhotoFileCell.m
//  NetDisk
//
//  Created by Yangsl on 13-5-31.
//
//

#import "PhotoFileCell.h"

@implementation PhotoFileCell
@synthesize cellArray;

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        // Initialization code
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
    for(int i=0;i<[self.contentView.subviews count];i++)
    {
        UIView *view = [self.contentView.subviews objectAtIndex:i];
        view = nil;
    }
    NSLog(@"PhotoFileCell类已死");
    
    [cellArray release];
    [super dealloc];
}

@end
