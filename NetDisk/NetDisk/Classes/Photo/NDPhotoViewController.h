//
//  NDPhotoViewController.h
//  NetDisk
//
//  Created by jiangwei on 12-12-10.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "NDMainCell.h"

#import "NSString+SBJSON.h"

#import "clientlib/SevenCBoxClient.h"
#import "MBProgressHUD.h"
#import "Function.h"
#import "BIDragRefreshTableView.h"
#import "BILazyImageView.h"
#import "NDPhotoDetailViewController.h"
#import "ATMHud.h"
#import "NDTaskManagerViewController.h"
#import "NDAppDelegate.h"
#import "NDSettingViewController.h"
@interface NDPhotoViewController : UIViewController<BIDragRefreshTableViewDelegate>
{
    SevenCBoxClient scBox;
    
    BIDragRefreshTableView *m_tableView;
    
    NSArray *m_listArray;
    
    MBProgressHUD *HUD;
    
    ATMHud *m_hud;
}

@property (nonatomic,retain) BIDragRefreshTableView *m_tableView;

- (IBAction)comeBack:(id)sender;
- (IBAction)uploadFile:(id)sender;
- (IBAction)setting:(id)sender;
@end
