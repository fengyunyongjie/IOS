//
//  SCBFileManager.m
//  NetDisk
//
//  Created by fengyongning on 13-4-15.
//
//

#import "SCBFileManager.h"
#import "SCBoxConfig.h"
#import "SCBSession.h"
@interface SCBFileManager()
{
    NSURLConnection *_conn;
}
@end
@implementation SCBFileManager
-(void)cancelAllTask
{
    self.delegate=nil;
}

-(void)openFinderWithCategory:(NSString *)category;
{
    self.fm_type=kFMTypeOpenCategoryDir;
    self.activeData=[NSMutableData data];
    NSURL *s_url=[NSURL URLWithString:[NSString stringWithFormat:@"%@%@",SERVER_URL,FM_CATEGORY_DIR_URI]];
    NSMutableURLRequest *request=[NSMutableURLRequest requestWithURL:s_url cachePolicy:NSURLRequestReloadIgnoringLocalCacheData timeoutInterval:CONNECT_TIMEOUT];
    NSMutableString *body=[[NSMutableString alloc] init];
    NSString *s_id=[[SCBSession sharedSession] spaceID];
    [body appendFormat:@"cursor=%d&offset=%d&space_id=%@&category=%@",0,-1,s_id,category];
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

-(void)openFileWithID:(NSString *)f_id category:(NSString *)category
{
    self.fm_type=kFMTypeOpenCategoryFile;
    self.activeData=[NSMutableData data];
    NSURL *s_url=[NSURL URLWithString:[NSString stringWithFormat:@"%@%@",SERVER_URL,FM_CATEGORY_FILE_URI]];
    NSMutableURLRequest *request=[NSMutableURLRequest requestWithURL:s_url cachePolicy:NSURLRequestReloadIgnoringLocalCacheData timeoutInterval:CONNECT_TIMEOUT];
    NSMutableString *body=[[NSMutableString alloc] init];
    NSString *s_id=[[SCBSession sharedSession] spaceID];
    [body appendFormat:@"f_id=%@&cursor=%d&offset=%d&category=%@",f_id,0,-1,category];
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
-(void)searchWithQueryparam:(NSString *)f_queryparam
{
    self.fm_type=kFMTypeSearch;
    self.activeData=[NSMutableData data];
    NSURL *s_url=[NSURL URLWithString:[NSString stringWithFormat:@"%@%@",SERVER_URL,FM_SEARCH_URI]];
    NSMutableURLRequest *request=[NSMutableURLRequest requestWithURL:s_url cachePolicy:NSURLRequestReloadIgnoringLocalCacheData timeoutInterval:CONNECT_TIMEOUT];
    NSMutableString *body=[[NSMutableString alloc] init];
    NSString *s_id=[[SCBSession sharedSession] spaceID];
    [body appendFormat:@"f_pid=%@&f_queryparam=%@&cursor=%d&offset=%d&space_id=%@&type=%@",@"1",f_queryparam,0,-1,s_id,@"1"];
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
    self.fm_type=kFMTypeNewFinder;
    self.activeData=[NSMutableData data];
    NSURL *s_url=[NSURL URLWithString:[NSString stringWithFormat:@"%@%@",SERVER_URL,FM_MKDIR_URI]];
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
-(void)operateUpdateWithID:(NSString *)f_id
{
    self.fm_type=kFMTypeOperateUpdate;
    self.activeData=[NSMutableData data];
    NSURL *s_url=[NSURL URLWithString:[NSString stringWithFormat:@"%@%@",SERVER_URL,FM_URI]];
    NSMutableURLRequest *request=[NSMutableURLRequest requestWithURL:s_url cachePolicy:NSURLRequestReloadIgnoringLocalCacheData timeoutInterval:CONNECT_TIMEOUT];
    NSMutableString *body=[[NSMutableString alloc] init];
    NSString *s_id=[[SCBSession sharedSession] spaceID];
    [body appendFormat:@"f_id=%@&cursor=%d&offset=%d&space_id=%@&iszone=%@&sort=%@&sort_direct=%@",f_id,0,-1,s_id,@"1",@"f_modify",@"desc"];
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
-(void)openFinderWithID:(NSString *)f_id sID:(NSString *)s_id
{
    self.fm_type=kFMTypeOpenFinder;
    self.activeData=[NSMutableData data];
    NSURL *s_url=[NSURL URLWithString:[NSString stringWithFormat:@"%@%@",SERVER_URL,FM_URI]];
    NSMutableURLRequest *request=[NSMutableURLRequest requestWithURL:s_url cachePolicy:NSURLRequestReloadIgnoringLocalCacheData timeoutInterval:CONNECT_TIMEOUT];
    NSMutableString *body=[[NSMutableString alloc] init];
    [body appendFormat:@"f_id=%@&cursor=%d&offset=%d&space_id=%@&iszone=%@&sort=%@&sort_direct=%@",f_id,0,-1,s_id,@"1",@"f_modify",@"desc"];
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
    self.fm_type=kFMTypeRename;
    self.activeData=[NSMutableData data];
    NSURL *s_url=[NSURL URLWithString:[NSString stringWithFormat:@"%@%@",SERVER_URL,FM_RENAME_URI]];
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
    self.fm_type=kFMTypeMove;
    self.activeData=[NSMutableData data];
    NSURL *s_url=[NSURL URLWithString:[NSString stringWithFormat:@"%@%@",SERVER_URL,FM_MOVE_URI]];
    NSMutableURLRequest *request=[NSMutableURLRequest requestWithURL:s_url cachePolicy:NSURLRequestReloadIgnoringLocalCacheData timeoutInterval:CONNECT_TIMEOUT];
    NSMutableString *body=[[NSMutableString alloc] init];
    NSString *fids=[f_ids componentsJoinedByString:@"&f_ids[]="];
    NSString *s_id=[[SCBSession sharedSession] spaceID];
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
    self.fm_type=kFMTypeRemove;
    self.activeData=[NSMutableData data];
    NSURL *s_url=[NSURL URLWithString:[NSString stringWithFormat:@"%@%@",SERVER_URL,FM_RM_URI]];
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


//打开空间成员
-(void)requestOpenFamily:(NSString *)space_id
{
    self.fm_type = kFMTypeFamily;
    self.activeData = [NSMutableData data];
    NSURL *s_url=[NSURL URLWithString:[NSString stringWithFormat:@"%@%@",SERVER_URL,FM_FAMILY_MEMBERS]];
    NSMutableURLRequest *request=[NSMutableURLRequest requestWithURL:s_url cachePolicy:NSURLRequestReloadIgnoringLocalCacheData timeoutInterval:CONNECT_TIMEOUT];
    NSMutableString *body=[[NSMutableString alloc] init];
    [body appendFormat:@"space_id=%@",space_id];
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
        switch (self.fm_type) {
            case kFMTypeOpenFinder:
                break;
            case kFMTypeRemove:
                [self.delegate removeUnsucess];
                break;
            case kFMTypeRename:
                [self.delegate renameUnsucess];
                break;
            case kFMTypeMove:
                [self.delegate moveUnsucess];
                break;
            case kFMTypeNewFinder:
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
            switch (self.fm_type) {
                case kFMTypeOpenCategoryDir:
                    [self.delegate openFinderSucess:dic];
                    break;
                case kFMTypeOpenCategoryFile:
                    [self.delegate openFinderSucess:dic];
                    break;
                case kFMTypeOpenFinder:
                    [self.delegate openFinderSucess:dic];
                    break;
                case kFMTypeRemove:
                    [self.delegate removeSucess];
                    break;
                case kFMTypeRename:
                    [self.delegate renameSucess];
                    break;
                case kFMTypeMove:
                    [self.delegate moveSucess];
                    NSLog(@"移动成功");
                    break;
                case kFMTypeOperateUpdate:
                    [self.delegate operateSucess:dic];
                    break;
                case kFMTypeNewFinder:
                    [self.delegate newFinderSucess];
                    break;
                case kFMTypeSearch:
                    [self.delegate searchSucess:dic];
                    break;
                case kFMTypeFamily:
                    [self.delegate getOpenFamily:dic];
                    break;
            }
        }
    }else
    {
        NSLog(@"操作失败 数据大小：%d",[self.activeData length]);
        if (self.delegate) {
            switch (self.fm_type) {
                case kFMTypeOpenFinder:
                    break;
                case kFMTypeRemove:
                    [self.delegate removeUnsucess];
                    break;
                case kFMTypeRename:
                    [self.delegate renameUnsucess];
                    break;
                case kFMTypeMove:
                    [self.delegate moveUnsucess];
                    break;
                case kFMTypeNewFinder:
                    [self.delegate newFinderUnsucess];
                    break;
                case kFMTypeSearch:
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
