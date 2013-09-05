//
//  FileTableView.h
//  NetDisk
//
//  Created by Yangsl on 13-8-22.
//
//

#import <UIKit/UIKit.h>
#import "PhotoViewController.h"
#import "SCBPhotoManager.h"
#import "DownImage.h"
#import "CustomControl.h"
#import "SCBFileManager.h"
#import "SCBLinkManager.h"
#import "MBProgressHUD.h"

@protocol FileTableViewDelegate <NSObject>

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

@interface FileTableView : UITableView <NewFoldDelegate,UITableViewDataSource,UITableViewDelegate,DownloaderDelegate,UIAlertViewDelegate,SCBFileManagerDelegate,SCBLinkManagerDelegate,UIActionSheetDelegate>
{
    SCBPhotoManager *photoManager;
    NSDictionary *upDictionary;
    NSMutableArray *tableArray;
    NSMutableDictionary *tableDictionary; 
    CustomControl *folderMenu;
    CustomControl *fileMenu;
    UIButton *escButton;
    CGFloat allHeight;
    
    id<FileTableViewDelegate> file_delegate;
    NSIndexPath *selectedIndexPath;
    SCBFileManager *fileManager;
    SCBLinkManager *linkManager;
    
    NSString *p_id;
    
    NSMutableDictionary *selected_dictionary;
    MBProgressHUD *hud;
    BOOL isEdition;
    int sharedType; //1 短信分享，2 邮件分享，3 复制，4 微信，5 朋友圈
}

@property(nonatomic,retain) SCBPhotoManager *photoManager;
@property(nonatomic,retain) NSDictionary *upDictionary;
@property(nonatomic,retain) NSMutableArray *tableArray;
@property(nonatomic,retain) NSMutableDictionary *tableDictionary;
@property(nonatomic,retain) CustomControl *folderMenu;
@property(nonatomic,retain) CustomControl *fileMenu;
@property(nonatomic,retain) UIButton *escButton;
@property(nonatomic,assign) CGFloat allHeight;

@property(nonatomic,retain) id<FileTableViewDelegate> file_delegate;
@property(nonatomic,retain) NSIndexPath *selectedIndexPath;
@property(nonatomic,retain) SCBFileManager *fileManager;
@property(nonatomic,retain) SCBLinkManager *linkManager;

@property(nonatomic,retain) NSString *p_id;

@property(nonatomic,retain) NSMutableDictionary *selected_dictionary;
@property(nonatomic,retain) MBProgressHUD *hud;
@property(nonatomic,assign) BOOL isEdition;

//请求文件
-(void)requestFile:(NSString *)f_id space_id:(NSString *)space_id;
//移动文件
-(void)setMoveFile:(NSString *)pid;
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
#pragma mark 新建文件夹
-(void)toNewFinder:(NSString *)textName;
#pragma mark 请求我的家庭空间
-(void)requestSpace:(NSString *)spaceid;

@end
