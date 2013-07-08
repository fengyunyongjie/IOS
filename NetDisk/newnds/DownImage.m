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
#import "YNFunctions.h"
#import "AppDelegate.h"

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
    NSLog(@"下载类死亡：%i,%i",activeDownload.retainCount,imageConnection.retainCount);
    [activeDownload release];
    [imageConnection release];
    [imageUrl release];
    [super dealloc];
}
- (void)startDownload
{
    AppDelegate *apple = (AppDelegate *)[[UIApplication sharedApplication] delegate];
    [apple setIsDownImageIsNil:FALSE];
    NSString *path = [self get_image_save_file_path:imageUrl];
    //查询本地是否已经有该图片
    BOOL bl = [self image_exists_at_file_path:path];
    
    if(bl)
    {
        UIImage *image = [[UIImage alloc] initWithContentsOfFile:path];
        [delegate appImageDidLoad:imageViewIndex urlImage:image index:index]; //将视图tag和地址派发给实现类
        [image release];
    }
    else
    {
        activeDownload = [[NSMutableData alloc] init];
        
        if(showType == 0)
        {
            NSString *fielStirng = [NSString stringWithFormat:@"%i",self.fileId];
            NSURL *s_url=[NSURL URLWithString:[NSString stringWithFormat:@"%@%@?image_size=M",SERVER_URL,FM_DOWNLOAD_THUMB_URI_NEW]];
//            NSURL *s_url=[NSURL URLWithString:[NSString stringWithFormat:@"%@%@",SERVER_URL,FM_DOWNLOAD_THUMB_URI]];
            NSMutableURLRequest *request=[[NSMutableURLRequest alloc] initWithURL:s_url cachePolicy:NSURLRequestReloadIgnoringLocalCacheData timeoutInterval:CONNECT_TIMEOUT];
            [request setValue:[[SCBSession sharedSession] userId] forHTTPHeaderField:@"usr_id"];
            [request setValue:CLIENT_TAG forHTTPHeaderField:@"client_tag"];
            [request setValue:[[SCBSession sharedSession] userToken] forHTTPHeaderField:@"usr_token"];
            [request setValue:fielStirng forHTTPHeaderField:@"f_id"];
            [request setHTTPMethod:@"GET"];
            imageConnection = [[NSURLConnection alloc] initWithRequest:request delegate:self];
            [request release];
        }
        else
        {
            NSString *fielStirng = [[NSString stringWithFormat:@"%i",self.fileId] base64String];
            NSURL *s_url=[NSURL URLWithString:[NSString stringWithFormat:@"%@%@?target=%@&default_pic=false",SERVER_URL,FM_DOWNLOAD_Look,fielStirng]];
            if(showType == 1)
            {
                s_url=[NSURL URLWithString:[NSString stringWithFormat:@"%@%@?target=%@",SERVER_URL,FM_DOWNLOAD_Look,fielStirng]];
            }
            NSMutableURLRequest *request=[[NSMutableURLRequest alloc] initWithURL:s_url cachePolicy:NSURLRequestReloadIgnoringLocalCacheData timeoutInterval:CONNECT_TIMEOUT];
            [request setValue:[[SCBSession sharedSession] userId] forHTTPHeaderField:@"usr_id"];
            [request setValue:CLIENT_TAG forHTTPHeaderField:@"client_tag"];
            [request setValue:[[SCBSession sharedSession] userToken] forHTTPHeaderField:@"usr_token"];
            [request setHTTPMethod:@"GET"];
            imageConnection = [[NSURLConnection alloc] initWithRequest:request delegate:self];
            [request release];
            NSLog(@"fielStirng:%i",fielStirng.retainCount);
        }
    }
}

