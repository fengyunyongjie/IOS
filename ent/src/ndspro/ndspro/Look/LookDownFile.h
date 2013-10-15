//
//  LookDownFile.h
//  ndspro
//
//  Created by Yangsl on 13-10-15.
//  Copyright (c) 2013年 fengyongning. All rights reserved.
//

#import <Foundation/Foundation.h>

@protocol LookDownDelegate <NSObject>
- (void)appImageDidLoad:(NSInteger)indexTag urlImage:(NSString *)path index:(NSIndexPath *)indexPath;
- (void)downFinish:(NSString *)baseUrl;
-(void)downFile:(NSInteger)downSize totalSize:(NSInteger)sudu;
-(void)didFailWithError;
@end

@interface LookDownFile : NSObject<NSURLConnectionDelegate>
{
    NSInteger endSecond;
    NSInteger endSudu;
}

@property (nonatomic) NSInteger imageViewIndex;
@property (nonatomic, strong) id <LookDownDelegate> delegate;
@property (nonatomic, assign) NSInteger downsize;
@property (nonatomic, strong) NSURLConnection *imageConnection;
@property (nonatomic, strong) NSString *file_id;
@property (nonatomic, strong) NSIndexPath *indexPath;
@property (nonatomic, assign) BOOL isStop;
@property (nonatomic, assign) NSInteger macTimeOut;
@property (nonatomic, assign) NSInteger fileSize;
@property (nonatomic, strong) NSString *fileName;
@property (nonatomic, strong) NSString *file_path;
@property (strong,nonatomic) NSOutputStream *fileStream;

- (void)startDownload;
- (void)cancelDownload;
@end
