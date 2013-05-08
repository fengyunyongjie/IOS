//
//  SCBAccountManager.h
//  NetDisk
//
//  Created by fengyongning on 13-4-12.
//
//

#import <Foundation/Foundation.h>
@protocol SCBAccountManagerDelegate;
@interface SCBAccountManager : NSObject<NSURLConnectionDelegate>
@property(nonatomic,assign) id<SCBAccountManagerDelegate>  delegate;
+(SCBAccountManager *)sharedManager;
//login
-(void)UserLoginWithName:(NSString *)user_name Password:(NSString *)user_pwd;
//logout
-(void)UserLogout;
//register
-(void)UserRegisterWithName:(NSString *)user_name Password:(NSString *)user_pwd;
@end

@protocol SCBAccountManagerDelegate
-(void)loginSucceed:(id)manager;
-(void)loginUnsucceed:(id)manager;
@end