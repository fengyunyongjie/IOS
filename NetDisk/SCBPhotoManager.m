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
#import "AppDelegate.h"
#import "JSON.h"
#import "PhotoFile.h"

@implementation SCBPhotoManager
@synthesize photoDelegate;
@synthesize matableData;
@synthesize newFoldDelegate;
@synthesize sectionarray;
@synthesize tablediction;

#pragma mark 获取时间分组
-(void)getPhotoTimeLine:(BOOL)bl
{
    isFirst = bl;
    NSURL *s_url=[NSURL URLWithString:[NSString stringWithFormat:@"%@%@",SERVER_URL,PHOTO_ALL]];
    NSMutableURLRequest *request=[NSMutableURLRequest requestWithURL:s_url cachePolicy:NSURLRequestReloadIgnoringLocalCacheData timeoutInterval:CONNECT_TIMEOUT];
    url_string = PHOTO_ALL;
    self.matableData = [NSMutableData data];
    
    [request setValue:[[SCBSession sharedSession] userId] forHTTPHeaderField:@"usr_id"];
    [request setValue:CLIENT_TAG forHTTPHeaderField:@"client_tag"];
    [request setValue:[[SCBSession sharedSession] userToken] forHTTPHeaderField:@"usr_token"];
    [request setHTTPMethod:@"POST"];
    NSLog(@"%@,%@",[[SCBSession sharedSession] userId],[[SCBSession sharedSession] userToken]);
    
    [[[NSURLConnection alloc] initWithRequest:request delegate:self] autorelease];
}

#pragma mark 获取所有时间轴上的照片信息
-(void)getAllPhotoGeneral:(NSArray *)timeLineArray
{
    
    timeDictionary = [[NSMutableDictionary alloc] init];
    photoDictionary  = [[NSMutableDictionary alloc] init];
    allKeysArray = [[NSMutableArray alloc] init];
    timeLineAllArray = [timeLineArray retain];
    timeLineTotalNumber = [timeLineArray count];
    timeLineNowNumber = 0;
    [self getPhotoGeneral];
}

#pragma mark 获取按年或月查询的概要照片
-(void)getPhotoGeneral
{
    self.matableData = [NSMutableData data];
    NSURL *s_url=[NSURL URLWithString:[NSString stringWithFormat:@"%@%@",SERVER_URL,PHOTO_GENERAL]];
    NSMutableURLRequest *request=[NSMutableURLRequest requestWithURL:s_url cachePolicy:NSURLRequestReloadIgnoringLocalCacheData timeoutInterval:CONNECT_TIMEOUT];
    url_string = PHOTO_GENERAL;
    NSMutableString *body=[[NSMutableString alloc] init];
    [body appendFormat:@"date=%@&maxNum=10000",[timeLineAllArray objectAtIndex:timeLineNowNumber]];
    NSMutableData *myRequestData=[NSMutableData data];
    [myRequestData appendData:[body dataUsingEncoding:NSUTF8StringEncoding]];
    [request setHTTPBody:myRequestData];
    NSLog(@"--------------------------------------------------请求的参数：%@",body);
    [body release];
    [request setValue:[[SCBSession sharedSession] userId] forHTTPHeaderField:@"usr_id"];
    [request setValue:CLIENT_TAG forHTTPHeaderField:@"client_tag"];
    [request setValue:[[SCBSession sharedSession] userToken] forHTTPHeaderField:@"usr_token"];
    [request setHTTPMethod:@"POST"];
    NSLog(@"%@,%@",[[SCBSession sharedSession] userId],[[SCBSession sharedSession] userToken]);
    
    
    timeLineNowNumber++;
    [[[NSURLConnection alloc] initWithRequest:request delegate:self] autorelease];
}

