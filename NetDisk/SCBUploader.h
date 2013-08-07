//
//  SCBUploader.h
//  NetDisk
//
//  Created by fengyongning on 13-4-15.
//
//

#import <Foundation/Foundation.h>
#import "ASIHTTPRequest.h"
#import "ASIFormDataRequest.h"

@protocol UpLoadDelegate <NSObject,ASIHTTPRequestDelegate>

//上传效验
-(void)uploadVerify:(NSDictionary *)dictionary;

//上传文件完成
-(void)uploadFinish:(NSDictionary *)dictionary;

//申请上传状态
-(void)requestUploadState:(NSDictionary *)dictionary;

//查看上传记录
-(void)lookDescript:(NSDictionary *)dictionary;

//上传文件流
-(void)uploadFiles:(int)proress;

//上传提交
-(void)uploadCommit:(NSDictionary *)dictionary;

//上传失败
-(void)didFailWithError;

@end


@interface SCBUploader : NSObject <ASIHTTPRequestDelegate>
{
    id<UpLoadDelegate> upLoadDelegate;
    NSMutableData *matableData;
    NSString *url_string;
    int currSize;
    int macTimeOut;
}

@property(nonatomic,retain) id<UpLoadDelegate> upLoadDelegate;
@property(nonatomic,retain) NSMutableData *matableData;


//上传效验
-(void)requestUploadVerify:(int)f_pid f_name:(NSString *)f_name f_size:(NSString *)f_size f_md5:(NSString *)f_md5;

//上传
-(NSURLConnection *)requestUploadFile:(NSString *)f_pid f_name:(NSString *)f_name s_name:(NSString *)s_name skip:(NSString *)skip f_md5:(NSString *)f_md5 Image:(NSData *)image;

//上传
-(void)requestUploadState:(NSString *)s_name;

//上传提交
-(void)requestUploadCommit:(NSString *)f_pid f_name:(NSString *)f_name s_name:(NSString *)s_name device:(NSString *)deviceName skip:(NSString *)skip f_md5:(NSString *)f_md5 img_createtime:(NSString *)dateString  space_id:(NSString *)space_id;
//
////查看上传记录
//-(void)lookDescript:(NSDictionary *)dictionary;
//
////上传文件流
//-(void)uploadFiles:(NSDictionary *)dictionary;
//
////上传提交
//-(void)uploadCommit:(NSDictionary *)dictionary;

@end
