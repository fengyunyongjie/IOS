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
#import "DownImage.h"
#import "PhotoDetailViewController.h"

@interface PhotoViewController : UIViewController<SCBPhotoDelegate,DownloaderDelegate,UIScrollViewDelegate,UITableViewDelegate,UITableViewDataSource,DeleteDelegate>
{
    SCBPhotoManager *photoManager;
    NSInteger show_height;
    NSMutableDictionary *allDictionary;
    NSInteger imageTa;
    UITableView *table_view;
}

@property(nonatomic,retain) SCBPhotoManager *photoManager;
@property(nonatomic,retain) NSMutableDictionary *allDictionary;
@property(nonatomic,retain) UITableView *table_view;

@end
