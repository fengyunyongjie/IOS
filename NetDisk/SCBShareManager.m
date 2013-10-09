//
//  SCBShareManager.m
//  NetDisk
//
//  Created by fengyongning on 13-4-15.
//
//

#import "SCBShareManager.h"
#import "SCBoxConfig.h"
#import "SCBSession.h"
@interface SCBShareManager()
{
    NSURLConnection *_conn;
}
@end
@implementation SCBShareManager
@synthesize isFamily;

-(void)cancelAllTask
{
    self.delegate=nil;
    _conn = nil;
}
-(void)searchWithQueryparam:(NSString *)f_queryparam shareType:(NSString *)share_type
{
    self.sm_type=kSMTypeSearch;
    self.activeData=[NSMutableData data];
    NSURL *s_url=[NSURL URLWithString:[NSString stringWithFormat:@"%@%@",SERVER_URL,SHARE_SEARCH_URI]];
    NSMutableURLRequest *request=[NSMutableURLRequest requestWithURL:s_url cachePolicy:NSURLRequestReloadIgnoringLocalCacheData timeoutInterval:CONNECT_TIMEOUT];
    NSMutableString *body=[[NSMutableString alloc] init];
    [body appendFormat:@"f_pid=%@&f_queryparam=%@&cursor=%d&offset=%d&shareType=%@",@"1",f_queryparam,0,-1,share_type];
    NSLog(@"%@",body);
    NSMutableData *myRequestData=[NSMutableData data];
    [myRequestData appendData:[body dataUsingEncoding:NSUTF8StringEncoding]];
    
    [request setValue:[[SCBSession sharedSession] userId] forHTTPHeaderField:@"usr_id"];
    [request setValue:CLIENT_TAG forHTTPHeaderField:@"client_tag"];
    [request setValue:[[SCBSession sharedSession] userToken] forHTTPHeaderField:@"usr_token"];
    [request setHTTPBody:myRequestData];
    [request setHTTPMethod:@"POST"];
    _conn=[[[NSURLConnection alloc] initWithRequest:request delegate:self] autorelease];
    [body release];
}
-(void)newFinderWithName:(NSString *)f_name pID:(NSString*)f_pid sID:(NSString *)s_id;
{
    self.sm_type=kSMTypeNewFinder;
    self.activeData=[NSMutableData data];
    NSURL *s_url=[NSURL URLWithString:[NSString stringWithFormat:@"%@%@",SERVER_URL,SHARE_MKDIR_URI]];
    NSMutableURLRequest *request=[NSMutableURLRequest requestWithURL:s_url cachePolicy:NSURLRequestReloadIgnoringLocalCacheData timeoutInterval:CONNECT_TIMEOUT];
    NSMutableString *body=[[NSMutableString alloc] init];
    [body appendFormat:@"f_name=%@&f_pid=%@&space_id=%@",f_name,f_pid,s_id];
    NSLog(@"%@",body);
    NSMutableData *myRequestData=[NSMutableData data];
    [myRequestData appendData:[body dataUsingEncoding:NSUTF8StringEncoding]];
    
    [request setValue:[[SCBSession sharedSession] userId] forHTTPHeaderField:@"usr_id"];
    [request setValue:CLIENT_TAG forHTTPHeaderField:@"client_tag"];
    [request setValue:[[SCBSession sharedSession] userToken] forHTTPHeaderField:@"usr_token"];
    [request setHTTPBody:myRequestData];
    [request setHTTPMethod:@"POST"];
    [body release];
    
    _conn=[[[NSURLConnection alloc] initWithRequest:request delegate:self] autorelease];
}
-(void)operateUpdateWithID:(NSString *)f_id shareType:(NSString *)share_type
{
    self.sm_type=kSMTypeOperateUpdate;
    self.activeData=[NSMutableData data];
    NSURL *s_url=[NSURL URLWithString:[NSString stringWithFormat:@"%@%@",SERVER_URL,SHARE_OPEN_URI]];
    NSMutableURLRequest *request=[NSMutableURLRequest requestWithURL:s_url cachePolicy:NSURLRequestReloadIgnoringLocalCacheData timeoutInterval:CONNECT_TIMEOUT];
    NSMutableString *body=[[NSMutableString alloc] init];
//    [body appendFormat:@"f_id=%@&cursor=%d&offset=%d&shareType=%@",f_id,0,-1,share_type];
    [body appendFormat:@"f_id=%@&cursor=%d&offset=%d&shareType=%@&sort=%@&sort_direct=%@",f_id,0,-1,share_type,@"f_modify",@"desc"];
    NSLog(@"%@",body);
    NSMutableData *myRequestData=[NSMutableData data];
    [myRequestData appendData:[body dataUsingEncoding:NSUTF8StringEncoding]];
    
    [request setValue:[[SCBSession sharedSession] userId] forHTTPHeaderField:@"usr_id"];
    [request setValue:CLIENT_TAG forHTTPHeaderField:@"client_tag"];
    [request setValue:[[SCBSession sharedSession] userToken] forHTTPHeaderField:@"usr_token"];
    [request setHTTPBody:myRequestData];
    [request setHTTPMethod:@"POST"];
    _conn=[[[NSURLConnection alloc] initWithRequest:request delegate:self] autorelease];
    [body release];
}
-(void)openFinderWithID:(NSString *)f_id shareType:(NSString *)share_type
{
    self.sm_type=kSMTypeOpenFinder;
    self.activeData=[NSMutableData data];
    NSURL *s_url=[NSURL URLWithString:[NSString stringWithFormat:@"%@%@",SERVER_URL,SHARE_OPEN_URI]];
    NSMutableURLRequest *request=[NSMutableURLRequest requestWithURL:s_url cachePolicy:NSURLRequestReloadIgnoringLocalCacheData timeoutInterval:CONNECT_TIMEOUT];
    NSMutableString *body=[[NSMutableString alloc] init];
//    [body appendFormat:@"f_id=%@&cursor=%d&offset=%d&shareType=%@",f_id,0,-1,share_type];
   [body appendFormat:@"f_id=%@&cursor=%d&offset=%d&shareType=%@&sort=%@&sort_direct=%@",f_id,0,-1,share_type,@"f_modify",@"desc"];
    NSLog(@"%@",body);
    NSMutableData *myRequestData=[NSMutableData data];
    [myRequestData appendData:[body dataUsingEncoding:NSUTF8StringEncoding]];
    
    [request setValue:[[SCBSession sharedSession] userId] forHTTPHeaderField:@"usr_id"];
    [request setValue:CLIENT_TAG forHTTPHeaderField:@"client_tag"];
    [request setValue:[[SCBSession sharedSession] userToken] forHTTPHeaderField:@"usr_token"];
    [request setHTTPBody:myRequestData];
    [request setHTTPMethod:@"POST"];
    [body release];
    
    _conn=[[[NSURLConnection alloc] initWithRequest:request delegate:self] autorelease];
}
-(void)renameWithID:(NSString *)f_id newName:(NSString *)f_name
{
    self.sm_type=kSMTypeRename;
    self.activeData=[NSMutableData data];
    NSURL *s_url=[NSURL URLWithString:[NSString stringWithFormat:@"%@%@",SERVER_URL,SHARE_RENAME_URI]];
    NSMutableURLRequest *request=[NSMutableURLRequest requestWithURL:s_url cachePolicy:NSURLRequestReloadIgnoringLocalCacheData timeoutInterval:CONNECT_TIMEOUT];
    NSMutableString *body=[[NSMutableString alloc] init];
    [body appendFormat:@"f_id=%@&f_name=%@",f_id,f_name];
    NSLog(@"%@",body);
    NSMutableData *myRequestData=[NSMutableData data];
    [myRequestData appendData:[body dataUsingEncoding:NSUTF8StringEncoding]];
    
    [request setValue:[[SCBSession sharedSession] userId] forHTTPHeaderField:@"usr_id"];
    [request setValue:CLIENT_TAG forHTTPHeaderField:@"client_tag"];
    [request setValue:[[SCBSession sharedSession] userToken] forHTTPHeaderField:@"usr_token"];
    [request setHTTPBody:myRequestData];
    [request setHTTPMethod:@"POST"];
    [body release];
    
    _conn=[[[NSURLConnection alloc] initWithRequest:request delegate:self] autorelease];
}
-(void)moveFileIDs:(NSArray *)f_ids toPID:(NSString *)f_pid
{
    self.sm_type=kSMTypeMove;
    self.activeData=[NSMutableData data];
    NSURL *s_url=[NSURL URLWithString:[NSString stringWithFormat:@"%@%@",SERVER_URL,SHARE_MOVE_URI]];
    NSMutableURLRequest *request=[NSMutableURLRequest requestWithURL:s_url cachePolicy:NSURLRequestReloadIgnoringLocalCacheData timeoutInterval:CONNECT_TIMEOUT];
    NSMutableString *body=[[NSMutableString alloc] init];
    NSString *fids=[f_ids componentsJoinedByString:@"&f_ids[]="];
    NSString *s_id;
    if(isFamily)
    {
        s_id = [[SCBSession sharedSession] homeID];
    }
    else
    {
        s_id=[[SCBSession sharedSession] spaceID];
    }
    [body appendFormat:@"f_pid=%@&f_ids[]=%@&space_id=%@",f_pid,fids,s_id];
    NSLog(@"move: %@",body);
    NSMutableData *myRequestData=[NSMutableData data];
    [myRequestData appendData:[body dataUsingEncoding:NSUTF8StringEncoding]];
    
    [request setValue:[[SCBSession sharedSession] userId] forHTTPHeaderField:@"usr_id"];
    [request setValue:CLIENT_TAG forHTTPHeaderField:@"client_tag"];
    [request setValue:[[SCBSession sharedSession] userToken] forHTTPHeaderField:@"usr_token"];
    [request setHTTPBody:myRequestData];
    [request setHTTPMethod:@"POST"];
    [body release];
    
    _conn=[[[NSURLConnection alloc] initWithRequest:request delegate:self] autorelease];
}
-(void)removeFileWithIDs:(NSArray*)f_ids
{
    self.sm_type=kSMTypeRemove;
    self.activeData=[NSMutableData data];
    NSURL *s_url=[NSURL URLWithString:[NSString stringWithFormat:@"%@%@",SERVER_URL,SHARE_RM_URI]];
    NSMutableURLRequest *request=[NSMutableURLRequest requestWithURL:s_url cachePolicy:NSURLRequestReloadIgnoringLocalCacheData timeoutInterval:CONNECT_TIMEOUT];
    NSMutableString *body=[[NSMutableString alloc] init];
    NSString *fids=[f_ids componentsJoinedByString:@"&f_ids[]="];
    [body appendFormat:@"f_ids[]=%@",fids];
    NSLog(@"\"remove: %@\"",body);
    NSMutableData *myRequestData=[NSMutableData data];
    [myRequestData appendData:[body dataUsingEncoding:NSUTF8StringEncoding]];
    
    [request setValue:[[SCBSession sharedSession] userId] forHTTPHeaderField:@"usr_id"];
    [request setValue:CLIENT_TAG forHTTPHeaderField:@"client_tag"];
    [request setValue:[[SCBSession sharedSession] userToken] forHTTPHeaderField:@"usr_token"];
    [request setHTTPBody:myRequestData];
    [request setHTTPMethod:@"POST"];
    
    _conn=[[[NSURLConnection alloc] initWithRequest:request delegate:self] autorelease];
    [body release];
}

