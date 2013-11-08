//
//  PhotoTableView.m
//  NetDisk
//
//  Created by Yangsl on 13-8-22.
//
//

#import "PhotoTableView.h"
#import "PhotoFile.h"
#import "PhotoFileCell.h"
#import "YNFunctions.h"
#import "PhotoLookViewController.h"
#import "SCBSession.h"
#import "AppDelegate.h"
#import "FileTableView.h"

#define timeLine1 @"今天"
#define timeLine2 @"昨天"
#define timeLine3 @"本周"
#define timeLine4 @"上一周"
#define timeLine5 @"本月"
#define timeLine6 @"上一月"
#define timeLine7 @"本年"

#define UICellTag 10000000
#define UIImageTag 1000000
#define UIButtonTag 2000000

#define kAlertTagRename 1001
#define kAlertTagDeleteOne 1002
#define kActionSheetTagShare 70
#define kActionSheetTagMore 71
#define kAlertTagMailAddr 72

@implementation PhotoTableView
@synthesize _dicReuseCells,editBL,photo_diction,sectionarray,downCellArray,isLoadData,isLoadImage,endFloat,isSort,photo_delegate,fileManager,linkManager,hud,requestId;

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        
    }
    photo_diction = [[NSMutableDictionary alloc] init];
    sectionarray = [[NSMutableArray alloc] init];
    downCellArray = [[NSMutableArray alloc] init];
    
    _dicReuseCells = [[NSMutableDictionary alloc] init];
    self.dataSource = self;
    self.delegate = self;
    
    fileManager = [[SCBFileManager alloc] init];
    fileManager.delegate = self;
    linkManager = [[SCBLinkManager alloc] init];
    linkManager.delegate = self;
    return self;
}

//加载数据
-(void)reloadPhotoData
{
    AppDelegate *app_delegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
    [app_delegate clearDown];
    [sectionarray removeAllObjects];
    [photo_diction removeAllObjects];
    [self setSeparatorStyle:UITableViewCellSeparatorStyleSingleLine];
    [self reloadData];
    [self requestPhotoTimeLine];
}

//请求时间轴
-(void)requestPhotoTimeLine
{
    dispatch_async(dispatch_get_main_queue(), ^{
        AppDelegate *appleDate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
        if(appleDate.isHomeLoad)
        {
            NSLog(@"正在请求时间轴");
            //请求时间轴
            SCBPhotoManager *photoManager = [[[SCBPhotoManager alloc] init] autorelease];
            [photoManager setPhotoDelegate:self];
            [photoManager getPhotoArrayTimeline:requestId];
        }
        else
        {
            NSLog(@"停止请求时间轴");
            [appleDate clearDown];
        }
    });
    
}

#pragma mark SCBPhotoDelegate ------------------

