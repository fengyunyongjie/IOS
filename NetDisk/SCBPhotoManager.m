//
//  SCBPhotoManager.m
//  NetDisk
//
//  Created by fengyongning on 13-4-15.
//
//

#import "SCBPhotoManager.h"
#import "SCBSession.h"
#import "SCBoxConfig.h"
#import "PhohoDemo.h"

@implementation SCBPhotoManager
@synthesize photoDelegate;

#pragma mark 获取时间分组
-(void)getPhotoTimeLine
{
    NSURL *s_url=[NSURL URLWithString:[NSString stringWithFormat:@"%@%@",SERVER_URL,PHOTO_TIMERLINE]];
    NSMutableURLRequest *request=[NSMutableURLRequest requestWithURL:s_url cachePolicy:NSURLRequestReloadIgnoringLocalCacheData timeoutInterval:CONNECT_TIMEOUT];
    url_string = PHOTO_TIMERLINE;
//    NSMutableString *body=[[NSMutableString alloc] init];
//    [body appendFormat:@"f_id=%@&cursor=%d&offset=%d",@"1",0,-1];
//    NSMutableData *myRequestData=[NSMutableData data];
//    [myRequestData appendData:[body dataUsingEncoding:NSUTF8StringEncoding]];
    if(matableData==nil)
    {
        matableData = [[NSMutableData alloc] init];
    }
    else
    {
        [matableData release];
        matableData = [[NSMutableData alloc] init];
    }
    
    [request setValue:[[SCBSession sharedSession] userId] forHTTPHeaderField:@"usr_id"];
    [request setValue:CLIENT_TAG forHTTPHeaderField:@"client_tag"];
    [request setValue:[[SCBSession sharedSession] userToken] forHTTPHeaderField:@"usr_token"];
    [request setHTTPMethod:@"POST"];
    
    [[[NSURLConnection alloc] initWithRequest:request delegate:self] autorelease];
}

#pragma mark 获取所有时间轴上的照片信息
-(void)getAllPhotoGeneral:(NSArray *)timeLineArray
{
    timeDictionary = [[NSMutableDictionary alloc] init];
    timeLineAllArray = timeLineArray;
    timeLineTotalNumber = [timeLineArray count];
    if(matableData==nil)
    {
        matableData = [[NSMutableData alloc] init];
    }
    else
    {
        [matableData release];
        matableData = [[NSMutableData alloc] init];
    }
    timeLineNowNumber = 0;
    [self getPhotoGeneral];
    
}

#pragma mark 获取按年或月查询的概要照片
-(void)getPhotoGeneral
{
    NSURL *s_url=[NSURL URLWithString:[NSString stringWithFormat:@"%@%@",SERVER_URL,PHOTO_GENERAL]];
    NSMutableURLRequest *request=[NSMutableURLRequest requestWithURL:s_url cachePolicy:NSURLRequestReloadIgnoringLocalCacheData timeoutInterval:CONNECT_TIMEOUT];
    url_string = PHOTO_GENERAL;
    NSMutableString *body=[[NSMutableString alloc] init];
    [body appendFormat:@"date=%@&maxNum=100",[timeLineAllArray objectAtIndex:timeLineNowNumber]];
    NSMutableData *myRequestData=[NSMutableData data];
    [myRequestData appendData:[body dataUsingEncoding:NSUTF8StringEncoding]];
    
    [request setValue:[[SCBSession sharedSession] userId] forHTTPHeaderField:@"usr_id"];
    [request setValue:CLIENT_TAG forHTTPHeaderField:@"client_tag"];
    [request setValue:[[SCBSession sharedSession] userToken] forHTTPHeaderField:@"usr_token"];
    [request setHTTPMethod:@"POST"];
    NSLog(@"%@,%@",[[SCBSession sharedSession] userId],[[SCBSession sharedSession] userToken]);
    [request setHTTPBody:myRequestData];
    timeLineNowNumber++;
    [[[NSURLConnection alloc] initWithRequest:request delegate:self] autorelease];
}

