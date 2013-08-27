//
//  FileTableViewCell.m
//  NetDisk
//
//  Created by Yangsl on 13-8-26.
//
//

#import "FileTableViewCell.h"
#define CheckButtonColor [UIColor colorWithRed:223.0/255.0 green:230.0/255.0 blue:250.0/255.0 alpha:1.0]

@implementation FileTableViewCell
@synthesize select_button;
@synthesize image_view;

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        
    }
    CGRect background_rect = CGRectMake(0, 0, self.frame.size.width, 50);
    image_view = [[UIImageView alloc] initWithFrame:background_rect];
    [image_view setBackgroundColor:CheckButtonColor];
    [self addSubview:image_view];
    [self sendSubviewToBack:image_view];
    image_view.hidden = YES;
    
    CGRect rect = CGRectMake(10, 10, 30, 30);
    select_button = [[UIButton alloc] initWithFrame:rect];
    [select_button setImage:[UIImage imageNamed:@"Unselected.png"] forState:UIControlStateNormal];
    CGRect select_rect = CGRectMake(0, 0, self.frame.size.width, self.frame.size.height);
    self.selectedBackgroundView = [[UIView alloc] initWithFrame:select_rect];
    self.selectedBackgroundView.backgroundColor =  CheckButtonColor;
    [self addSubview:select_button];
    select_button.hidden = YES;
    
    return self;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];
}

-(void)dealloc
{
    [select_button release];
    [image_view release];
    [super dealloc];
}

@end