//拒绝好友的共享邀请/share/invitation/remove
-(void)shareInvitationAdd:(NSString *)f_id friend_id:(NSString *)friend_id
{
    self.sm_type=kSMTypeAcceptAdd;
    self.activeData=[NSMutableData data];
    NSURL *s_url=[NSURL URLWithString:[NSString stringWithFormat:@"%@%@",SERVER_URL,SHARE_INVITATION_ADD]];
    NSMutableURLRequest *request=[NSMutableURLRequest requestWithURL:s_url cachePolicy:NSURLRequestReloadIgnoringLocalCacheData timeoutInterval:CONNECT_TIMEOUT];
    NSMutableString *body=[[NSMutableString alloc] init];
    [body appendFormat:@"f_id=%@&friend_id=%@",f_id,friend_id];
    NSLog(@"url:%@",SHARE_INVITATION_ADD);
    NSLog(@"body:%@",body);
    NSMutableData *myRequestData=[NSMutableData data];
    [myRequestData appendData:[body dataUsingEncoding:NSUTF8StringEncoding]];
    
    [request setValue:[[SCBSession sharedSession] userId] forHTTPHeaderField:@"usr_id"];
    [request setValue:CLIENT_TAG forHTTPHeaderField:@"client_tag"];
    [request setValue:[[SCBSession sharedSession] userToken] forHTTPHeaderField:@"usr_token"];
    [request setHTTPBody:myRequestData];
    [request setHTTPMethod:@"POST"];
    [body release];
    
    _conn=[[[NSURLConnection alloc] initWithRequest:request delegate:self] autorelease];
}

