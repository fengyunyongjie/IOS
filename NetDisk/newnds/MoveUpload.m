//
//  MoveUpload.m
//  NetDisk
//
//  Created by Yangsl on 13-9-26.
//
//  新代码

#import "MoveUpload.h"
#import "MKNetworkKit.h"
#import <AssetsLibrary/AssetsLibrary.h>
#import "UpLoadList.h"
#import "NSString+Format.h"
#import "SCBSession.h"
#import "AppDelegate.h"

@implementation MoveUpload
@synthesize uploadArray,isStopCurrUpload,isStart,isOpenedUpload;

-(id)init
{
    self = [super init];
    [self selectUploadList];
    return self;
}

//查询出所有数据
-(void)selectUploadList
{
    UpLoadList *list = [[UpLoadList alloc] init];
    uploadArray = [[NSMutableArray alloc] initWithArray:[list selectMoveUploadListAllAndNotUpload]];
    [list release];
}

-(void)updateLoad
{
    AppDelegate *appleDate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
    UINavigationController *NavigationController = [[appleDate.myTabBarController viewControllers] objectAtIndex:2];
    ChangeUploadViewController *uploadView = (ChangeUploadViewController *)[NavigationController.viewControllers objectAtIndex:0];
    if([uploadView isKindOfClass:[ChangeUploadViewController class]])
    {
        if([uploadView.uploadingList count] == 0 || !uploadView.uploadingList)
        {
            [uploadView setUploadingList:uploadArray];
        }
        [uploadView.uploadListTableView reloadData];
    }
    [appleDate.myTabBarController addUploadNumber:[uploadArray count]];
    UIApplication *app = [UIApplication sharedApplication];
    app.applicationIconBadgeNumber = [uploadArray count];
    if(!isStart)
    {
        [self upNetworkStop];
    }
}

-(void)changeUpload:(NSMutableOrderedSet *)array_ changeDeviceName:(NSString *)device_name changeFileId:(NSString *)f_id changeSpaceId:(NSString *)s_id
{
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 0), ^{
        if([array_ count]>0)
        {
            for(int i=0;i<[array_ count];i++)
            {
                if(i == 0)
                {
                    dispatch_async(dispatch_get_main_queue(), ^{
                    AppDelegate *appleDate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
                    [appleDate.myTabBarController addUploadNumber:[array_ count]];
                    UIApplication *app = [UIApplication sharedApplication];
                    app.applicationIconBadgeNumber = [array_ count];
                    });
                }
                ALAsset *asset = [array_ objectAtIndex:i];
                UpLoadList *list = [[UpLoadList alloc] init];
                list.t_date = @"";
                list.t_lenght = asset.defaultRepresentation.size;
                list.t_name = [NSString formatNSStringForOjbect:asset.defaultRepresentation.filename];
                list.t_state = 0;
                list.t_fileUrl = [NSString formatNSStringForOjbect:asset.defaultRepresentation.url];
                list.t_url_pid = [NSString formatNSStringForOjbect:f_id];
                list.t_url_name = [NSString formatNSStringForOjbect:device_name];
                list.t_file_type = 0;
                list.user_id = [NSString formatNSStringForOjbect:[[SCBSession sharedSession] userId]];
                list.file_id = @"";
                list.upload_size = 0;
                list.is_autoUpload = NO;
                list.is_share = NO;
                list.spaceId = [NSString formatNSStringForOjbect:s_id];
                [list insertUploadList];
                [list release];
            }
        }
        [self updateUploadList];
    });
}

//查询出所有数据
-(void)updateUploadList
{
    UpLoadList *list = [[UpLoadList alloc] init];
    if([uploadArray count] == 0)
    {
        list.t_id = 0;
    }
    else
    {
        list.t_id =  ((UpLoadList *)[uploadArray lastObject]).t_id;
    }
    
    [uploadArray addObjectsFromArray:[list selectMoveUploadListAllAndNotUpload]];
    [list release];
    [self updateTable];
    [self start];
}

-(void)start
{
    isOpenedUpload = YES;
    if(!isStart)
    {
        isStart = YES;
        isStopCurrUpload = NO;
        [self updateTableStateForWaiting];
        [self startUpload];
    }
}

//开始上传
-(void)startUpload
{
    if([uploadArray count]>0 && isStart)
    {
        NewUpload *newUpload = [[NewUpload alloc] init];
        newUpload.list = [uploadArray objectAtIndex:0];
        [newUpload setDelegate:self];
        [newUpload startUpload];
        [newUpload release];
    }
    else
    {
        isStart = FALSE;
    }
}


#pragma mark NewUploadDelegate