- (void)cancelDownload
{
    [imageConnection cancel];
}
#pragma mark -
#pragma mark Download support (NSURLConnectionDelegate)
- (void)connection:(NSURLConnection *)connection didReceiveData:(NSData *)data
{
    [activeDownload appendData:data];
}
- (void)connection:(NSURLConnection *)connection didFailWithError:(NSError *)error
{
    NSLog(@"重新下载图片");
    if(activeDownload)
    {
        [activeDownload release];
    }
    if(imageConnection)
    {
        [imageConnection release];
    }
    activeDownload = [[NSMutableData alloc] init];
    if(![[self GetCurrntNet] isEqualToString:@"没有网络链接"])
    {
        NSString *fielStirng = [NSString stringWithFormat:@"%i",self.fileId];
        NSURL *s_url=[NSURL URLWithString:[NSString stringWithFormat:@"%@%@?image_size=M",SERVER_URL,FM_DOWNLOAD_THUMB_URI]];
        NSMutableURLRequest *request=[[NSMutableURLRequest alloc] initWithURL:s_url cachePolicy:NSURLRequestReloadIgnoringLocalCacheData timeoutInterval:CONNECT_TIMEOUT];
        [request setValue:[[SCBSession sharedSession] userId] forHTTPHeaderField:@"usr_id"];
        [request setValue:CLIENT_TAG forHTTPHeaderField:@"client_tag"];
        [request setValue:[[SCBSession sharedSession] userToken] forHTTPHeaderField:@"usr_token"];
        [request setValue:fielStirng forHTTPHeaderField:@"f_id"];
        [request setHTTPMethod:@"GET"];
        
        imageConnection = [[NSURLConnection alloc] initWithRequest:request delegate:self];
        [request release];
    }
}

//下载完成后将图片写入黑盒子，
- (void)connectionDidFinishLoading:(NSURLConnection *)connection
{
    NSDictionary *diction = [NSJSONSerialization JSONObjectWithData:self.activeDownload options:NSJSONReadingMutableLeaves error:nil];
    NSLog(@"connectionDidFinishLoading:%@.length:%i",diction,[activeDownload length]);
    if([[diction objectForKey:@"code"] intValue] == 1 || [[diction objectForKey:@"code"] intValue] == 3 )
    {
        [self connection:nil didFailWithError:nil];
    }
    else
    {
        NSString *documentDir = [YNFunctions getProviewCachePath];
        NSArray *array=[imageUrl componentsSeparatedByString:@"/"];
        NSString *path=[NSString stringWithFormat:@"%@/%@",documentDir,[array lastObject]];
        [activeDownload writeToFile:path atomically:YES];
        UIImage  *image = [[UIImage alloc] initWithContentsOfFile:path];
        AppDelegate *apple = (AppDelegate *)[[UIApplication sharedApplication] delegate];
        if(!apple.isDownImageIsNil)
        {
            if(delegate && [delegate respondsToSelector:@selector(appImageDidLoad:urlImage:index:)])
            {
                [delegate appImageDidLoad:imageViewIndex urlImage:image index:index]; //将视图tag和地址派发给实现类
            }
        }
        else
        {
            NSLog(@"不能添加图片了－－－－－－－－－－－－－－－－");
        }
        NSLog(@"image:%i",image.retainCount);
        [image release];
    }
}

//这个路径下是否存在此图片
- (BOOL)image_exists_at_file_path:(NSString *)image_path
{
    NSFileManager *file_manager = [NSFileManager defaultManager];
    NSString *documentDir = [YNFunctions getProviewCachePath];
    NSArray *array=[image_path componentsSeparatedByString:@"/"];
    NSString *path=[NSString stringWithFormat:@"%@/%@",documentDir,[array lastObject]];
    return [file_manager fileExistsAtPath:path];
}


//获取图片路径
- (NSString*)get_image_save_file_path:(NSString*)image_path
{
    NSString *documentDir = [YNFunctions getProviewCachePath];
    NSArray *array=[image_path componentsSeparatedByString:@"/"];
    NSString *path=[NSString stringWithFormat:@"%@/%@",documentDir,[array lastObject]];
    return path;
}

//判断当前的网络是3g还是wifi
-(NSString*) GetCurrntNet
{
    NSString *connectionKind;
    Reachability *hostReach = [Reachability reachabilityWithHostName:@"www.google.com"];
    switch ([hostReach currentReachabilityStatus]) {
        case NotReachable:
        {
            connectionKind = @"没有网络链接";
        }
            break;
        case ReachableViaWiFi:
        {
            connectionKind = @"WIFI";
        }
            break;
        case ReachableViaWWAN:
        {
            connectionKind = @"WLAN";
        }
            break;
        default:
            break;
    }
    return connectionKind;
}

@end
