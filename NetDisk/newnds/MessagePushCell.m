//
//  MessagePushCell.m
//  NetDisk
//
//  Created by Yangsl on 13-8-5.
//
//

#import "MessagePushCell.h"
#define navbarWidth 200
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
        
    }
    return self;
}


-(void)setUpdate:(NSString *)title timeString:(NSString *)timeString msg_type:(NSString *)msg_type msg_sender_remark:(NSString *)msg_sender_remark
{
    int type = [msg_type intValue];
    switch (type) {
        case 1:
            title = [NSString stringWithFormat:AddFirendToMe,msg_sender_remark];
            break;
        case 2:
            title = [NSString stringWithFormat:AddFirendToOther];
            break;
        case 3:
            title = [NSString stringWithFormat:AddFamilyToMe,msg_sender_remark];
            break;
        case 4:
            title = [NSString stringWithFormat:AddFirendToSelf,msg_sender_remark,title];
            break;
        case 5:
            title = [NSString stringWithFormat:AddShared,msg_sender_remark,title];
            break;
        case 6:
            title = [NSString stringWithFormat:GetOutShared,msg_sender_remark,title];
            break;
        case 7:
            title = [NSString stringWithFormat:EscShared,msg_sender_remark,title];
            break;
        case 8:
            title = [NSString stringWithFormat:AccoutSelfEsc,msg_sender_remark,title];
            break;
        case 9:
            title = [NSString stringWithFormat:UpdateNameShared,msg_sender_remark,title,title];
            break;
        case 10:
            title = [NSString stringWithFormat:DeleteFile,msg_sender_remark,title];
            break;
        case 11:
            title = [NSString stringWithFormat:NewFlod,msg_sender_remark,title,title];
            break;
        case 12:
            title = [NSString stringWithFormat:NewAdd,msg_sender_remark,title];
            break;
        default:
            break;
    }
    
    [title_label setText:title];
    [time_label setText:timeString];
    //文字换行
    title_label.numberOfLines=0;
    CGSize size = [title_label sizeThatFits:CGSizeMake(150, 0)];//假定label_1设置的固定宽度为100，自适应高
    [title_label.text sizeWithFont:title_label.font
          constrainedToSize:size
              lineBreakMode:UILineBreakModeWordWrap];  //这句加上才能自适应
    NSLog(@"字符在宽度不变，自适应高：%f",size.height);
    CGRect rct = title_label.frame;
    if(size.height>time_label.frame.origin.y)
    {
        size.height = time_label.frame.origin.y-3;
    }
    rct.size.height=size.height;
    title_label.frame = rct;    //把得到的高赋给label_1
}

-(void)firstLoad:(CGFloat)height
{
    back_image = [[UIImageView alloc] initWithFrame:self.bounds];
    [self addSubview:back_image];
    
    CGRect title_rect = CGRectMake(boderWidth, 5, navbarWidth-boderWidth, 22);
    title_label = [[UILabel alloc] initWithFrame:title_rect];
    [title_label setTextColor:[UIColor blackColor]];
    [title_label setBackgroundColor:[UIColor clearColor]];
    [title_label setFont:[UIFont systemFontOfSize:16]];
    [self addSubview:title_label];
    
    CGRect time_rect = CGRectMake(boderWidth, height-27, navbarWidth-boderWidth, 22);
    time_label = [[UILabel alloc] initWithFrame:time_rect];
    [time_label setTextColor:[UIColor colorWithRed:128.0/255.0 green:128.0/255.0 blue:128.0/255.0 alpha:1]];
    [time_label setBackgroundColor:[UIColor clearColor]];
    [time_label setFont:[UIFont systemFontOfSize:12]];
    [self addSubview:time_label];
    
    CGRect accept_rect = CGRectMake(320-boderWidth-105, (height-22)/2, 50, 22);
    accept_button = [[UIButton alloc] initWithFrame:accept_rect];
    [accept_button setBackgroundImage:[UIImage imageNamed:@"Bt_NewsAccept.png"] forState:UIControlStateNormal];
    [accept_button setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [accept_button setTitle:@"接受" forState:UIControlStateNormal];
    [self addSubview:accept_button];
    
    CGRect refused_rect = CGRectMake(320-boderWidth-50, (height-22)/2, 50, 22);
    refused_button = [[UIButton alloc] initWithFrame:refused_rect];
    [refused_button setBackgroundImage:[UIImage imageNamed:@"Bt_NewsRefuse.png"] forState:UIControlStateNormal];
    [refused_button setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [refused_button setTitle:@"拒绝" forState:UIControlStateNormal];
    [self addSubview:refused_button];
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