-(void)getPhotoTiimeLine:(NSDictionary *)dictionary
{
//    [self clearsContextBeforeDrawing];
//    [photo_array removeAllObjects];
//    [sectionarray removeAllObjects];
//    NSCalendar *calendar = [NSCalendar currentCalendar];
//    NSDate *todayDate = [NSDate date];
//    NSDateComponents *todayComponent = [calendar components:NSEraCalendarUnit| NSYearCalendarUnit| NSMonthCalendarUnit| NSDayCalendarUnit| NSHourCalendarUnit| NSMinuteCalendarUnit | NSSecondCalendarUnit| NSWeekCalendarUnit | NSWeekdayCalendarUnit | NSWeekdayOrdinalCalendarUnit | NSQuarterCalendarUnit | NSWeekOfMonthCalendarUnit | NSWeekOfYearCalendarUnit | NSYearForWeekOfYearCalendarUnit fromDate:todayDate];
//    
//    //今天的起止时间
//    NSString *eString  = [NSString stringWithFormat:@"%i-%i-%i %i:%i",todayComponent.year,todayComponent.month,todayComponent.day,todayComponent.hour,todayComponent.minute];
//    NSString *sString  = [NSString stringWithFormat:@"%i-%i-%i 00:00",todayComponent.year,todayComponent.month,todayComponent.day];
//    PhotoFile *photo_file = [[PhotoFile alloc] init];
//    NSArray *timeArray = [photo_file selectMoreTaskTable:sString eDate:eString];
//    if([timeArray count]>0)
//    {
//        [sectionarray addObject:timeLine1];
//        [tablediction setObject:timeArray forKey:timeLine1];
//    }
//    NSLog(@"timeArray:%@ \n count:%i",timeArray,[timeArray count]);
//    //昨天的起止时间
//    if([self startTimeMoreThanEndTime:sString eTime:eString])
//    {
//        eString = sString;
//    }
//    if(todayComponent.day-2 == -1)
//    {
//        sString  = [NSString stringWithFormat:@"%i-%i-%i 00:00",todayComponent.year,todayComponent.month-1,[self theDaysInYear:todayComponent.year inMonth:todayComponent.month-1]];
//    }
//    else
//    {
//        sString  = [NSString stringWithFormat:@"%i-%i-%i 00:00",todayComponent.year,todayComponent.month,todayComponent.day-1];
//    }
//    
//    timeArray = [photo_file selectMoreTaskTable:sString eDate:eString];
//    if([timeArray count]>0)
//    {
//        [sectionarray addObject:timeLine2];
//        [tablediction setObject:timeArray forKey:timeLine2];
//    }
//    NSLog(@"timeArray:%@ \n count:%i",timeArray,[timeArray count]);
//    
//    //本周的起止时间
//    if([self startTimeMoreThanEndTime:sString eTime:eString])
//    {
//        eString = sString;
//    }
//    if(todayComponent.day-todayComponent.weekday < 0)
//    {
//        sString  = [NSString stringWithFormat:@"%i-%i-%i 00:00",todayComponent.year,todayComponent.month-1,[self theDaysInYear:todayComponent.year inMonth:todayComponent.month-1]+(todayComponent.day-todayComponent.weekday)+1];
//    }
//    else
//    {
//        sString  = [NSString stringWithFormat:@"%i-%i-%i 00:00",todayComponent.year,todayComponent.month,todayComponent.day-todayComponent.weekday+1];
//    }
//    timeArray = [photo_file selectMoreTaskTable:sString eDate:eString];
//    if([timeArray count]>0)
//    {
//        [sectionarray addObject:timeLine3];
//        [tablediction setObject:timeArray forKey:timeLine3];
//    }
//    NSLog(@"timeArray:%@ \n count:%i",timeArray,[timeArray count]);
//    
//    //上一周的起止时间
//    if([self startTimeMoreThanEndTime:sString eTime:eString])
//    {
//        eString = sString;
//    }
//    if(todayComponent.day-(todayComponent.weekday+7)<0)
//    {
//        sString  = [NSString stringWithFormat:@"%i-%i-%i 00:00",todayComponent.year,todayComponent.month-1,[self theDaysInYear:todayComponent.year inMonth:todayComponent.month-1]+(todayComponent.day-(todayComponent.weekday+7))+1];
//    }
//    else
//    {
//        sString  = [NSString stringWithFormat:@"%i-%i-%i 00:00",todayComponent.year,todayComponent.month,todayComponent.day-(todayComponent.weekday+7)+1];
//    }
//    timeArray = [photo_file selectMoreTaskTable:sString eDate:eString];
//    if([timeArray count]>0)
//    {
//        [sectionarray addObject:timeLine4];
//        [tablediction setObject:timeArray forKey:timeLine4];
//    }
//    NSLog(@"timeArray:%@ \n count:%i",timeArray,[timeArray count]);
//    
//    //本月的起止时间
//    if([self startTimeMoreThanEndTime:sString eTime:eString])
//    {
//        eString = sString;
//    }
//    sString  = [NSString stringWithFormat:@"%i-%i-%i 00:00",todayComponent.year,todayComponent.month,1];
//    timeArray = [photo_file selectMoreTaskTable:sString eDate:eString];
//    if([timeArray count]>0)
//    {
//        [sectionarray addObject:timeLine5];
//        [tablediction setObject:timeArray forKey:timeLine5];
//    }
//    NSLog(@"timeArray:%@ \n count:%i",timeArray,[timeArray count]);
//    
//    //上个月的起止时间
//    if([self startTimeMoreThanEndTime:sString eTime:eString])
//    {
//        eString = sString;
//    }
//    sString  = [NSString stringWithFormat:@"%i-%i-%i 00:00",todayComponent.year,todayComponent.month-1,1];
//    timeArray = [photo_file selectMoreTaskTable:sString eDate:eString];
//    if([timeArray count]>0)
//    {
//        [sectionarray addObject:timeLine6];
//        [tablediction setObject:timeArray forKey:timeLine6];
//    }
//    NSLog(@"timeArray:%@ \n count:%i",timeArray,[timeArray count]);
//    
//    //本年的起止时间
//    if([self startTimeMoreThanEndTime:sString eTime:eString])
//    {
//        eString = sString;
//    }
//    sString  = [NSString stringWithFormat:@"%i-%i-%i 00:00",todayComponent.year,1,1];
//    timeArray = [photo_file selectMoreTaskTable:sString eDate:eString];
//    if([timeArray count]>0)
//    {
//        [sectionarray addObject:timeLine7];
//        [tablediction setObject:timeArray forKey:timeLine7];
//    }
//    NSLog(@"timeArray:%@ \n count:%i",timeArray,[timeArray count]);
//    
//    //十年内的数据
//    for(int i=1;i<=10;i++)
//    {
//        if([self startTimeMoreThanEndTime:sString eTime:eString])
//        {
//            eString = sString;
//        }
//        sString  = [NSString stringWithFormat:@"%i-%i-%i 00:00",todayComponent.year-i,1,1];
//        timeArray = [photo_file selectMoreTaskTable:sString eDate:eString];
//        if([timeArray count]>0)
//        {
//            [sectionarray addObject:[NSString stringWithFormat:@"%i年",todayComponent.year-i]];
//            [tablediction setObject:timeArray forKey:[NSString stringWithFormat:@"%i年",todayComponent.year-i]];
//        }
//        NSLog(@"timeArray:%@ \n count:%i",timeArray,[timeArray count]);
//    }
//    
//    [self reloadData];
//    
//    [NSTimer scheduledTimerWithTimeInterval:0.5 target:self selector:@selector(FirstLoad) userInfo:nil repeats:NO];
}

-(void)getPhotoGeneral:(NSDictionary *)dictionary photoDictioin:(NSMutableDictionary *)photoDic
{
    
}

-(void)getPhotoArrayTimeline:(NSDictionary *)dictionary
{
    [sectionarray removeAllObjects];
    [photo_diction removeAllObjects];
    NSArray *array = [dictionary objectForKey:@"data"];
    
    for(NSDictionary *diction in array)
    {
        int counts = [[diction objectForKey:@"counts"] intValue];
        if(counts > 0)
        {
            [sectionarray addObject:diction];
        }
    }
    if([sectionarray count]>0)
    {
        [self reloadData];
        photoType = 0;
        AppDelegate *appleDate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
        if(appleDate.isHomeLoad)
        {
            NSLog(@"正在加载家庭空间数据");
            [self requestPhotoType];
        }
        else
        {
            NSLog(@"停止加载家庭空间数据");
            [appleDate clearDown];
        }
    }
    else
    {
        [photo_delegate nullData];
    }
}

-(void)requestPhotoType
{
    if(photoType < [sectionarray count])
    {
        NSDictionary *dictionary = [sectionarray objectAtIndex:photoType];
        NSString *Express = [dictionary objectForKey:@"express"];
        
        AppDelegate *appleDate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
        if(appleDate.isHomeLoad)
        {
            NSLog(@"正在加载家庭空间数据");
            //请求时间轴
            SCBPhotoManager *photoManager = [[[SCBPhotoManager alloc] init] autorelease];
            [photoManager setPhotoDelegate:self];
            [photoManager getPhotoDetailTimeImage:requestId express:Express];
        }
        else
        {
            NSLog(@"停止加载家庭空间数据");
            [appleDate clearDown];
        }
    }
}

