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
    kSMTypeSearch,
}kSMType;
@protocol SCBShareManagerDelegate;
@interface SCBShareManager : NSObject
@property (nonatomic,assign)id<SCBShareManagerDelegate> delegate;
@property (strong,nonatomic) NSMutableData *activeData;
@property (assign,nonatomic) kSMType sm_type;
-(void)cancelAllTask;

//打开共享/share
-(void)openFinderWithID:(NSString *)f_id shareType:(NSString *)share_type;
//设置共享/share/create
//新建/share/mkdir
//重命名/share/rename
//复制粘贴/share/copypaste
//剪切粘贴/share/cutpaste
//删除/share/rm
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
@end
@protocol SCBShareManagerDelegate
-(void)searchSucess:(NSDictionary *)datadic;
-(void)openFinderSucess:(NSDictionary *)datadic;
-(void)openFinderUnsucess;
@end