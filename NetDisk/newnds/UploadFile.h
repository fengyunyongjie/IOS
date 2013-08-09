//
//  UploadFile.h
//  NetDisk
//  上传流程类
//  Created by Yangsl on 13-7-26.
//
//

#import <Foundation/Foundation.h>
#import "TaskDemo.h"
#import "SCBPhotoManager.h"
#import "SCBUploader.h"

@protocol UploadFileDelegate <NSObject>
//上传成功
-(void)upFinish:(NSInteger)fileTag;
//上传进行时，发送上传进度数据
-(void)upProess:(float)proress fileTag:(NSInteger)fileTag;
//上传失败
-(void)upError:(NSInteger)fileTag;
@end

@interface UploadFile : NSObject <NewFoldDelegate,UpLoadDelegate,SCBPhotoDelegate>
{
    //上传需要的参数
    TaskDemo *demo;
    //服务器文件操作类
    SCBPhotoManager *photoManger;
    //上传请求类
    SCBUploader *uploderDemo;
    
    //上传至文件夹目录ID
    NSString *f_pid;
    NSString *f_id;
    
    //上传至文件夹目录名称
    NSString *deviceName;
    //上传前，需要保存的md5数据
    NSString *uploadData;
    //上传验证后，得到一个临时文件名称
    NSString *finishName;
    //上传开始，把上传的网络连接保存
    NSURLConnection *connection;
    //上传代理
    id<UploadFileDelegate> delegate;
    NSInteger currTag;
    BOOL isStop;
    NSString *space_id;
}

@property(nonatomic,retain) TaskDemo *demo;
@property(nonatomic,retain) SCBPhotoManager *photoManger;
@property(nonatomic,retain) SCBUploader *uploderDemo;
@property(nonatomic,retain) NSString *deviceName;
@property(nonatomic,retain) NSString *finishName;
@property(nonatomic,retain) NSURLConnection *connection;
@property(nonatomic,retain) id<UploadFileDelegate> delegate;
@property(nonatomic,retain) NSString *space_id;
@property(nonatomic,assign) NSString *f_pid;
@property(nonatomic,assign) NSString *f_id;

//上传开始
-(void)upload;
//上传暂停
-(void)upStop;
//上传销毁
-(void)upClear;

@end
