//
//  SCBSession.m
//  NetDisk
//
//  Created by fengyongning on 13-4-12.
//
//

#import "SCBSession.h"
static SCBSession * _sharedSession;
@implementation SCBSession
+(SCBSession *)sharedSession
{
    if (_sharedSession==nil) {
        _sharedSession=[[self alloc] init];
    }
    return _sharedSession;
}
-(id)init
{
    self=[super init];
    if (self) {
        self.userId=(NSString *)[[NSUserDefaults standardUserDefaults] objectForKey:@"usr_id"];
        self.userToken=(NSString *)[[NSUserDefaults standardUserDefaults] objectForKey:@"usr_token"];
        self.spaceID=(NSString *)[[NSUserDefaults standardUserDefaults] objectForKey:@"space_id"];
        self.homeID=(NSString *)[[NSUserDefaults standardUserDefaults] objectForKey:@"home_id"];
        self.userTag=(NSString *)[[NSUserDefaults standardUserDefaults] objectForKey:@"usr_tag"];
    }
    return self;
}
//-(id)initWithUserID:(NSString *)usr_id Token:usr_token
//{
//    self=[super init];
//    if (self) {
//        _usr_id=usr_id;
//        _usr_token=usr_token;
//    }
//    return self;
//}
@end
