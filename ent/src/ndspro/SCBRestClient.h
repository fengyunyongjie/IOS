//
//  SCBoxRestClient.h
//  NetDisk
//
//  Created by fengyongning on 13-4-11.
//
//

#import <Foundation/Foundation.h>

@protocol SCBRestClientDelegate;
@class SCBSession;

@class SCBFriendManager,SCBMessageManager,SCBFileManager,SCBShareManager,SCBPhotoManager;

@interface SCBRestClient : NSObject{
    id<SCBRestClientDelegate> delegate;
}
@property (nonatomic, assign) id<SCBRestClientDelegate> delegate;

-(id)initWithSession:(SCBSession*)session;
-(id)initWithSession:(SCBSession *)session userId:(NSString *)userId;

//取消所有未完成的请求
-(void)cancelAllRequests;

- (void)loadMetadata:(NSString*)path;

- (void)loadFile:(NSString *)path intoPath:(NSString *)destinationPath;
- (void)cancelFileLoad:(NSString*)path;

- (void)loadThumbnail:(NSString *)path ofSize:(NSString *)size intoPath:(NSString *)destinationPath;
- (void)cancelThumbnailLoad:(NSString*)path size:(NSString*)size;

- (void)uploadFile:(NSString *)filename toPath:(NSString *)path withParentRev:(NSString *)parentRev
          fromPath:(NSString *)sourcePath;
- (void)cancelFileUpload:(NSString *)path;

- (void)uploadFile:(NSString*)filename toPath:(NSString*)path fromPath:(NSString *)sourcePath __attribute__((deprecated));
- (void)uploadFileChunk:(NSString *)uploadId offset:(unsigned long long)offset fromPath:(NSString *)localPath;
- (void)uploadFile:(NSString *)filename toPath:(NSString *)parentFolder withParentRev:(NSString *)parentRev
      fromUploadId:(NSString *)uploadId;

- (void)loadRevisionsForFile:(NSString *)path;
- (void)loadRevisionsForFile:(NSString *)path limit:(NSInteger)limit;

- (void)restoreFile:(NSString *)path toRev:(NSString *)rev;

- (void)createFolder:(NSString*)path;

- (void)deletePath:(NSString*)path;

- (void)copyFrom:(NSString*)fromPath toPath:(NSString *)toPath;

- (void)createCopyRef:(NSString *)path;

- (void)copyFromRef:(NSString*)copyRef toPath:(NSString *)toPath;







- (void)moveFrom:(NSString*)fromPath toPath:(NSString *)toPath;

- (void)loadAccountInfo;

- (void)searchPath:(NSString*)path forKeyword:(NSString*)keyword;

- (void)loadSharableLinkForFile:(NSString *)path;
- (void)loadSharableLinkForFile:(NSString *)path shortUrl:(BOOL)createShortUrl;

- (void)loadStreamableURLForFile:(NSString *)path;

- (NSUInteger)requestCount;
@end





@protocol SCBRestClientDelegate <NSObject>
@end
