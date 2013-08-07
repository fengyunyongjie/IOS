//
//  SCBLinkManager.h
//  NetDisk
//
//  Created by fengyongning on 13-7-8.
//
//

#import <Foundation/Foundation.h>
typedef enum {
    kLMTypeReleaseLink,
}kLMType;
@protocol SCBLinkManagerDelegate;
@interface SCBLinkManager : NSObject
@property (nonatomic,assign)id<SCBLinkManagerDelegate> delegate;
@property (strong,nonatomic) NSMutableData *activeData;
@property (assign,nonatomic) kLMType lm_type;
-(void)cancelAllTask;
//发布公开外链
-(void)linkWithIDs:(NSArray *)f_ids;
@end
@protocol SCBLinkManagerDelegate
-(void)releaseLinkSuccess:(NSString *)l_url;
-(void)releaseLinkUnsuccess:(NSString *)error_info;
@end