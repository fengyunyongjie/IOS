//
//  MessagePushCell.h
//  NetDisk
//
//  Created by Yangsl on 13-8-5.
//
//

#import <UIKit/UIKit.h>

@interface MessagePushCell : UITableViewCell
{
    UIImageView *back_image;
    UILabel *title_label;
    UILabel *time_label;
    UIButton *accept_button;
    UIButton *refused_button;
}

@property(nonatomic,retain) UIImageView *back_image;
@property(nonatomic,retain) UILabel *title_label;
@property(nonatomic,retain) UILabel *time_label;
@property(nonatomic,retain) UIButton *accept_button;
@property(nonatomic,retain) UIButton *refused_button;

@end
