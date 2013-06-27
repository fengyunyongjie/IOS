//
//  IconDownloader.m
//  NetDisk
//
//  Created by fengyongning on 13-5-17.
//
//

#import "IconDownloader.h"
#import "SCBoxConfig.h"
#import "SCBSession.h"
#import "YNFunctions.h"

@implementation IconDownloader
- (void)startDownload
{
    NSString *f_id=[self.data_dic objectForKey:@"f_id"];
    NSLog(@"%@",f_id);
    self.activeDownload=[NSMutableData data];
    NSURL *s_url=[NSURL URLWithString:[NSString stringWithFormat:@"%@%@",SERVER_URL,FM_DOWNLOAD_THUMB_URI]];
    NSMutableURLRequest *request=[NSMutableURLRequest requestWithURL:s_url cachePolicy:NSURLRequestReloadIgnoringLocalCacheData timeoutInterval:CONNECT_TIMEOUT];
//    NSMutableString *body=[[NSMutableString alloc] init];
//    [body appendFormat:@"f_id=%@&f_skip=%d",f_id,0];
//    NSMutableData *myRequestData=[NSMutableData data];
//    [myRequestData appendData:[body dataUsingEncoding:NSUTF8StringEncoding]];
    //[request setHTTPBody:myRequestData];
    [request setValue:[[SCBSession sharedSession] userId] forHTTPHeaderField:@"usr_id"];
    [request setValue:CLIENT_TAG forHTTPHeaderField:@"client_tag"];
    [request setValue:[[SCBSession sharedSession] userToken] forHTTPHeaderField:@"usr_token"];
    NSString *theFID=[NSString stringWithFormat:@"%@",f_id];
    [request setValue:theFID forHTTPHeaderField:@"f_id"];
    [request setHTTPMethod:@"GET"];
    NSLog(@"%@",[request allHTTPHeaderFields]);
    NSURLConnection *conn=[[NSURLConnection alloc] initWithRequest:request delegate:self];
    //[conn start];
    self.imageConnection=conn;
    [conn release];
}
-(void)dealloc
{
    [self cancelDownload];
    [super dealloc];
}
- (void)cancelDownload
{
    [self.imageConnection cancel];
    self.delegate=nil;
}
#pragma mark -
#pragma mark Download support (NSURLConnectionDelegate)
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
    if (httpResponse && [httpResponse respondsToSelector:@selector(allHeaderFields)]) {
        NSDictionary *httpResponseHeaderFields=[httpResponse allHeaderFields];
        self.code=[[httpResponseHeaderFields objectForKey:@"code"] intValue];
        switch (self.code) {
            case 0:
                NSLog(@"0：下载请求成功");
                break;
            case 1:
                NSLog(@"1：失败-服务端异常");
                break;
            case 2:
                NSLog(@"2：无效的文件id（id不存在）");
                break;
            case 3:
                NSLog(@"3：无权访问的文件id（非自己的文件、别人的 没有共享关系的文件）");
                break;
            default:
                break;
        }
    }
}

- (void)connection:(NSURLConnection *)connection didReceiveData:(NSData *)data
{
    [self.activeDownload appendData:data];
}

- (void)connection:(NSURLConnection *)connection didFailWithError:(NSError *)error
{
    NSLog(@"connection:didFailWithError");
	// Clear the activeDownload property to allow later attempts
    self.activeDownload = nil;
    
    // Release the connection now that it's finished
    self.imageConnection = nil;
}

- (void)connectionDidFinishLoading:(NSURLConnection *)connection
{
    NSString *compressaddr=[self.data_dic objectForKey:@"compressaddr"];
    compressaddr =[YNFunctions picFileNameFromURL:compressaddr];
    NSString *path=[YNFunctions getIconCachePath];
    path=[path stringByAppendingPathComponent:compressaddr];
    [self.activeDownload writeToFile:path atomically:YES];
    self.activeDownload = nil;
    
    // Release the connection now that it's finished
    self.imageConnection = nil;
    if (self.code!=0) {
        return;
    }
    // call our delegate and tell it that our icon is ready for display
    if (self.delegate)
    {
        if ([self.delegate respondsToSelector:@selector(appImageDidLoad:)]) {
            [self.delegate appImageDidLoad:self.indexPathInTableView];
        }
    }
}
@end
