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
    self.activeDownload=[NSMutableData data];
    BOOL success;
    NSURL *url;
    NSURLRequest *request;
    
    assert(self.imageConnection == nil);         // don't tap receive twice in a row!
    assert(self.fileStream == nil);         // ditto
    assert(self.filePath == nil);           // ditto
    
    NSString *fthumb=[self.data_dic objectForKey:@"fthumb"];
    url=[NSURL URLWithString:[NSString stringWithFormat:@"%@%@",HOST_URL,fthumb]];
    NSLog(@"下载文件：%@",url);
    success=(url!=nil);
    if (!success) {
        //如果Url为URL 提示无效的URL
        NSLog(@"无效的URL");
    }else{
        NSString *fthumb=[self.data_dic objectForKey:@"fthumb"];
        //compressaddr =[YNFunctions picFileNameFromURL:compressaddr];
        NSString *path=[YNFunctions getIconCachePath];
        fthumb=[YNFunctions picFileNameFromURL:fthumb];
        path=[path stringByAppendingPathComponent:fthumb];
        self.filePath=path;
        assert(self.filePath!=nil);
        self.fileStream=[NSOutputStream outputStreamToFileAtPath:self.filePath append:NO];
        assert(self.fileStream!=nil);
        [self.fileStream open];
        request=[NSURLRequest requestWithURL:url];
        assert(request!=nil);
        self.imageConnection=[NSURLConnection connectionWithRequest:request delegate:self];
        assert(self.imageConnection!=nil);
    }
//    [request setValue:[[SCBSession sharedSession] userId] forHTTPHeaderField:@"usr_id"];
//    [request setValue:CLIENT_TAG forHTTPHeaderField:@"client_tag"];
//    [request setValue:[[SCBSession sharedSession] userToken] forHTTPHeaderField:@"usr_token"];
//    NSString *theFID=[NSString stringWithFormat:@"%@",f_id];
//    [request setValue:theFID forHTTPHeaderField:@"f_id"];
//    [request setHTTPMethod:@"GET"];
//    NSLog(@"%@",[request allHTTPHeaderFields]);
//    NSURLConnection *conn=[[NSURLConnection alloc] initWithRequest:request delegate:self];
    //[conn start];
//    self.imageConnection=conn;
}
- (void)cancelDownload
{
    [self.imageConnection cancel];
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
    
    assert(theConnection == self.imageConnection);
    
    httpResponse = (NSHTTPURLResponse *) response;
    assert( [httpResponse isKindOfClass:[NSHTTPURLResponse class]] );
    
    if ((httpResponse.statusCode / 100) != 2) {
        NSLog(@"HTTP error %zd",(ssize_t)httpResponse.statusCode);
    } else {
        NSLog(@"Response OK.");
    }
    if (httpResponse && [httpResponse respondsToSelector:@selector(allHeaderFields)]) {
        NSDictionary *httpResponseHeaderFields=[httpResponse allHeaderFields];
        self.code=-1;
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
            case -1:
                NSLog(@"-1：示获取到值");
                break;
            default:
                break;
        }
    }
}

- (void)connection:(NSURLConnection *)connection didReceiveData:(NSData *)data
{
    #pragma unused(connection)
    NSInteger       dataLength;
    const uint8_t * dataBytes;
    NSInteger       bytesWritten;
    NSInteger       bytesWrittenSoFar;
    
    assert(connection == self.imageConnection);
    
    dataLength = [data length];
    dataBytes  = [data bytes];
    
    bytesWrittenSoFar = 0;
    do {
        bytesWritten = [self.fileStream write:&dataBytes[bytesWrittenSoFar] maxLength:dataLength - bytesWrittenSoFar];
        assert(bytesWritten != 0);
        if (bytesWritten == -1) {
            //[self stopReceiveWithStatus:@"File write error"];
            break;
        } else {
            bytesWrittenSoFar += bytesWritten;
        }
    } while (bytesWrittenSoFar != dataLength);
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
    #pragma unused(connection)
    assert(connection == self.imageConnection);
//    NSString *fthumb=[self.data_dic objectForKey:@"fthumb"];
    //compressaddr =[YNFunctions picFileNameFromURL:compressaddr];
//    NSString *path=[YNFunctions getIconCachePath];
//    path=[path stringByAppendingPathComponent:fthumb];
//    [self.activeDownload writeToFile:path atomically:YES];
    self.activeDownload = nil;
    
    // Release the connection now that it's finished
    self.imageConnection = nil;
    
    // call our delegate and tell it that our icon is ready for display
    if (self.delegate)
    {
        @try {
            [self.delegate appImageDidLoad:self.indexPathInTableView];
        }
        @catch (NSException *exception) {
        }
        @finally {
        }
    }
}
@end
