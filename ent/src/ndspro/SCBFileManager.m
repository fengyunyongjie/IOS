//
//  SCBFileManager.m
//  NetDisk
//
//  Created by fengyongning on 13-4-15.
//
//

#import "SCBFileManager.h"
#import "YNFunctions.h"
#import "SCBoxConfig.h"
#import "SCBSession.h"
@interface SCBFileManager()
{
    NSURLConnection *_conn;
}
@end
@implementation SCBFileManager
@synthesize isFamily;

-(void)cancelAllTask
{
    self.delegate=nil;
}
#pragma mark 获取工作区列表  子账号空间权限列表/ent/author/menus
-(void)authorMenus
{
    self.fm_type=kFMTypeAuthorMenus;
    self.activeData=[NSMutableData data];
    NSURL *s_url=[NSURL URLWithString:[NSString stringWithFormat:@"%@%@",SERVER_URL,AUTHOR_MENUS_URI]];
    NSLog(@"%@",s_url);
    NSMutableURLRequest *request=[NSMutableURLRequest requestWithURL:s_url cachePolicy:NSURLRequestReloadIgnoringLocalCacheData timeoutInterval:CONNECT_TIMEOUT];
    
    [request setHTTPMethod:@"POST"];
    [request setValue:[[SCBSession sharedSession] userId] forHTTPHeaderField:@"ent_uid"];
    [request setValue:CLIENT_TAG forHTTPHeaderField:@"ent_uclient"];
    [request setValue:[[SCBSession sharedSession] userToken] forHTTPHeaderField:@"ent_utoken"];
    [request setValue:[[SCBSession sharedSession] ent_utype] forHTTPHeaderField:@"ent_utype"];
    NSLog(@"ent_uid:%@",[[SCBSession sharedSession] userId]);
    NSLog(@"ent_uid:%@",[[SCBSession sharedSession] userToken]);
    NSLog(@"ent_uid:%@",[[SCBSession sharedSession] ent_utype]);
    _conn=[[NSURLConnection alloc] initWithRequest:request delegate:self];
}
#pragma mark 打开移动目录
-(void)requestMoveFile:(NSString *)f_pid fIds:(NSArray *)f_ids
{
    self.fm_type=kFMTypeOpenFinder;
    self.activeData=[NSMutableData data];
    NSURL *s_url=[NSURL URLWithString:[NSString stringWithFormat:@"%@%@",SERVER_URL,FM_CUTTO]];
    NSMutableURLRequest *request=[NSMutableURLRequest requestWithURL:s_url cachePolicy:NSURLRequestReloadIgnoringLocalCacheData timeoutInterval:CONNECT_TIMEOUT];;
    NSMutableString *body=[[NSMutableString alloc] init];
    
    NSString *s_id;
    if(isFamily)
    {
        s_id = [[SCBSession sharedSession] homeID];
    }
    else
    {
        s_id=[[SCBSession sharedSession] spaceID];
    }
    NSString *fids=[f_ids componentsJoinedByString:@"&f_ids[]="];
    [body appendFormat:@"pId=%@",f_pid];
    [body appendFormat:@"&space_id=%@",s_id];
    [body appendFormat:@"&fIds[]=%@",fids];
    
    NSLog(@"body:%@",body);
    NSMutableData *myRequestData=[NSMutableData data];
    [myRequestData appendData:[body dataUsingEncoding:NSUTF8StringEncoding]];
    [request setHTTPBody:myRequestData];
    [request setHTTPMethod:@"POST"];
    [request setValue:[[SCBSession sharedSession] userId] forHTTPHeaderField:@"usr_id"];
    [request setValue:CLIENT_TAG forHTTPHeaderField:@"client_tag"];
    [request setValue:[[SCBSession sharedSession] userToken] forHTTPHeaderField:@"usr_token"];
    NSLog(@"%@,%@",[[SCBSession sharedSession] userId],[[SCBSession sharedSession] userToken]);
    [[NSURLConnection alloc] initWithRequest:request delegate:self] ;
}