#pragma mark 处理返回的数据
-(void)mangerGobackData:(NSDictionary *)dictionary
{
    NSLog(@"dictionary:%@",dictionary);
    
    if([[dictionary objectForKey:@"photos"] isKindOfClass:[NSArray class]])
    {
        NSArray *photosArray = [dictionary objectForKey:@"photos"];
        for(int i=0;i<[photosArray count];i++)
        {
            NSDictionary *photosDiction = [photosArray objectAtIndex:i];
            if([[photosDiction objectForKey:@"list"] isKindOfClass:[NSArray class]])
            {
                NSArray *array_dict = [photosDiction objectForKey:@"list"];
                NSMutableArray *tableArray = [[NSMutableArray alloc] init];
                NSString *string_date;
                for(int j=0;j<[array_dict count];j++)
                {
                    PhohoDemo *photo_demo = [[PhohoDemo alloc] init];
                    [photo_demo setTotal:[[photosDiction objectForKey:@"total"] intValue]];
                    NSDictionary *dict = [array_dict objectAtIndex:j];
                    NSLog(@"[dateFormatter dateFromString:string_date]:%@",dict);
                    [photo_demo setF_mime:[dict objectForKey:@"f_mime"]];
                    [photo_demo setF_size:[[dict objectForKey:@"f_size"] intValue]];
                    [photo_demo setF_name:[dict objectForKey:@"f_name"]];
                    [photo_demo setF_pid:[[dict objectForKey:@"f_pid"] intValue]];
                    if([[dict objectForKey:@"img_create"] isKindOfClass:[NSString class]])
                    {
                        [photo_demo setImg_create:[dict objectForKey:@"img_create"]];
                    }
                    [photo_demo setF_create:[dict objectForKey:@"f_create"]];
                    string_date = photo_demo.f_create;
                    [photo_demo setF_id:[[dict objectForKey:@"f_id"] intValue]];
                    [photo_demo setF_mime:[dict objectForKey:@"f_modify"]];
                    [photo_demo setCompressaddr:[dict objectForKey:@"compressaddr"]];
                    [photo_demo setF_ownerid:[[dict objectForKey:@"f_ownerid"] intValue]];
                    [tableArray addObject:photo_demo];
                    [photo_demo release];
                }
                
                NSDateFormatter *dateFormatter = [[[NSDateFormatter alloc] init] autorelease];
                [dateFormatter setDateStyle:NSDateFormatterMediumStyle];
                [dateFormatter setTimeStyle:NSDateFormatterShortStyle];
                [dateFormatter setDateFormat:@"yyyy-MM-dd HH:mm:ss"];
                NSDate *date_string = [dateFormatter dateFromString:string_date];
                NSString *date_type = [self getNowTimeLineForType:date_string];
                [timeDictionary setObject:tableArray forKey:date_type];
                NSLog(@"timeDictionary:%@",timeDictionary);
                [tableArray release];
            }
        }

    }
}

#pragma mark -请求成功后，分发数据
- (void)connection:(NSURLConnection *)connection didReceiveData:(NSData *)data
{
    [matableData appendData:data];
}

- (void)connectionDidFinishLoading:(NSURLConnection *)connection
{
    NSDictionary *diction = [NSJSONSerialization JSONObjectWithData:matableData options:NSJSONReadingMutableLeaves error:nil];
    NSLog(@"请求成功后，分发数据:%@",diction);
    NSString *type_string = [[[[[connection originalRequest] URL] path] componentsSeparatedByString:@"/"] lastObject];
    if([type_string isEqualToString:[[PHOTO_TIMERLINE componentsSeparatedByString:@"/"] lastObject]])
    {
        [photoDelegate getPhotoTiimeLine:diction];
    }
    else if([type_string isEqualToString:[[PHOTO_GENERAL componentsSeparatedByString:@"/"] lastObject]])
    {
        [self mangerGobackData:diction];
        if(timeLineNowNumber<timeLineTotalNumber)
        {
            [self getPhotoGeneral];
        }
        else
        {
            [photoDelegate getPhotoGeneral:timeDictionary];
        }
    }
    else if([type_string isEqualToString:[[PHOTO_DETAIL componentsSeparatedByString:@"/"] lastObject]])
    {
        [photoDelegate getPhotoDetail:diction];
    }
}

