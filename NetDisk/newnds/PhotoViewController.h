//
//  PhotoViewController.h
//  NetDisk
//
//  Created by Yangsl on 13-5-2.
//
//
#define timeLine1 @"今天"
#define timeLine2 @"昨天"
#define timeLine3 @"本周"
#define timeLine4 @"上一周"
#define timeLine5 @"本月"
#define timeLine6 @"上一月"
#define timeLine7 @"本年"

#define UICellTag 10000000
#define UIImageTag 1000000
#define UIButtonTag 2000000

#import <UIKit/UIKit.h>
#import "SCBPhotoManager.h"
#import "DownImage.h"
#import "MBProgressHUD.h"

/*
 1:公开版
 0:测试版 暂时屏蔽部分代码
 */
#ifndef DEBUG_PUBLIC_EDITION
#define DEBUG_PUBLIC_EDITION 1
#endif

@interface PhotoViewController : UIViewController<SCBPhotoDelegate,UIScrollViewDelegate,UITableViewDelegate,UITableViewDataSource,UIAlertViewDelegate,DownloaderDelegate>
{
    SCBPhotoManager *photoManager;
    NSInteger show_height;
    NSMutableDictionary *allDictionary;
    NSInteger imageTa;
    UITableView *table_view;
    UIActivityIndicatorView *activity_indicator;
    NSString *user_id;
    NSString *user_token;
    NSMutableArray *allKeys;
    
    NSMutableArray *_arrVisibleCells; // 重用的cell
	NSMutableDictionary *_dicReuseCells; //选中的数据
    BOOL editBL;  //是否为编辑状态，默认为false
    UIView *bottonView;
    NSMutableDictionary *photo_diction;
    
    UIScrollView *scroll_view;
    
    NSMutableArray *downArray;
    int downNumber;
    BOOL bl;
    UIBarButtonItem *deleteItem;
    UIBarButtonItem *right_item;
    UIBarButtonItem *done_item;
    
    __block NSMutableDictionary *tablediction;
    __block NSMutableArray *sectionarray;
    
    BOOL isLoadImage;
    BOOL isFirst;
    BOOL isLoadData;
    MBProgressHUD *hud;
    float endFloat;
    float selfLenght;
    UITableView *saveTableView;
    int cellNumber;
    
    /*
     倒序
     */
    bool isSort;
    
    NSOperationQueue *operationQueue;
    
    BOOL isOnece;
    NSTimer *timer;
    BOOL isReload;
}

@property(nonatomic,retain) SCBPhotoManager *photoManager;
@property(nonatomic,retain) NSMutableDictionary *allDictionary;
@property(nonatomic,retain) UITableView *table_view;
@property(nonatomic,retain) UIActivityIndicatorView *activity_indicator;
@property(nonatomic,retain) NSString *user_id;
@property(nonatomic,retain) NSString *user_token;
@property(nonatomic,retain) NSMutableArray *allKeys;
@property(nonatomic,retain) NSMutableArray *_arrVisibleCells; // 重用的cell
@property(nonatomic,retain) NSMutableDictionary *_dicReuseCells; //选中的数据
@property(nonatomic,retain) UIView *bottonView;
@property(nonatomic,retain) UIBarButtonItem *deleteItem;
@property(nonatomic,retain) UIBarButtonItem *right_item;
@property(nonatomic,retain) UIBarButtonItem *done_item;

@property(nonatomic,retain) NSMutableDictionary *tablediction;
@property(nonatomic,retain) NSMutableArray *sectionarray;

@property(nonatomic,retain) NSCondition *condition;
@property(nonatomic,retain) NSMutableArray *downCellArray; // 重用的cell

#pragma mark -得到时间轴的列表
-(void)getPhotoTiimeLine:(NSDictionary *)dictionary;

@end

@interface CellTag : NSObject
{
    NSInteger fileTag;
    NSInteger imageTag;
    NSInteger buttonTag;
    NSInteger pageTag;
    NSInteger sectionTag;
}

@property(nonatomic,assign) NSInteger fileTag;
@property(nonatomic,assign) NSInteger imageTag;
@property(nonatomic,assign) NSInteger buttonTag;
@property(nonatomic,assign) NSInteger pageTag;
@property(nonatomic,assign) NSInteger sectionTag;
@end

@interface SelectButton : UIButton
{
    CellTag *cell;
}
@property(nonatomic,retain) CellTag *cell;

@end
