//
//  MessagePushCell.h
//  NetDisk
//
//  Created by Yangsl on 13-8-5.
//
//
#define navbarWidth 200
#define boderWidth 10
#import <UIKit/UIKit.h>
#define AddFirendToMe @"%@添加您为好友" //添加好友消息
#define AddFirendToOther @"添加对方为好友" //添加好友消息
#define AddFamilyToMe @"%@邀请添加%@为家庭空间成员" //添加家庭成员
#define AddFirendToSelf @"%@对你说：\"%@\"" //好友私信
#define AddShared @"%@邀请你加入\"%@\"共享文件夹" //邀请加入共享
#define GetOutShared @"%@将你从共享文件夹\"%@\"中移除" //踢出共享用户
#define EscShared @"%@取消了\"%@\"的共享" //取消共享文件夹
#define AccoutSelfEsc @"%@退出了\"%@\"共享文件夹" //用户主动退出共享文件夹
#define UpdateNameShared @"%@将\"%@\"更改为\"%@\"" //共享文件夹重命名
#define UploadFile @"%@上传文件\"%@\"至\"%@\"" //上传文件
#define DeleteFile @"%@删除了文件\"%@\"" //删除文件
#define NewFlod @"%@新建了文件夹\"%@\"至\"%@\"" //新建文件夹
#define NewAdd @"%@在\"%@\"中加入了新内容" //新加图片和视频

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

-(void)setUpdate:(NSString *)title timeString:(NSString *)timeString msg_type:(NSString *)msg_type msg_sender_remark:(NSString *)msg_sender_remark msg_sort:(NSString *)msg_sort;
-(void)firstLoad:(CGFloat)height;

@end
