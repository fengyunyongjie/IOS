//
//  SelectFileListViewController.h
//  ndspro
//
//  Created by fengyongning on 13-10-8.
//  Copyright (c) 2013年 fengyongning. All rights reserved.
//
// 移动选择、转存选择、提交选择、上传选择
#import <UIKit/UIKit.h>
#import "FileListViewController.h"
//@class FileListViewController;
typedef enum {
    kSelectTypeDefault,
    kSelectTypeMove,
    kSelectTypeResave,
    kSelectTypeCommit,
} SelectType;
@interface SelectFileListViewController : UIViewController<UITableViewDataSource,UITableViewDelegate>
@property (strong,nonatomic) NSArray *targetsArray;
@property (strong,nonatomic) NSDictionary *dataDic;
@property (strong,nonatomic) NSArray *listArray;
@property (strong,nonatomic) NSArray *finderArray;
@property (strong,nonatomic) NSString *f_id;
@property (strong,nonatomic) NSString *spid;
@property (strong,nonatomic) NSString *roletype;
@property (strong,nonatomic) NSMutableDictionary *imageDownloadsInProgress;
@property (strong,nonatomic) UITableView *tableView;
@property (strong,nonatomic) NSIndexPath *selectedIndexPath;
@property (strong,nonatomic) UIToolbar *toolbar;
@property (weak,nonatomic) FileListViewController *delegate;
@property (assign,nonatomic) SelectType type;
@end