-(void)getPhotoDetailTimeImage:(NSDictionary *)dictionary
{
    AppDelegate *appleDate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
    if(appleDate.isHomeLoad)
    {
        NSLog(@"正在加载家庭空间数据");
        NSArray *array = [dictionary objectForKey:@"data"];
        if([array count] > 0)
        {
            [photo_delegate haveData];
            NSMutableArray *tableArray = [[NSMutableArray alloc] init];
            for(NSDictionary *dictionary in array)
            {
                PhotoFile *demo = [[PhotoFile alloc] init];
                demo.f_id = [[dictionary objectForKey:@"f_id"] intValue];
                [tableArray addObject:demo];
                [demo release];
            }
            if([tableArray count] > 0)
            {
                NSLog(@"tableArray:%@",tableArray);
            }
            //        if (photoType>=dictionary.count) {
            //            NSLog(@"数据数量：：%d",dictionary.count);
            //            return;
            //        }
            NSLog(@"数据数量：：%d,下标::%d",dictionary.count,photoType);
            @try {
                NSDictionary *dictionary = [sectionarray objectAtIndex:photoType];
                NSString *tag = [dictionary objectForKey:@"tag"];
                [photo_diction setObject:tableArray forKey:tag];
            }
            @catch (NSException *exception) {
                NSLog(@"我的天呐，出现异常了！");
                CFShow(exception);
                return;
            }
            @finally {
                
            }
            [tableArray release];
        }
        photoType++;
        [self requestPhotoType];
        [self setSeparatorStyle:UITableViewCellSeparatorStyleNone];
        [self reloadData];
        
        if([[photo_diction allKeys] count] == 0)
        {
            [photo_delegate nullData];
        }
        else
        {
            [photo_delegate haveData];
        }
        
        //加载数据
        [NSTimer scheduledTimerWithTimeInterval:0.5 target:self selector:@selector(FirstLoad) userInfo:nil repeats:NO];
    }
    else
    {
        NSLog(@"停止加载家庭空间数据");
        [appleDate clearDown];
    }
}

-(void)getPhotoDetail:(NSDictionary *)dictionary
{
    
}

-(void)requstDelete:(NSDictionary *)dictionary
{
    if([[dictionary objectForKey:@"code"] intValue] == 0)
    {
        
    }
    else
    {
        
    }
}

-(void)getFileDetail:(NSDictionary *)dictionary
{
    
}

-(void)didFailWithError
{
    
}

#pragma mark 常用基本方法

-(void)FirstLoad
{
    isLoadData = TRUE;
    isLoadImage = TRUE;
    [NSThread detachNewThreadSelector:@selector(getImageLoad) toTarget:self withObject:nil];
}

- (void)appImageDidLoad:(NSInteger)indexTag urlImage:(UIImage *)image index:(NSIndexPath *)indexPath
{
    if(isLoadImage)
    {
        NSObject *obj = [self viewWithTag:indexTag];
        if(!obj)
        {
            return;
        }
        
        UIImageView *image_view = (UIImageView *)obj;
        UIImage *imageV = image;
        if(imageV.size.width>=imageV.size.height)
        {
            if(imageV.size.height<=200)
            {
                CGRect imageRect = CGRectMake((imageV.size.width-imageV.size.height)/2, 0, imageV.size.height, imageV.size.height);
                imageV = [self imageFromImage:imageV inRect:imageRect];
                [image_view performSelectorOnMainThread:@selector(setImage:) withObject:imageV waitUntilDone:YES];
            }
            else
            {
                CGSize newImageSize;
                newImageSize.height = 200;
                newImageSize.width = 200*imageV.size.width/imageV.size.height;
                UIImage *imageS = [self scaleFromImage:imageV toSize:newImageSize];
                CGRect imageRect = CGRectMake((newImageSize.width-200)/2, 0, 200, 200);
                imageS = [self imageFromImage:imageS inRect:imageRect];
                [image_view performSelectorOnMainThread:@selector(setImage:) withObject:imageS waitUntilDone:YES];
            }
        }
        else if(imageV.size.width<=imageV.size.height)
        {
            if(imageV.size.width<=200)
            {
                CGRect imageRect = CGRectMake(0, (imageV.size.height-imageV.size.width)/2, imageV.size.width, imageV.size.width);
                imageV = [self imageFromImage:imageV inRect:imageRect];
                [image_view performSelectorOnMainThread:@selector(setImage:) withObject:imageV waitUntilDone:YES];
            }
            else
            {
                CGSize newImageSize;
                newImageSize.width = 200;
                newImageSize.height = 200*imageV.size.height/imageV.size.width;
                UIImage *imageS = [self scaleFromImage:imageV toSize:newImageSize];
                CGRect imageRect = CGRectMake(0, (newImageSize.height-200)/2, 200, 200);
                imageS = [self imageFromImage:imageS inRect:imageRect];
                [image_view performSelectorOnMainThread:@selector(setImage:) withObject:imageS waitUntilDone:YES];
            }
        }
    }
}

-(void)getImageLoad
{
    AppDelegate *appleDate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
    if(appleDate.isHomeLoad)
    {
        NSLog(@"正在加载图片");
        dispatch_async(dispatch_get_main_queue(), ^{
            NSAutoreleasePool *pool = [[NSAutoreleasePool alloc] init];
            if(!downCellArray)
            {
                isLoadData = FALSE;
                return;
            }
            for(int i=0;isLoadData && isLoadImage && i<[downCellArray count];i++)
            {
                PhotoFileCell *cell = (PhotoFileCell *)[downCellArray objectAtIndex:i];
                NSArray *array = [cell cellArray];
                if(!array)
                {
                    isLoadData = FALSE;
                    return;
                }
                for(int j=0;isLoadData && isLoadImage && j<[array count];j++)
                {
                    CellTag *cellTag = [array objectAtIndex:j];
                    if(!cellTag)
                    {
                        isLoadData = FALSE;
                        return;
                    }
                    if(![self image_exists_at_file_path:[NSString stringWithFormat:@"%i",cellTag.fileTag]])
                    {
                        dispatch_async(dispatch_get_main_queue(), ^{
                            if(appleDate.isHomeLoad)
                            {
                                NSLog(@"正在下载图片");
                                DownImage *downImage = [[[DownImage alloc] init] autorelease];
                                [downImage setFileId:cellTag.fileTag];
                                [downImage setImageUrl:[NSString stringWithFormat:@"%i",cellTag.fileTag]];
                                [downImage setImageViewIndex:cellTag.imageTag];
                                [downImage setDelegate:self];
                                [downImage startDownload];
                            }
                            else
                            {
                                NSLog(@"停止继续下载");
                            }
                        });
                    }
                }
            }
            //    dispatch_async(dispatch_get_main_queue(), ^{
            isLoadData = FALSE;
            [downCellArray removeAllObjects];
            //    });
            [pool release];
        });
    }
    else
    {
        NSLog(@"停止加载图片");
        [appleDate clearDown];
    }
}

