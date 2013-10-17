//
//  FileListViewController.h
//  ndspro
//
//  Created by fengyongning on 13-9-26.
//  Copyright (c) 2013年 fengyongning. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "QBImagePickerController.h"
#import "EGORefreshTableHeaderView.h"

typedef enum {
    kMyndsTypeDefault,
    kMyndsTypeSelect,
    kMyndsTypeMyShareSelect,
    kMyndsTypeShareSelect,
    kMyndsTypeMyShare,
    kMyndsTypeShare,
    kMyndsTypeDefaultSearch,
    kMyndsTypeMyShareSearch,
    kMyndsTypeShareSearch,
} FileListType;
@interface FileListViewController : UIViewController<EGORefreshTableHeaderDelegate,UITableViewDataSource,UITableViewDelegate,QBImagePickerControllerDelegate>
{
    EGORefreshTableHeaderView *_refreshHeaderView;
    BOOL _reloading;
}
@property (strong,nonatomic) NSDictionary *dataDic;
@property (strong,nonatomic) NSArray *listArray;
@property (strong,nonatomic) NSArray *finderArray;
@property (strong,nonatomic) NSArray *selectArray;
@property (strong,nonatomic) NSString *f_id;
@property (strong,nonatomic) NSString *spid;
@property (strong,nonatomic) NSString *roletype;
@property (assign,nonatomic) FileListType flType;
@property (strong,nonatomic) NSMutableDictionary *imageDownloadsInProgress;
@property (strong,nonatomic) UITableView *tableView;
@property (strong,nonatomic) NSIndexPath *selectedIndexPath;
-(void)moveFileToID:(NSString *)f_id;
-(void)commitFileToID:(NSString *)f_id sID:(NSString *)s_pid;
-(void)resaveFileToID:(NSString *)f_id;
@end
