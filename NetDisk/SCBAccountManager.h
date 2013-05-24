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
}kUserType;
@protocol SCBAccountManagerDelegate;
@interface SCBAccountManager : NSObject<NSURLConnectionDelegate>
@property(strong,nonatomic) NSMutableData *activeData;
@property(nonatomic,assign) id<SCBAccountManagerDelegate>  delegate;
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
//获取空间信息 /usr/space
-(void)currentUserSpace;
@end

@protocol SCBAccountManagerDelegate
-(void)loginSucceed:(id)manager;
-(void)loginUnsucceed:(id)manager;
-(void)registSucceed;
//[self.delegate spaceSucceedUsed:[dic objectForKey:@"space_used"] total:[dic objectForKey:@"space_total"]];
-(void)spaceSucceedUsed:(NSString *)space_used total:(NSString *)space_total;
@end