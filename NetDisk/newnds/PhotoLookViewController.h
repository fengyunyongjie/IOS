//
//  PhotoLookViewController.h
//  NetDisk
//
//  Created by Yangsl on 13-6-5.
//
//

#import <UIKit/UIKit.h>
#import "MBProgressHUD.h"
#import "SCBPhotoManager.h"
#import "DownImage.h"

@interface PhotoLookViewController : UIViewController<UIScrollViewDelegate,UIActionSheetDelegate,SCBPhotoDelegate,DownloaderDelegate>{
    /*
     缩放代码
     */
    CGFloat offset;
    float scollviewHeight;
    NSMutableArray *tableArray;
    NSInteger currPage;
    
    /*
     添加头部和底部栏
     */
    UIButton *leftButton;
    UIButton *centerButton;
    UIButton *rightButton;
    BOOL isCliped;
    UIToolbar *bottonToolBar;
    
    /*
     操作提示
     */
    MBProgressHUD *hud;
    int deletePage;
    
    /*
     记录滑动中加载了多少条数据
     */
    NSInteger startPage;
    NSInteger endPage;
    
    /*
     字典类型把已经加载完成的数据存储
     */
    NSMutableDictionary *imageDic;
    NSMutableDictionary *activityDic;
    
    /*
     滑动不加载数据
     */
    BOOL isLoadImage;
    
    /*
     双击事件
     */
    BOOL isDoubleClick;
    
    NSMutableArray *downArray;
}

@property (nonatomic, retain) UIScrollView *imageScrollView;
@property (nonatomic, retain) NSMutableArray *tableArray;
@property (nonatomic, assign) NSInteger currPage;
@property (nonatomic, assign) BOOL isCliped;


-(CGRect)zoomRectForScale:(float)scale inView:(UIScrollView*)scrollView withCenter:(CGPoint)center;


@end
