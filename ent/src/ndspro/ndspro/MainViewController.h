//
//  MainViewController.h
//  ndspro
//
//  Created by fengyongning on 13-9-26.
//  Copyright (c) 2013年 fengyongning. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "FileListViewController.h"
#import "EGORefreshTableHeaderView.h"
typedef enum {
    kTypeDefault,
    kTypeCommit,
    kTypeResave,
} MainType;
@interface MainViewController : UIViewController<EGORefreshTableHeaderDelegate,UITableViewDataSource,UITableViewDelegate>
{
    EGORefreshTableHeaderView *_refreshHeaderView;
    BOOL _reloading;
}
@property(strong,nonatomic) NSArray *listArray;
@property(strong,nonatomic) UITableView *tableView;
@property(weak,nonatomic) FileListViewController *delegate;
@property(assign,nonatomic) MainType type;
@end
