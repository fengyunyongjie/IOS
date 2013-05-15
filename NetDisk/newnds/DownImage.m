//
//  DownImage.m
//  NetDisk
//
//  Created by Yangsl on 13-5-6.
//
//

#import "DownImage.h"
#import "SCBoxConfig.h"
#import "SCBSession.h"
#import "MF_Base64Additions.h"
@implementation DownImage
@synthesize delegate;
@synthesize activeDownload;
@synthesize imageConnection;
@synthesize imageUrl;
@synthesize imageViewIndex;
@synthesize fileId;
@synthesize index;
@synthesize showType;

#pragma mark
- (void)dealloc
{
    [activeDownload release];
    [imageConnection cancel];
    [imageConnection release];
    [super dealloc];
}
- (void)startDownload
{
    //查询本地是否已经有该图片
    if([self image_exists_at_file_path:imageUrl])
    {
        NSString *path = [self get_image_save_file_path:imageUrl];
        NSLog(@"path:%@",path);
        UIImage *image = [[UIImage alloc] initWithContentsOfFile:path];
        [delegate appImageDidLoad:imageViewIndex urlImage:image index:index];
        [image release];
    }
    else
    {
        NSString *fielStirng = [NSString stringWithFormat:@"%i",self.fileId];
        fielStirng = [fielStirng base64String];
        NSURL *s_url=[NSURL URLWithString:[NSString stringWithFormat:@"%@%@?target=%@&default_pic=false",SERVER_URL,FM_DOWNLOAD_Look,fielStirng]];
        if(showType == 1)
        {
            s_url=[NSURL URLWithString:[NSString stringWithFormat:@"%@%@?target=%@",SERVER_URL,FM_DOWNLOAD_Look,fielStirng]];
        }
        NSMutableURLRequest *request=[NSMutableURLRequest requestWithURL:s_url cachePolicy:NSURLRequestReloadIgnoringLocalCacheData timeoutInterval:CONNECT_TIMEOUT];
        [request setValue:[[SCBSession sharedSession] userId] forHTTPHeaderField:@"usr_id"];
        [request setValue:CLIENT_TAG forHTTPHeaderField:@"client_tag"];
        [request setValue:[[SCBSession sharedSession] userToken] forHTTPHeaderField:@"usr_token"];
        [request setHTTPMethod:@"GET"];
        
        self.activeDownload = [NSMutableData data];
        NSURLConnection *conn = [[NSURLConnection alloc] initWithRequest:request delegate:self];
        
        self.imageConnection = conn;
        [conn release];
    }
    
}
- (void)cancelDownload
{
    [self.imageConnection cancel];
    self.imageConnection = nil;
    self.activeDownload = nil;
}
#pragma mark -
#pragma mark Download support (NSURLConnectionDelegate)
- (void)connection:(NSURLConnection *)connection didReceiveData:(NSData *)data
{
    [self.activeDownload appendData:data];
}
- (void)connection:(NSURLConnection *)connection didFailWithError:(NSError *)error
{
    self.activeDownload = nil;
    self.imageConnection = nil;
}

//下载完成后将图片写入黑盒子，
- (void)connectionDidFinishLoading:(NSURLConnection *)connection
{
    NSDictionary *diction = [NSJSONSerialization JSONObjectWithData:self.activeDownload options:NSJSONReadingMutableLeaves error:nil];
    if([[diction objectForKey:@"code"] intValue] == 3)
    {
        NSString *fielStirng = [NSString stringWithFormat:@"%i",self.fileId];
        fielStirng = [fielStirng base64String];
        NSURL *s_url=[NSURL URLWithString:[NSString stringWithFormat:@"%@%@?target=%@&default_pic=true",SERVER_URL,FM_DOWNLOAD_Look,fielStirng]];
        NSMutableURLRequest *request=[NSMutableURLRequest requestWithURL:s_url cachePolicy:NSURLRequestReloadIgnoringLocalCacheData timeoutInterval:CONNECT_TIMEOUT];
        [request setValue:[[SCBSession sharedSession] userId] forHTTPHeaderField:@"usr_id"];
        [request setValue:CLIENT_TAG forHTTPHeaderField:@"client_tag"];
        [request setValue:[[SCBSession sharedSession] userToken] forHTTPHeaderField:@"usr_token"];
        [request setHTTPMethod:@"GET"];
        
        self.activeDownload = [NSMutableData data];
        NSURLConnection *conn = [[NSURLConnection alloc] initWithRequest:request delegate:self];
        
        self.imageConnection = conn;
        [conn release];
    }
    else
    {
        UIImage *image = [[UIImage alloc] initWithData:self.activeDownload];
        newDownImage=image;
        NSArray *documentPaths = NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES);
        NSString *documentDir = [documentPaths objectAtIndex:0];
        NSArray *array=[imageUrl componentsSeparatedByString:@"/"];
        NSString *path=[NSString stringWithFormat:@"%@/%@",documentDir,[array lastObject]];
        [activeDownload writeToFile:path atomically:YES];
        NSString *urlpath = [NSString stringWithFormat:@"%@",path];
        NSLog(@"urlpath:%@",urlpath);
        self.activeDownload = nil;
        self.imageConnection = nil;
        [delegate appImageDidLoad:imageViewIndex urlImage:image index:index]; //将视图tag和地址派发给实现类
        [image release];
    }
}

//这个路径下是否存在此图片
- (BOOL)image_exists_at_file_path:(NSString *)image_path
{
    NSFileManager *file_manager = [NSFileManager defaultManager];
    NSArray *path_array = NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES);
    NSString *documentDir = [path_array objectAtIndex:0];
    NSArray *array=[image_path componentsSeparatedByString:@"/"];
    NSString *path=[NSString stringWithFormat:@"%@/%@",documentDir,[array lastObject]];
    return [file_manager fileExistsAtPath:path];
}


//获取图片路径
- (NSString*)get_image_save_file_path:(NSString*)image_path
{
    NSArray *path_array = NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES);
    NSString *documentDir = [path_array objectAtIndex:0];
    NSArray *array=[image_path componentsSeparatedByString:@"/"];
    NSString *path=[NSString stringWithFormat:@"%@/%@",documentDir,[array lastObject]];
    return path;
}

@end
