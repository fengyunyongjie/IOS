//
//  SCBAccountManager.h
//  NetDisk
//
//  Created by fengyongning on 13-4-12.
//
//

#import <Foundation/Foundation.h>

@interface SCBAccountManager : NSObject<NSURLConnectionDelegate>
//login
-(void)UserLoginWithName:(NSString *)user_name Password:(NSString *)user_pwd;
//logout
-(void)UserLogout;
//register
-(void)UserRegisterWithName:(NSString *)user_name Password:(NSString *)user_pwd;
@end