#pragma mark 按钮点击事件
-(void)clicked:(id)sender
{
    isLoadImage = FALSE;
    SelectButton *button = sender;
    int fid = button.tag-UIButtonTag;
    if(editBL)
    {
        if(button.selected)
        {
            [button setSelected:NO];
            [_dicReuseCells removeObjectForKey:[NSString stringWithFormat:@"%i",fid]];
            [button setBackgroundImage:[UIImage imageNamed:@"111.png"] forState:UIControlStateNormal];
        }
        else
        {
            [button setSelected:YES];
            [_dicReuseCells setObject:[NSNumber numberWithInt:fid] forKey:[NSString stringWithFormat:@"%i",fid]];
            [button setBackgroundImage:[UIImage imageNamed:@"interestSelected.png"] forState:UIControlStateNormal];
        }
    }
    else
    {
        NSDictionary *dictionary = [sectionarray objectAtIndex:button.cell.sectionTag];
        NSString *sectionString = [dictionary objectForKey:@"tag"];
        NSArray *array = [photo_diction objectForKey:sectionString];
        [photo_delegate showFile:button.cell.pageTag array:[NSMutableArray arrayWithArray:array]];
    }
}

#pragma mark UIScrollviewDelegate

- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView
{
        isLoadImage = TRUE;
        if(!isLoadData && scrollView.contentOffset.y >= 0 && endFloat > scrollView.contentOffset.y && scrollView.contentOffset.y <= scrollView.contentSize.height)
        {
            isSort = TRUE;
            endFloat = scrollView.contentOffset.y;
            isLoadData = TRUE;
            [NSThread detachNewThreadSelector:@selector(getImageLoad) toTarget:self withObject:nil];
        }
        
        if(!isLoadData && scrollView.contentOffset.y >= 0 && endFloat < scrollView.contentOffset.y && scrollView.contentOffset.y <= scrollView.contentSize.height)
        {
            isSort = FALSE;
            endFloat = scrollView.contentOffset.y;
            isLoadData = TRUE;
            [NSThread detachNewThreadSelector:@selector(getImageLoad) toTarget:self withObject:nil];
        }
}

-(void)scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate
{
    isLoadImage = TRUE;
    if(!isLoadData && scrollView.contentOffset.y >= 0 && endFloat > scrollView.contentOffset.y && scrollView.contentOffset.y <= scrollView.contentSize.height)
    {
        isSort = TRUE;
        endFloat = scrollView.contentOffset.y;
        isLoadData = TRUE;
        [NSThread detachNewThreadSelector:@selector(getImageLoad) toTarget:self withObject:nil];
    }
    
    if(!isLoadData && scrollView.contentOffset.y >= 0 && endFloat < scrollView.contentOffset.y && scrollView.contentOffset.y <= scrollView.contentSize.height)
    {
        isSort = FALSE;
        endFloat = scrollView.contentOffset.y;
        isLoadData = TRUE;
        [NSThread detachNewThreadSelector:@selector(getImageLoad) toTarget:self withObject:nil];
    }
}

-(void)scrollViewWillBeginDragging:(UIScrollView *)scrollView
{
    isLoadImage = FALSE;
}

#pragma mark UITableViewDelegate

-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    if([sectionarray count] == 0)
    {
        return 1;
    }
    return [sectionarray count];
}

-(NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{
    if([sectionarray count] == 0)
    {
        return nil;
    }
    NSDictionary *dictionary = [sectionarray objectAtIndex:section];
    return [dictionary objectForKey:@"tag"];
}

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if([sectionarray count] == 0)
    {
        return 1;
    }
    NSDictionary *dictionary = [sectionarray objectAtIndex:section];
    int number = [[dictionary objectForKey:@"counts"] intValue];
    if(number%3==0)
    {
        return number/3;
    }
    else
    {
        return number/3+1;
    }
}

-(float)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    if([sectionarray count] == 0)
    {
        return 0;
    }
    return 20;
}

