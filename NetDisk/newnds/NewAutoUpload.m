//
//  NewAutoUpload.m
//  NetDisk
//
//  Created by Yangsl on 13-9-27.
//
//

#import "NewAutoUpload.h"
#import <AssetsLibrary/AssetsLibrary.h>
#import "UserInfo.h"
#import "AppDelegate.h"
#import "UpLoadList.h"
#import "NSString+Format.h"
#import "SCBSession.h"
#import "AutoUploadList.h"
#import "SCBSession.h"
#import "NSString+Format.h"

@implementation NewAutoUpload
@synthesize uploadArray,isStopCurrUpload,isStart,isOpenedUpload,isStop;

/*
 
 1.检查照片库
 2.比对
 3.查询
 4.上传
 5.结束
 */

-(void)selectPhotoLibary
{
    isStop = YES;
    UserInfo *info = [[[UserInfo alloc] init] autorelease];
    info.user_name = [NSString formatNSStringForOjbect:[[SCBSession sharedSession] userName]];
    NSMutableArray *array = [info selectAllUserinfo];
    if([array count] == 0)
    {
        info.f_id = -1;
        info.auto_url = [NSString stringWithFormat:@"手机照片/来自于-%@",[AppDelegate deviceString]];
        info.space_id = [NSString formatNSStringForOjbect:[[SCBSession sharedSession] spaceID]];
        [info insertUserinfo];
    }
    else
    {
        UserInfo *uinfo = [array lastObject];
        info.f_id = uinfo.f_id;
        info.space_id = uinfo.space_id;
        info.auto_url = uinfo.auto_url;
    }
    
    ALAssetsLibrary *library = [[[ALAssetsLibrary alloc] init] autorelease];
    [library enumerateGroupsWithTypes:ALAssetsGroupSavedPhotos usingBlock:^(ALAssetsGroup *group, BOOL *stop) {//获取所有groups
        __block int total = 0;
        if([group numberOfAssets]>0)
        {
            NSLog(@"[group numberOfAssets]:%i",[group numberOfAssets]);
            [group enumerateAssetsUsingBlock:^(ALAsset *asset, NSUInteger index, BOOL *stop) {
                NSString* assetType = [asset valueForProperty:ALAssetPropertyType];
                if ([assetType isEqualToString:ALAssetTypePhoto]) {
                    if(asset)
                    {
                        AutoUploadList *ls = [[[AutoUploadList alloc] init] autorelease];
                        ls.a_name = [NSString formatNSStringForOjbect:asset.defaultRepresentation.filename];
                        ls.a_user_id = [NSString formatNSStringForOjbect:[[SCBSession sharedSession] userId]];
                        BOOL bl = [ls selectAutoUploadList];
                        if(!bl)
                        {
                            UpLoadList *list = [[UpLoadList alloc] init];
                            list.t_date = @"";
                            list.t_lenght = asset.defaultRepresentation.size;
                            list.t_name = [NSString formatNSStringForOjbect:asset.defaultRepresentation.filename];
                            list.t_state = 0;
                            list.t_fileUrl = [NSString formatNSStringForOjbect:asset.defaultRepresentation.url];
                            list.t_url_pid = [NSString formatNSStringForOjbect:[NSNumber numberWithInt:info.f_id]];
                            list.t_url_name = [NSString formatNSStringForOjbect:info.auto_url];
                            list.t_file_type = 0;
                            list.user_id = [NSString formatNSStringForOjbect:[[SCBSession sharedSession] userId]];
                            list.file_id = @"";
                            list.upload_size = 0;
                            list.is_autoUpload = YES;
                            list.is_share = NO;
                            list.spaceId = [NSString formatNSStringForOjbect:info.space_id];
                            [list insertUploadList];
                            ls.a_user_id = [NSString formatNSStringForOjbect:list.user_id];
                            ls.a_state = 0;
                            [ls insertAutoUploadList];
                            
                            AppDelegate *appleDate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
                            UINavigationController *NavigationController = [[appleDate.myTabBarController viewControllers] objectAtIndex:2];
                            ChangeUploadViewController *uploadView = (ChangeUploadViewController *)[NavigationController.viewControllers objectAtIndex:0];
                            if([uploadView isKindOfClass:[ChangeUploadViewController class]])
                            {
                                if(uploadView.uploadListTableView.tableHeaderView == nil)
                                {
                                    NSInteger count = [ls SelectCountAutoUploadList];
                                    [uploadView startAutomaticList:list total:[group numberOfAssets]-count];
                                    [appleDate.myTabBarController addUploadNumber:[uploadArray count]+[appleDate.moveUpload.uploadArray count]-count];
                                    UIApplication *app = [UIApplication sharedApplication];
                                    app.applicationIconBadgeNumber = [uploadArray count]+[appleDate.moveUpload.uploadArray count]-count;
                                }
                            }
                            
                            [list release];
                        }
                    }
                }
                total++;
            }];
            if([group numberOfAssets]<=total-1)
            {
                isStop = FALSE;
                if(!isStart)
                {
                    isStart = TRUE;
                    [NSThread detachNewThreadSelector:@selector(startUpload) toTarget:self withObject:nil];
                }
            }
        }
    } failureBlock:^(NSError *error) {
        isStop = FALSE;
        isStart = FALSE;
        dispatch_async(dispatch_get_main_queue(), ^{
        NSString *titleString;
        if([[[UIDevice currentDevice] systemVersion] intValue]>=6.0)
        {
            titleString = @"因iOS系统限制，开启照片服务才能上传，传输过程严格加密，不会作其他用途。\n\n\t步骤：设置>隐私>照片>虹盘";
        }
        else
        {
            titleString = @"因iOS系统限制，开启照片服务才能上传，传输过程严格加密，不会作其他用途。\n\n\t\t步骤：设置>定位服务>虹盘";
        }
        UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"提示" message:titleString delegate:nil cancelButtonTitle:@"知道了" otherButtonTitles:nil, nil];
        [alertView show];
        [alertView release];
        });
    }];
}