-(void)openFinderWithCategory:(NSString *)category;
{
    self.fm_type=kFMTypeOpenCategoryDir;
    self.activeData=[NSMutableData data];
    NSURL *s_url=[NSURL URLWithString:[NSString stringWithFormat:@"%@%@",SERVER_URL,FM_CATEGORY_DIR_URI]];
    NSMutableURLRequest *request=[NSMutableURLRequest requestWithURL:s_url cachePolicy:NSURLRequestReloadIgnoringLocalCacheData timeoutInterval:CONNECT_TIMEOUT];
    NSMutableString *body=[[NSMutableString alloc] init];
    NSString *s_id;
    if(isFamily)
    {
        s_id = [[SCBSession sharedSession] homeID];
    }
    else
    {
        s_id=[[SCBSession sharedSession] spaceID];
    }
    [body appendFormat:@"cursor=%d&offset=%d&space_id=%@&category=%@",0,-1,s_id,category];
    NSLog(@"%@",body);
    NSMutableData *myRequestData=[NSMutableData data];
    [myRequestData appendData:[body dataUsingEncoding:NSUTF8StringEncoding]];
    
    [request setValue:[[SCBSession sharedSession] userId] forHTTPHeaderField:@"usr_id"];
    [request setValue:CLIENT_TAG forHTTPHeaderField:@"client_tag"];
    [request setValue:[[SCBSession sharedSession] userToken] forHTTPHeaderField:@"usr_token"];
    [request setHTTPBody:myRequestData];
    [request setHTTPMethod:@"POST"];
    
    _conn=[[NSURLConnection alloc] initWithRequest:request delegate:self];
}