-(float)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if([sectionarray count] == 0)
    {
        return 50;
    }
    NSDictionary *dictionary = [sectionarray objectAtIndex:indexPath.section];
    int number = [[dictionary objectForKey:@"counts"] intValue];
    if(([indexPath row]+1)*3 >= number)
    {
        return 110;
    }
    return 105;
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if([sectionarray count] == 0)
    {
        PhotoFileCell *cell = [[[PhotoFileCell alloc] init] autorelease];
        [cell setSelectionStyle:UITableViewCellSelectionStyleNone];
        cell.textLabel.text = @"等待中...";
        return cell;
    }
    
    int section = [indexPath section];
    int row = [indexPath row];
    static NSString *cellString = @"cellString";
    PhotoFileCell *cell = [self dequeueReusableCellWithIdentifier:cellString];
    if(cell == nil)
    {
        cell = [[[PhotoFileCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellString] autorelease];
        [cell setSelectionStyle:UITableViewCellSelectionStyleNone];
    }
    else
    {
        while ([cell.contentView.subviews lastObject] != nil) {
            [(UIView*)[cell.contentView.subviews lastObject] removeFromSuperview];  //删除并进行重新分配
        }
    }
    
    if([photo_diction.allKeys count] == 0)
    {
        if(indexPath.section<[sectionarray count])
        {
           NSDictionary *dictionary = [sectionarray objectAtIndex:indexPath.section];
            int total = [[dictionary objectForKey:@"counts"] intValue];
            cell.tag = row+UICellTag*section;
            if(total/3 == row)
            {
                int number = 3;
                if(total%3>0)
                {
                    number = total%3;
                }
                for(int i=0;i<number;i++)
                {
                    if(row*3+i>=total)
                    {
                        break;
                    }
                    CGRect rect = CGRectMake(i*105+5, 5, 100, 100);
                    UIImageView *image = [[UIImageView alloc] initWithFrame:rect];
                    UIImage *imageV = [UIImage imageNamed:@"icon_Load.png"];
                    [image performSelectorOnMainThread:@selector(setImage:) withObject:imageV waitUntilDone:YES];
                    [cell.contentView addSubview:image];
                    SelectButton *button = [[SelectButton alloc] initWithFrame:rect];
                    [button setTag:row+UIButtonTag*section];
                    [cell.contentView addSubview:button];
                    [button release];
                }
            }
            else
            {
                for(int i=0;i<3;i++)
                {
                    CGRect rect = CGRectMake(i*105+5, 5, 100, 100);
                    UIImageView *image = [[UIImageView alloc] initWithFrame:rect];
                    UIImage *imageV = [UIImage imageNamed:@"icon_Load.png"];
                    [image performSelectorOnMainThread:@selector(setImage:) withObject:imageV waitUntilDone:YES];
                    [cell.contentView addSubview:image];
                    SelectButton *button = [[SelectButton alloc] initWithFrame:rect];
                    [button setTag:row+UIButtonTag*section];
                    [cell.contentView addSubview:button];
                    [button release];
                }
            }
        }
        else
        {
            NSLog(@"获取文件越界");
        }
    }
    else
    {
        if(indexPath.section<[sectionarray count])
        {
            NSDictionary *dictionary = [sectionarray objectAtIndex:indexPath.section];
            NSString *sectionNumber = [dictionary objectForKey:@"tag"];
            NSArray *array = [photo_diction objectForKey:sectionNumber];
            if([array count]/3 == row)
            {
                cell.tag = row+UICellTag*section;
                int number = 3;
                if([array count]%3>0)
                {
                    number = [array count]%3;
                }
                NSMutableArray *cellArray = [[NSMutableArray alloc] init];
                NSMutableArray *imageArray = [[NSMutableArray alloc] init];
                for(int i=0;i<number;i++)
                {
                    if(row*3+i>=[array count])
                    {
                        NSLog(@"列表越界");
                        break;
                    }
                    CellTag *cellT = [[CellTag alloc] init];
                    PhotoFile *demo = [array objectAtIndex:row*3+i];
                    [cellT setFileTag:demo.f_id];
                    CGRect rect = CGRectMake(i*105+5, 5, 100, 100);
                    UIImageView *image = [[UIImageView alloc] initWithFrame:rect];
                    image.tag = UIImageTag+demo.f_id;
                    [cellT setImageTag:image.tag];
                    
                    {
                        UIImage *imageV = [UIImage imageNamed:@"icon_Load.png"];
                        [image performSelectorOnMainThread:@selector(setImage:) withObject:imageV waitUntilDone:YES];
                    }
                    
                    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_BACKGROUND, 0), ^{
                        if([self image_exists_at_file_path:[NSString stringWithFormat:@"%i",demo.f_id]])
                        {
                            NSString *path = [self get_image_save_file_path:[NSString stringWithFormat:@"%i",demo.f_id]];
                            UIImage *imageV = [UIImage imageWithContentsOfFile:path];
                            
                            if(imageV.size.width>=imageV.size.height)
                            {
                                if(imageV.size.height<=200)
                                {
                                    CGRect imageRect = CGRectMake((imageV.size.width-imageV.size.height)/2, 0, imageV.size.height, imageV.size.height);
                                    imageV = [self imageFromImage:imageV inRect:imageRect];
                                    [image performSelectorOnMainThread:@selector(setImage:) withObject:imageV waitUntilDone:YES];
                                }
                                else
                                {
                                    CGSize newImageSize;
                                    newImageSize.height = 200;
                                    newImageSize.width = 200*imageV.size.width/imageV.size.height;
                                    UIImage *imageS = [self scaleFromImage:imageV toSize:newImageSize];
                                    CGRect imageRect = CGRectMake((newImageSize.width-200)/2, 0, 200, 200);
                                    imageS = [self imageFromImage:imageS inRect:imageRect];
                                    [image performSelectorOnMainThread:@selector(setImage:) withObject:imageS waitUntilDone:YES];
                                }
                            }
                            else if(imageV.size.width<=imageV.size.height)
                            {
                                if(imageV.size.width<=200)
                                {
                                    CGRect imageRect = CGRectMake(0, (imageV.size.height-imageV.size.width)/2, imageV.size.width, imageV.size.width);
                                    imageV = [self imageFromImage:imageV inRect:imageRect];
                                    [image performSelectorOnMainThread:@selector(setImage:) withObject:imageV waitUntilDone:YES];
                                }
                                else
                                {
                                    CGSize newImageSize;
                                    newImageSize.width = 200;
                                    newImageSize.height = 200*imageV.size.height/imageV.size.width;
                                    UIImage *imageS = [self scaleFromImage:imageV toSize:newImageSize];
                                    CGRect imageRect = CGRectMake(0, (newImageSize.height-200)/2, 200, 200);
                                    imageS = [self imageFromImage:imageS inRect:imageRect];
                                    [image performSelectorOnMainThread:@selector(setImage:) withObject:imageS waitUntilDone:YES];
                                }
                            }
                        }
                    });
                    
                    [cell.contentView addSubview:image];
                    [imageArray addObject:image];
                    
                    SelectButton *button = [[SelectButton alloc] initWithFrame:rect];
                    [button setTag:UIButtonTag+demo.f_id];
                    [cellT setButtonTag:button.tag];
                    [cellT setSectionTag:section];
                    [cellT setPageTag:row*3+i];
                    [cellArray addObject:cellT];
                    [button setCell:cellT];
                    
                    [image release];
                    [cellT release];
                    [button addTarget:self action:@selector(clicked:) forControlEvents:UIControlEventTouchUpInside];
                    if(editBL)
                    {
                        for(int i=0;i<[[_dicReuseCells allKeys] count];i++)
                        {
                            int fid = [[_dicReuseCells objectForKey:[[_dicReuseCells allKeys] objectAtIndex:i]] intValue];
                            if(demo.f_id == fid)
                            {
                                [button setSelected:YES];
                                [button setBackgroundImage:[UIImage imageNamed:@"interestSelected.png"] forState:UIControlStateNormal];
                            }
                        }
                    }
                    [cell.contentView addSubview:button];
                    [button release];
                    
                    NSLog(@"imageCount:%i",image.retainCount);
                }
                if([downCellArray count]>5)
                {
                    [downCellArray removeObjectAtIndex:0];
                }
                [downCellArray addObject:cell];
                //        operation *queue = [[operation alloc] init];
                //        [queue cellArray:cellArray imagev:imageArray];
                //        [operationQueue addOperation:queue];
                //        [queue release];
                [cell setCellArray:cellArray];
                [cellArray release];
                [imageArray release];
            }
            else
            {
                cell.tag = row+UICellTag*section;
                NSMutableArray *cellArray = [[NSMutableArray alloc] init];
                NSMutableArray *imageArray = [[NSMutableArray alloc] init];
                for(int i=0;i<3;i++)
                {
                    if(row*3+i>=[array count])
                    {
                        NSLog(@"列表越界");
                        break;
                    }
                    CellTag *cellT = [[CellTag alloc] init];
                    PhotoFile *demo = [array objectAtIndex:row*3+i];
                    [cellT setFileTag:demo.f_id];
                    CGRect rect = CGRectMake(i*105+5, 5, 100, 100);
                    UIImageView *image = [[UIImageView alloc] initWithFrame:rect];
                    image.tag = UIImageTag+demo.f_id;
                    [cellT setImageTag:image.tag];
                    
                    {
                        UIImage *imageV = [UIImage imageNamed:@"icon_Load.png"];
                        [image performSelectorOnMainThread:@selector(setImage:) withObject:imageV waitUntilDone:YES];
                    }
                    
                    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_BACKGROUND, 0), ^{
                        if([self image_exists_at_file_path:[NSString stringWithFormat:@"%i",demo.f_id]])
                        {
                            NSString *path = [self get_image_save_file_path:[NSString stringWithFormat:@"%i",demo.f_id]];
                            UIImage *imageV = [UIImage imageWithContentsOfFile:path];
                            if(imageV.size.width>=imageV.size.height)
                            {
                                if(imageV.size.height<=200)
                                {
                                    CGRect imageRect = CGRectMake((imageV.size.width-imageV.size.height)/2, 0, imageV.size.height, imageV.size.height);
                                    imageV = [self imageFromImage:imageV inRect:imageRect];
                                    [image performSelectorOnMainThread:@selector(setImage:) withObject:imageV waitUntilDone:YES];
                                }
                                else
                                {
                                    CGSize newImageSize;
                                    newImageSize.height = 200;
                                    newImageSize.width = 200*imageV.size.width/imageV.size.height;
                                    UIImage *imageS = [self scaleFromImage:imageV toSize:newImageSize];
                                    CGRect imageRect = CGRectMake((newImageSize.width-200)/2, 0, 200, 200);
                                    imageS = [self imageFromImage:imageS inRect:imageRect];
                                    [image performSelectorOnMainThread:@selector(setImage:) withObject:imageS waitUntilDone:YES];
                                }
                            }
                            else if(imageV.size.width<=imageV.size.height)
                            {
                                if(imageV.size.width<=200)
                                {
                                    CGRect imageRect = CGRectMake(0, (imageV.size.height-imageV.size.width)/2, imageV.size.width, imageV.size.width);
                                    imageV = [self imageFromImage:imageV inRect:imageRect];
                                    [image performSelectorOnMainThread:@selector(setImage:) withObject:imageV waitUntilDone:YES];
                                }
                                else
                                {
                                    CGSize newImageSize;
                                    newImageSize.width = 200;
                                    newImageSize.height = 200*imageV.size.height/imageV.size.width;
                                    UIImage *imageS = [self scaleFromImage:imageV toSize:newImageSize];
                                    CGRect imageRect = CGRectMake(0, (newImageSize.height-200)/2, 200, 200);
                                    imageS = [self imageFromImage:imageS inRect:imageRect];
                                    [image performSelectorOnMainThread:@selector(setImage:) withObject:imageS waitUntilDone:YES];
                                }
                            }
                        }
                    });
                    
                    [cell.contentView addSubview:image];
                    [imageArray addObject:image];
                    
                    SelectButton *button = [[SelectButton alloc] initWithFrame:rect];
                    [button setTag:UIButtonTag+demo.f_id];
                    [cellT setButtonTag:button.tag];
                    [cellT setSectionTag:section];
                    [cellT setPageTag:row*3+i];
                    [cellArray addObject:cellT];
                    [button setCell:cellT];
                    
                    [image release];
                    [cellT release];
                    [button addTarget:self action:@selector(clicked:) forControlEvents:UIControlEventTouchUpInside];
                    if(editBL)
                    {
                        for(int i=0;i<[[_dicReuseCells allKeys] count];i++)
                        {
                            int fid = [[_dicReuseCells objectForKey:[[_dicReuseCells allKeys] objectAtIndex:i]] intValue];
                            if(demo.f_id == fid)
                            {
                                [button setSelected:YES];
                                [button setBackgroundImage:[UIImage imageNamed:@"interestSelected.png"] forState:UIControlStateNormal];
                            }
                        }
                    }
                    [cell.contentView addSubview:button];
                    [button release];
                    
                    NSLog(@"imageCount:%i",image.retainCount);
                }
                if([downCellArray count]>5)
                {
                    [downCellArray removeObjectAtIndex:0];
                }
                [downCellArray addObject:cell];
                //        operation *queue = [[operation alloc] init];
                //        [queue cellArray:cellArray imagev:imageArray];
                //        [operationQueue addOperation:queue];
                //        [queue release];
                [cell setCellArray:cellArray];
                [cellArray release];
                [imageArray release];
            }
        }
        else
        {
            NSLog(@"获取文件越界");
        }
    }
    return cell;
}

