//
//  PhotoTableView.h
//  NetDisk
//
//  Created by Yangsl on 13-8-22.
//
//

#import <UIKit/UIKit.h>
#import "PhotoViewController.h"
#import "SCBPhotoManager.h"
#import "DownImage.h"
#import "SCBFileManager.h"
#import "SCBLinkManager.h"
#import <MessageUI/MessageUI.h>
#import "MBProgressHUD.h"

@protocol PhotoTableViewDelegate <NSObject>

-(void)showFile:(int)index array:(NSMutableArray *)tableArray;

-(void)showAllFile:(NSMutableArray *)tableArray;

-(void)downController:(NSString *)fid;

-(void)showController:(NSString *)f_id titleString:(NSString *)f_name;

-(void)messageShare:(NSString *)content;

-(void)mailShare:(NSString *)content;

-(void)setMemberArray:(NSArray *)memberArray;

-(void)haveData;

-(void)nullData;

@end

@interface PhotoTableView : UITableView <SCBPhotoDelegate,UITableViewDataSource,UITableViewDelegate,DownloaderDelegate,UIActionSheetDelegate,SCBFileManagerDelegate,SCBLinkManagerDelegate,UIAlertViewDelegate>
{
    SCBPhotoManager *photoManager;
	NSMutableDictionary *_dicReuseCells; //选中的数据
    BOOL editBL;  //是否为编辑状态，默认为false
    NSMutableDictionary *photo_diction;
    NSMutableArray *sectionarray;
    NSMutableArray *downCellArray;
    
    BOOL isLoadImage;
    BOOL isLoadData;
    
    float endFloat;
    BOOL isSort;
    
    id<PhotoTableViewDelegate> photo_delegate;
    SCBFileManager *fileManager;
    SCBLinkManager *linkManager;
    MBProgressHUD *hud;
    int photoType;
    int sharedType;  //1 短信分享，2 邮件分享，3 复制，4 微信，5 朋友圈
    
    NSString *requestId;
}

@property(nonatomic,assign) SCBPhotoManager *photoManager;
@property(nonatomic,retain) NSMutableDictionary *_dicReuseCells; //选中的数据
@property(nonatomic,assign) BOOL editBL;  //是否为编辑状态，默认为false
@property(nonatomic,retain) NSMutableDictionary *photo_diction;
@property(nonatomic,retain) NSMutableArray *sectionarray;
@property(nonatomic,retain) NSMutableArray *downCellArray; // 重用的cell

@property(nonatomic,assign) BOOL isLoadImage;
@property(nonatomic,assign) BOOL isLoadData;

@property(nonatomic,assign) float endFloat;
@property(nonatomic,assign) BOOL isSort;

@property(nonatomic,retain) id<PhotoTableViewDelegate> photo_delegate;
@property(nonatomic,retain) SCBFileManager *fileManager;
@property(nonatomic,retain) SCBLinkManager *linkManager;
@property(nonatomic,retain) MBProgressHUD *hud;
@property(nonatomic,retain) NSString *requestId;

//加载数据
-(void)reloadPhotoData;
//编辑事件
-(void)editAction;
//全部选中事件
-(void)allCehcked;
//全部取消
-(void)allEscCheckde;
//取消事件
-(void)escAction;

#pragma mark 分享文件
-(void)toShared:(id)sender;
#pragma mark 移动文件
-(void)toMove:(id)sender;
#pragma mark 删除文件
-(void)toDelete:(id)sender;

@end