-(id)init
{
    self = [super init];
    uploadArray = [[NSMutableArray alloc] init];
    return self;
}

-(void)updateLoad
{
    [self updateTable];
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
    
    [uploadArray addObjectsFromArray:[list selectAutoUploadListAllAndNotUpload]];
    [list release];
    [self updateTable];
}

-(void)start
{
    isOpenedUpload = YES;
    if(!isStart)
    {
        isStopCurrUpload = NO;
        [self updateTableStateForWaiting];
    }
    
    if(!isStop)
    {
        [self selectPhotoLibary];
    }
}

//开始上传
-(void)startUpload
{
    [self updateUploadList];
    if([uploadArray count]>0 && isStart)
    {
        NewUpload *newUpload = [[NewUpload alloc] init];
        newUpload.list = [uploadArray objectAtIndex:0];
        newUpload.list.t_state = 0;
        newUpload.list.upload_size = 0;
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
        AutoUploadList *ls = [[AutoUploadList alloc] init];
        ls.a_name = [NSString formatNSStringForOjbect:list.t_name];
        ls.a_state = 1;
        ls.a_user_id = [NSString formatNSStringForOjbect:list.user_id];
        [ls updateAutoUploadList];
        [ls release];
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
        
        AutoUploadList *ls = [[AutoUploadList alloc] init];
        ls.a_name = [NSString formatNSStringForOjbect:list.t_name];
        ls.a_state = 1;
        ls.a_user_id = [NSString formatNSStringForOjbect:list.user_id];
        [ls updateAutoUploadList];
        [ls release];
        
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
        if([uploadArray count]>0)
        {
            UpLoadList *list = [uploadArray objectAtIndex:0];
            [uploadView startAutomaticList:list total:[uploadArray count]];
        }
        else
        {
            uploadView.uploadListTableView.tableHeaderView = nil;
        }
    }
    [appleDate.myTabBarController addUploadNumber:[uploadArray count]+[appleDate.moveUpload.uploadArray count]];
    UIApplication *app = [UIApplication sharedApplication];
    app.applicationIconBadgeNumber = [uploadArray count]+[appleDate.moveUpload.uploadArray count];
}

//修改Ui状态为等待WiFi
-(void)updateTableStateForWaitWiFi
{
    if([uploadArray count]>0)
    {
        UpLoadList *list = [uploadArray objectAtIndex:0];
        list.t_state = 3;
    }
    [self updateTable];
}

//修改Ui状态为等待
-(void)updateTableStateForWaiting
{
    if([uploadArray count]>0)
    {
        UpLoadList *list = [uploadArray objectAtIndex:0];
        list.t_state = 0;
    }
    [self updateTable];
}

//修改Ui状态为暂停
-(void)updateTableStateForStop
{
    if([uploadArray count]>0)
    {
        UpLoadList *list = [uploadArray objectAtIndex:0];
        list.t_state = 2;
    }
    [self updateTable];
}

//销毁所有上传
-(void)stopAllUpload
{
    isStopCurrUpload = YES;
    isStart = NO;
    
    if(uploadArray)
    {
        [uploadArray removeAllObjects];
    }
    
    UpLoadList *uplist = [[UpLoadList alloc] init];
    [uplist deleteAutoUploadListAllAndNotUpload];
    [uplist release];
    
    AutoUploadList *list = [[AutoUploadList alloc] init];
    [list deleteAllAutoUploadList];
    [list release];
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
