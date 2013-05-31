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
    [cellArray release];
    [super dealloc];
}

@end
