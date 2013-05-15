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
#import "SCBPhotoManager.h"
@protocol DeleteDelegate  //删除后，改变主窗口数据源
- (void)deleteForDeleteArray:(NSInteger)page timeLine:(NSString *)timeLineString;
@end
@interface PhotoDetailViewController : UIViewController<DownloaderDelegate,UIScrollViewDelegate,SCBPhotoDelegate>
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
    
    int deletePage;
    
    id<DeleteDelegate> deleteDelegate;
    NSString *timeLine;
}

@property(nonatomic,retain) UIScrollView *scroll_View;
@property(nonatomic,retain) UIView *topView;
@property(nonatomic,retain) UIView *bottonView;
@property(nonatomic,retain) UILabel *pageLabel;
@property(nonatomic,retain) id<DeleteDelegate> deleteDelegate;
@property(nonatomic,retain) NSString *timeLine;

#pragma mark 加载所有数据
-(void)loadAllDiction:(NSArray *)allArray currtimeIdexTag:(int)indexTag;

-(void)showIndexTag:(NSInteger)indexTag;

-(void)addCenterImageView:(PhohoDemo *)demo currPage:(NSInteger)pageIndex totalCount:(NSInteger)count;



@end
