//
//  UploadManager.m
//  ndspro
//
//  Created by Yangsl on 13-10-11.
//  Copyright (c) 2013年 fengyongning. All rights reserved.
//

#import "UploadManager.h"
#import <AssetsLibrary/AssetsLibrary.h>
#import "UpLoadList.h"
#import "NSString+Format.h"
#import "SCBSession.h"
#import "AppDelegate.h"
#import "UpDownloadViewController.h"
#import "MyTabBarViewController.h"

@implementation UploadManager
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
}

-(void)updateLoad
{
    UpLoadList *list = [[UpLoadList alloc] init];
    if([uploadArray count] == 0)
    {
        list.t_id = 0;
    }
    else
    {
        UpLoadList *ls = [uploadArray lastObject];
        if(ls!=nil)
        {
            list.t_id =  ls.t_id;
        }
    }
    list.user_id = [NSString formatNSStringForOjbect:[[SCBSession sharedSession] userId]];
    [uploadArray addObjectsFromArray:[list selectMoveUploadListAllAndNotUpload]];
    AppDelegate *appleDate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
    UINavigationController *NavigationController = [[appleDate.myTabBarVC viewControllers] objectAtIndex:1];
    UpDownloadViewController *uploadView = (UpDownloadViewController *)[NavigationController.viewControllers objectAtIndex:0];
    if([uploadView isKindOfClass:[UpDownloadViewController class]])
    {
        if([uploadView.upLoading_array count] == 0)
        {
            [uploadView setUpLoading_array:uploadArray];
        }
    }
    if(!isStart)
    {
        isStopCurrUpload = YES;
        isStart = FALSE;
        for (int i=0; i<[uploadArray count]; i++) {
            UpLoadList *list = [uploadArray objectAtIndex:i];
            list.t_state = 2;
        }
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
    [self updateTable];
    [self start];
}

-(void)start
{
    isOpenedUpload = YES;
    if(!isStart)
    {
        [self updateTableStateForWaiting];
        isStart = YES;
        [self startUpload];
    }
}

//开始上传
-(void)startUpload
{
    if([uploadArray count]>0 && isStart)
    {
        isStopCurrUpload = NO;
        UploadFile *newUpload = [[UploadFile alloc] init];
        newUpload.list = [uploadArray objectAtIndex:0];
        [newUpload setDelegate:self];
        [newUpload startUpload];
    }
    if([uploadArray count]==0)
    {
        isStart = FALSE;
    }
    if(!isStart)
    {
        [self upNetworkStop];
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
        NSDate *todayDate = [NSDate date];
        NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
        [dateFormatter setDateStyle:NSDateFormatterMediumStyle];
        [dateFormatter setTimeStyle:NSDateFormatterShortStyle];
        [dateFormatter setDateFormat:@"yyyy-MM-dd HH:mm:ss"];
        list.t_date = [dateFormatter stringFromDate:todayDate];
        [list updateUploadList];
        [uploadArray removeObjectAtIndex:0];
        [self updateTable];
    }
    [self startUpload];
}

//上传进行时，发送上传进度数据
-(void)upProess:(float)proress fileTag:(NSInteger)sudu
{
    if([uploadArray count]>0)
    {
        UpLoadList *list = [uploadArray objectAtIndex:0];
        if(sudu<0)
        {
            sudu = 0-sudu;
        }
        list.sudu = (int)sudu;
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
        UINavigationController *NavigationController = [[appleDate.myTabBarVC viewControllers] objectAtIndex:1];
        UpDownloadViewController *uploadView = (UpDownloadViewController *)[NavigationController.viewControllers objectAtIndex:0];
        if([uploadView isKindOfClass:[UpDownloadViewController class]])
        {
            [uploadView showSpaceNot];
        }
    });
    [self stopAllUpload];
}

-(void)upNotUpload
{
    //调用ui
    dispatch_async(dispatch_get_main_queue(), ^{
        AppDelegate *appleDate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
        UINavigationController *NavigationController = [[appleDate.myTabBarVC viewControllers] objectAtIndex:1];
        UpDownloadViewController *uploadView = (UpDownloadViewController *)[NavigationController.viewControllers objectAtIndex:0];
        if([uploadView isKindOfClass:[UpDownloadViewController class]])
        {
            [uploadView showFloderNot];
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
    if([uploadArray count]>0 && isOpenedUpload)
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
        NSDate *todayDate = [NSDate date];
        NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
        [dateFormatter setDateStyle:NSDateFormatterMediumStyle];
        [dateFormatter setTimeStyle:NSDateFormatterShortStyle];
        [dateFormatter setDateFormat:@"yyyy-MM-dd HH:mm:ss"];
        list.t_date = [dateFormatter stringFromDate:todayDate];
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
    [self updateTableStateForStop];
}

//更新ui
-(void)updateTable
{
    dispatch_async(dispatch_get_main_queue(), ^{
        AppDelegate *appleDate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
        UINavigationController *NavigationController = [[appleDate.myTabBarVC viewControllers] objectAtIndex:1];
        UpDownloadViewController *uploadView = (UpDownloadViewController *)[NavigationController.viewControllers objectAtIndex:0];
        if([uploadView isKindOfClass:[UpDownloadViewController class]])
        {
            //更新UI
            [uploadView isSelectedLeft:uploadView.isShowUpload];
        }
        UIApplication *app = [UIApplication sharedApplication];
        app.applicationIconBadgeNumber = [self.uploadArray count]+[appleDate.downmange.downingArray count];
        [appleDate.myTabBarVC addUploadNumber:app.applicationIconBadgeNumber];
    });
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
    [self updateTableStateForStop];
}

//删除一条上传
-(void)deleteOneUpload:(NSInteger)selectIndex
{
    if(selectIndex<[uploadArray count])
    {
        if(selectIndex==0 && isStart)
        {
            isStopCurrUpload = YES;
        }
        else if(selectIndex<[uploadArray count])
        {
            UpLoadList *list = [uploadArray objectAtIndex:selectIndex];
            [list deleteUploadList];
            [uploadArray removeObjectAtIndex:selectIndex];
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