-(void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if(alertView.tag == kAlertTagMailAddr)
    {
        if (buttonIndex==1) {
            NSString *fildtext=[[alertView textFieldAtIndex:0] text];
            if (![self checkIsEmail:fildtext])
            {
                if (self.hud) {
                    [self.hud removeFromSuperview];
                }
                return;
            }
            
            NSMutableArray *f_ids=[NSMutableArray array];
            for (int i=0;i<_dicReuseCells.allKeys.count;i++) {
                NSString *key = [_dicReuseCells.allKeys objectAtIndex:i];
                NSString *fid = [NSString stringWithFormat:@"%@",[_dicReuseCells objectForKey:key]];
                if (fid) {
                    [f_ids addObject:fid];
                }
            }
            
            [linkManager releaseLinkEmail:f_ids l_pwd:@"a1b2" receiver:@[fildtext]];
            
            NSLog(@"点击确定");
        }else
        {
            NSLog(@"点击其它");
        }
    }
}

-(BOOL)checkIsEmail:(NSString *)text
{
    NSString *Regex = @"[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,4}";
    
    NSPredicate *emailTest = [NSPredicate predicateWithFormat:@"SELF MATCHES %@", Regex];
    
    return [emailTest evaluateWithObject:text];
}

#pragma mark UIActionSheetDelegate
-(void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if(actionSheet.tag == kActionSheetTagShare)
    {
        if (buttonIndex == 0) {
            NSLog(@"短信分享");
            //[self toDelete:nil];
            [self messageShare:actionSheet.title];
        }else if (buttonIndex == 1) {
            NSLog(@"邮件分享");
            NSString *name=@"";
            UIAlertView *alert=[[UIAlertView alloc] initWithTitle:@"邮件分享" message:@"请您输入分享人的邮件地址：" delegate:self cancelButtonTitle:@"取消" otherButtonTitles:@"确定", nil];
            [alert setAlertViewStyle:UIAlertViewStylePlainTextInput];
            [[alert textFieldAtIndex:0] setText:name];
            [alert setTag:kAlertTagMailAddr];
            [alert show];
        }else if(buttonIndex == 2) {
            NSLog(@"复制");
            [self pasteBoard:actionSheet.title];
        }else if(buttonIndex == 3) {
            NSLog(@"微信");
            [self weixin:actionSheet.title];
        }else if(buttonIndex == 4) {
            NSLog(@"朋友圈");
            [self frends:actionSheet.title];
        }else if(buttonIndex == 5) {
            NSLog(@"新浪");
        }else if(buttonIndex == 6) {
            NSLog(@"取消");
        }
    }
    else if(actionSheet.tag == kAlertTagDeleteOne)
    {
        if(buttonIndex == 0)
        {
            NSMutableArray *array = [[NSMutableArray alloc] init];
            
            for(int i=0;i<[_dicReuseCells.allKeys count];i++)
            {
                NSString *f_id=[_dicReuseCells objectForKey:[_dicReuseCells.allKeys objectAtIndex:i]];
                [array addObject:f_id];
            }
            if([array count]>0)
            {
                [fileManager removeFileWithIDs:array];
                [_dicReuseCells removeAllObjects];
            }
            [array release];
        }
    }
    else if(actionSheet.tag == kActionSheetTagMore)
    {
        if(buttonIndex == 0)
        {
            [self toMove:nil];
        }
    }
}

