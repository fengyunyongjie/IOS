//
//  UploadViewCell.m
//  NetDisk
//
//  Created by Yangsl on 13-7-26.
//
//

#import "UploadViewCell.h"

@implementation UploadViewCell
@synthesize demo,button_dele_button,imageView,progressView,contentView,label_name;
@synthesize delegate;

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        CGRect image_rect = CGRectMake(5, 5, 40, 40);
        self.imageView = [[UIImageView alloc] initWithFrame:image_rect];
        [self addSubview:self.imageView];
        
        CGRect label_rect = CGRectMake(60, 2, 200, 20);
        self.label_name = [[UILabel alloc] initWithFrame:label_rect];
        [self.label_name setTextColor:[UIColor blackColor]];
        [self.label_name setBackgroundColor:[UIColor clearColor]];
        [self addSubview:self.label_name];
        
        CGRect progress_rect = CGRectMake(60, 30, 200, 1);
        self.progressView = [[UIProgressView alloc] initWithFrame:progress_rect];
        [self addSubview:self.progressView];
        
        CGRect button_rect = CGRectMake(270, 10, 30, 30);
        self.button_dele_button = [[UIButton alloc] initWithFrame:button_rect];
        [self.button_dele_button setBackgroundImage:[UIImage imageNamed:@"Bt_Cancle.png"] forState:UIControlStateNormal];
        [self.button_dele_button addTarget:self action:@selector(deleteSelf) forControlEvents:UIControlEventTouchUpInside];
        [self addSubview:self.button_dele_button];
    }
    return self;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];
    // Configure the view for the selected state
}

-(void)setUploadDemo:(TaskDemo *)demo_
{
    self.demo = demo_;
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 0), ^{
        [self.imageView setImage:[UIImage imageWithData:self.demo.f_data]];
    });
    if(demo.f_state == 1)
    {
        [self.progressView setProgress:1];
    }
    else
    {
        [self.progressView setProgress:demo.proess];
    }
    
    [self.label_name setText:self.demo.f_base_name];
}

-(void)deleteSelf
{
    [delegate deletCell:self];
}

@end
