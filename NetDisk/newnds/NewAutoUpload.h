//
//  NewAutoUpload.h
//  NetDisk
//
//  Created by Yangsl on 13-9-27.
//
//

#import <Foundation/Foundation.h>
#import "NewUpload.h"

@interface NewAutoUpload : NSObject<NewUploadDelegate>

@property(nonatomic,retain) NSMutableArray *uploadArray;
@property(nonatomic,assign) BOOL isStopCurrUpload;
@property(nonatomic,assign) BOOL isStart;
@property(nonatomic,assign) BOOL isOpenedUpload;
@property(nonatomic,assign) BOOL isStop;
@property(nonatomic,assign) BOOL isGoOn;

-(void)updateLoad;
-(void)start;

//暂时所有上传
-(void)stopAllUpload;
//删除一条上传
-(void)deleteOneUpload:(NSInteger)selectIndex;
//删除所有上传
-(void)deleteAllUpload;
//暂停上传
-(void)stopUpload;
//开始上传
-(void)goOnUpload;

//修改上传按钮
-(void)updateUploadStartButton:(NSString *)text;
//修改上传按钮为不可用
-(void)updateUploadStartButtonState:(BOOL)isNot;

@end
