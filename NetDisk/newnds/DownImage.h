//
//  DownImage.h
//  NetDisk
//
//  Created by Yangsl on 13-5-6.
//
//

//DownImage.h 类
#import <UIKit/UIKit.h>
#import <Foundation/Foundation.h>
@protocol DownloaderDelegate <NSObject>  //使用代理派发的原因在于，不知道何时下载完成，indexTag：将要显示图片的tag，imageUrl：图片的地址
- (void)appImageDidLoad:(NSInteger)indexTag urlImage:(UIImage *)image index:(int)index;
@end

@interface DownImage : NSObject {
    NSInteger imageViewIndex; //需要的视图tag
    
    id <DownloaderDelegate> delegate;
    NSInteger fileId;
    NSMutableData *activeDownload;
    NSURLConnection *imageConnection;
    NSString *imageUrl;
    UIImage *newDownImage;
    int index;
    int showType; //0缩略图，1预览图
}

@property (nonatomic) NSInteger imageViewIndex;
@property (nonatomic, assign) id <DownloaderDelegate> delegate;
@property (nonatomic, retain) NSMutableData *activeDownload;
@property (nonatomic, retain) NSURLConnection *imageConnection;
@property (nonatomic, retain) NSString *imageUrl;
@property (nonatomic, assign) NSInteger fileId;
@property (nonatomic, assign) int index;
@property (nonatomic, assign) int showType;

- (void)startDownload;
- (void)cancelDownload;
//这个路径下是否存在此图片
- (BOOL)image_exists_at_file_path:(NSString *)image_path;
//获取图片路径
- (NSString*)get_image_save_file_path:(NSString*)image_path;

@end

