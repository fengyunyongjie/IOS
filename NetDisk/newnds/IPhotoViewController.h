//
//  IPhotoViewController.h
//  NetDisk
//
//  Created by Yangsl on 13-8-23.
//
//

#import <UIKit/UIKit.h>
#import "FileTableView.h"
#import "PhotoTableView.h"
#import "QBImageFileViewController.h"
#import "SCBFileManager.h"
#import <MessageUI/MessageUI.h>
#import "QBImagePickerController.h"

@interface IPhotoViewController : UIViewController <FileTableViewDelegate,PhotoTableViewDelegate,QBImageFileViewDelegate,MFMessageComposeViewControllerDelegate,MFMailComposeViewControllerDelegate,UITextFieldDelegate,QBImagePickerControllerDelegate>
{
    UIView *topView;
    BOOL isNeedBackButton;
    BOOL isPhoto;
    
    FileTableView *file_tableView;
    PhotoTableView *photo_tableView;
    
    NSString *f_id;
    
    UIButton *escButton;
    NSString *move_fid;

    UIControl *ctrlView;
    UIView *edit_view;
    UIControl *edit_control;
    UIControl *newFinder_control;
    UITextField *finderName_textField;
    UIButton *Bt_All;
    UILabel *label_all;
    UIControl *space_control;
    NSArray *member_array;
    
    NSString *spaceId;
    int sharedType;
    
    UIImageView *null_imageview; //pop.png
}

@property(nonatomic,retain) UIView *topView;
@property(nonatomic,assign) BOOL isNeedBackButton;
@property(nonatomic,assign) BOOL isPhoto;

@property(nonatomic,retain) FileTableView *file_tableView;
@property(nonatomic,retain) PhotoTableView *photo_tableView;

@property(nonatomic,retain) NSString *f_id;
@property(nonatomic,retain) UIButton *escButton;
@property(nonatomic,retain) NSString *move_fid;

@property(nonatomic,retain) UIControl *ctrlView;

@property(nonatomic,retain) UIView *edit_view;
@property(nonatomic,retain) UIControl *edit_control;
@property(nonatomic,retain) UIControl *newFinder_control;
@property(nonatomic,retain) UITextField *finderName_textField;
@property(nonatomic,retain) UIButton *Bt_All;
@property(nonatomic,retain) UILabel *label_all;
@property(nonatomic,retain) UIControl *space_control;
@property(nonatomic,retain) NSArray *member_array;
@property(nonatomic,assign) int sharedType;
@property(nonatomic,retain) UIImageView *null_imageview;

//显示文件列表
-(void)showFileList;
//显示照片列表
-(void)showPhotoList;
//点击照片内容
-(void)clicked_photo:(id)sender;
//点击文件内容
-(void)clicked_file:(id)sender;

@end
