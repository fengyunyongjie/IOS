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
@synthesize matableData;
@synthesize delegate;


#pragma mark ------------ 获取群组列表
-(void)getFriendshipsGroups:(int)cursor offset:(int)offset
{
    self.matableData = [NSMutableData data];
    NSURL *s_url=[NSURL URLWithString:[NSString stringWithFormat:@"%@%@",SERVER_URL,FRIENDSHIPS_GROUPS]];
    NSMutableURLRequest *request=[NSMutableURLRequest requestWithURL:s_url cachePolicy:NSURLRequestReloadIgnoringLocalCacheData timeoutInterval:CONNECT_TIMEOUT];
    url_string = FRIENDSHIPS_GROUPS;
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

#pragma mark ------------ 获取所有群组及好友列表
-(void)getFriendshipsGroupsDeep
{
    self.matableData = [NSMutableData data];
    NSURL *s_url=[NSURL URLWithString:[NSString stringWithFormat:@"%@%@",SERVER_URL,FRIENDSHIPS_GROUPS_DEEP]];
    NSMutableURLRequest *request=[NSMutableURLRequest requestWithURL:s_url cachePolicy:NSURLRequestReloadIgnoringLocalCacheData timeoutInterval:CONNECT_TIMEOUT];
    url_string = FRIENDSHIPS_GROUPS_DEEP;
    [request setValue:[[SCBSession sharedSession] userId] forHTTPHeaderField:@"usr_id"];
    [request setValue:CLIENT_TAG forHTTPHeaderField:@"client_tag"];
    [request setValue:[[SCBSession sharedSession] userToken] forHTTPHeaderField:@"usr_token"];
    [request setHTTPMethod:@"POST"];
    NSLog(@"%@,%@",[[SCBSession sharedSession] userId],[[SCBSession sharedSession] userToken]);
    [[[NSURLConnection alloc] initWithRequest:request delegate:self] autorelease];
}

#pragma mark ------------ 创建群组
-(void)getFriendshipsGroupsCreate:(NSString *)group_name
{
    self.matableData = [NSMutableData data];
    NSURL *s_url=[NSURL URLWithString:[NSString stringWithFormat:@"%@%@",SERVER_URL,FRIENDSHOPS_GROUP_CREATE]];
    NSMutableURLRequest *request=[NSMutableURLRequest requestWithURL:s_url cachePolicy:NSURLRequestReloadIgnoringLocalCacheData timeoutInterval:CONNECT_TIMEOUT];
    url_string = FRIENDSHOPS_GROUP_CREATE;
    NSMutableString *body=[[NSMutableString alloc] init];
    [body appendFormat:@"group_name=%@",group_name];
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

#pragma mark ------------ 修改群组
-(void)getFriendshipsGroupsUpdate:(int)group_id group_name:(NSString *)group_name
{
    self.matableData = [NSMutableData data];
    NSURL *s_url=[NSURL URLWithString:[NSString stringWithFormat:@"%@%@",SERVER_URL,FRIENDSHIPS_GROUP_UPDATE]];
    NSMutableURLRequest *request=[NSMutableURLRequest requestWithURL:s_url cachePolicy:NSURLRequestReloadIgnoringLocalCacheData timeoutInterval:CONNECT_TIMEOUT];
    url_string = FRIENDSHIPS_GROUP_UPDATE;
    NSMutableString *body=[[NSMutableString alloc] init];
    [body appendFormat:@"group_id=%i&group_name=%@",group_id,group_name];
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

#pragma mark ------------  删除群组
-(void)getFriendshipsGroupDel:(int)isdeep group_id:(int)group_id
{
    self.matableData = [NSMutableData data];
    NSURL *s_url=[NSURL URLWithString:[NSString stringWithFormat:@"%@%@",SERVER_URL,FRIENDSHIP_GROUP_DEL]];
    NSMutableURLRequest *request=[NSMutableURLRequest requestWithURL:s_url cachePolicy:NSURLRequestReloadIgnoringLocalCacheData timeoutInterval:CONNECT_TIMEOUT];
    url_string = FRIENDSHIP_GROUP_DEL;
    NSMutableString *body=[[NSMutableString alloc] init];
    [body appendFormat:@"isdeep=%i&group_id=%i",isdeep,group_id];
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
#pragma mark ------------  获取好友列表
-(void)getFriendshipsFriends:(int)group_id cursor:(int)cursor offset:(int)offset
{
    self.matableData = [NSMutableData data];
    NSURL *s_url=[NSURL URLWithString:[NSString stringWithFormat:@"%@%@",SERVER_URL,FRIENDSHIPS_FRIENDS]];
    NSMutableURLRequest *request=[NSMutableURLRequest requestWithURL:s_url cachePolicy:NSURLRequestReloadIgnoringLocalCacheData timeoutInterval:CONNECT_TIMEOUT];
    url_string = FRIENDSHIPS_FRIENDS;
    NSMutableString *body=[[NSMutableString alloc] init];
    [body appendFormat:@"group_id=%i&cursor=%i&offset=%i",group_id,cursor,offset];
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

#pragma mark ------------  添加好友
-(void)getFriendshipsFriendsCreate:(NSString *)friend_name group_id:(int)group_id friend_remark:(NSString *)friend_remark
{
    self.matableData = [NSMutableData data];
    NSURL *s_url=[NSURL URLWithString:[NSString stringWithFormat:@"%@%@",SERVER_URL,FRIENDSHIPS_FRIEND_CREATE]];
    NSMutableURLRequest *request=[NSMutableURLRequest requestWithURL:s_url cachePolicy:NSURLRequestReloadIgnoringLocalCacheData timeoutInterval:CONNECT_TIMEOUT];
    url_string = FRIENDSHIPS_FRIEND_CREATE;
    NSMutableString *body=[[NSMutableString alloc] init];
    [body appendFormat:@"friend_name=%@&group_id=%i&friend_remark=%@",friend_name,group_id,friend_remark];
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

#pragma mark ------------  移动好友
-(void)getFriendshipsFriendMove:(int)group_id friend_id:(int)friend_id
{
    self.matableData = [NSMutableData data];
    NSURL *s_url=[NSURL URLWithString:[NSString stringWithFormat:@"%@%@",SERVER_URL,FRIENDSHIPS_FRIEND_MOVE]];
    NSMutableURLRequest *request=[NSMutableURLRequest requestWithURL:s_url cachePolicy:NSURLRequestReloadIgnoringLocalCacheData timeoutInterval:CONNECT_TIMEOUT];
    url_string = FRIENDSHIPS_FRIEND_MOVE;
    NSMutableString *body=[[NSMutableString alloc] init];
    [body appendFormat:@"group_id=%i&friend_id=%i",group_id,friend_id];
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

#pragma mark ------------  修改好友备注
-(void)getFriendshipsFriendRemarkUpdate:(NSString *)friend_remark friend_id:(int)friend_id
{
    self.matableData = [NSMutableData data];
    NSURL *s_url=[NSURL URLWithString:[NSString stringWithFormat:@"%@%@",SERVER_URL,FRIENDSHIPS_FRIEND_REMARK_UPDATE]];
    NSMutableURLRequest *request=[NSMutableURLRequest requestWithURL:s_url cachePolicy:NSURLRequestReloadIgnoringLocalCacheData timeoutInterval:CONNECT_TIMEOUT];
    url_string = FRIENDSHIPS_FRIEND_REMARK_UPDATE;
    NSMutableString *body=[[NSMutableString alloc] init];
    [body appendFormat:@"friend_remark=%@&friend_id=%i",friend_remark,friend_id];
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

#pragma mark ------------  删除好友
-(void)getFriendshipsFriendDel:(int)friend_id
{
    self.matableData = [NSMutableData data];
    NSURL *s_url=[NSURL URLWithString:[NSString stringWithFormat:@"%@%@",SERVER_URL,FRIENDSHIPS_FRIEND_DEL]];
    NSMutableURLRequest *request=[NSMutableURLRequest requestWithURL:s_url cachePolicy:NSURLRequestReloadIgnoringLocalCacheData timeoutInterval:CONNECT_TIMEOUT];
    url_string = FRIENDSHIPS_FRIEND_DEL;
    NSMutableString *body=[[NSMutableString alloc] init];
    [body appendFormat:@"friend_id=%i",friend_id];
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

#pragma mark -请求过程中，存储数据
- (void)connection:(NSURLConnection *)connection didReceiveData:(NSData *)data
{
    [self.matableData appendData:data];
}

#pragma mark -请求成功后，分发数据
- (void)connectionDidFinishLoading:(NSURLConnection *)connection
{
    NSDictionary *diction = [NSJSONSerialization JSONObjectWithData:self.matableData options:NSJSONReadingMutableLeaves error:nil];
    NSLog(@"请求成功后，分发数据:%@",diction);
    NSString *type_string = [[[[[connection originalRequest] URL] path] componentsSeparatedByString:@"/"] lastObject];
    if([type_string isEqualToString:[[FRIENDSHIPS_GROUPS componentsSeparatedByString:@"/"] lastObject]])
    {
        if([delegate respondsToSelector:@selector(getFriendshipsGroups:)])
        {
            [delegate getFriendshipsGroups:diction];
        }
    }
    else if([type_string isEqualToString:[[FRIENDSHIPS_GROUPS_DEEP componentsSeparatedByString:@"/"] lastObject]])
    {
        if([delegate respondsToSelector:@selector(getFriendshipsGroupsDeep:)])
        {
            [delegate getFriendshipsGroupsDeep:diction];
        }
    }
//    else if([type_string isEqualToString:[[FRIENDSHOPS_GROUP_CREATE componentsSeparatedByString:@"/"] lastObject]])
//    {
//        if([delegate respondsToSelector:@selector(getFriendshipsGroupsCreate:)])
//        {
//            [delegate getFriendshipsGroupsCreate:diction];
//        }
//    }
    else if([type_string isEqualToString:[[FRIENDSHIPS_GROUP_UPDATE componentsSeparatedByString:@"/"] lastObject]])
    {
        if([delegate respondsToSelector:@selector(getFriendshipsGroupsUpdate:)])
        {
            [delegate getFriendshipsGroupsUpdate:diction];
        }
    }
    else if([type_string isEqualToString:[[FRIENDSHIP_GROUP_DEL componentsSeparatedByString:@"/"] lastObject]])
    {
        if([delegate respondsToSelector:@selector(getFriendshipsGroupDel:)])
        {
            [delegate getFriendshipsGroupDel:diction];
        }
    }
    else if([type_string isEqualToString:[[FRIENDSHIPS_FRIENDS componentsSeparatedByString:@"/"] lastObject]])
    {
        if([delegate respondsToSelector:@selector(getFriendshipsFriends:)])
        {
            [delegate getFriendshipsFriends:diction];
        }
    }
    else if([type_string isEqualToString:[[FRIENDSHIPS_FRIEND_CREATE componentsSeparatedByString:@"/"] lastObject]])
    {
        if([delegate respondsToSelector:@selector(getFriendshipsFriendsCreate:)])
        {
            [delegate getFriendshipsFriendsCreate:diction];
        }
    }
    else if([type_string isEqualToString:[[FRIENDSHIPS_FRIEND_MOVE componentsSeparatedByString:@"/"] lastObject]])
    {
        if([delegate respondsToSelector:@selector(getFriendshipsFriendMove:)])
        {
            [delegate getFriendshipsFriendMove:diction];
        }
    }
    else if([type_string isEqualToString:[[FRIENDSHIPS_FRIEND_REMARK_UPDATE componentsSeparatedByString:@"/"] lastObject]])
    {
        if([delegate respondsToSelector:@selector(getFriendshipsFriendRemarkUpdate:)])
        {
            [delegate getFriendshipsFriendRemarkUpdate:diction];
        }
    }
    else if([type_string isEqualToString:[[FRIENDSHIPS_FRIEND_DEL componentsSeparatedByString:@"/"] lastObject]])
    {
        if([delegate respondsToSelector:@selector(getFriendshipsFriendDel:)])
        {
            [delegate getFriendshipsFriendDel:diction];
        }
    }
}

#pragma mark -请求失败后，分发数据
- (void)connection:(NSURLConnection *)connection didFailWithError:(NSError *)error
{
    if([delegate respondsToSelector:@selector(error)])
    {
        [delegate error];
    }
}

@end
