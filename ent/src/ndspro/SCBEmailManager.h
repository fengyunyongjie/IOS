//
//  SCBEmailManager.h
//  ndspro
//
//  Created by fengyongning on 13-10-9.
//  Copyright (c) 2013年 fengyongning. All rights reserved.
//

#import <Foundation/Foundation.h>
typedef enum {
    kEMTypeList,            //收发邮件列表/ent/email/list
    kEMTypeDetail,          //收发邮件详情/ent/email/detail
    kEMTypeSendInterior,    //发送站内信/ent/email/send/interior
    kEMTypeSendExternal,    //发送站外信/ent/email/send/external
    kEMTypeDelete,          //站内外信删除/ent/email/del
    kEMTypeFileList,        //获取邮件内文件列表/ent/email/fids
    kEMTypeCheckDownload,   //站外信邮件下载校验/ent/email/checkDownload
    kEMTypeShowDetails,     //邮件详情显示/ent/email/details (不推荐使用)
}kEMType;
@protocol SCBEmailManagerDelegate;
@interface SCBEmailManager : NSObject
@property (nonatomic,weak) id<SCBEmailManagerDelegate> delegate;
@property (strong,nonatomic) NSMutableData *activeData;
@property (assign,nonatomic) kEMType em_type;

-(void)cancelAllTask;
-(void)listEmailWithType:(NSString *)type;  //type 0为收件箱，1为发件箱，2为所有
-(void)detailEmailWithID:(NSString *)eid type:(NSString *)type; //type 同上
-(void)sendInteriorEmailToUser:(NSArray *)usrids Title:(NSString *)title Content:(NSString *)content Files:(NSArray *)fids;
-(void)sendExternalEmailToUser:(NSString *)recevers Title:(NSString *)title Content:(NSString *)content Files:(NSArray *)fids;
-(void)removeEmailWithID:(NSString *)eid type:(NSString *)type; //type 同上
-(void)fileListWithID:(NSString *)eid;
@end
@protocol SCBEmailManagerDelegate
@optional
-(void)listEmailSucceed:(NSDictionary *)datadic;
-(void)listEmailFail;
-(void)detailEmailSucceed:(NSDictionary *)datadic;
-(void)detailEmailFail;
-(void)sendEmailSucceed;
-(void)sendEmailFail;
-(void)removeEmailSucceed;
-(void)removeEmailFail;
-(void)fileListSucceed:(NSData *)data;
-(void)fileListFail;
@end