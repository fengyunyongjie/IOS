//
//  NDFmInfoViewController.h
//  NetDisk
//
//  Created by jiangwei on 13-1-15.
//  Copyright (c) 2013年 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "UIRenameViewController.h"
#import "Function.h"
@interface NDFmInfoViewController : UIViewController
{
    UITableView *m_tableView;
    NSMutableDictionary *m_myInfoDic;
}
@property (nonatomic,retain) IBOutlet UITableView *m_tableView;
@property (nonatomic,retain) NSMutableDictionary *m_myInfoDic;
- (IBAction)comeBack:(id)sender;
@end
