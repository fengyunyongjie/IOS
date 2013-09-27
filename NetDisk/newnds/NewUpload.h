//
//  NewUpload.h
//  NetDisk
//
//  Created by Yangsl on 13-9-26.
//
//

#import <Foundation/Foundation.h>
#import "SCBPhotoManager.h"
#import "SCBUploader.h"
#import "UpLoadList.h"
#import "MKNetworkOperation.h"

@protocol NewUploadDelegate <NSObject>

//上传成功
-(void)upFinish:(NSDictionary *)dicationary;
//上传进行时，发送上传进度数据
-(void)upProess:(float)proress fileTag:(NSInteger)fileTag;
//文件重名
-(void)upReName;
//上传失败
-(void)upError;
//等待WiFi
-(void)upWaitWiFi;
//网络失败
-(void)upNetworkStop;

@end

@interface NewUpload : NSObject<SCBPhotoDelegate,NewFoldDelegate,UpLoadDelegate>

@property(nonatomic,retain) SCBPhotoManager *photoManger;
@property(nonatomic,retain) SCBUploader *uploderDemo;
@property(nonatomic,retain) NSString *finishName;
@property(nonatomic,retain) NSURLConnection *connection;
@property(nonatomic,retain) UpLoadList *list;
@property(nonatomic,retain) NSArray *urlNameArray;
@property(nonatomic,assign) NSInteger urlIndex;
@property(nonatomic,retain) __block NSData *file_data;
@property(nonatomic,retain) NSString *md5String;
@property(nonatomic,retain) MKNetworkOperation *netWorkOperation;

@property(nonatomic,retain) id<NewUploadDelegate> delegate;

-(id)init;

-(void)setList:(UpLoadList *)list_;

//开始上传任务
-(void)startUpload;

@end
