//
//  NDViewController.h
//  NetDisk
//
//  Created by jiangwei on 12-11-12.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "NDMainCell.h"
#import "NDShareViewController.h"
#import "NDKeepViewController.h"
#import "NDMainViewController.h"
#import "ImageShowViewController.h"
#import "NDSettingViewController.h"
#import "NDActivityViewController.h"
#import "NDLoginViewController.h"
#import "NDPhotoViewController.h"
#import "NDFmInfoViewController.h"

#import "NSString+SBJSON.h"
#import "clientlib/SevenCBoxClient.h"
#import "MBProgressHUD.h"
#import "Function.h"
#import "clientlib/Task.h"
#import "ATMHud.h"
#import "NDAppDelegate.h"
#import "BIDragRefreshTableView.h"
/*
 #ifndef __OPTIMIZE__
 # define NSLog(...) NSLog(__VA_ARGS__)
 #else
 # define NSLog(...) {}
 #endif
 */

@interface NDViewController : UIViewController<UIActionSheetDelegate,UIImagePickerControllerDelegate,UINavigationControllerDelegate,MBProgressHUDDelegate,NDMainCellDelegate,NDLoginViewControllerDelegate,UISearchBarDelegate,BIDragRefreshTableViewDelegate>
{
    SevenCBoxClient scBox;
    CTask *task;
    
    BIDragRefreshTableView *m_tableView;
    NSArray *m_listArray;
    
    UIImagePickerController * imagePickerController;
    
    MBProgressHUD *HUD;
    ATMHud *m_hud;
    
    int counts;
    
    UILabel *m_storeLabel;
    UILabel *m_titleLabel;
    
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
    
    int shareRow;
    
    UISearchBar *m_searchBar;
    NSArray *m_listSourceArray;
    
    NSMutableArray *_items;//批量选中标识
    int selectdCellCount;//被选中的记录数
    int selectdCellCountOfDirectory;//被选中的文件夹数
}
@property (nonatomic,retain) IBOutlet UIButton *m_editButton;
@property (nonatomic,retain) IBOutlet UIView *m_bottomBackView;
@property (nonatomic,retain) IBOutlet UIView *m_normalView;
@property (nonatomic,retain) IBOutlet UIView *m_pastView;
@property (nonatomic,retain) IBOutlet UIView *m_batchView;
@property (nonatomic,retain) IBOutlet BIDragRefreshTableView *m_tableView;
@property (nonatomic,retain) IBOutlet UILabel *m_titleLabel;
@property (nonatomic,retain) IBOutlet UILabel *m_storeLabel;
@property (nonatomic,retain) IBOutlet UIButton *m_leftButton;
@property (nonatomic,retain) IBOutlet UIButton *m_rightButton;
@property (nonatomic,retain) IBOutlet UIButton *m_pasteButton;
@property (nonatomic,retain) IBOutlet UIButton *m_cacleButton;
@property (nonatomic,retain) IBOutlet UIButton *m_deleteButton;
@property (nonatomic,retain) IBOutlet UIButton *m_shareButton;
@property (nonatomic,retain) IBOutlet UIButton *m_moveButton;

@property (nonatomic,retain ) NSMutableArray *items;

- (IBAction)aboutMsg:(id)sender;
- (IBAction)frientMsg:(id)sender;
- (IBAction)uploadFile:(id)sender;
- (IBAction)setting:(id)sender;
- (IBAction)pasteAction:(id)sender;
- (IBAction)cancleAction:(id)sender;
- (IBAction)editAction:(id)sender;
- (IBAction)deleteAction:(id)sender;
- (IBAction)shareAction:(id)sender;
- (IBAction)moveAction:(id)sender;

- (NSArray *)sortList:(NSArray *)sourceArray;

- (void)showImagePicker:(BOOL)hasCamera;
- (void)hiddenPasteButton:(BOOL)theBL;
- (void)disEnableButtons;
- (void)showFmInfoAction;
@end