//???Â•ΩÂ????‰∫??ËØ?share/invitation/remove
-(void)shareInvitationRemove:(NSString *)f_id friend_id:(NSString *)friend_id
{
    self.sm_type=kSMTypeRefusedAdd;
    self.activeData=[NSMutableData data];
    NSURL *s_url=[NSURL URLWithString:[NSString stringWithFormat:@"%@%@",SERVER_URL,SHARE_INVITATION_REMOVE]];
    NSMutableURLRequest *request=[NSMutableURLRequest requestWithURL:s_url cachePolicy:NSURLRequestReloadIgnoringLocalCacheData timeoutInterval:CONNECT_TIMEOUT];
    NSMutableString *body=[[NSMutableString alloc] init];
    [body appendFormat:@"f_id=%@&friend_id=%@",f_id,friend_id];
    NSLog(@"%@",body);
    NSMutableData *myRequestData=[NSMutableData data];
    [myRequestData appendData:[body dataUsingEncoding:NSUTF8StringEncoding]];
    
    [request setValue:[[SCBSession sharedSession] userId] forHTTPHeaderField:@"usr_id"];
    [request setValue:CLIENT_TAG forHTTPHeaderField:@"client_tag"];
    [request setValue:[[SCBSession sharedSession] userToken] forHTTPHeaderField:@"usr_token"];
    [request setHTTPBody:myRequestData];
    [request setHTTPMethod:@"POST"];
    [body release];
    
    _conn=[[[NSURLConnection alloc] initWithRequest:request delegate:self] autorelease];
}

