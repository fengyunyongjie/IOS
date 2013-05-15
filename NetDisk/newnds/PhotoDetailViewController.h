//
//  PhotoDetailViewController.h
//  NetDisk
//
//  Created by Yangsl on 13-5-6.
//
//

#import <UIKit/UIKit.h>
#import "DownImage.h"
#import "PhohoDemo.h"
#import "PhotoDetailView.h"

@interface PhotoDetailViewController : UIViewController<DownloaderDelegate,UIScrollViewDelegate>
{
    UIScrollView *scroll_View;
    float allHeight;
    NSInteger imageTag;
    NSMutableArray *allPhotoDemoArray;
    NSInteger currPageNumber;
    PhotoDetailView *OntimeView;
    
    UIView *topView;
    UIView *bottonView;
    UILabel *pageLabel;
}

@property(nonatomic,retain) UIScrollView *scroll_View;
@property(nonatomic,retain) UIView *topView;
@property(nonatomic,retain) UIView *bottonView;
@property(nonatomic,retain) UILabel *pageLabel;

#pragma mark 加载所有数据
-(void)loadAllDiction:(NSArray *)allArray currtimeIdexTag:(int)indexTag;

-(void)showIndexTag:(NSInteger)indexTag;

-(void)addCenterImageView:(PhohoDemo *)demo currPage:(NSInteger)pageIndex totalCount:(NSInteger)count;

@end
