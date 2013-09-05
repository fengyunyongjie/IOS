//
//  SCBShareManager.h
//  NetDisk
//
//  Created by fengyongning on 13-4-15.
//
//

#import <Foundation/Foundation.h>
typedef enum{
    kSMTypeOpenFinder,
    kSMTypeRemove,
    kSMTypeRename,
    kSMTypeMove,
    kSMTypeOperateUpdate,
    kSMTypeNewFinder,
    kSMTypeSearch,
    kSMTypeAcceptAdd,
    kSMTypeRefusedAdd
}kSMType;
@protocol SCBShareManagerDelegate;
@interface SCBShareManager : NSObject
{
    BOOL isFamily;
}
@property (nonatomic,assign)id<SCBShareManagerDelegate> delegate;
@property (strong,nonatomic) NSMutableData *activeData;
@property (assign,nonatomic) kSMType sm_type;
@property (nonatomic,retain) NSString *url_type;
@property (nonatomic,assign) BOOL isFamily;

-(void)cancelAllTask;

//打开共享/share
-(void)openFinderWithID:(NSString *)f_id shareType:(NSString *)share_type;
-(void)operateUpdateWithID:(NSString *)f_id shareType:(NSString *)share_type;
//设置共享/share/create
//新建/share/mkdir
-(void)newFinderWithName:(NSString *)f_name pID:(NSString*)f_pid sID:(NSString *)s_id;
//重命名/share/rename
-(void)renameWithID:(NSString *)f_id newName:(NSString *)f_name;
//复制粘贴/share/copypaste
//剪切粘贴/share/cutpaste
-(void)moveFileIDs:(NSArray *)f_ids toPID:(NSString *)f_pid;
//删除/share/rm
-(void)removeFileWithIDs:(NSArray*)f_ids;
//搜索/share/search
-(void)searchWithQueryparam:(NSString *)f_queryparam shareType:(NSString *)share_type;
//取消共享/share/cancel
//获取共享成员列表/share/members
//踢除共享成员/share/member/rm
//添加共享成员/share/member/add
//退出共享/share/member/exit
//打开共享回收站/share/trash
//彻底删除/share/trash/del
//清空回收站/share/trash/delall

//接受好友的共享邀请share/invitation/add
-(void)shareInvitationAdd:(NSString *)f_id friend_id:(NSString *)friend_id;

//拒绝好友的共享邀请/share/invitation/remove
-(void)shareInvitationRemove:(NSString *)f_id friend_id:(NSString *)friend_id;

@end
@protocol SCBShareManagerDelegate
-(void)searchSucess:(NSDictionary *)datadic;
-(void)operateSucess:(NSDictionary *)datadic;
-(void)openFinderSucess:(NSDictionary *)datadic;
-(void)InvitationAdd:(NSDictionary *)dationary;
-(void)openFinderUnsucess;
-(void)removeSucess;
-(void)removeUnsucess;
-(void)renameSucess;
-(void)renameUnsucess;
-(void)moveSucess;
-(void)moveUnsucess;
-(void)newFinderSucess;
-(void)newFinderUnsucess;
@end