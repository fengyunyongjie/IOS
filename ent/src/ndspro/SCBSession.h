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
@property(nonatomic,strong)NSString *userId;    //ent_uid	子账号id	String，加密过
@property(nonatomic,strong)NSString *userToken; //ent_utoken	token
@property(strong,nonatomic)NSString *userName;
@property(strong,nonatomic)NSString *userPwd;
@property(strong,nonatomic)NSString *userTag;
@property(strong,nonatomic)NSString *homeID;
@property(strong,nonatomic)NSString *spaceID;
@property(strong,nonatomic)NSString *ent_utype;  //账号类型:0代表企业账号，1代表子账号
+(SCBSession *)sharedSession;
//-(id)initWithUserID:(NSString *)usr_id Token:usr_token;
@end
