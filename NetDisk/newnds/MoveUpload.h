//
//  MoveUpload.h
//  NetDisk
//
//  Created by Yangsl on 13-9-26.
//
//  新代码

#import <Foundation/Foundation.h>
#import "NewUpload.h"

@interface MoveUpload : NSObject<NewUploadDelegate>

@property(nonatomic,retain) NSMutableArray *uploadArray;
@property(nonatomic,assign) BOOL isStopCurrUpload;
@property(nonatomic,assign) BOOL isStart;
@property(nonatomic,assign) BOOL isOpenedUpload;

-(id)init;
-(void)updateLoad;
-(void)start;

-(void)addUpload:(NSString *)filePath changeDeviceName:(NSString *)device_name changeFileId:(NSString *)f_id changeSpaceId:(NSString *)s_id;
-(void)changeUpload:(NSMutableOrderedSet *)array_ changeDeviceName:(NSString *)device_name changeFileId:(NSString *)f_id changeSpaceId:(NSString *)s_id;

//暂时所有上传
-(void)stopAllUpload;
//删除一条上传
-(void)deleteOneUpload:(NSInteger)selectIndex;
//删除所有上传
-(void)deleteAllUpload;

@end
