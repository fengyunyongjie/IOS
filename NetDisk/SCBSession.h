//
//  SCBSession.h
//  NetDisk
//
//  Created by fengyongning on 13-4-12.
//
//

#import <Foundation/Foundation.h>

@interface SCBSession : NSObject
{
    NSString * _usr_id;
    NSString * _usr_token;
}
@property(nonatomic,retain)NSString *userId;
@property(nonatomic,retain)NSString *userToken;
@property(strong,nonatomic)NSString *userName;
@property(strong,nonatomic)NSString *userPwd;
@property(strong,nonatomic)NSString *userTag;
@property(strong,nonatomic)NSString *homeID;
@property(strong,nonatomic)NSString *spaceID;
+(SCBSession *)sharedSession;
//-(id)initWithUserID:(NSString *)usr_id Token:usr_token;
@end
