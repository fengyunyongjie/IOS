//
//  DownManager.h
//  ndspro
//
//  Created by Yangsl on 13-10-11.
//  Copyright (c) 2013年 fengyongning. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "DownList.h"
#import "DwonFile.h"

@interface DownManager : NSObject<DownloaderDelegate>

@property(strong,nonatomic) NSMutableArray *downingArray;
@property(nonatomic,assign) BOOL isStopCurrDown;
@property(nonatomic,assign) BOOL isStart;
@property(nonatomic,assign) BOOL isOpenedDown;

-(id)init;
-(void)updateLoad;
-(void)start;

//将需要下载的文件添加到数据库中
-(void)addDownList:(NSString *)d_name thumbName:(NSString *)thumbName d_fileId:(NSString *)d_file_id d_downSize:(NSInteger)d_downSize;

//暂时所有上传
-(void)stopAllDown;
//删除一条上传
-(void)deleteOneDown:(NSInteger)selectIndex;
//删除所有上传
-(void)deleteAllDown;

@end
