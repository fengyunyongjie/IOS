//
//  FileTableView.h
//  NetDisk
//
//  Created by Yangsl on 13-8-22.
//
//

#import <UIKit/UIKit.h>
#import "SCBPhotoManager.h"
#import "DownImage.h"
#import "CustomControl.h"
#import "SCBFileManager.h"
#import "SCBLinkManager.h"

@protocol FileTableViewDelegate <NSObject>

-(void)showFile:(int)index array:(NSMutableArray *)tableArray;

-(void)showAllFile:(NSMutableArray *)tableArray;

-(void)downController:(NSString *)fid;

-(void)showController:(NSString *)f_id titleString:(NSString *)f_name;

@end

@interface FileTableView : UITableView <NewFoldDelegate,UITableViewDataSource,UITableViewDelegate,DownloaderDelegate,UIAlertViewDelegate,SCBFileManagerDelegate,SCBLinkManagerDelegate>
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

//请求文件
-(void)requestFile:(NSString *)f_id space_id:(NSString *)space_id;

//编辑事件
-(void)editAction;
//取消事件
-(void)escAction;

@end
