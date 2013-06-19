//
//  SCBDownloader.m
//  NetDisk
//
//  Created by fengyongning on 13-4-15.
//
//

#import "SCBDownloader.h"
#import "SCBoxConfig.h"
#import "SCBSession.h"

@implementation SCBDownloader

@synthesize index;
@synthesize delegate;
@synthesize fileId=_f_id;
@synthesize savedPath=_savedPath;
@synthesize activeDownload;
@synthesize fileConnection;
-(void)dealloc
{
    [activeDownload release];
    [fileConnection cancel];
    [fileConnection release];
    [super dealloc];
}
-(void)startDownload
{
    self.tempSavedPath=[self.savedPath stringByAppendingPathComponent:@".download"];
    self.activeDownload=[NSMutableData data];
    NSURL *s_url=[NSURL URLWithString:[NSString stringWithFormat:@"%@%@?f_id=%@&f_skip=%d",SERVER_URL,FM_DOWNLOAD_URI,self.fileId,0]];
    NSMutableURLRequest *request=[NSMutableURLRequest requestWithURL:s_url cachePolicy:NSURLRequestReloadIgnoringLocalCacheData timeoutInterval:CONNECT_TIMEOUT];
    NSMutableString *body=[[NSMutableString alloc] init];
    [body appendFormat:@"f_id=%@&f_skip=%d",self.fileId,0];
    NSMutableData *myRequestData=[NSMutableData data];
    [myRequestData appendData:[body dataUsingEncoding:NSUTF8StringEncoding]];
    //[request setHTTPBody:myRequestData];
    [request setValue:[[SCBSession sharedSession] userId] forHTTPHeaderField:@"usr_id"];
    [request setValue:CLIENT_TAG forHTTPHeaderField:@"client_tag"];
    [request setValue:[[SCBSession sharedSession] userToken] forHTTPHeaderField:@"usr_token"];
    [request setHTTPMethod:@"GET"];
    NSURLConnection *conn=[[NSURLConnection alloc] initWithRequest:request delegate:self];
    //[conn start];
    self.fileConnection=conn;
    [conn release];
    NSLog(@"%@",request);
    NSLog(@"%@",[[NSString alloc] initWithData:request.HTTPBody encoding:NSUTF8StringEncoding]);
    NSLog(@"%@",request.allHTTPHeaderFields);
    NSLog(@"httpbody : %@",body);
    NSLog(@"usr_id : %@",[[SCBSession sharedSession] userId]);
    NSLog(@"client_tag : %@",CLIENT_TAG);
    NSLog(@"usr_token : %@",[[SCBSession sharedSession] userToken]);
    
    
}
-(void)cancelDownload
{
    [fileConnection cancel];
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
        int code=-1;
        code=[[httpResponseHeaderFields objectForKey:@"code"] intValue];
        switch (code) {
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
    [data writeToFile:self.tempSavedPath atomically:NO];
    NSLog(@"connection:didReceiveData:");
    if (delegate) {
        [delegate updateProgress:[self.activeDownload length] index:self.index];
    }
}

- (void)connection:(NSURLConnection *)connection didFailWithError:(NSError *)error
{
    if (self.delegate) {
        if ([(NSObject *)self.delegate respondsToSelector:@selector(downloadFail)]) {
            [self.delegate downloadFail];
        }
    }
	// Clear the activeDownload property to allow later attempts
    self.activeDownload = nil;
    
    // Release the connection now that it's finished
    self.fileConnection = nil;
    NSLog(@"connection:didFailWithError");
}

- (void)connectionDidFinishLoading:(NSURLConnection *)connection
{
    // Set appIcon and clear temporary data/image
//    UIImage *image = [[UIImage alloc] initWithData:self.activeDownload];
//    
//    if (image.size.width != kAppIconSize || image.size.height != kAppIconSize)
//	{
//        CGSize itemSize = CGSizeMake(kAppIconSize, kAppIconSize);
//		UIGraphicsBeginImageContext(itemSize);
//		CGRect imageRect = CGRectMake(0.0, 0.0, itemSize.width, itemSize.height);
//		[image drawInRect:imageRect];
//		self.appRecord.appIcon = UIGraphicsGetImageFromCurrentImageContext();
//		UIGraphicsEndImageContext();
//    }
//    else
//    {
//        self.appRecord.appIcon = image;
//    }
    
//    self.activeDownload = nil;
//    [image release];
    
    // Release the connection now that it's finished
    self.fileConnection = nil;
    
    // call our delegate and tell it that our icon is ready for display
    //[delegate fileDidDownload:self.index];
    NSLog(@"connectionDidFinishLoading");
    //UIImage *image=[[UIImage alloc] initWithData:self.activeDownload];
    [self.activeDownload writeToFile:self.savedPath atomically:YES];
    if (delegate) {
        [delegate fileDidDownload:self.index];
    }
    
}
@end
