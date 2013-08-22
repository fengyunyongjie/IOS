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

@protocol FileTableViewDelegate <NSObject>

-(void)showFile:(int)index array:(NSMutableArray *)tableArray;

-(void)showAllFile:(NSMutableArray *)tableArray;

@end

@interface FileTableView : UITableView <NewFoldDelegate,UITableViewDataSource,UITableViewDelegate,DownloaderDelegate>
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

//请求文件
-(void)requestFile:(NSString *)f_id space_id:(NSString *)space_id;

@end
