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


@interface PhotoViewController : UIViewController<SCBPhotoDelegate,DownloaderDelegate,UIScrollViewDelegate>
{
    SCBPhotoManager *photoManager;
    UIScrollView *scroll_View;
    NSInteger show_height;
    NSDictionary *allDictionary;
    NSInteger imageTa;
}

@property(nonatomic,retain) SCBPhotoManager *photoManager;
@property(nonatomic,retain) UIScrollView *scroll_View;
@property(nonatomic,retain) NSDictionary *allDictionary;


@end
