//
//  AutomaticUpload.h
//  NetDisk
//
//  Created by Yangsl on 13-8-7.
//
//

/*
 
 自动上传逻辑
 
 1.搜索照片库的照片
 2.比对本地照片库信息
 3.只是上传本地数据库和服务器都没有的图片
 4.开启上传
 
 */

@protocol UploadAllFileDelegate <NSObject>
//上传成功
-(void)upFinish:(NSInteger)fileTag;
//上传进行时，发送上传进度数据
-(void)upProess:(float)proress fileTag:(NSInteger)fileTag;

@end

#import <Foundation/Foundation.h>
#import "UploadFile.h"

@interface AutomaticUpload : NSObject <UploadFileDelegate>
{
    NSMutableArray *assetArray;
    id<UploadAllFileDelegate> uploadAllDelegate;
    NSString *space_id;
    NSString *deviceName;
}

@property(nonatomic,retain) NSMutableArray *assetArray;
@property(nonatomic,retain) id<UploadAllFileDelegate> uploadAllDelegate;

//比对本地数据库
-(NSMutableArray *)isHaveData;

//开启自动上传
-(void)startAutomaticUpload;

//关闭自动上传
-(void)colseAutomaticUpload;



@end