-(void)mailShare:(NSString *)content
{
    sharedType = 2;
    [self getPubSharedLink];
}

-(void)pasteBoard:(NSString *)content
{
    sharedType = 3;
    [self getPubSharedLink];
}

-(void)messageShare:(NSString *)content
{
    sharedType = 1;
    [self getPubSharedLink];
}

-(void)weixin:(NSString *)content
{
    sharedType = 4;
    [self getPubSharedLink];
}

-(void)frends:(NSString *)content
{
    sharedType = 5;
    [self getPubSharedLink];
}

#pragma mark 分享方法
-(void)getPubSharedLink
{
    linkManager.delegate = self;
    if([_dicReuseCells.allKeys count]>0)
    {
        NSMutableArray *f_ids=[NSMutableArray array];
        for (int i=0;i<_dicReuseCells.allKeys.count;i++) {
            NSString *key = [_dicReuseCells.allKeys objectAtIndex:i];
            NSString *fid = [NSString stringWithFormat:@"%@",[_dicReuseCells objectForKey:key]];
            if (fid) {
                [f_ids addObject:fid];
            }
        }
        [linkManager linkWithIDs:f_ids];
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

-(BOOL)startTimeMoreThanEndTime:(NSString *)sTime eTime:(NSString *)eTime
{
    NSDateFormatter *dateFormatter = [[[NSDateFormatter alloc] init] autorelease];
    [dateFormatter setDateStyle:NSDateFormatterMediumStyle];
    [dateFormatter setTimeStyle:NSDateFormatterShortStyle];
    [dateFormatter setDateFormat:@"yyyy-MM-dd HH:mm"];
    NSDate *sDate = [dateFormatter dateFromString:sTime];
    NSDate *eDate = [dateFormatter dateFromString:eTime];
    if([sDate timeIntervalSince1970]<[eDate timeIntervalSince1970])
    {
        return YES;
    }
    return NO;
}

#pragma mark 

//编辑事件
-(void)editAction
{
    if(!editBL)
    {
        [_dicReuseCells removeAllObjects];
        editBL = YES;
    }
}

//取消事件
-(void)escAction
{
    if(editBL)
    {
        editBL = FALSE;
        NSArray *cellArrays = [self indexPathsForVisibleRows];
        for(int i=0;i<[cellArrays count];i++)
        {
            PhotoFileCell *cell = (PhotoFileCell *)[self cellForRowAtIndexPath:[cellArrays objectAtIndex:i]];
            NSArray *array = [cell cellArray];
            for(int j=0;j<[array count];j++)
            {
                CellTag *cellTag = [array objectAtIndex:j];
                for(int k=0;k<[[_dicReuseCells allKeys] count];k++)
                {
                    int fid = [[_dicReuseCells objectForKey:[[_dicReuseCells allKeys] objectAtIndex:k]] intValue];
                    if(cellTag.fileTag == fid)
                    {
                        UIButton *button = (UIButton *)[self viewWithTag:cellTag.buttonTag];
                        [button setBackgroundImage:[UIImage imageNamed:@"111.png"] forState:UIControlStateNormal];
                        [button setSelected:NO];
                    }
                }
            }
        }
    }
}

//全部选中事件
-(void)allCehcked
{
    NSArray *cellArrays = [self indexPathsForVisibleRows];
    for(int i=0;i<[cellArrays count];i++)
    {
        PhotoFileCell *cell = (PhotoFileCell *)[self cellForRowAtIndexPath:[cellArrays objectAtIndex:i]];
        NSArray *array = [cell cellArray];
        for(int j=0;j<[array count];j++)
        {
            CellTag *cellTag = [array objectAtIndex:j];
            UIButton *button = (UIButton *)[self viewWithTag:cellTag.buttonTag];
            [button setBackgroundImage:[UIImage imageNamed:@"interestSelected.png"] forState:UIControlStateNormal];
            [button setSelected:YES];
        }
    }
    
    for(int i=0;i<[sectionarray count];i++)
    {
        NSDictionary *dictionary = [sectionarray objectAtIndex:i];
        NSString *sectionNumber = [dictionary objectForKey:@"tag"];
        NSArray *array = [photo_diction objectForKey:sectionNumber];
        for(int j=0;j<[array count];j++)
        {
            PhotoFile *demo = [array objectAtIndex:j];
            [_dicReuseCells setObject:[NSNumber numberWithInt:demo.f_id] forKey:[NSString stringWithFormat:@"%i",demo.f_id]];
        }
    }
}

//全部取消
-(void)allEscCheckde
{
    NSArray *cellArrays = [self indexPathsForVisibleRows];
    for(int i=0;i<[cellArrays count];i++)
    {
        PhotoFileCell *cell = (PhotoFileCell *)[self cellForRowAtIndexPath:[cellArrays objectAtIndex:i]];
        NSArray *array = [cell cellArray];
        for(int j=0;j<[array count];j++)
        {
            CellTag *cellTag = [array objectAtIndex:j];
            UIButton *button = (UIButton *)[self viewWithTag:cellTag.buttonTag];
            [button setBackgroundImage:[UIImage imageNamed:@"111.png"] forState:UIControlStateNormal];
            [button setSelected:NO];
        }
    }
    [_dicReuseCells removeAllObjects];
}


#pragma mark 分享文件
-(void)toShared:(id)sender
{
    UIActionSheet *actionSheet=[[UIActionSheet alloc]  initWithTitle:@"分享" delegate:self cancelButtonTitle:@"取消" destructiveButtonTitle:nil otherButtonTitles:@"短信分享",@"邮件分享",@"复制链接",@"分享到微信好友",@"分享到微信朋友圈", nil];
    NSString *l_url=@"分享";
    [actionSheet setTitle:l_url];
    [actionSheet setTag:kActionSheetTagShare];
    [actionSheet setActionSheetStyle:UIActionSheetStyleBlackOpaque];
    [actionSheet showInView:[[UIApplication sharedApplication] keyWindow]];
    [actionSheet release];
}

#pragma mark 移动文件
-(void)toMove:(id)sender
{
    
}

#pragma mark 删除文件
-(void)toDelete:(id)sender
{
    UIActionSheet *actioinSheet = [[UIActionSheet alloc] initWithTitle:@"是否要删除文件" delegate:self cancelButtonTitle:@"取消" destructiveButtonTitle:@"删除" otherButtonTitles:nil, nil];
    [actioinSheet showInView:[[UIApplication sharedApplication] keyWindow]];
    [actioinSheet setActionSheetStyle:UIActionSheetStyleBlackOpaque];
    [actioinSheet setTag:kAlertTagDeleteOne];
    [actioinSheet release];
}


#pragma mark SCBFileManagerDelegate

-(void)searchSucess:(NSDictionary *)datadic{}
-(void)operateSucess:(NSDictionary *)datadic{}
-(void)openFinderSucess:(NSDictionary *)datadic{}
//打开家庭成员
-(void)getOpenFamily:(NSDictionary *)dictionary
{
    NSLog(@"dictionary:%@",dictionary);
    NSMutableArray *table_array = [[NSMutableArray alloc] init];
    NSArray *array = [dictionary objectForKey:@"spaces"];
    if([array count] > 0)
    {
        [table_array addObjectsFromArray:array];
        NSMutableArray *marray=[NSMutableArray array];
        for (NSDictionary *dic in array) {
            NSString *str=[dic objectForKey:@"space_id"];
            if (str) {
                [marray addObject:str];
            }
        }
        [YNFunctions setAllFamily:marray];
    }
    [photo_delegate setMemberArray:table_array];
    [table_array release];
}
-(void)openFinderUnsucess{}
-(void)removeSucess{}
-(void)removeUnsucess{}
-(void)renameSucess{}
-(void)renameUnsucess{}
-(void)moveSucess{}
-(void)moveUnsucess{}
-(void)newFinderSucess{}
-(void)newFinderUnsucess{}

#pragma mark  SCBLinkManagerDelegate
-(void)releaseEmailSuccess:(NSString *)l_url
{
    NSLog(@"邮件分享成功：%@",l_url);
}
-(void)releaseLinkSuccess:(NSString *)l_url
{
    NSLog(@"releaseLinkSuccess:%@",l_url);
    if(sharedType == 1)
    {
        //短信分享
        [photo_delegate messageShare:l_url];
    }
    else if(sharedType == 2)
    {
        //邮件分享
        [photo_delegate mailShare:l_url];
    }
    else if(sharedType == 3)
    {
        //复制
        [[UIPasteboard generalPasteboard] setString:l_url];
        if (self.hud) {
            [self.hud removeFromSuperview];
        }
        self.hud=nil;
        self.hud=[[MBProgressHUD alloc] initWithView:self];
        [self addSubview:self.hud];
        [self.hud show:NO];
        self.hud.labelText=@"已经复制成功";
        self.hud.mode=MBProgressHUDModeText;
        self.hud.margin=10.f;
        [self.hud show:YES];
        [self.hud hide:YES afterDelay:1.0f];
    }
    else if(sharedType == 4)
    {
        //微信
        NSString *text=[NSString stringWithFormat:@"%@想和您分享虹盘的文件，链接地址：%@",[[NSUserDefaults standardUserDefaults] objectForKey:@"usr_name"],l_url];
        
        AppDelegate *appDelegate= (AppDelegate *)[[UIApplication sharedApplication] delegate];
        [appDelegate sendImageContentIsFiends:NO text:text];
    }
    else if(sharedType == 5)
    {
        NSString *text=[NSString stringWithFormat:@"%@想和您分享虹盘的文件，链接地址：%@",[[NSUserDefaults standardUserDefaults] objectForKey:@"usr_name"],l_url];
        
        AppDelegate *appDelegate=(AppDelegate *)[[UIApplication sharedApplication] delegate];
        [appDelegate sendImageContentIsFiends:YES text:text];
    }
}
-(void)releaseLinkUnsuccess:(NSString *)error_info{
    NSLog(@"openFinderUnsucess: 网络连接失败!!");
    if (self.hud) {
        [self.hud removeFromSuperview];
    }
    self.hud=nil;
    self.hud=[[MBProgressHUD alloc] initWithView:self];
    [self addSubview:self.hud];
    [self.hud show:NO];
    if (error_info==nil||[error_info isEqualToString:@""]) {
        self.hud.labelText=@"获取外链失败";
    }else
    {
        self.hud.labelText=error_info;
    }
    self.hud.mode=MBProgressHUDModeText;
    self.hud.margin=10.f;
    [self.hud show:YES];
    [self.hud hide:YES afterDelay:1.0f];
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

-(UIImage *)imageFromImage:(UIImage *)image inRect:(CGRect)rect{
	CGImageRef sourceImageRef = [image CGImage];
	CGImageRef newImageRef = CGImageCreateWithImageInRect(sourceImageRef, rect);
	UIImage *newImage = [UIImage imageWithCGImage:newImageRef];
    CGImageRelease(newImageRef);
	return newImage;
}

-(UIImage *)scaleFromImage:(UIImage *)image toSize:(CGSize)size
{
    UIGraphicsBeginImageContext(size);
    [image drawInRect:CGRectMake(0, 0, size.width, size.height)];
    UIImage *newImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return newImage;
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

-(void)dealloc
{
    [_dicReuseCells release];
    [photo_diction release];
    [sectionarray release];
    [downCellArray release];
    [fileManager release];
    [linkManager release];
    [requestId release];
    [super dealloc];
}

@end
