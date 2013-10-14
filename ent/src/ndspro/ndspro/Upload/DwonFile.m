//
//  DwonFile.m
//  ndspro
//
//  Created by Yangsl on 13-10-11.
//  Copyright (c) 2013年 fengyongning. All rights reserved.
//

#import "DwonFile.h"
#import "YNFunctions.h"
#import "SCBoxConfig.h"
#import "SCBSession.h"
#import "MF_Base64Additions.h"

@implementation DwonFile
@synthesize delegate;
@synthesize downsize;
@synthesize imageConnection;
@synthesize imageViewIndex;
@synthesize file_id;
@synthesize index;
@synthesize showType;
@synthesize indexPath;
@synthesize isStop;
@synthesize macTimeOut;
@synthesize fileSize;
@synthesize fileName;
@synthesize file_path;

- (void)startDownload
{
    NSString *path = [self get_image_save_file_path:file_id];
    //查询本地是否已经有该图片
    BOOL bl = [self image_exists_at_file_path:path];
    
    if(bl)
    {
        UIImage *image = [[UIImage alloc] initWithContentsOfFile:path];
        [delegate appImageDidLoad:imageViewIndex urlImage:image index:indexPath]; //将视图tag和地址派发给实现类
    }
    else
    {
        NSString *documentDir = [YNFunctions getProviewCachePath];
        NSArray *array=[fileName componentsSeparatedByString:@"/"];
        file_path = [NSString stringWithFormat:@"%@/%@",documentDir,[array lastObject]];
        assert(path!=nil);
        self.fileStream=[NSOutputStream outputStreamToFileAtPath:file_path append:NO];
        assert(self.fileStream!=nil);
        [self.fileStream open];
        NSURL *s_url=[NSURL URLWithString:[NSString stringWithFormat:@"%@%@?ent_uid=%@&fids[]=%@",SERVER_URL,FM_DOWNLOAD_URI,[NSString formatNSStringForOjbect:[[SCBSession sharedSession] userId]],file_id]];
        DDLogInfo(@"url:%@",s_url);
        NSMutableURLRequest *request=[[NSMutableURLRequest alloc] initWithURL:s_url cachePolicy:NSURLRequestReloadIgnoringLocalCacheData timeoutInterval:CONNECT_TIMEOUT];
        
        [request setHTTPMethod:@"GET"];
        imageConnection = [[NSURLConnection alloc] initWithRequest:request delegate:self];
    }
}

- (void)cancelDownload
{
    isStop = YES;
}

#pragma mark -
#pragma mark Download support (NSURLConnectionDelegate)

- (void)connection:(NSURLConnection *)connection didReceiveData:(NSData *)data
{
    DDLogInfo(@"下载的大小:%i",[data length]);
    downsize += [data length];
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
    
    
    NSCalendar *calendar = [NSCalendar currentCalendar];
    NSDate *todayDate = [NSDate date];
    NSDateComponents *todayComponent = [calendar components:NSEraCalendarUnit| NSYearCalendarUnit| NSMonthCalendarUnit| NSDayCalendarUnit| NSHourCalendarUnit| NSMinuteCalendarUnit | NSSecondCalendarUnit| NSWeekCalendarUnit | NSWeekdayCalendarUnit | NSWeekdayOrdinalCalendarUnit | NSQuarterCalendarUnit | NSWeekOfMonthCalendarUnit | NSWeekOfYearCalendarUnit | NSYearForWeekOfYearCalendarUnit fromDate:todayDate];
    if(endSecond==todayComponent.second)
    {
        return;
    }
    [delegate downFile:downsize totalSize:endSecond-[data length]];
    macTimeOut += 10;
    NSMutableURLRequest *request = (NSMutableURLRequest *)[connection currentRequest];
    [request setTimeoutInterval:macTimeOut];
    endSecond = todayComponent.second;
}

- (void)connection:(NSURLConnection *)connection didFailWithError:(NSError *)error
{
    DDLogInfo(@"eeor:%@",error);
    if(delegate && [delegate respondsToSelector:@selector(didFailWithError)])
    {
        [delegate didFailWithError];
    }
}

- (void)connectionDidFinishLoading:(NSURLConnection *)connection
{
    //下载完成
    if(file_path)
    {
        [delegate downFinish:file_path];
    }
}

- (void)connection:(NSURLConnection *)theConnection didReceiveResponse:(NSURLResponse *)response
{
    DDLogInfo(@"response:%@",response);
    NSHTTPURLResponse *ponse = (NSHTTPURLResponse *)response;
    if(ponse.statusCode == 404)
    {
        file_path = nil;
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

@end
