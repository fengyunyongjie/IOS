//
//  NDShareViewController.h
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
#import "NDMainViewController.h"

@interface NDShareViewController : UIViewController
{
    SevenCBoxClient scBox;
    
    UITableView *m_tableView;
    
    NSArray *m_listArray;
    
    MBProgressHUD *HUD;
    
    NDMainViewController *subFolderView;
}
@property (nonatomic,retain) IBOutlet UITableView *m_tableView;
@property (nonatomic,retain) NSArray *m_listArray;
@end