#pragma mark - NSURLConnectionDelegate Methods

- (void)connection:(NSURLConnection *)theConnection didReceiveResponse:(NSURLResponse *)response
// A delegate method called by the NSURLConnection when the request/response
// exchange is complete.  We look at the response to check that the HTTP
// status code is 2xx.  If it isn't, we fail right now.
{
    NSLog(@"connection:didReceiveResponse:");
#pragma unused(theConnection)
    NSHTTPURLResponse * httpResponse;
    
    //    assert(theConnection == self.connection);
    //
    httpResponse = (NSHTTPURLResponse *) response;
    assert( [httpResponse isKindOfClass:[NSHTTPURLResponse class]] );
    
    if ((httpResponse.statusCode / 100) != 2) {
        NSLog(@"HTTP error %zd",(ssize_t)httpResponse.statusCode);
    } else {
        NSLog(@"Response OK.");
    }
}

- (void)connection:(NSURLConnection *)connection didReceiveData:(NSData *)data
{
    [self.activeData appendData:data];
    NSLog(@"connection:didReceiveData:");
}

- (void)connection:(NSURLConnection *)connection didFailWithError:(NSError *)error
{
	// Clear the activeDownload property to allow later attempts
    // Release the connection now that it's finished
    NSLog(@"connection:didFailWithError");
    if (self.delegate) {
        switch (self.sm_type) {
            case kSMTypeOpenFinder:
                break;
            case kSMTypeRemove:
                [self.delegate removeUnsucess];
                break;
            case kSMTypeRename:
                [self.delegate renameUnsucess];
                break;
            case kSMTypeMove:
                [self.delegate moveUnsucess];
                break;
            case kSMTypeNewFinder:
                [self.delegate newFinderUnsucess];
                break;
                
        }
    }

}

