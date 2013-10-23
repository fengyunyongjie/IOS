//
//  SCBAccountManager.h
//  NetDisk
//
//  Created by fengyongning on 13-4-12.
//
//

#import <Foundation/Foundation.h>
typedef enum {
    kUserLogin,
    kUserRegist,
    kUserLogout,
    kUserExist,
    kUserGetProfile,
    kUserGetSpace,
    kUserGetList,
    kUserGetInfo,
    kUserCheckVersion,
}kUserType;
@protocol SCBAccountManagerDelegate;
@interface SCBAccountManager : NSObject<NSURLConnectionDelegate>
@property(strong,nonatomic) NSMutableData *activeData;
@property(weak,nonatomic) id<SCBAccountManagerDelegate>  delegate;
@property(nonatomic,assign) kUserType type;
+(SCBAccountManager *)sharedManager;
//login
-(void)UserLoginWithName:(NSString *)user_name Password:(NSString *)user_pwd;
//logout
-(void)UserLogout;
//register
-(void)UserRegisterWithName:(NSString *)user_name Password:(NSString *)user_pwd;
//帐号校验 /usr/exit
//修改个人信息 /usr/profile/update
//获取个人信息 /usr/profile
-(void)currentProfile;
//获取空间信息 /usr/space
-(void)currentUserSpace;
//子账号列表/ent/user/list
-(void)getUserList;
//
-(void)getUserInfo;
//
-(void)checkNewVersion:(NSString *)version;
@end

@protocol SCBAccountManagerDelegate
@optional
-(void)networkError;
-(void)checkVersionSucceed:(NSDictionary *)datadic;
-(void)checkVersionFail;
-(void)getUserListSucceed:(NSDictionary *)datadic;
-(void)getUserListFail;
-(void)getUserInfoSucceed:(NSDictionary *)datadic;
-(void)getUserInfoFail;
-(void)loginSucceed:(id)manager;
-(void)loginUnsucceed:(id)manager;
-(void)registSucceed;
-(void)registUnsucceed:(id)manager;
//[self.delegate spaceSucceedUsed:[dic objectForKey:@"space_used"] total:[dic objectForKey:@"space_total"]];
-(void)spaceSucceedUsed:(NSString *)space_used total:(NSString *)space_total;
-(void)nicknameSucessed:(NSString *)nickname;
@end