//
//  MessagePushCell.m
//  NetDisk
//
//  Created by Yangsl on 13-8-5.
//
//

#import "MessagePushCell.h"
#define currHeihgt self.frame.size.height
#define navbarWidth 160
#define boderWidth 10

@implementation MessagePushCell
@synthesize back_image;
@synthesize title_label;
@synthesize time_label;
@synthesize accept_button;
@synthesize refused_button;

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        back_image = [[UIImageView alloc] initWithFrame:self.bounds];
        [self addSubview:back_image];
        
        CGRect title_rect = CGRectMake(boderWidth, 3, navbarWidth-boderWidth, 22);
        title_label = [[UILabel alloc] initWithFrame:title_rect];
        [title_label setTextColor:[UIColor blackColor]];
        [title_label setBackgroundColor:[UIColor clearColor]];
        [self addSubview:title_label];
        
        CGRect time_rect = CGRectMake(boderWidth, 3, navbarWidth-boderWidth, 22);
        time_label = [[UILabel alloc] initWithFrame:time_rect];
        [time_label setTextColor:[UIColor blackColor]];
        [time_label setBackgroundColor:[UIColor clearColor]];
        [self addSubview:time_label];
        
        CGRect accept_rect = CGRectMake(320-boderWidth-5-100, 3, 50, 22);
        accept_button = [[UIButton alloc] initWithFrame:accept_rect];
        [accept_button setBackgroundImage:[UIImage imageNamed:@"Bt_NewsAccept.png"] forState:UIControlStateNormal];
        [self addSubview:accept_button];
        
        CGRect refused_rect = CGRectMake(320-boderWidth-5-50, 3, 50, 22);
        refused_button = [[UIButton alloc] initWithFrame:refused_rect];
        [refused_button setBackgroundImage:[UIImage imageNamed:@"Bt_NewsRefuse.png"] forState:UIControlStateNormal];
        [self addSubview:refused_button];
    }
    return self;
}


-(void)setUpdate:(NSString *)title timeString:(NSString *)timeString
{
    [title_label setText:title];
    [time_label setText:timeString];
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

-(void)dealloc
{
    [back_image release];
    [title_label release];
    [time_label release];
    [accept_button release];
    [refused_button release];
    [super dealloc];
}

@end
