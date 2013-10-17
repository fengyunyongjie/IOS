//
//  UploadViewCell.h
//  NetDisk
//
//  Created by Yangsl on 13-7-26.
//
//

#import <UIKit/UIKit.h>

//引用类
#import "CustomJinDu.h"
#import "UpLoadList.h"
#import "DownList.h"

@protocol UploadViewCellDelegate <NSObject>

-(void)deletCell:(NSObject *)object;

@end

@interface UploadViewCell : UITableViewCell
{
    UIImageView *imageView;
    UILabel *label_name;
    UIButton *button_dele_button;
    CustomJinDu *jinDuView;
    id<UploadViewCellDelegate> delegate;
    UILabel *size_label;
    UILabel *sudu_label;
    UIButton *button_start_button;
    UpLoadList *upload_list;
    DownList *down_list;
}

@property(nonatomic,retain) UIImageView *imageView;
@property(nonatomic,retain) UILabel *label_name;
@property(nonatomic,retain) UIButton *button_dele_button;
@property(nonatomic,retain) CustomJinDu *jinDuView;
@property(nonatomic,retain) id<UploadViewCellDelegate> delegate;
@property(nonatomic,retain) UILabel *size_label;
@property(nonatomic,retain) UILabel *sudu_label;
@property(nonatomic,retain) UIButton *button_start_button;
@property(nonatomic,retain) DownList *down_list;

-(void)setUploadDemo:(UpLoadList *)list;
-(void)setDownDemo:(DownList *)list;
-(void)showTopBar;
-(void)showEdit:(BOOL)bl;

@end