-(void)openFileWithID:(NSString *)f_id category:(NSString *)category
{
    self.fm_type=kFMTypeOpenCategoryFile;
    self.activeData=[NSMutableData data];
    NSURL *s_url=[NSURL URLWithString:[NSString stringWithFormat:@"%@%@",SERVER_URL,FM_CATEGORY_FILE_URI]];
    NSMutableURLRequest *request=[NSMutableURLRequest requestWithURL:s_url cachePolicy:NSURLRequestReloadIgnoringLocalCacheData timeoutInterval:CONNECT_TIMEOUT];
    NSMutableString *body=[[NSMutableString alloc] init];
    NSString *s_id;
    if(isFamily)
    {
        s_id = [[SCBSession sharedSession] homeID];
    }
    else
    {
        s_id=[[SCBSession sharedSession] spaceID];
    }
    [body appendFormat:@"f_id=%@&cursor=%d&offset=%d&category=%@",f_id,0,-1,category];
    NSLog(@"%@",body);
    NSMutableData *myRequestData=[NSMutableData data];
    [myRequestData appendData:[body dataUsingEncoding:NSUTF8StringEncoding]];
    
    [request setValue:[[SCBSession sharedSession] userId] forHTTPHeaderField:@"usr_id"];
    [request setValue:CLIENT_TAG forHTTPHeaderField:@"client_tag"];
    [request setValue:[[SCBSession sharedSession] userToken] forHTTPHeaderField:@"usr_token"];
    [request setHTTPBody:myRequestData];
    [request setHTTPMethod:@"POST"];

    
    _conn=[[NSURLConnection alloc] initWithRequest:request delegate:self];
}
-(void)searchWithQueryparam:(NSString *)f_queryparam
{
    self.fm_type=kFMTypeSearch;
    self.activeData=[NSMutableData data];
    NSURL *s_url=[NSURL URLWithString:[NSString stringWithFormat:@"%@%@",SERVER_URL,FM_SEARCH_URI]];
    NSMutableURLRequest *request=[NSMutableURLRequest requestWithURL:s_url cachePolicy:NSURLRequestReloadIgnoringLocalCacheData timeoutInterval:CONNECT_TIMEOUT];
    NSMutableString *body=[[NSMutableString alloc] init];
    NSString *s_id;
    if(isFamily)
    {
        s_id = [[SCBSession sharedSession] homeID];
    }
    else
    {
        s_id=[[SCBSession sharedSession] spaceID];
    }
    [body appendFormat:@"f_pid=%@&f_queryparam=%@&cursor=%d&offset=%d&space_id=%@&type=%@",@"1",f_queryparam,0,-1,s_id,@"1"];
    NSLog(@"%@",body);
    NSMutableData *myRequestData=[NSMutableData data];
    [myRequestData appendData:[body dataUsingEncoding:NSUTF8StringEncoding]];
    
    [request setValue:[[SCBSession sharedSession] userId] forHTTPHeaderField:@"usr_id"];
    [request setValue:CLIENT_TAG forHTTPHeaderField:@"client_tag"];
    [request setValue:[[SCBSession sharedSession] userToken] forHTTPHeaderField:@"usr_token"];
    [request setHTTPBody:myRequestData];
    [request setHTTPMethod:@"POST"];
    _conn=[[NSURLConnection alloc] initWithRequest:request delegate:self] ;
}
-(void)newFinderWithName:(NSString *)f_name pID:(NSString*)f_pid sID:(NSString *)s_id;
{
    self.fm_type=kFMTypeNewFinder;
    self.activeData=[NSMutableData data];
    NSURL *s_url=[NSURL URLWithString:[NSString stringWithFormat:@"%@%@",SERVER_URL,FM_MKDIR_URI]];
    NSMutableURLRequest *request=[NSMutableURLRequest requestWithURL:s_url cachePolicy:NSURLRequestReloadIgnoringLocalCacheData timeoutInterval:CONNECT_TIMEOUT];
    NSMutableString *body=[[NSMutableString alloc] init];
    [body appendFormat:@"fname=%@&fpid=%@&spid=%@",f_name,f_pid,s_id];
    NSLog(@"%@",body);
    NSMutableData *myRequestData=[NSMutableData data];
    [myRequestData appendData:[body dataUsingEncoding:NSUTF8StringEncoding]];
    
    [request setValue:[[SCBSession sharedSession] userId] forHTTPHeaderField:@"ent_uid"];
    [request setValue:CLIENT_TAG forHTTPHeaderField:@"ent_uclient"];
    [request setValue:[[SCBSession sharedSession] userToken] forHTTPHeaderField:@"ent_utoken"];
    [request setValue:[[SCBSession sharedSession] ent_utype] forHTTPHeaderField:@"ent_utype"];
    [request setHTTPBody:myRequestData];
    [request setHTTPMethod:@"POST"];

    
    _conn=[[NSURLConnection alloc] initWithRequest:request delegate:self];
}
-(void)operateUpdateWithID:(NSString *)f_id sID:(NSString *)s_id
{
    self.fm_type=kFMTypeOperateUpdate;
    self.activeData=[NSMutableData data];
    NSURL *s_url=[NSURL URLWithString:[NSString stringWithFormat:@"%@%@",SERVER_URL,FM_URI]];
    NSLog(@"%@",s_url);
    NSMutableURLRequest *request=[NSMutableURLRequest requestWithURL:s_url cachePolicy:NSURLRequestReloadIgnoringLocalCacheData timeoutInterval:CONNECT_TIMEOUT];
    NSMutableString *body=[[NSMutableString alloc] init];
    NSString *desc=[YNFunctions getDesc];
    NSString *order=@"asc";
    if ([desc isEqualToString:@"time"]) {
        order=@"desc";
    }
    [body appendFormat:@"fpid=%@&cursor=%d&offset=%d&spid=%@&order=%@&desc=%@",f_id,0,0,s_id,desc,order];
    NSLog(@"%@",body);
    NSMutableData *myRequestData=[NSMutableData data];
    [myRequestData appendData:[body dataUsingEncoding:NSUTF8StringEncoding]];
    
    [request setHTTPBody:myRequestData];
    [request setHTTPMethod:@"POST"];
    [request setValue:[[SCBSession sharedSession] userId] forHTTPHeaderField:@"ent_uid"];
    [request setValue:CLIENT_TAG forHTTPHeaderField:@"ent_uclient"];
    [request setValue:[[SCBSession sharedSession] userToken] forHTTPHeaderField:@"ent_utoken"];
    [request setValue:[[SCBSession sharedSession] ent_utype] forHTTPHeaderField:@"ent_utype"];
    NSLog(@"ent_uid:%@",[[SCBSession sharedSession] userId]);
    NSLog(@"ent_uid:%@",[[SCBSession sharedSession] userToken]);
    NSLog(@"ent_uid:%@",[[SCBSession sharedSession] ent_utype]);
    _conn=[[NSURLConnection alloc] initWithRequest:request delegate:self];
}
-(void)openFinderWithID:(NSString *)f_id sID:(NSString *)s_id
{
    self.fm_type=kFMTypeOpenFinder;
    self.activeData=[NSMutableData data];
    NSURL *s_url=[NSURL URLWithString:[NSString stringWithFormat:@"%@%@",SERVER_URL,FM_URI]];
    NSLog(@"%@",s_url);
    NSMutableURLRequest *request=[NSMutableURLRequest requestWithURL:s_url cachePolicy:NSURLRequestReloadIgnoringLocalCacheData timeoutInterval:CONNECT_TIMEOUT];
    NSMutableString *body=[[NSMutableString alloc] init];
    NSString *desc=[YNFunctions getDesc];
    NSString *order=@"asc";
    if ([desc isEqualToString:@"time"]) {
        order=@"desc";
    }
    [body appendFormat:@"fpid=%@&cursor=%d&offset=%d&spid=%@&order=%@&desc=%@",f_id,0,0,s_id,desc,order];
    NSLog(@"%@",body);
    NSMutableData *myRequestData=[NSMutableData data];
    [myRequestData appendData:[body dataUsingEncoding:NSUTF8StringEncoding]];
    
    [request setHTTPBody:myRequestData];
    [request setHTTPMethod:@"POST"];
    [request setValue:[[SCBSession sharedSession] userId] forHTTPHeaderField:@"ent_uid"];
    [request setValue:CLIENT_TAG forHTTPHeaderField:@"ent_uclient"];
    [request setValue:[[SCBSession sharedSession] userToken] forHTTPHeaderField:@"ent_utoken"];
    [request setValue:[[SCBSession sharedSession] ent_utype] forHTTPHeaderField:@"ent_utype"];
    NSLog(@"ent_uid:%@",[[SCBSession sharedSession] userId]);
    NSLog(@"ent_uid:%@",[[SCBSession sharedSession] userToken]);
    NSLog(@"ent_uid:%@",[[SCBSession sharedSession] ent_utype]);
    _conn=[[NSURLConnection alloc] initWithRequest:request delegate:self];
}

