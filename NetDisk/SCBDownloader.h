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
    id<SCBDownloaderDelegate> delegate;
    
    NSMutableData *activeDownload;
    NSURLConnection *fileConnection;
}
@property(nonatomic,assign)int index;
@property(nonatomic,retain)NSString *fileId;
@property(nonatomic,retain)NSString *savedPath;
@property(nonatomic,assign)id<SCBDownloaderDelegate> delegate;
@property (nonatomic, retain) NSMutableData *activeDownload;
@property(nonatomic,retain)NSURLConnection *fileConnection;
@property(strong,nonatomic)NSString *tempSavedPath;

-(void)startDownload;
-(void)cancelDownload;
@end

@protocol SCBDownloaderDelegate
-(void)fileDidDownload:(int)index;
-(void)downloadFail;
-(void)updateProgress:(long)size index:(int)index;
@end