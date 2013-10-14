//
//  DwonFile.h
//  ndspro
//
//  Created by Yangsl on 13-10-11.
//  Copyright (c) 2013年 fengyongning. All rights reserved.
//

#import <Foundation/Foundation.h>

@protocol DownloaderDelegate <NSObject>
- (void)appImageDidLoad:(NSInteger)indexTag urlImage:(UIImage *)image index:(NSIndexPath *)indexPath;
- (void)downFinish:(NSString *)baseUrl;
-(void)downFile:(NSInteger)downSize totalSize:(NSInteger)sudu;
-(void)didFailWithError;
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

@interface DwonFile : NSObject<NSURLConnectionDelegate>
{
    NSInteger endSecond;
    NSInteger endSudu;
}

@property (nonatomic) NSInteger imageViewIndex;
@property (nonatomic, strong) id <DownloaderDelegate> delegate;
@property (nonatomic, assign) NSInteger downsize;
@property (nonatomic, strong) NSURLConnection *imageConnection;
@property (nonatomic, strong) NSString *file_id;
@property (nonatomic, assign) int index;
@property (nonatomic, assign) int showType;
@property (nonatomic, strong) NSIndexPath *indexPath;
@property (nonatomic, assign) BOOL isStop;
@property (nonatomic, assign) NSInteger macTimeOut;
@property (nonatomic, assign) NSInteger fileSize;
@property (nonatomic, strong) NSString *fileName;
@property (nonatomic, strong) NSString *file_path;
@property (strong,nonatomic) NSOutputStream *fileStream;

- (void)startDownload;
- (void)cancelDownload;
//这个路径下是否存在此图片
- (BOOL)image_exists_at_file_path:(NSString *)image_path;
//获取图片路径
- (NSString*)get_image_save_file_path:(NSString*)image_path;

@end