-(void)renameWithID:(NSString *)f_id newName:(NSString *)f_name sID:(NSString *)s_id
{
    self.fm_type=kFMTypeRename;
    self.activeData=[NSMutableData data];
    NSURL *s_url=[NSURL URLWithString:[NSString stringWithFormat:@"%@%@",SERVER_URL,FM_RENAME_URI]];
    NSMutableURLRequest *request=[NSMutableURLRequest requestWithURL:s_url cachePolicy:NSURLRequestReloadIgnoringLocalCacheData timeoutInterval:CONNECT_TIMEOUT];
    NSMutableString *body=[[NSMutableString alloc] init];
    [body appendFormat:@"fid=%@&fname=%@&spid=%@",f_id,f_name,s_id];
    NSLog(@"%@",body);
    NSMutableData *myRequestData=[NSMutableData data];
    [myRequestData appendData:[body dataUsingEncoding:NSUTF8StringEncoding]];
    
    [request setHTTPBody:myRequestData];
    [request setHTTPMethod:@"POST"];
    [request setValue:[[SCBSession sharedSession] userId] forHTTPHeaderField:@"ent_uid"];
    [request setValue:CLIENT_TAG forHTTPHeaderField:@"ent_uclient"];
    [request setValue:[[SCBSession sharedSession] userToken] forHTTPHeaderField:@"ent_utoken"];
    [request setValue:[[SCBSession sharedSession] ent_utype] forHTTPHeaderField:@"ent_utype"];
    
    _conn=[[NSURLConnection alloc] initWithRequest:request delegate:self];
}
-(void)moveFileIDs:(NSArray *)f_ids toPID:(NSString *)f_pid sID:(NSString *)s_id
{
    self.fm_type=kFMTypeMove;
    self.activeData=[NSMutableData data];
    NSURL *s_url=[NSURL URLWithString:[NSString stringWithFormat:@"%@%@",SERVER_URL,FM_MOVE_URI]];
    NSMutableURLRequest *request=[NSMutableURLRequest requestWithURL:s_url cachePolicy:NSURLRequestReloadIgnoringLocalCacheData timeoutInterval:CONNECT_TIMEOUT];
    NSMutableString *body=[[NSMutableString alloc] init];
    NSString *fids=[f_ids componentsJoinedByString:@"&fids[]="];
    [body appendFormat:@"fpid=%@&fids[]=%@&spid=%@",f_pid,fids,s_id];
    NSLog(@"move: %@",body);
    NSMutableData *myRequestData=[NSMutableData data];
    [myRequestData appendData:[body dataUsingEncoding:NSUTF8StringEncoding]];
    
    [request setHTTPBody:myRequestData];
    [request setHTTPMethod:@"POST"];
    [request setValue:[[SCBSession sharedSession] userId] forHTTPHeaderField:@"ent_uid"];
    [request setValue:CLIENT_TAG forHTTPHeaderField:@"ent_uclient"];
    [request setValue:[[SCBSession sharedSession] userToken] forHTTPHeaderField:@"ent_utoken"];
    [request setValue:[[SCBSession sharedSession] ent_utype] forHTTPHeaderField:@"ent_utype"];
    
    _conn=[[NSURLConnection alloc] initWithRequest:request delegate:self];
}
//文件提交/ent/file/commit
-(void)commitFileIDs:(NSArray *)f_ids toPID:(NSString *)f_pid sID:(NSString *)s_id
{
    self.fm_type=kFMTypeMove;
    self.activeData=[NSMutableData data];
    NSURL *s_url=[NSURL URLWithString:[NSString stringWithFormat:@"%@%@",SERVER_URL,FM_COMMIT_URI]];
    NSMutableURLRequest *request=[NSMutableURLRequest requestWithURL:s_url cachePolicy:NSURLRequestReloadIgnoringLocalCacheData timeoutInterval:CONNECT_TIMEOUT];
    NSMutableString *body=[[NSMutableString alloc] init];
    NSString *fids=[f_ids componentsJoinedByString:@"&fids[]="];
    [body appendFormat:@"fpid=%@&fids[]=%@&spid=%@",f_pid,fids,s_id];
    NSLog(@"move: %@",body);
    NSMutableData *myRequestData=[NSMutableData data];
    [myRequestData appendData:[body dataUsingEncoding:NSUTF8StringEncoding]];
    
    [request setHTTPBody:myRequestData];
    [request setHTTPMethod:@"POST"];
    [request setValue:[[SCBSession sharedSession] userId] forHTTPHeaderField:@"ent_uid"];
    [request setValue:CLIENT_TAG forHTTPHeaderField:@"ent_uclient"];
    [request setValue:[[SCBSession sharedSession] userToken] forHTTPHeaderField:@"ent_utoken"];
    [request setValue:[[SCBSession sharedSession] ent_utype] forHTTPHeaderField:@"ent_utype"];
    
    _conn=[[NSURLConnection alloc] initWithRequest:request delegate:self];
}
//文件转存/ent/file/resave
-(void)resaveFileIDs:(NSArray *)f_ids toPID:(NSString *)f_pid
{
    self.fm_type=kFMTypeMove;
    self.activeData=[NSMutableData data];
    NSURL *s_url=[NSURL URLWithString:[NSString stringWithFormat:@"%@%@",SERVER_URL,FM_RESAVE_URI]];
    NSMutableURLRequest *request=[NSMutableURLRequest requestWithURL:s_url cachePolicy:NSURLRequestReloadIgnoringLocalCacheData timeoutInterval:CONNECT_TIMEOUT];
    NSMutableString *body=[[NSMutableString alloc] init];
    NSString *fids=[f_ids componentsJoinedByString:@"&fids[]="];
    [body appendFormat:@"fpid=%@&fids[]=%@",f_pid,fids];
    NSLog(@"move: %@",body);
    NSMutableData *myRequestData=[NSMutableData data];
    [myRequestData appendData:[body dataUsingEncoding:NSUTF8StringEncoding]];
    
    [request setHTTPBody:myRequestData];
    [request setHTTPMethod:@"POST"];
    [request setValue:[[SCBSession sharedSession] userId] forHTTPHeaderField:@"ent_uid"];
    [request setValue:CLIENT_TAG forHTTPHeaderField:@"ent_uclient"];
    [request setValue:[[SCBSession sharedSession] userToken] forHTTPHeaderField:@"ent_utoken"];
    [request setValue:[[SCBSession sharedSession] ent_utype] forHTTPHeaderField:@"ent_utype"];
    
    _conn=[[NSURLConnection alloc] initWithRequest:request delegate:self];
}
-(void)copyFileIDs:(NSArray *)f_ids toPID:(NSString *)f_pid toSpaceId:(NSString *)spaceId toPidSpaceId:(NSString *)sp_id
{
    self.fm_type=kFMTypeMove;
    self.activeData=[NSMutableData data];
    NSURL *s_url=[NSURL URLWithString:[NSString stringWithFormat:@"%@%@",SERVER_URL,FM_COPYPASTE]];
    NSMutableURLRequest *request=[NSMutableURLRequest requestWithURL:s_url cachePolicy:NSURLRequestReloadIgnoringLocalCacheData timeoutInterval:CONNECT_TIMEOUT];
    NSMutableString *body=[[NSMutableString alloc] init];
    NSString *fids=[f_ids componentsJoinedByString:@"&f_ids[]="];
//    NSString *s_id;
//    if(isFamily)
//    {
//        s_id = [[SCBSession sharedSession] homeID];
//    }
//    else
//    {
//        s_id=[[SCBSession sharedSession] spaceID];
//    }
    [body appendFormat:@"f_pid=%@&f_ids[]=%@&space_id=%@&f_pid_space_id=%@",f_pid,fids,spaceId,sp_id];
    NSLog(@"move: %@",body);
    NSMutableData *myRequestData=[NSMutableData data];
    [myRequestData appendData:[body dataUsingEncoding:NSUTF8StringEncoding]];
    
    [request setValue:[[SCBSession sharedSession] userId] forHTTPHeaderField:@"usr_id"];
    [request setValue:CLIENT_TAG forHTTPHeaderField:@"client_tag"];
    [request setValue:[[SCBSession sharedSession] userToken] forHTTPHeaderField:@"usr_token"];
    [request setHTTPBody:myRequestData];
    [request setHTTPMethod:@"POST"];
    
    _conn=[[NSURLConnection alloc] initWithRequest:request delegate:self];
}
-(void)removeFileWithIDs:(NSArray*)f_ids
{
    self.fm_type=kFMTypeRemove;
    self.activeData=[NSMutableData data];
    NSURL *s_url=[NSURL URLWithString:[NSString stringWithFormat:@"%@%@",SERVER_URL,FM_RM_URI]];
    NSMutableURLRequest *request=[NSMutableURLRequest requestWithURL:s_url cachePolicy:NSURLRequestReloadIgnoringLocalCacheData timeoutInterval:CONNECT_TIMEOUT];
    NSMutableString *body=[[NSMutableString alloc] init];
    NSString *fids=[f_ids componentsJoinedByString:@"&fids[]="];
    [body appendFormat:@"fids[]=%@",fids];
    NSLog(@"\"remove: %@\"",body);
    NSMutableData *myRequestData=[NSMutableData data];
    [myRequestData appendData:[body dataUsingEncoding:NSUTF8StringEncoding]];
    
    [request setHTTPBody:myRequestData];
    [request setHTTPMethod:@"POST"];
    [request setValue:[[SCBSession sharedSession] userId] forHTTPHeaderField:@"ent_uid"];
    [request setValue:CLIENT_TAG forHTTPHeaderField:@"ent_uclient"];
    [request setValue:[[SCBSession sharedSession] userToken] forHTTPHeaderField:@"ent_utoken"];
    [request setValue:[[SCBSession sharedSession] ent_utype] forHTTPHeaderField:@"ent_utype"];
    
    _conn=[[NSURLConnection alloc] initWithRequest:request delegate:self];
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
    [request setValue:[[SCBSession sharedSession] userId] forHTTPHeaderField:@"usr_id"];
    [request setValue:CLIENT_TAG forHTTPHeaderField:@"client_tag"];
    [request setValue:[[SCBSession sharedSession] userToken] forHTTPHeaderField:@"usr_token"];
    [request setHTTPMethod:@"POST"];
    NSLog(@"%@,%@",[[SCBSession sharedSession] userId],[[SCBSession sharedSession] userToken]);
    [[NSURLConnection alloc] initWithRequest:request delegate:self];
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
    NSLog(@"connection:didReceiveData:%@",data);
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
    if(!self.activeData)
    {
        NSLog(@"请求得到的数据为空");
        return;
    }
    
    NSLog(@"%@",[[NSString alloc] initWithData:self.activeData encoding:NSUTF8StringEncoding]);
    NSError *jsonParsingError=nil;
    
    NSDictionary *dic=[NSJSONSerialization JSONObjectWithData:self.activeData options:0 error:&jsonParsingError];
    if (self.fm_type==kFMTypeAuthorMenus) {
        @try {
            if ([[dic objectForKey:@"code"] intValue]!=0) {
                NSLog(@"获取空间列表返回错误");
            }
        }
        @catch (NSException *exception) {
            NSLog(@"有异常～,说明成功？？");
            if (self.delegate) {
                [self.delegate authorMenusSuccess:self.activeData];
            }
        }
        @finally {
            NSLog(@"%@",dic);
            NSLog(@"@finally");
        }
    }else
    if ([[dic objectForKey:@"code"] intValue]==0) {
        NSLog(@"操作成功 数据大小：%d",[self.activeData length]);
        if (self.delegate) {
            switch (self.fm_type) {
                case kFMTypeAuthorMenus:
//                    [self.delegate authorMenusSuccess:dic];
                    NSLog(@"这里错误！%s,%d",__PRETTY_FUNCTION__,__LINE__);
                    break;
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
