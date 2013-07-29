//
//  ChangeUploadViewController.h
//  NetDisk
//  定点上传
//  Created by Yangsl on 13-7-26.
//
//

#import <UIKit/UIKit.h>
//引用代理类
#import "UploadFile.h"
#import "QBImagePickerController.h"
#import "UploadViewCell.h"

@interface ChangeUploadViewController : UIViewController <UploadFileDelegate,UITableViewDataSource,UITableViewDelegate,QBImagePickerControllerDelegate,UploadViewCellDelegate>
{
    //头部视图
    UIView *topView;
    //底部视图
    //中间列表
    UITableView *uploadListTableView;
    //上传数据列表
    NSMutableArray *uploadingList;
    //历史纪录数据列表
    NSMutableArray *historyList;
    //如果为Flase,显示上传纪录，为True，显示历史纪录
    BOOL isHistoryShow;
    //上传至文件夹目录名称
    NSString *deviceName;
}

@property(nonatomic,retain) UIView *topView;
@property(nonatomic,retain) UITableView *uploadListTableView;
@property(nonatomic,retain) NSMutableArray *uploadingList;
@property(nonatomic,retain) NSMutableArray *historyList;
@property(nonatomic,assign) BOOL isHistoryShow;

@end