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
+(SCBSession *)sharedSession;
//-(id)initWithUserID:(NSString *)usr_id Token:usr_token;
@end
