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

#import <UIKit/UIKit.h>
#import "SCBPhotoManager.h"
#import "PhotoDetailViewController.h"

/*
 1:公开版
 0:测试版 暂时屏蔽部分代码
 */
#ifndef DEBUG_PUBLIC_EDITION
#define DEBUG_PUBLIC_EDITION 1
#endif

@interface PhotoViewController : UIViewController<SCBPhotoDelegate,UIScrollViewDelegate,UITableViewDelegate,UITableViewDataSource,DeleteDelegate>
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
    
    NSMutableArray *_arrVisibleCells; // 当前可见的cell
	NSMutableDictionary *_dicReuseCells; //重用的cell
    BOOL editBL;
    UIView *bottonView;
}

@property(nonatomic,retain) SCBPhotoManager *photoManager;
@property(nonatomic,retain) NSMutableDictionary *allDictionary;
@property(nonatomic,retain) UITableView *table_view;
@property(nonatomic,retain) UIActivityIndicatorView *activity_indicator;
@property(nonatomic,retain) NSString *user_id;
@property(nonatomic,retain) NSString *user_token;

@end
