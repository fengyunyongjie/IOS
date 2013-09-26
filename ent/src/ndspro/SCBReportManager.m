//
//  SCBReportManager.m
//  NetDisk
//
//  Created by fengyongning on 13-8-14.
//
//
#import "SCBoxConfig.h"
#import "SCBSession.h"
#import "SCBReportManager.h"

@implementation SCBReportManager
-(void)callAllTask
{
    self.delegate=nil;
}
-(void)sendReport:(NSString *)report
{
    self.activeData=[NSMutableData data];
    self.type=kReportSend;
    NSURL *s_url= [NSURL URLWithString:[NSString stringWithFormat:@"%@%@",SERVER_URL,REPORT_ADVICE_URI]];
    NSMutableURLRequest *request=[NSMutableURLRequest requestWithURL:s_url cachePolicy:NSURLRequestReloadIgnoringLocalCacheData timeoutInterval:CONNECT_TIMEOUT];
    NSMutableString *body=[[NSMutableString alloc] init];
    [body appendFormat:@"advice=%@",report];
    NSMutableData *myRequestData=[NSMutableData data];
    [myRequestData appendData:[body dataUsingEncoding:NSUTF8StringEncoding]];
    [request setHTTPBody:myRequestData];
    [request setValue:CLIENT_TAG forHTTPHeaderField:@"client_tag"];
    [request setValue:[[SCBSession sharedSession] userId] forHTTPHeaderField:@"usr_id"];
    [request setValue:[[SCBSession sharedSession] userToken] forHTTPHeaderField:@"usr_token"];
    [request setHTTPMethod:@"POST"];
    [[NSURLConnection alloc] initWithRequest:request delegate:self];

}
#pragma mark NSURLConnectionDelegate Method
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

- (void)connection:(NSURLConnection *)theConnection didReceiveData:(NSData *)data
// A delegate method called by the NSURLConnection as data arrives.  The
// response data for a POST is only for useful for debugging purposes,
// so we just drop it on the floor.
{
    [self.activeData appendData:data];
    NSLog(@"connection:didReceiveData:");
    //    assert(theConnection == self.connection);
    
    // do nothing
}

- (void)connection:(NSURLConnection *)theConnection didFailWithError:(NSError *)error
// A delegate method called by the NSURLConnection if the connection fails.
// We shut down the connection and display the failure.  Production quality code
// would either display or log the actual error.
{
    NSLog(@"connection:didFailWithError");
#pragma unused(theConnection)
#pragma unused(error)
    //    assert(theConnection == self.connection);
    //
    //    [self stopSendWithStatus:@"Connection failed"];
    switch (self.type) {
        case kReportSend:
            [self.delegate sendReportUnsucceed];
            break;
        default:
            break;
    }
}

- (void)connectionDidFinishLoading:(NSURLConnection *)theConnection
// A delegate method called by the NSURLConnection when the connection has been
// done successfully.  We shut down the connection with a nil status, which
// causes the image to be displayed.
{
    NSLog(@"connectionDidFinishLoading");
    NSError *jsonParsingError=nil;
    if (self.activeData==nil) {
        NSLog(@"!!!数据错误!!");
        return;
    }
    NSDictionary *dic=[NSJSONSerialization JSONObjectWithData:self.activeData options:0 error:&jsonParsingError];
    NSLog(@"%@",dic);
    if ([[dic objectForKey:@"code"] intValue]==0) {
    }else
    {
        NSLog(@"网络操作失败：");
    }
    switch (self.type) {
        case kReportSend:
            if ([[dic objectForKey:@"code"] intValue]==0) {
                [self.delegate sendReportSucceed];
            }else
            {
                [self.delegate sendReportUnsucceed];
            }
            break;
        
        default:
            break;
    }
    self.activeData=nil;
}
@end
