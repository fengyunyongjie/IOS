//
//  UploadManager.h
//  ndspro
//
//  Created by Yangsl on 13-10-11.
//  Copyright (c) 2013年 fengyongning. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface UploadManager : NSObject

@property(nonatomic,retain) NSMutableArray *uploadArray;
@property(nonatomic,assign) BOOL isStopCurrUpload;
@property(nonatomic,assign) BOOL isStart;
@property(nonatomic,assign) BOOL isOpenedUpload;

-(id)init;
-(void)updateLoad;
-(void)start;

-(void)changeUpload:(NSMutableOrderedSet *)array_ changeDeviceName:(NSString *)device_name changeFileId:(NSString *)f_id changeSpaceId:(NSString *)s_id;

//暂时所有上传
-(void)stopAllUpload;
//删除一条上传
-(void)deleteOneUpload:(NSInteger)selectIndex;
//删除所有上传
-(void)deleteAllUpload;

@end
