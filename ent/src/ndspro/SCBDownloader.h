//
//  SCBDownloader.h
//  NetDisk
//
//  Created by fengyongning on 13-4-15.
//
//

#import <Foundation/Foundation.h>
@protocol SCBDownloaderDelegate;
@interface SCBDownloader : NSObject
{
    NSString * _f_id;
    NSString * _savedPath;
    int index;
    NSMutableData *activeDownload;
    NSURLConnection *fileConnection;
}
@property(nonatomic,assign)int index;
@property(strong,nonatomic)NSString *fileId;
@property(strong,nonatomic)NSString *savedPath;
@property(weak,nonatomic)id<SCBDownloaderDelegate> delegate;
@property(strong,nonatomic) NSMutableData *activeDownload;
@property(strong,nonatomic)NSURLConnection *fileConnection;
@property(strong,nonatomic)NSString *tempSavedPath;
@property(assign,nonatomic)long dataSize;

-(void)startDownload;
-(void)cancelDownload;
@end

@protocol SCBDownloaderDelegate
-(void)fileDidDownload:(int)index;
-(void)downloadFail:(int)error;
-(void)updateProgress:(long)size index:(int)index;
@end