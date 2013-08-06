//
//  SCBFriendManager.m
//  NetDisk
//
//  Created by fengyongning on 13-4-15.
//
//

#import "SCBFriendManager.h"
#import "SCBoxConfig.h"
#import "SCBSession.h"

@implementation SCBFriendManager

-(void)getFriendshipsGroups:(int)cursor offset:(int)offset
{
    self.matableData = [NSMutableData data];
    NSURL *s_url=[NSURL URLWithString:[NSString stringWithFormat:@"%@%@",SERVER_URL,MSGS]];
    NSMutableURLRequest *request=[NSMutableURLRequest requestWithURL:s_url cachePolicy:NSURLRequestReloadIgnoringLocalCacheData timeoutInterval:CONNECT_TIMEOUT];
    url_string = MSGS;
    NSMutableString *body=[[NSMutableString alloc] init];
    [body appendFormat:@"cursor=%i&offset=%i",cursor,offset];
    NSMutableData *myRequestData=[NSMutableData data];
    [myRequestData appendData:[body dataUsingEncoding:NSUTF8StringEncoding]];
    [request setHTTPBody:myRequestData];
    NSLog(@"--------------------------------------------------请求的参数：%@",body);
    [body release];
    [request setValue:[[SCBSession sharedSession] userId] forHTTPHeaderField:@"usr_id"];
    [request setValue:CLIENT_TAG forHTTPHeaderField:@"client_tag"];
    [request setValue:[[SCBSession sharedSession] userToken] forHTTPHeaderField:@"usr_token"];
    [request setHTTPMethod:@"POST"];
    NSLog(@"%@,%@",[[SCBSession sharedSession] userId],[[SCBSession sharedSession] userToken]);
    [[[NSURLConnection alloc] initWithRequest:request delegate:self] autorelease];
}

@end
