//
//  UploadFile.h
//  ndspro
//
//  Created by Yangsl on 13-10-11.
//  Copyright (c) 2013年 fengyongning. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "SCBUploader.h"
#import "UpLoadList.h"

@protocol NewUploadDelegate <NSObject>

//上传成功
-(void)upFinish:(NSDictionary *)dicationary;
//上传进行时，发送上传进度数据
-(void)upProess:(float)proress fileTag:(NSInteger)sudu;
//文件重名
-(void)upReName;
//上传失败
-(void)upError;
//服务器异常
-(void)webServiceFail;
//上传无权限
-(void)upNotUpload;
//用户存储空间不足
-(void)upUserSpaceLass;
//等待WiFi
-(void)upWaitWiFi;
//网络失败
-(void)upNetworkStop;

@end

@interface UploadFile : NSObject<UpLoadDelegate>

@property(nonatomic,retain) SCBUploader *uploderDemo;
@property(nonatomic,retain) NSString *finishName;
@property(nonatomic,retain) NSURLConnection *connection;
@property(nonatomic,retain) UpLoadList *list;
@property(nonatomic,retain) NSArray *urlNameArray;
@property(nonatomic,assign) NSInteger urlIndex;
@property(nonatomic,retain) __block NSData *file_data;
@property(nonatomic,retain) NSString *md5String;
@property(nonatomic,assign) NSInteger total;

@property(nonatomic,retain) id<NewUploadDelegate> delegate;

-(id)init;

-(void)setList:(UpLoadList *)list_;

//开始上传任务
-(void)startUpload;

@end
