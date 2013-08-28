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
    kLMTypeReleaseLinkEmail,
}kLMType;
@protocol SCBLinkManagerDelegate;
@interface SCBLinkManager : NSObject
@property (nonatomic,assign)id<SCBLinkManagerDelegate> delegate;
@property (strong,nonatomic) NSMutableData *activeData;
@property (assign,nonatomic) kLMType lm_type;
-(void)cancelAllTask;
//发布公开外链
-(void)linkWithIDs:(NSArray *)f_ids;
//邮件分享私密外链
-(void)releaseLinkEmail:(NSArray *)f_ids l_pwd:(NSString *)l_pwd receiver:(NSArray *)receiver;
@end
@protocol SCBLinkManagerDelegate
-(void)releaseEmailSuccess:(NSString *)l_url;
-(void)releaseLinkSuccess:(NSString *)l_url;
-(void)releaseLinkUnsuccess:(NSString *)error_info;
@end