- (void)connectionDidFinishLoading:(NSURLConnection *)connection
{
    // Release the connection now that it's finished
    // call our delegate and tell it that our icon is ready for display
    //[delegate fileDidDownload:self.index];
    NSLog(@"%@",[[NSString alloc] initWithData:self.activeData encoding:NSUTF8StringEncoding]);
    NSError *jsonParsingError=nil;
    
    NSDictionary *dic=[NSJSONSerialization JSONObjectWithData:self.activeData options:0 error:&jsonParsingError];
    if ([[dic objectForKey:@"code"] intValue]==0) {
        NSLog(@"操作成功 数据大小：%d",[self.activeData length]);
        if (self.delegate) {
            switch (self.sm_type) {
                case kSMTypeOpenFinder:
                    [self.delegate openFinderSucess:dic];
                    break;
                case kSMTypeRemove:
                    [self.delegate removeSucess];
                    break;
                case kSMTypeRename:
                    [self.delegate renameSucess];
                    break;
                case kSMTypeMove:
                    [self.delegate moveSucess];
                    NSLog(@"移动成功");
                    break;
                case kSMTypeOperateUpdate:
                    [self.delegate operateSucess:dic];
                    break;
                case kSMTypeNewFinder:
                    [self.delegate newFinderSucess];
                    break;
                case kSMTypeSearch:
                    [self.delegate searchSucess:dic];
                    break;
                case kSMTypeAcceptAdd:
                    [self.delegate InvitationAdd:dic];
                    break;
                case kSMTypeRefusedAdd:
                    [self.delegate InvitationAdd:dic];
                    break;
            }
        }

    }
    else
    {
        NSLog(@"操作失败 数据大小：%d",[self.activeData length]);
        if (self.delegate) {
            int code = [[dic objectForKey:@"code"] intValue];
            switch (self.sm_type) {
                case kSMTypeOpenFinder:
                {
                    switch (code) {
                        case 1:
                            [self.delegate notingChange:@"服务端异常"];
                            break;
                        case 2:
                            [self.delegate notingChange:@"不是文件拥有者"];
                            break;
                        default:
                            break;
                    }
                }
                    break;
                case kSMTypeRemove:
                {
                    switch (code) {
                        case 1:
                            [self.delegate notingChange:@"服务端异常"];
                            break;
                        case 2:
                            [self.delegate notingChange:@"所选文件不存在"];
                            break;
                        case 4:
                            [self.delegate notingChange:@"共享根目录不能移除"];
                            break;
                        case 5:
                            [self.delegate notingChange:@"网盘根目录不能移除"];
                            break;
                        case 9:
                            [self.delegate notingChange:@"没有操作权限"];
                            break;
                        default:
                            break;
                    }
                }
                    break;
                case kSMTypeRename:
                {
                    switch (code) {
                        case 1:
                            [self.delegate notingChange:@"服务端异常"];
                            break;
                        case 2:
                            [self.delegate notingChange:@"文件重名"];
                            break;
                        case 3:
                            [self.delegate notingChange:@"名字包含特殊字符"];
                            break;
                        case 4:
                            [self.delegate notingChange:@"文件名过长"];
                            break;
                        case 5:
                            [self.delegate notingChange:@"根目录不能重命名"];
                            break;
                        case 6:
                            [self.delegate notingChange:@"没有操作权限"];
                            break;
                        default:
                            break;
                    }
                }
                    break;
                case kSMTypeMove:
                {
                    switch (code) {
                        case 1:
                            [self.delegate notingChange:@"服务端异常"];
                            break;
                        case 2:
                            [self.delegate notingChange:@"所选文件不存在"];
                            break;
                        case 3:
                            [self.delegate notingChange:@"目标文件夹不存在"];
                            break;
                        case 4:
                            [self.delegate notingChange:@"目标不是文件夹"];
                            break;
                        case 5:
                            [self.delegate notingChange:@"根目录不能剪切"];
                            break;
                        case 7:
                            [self.delegate notingChange:@"不能剪切到当前目录"];
                            break;
                        case 8:
                            [self.delegate notingChange:@"没有操作权限"];
                            break;
                        case 9:
                            [self.delegate notingChange:@"所选文件夹或子文件夹不能包含目标文件夹"];
                            break;
                        case 10:
                            [self.delegate notingChange:@"没有操作权限"];
                            break;
                        default:
                            break;
                    }
                }
                    break;
                case kSMTypeNewFinder:
                {
                    switch (code) {
                        case 1:
                            [self.delegate notingChange:@"服务端异常"];
                            break;
                        case 2:
                            [self.delegate notingChange:@"文件重名"];
                            break;
                        case 3:
                            [self.delegate notingChange:@"名字包含特殊字符"];
                            break;
                        case 4:
                            [self.delegate notingChange:@"文件名过长"];
                            break;
                        case 5:
                            [self.delegate notingChange:@"没有操作权限"];
                            break;
                        default:
                            break;
                    }
                }
                    break;
                case kSMTypeSearch:
                    [self.delegate newFinderUnsucess];
                    break;
            }
        }
    }
    self.activeData=nil;
    self.delegate=nil;
    NSLog(@"connectionDidFinishLoading");
    //UIImage *image=[[UIImage alloc] initWithData:self.activeDownload];
}

@end