#pragma mark 处理返回的数据
-(void)mangerGobackData:(NSDictionary *)dictionary
{
    NSLog(@"处理返回的数据:%@",dictionary);
    
    if([[dictionary objectForKey:@"photos"] isKindOfClass:[NSArray class]])
    {
        NSArray *photosArray = [dictionary objectForKey:@"photos"];
        for(int i=0;i<[photosArray count];i++)
        {
            NSDictionary *photosDiction = [photosArray objectAtIndex:i];
            if([[photosDiction objectForKey:@"list"] isKindOfClass:[NSArray class]])
            {
                NSDateFormatter *dateFormatter = [[[NSDateFormatter alloc] init] autorelease];
                [dateFormatter setDateStyle:NSDateFormatterMediumStyle];
                [dateFormatter setTimeStyle:NSDateFormatterShortStyle];
                [dateFormatter setDateFormat:@"yyyy-MM-dd HH:mm:ss"];
                NSDate *date_string;
                NSString *date_type = nil;
                NSArray *array_dict = [photosDiction objectForKey:@"list"];
                NSMutableArray *tableArray = nil;
                NSString *string_date;
                for(int j=0;j<[array_dict count];j++)
                {
                    PhohoDemo *photo_demo = [[PhohoDemo alloc] init];
                    [photo_demo setTotal:[[photosDiction objectForKey:@"total"] intValue]];
                    NSDictionary *dict = [array_dict objectAtIndex:j];
                    [photo_demo setF_mime:[dict objectForKey:@"f_mime"]];
                    [photo_demo setF_size:[[dict objectForKey:@"f_size"] intValue]];
                    [photo_demo setF_name:[dict objectForKey:@"f_name"]];
                    [photo_demo setF_pid:[[dict objectForKey:@"f_pid"] intValue]];
                    
                    if([[dict objectForKey:@"img_create"] isKindOfClass:[NSString class]])
                    {
                        [photo_demo setImg_create:[dict objectForKey:@"img_create"]];
                    }
                    
                    [photo_demo setF_create:[dict objectForKey:@"f_create"]];
                    string_date = photo_demo.img_create;
                    [photo_demo setF_id:[[dict objectForKey:@"f_id"] intValue]];
                    [photo_demo setF_modify:[dict objectForKey:@"f_modify"]];
                    [photo_demo setCompressaddr:[dict objectForKey:@"compressaddr"]];
                    [photo_demo setF_ownerid:[[dict objectForKey:@"f_ownerid"] intValue]];
                    [photo_demo setF_owername:@""];
                    [photo_demo setF_pids:@""];
                    if(j==0)
                    {
                        date_string = [dateFormatter dateFromString:string_date];
                        date_type = [self getNowTimeLineForType:date_string];
                        NSLog(@"类型：%@",date_type);
                        if([[timeDictionary objectForKey:date_type] isKindOfClass:[NSMutableArray class]])
                        {
                            tableArray = [[NSMutableArray alloc] initWithArray:[timeDictionary objectForKey:date_type]];
                        }
                        else
                        {
                            tableArray = [[NSMutableArray alloc] init];
                        }
                    }
                    [photo_demo setTimeLine:date_type];
                    [tableArray addObject:[NSString stringWithFormat:@"%i",photo_demo.f_id]];
                    [photoDictionary setObject:photo_demo forKey:[NSString stringWithFormat:@"%i",photo_demo.f_id]];
                    [photo_demo release];
                }
                NSLog(@"date_type:%@",date_type);
                BOOL typeBl = FALSE;
                for(int k=0;k<[allKeysArray count];k++)
                {
                    NSString *keyString = [allKeysArray objectAtIndex:k];
                    if([keyString isEqualToString:date_type])
                    {
                        typeBl = TRUE;
                        break;
                    }
                }
                if(typeBl)
                {}
                else if([date_type isEqualToString:timeLine1])
                {
                    if([allKeysArray count]>1)
                    {
                        [allKeysArray insertObject:date_type atIndex:0];
                    }
                    else
                    {
                        [allKeysArray addObject:date_type];
                    }
                }
                else if([date_type isEqualToString:timeLine2])
                {
                    if([allKeysArray count]>1)
                    {
                        [allKeysArray insertObject:date_type atIndex:1];
                    }
                    else
                    {
                        [allKeysArray addObject:date_type];
                    }
                }
                else if([date_type isEqualToString:timeLine3])
                {
                    if([allKeysArray count]>2)
                    {
                        [allKeysArray insertObject:date_type atIndex:2];
                    }
                    else
                    {
                        [allKeysArray addObject:date_type];
                    }
                }
                else if([date_type isEqualToString:timeLine4])
                {
                    if([allKeysArray count]>3)
                    {
                        [allKeysArray insertObject:date_type atIndex:3];
                    }
                    else
                    {
                        [allKeysArray addObject:date_type];
                    }
                }
                else if([date_type isEqualToString:timeLine5])
                {
                    if([allKeysArray count]>4)
                    {
                        [allKeysArray insertObject:date_type atIndex:4];
                    }
                    else
                    {
                        [allKeysArray addObject:date_type];
                    }
                }
                else if([date_type isEqualToString:timeLine6])
                {
                    if([allKeysArray count]>5)
                    {
                        [allKeysArray insertObject:date_type atIndex:5];
                    }
                    else
                    {
                        [allKeysArray addObject:date_type];
                    }
                }
                else if([date_type isEqualToString:timeLine7])
                {
                    if([allKeysArray count]>6)
                    {
                        [allKeysArray insertObject:date_type atIndex:6];
                    }
                    else
                    {
                        [allKeysArray addObject:date_type];
                    }
                }
                else
                {
                    [allKeysArray addObject:date_type];
                }
                NSLog(@"allkey:%@",allKeysArray);
                [timeDictionary setObject:tableArray forKey:date_type];
                [timeDictionary setObject:allKeysArray forKey:@"timeLine"];
                [tableArray release];
            }
        }
    }
}

