//
//  NDActivityViewController.h
//  NetDisk
//
//  Created by jiangwei on 12-11-12.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "NDActivityCell.h"
#import "BIDragRefreshTableView.h"
@interface NDActivityViewController : UIViewController<BIDragRefreshTableViewDelegate>
{
    BIDragRefreshTableView *m_tableView;
    int i;
}
@property (nonatomic,retain) IBOutlet BIDragRefreshTableView *m_tableView;
@end
