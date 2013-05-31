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
    
    // call our delegate and tell it that our icon is ready for display
    if (self.delegate)
    {
        if ([self.delegate respondsToSelector:@selector(appImageDidLoad:)]) {
            [self.delegate appImageDidLoad:self.indexPathInTableView];
        }
    
    }
}
@end