#pragma mark 优化数据得到自己想要的数据
-(void)getMangerDiction:(NSDictionary *)dicion
{
    NSLog(@"dicion--------------------:%@",dicion);
    BOOL bl = FALSE;
    NSDateFormatter *dateFormatter = [[[NSDateFormatter alloc] init] autorelease];
    [dateFormatter setDateStyle:NSDateFormatterMediumStyle];
    [dateFormatter setTimeStyle:NSDateFormatterShortStyle];
    [dateFormatter setDateFormat:@"yyyy-MM-dd HH:mm"];
    //获取所有数据
    if([[dicion objectForKey:@"files"] isKindOfClass:[NSArray class]])
    {
        NSArray *allArray = [dicion objectForKey:@"files"];
        //判断数据个数是否相等
        PhotoFile *photo_f = [[[PhotoFile alloc] init] autorelease];
        NSInteger count = [photo_f selectCountTaskTable];
        if(count!=[allArray count] || [allArray count]==0)
        {
            bl = TRUE;
            [photo_f deleteAllPhotoFileTable];
            for(int i=0;i<[allArray count];i++)
            {
                NSDictionary *dictionary = [allArray objectAtIndex:i];
                NSString *f_date = [dictionary objectForKey:@"f_date"];
                int f_id = [[dictionary objectForKey:@"f_id"] intValue];
                PhotoFile *photo_file = [[[PhotoFile alloc] init] autorelease];
                photo_file.f_id = f_id;
                photo_file.f_date = f_date;
                photo_file.f_time = [[dateFormatter dateFromString:f_date] timeIntervalSince1970];
                NSLog(@"photo_file.f_time:%f",photo_file.f_time);
                [photo_file insertPhotoFileTable];
            }
        }
    }
    if(bl || isFirst)
    {
        [photoDelegate getPhotoTiimeLine:nil];
    }
    else
    {
        [photoDelegate didFailWithError];
    }
}

- (void)connection:(NSURLConnection *)connection didFailWithError:(NSError *)error
{
    NSString *type_string = [[[[[connection originalRequest] URL] path] componentsSeparatedByString:@"/"] lastObject];
    if([type_string isEqualToString:[[FM_MKDIR_URL componentsSeparatedByString:@"/"] lastObject]])
    {
        if([newFoldDelegate respondsToSelector:@selector(didFailWithError)])
        {
            [newFoldDelegate didFailWithError];
        }
    }
    else if([type_string isEqualToString:[[FM_URI componentsSeparatedByString:@"/"] lastObject]])
    {
        if([newFoldDelegate respondsToSelector:@selector(didFailWithError)])
        {
            [newFoldDelegate didFailWithError];
        }
    }
    
    else if([type_string isEqualToString:[[PHOTO_Delete componentsSeparatedByString:@"/"] lastObject]])
    {
        if([photoDelegate respondsToSelector:@selector(requstDelete:)])
        {
            [photoDelegate requstDelete:[NSDictionary dictionaryWithObject:@"3" forKey:@"code"]];
        }
    }
    else if([type_string isEqualToString:[[FM_GETFILEINFO componentsSeparatedByString:@"/"] lastObject]])
    {
        if([photoDelegate respondsToSelector:@selector(getFileDetail:)])
        {
            [photoDelegate getFileDetail:[NSDictionary dictionaryWithObject:@"3" forKey:@"code"]];
        }
    }
    else if([type_string isEqualToString:[[PHOTO_ALL componentsSeparatedByString:@"/"] lastObject]])
    {
        [photoDelegate didFailWithError];
    }
}


