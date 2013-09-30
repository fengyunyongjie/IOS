//
//  IconDownloader.h
//  NetDisk
//
//  Created by fengyongning on 13-5-17.
//
//

#import <Foundation/Foundation.h>
@protocol IconDownloaderDelegate;
@interface IconDownloader : NSObject
@property (strong,nonatomic) NSDictionary *data_dic;
@property (strong,nonatomic) NSIndexPath *indexPathInTableView;
@property (weak,nonatomic) id<IconDownloaderDelegate> delegate;
@property (strong,nonatomic) NSMutableData *activeDownload;
@property (strong,nonatomic) NSURLConnection *imageConnection;
@property (assign,nonatomic) int code;
@property (strong,nonatomic) NSString *filePath;
@property (strong,nonatomic) NSOutputStream *fileStream;
-(void)startDownload;
-(void)cancelDownload;
@end

@protocol IconDownloaderDelegate

- (void)appImageDidLoad:(NSIndexPath *)indexPath;

@end