#pragma mark 判断当前时间属于哪一类
-(NSString *)getNowTimeLineForType:(NSDate *)date
{
    //得到当前时间戳
    NSDate *today = [NSDate date];
    NSInteger todayInteger = [today timeIntervalSince1970];
    NSInteger bodyInteger = [date timeIntervalSince1970];
    NSInteger compareInteger = todayInteger-bodyInteger;
    //今天
    if(compareInteger<24*60*60)
    {
        return @"今天";
    }
    //昨天
    if(compareInteger<2*24*60*60)
    {
        return @"昨天";
    }
    //本周
    if(compareInteger<7*24*60*60)
    {
        return @"本周";
    }
    //上一周
    if(compareInteger<14*24*60*60)
    {
        return @"上一周";
    }
    //本月
    if(compareInteger<[self getNowMonthToManyDay]*24*60*60)
    {
        return @"本月";
    }
    //上一月
    NSDateFormatter *dateFormatter = [[[NSDateFormatter alloc] init] autorelease];
    [dateFormatter setDateStyle:NSDateFormatterMediumStyle];
    [dateFormatter setTimeStyle:NSDateFormatterShortStyle];
    [dateFormatter setDateFormat:@"yyyy"];
    int oldMonthDay = [self theDaysInYear:[[dateFormatter stringFromDate:today] intValue] inMonth:[[timeLineAllArray objectAtIndex:timeLineNowNumber-1] intValue]];
    if(compareInteger<([self getNowMonthToManyDay]+oldMonthDay)*24*60*60)
    {
        return @"上一月";
    }
    //本年
    if(compareInteger < [self getNowYearToManyDay]*24*60*60)
    {
        return @"本年";
    }
    //xxxx年
    return [NSString stringWithFormat:@"%@年",[dateFormatter stringFromDate:today]];
}

#pragma mark 得到月份天数
-(int)theDaysInYear:(int)year inMonth:(int)month
{
    if (month == 1||month == 3||month == 5||month == 7||month == 8||month == 10||month == 12) {
        return 31;
    }
    if (month == 4||month == 6||month == 9||month == 11) {
        return 30;
    }
    if ((year % 4 == 0 && year % 100 != 0) || year % 400 == 0) {
        return 29;
    }
    return 28;
}

#pragma mark 获取本月过了多少天
-(int)getNowMonthToManyDay
{
    NSDateFormatter *dateFormatter = [[[NSDateFormatter alloc] init] autorelease];
    [dateFormatter setDateStyle:NSDateFormatterMediumStyle];
    [dateFormatter setTimeStyle:NSDateFormatterShortStyle];
    
    [dateFormatter setDateFormat:@"dd"];
    NSDate *today = [NSDate date];
    int manyDay = [[dateFormatter stringFromDate:today] intValue];
    return manyDay;
}

#pragma mark 获取本年过了多少天
-(int)getNowYearToManyDay
{
    NSDateFormatter *dateFormatter = [[[NSDateFormatter alloc] init] autorelease];
    [dateFormatter setDateStyle:NSDateFormatterMediumStyle];
    [dateFormatter setTimeStyle:NSDateFormatterShortStyle];
    [dateFormatter setDateFormat:@"MM"];
    NSDate *today = [NSDate date];
    int manyDay = [[dateFormatter stringFromDate:today] intValue];
    [dateFormatter setDateFormat:@"yyyy"];
    int nowYear = [[dateFormatter stringFromDate:today] intValue];
    int nowYearDay =0;
    for(int i=0;i<manyDay;i++)
    {
        nowYearDay += [self theDaysInYear:nowYear inMonth:i];
    }
    return nowYearDay + [self getNowMonthToManyDay];
}

@end
