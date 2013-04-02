//
//  NDMainViewController.h
//  NetDisk
//
//  Created by jiangwei on 12-11-12.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "NDMainCell.h"
#import "NSString+SBJSON.h"
#import "clientlib/SevenCBoxClient.h"
#import "MBProgressHUD.h"
#import "Function.h"
#import "NDSettingViewController.h"
#import "clientlib/Task.h"
#import "ImageShowViewController.h"
#import "NDAppDelegate.h"
#import "ATMHud.h"
#import "NDFmInfoViewController.h"
#import "Item.h"
#import "BIDragRefreshTableView.h"
#import "BIButton.h"
#import "AGImagePickerController.h"
#import "AGIPCToolbarItem.h"
#import "UIRenameViewController.h"

typedef enum{
    PViewController =1,
    PShareViewController,
    PPhotoViewController,
} ParentViewType;

@interface NDMainViewController : UIViewController<UIActionSheetDelegate,UIImagePickerControllerDelegate,UINavigationControllerDelegate,MBProgressHUDDelegate,NDMainCellDelegate,BIDragRefreshTableViewDelegate,UISearchBarDelegate>
{
    SevenCBoxClient scBox;
    CTask *task;
    
    NSString *m_title;
    BIDragRefreshTableView *m_tableView;
    NSArray *m_listArray;
    NSArray *m_listSourceArray;
    
    ParentViewType m_parentType;
    NSString *m_parentFID;
    NSMutableDictionary *m_infoDic;
    
    UIImagePickerController * imagePickerController;
    
    MBProgressHUD *HUD;
    ATMHud *m_hud;
    
    UIButton *m_editButton;
    
    UIView *m_bottomBackView;
    UIView *m_normalView;//上传照片 设置
    UIButton *m_leftButton;
    UIButton *m_rightButton;
    
    UIView *m_pastView;//粘贴 取消
    UIButton *m_pasteButton;
    UIButton *m_cacleButton;

    UIView *m_batchView;//删除 共享 移动
    UIButton *m_deleteButton;
    UIButton *m_shareButton;
    UIButton *m_moveButton;
    
    UISearchDisplayController *searchDC;
    UISearchBar *m_searchBar;
    
    int counts;//记录cell count;
    
    UILabel *m_titleLabel;
    
    int shareRow;
    
    NSMutableArray *_items;//批量选中标识
    int selectdCellCount;//被选中的记录数
    int selectdCellCountOfDirectory;//被选中的文件夹数
    
    UIImageView *m_rightLineImageView;
    
    BIButton *m_backRootButton;
    
    NSMutableArray *selectedPhotos;
    
}
@property (nonatomic,retain) IBOutlet UIButton *m_leftButton;
@property (nonatomic,retain) IBOutlet UIButton *m_rightButton;
@property (nonatomic,retain) IBOutlet UIButton *m_pasteButton;
@property (nonatomic,retain) IBOutlet UIButton *m_cacleButton;
@property (nonatomic,retain) IBOutlet UIButton *m_editButton;
@property (nonatomic,retain) IBOutlet UIButton *m_deleteButton;
@property (nonatomic,retain) IBOutlet UIButton *m_shareButton;
@property (nonatomic,retain) IBOutlet UIButton *m_moveButton;
@property (nonatomic,retain) IBOutlet UIView *m_bottomBackView;
@property (nonatomic,retain) IBOutlet UIView *m_normalView;
@property (nonatomic,retain) IBOutlet UIView *m_pastView;
@property (nonatomic,retain) IBOutlet UIView *m_batchView;
@property (nonatomic,retain) IBOutlet UIImageView *m_rightLineImageView;
@property (nonatomic,retain) IBOutlet BIButton *m_backRootButton;

- (IBAction)uploadFile:(id)sender;
- (IBAction)setting:(id)sender;
- (IBAction)comeBack:(id)sender;
- (IBAction)comeBackToRoot:(id)sender;
- (IBAction)pasteAction:(id)sender;
- (IBAction)cancleAction:(id)sender;
- (IBAction)showFmInfoAction:(id)sender;
- (IBAction)editAction:(id)sender;
- (IBAction)deleteAction:(id)sender;
- (IBAction)shareAction:(id)sender;
- (IBAction)moveAction:(id)sender;

@property (nonatomic,retain) IBOutlet UILabel *m_titleLabel;
@property (nonatomic,assign) ParentViewType m_parentType;
@property (nonatomic,retain) NSString *m_parentFID;
@property (nonatomic,retain) NSString *m_title;
@property (nonatomic,retain) BIDragRefreshTableView *m_tableView;
@property (nonatomic,retain) NSArray *m_listArray;
@property (nonatomic,retain) NSDictionary *m_infoDic;
@property (nonatomic,retain) NSMutableArray *items;
@property (nonatomic,retain) NSMutableArray *selectedPhotos;

- (void)getFileDataFromServer;
- (void)showImagePicker:(BOOL)hasCamera;
- (void)hiddenPasteButton:(BOOL)theBL;
- (void)hiddenBatchButton:(BOOL)theBL;
- (void)setEnableButtons:(int)index;
- (void)disEnableButtons;
- (void)openAction;
@end
