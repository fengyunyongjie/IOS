//
//  SCBLinkManager.m
//  NetDisk
//
//  Created by fengyongning on 13-7-8.
//
//

#import "SCBLinkManager.h"
#import "SCBoxConfig.h"
#import "SCBSession.h"

@implementation SCBLinkManager
-(void)cancelAllTask
{
    self.delegate=nil;
}
-(void)linkWithIDs:(NSArray *)f_ids
{
    self.lm_type=kLMTypeReleaseLink;
    self.activeData=[NSMutableData data];
    NSURL *s_url=[NSURL URLWithString:[NSString stringWithFormat:@"%@%@",SERVER_URL,LINK_RELEASE_PUB_URI]];
    NSMutableURLRequest *request=[NSMutableURLRequest requestWithURL:s_url cachePolicy:NSURLRequestReloadIgnoringLocalCacheData timeoutInterval:CONNECT_TIMEOUT];
    NSMutableString *body=[[NSMutableString alloc] init];
    NSString *fids=[f_ids componentsJoinedByString:@"&f_ids[]="];
    [body appendFormat:@"f_ids[]=%@",fids];
    NSLog(@"body: %@",body);
    NSMutableData *myRequestData=[NSMutableData data];
    [myRequestData appendData:[body dataUsingEncoding:NSUTF8StringEncoding]];
    
    [request setValue:[[SCBSession sharedSession] userId] forHTTPHeaderField:@"usr_id"];
    [request setValue:CLIENT_TAG forHTTPHeaderField:@"client_tag"];
    [request setValue:[[SCBSession sharedSession] userToken] forHTTPHeaderField:@"usr_token"];
    [request setHTTPBody:myRequestData];
    [request setHTTPMethod:@"POST"];
    
    NSURLConnection * conn=[[[NSURLConnection alloc] initWithRequest:request delegate:self] autorelease];
    [body release];
}
-(void)releaseLinkEmail:(NSArray *)f_ids l_pwd:(NSString *)l_pwd receiver:(NSArray *)receiver
{
    self.lm_type=kLMTypeReleaseLinkEmail;
    self.activeData=[NSMutableData data];
    NSURL *s_url=[NSURL URLWithString:[NSString stringWithFormat:@"%@%@",SERVER_URL,LINK_RELEASE_EMAIL_URI]];
    NSMutableURLRequest *request=[NSMutableURLRequest requestWithURL:s_url cachePolicy:NSURLRequestReloadIgnoringLocalCacheData timeoutInterval:CONNECT_TIMEOUT];
    NSMutableString *body=[[NSMutableString alloc] init];
    NSString *fids=[f_ids componentsJoinedByString:@"&f_ids[]="];
    NSString *receivers=[receiver componentsJoinedByString:@"&receiver[]="];
    //NSString *lpwd=@"a1b2";
    NSString *lpwd=[NSString stringWithFormat:@"%c%d%c%d",(arc4random()%(122-96))+97,arc4random()%10,(arc4random()%(122-96))+97,arc4random()%10];
    [body appendFormat:@"f_ids[]=%@&l_pwd=%@&receiver[]=%@",fids,lpwd,receivers];
    NSLog(@"body: %@",body);
    NSMutableData *myRequestData=[NSMutableData data];
    [myRequestData appendData:[body dataUsingEncoding:NSUTF8StringEncoding]];
    
    [request setValue:[[SCBSession sharedSession] userId] forHTTPHeaderField:@"usr_id"];
    [request setValue:CLIENT_TAG forHTTPHeaderField:@"client_tag"];
    [request setValue:[[SCBSession sharedSession] userToken] forHTTPHeaderField:@"usr_token"];
    [request setHTTPBody:myRequestData];
    [request setHTTPMethod:@"POST"];
    
    NSURLConnection * conn=[[[NSURLConnection alloc] initWithRequest:request delegate:self] autorelease];
    [body release];
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
        switch (self.lm_type) {
            case kLMTypeReleaseLink:
                [self.delegate releaseLinkUnsuccess:@"网络有问题"];
                break;
            case kLMTypeReleaseLinkEmail:
                [self.delegate releaseLinkUnsuccess:@"网络有问题"];
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
            switch (self.lm_type) {
                case kLMTypeReleaseLink:
                    [self.delegate releaseLinkSuccess:[dic objectForKey:@"l_url"]];
                    break;
                case kLMTypeReleaseLinkEmail:
                    [self.delegate releaseEmailSuccess:[dic objectForKey:@"l_url"]];
                    break;
            }
        }
    }else
    {
        NSLog(@"操作失败 数据大小：%d",[self.activeData length]);
        if (self.delegate) {
            switch (self.lm_type) {
                case kLMTypeReleaseLink:
                {
                    NSString *info=(NSString *)[dic objectForKey:@"info"];
                    [self.delegate releaseLinkUnsuccess:info];
                }
                    break;
                case kLMTypeReleaseLinkEmail:
                {
                    NSString *info=(NSString *)[dic objectForKey:@"info"];
                    [self.delegate releaseLinkUnsuccess:info];
                }
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