#pragma mark 请求删除文件
-(void)requestDeletePhoto:(NSArray *)deleteId
{
    self.matableData = [NSMutableData data];
    NSURL *s_url=[NSURL URLWithString:[NSString stringWithFormat:@"%@%@",SERVER_URL,PHOTO_Delete]];
    NSMutableURLRequest *request=[NSMutableURLRequest requestWithURL:s_url cachePolicy:NSURLRequestReloadIgnoringLocalCacheData timeoutInterval:CONNECT_TIMEOUT];
    url_string = PHOTO_Delete;
    [request setValue:[[SCBSession sharedSession] userId] forHTTPHeaderField:@"usr_id"];
    [request setValue:CLIENT_TAG forHTTPHeaderField:@"client_tag"];
    [request setValue:[[SCBSession sharedSession] userToken] forHTTPHeaderField:@"usr_token"];
    
    NSMutableString *idString = [[NSMutableString alloc] init];
    for(int i=0;i<[deleteId count];i++)
    {
        if(i==0)
        {
            [idString appendString:[NSString stringWithFormat:@"f_ids[]=%@",[deleteId objectAtIndex:i]]];
        }
        else
        {
            [idString appendString:[NSString stringWithFormat:@"&f_ids[]=%@",[deleteId objectAtIndex:i]]];
        }
    }
    
    NSLog(@"idString:%@",idString);
    NSMutableString *body=[[NSMutableString alloc] init];
    [body appendString:idString];
    [idString release];
    NSMutableData *myRequestData=[NSMutableData data];
    [myRequestData appendData:[body dataUsingEncoding:NSUTF8StringEncoding]];
    [request setHTTPBody:myRequestData];
    [body release];
    [request setHTTPMethod:@"POST"];
    NSLog(@"%@,%@",[[SCBSession sharedSession] userId],[[SCBSession sharedSession] userToken]);
    [[[NSURLConnection alloc] initWithRequest:request delegate:self] autorelease];
}

#pragma mark -请求成功后，分发数据
- (void)connection:(NSURLConnection *)connection didReceiveData:(NSData *)data
{
    [self.matableData appendData:data];
}

- (void)connectionDidFinishLoading:(NSURLConnection *)connection
{
    NSLog(@"--------------------------------------------------太忙了");
    NSDictionary *diction = [NSJSONSerialization JSONObjectWithData:self.matableData options:NSJSONReadingMutableLeaves error:nil];
    NSLog(@"请求成功后，分发数据:%@",diction);
    NSString *type_string = [[[[[connection originalRequest] URL] path] componentsSeparatedByString:@"/"] lastObject];
    if([type_string isEqualToString:[[PHOTO_TIMERLINE componentsSeparatedByString:@"/"] lastObject]])
    {
        if([photoDelegate respondsToSelector:@selector(getPhotoTiimeLine:)])
        {
            [photoDelegate getPhotoTiimeLine:diction];
        }
    }
    else if([type_string isEqualToString:[[PHOTO_ALL componentsSeparatedByString:@"/"] lastObject]])
    {
        [self getMangerDiction:diction];
    }
    else if([type_string isEqualToString:[[PHOTO_DETAIL componentsSeparatedByString:@"/"] lastObject]])
    {
        if([photoDelegate respondsToSelector:@selector(getPhotoDetail:)])
        {
            [photoDelegate getPhotoDetail:diction];
        }
    }
    else if([type_string isEqualToString:[[PHOTO_Delete componentsSeparatedByString:@"/"] lastObject]])
    {
        if([photoDelegate respondsToSelector:@selector(requstDelete:)])
        {
            [photoDelegate requstDelete:diction];
        }
    }
    else if([type_string isEqualToString:[[FM_MKDIR_URL componentsSeparatedByString:@"/"] lastObject]])
    {
        if([newFoldDelegate respondsToSelector:@selector(newFold:)])
        {
            [newFoldDelegate newFold:diction];
        }
    }
    else if([type_string isEqualToString:[[FM_URI componentsSeparatedByString:@"/"] lastObject]])
    {
        if([newFoldDelegate respondsToSelector:@selector(openFile:)])
        {
            [newFoldDelegate openFile:diction];
        }
    }
    else if([type_string isEqualToString:[[FM_GETFILEINFO componentsSeparatedByString:@"/"] lastObject]])
    {
        if([photoDelegate respondsToSelector:@selector(getFileDetail:)])
        {
            [photoDelegate getFileDetail:diction];
        }
    }
    else if([type_string isEqualToString:[[FM_CUTTO componentsSeparatedByString:@"/"] lastObject]])
    {
        if([newFoldDelegate respondsToSelector:@selector(openFile:)])
        {
            [newFoldDelegate openFile:diction];
        }
    }
        
}

