//
//  NDPhotoDetailViewController.h
//  NetDisk
//
//  Created by jiangwei on 13-1-26.
//  Copyright (c) 2013年 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "NDMainCell.h"

#import "NSString+SBJSON.h"
#import "ATMHud.h"
#import "clientlib/SevenCBoxClient.h"
#import "MBProgressHUD.h"
#import "Function.h"
#import "BIDragRefreshTableView.h"
#import "BILazyImageView.h"
#import "ImageShowViewController.h"
#import "NDTaskManagerViewController.h"
#import "NDAppDelegate.h"
#import "NDSettingViewController.h"
#define GET_COUNT 30
@interface NDPhotoDetailViewController : UIViewController<BIDragRefreshTableViewDelegate,BILazyImageViewDelegate,UIActionSheetDelegate>
{
    SevenCBoxClient scBox;

    BIDragRefreshTableView *m_tableView;

    NSMutableArray *m_listArray;

    MBProgressHUD *HUD;

    NSString *m_timeLine;
    NSDictionary *m_selectedImageDic;
    
    ATMHud *m_hud;
    
    UILabel *m_titleLabel;
    NSString *m_title;
    
    int tableTag;
    UIView *m_bottomView;
}

@property (nonatomic,retain) BIDragRefreshTableView *m_tableView;
@property (nonatomic,retain) NSString *m_timeLine;
@property (nonatomic,retain) IBOutlet UILabel *m_titleLabel;
@property (nonatomic,retain) IBOutlet UIView *m_bottomView;

@property (nonatomic,retain) NSString *m_title;
- (IBAction)comeBack:(id)sender;
- (IBAction)refresh:(id)sender;

- (BOOL)isDownloadedImage:(NSString *)theImageName;

- (IBAction)uploadFile:(id)sender;
- (IBAction)setting:(id)sender;
@end
