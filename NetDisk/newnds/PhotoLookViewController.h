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
#import "SCBLinkManager.h"
#import <MessageUI/MessageUI.h>

@interface PhotoLookViewController : UIViewController<UIScrollViewDelegate,UIActionSheetDelegate,SCBPhotoDelegate,DownloaderDelegate,SCBLinkManagerDelegate,MFMessageComposeViewControllerDelegate,MFMailComposeViewControllerDelegate,UIActionSheetDelegate>{
    /*
     缩放代码
     */
    NSMutableArray *tableArray;
    NSInteger currPage;
    
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
    NSMutableDictionary *activityDic;
    
    /*
     滑动不加载数据
     */
    BOOL isLoadImage;
    CGFloat currWidth;
    CGFloat currHeight;
    
    NSInteger endCurrPage;
    
    UIScrollView *imageScrollView;
    CGFloat enFloat;
    
    NSMutableArray *downArray;
    
    int sharedType; //1 短信分享，2 邮件分享，3 复制，4 微信，5 朋友圈
    
    SCBLinkManager *linkManager;
    NSString *selected_id;
}

@property (atomic, retain) UIScrollView *imageScrollView;
@property (nonatomic, retain) NSMutableArray *tableArray;
@property (nonatomic, assign) NSInteger currPage;

@property(assign,nonatomic) CGFloat offset;
@property(assign,nonatomic) BOOL isDoubleClick;

/*
 添加头部和底部栏
 */
@property(retain,nonatomic) UIButton *topLeftButton;
@property(retain,nonatomic) UILabel *topTitleLabel;
@property(retain,nonatomic) UIToolbar *topToolBar;

@property(retain,nonatomic) UIButton *leftButton;
@property(retain,nonatomic) UIButton *centerButton;
@property(retain,nonatomic) UIButton *rightButton;
@property(assign,nonatomic) BOOL isCliped;
@property(retain,nonatomic) UIToolbar *bottonToolBar;
@property(assign,nonatomic) BOOL isScape;
@property(assign,nonatomic) int page;
@property(assign,nonatomic) int endFloat;
@property(nonatomic,retain) SCBLinkManager *linkManager;
@property(nonatomic,retain) NSString *selected_id;
@property(nonatomic,retain) MBProgressHUD *hud;

-(CGRect)zoomRectForScale:(float)scale inView:(UIScrollView*)scrollView withCenter:(CGPoint)center;


@end