#pragma mark 判断当前时间属于哪一类
-(NSString *)getNowTimeLineForType:(NSDate *)date
{
    //得到当前时间戳
    NSCalendar *calendar = [NSCalendar currentCalendar];
    NSDateComponents *component = [calendar components:NSEraCalendarUnit| NSYearCalendarUnit| NSMonthCalendarUnit| NSDayCalendarUnit| NSHourCalendarUnit| NSMinuteCalendarUnit | NSSecondCalendarUnit| NSWeekCalendarUnit | NSWeekdayCalendarUnit | NSWeekdayOrdinalCalendarUnit | NSQuarterCalendarUnit | NSWeekOfMonthCalendarUnit | NSWeekOfYearCalendarUnit | NSYearForWeekOfYearCalendarUnit fromDate:date];
    
    NSDate *todayDate = [NSDate date];
    NSDateComponents *todayComponent = [calendar components:NSEraCalendarUnit| NSYearCalendarUnit| NSMonthCalendarUnit| NSDayCalendarUnit| NSHourCalendarUnit| NSMinuteCalendarUnit | NSSecondCalendarUnit| NSWeekCalendarUnit | NSWeekdayCalendarUnit | NSWeekdayOrdinalCalendarUnit | NSQuarterCalendarUnit | NSWeekOfMonthCalendarUnit | NSWeekOfYearCalendarUnit | NSYearForWeekOfYearCalendarUnit fromDate:todayDate];
    
    if(todayComponent.year == component.year)
    {
        if(todayComponent.month == component.month)
        {
            if(todayComponent.week == component.week)
            {
                //今天
                if(todayComponent.weekday == component.weekday)
                {
                    return @"今天";
                }
                else if(todayComponent.weekday-component.weekday == 1)
                {
                    return @"昨天";
                }
                else
                {
                    return @"本周";
                }
            }
            else if(todayComponent.week - component.week ==1)
            {
                return @"上一周";
            }
            else
            {
                return @"本月";
            }
        }
        else if(todayComponent.month-component.month == 1)
        {
            return @"上一月";
        }
        else
        {
            return @"本年";
        }
    }
    else 
    {
        return [NSString stringWithFormat:@"%i年",component.year];
    }
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

#pragma mark 新建文件夹
-(void)requestNewFold:(NSString *)name FID:(int)f_id space_id:(NSString *)space_id
{
    NSLog(@"快要来了");
    self.matableData = [NSMutableData data];
    NSURL *s_url=[NSURL URLWithString:[NSString stringWithFormat:@"%@%@",SERVER_URL,FM_MKDIR_URL]];
    NSMutableURLRequest *request=[NSMutableURLRequest requestWithURL:s_url cachePolicy:NSURLRequestReloadIgnoringLocalCacheData timeoutInterval:CONNECT_TIMEOUT];
    url_string = FM_MKDIR_URL;
    [request setValue:[[SCBSession sharedSession] userId] forHTTPHeaderField:@"usr_id"];
    [request setValue:CLIENT_TAG forHTTPHeaderField:@"client_tag"];
    [request setValue:[[SCBSession sharedSession] userToken] forHTTPHeaderField:@"usr_token"];
    NSMutableString *body=[[NSMutableString alloc] init];
    [body appendFormat:@"f_name=%@&f_pid=%i&space_id=%@",name,f_id,space_id];
    NSLog(@"body:%@",body);
    NSMutableData *myRequestData=[NSMutableData data];
    [myRequestData appendData:[body dataUsingEncoding:NSUTF8StringEncoding]];
    [request setHTTPBody:myRequestData];
    [body release];
    [request setHTTPMethod:@"POST"];
    NSLog(@"%@,%@",[[SCBSession sharedSession] userId],[[SCBSession sharedSession] userToken]);
    [[[NSURLConnection alloc] initWithRequest:request delegate:self] autorelease];
    NSLog(@"来了");
}

#pragma mark 打开文件目录
-(void)openFinderWithID:(NSString *)f_id space_id:(NSString *)space_id
{
    self.matableData = [NSMutableData data];
    NSURL *s_url=[NSURL URLWithString:[NSString stringWithFormat:@"%@%@",SERVER_URL,FM_URI]];
    url_string = FM_URI;
    NSMutableURLRequest *request=[NSMutableURLRequest requestWithURL:s_url cachePolicy:NSURLRequestReloadIgnoringLocalCacheData timeoutInterval:CONNECT_TIMEOUT];
    NSMutableString *body=[[NSMutableString alloc] init];
    [body appendFormat:@"f_id=%@&cursor=%d&offset=%d&space_id=%@&iszone=%@&sort=%@&sort_direct=%@",f_id,0,-1,space_id,@"1",@"f_modify",@"asc"];
    
    NSLog(@"%@",body);
    NSMutableData *myRequestData=[NSMutableData data];
    [myRequestData appendData:[body dataUsingEncoding:NSUTF8StringEncoding]];
    [body release];
    [request setValue:[[SCBSession sharedSession] userId] forHTTPHeaderField:@"usr_id"];
    [request setValue:CLIENT_TAG forHTTPHeaderField:@"client_tag"];
    [request setValue:[[SCBSession sharedSession] userToken] forHTTPHeaderField:@"usr_token"];
    [request setHTTPBody:myRequestData];
    [request setHTTPMethod:@"POST"];
    
    [[[NSURLConnection alloc] initWithRequest:request delegate:self] autorelease];
}

#pragma mark 请求收藏详细信息
-(void)getDetail:(int)f_id
{
    self.matableData = [NSMutableData data];
    NSURL *s_url=[NSURL URLWithString:[NSString stringWithFormat:@"%@%@",SERVER_URL,FM_GETFILEINFO]];
    NSMutableURLRequest *request=[NSMutableURLRequest requestWithURL:s_url cachePolicy:NSURLRequestReloadIgnoringLocalCacheData timeoutInterval:CONNECT_TIMEOUT];
    url_string = FM_GETFILEINFO;
    [request setValue:[[SCBSession sharedSession] userId] forHTTPHeaderField:@"usr_id"];
    [request setValue:CLIENT_TAG forHTTPHeaderField:@"client_tag"];
    [request setValue:[[SCBSession sharedSession] userToken] forHTTPHeaderField:@"usr_token"];
    NSMutableString *body=[[NSMutableString alloc] init];
    [body appendFormat:@"f_id=%i",f_id];
    NSLog(@"body:%@",body);
    NSMutableData *myRequestData=[NSMutableData data];
    [myRequestData appendData:[body dataUsingEncoding:NSUTF8StringEncoding]];
    [request setHTTPBody:myRequestData];
    [body release];
    [request setHTTPMethod:@"POST"];
    NSLog(@"%@,%@",[[SCBSession sharedSession] userId],[[SCBSession sharedSession] userToken]);
    [[[NSURLConnection alloc] initWithRequest:request delegate:self] autorelease];
}

#pragma mark 打开移动目录
-(void)requestMoveFile:(NSString *)f_pid space_id:(NSString *)space_id
{
    self.matableData = [NSMutableData data];
    NSURL *s_url=[NSURL URLWithString:[NSString stringWithFormat:@"%@%@",SERVER_URL,FM_CUTTO]];
    NSMutableURLRequest *request=[NSMutableURLRequest requestWithURL:s_url cachePolicy:NSURLRequestReloadIgnoringLocalCacheData timeoutInterval:CONNECT_TIMEOUT];
    url_string = FM_CUTTO;
    [request setValue:[[SCBSession sharedSession] userId] forHTTPHeaderField:@"usr_id"];
    [request setValue:CLIENT_TAG forHTTPHeaderField:@"client_tag"];
    [request setValue:[[SCBSession sharedSession] userToken] forHTTPHeaderField:@"usr_token"];
    NSMutableString *body=[[NSMutableString alloc] init];
    [body appendFormat:@"pId=%@",f_pid];
    [body appendFormat:@"&space_id=%@",space_id];
    [body appendFormat:@"&fIds[]=%@",@[]];
    
    NSLog(@"body:%@",body);
    NSMutableData *myRequestData=[NSMutableData data];
    [myRequestData appendData:[body dataUsingEncoding:NSUTF8StringEncoding]];
    [request setHTTPBody:myRequestData];
    [body release];
    [request setHTTPMethod:@"POST"];
    NSLog(@"%@,%@",[[SCBSession sharedSession] userId],[[SCBSession sharedSession] userToken]);
    [[[NSURLConnection alloc] initWithRequest:request delegate:self] autorelease];
}

-(void)dealloc
{
    [photoDelegate release];
    [newFoldDelegate release];
    [matableData release];
    [tablediction release];
    [sectionarray release];
    [super dealloc];
}

@end
