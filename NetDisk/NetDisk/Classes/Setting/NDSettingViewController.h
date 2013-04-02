//
//  NDSettingViewController.h
//  NetDisk
//
//  Created by jiangwei on 12-11-12.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "NSString+SBJSON.h"
#import "clientlib/SevenCBoxClient.h"
#import "ATMHud.h"
#import "Function.h"
#import "NDTaskManagerViewController.h"
#import "NDAppDelegate.h"
@interface NDSettingViewController : UIViewController
{
    SevenCBoxClient scBox;
    
    UITableView *m_tableView;
    UIButton *m_exitButton;
    NSString *m_storeStr;
    
    ATMHud *m_hud;
}
- (IBAction)comeBack:(id)sender;
@property (nonatomic,retain) IBOutlet UITableView *m_tableView;
@property (nonatomic,retain) IBOutlet UIButton *m_exitButton;
- (void)clearCache;
@end
