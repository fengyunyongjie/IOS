//
//  UploadViewCell.h
//  NetDisk
//
//  Created by Yangsl on 13-7-26.
//
//

#import <UIKit/UIKit.h>

//引用类
#import "TaskDemo.h"
#import "CustomJinDu.h"
#import "UpLoadList.h"

@protocol UploadViewCellDelegate <NSObject>

-(void)deletCell:(int)index;

@end

@interface UploadViewCell : UITableViewCell
{
    UIImageView *imageView;
    UILabel *label_name;
    UIButton *button_dele_button;
    TaskDemo *demo;
    CustomJinDu *jinDuView;
    id<UploadViewCellDelegate> delegate;
    UIButton *button_start_button;
}

@property(nonatomic,retain) UIImageView *imageView;
@property(nonatomic,retain) UILabel *label_name;
@property(nonatomic,retain) UIButton *button_dele_button;
@property(nonatomic,retain) TaskDemo *demo;
@property(nonatomic,retain) CustomJinDu *jinDuView;
@property(nonatomic,retain) id<UploadViewCellDelegate> delegate;
@property(nonatomic,retain) UIButton *button_start_button;

-(void)setUploadDemo:(UpLoadList *)list;
-(void)showTopBar;

@end