//上传成功
-(void)upFinish:(NSDictionary *)dicationary
{
    if([uploadArray count]>0)
    {
        UpLoadList *list = [uploadArray objectAtIndex:0];
        list.t_state = 1;
        list.upload_size = list.t_lenght;
        list.file_id = [NSString formatNSStringForOjbect:[dicationary objectForKey:@"fid"]];
        NSCalendar *calendar = [NSCalendar currentCalendar];
        NSDate *todayDate = [NSDate date];
        NSDateComponents *todayComponent = [calendar components:NSEraCalendarUnit| NSYearCalendarUnit| NSMonthCalendarUnit| NSDayCalendarUnit| NSHourCalendarUnit| NSMinuteCalendarUnit | NSSecondCalendarUnit| NSWeekCalendarUnit | NSWeekdayCalendarUnit | NSWeekdayOrdinalCalendarUnit | NSQuarterCalendarUnit | NSWeekOfMonthCalendarUnit | NSWeekOfYearCalendarUnit | NSYearForWeekOfYearCalendarUnit fromDate:todayDate];
        list.t_date = [NSString stringWithFormat:@"%i-%i-%i %i:%i:%i",todayComponent.year,todayComponent.month,todayComponent.day,todayComponent.hour,todayComponent.minute,todayComponent.second];
        [list updateUploadList];
        [uploadArray removeObjectAtIndex:0];
        [self updateTable];
    }
    [self startUpload];
}
//上传进行时，发送上传进度数据
-(void)upProess:(float)proress fileTag:(NSInteger)fileTag
{
    if([uploadArray count]>0)
    {
        UpLoadList *list = [uploadArray objectAtIndex:0];
        list.upload_size = proress;
        float f = (float)list.upload_size / (float)list.t_lenght;
        NSLog(@"上传进度:%f",f);
        [self updateTable];
    }
}

//上传失败
-(void)upError
{
    isStopCurrUpload = FALSE;
    [self startUpload];
}

//等待WiFi
-(void)upWaitWiFi
{
    isStopCurrUpload = FALSE;
    isStart = FALSE;
    [self updateTableStateForWaitWiFi];
}

//文件重名
-(void)upReName
{
    if([uploadArray count]>0)
    {
        UpLoadList *list = [uploadArray objectAtIndex:0];
        [list deleteUploadList];
        [uploadArray removeObjectAtIndex:0];
        [self updateTable];
    }
    [self startUpload];
}

//网络失败
-(void)upNetworkStop
{
    isStopCurrUpload = FALSE;
    isStart = FALSE;
    [self updateTableStateForStop];
}

//更新ui
-(void)updateTable
{
    AppDelegate *appleDate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
    UINavigationController *NavigationController = [[appleDate.myTabBarController viewControllers] objectAtIndex:2];
    ChangeUploadViewController *uploadView = (ChangeUploadViewController *)[NavigationController.viewControllers objectAtIndex:0];
    if([uploadView isKindOfClass:[ChangeUploadViewController class]])
    {
        [uploadView.uploadListTableView reloadData];
    }
    [appleDate.myTabBarController addUploadNumber:[uploadArray count]+[appleDate.autoUpload.uploadArray count]];
    UIApplication *app = [UIApplication sharedApplication];
    app.applicationIconBadgeNumber = [uploadArray count]+[appleDate.autoUpload.uploadArray count];
}

//修改Ui状态为等待WiFi
-(void)updateTableStateForWaitWiFi
{
    for (int i=0; i<[uploadArray count]; i++) {
        UpLoadList *list = [uploadArray objectAtIndex:i];
        list.t_state = 3;
    }
    [self updateTable];
}

//修改Ui状态为等待
-(void)updateTableStateForWaiting
{
    for (int i=0; i<[uploadArray count]; i++) {
        UpLoadList *list = [uploadArray objectAtIndex:i];
        list.t_state = 0;
        list.upload_size = 0;
    }
    [self updateTable];
}

//修改Ui状态为暂停
-(void)updateTableStateForStop
{
    for (int i=0; i<[uploadArray count]; i++) {
        UpLoadList *list = [uploadArray objectAtIndex:i];
        list.t_state = 2;
    }
    [self updateTable];
}

//暂时所有上传
-(void)stopAllUpload
{
    isOpenedUpload = FALSE;
    isStopCurrUpload = YES;
    isStart = NO;
}

//删除一条上传
-(void)deleteOneUpload:(NSInteger)selectIndex
{
    if(selectIndex == 0)
    {
        [self deleteCurrUpload];
    }
    else
    {
        if([uploadArray count]>selectIndex)
        {
            UpLoadList *list = [uploadArray objectAtIndex:selectIndex];
            [list deleteUploadList];
            [uploadArray removeObjectAtIndex:selectIndex];
            [self updateTable];
        }
    }
}

//删除本次上传
-(void)deleteCurrUpload
{
    isStopCurrUpload = YES;
    if(!isStart)
    {
        if([uploadArray count]>0)
        {
            UpLoadList *list = [uploadArray objectAtIndex:0];
            [list deleteUploadList];
            [uploadArray removeObjectAtIndex:0];
            [self updateTable];
        }
    }
}

//删除所有上传
-(void)deleteAllUpload
{
    isStopCurrUpload = YES;
    isStart = NO;
    UpLoadList *list = [[UpLoadList alloc] init];
    BOOL bl = [list deleteMoveUploadListAllAndNotUpload];
    if(bl)
    {
        if(uploadArray)
        {
            [uploadArray removeAllObjects];
            [self updateTable];
        }
    }
}

@end
