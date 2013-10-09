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
    list.user_id = [NSString formatNSStringForOjbect:[[SCBSession sharedSession] userId]];
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
    [appleDate.myTabBarController addUploadNumber:[uploadArray count]+[appleDate.autoUpload.uploadArray count]];
    UIApplication *app = [UIApplication sharedApplication];
    app.applicationIconBadgeNumber = [uploadArray count]+[appleDate.autoUpload.uploadArray count];
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
                        [appleDate.myTabBarController addUploadNumber:[array_ count]+[appleDate.autoUpload.uploadArray count]];
                        UIApplication *app = [UIApplication sharedApplication];
                        app.applicationIconBadgeNumber = [array_ count]+[appleDate.autoUpload.uploadArray count];
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
                NSLog(@"[[SCBSession sharedSession] spaceID]:%@;[[SCBSession sharedSession] homeID]:%@",[[SCBSession sharedSession] spaceID],[[SCBSession sharedSession] homeID]);
                AppDelegate *appleDate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
                if(appleDate.isShareUpload)
                {
                    list.is_share = YES;
                }
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
    list.user_id = [NSString formatNSStringForOjbect:[[SCBSession sharedSession] userId]];
    
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
        [self updateTableStateForWaiting];
        [self startUpload];
    }
}

//开始上传
-(void)startUpload
{
    if([uploadArray count]>0 && isStart)
    {
        AppDelegate *app = (AppDelegate *)[[UIApplication sharedApplication] delegate];
        [app.autoUpload stopUpload];
        [app.autoUpload updateUploadStartButton:@"继续"];
        [app.autoUpload updateUploadStartButtonState:NO];
        isStopCurrUpload = NO;
        NewUpload *newUpload = [[NewUpload alloc] init];
        newUpload.list = [uploadArray objectAtIndex:0];
        [newUpload setDelegate:self];
        [newUpload startUpload];
        [newUpload release];
    }
    if([uploadArray count]==0)
    {
        isStart = FALSE;
        AppDelegate *app = (AppDelegate *)[[UIApplication sharedApplication] delegate];
        [app.autoUpload updateUploadStartButtonState:YES];
        [self updateTable];
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

//用户存储空间不足
-(void)upUserSpaceLass
{
    //调用ui
    dispatch_async(dispatch_get_main_queue(), ^{
        AppDelegate *appleDate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
        UINavigationController *NavigationController = [[appleDate.myTabBarController viewControllers] objectAtIndex:2];
        ChangeUploadViewController *uploadView = (ChangeUploadViewController *)[NavigationController.viewControllers objectAtIndex:0];
        if([uploadView isKindOfClass:[ChangeUploadViewController class]])
        {
            [uploadView uploadFail:@"用户存储空间不足"];
        }
    });
    [self upNetworkStop];
}

-(void)upNotUpload
{
    //调用ui
    dispatch_async(dispatch_get_main_queue(), ^{
        AppDelegate *appleDate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
        UINavigationController *NavigationController = [[appleDate.myTabBarController viewControllers] objectAtIndex:2];
        ChangeUploadViewController *uploadView = (ChangeUploadViewController *)[NavigationController.viewControllers objectAtIndex:0];
        if([uploadView isKindOfClass:[ChangeUploadViewController class]])
        {
            [uploadView uploadFail:@"无权限上传"];
        }
    });
    if([uploadArray count]>0)
    {
        UpLoadList *list = [uploadArray objectAtIndex:0];
        [list deleteUploadList];
        [uploadArray removeObjectAtIndex:0];
        [self updateTable];
    }
    [self startUpload];
}

//服务器异常
-(void)webServiceFail
{
    [self upError];
}

//上传失败
-(void)upError
{
    isStopCurrUpload = YES;
    if([uploadArray count]>0)
    {
        UpLoadList *list = [uploadArray objectAtIndex:0];
        [list deleteUploadList];
        [uploadArray removeObjectAtIndex:0];
        [self updateTable];
    }
    [self startUpload];
}

//等待WiFi
-(void)upWaitWiFi
{
    isStopCurrUpload = YES;
    isStart = FALSE;
    [self updateTableStateForWaitWiFi];
}

//文件重名
-(void)upReName
{
    if([uploadArray count]>0)
    {
        UpLoadList *list = [uploadArray objectAtIndex:0];
        list.t_state = 1;
        list.upload_size = list.t_lenght;
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

//网络失败
-(void)upNetworkStop
{
    isStopCurrUpload = YES;
    isStart = FALSE;
    AppDelegate *app = (AppDelegate *)[[UIApplication sharedApplication] delegate];
    if(!app.autoUpload.isGoOn)
    {
        [app.autoUpload updateUploadStartButton:@"继续"];
    }
    [self updateTableStateForStop];
}

//更新ui
-(void)updateTable
{
    dispatch_async(dispatch_get_main_queue(), ^{
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
    });
}

//修改Ui状态为等待WiFi
-(void)updateTableStateForWaitWiFi
{
    for (int i=0; i<[uploadArray count]; i++) {
        UpLoadList *list = [uploadArray objectAtIndex:i];
        list.t_state = 3;
    }
    AppDelegate *app = (AppDelegate *)[[UIApplication sharedApplication] delegate];
    [app.autoUpload updateUploadStartButton:@"继续"];
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
    AppDelegate *app = (AppDelegate *)[[UIApplication sharedApplication] delegate];
    [app.autoUpload updateUploadStartButton:@"继续"];
    isOpenedUpload = FALSE;
    isStopCurrUpload = YES;
    isStart = NO;
}

//删除一条上传
-(void)deleteOneUpload:(NSInteger)selectIndex
{
    for(int i=0;i<[uploadArray count];i++)
    {
        UpLoadList *list = [uploadArray objectAtIndex:i];
        NSLog(@"list.id:%i",list.t_id);
        if(list.t_id == selectIndex)
        {
            if(i == 0)
            {
                isStopCurrUpload = YES;
            }
            [list deleteUploadList];
            [uploadArray removeObjectAtIndex:i];
            [self updateTable];
            break;
        }
    }
}

//删除所有上传
-(void)deleteAllUpload
{
    isStopCurrUpload = YES;
    isStart = NO;
    UpLoadList *list = [[UpLoadList alloc] init];
    list.user_id = [NSString formatNSStringForOjbect:[[SCBSession sharedSession] userId]];
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
