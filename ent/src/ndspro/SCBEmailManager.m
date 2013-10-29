//
//  SCBEmailManager.m
//  ndspro
//
//  Created by fengyongning on 13-10-9.
//  Copyright (c) 2013年 fengyongning. All rights reserved.
//

#import "SCBEmailManager.h"
#import "SCBoxConfig.h"
#import "SCBSession.h"
@implementation SCBEmailManager
-(void)cancelAllTask
{
    self.delegate=nil;
}
-(void)listEmailWithType:(NSString *)type  //type 0为收件箱，1为发件箱，2为所有
{
    self.em_type=kEMTypeList;
    self.activeData=[NSMutableData data];
    NSURL *s_url=[NSURL URLWithString:[NSString stringWithFormat:@"%@%@",SERVER_URL,EMAIL_LIST_URI]];
    NSMutableURLRequest *request=[NSMutableURLRequest requestWithURL:s_url cachePolicy:NSURLRequestReloadIgnoringLocalCacheData timeoutInterval:CONNECT_TIMEOUT];
    NSMutableString *body=[[NSMutableString alloc] init];
//    NSString *fids=[f_ids componentsJoinedByString:@"&fids[]="];
    [body appendFormat:@"type=%@&cursor=%d&offset=%d",type,0,0];
    NSMutableData *myRequestData=[NSMutableData data];
    [myRequestData appendData:[body dataUsingEncoding:NSUTF8StringEncoding]];
    
    [request setHTTPBody:myRequestData];
    [request setHTTPMethod:@"POST"];
    [request setValue:[[SCBSession sharedSession] userId] forHTTPHeaderField:@"ent_uid"];
    [request setValue:CLIENT_TAG forHTTPHeaderField:@"ent_uclient"];
    [request setValue:[[SCBSession sharedSession] userToken] forHTTPHeaderField:@"ent_utoken"];
    [request setValue:[[SCBSession sharedSession] ent_utype] forHTTPHeaderField:@"ent_utype"];
    
    [[NSURLConnection alloc] initWithRequest:request delegate:self];
    NSLog(@"%s: %@",__PRETTY_FUNCTION__,s_url);
    NSLog(@"%s: %@",__PRETTY_FUNCTION__,body);
    NSLog(@"%s: %@",__PRETTY_FUNCTION__,[request allHTTPHeaderFields]);
}
-(void)operateUpdateWithType:(NSString *)type  //type 0为收件箱，1为发件箱，2为所有
{
    self.em_type=kEMTypeOperate;
    self.activeData=[NSMutableData data];
    NSURL *s_url=[NSURL URLWithString:[NSString stringWithFormat:@"%@%@",SERVER_URL,EMAIL_LIST_URI]];
    NSMutableURLRequest *request=[NSMutableURLRequest requestWithURL:s_url cachePolicy:NSURLRequestReloadIgnoringLocalCacheData timeoutInterval:CONNECT_TIMEOUT];
    NSMutableString *body=[[NSMutableString alloc] init];
    //    NSString *fids=[f_ids componentsJoinedByString:@"&fids[]="];
    [body appendFormat:@"type=%@&cursor=%d&offset=%d",type,0,0];
    NSMutableData *myRequestData=[NSMutableData data];
    [myRequestData appendData:[body dataUsingEncoding:NSUTF8StringEncoding]];
    
    [request setHTTPBody:myRequestData];
    [request setHTTPMethod:@"POST"];
    [request setValue:[[SCBSession sharedSession] userId] forHTTPHeaderField:@"ent_uid"];
    [request setValue:CLIENT_TAG forHTTPHeaderField:@"ent_uclient"];
    [request setValue:[[SCBSession sharedSession] userToken] forHTTPHeaderField:@"ent_utoken"];
    [request setValue:[[SCBSession sharedSession] ent_utype] forHTTPHeaderField:@"ent_utype"];
    
    [[NSURLConnection alloc] initWithRequest:request delegate:self];
    NSLog(@"%s: %@",__PRETTY_FUNCTION__,s_url);
    NSLog(@"%s: %@",__PRETTY_FUNCTION__,body);
    NSLog(@"%s: %@",__PRETTY_FUNCTION__,[request allHTTPHeaderFields]);
}
-(void)detailEmailWithID:(NSString *)eid type:(NSString *)type //type 同上
{
    self.em_type=kEMTypeDetail;
    self.activeData=[NSMutableData data];
    NSURL *s_url=[NSURL URLWithString:[NSString stringWithFormat:@"%@%@",SERVER_URL,EMAIL_DETAIL_URI]];
    NSMutableURLRequest *request=[NSMutableURLRequest requestWithURL:s_url cachePolicy:NSURLRequestReloadIgnoringLocalCacheData timeoutInterval:CONNECT_TIMEOUT];
    NSMutableString *body=[[NSMutableString alloc] init];
    //    NSString *fids=[f_ids componentsJoinedByString:@"&fids[]="];
    [body appendFormat:@"type=%@&eid=%@",type,eid];
    NSMutableData *myRequestData=[NSMutableData data];
    [myRequestData appendData:[body dataUsingEncoding:NSUTF8StringEncoding]];
    
    [request setHTTPBody:myRequestData];
    [request setHTTPMethod:@"POST"];
    [request setValue:[[SCBSession sharedSession] userId] forHTTPHeaderField:@"ent_uid"];
    [request setValue:CLIENT_TAG forHTTPHeaderField:@"ent_uclient"];
    [request setValue:[[SCBSession sharedSession] userToken] forHTTPHeaderField:@"ent_utoken"];
    [request setValue:[[SCBSession sharedSession] ent_utype] forHTTPHeaderField:@"ent_utype"];
    
    [[NSURLConnection alloc] initWithRequest:request delegate:self];
    NSLog(@"%s: %@",__PRETTY_FUNCTION__,s_url);
    NSLog(@"%s: %@",__PRETTY_FUNCTION__,body);
    NSLog(@"%s: %@",__PRETTY_FUNCTION__,[request allHTTPHeaderFields]);
}
-(void)sendInteriorEmailToUser:(NSArray *)usrids Title:(NSString *)title Content:(NSString *)content Files:(NSArray *)fids
{
    self.em_type=kEMTypeSendInterior;
    self.activeData=[NSMutableData data];
    NSURL *s_url=[NSURL URLWithString:[NSString stringWithFormat:@"%@%@",SERVER_URL,EMAIL_SENDIN_URI]];
    NSMutableURLRequest *request=[NSMutableURLRequest requestWithURL:s_url cachePolicy:NSURLRequestReloadIgnoringLocalCacheData timeoutInterval:CONNECT_TIMEOUT];
    NSMutableString *body=[[NSMutableString alloc] init];
    NSString *fids_str=[fids componentsJoinedByString:@"&fids[]="];
    NSString *usrids_str=[usrids componentsJoinedByString:@"&usrids[]="];
    [body appendFormat:@"fids[]=%@&usrids[]=%@&content=%@&title=%@",fids_str,usrids_str,content,title];
    NSMutableData *myRequestData=[NSMutableData data];
    [myRequestData appendData:[body dataUsingEncoding:NSUTF8StringEncoding]];
    
    [request setHTTPBody:myRequestData];
    [request setHTTPMethod:@"POST"];
    [request setValue:[[SCBSession sharedSession] userId] forHTTPHeaderField:@"ent_uid"];
    [request setValue:CLIENT_TAG forHTTPHeaderField:@"ent_uclient"];
    [request setValue:[[SCBSession sharedSession] userToken] forHTTPHeaderField:@"ent_utoken"];
    [request setValue:[[SCBSession sharedSession] ent_utype] forHTTPHeaderField:@"ent_utype"];
    
    [[NSURLConnection alloc] initWithRequest:request delegate:self];
    NSLog(@"%s: %@",__PRETTY_FUNCTION__,s_url);
    NSLog(@"%s: %@",__PRETTY_FUNCTION__,body);
    NSLog(@"%s: %@",__PRETTY_FUNCTION__,[request allHTTPHeaderFields]);
}
-(void)sendExternalEmailToUser:(NSString *)recevers Title:(NSString *)title Content:(NSString *)content Files:(NSArray *)fids
{
    self.em_type=kEMTypeSendExternal;
    self.activeData=[NSMutableData data];
    NSURL *s_url=[NSURL URLWithString:[NSString stringWithFormat:@"%@%@",SERVER_URL,EMAIL_SENDOUT_URI]];
    NSMutableURLRequest *request=[NSMutableURLRequest requestWithURL:s_url cachePolicy:NSURLRequestReloadIgnoringLocalCacheData timeoutInterval:CONNECT_TIMEOUT];
    NSMutableString *body=[[NSMutableString alloc] init];
    NSString *fids_str=[fids componentsJoinedByString:@"&fids[]="];
    [body appendFormat:@"fids[]=%@&recevers=%@&content=%@&title=%@",fids_str,recevers,content,title];
    NSMutableData *myRequestData=[NSMutableData data];
    [myRequestData appendData:[body dataUsingEncoding:NSUTF8StringEncoding]];
    
    [request setHTTPBody:myRequestData];
    [request setHTTPMethod:@"POST"];
    [request setValue:[[SCBSession sharedSession] userId] forHTTPHeaderField:@"ent_uid"];
    [request setValue:CLIENT_TAG forHTTPHeaderField:@"ent_uclient"];
    [request setValue:[[SCBSession sharedSession] userToken] forHTTPHeaderField:@"ent_utoken"];
    [request setValue:[[SCBSession sharedSession] ent_utype] forHTTPHeaderField:@"ent_utype"];
    
    [[NSURLConnection alloc] initWithRequest:request delegate:self];
    NSLog(@"%s: %@",__PRETTY_FUNCTION__,s_url);
    NSLog(@"%s: %@",__PRETTY_FUNCTION__,body);
    NSLog(@"%s: %@",__PRETTY_FUNCTION__,[request allHTTPHeaderFields]);
}
-(void)removeEmailWithID:(NSString *)eid type:(NSString *)type //type 同上
{
    self.em_type=kEMTypeDelete;
    self.activeData=[NSMutableData data];
    NSURL *s_url=[NSURL URLWithString:[NSString stringWithFormat:@"%@%@",SERVER_URL,EMAIL_DEL_URI]];
    NSMutableURLRequest *request=[NSMutableURLRequest requestWithURL:s_url cachePolicy:NSURLRequestReloadIgnoringLocalCacheData timeoutInterval:CONNECT_TIMEOUT];
    NSMutableString *body=[[NSMutableString alloc] init];
    //    NSString *fids=[f_ids componentsJoinedByString:@"&fids[]="];
    [body appendFormat:@"type=%@&eid=%@",type,eid];
    NSMutableData *myRequestData=[NSMutableData data];
    [myRequestData appendData:[body dataUsingEncoding:NSUTF8StringEncoding]];
    
    [request setHTTPBody:myRequestData];
    [request setHTTPMethod:@"POST"];
    [request setValue:[[SCBSession sharedSession] userId] forHTTPHeaderField:@"ent_uid"];
    [request setValue:CLIENT_TAG forHTTPHeaderField:@"ent_uclient"];
    [request setValue:[[SCBSession sharedSession] userToken] forHTTPHeaderField:@"ent_utoken"];
    [request setValue:[[SCBSession sharedSession] ent_utype] forHTTPHeaderField:@"ent_utype"];
    
    [[NSURLConnection alloc] initWithRequest:request delegate:self];
    NSLog(@"%s: %@",__PRETTY_FUNCTION__,s_url);
    NSLog(@"%s: %@",__PRETTY_FUNCTION__,body);
    NSLog(@"%s: %@",__PRETTY_FUNCTION__,[request allHTTPHeaderFields]);
}
-(void)removeEmailWithIDs:(NSArray *)eids type:(NSString *)type //type 同上
{
    self.em_type=kEMTypeDelete;
    self.activeData=[NSMutableData data];
    NSURL *s_url=[NSURL URLWithString:[NSString stringWithFormat:@"%@%@",SERVER_URL,EMAIL_DELALL_URL]];
    NSMutableURLRequest *request=[NSMutableURLRequest requestWithURL:s_url cachePolicy:NSURLRequestReloadIgnoringLocalCacheData timeoutInterval:CONNECT_TIMEOUT];
    NSMutableString *body=[[NSMutableString alloc] init];
    NSString *e_ids=[eids componentsJoinedByString:@"&eids[]="];
    [body appendFormat:@"type=%@&eids[]=%@",type,e_ids];
    NSMutableData *myRequestData=[NSMutableData data];
    [myRequestData appendData:[body dataUsingEncoding:NSUTF8StringEncoding]];
    
    [request setHTTPBody:myRequestData];
    [request setHTTPMethod:@"POST"];
    [request setValue:[[SCBSession sharedSession] userId] forHTTPHeaderField:@"ent_uid"];
    [request setValue:CLIENT_TAG forHTTPHeaderField:@"ent_uclient"];
    [request setValue:[[SCBSession sharedSession] userToken] forHTTPHeaderField:@"ent_utoken"];
    [request setValue:[[SCBSession sharedSession] ent_utype] forHTTPHeaderField:@"ent_utype"];
    
    [[NSURLConnection alloc] initWithRequest:request delegate:self];
    NSLog(@"%s: %@",__PRETTY_FUNCTION__,s_url);
    NSLog(@"%s: %@",__PRETTY_FUNCTION__,body);
    NSLog(@"%s: %@",__PRETTY_FUNCTION__,[request allHTTPHeaderFields]);
}
-(void)fileListWithID:(NSString *)eid
{
    self.em_type=kEMTypeFileList;
    self.activeData=[NSMutableData data];
    NSURL *s_url=[NSURL URLWithString:[NSString stringWithFormat:@"%@%@",SERVER_URL,EMAIL_FILELIST_URI]];
    NSMutableURLRequest *request=[NSMutableURLRequest requestWithURL:s_url cachePolicy:NSURLRequestReloadIgnoringLocalCacheData timeoutInterval:CONNECT_TIMEOUT];
    NSMutableString *body=[[NSMutableString alloc] init];
    //    NSString *fids=[f_ids componentsJoinedByString:@"&fids[]="];
    [body appendFormat:@"eid=%@",eid];
    NSMutableData *myRequestData=[NSMutableData data];
    [myRequestData appendData:[body dataUsingEncoding:NSUTF8StringEncoding]];
    
    [request setHTTPBody:myRequestData];
    [request setHTTPMethod:@"POST"];
    [request setValue:[[SCBSession sharedSession] userId] forHTTPHeaderField:@"ent_uid"];
    [request setValue:CLIENT_TAG forHTTPHeaderField:@"ent_uclient"];
    [request setValue:[[SCBSession sharedSession] userToken] forHTTPHeaderField:@"ent_utoken"];
    [request setValue:[[SCBSession sharedSession] ent_utype] forHTTPHeaderField:@"ent_utype"];
    
    [[NSURLConnection alloc] initWithRequest:request delegate:self];
    NSLog(@"%s: %@",__PRETTY_FUNCTION__,s_url);
    NSLog(@"%s: %@",__PRETTY_FUNCTION__,body);
    NSLog(@"%s: %@",__PRETTY_FUNCTION__,[request allHTTPHeaderFields]);
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
        [self.delegate networkError];
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
    if (self.em_type==kEMTypeFileList) {
        @try {
            if ([[dic objectForKey:@"code"] intValue]!=0) {
                NSLog(@"获取空间列表返回错误");
            }
        }
        @catch (NSException *exception) {
            NSLog(@"有异常～,说明成功？？");
            if (self.delegate) {
                [self.delegate fileListSucceed:self.activeData];
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
                switch (self.em_type) {
                    case kEMTypeList:
                        [self.delegate listEmailSucceed:dic];
                        break;
                    case kEMTypeDetail:
                        [self.delegate detailEmailSucceed:dic];
                        break;
                    case kEMTypeSendExternal:
                        [self.delegate sendEmailSucceed];
                        break;
                    case kEMTypeSendInterior:
                        [self.delegate sendEmailSucceed];
                        break;
                    case kEMTypeDelete:
                        [self.delegate removeEmailSucceed];
                        break;
                    case kEMTypeOperate:
                        [self.delegate operateSucceed:dic];
                        break;

                }
            }
        }else
        {
            if (self.delegate) {
                switch (self.em_type) {
                    case kEMTypeList:
//                        [self.delegate listEmailSucceed:dic];
                        break;
                    case kEMTypeDetail:
//                        [self.delegate detailEmailSucceed:dic];
                        break;
                    case kEMTypeSendExternal:
                        [self.delegate sendEmailFail];
                        break;
                    case kEMTypeSendInterior:
                        [self.delegate sendEmailFail];
                        break;
                    case kEMTypeDelete:
                        [self.delegate removeEmailFail];
                        break;
                        
                }
            }
        }
//            else
//        {
//            NSLog(@"操作失败 数据大小：%d",[self.activeData length]);
//            if (self.delegate) {
//                switch (self.fm_type) {
//                    case kFMTypeOpenFinder:
//                        break;
//                    case kFMTypeRemove:
//                        [self.delegate removeUnsucess];
//                        break;
//                    case kFMTypeRename:
//                        [self.delegate renameUnsucess];
//                        break;
//                    case kFMTypeMove:
//                        [self.delegate moveUnsucess];
//                        break;
//                    case kFMTypeNewFinder:
//                        [self.delegate newFinderUnsucess];
//                        break;
//                    case kFMTypeSearch:
//                        [self.delegate newFinderUnsucess];
//                        break;
//                }
//            }
//        }
    self.activeData=nil;
    self.delegate=nil;
    NSLog(@"connectionDidFinishLoading");
    //UIImage *image=[[UIImage alloc] initWithData:self.activeDownload];
}
@end
