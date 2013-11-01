//
//  DownManager.m
//  ndspro
//
//  Created by Yangsl on 13-10-11.
//  Copyright (c) 2013年 fengyongning. All rights reserved.
//

#import "DownManager.h"
#import "SCBSession.h"
#import "AppDelegate.h"
#import "MyTabBarViewController.h"
#import "UpDownloadViewController.h"
#import "MyTabBarViewController.h"

@implementation DownManager
@synthesize downingArray,isOpenedDown,isStart,isStopCurrDown,file,isAutoStart;

-(id)init
{
    self = [super init];
    [self selectDownList];
    return self;
}

//查询出所有数据
-(void)selectDownList
{
    DownList *list = [[DownList alloc] init];
    list.d_ure_id = [NSString formatNSStringForOjbect:[[SCBSession sharedSession] userId]];
    downingArray = [[NSMutableArray alloc] initWithArray:[list selectDowningAll]];
}

-(void)updateLoad
{
    [self updateDownList];
    AppDelegate *appleDate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
    UINavigationController *NavigationController = [[appleDate.myTabBarVC viewControllers] objectAtIndex:1];
    UpDownloadViewController *uploadView = (UpDownloadViewController *)[NavigationController.viewControllers objectAtIndex:0];
    if([uploadView isKindOfClass:[UpDownloadViewController class]])
    {
        if([uploadView.downLoading_array count] == 0)
        {
            [uploadView setDownLoading_array:downingArray];
        }
    }
    if(!isStart)
    {
        for (int i=0; i<[downingArray count]; i++) {
            DownList *list = [downingArray objectAtIndex:i];
            list.d_state = 2;
            list.curr_size = 0;
        }
    }
}

//将需要下载的文件添加到数据库中
-(void)addDownList:(NSString *)d_name thumbName:(NSString *)thumbName d_fileId:(NSString *)d_file_id d_downSize:(NSInteger)d_downSize
{
    DownList *list = [[DownList alloc] init];
    list.d_name = [NSString formatNSStringForOjbect:d_name];
    list.d_thumbUrl = [NSString formatNSStringForOjbect:thumbName];
    list.d_state = 0;
    list.d_baseUrl = @"";
    list.d_file_id = [NSString formatNSStringForOjbect:d_file_id];
    list.d_downSize = d_downSize;
    NSDate *todayDate = [NSDate date];
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateStyle:NSDateFormatterMediumStyle];
    [dateFormatter setTimeStyle:NSDateFormatterShortStyle];
    [dateFormatter setDateFormat:@"yyyy-MM-dd HH:mm:ss"];
    list.d_datetime = [dateFormatter stringFromDate:todayDate];
    list.d_ure_id = [NSString formatNSStringForOjbect:[[SCBSession sharedSession] userId]];
    
    [list insertDownList];
    [self start];
}

//更新数据
-(void)updateDownList
{
    DownList *list = [[DownList alloc] init];
    list.d_ure_id = [NSString formatNSStringForOjbect:[[SCBSession sharedSession] userId]];
    list.d_id = 0;
    if([downingArray count]>0)
    {
        DownList *endList = [downingArray lastObject];
        if(endList)
        {
            list.d_id = endList.d_id;
        }
    }
    [downingArray addObjectsFromArray:[list selectDowningAll]];
}

-(void)start
{
    isOpenedDown = YES;
    isAutoStart = YES;
    if(!isStart)
    {
        isStart = YES;
        [self updateTableStateForWaiting];
        [self startDown];
    }
    if(!isStart)
    {
        [self upNetworkStop];
    }
}

-(BOOL)IsHaveAutoStart
{
    if(isAutoStart && [downingArray count]>0)
    {
        return YES;
    }
    return NO;
}

//开启下载任务
-(void)startDown
{
    [self updateDownList];
    [self updateTable];
    if([downingArray count]>0 && isStart)
    {
        DownList *list = [downingArray objectAtIndex:0];
        DDLogInfo(@"下载的文件大小:%i",list.d_downSize);
        //开始下载
        self.file = [[DwonFile alloc] init];
        self.file.fileSize = list.d_downSize;
        self.file.file_id = list.d_file_id;
        self.file.fileName = list.d_name;
        self.file.delegate = self;
        if(list.d_state == 0 || list.is_Onece)
        {
            list.d_state = 0;
            [self.file startDownload];
        }
    }
    if([downingArray count]==0)
    {
        isStart = FALSE;
    }
}

#pragma 下载代理方法-----------

- (void)appImageDidLoad:(NSInteger)indexTag urlImage:(UIImage *)image index:(NSIndexPath *)indexPath
{
    
}
- (void)downFinish:(NSString *)baseUrl
{
    //下载完成后保存数据库
    if([downingArray count]>0)
    {
        DownList *list = [downingArray objectAtIndex:0];
        list.d_baseUrl = [NSString formatNSStringForOjbect:baseUrl];
        list.d_state = 1;
        NSDate *todayDate = [NSDate date];
        NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
        [dateFormatter setDateStyle:NSDateFormatterMediumStyle];
        [dateFormatter setTimeStyle:NSDateFormatterShortStyle];
        [dateFormatter setDateFormat:@"yyyy-MM-dd HH:mm:ss"];
        list.d_datetime = [dateFormatter stringFromDate:todayDate];
        [list updateDownListForUserId];
        [downingArray removeObjectAtIndex:0];
    }
    [self startDown];
}
-(void)downFile:(NSInteger)downSize totalSize:(NSInteger)sudu
{
    //计算出下载的进度和速度，显示到UI
    if([downingArray count]>0)
    {
        DownList *down = (DownList *)[downingArray objectAtIndex:0];
        down.curr_size = downSize;
    }
    [self updateTable];
}

-(void)didFailWithError
{
    //UI提示下载失败
    //并且继续下载下一条
    [self startDown];
}

//上传失败
-(void)upError
{
    if([downingArray count]>0 && isOpenedDown)
    {
        DownList *list = [downingArray objectAtIndex:0];
        list.d_state = 5;
        list.is_Onece = NO;
        [list deleteDownList];
        [list insertDownList];
        [downingArray removeObjectAtIndex:0];
        [self updateTable];
    }
    [self startDown];
}
//服务器异常
-(void)webServiceFail
{
    
}
//上传无权限
-(void)upNotUpload
{
    
}
//用户存储空间不足
-(void)upUserSpaceLass
{
    
}
//等待WiFi
-(void)upWaitWiFi
{
    isStart = FALSE;
    [self updateTableStateForWaitWiFi];
}
//网络失败
-(void)upNetworkStop
{
    isStart = FALSE;
    [self updateTableStateForStop];
}


#pragma mark 更新ui ----

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
        app.applicationIconBadgeNumber = [self.downingArray count]+[appleDate.uploadmanage.uploadArray count];
        [appleDate.myTabBarVC addUploadNumber:app.applicationIconBadgeNumber];
    });
}

//修改Ui状态为等待WiFi
-(void)updateTableStateForWaitWiFi
{
    for (int i=0; i<[downingArray count]; i++) {
        DownList *list = [downingArray objectAtIndex:i];
        if(list.d_state == 5)
        {
            list.is_Onece = YES;
        }
        else
        {
            list.d_state = 3;
        }
        list.curr_size = 0;
    }
    [self updateTable];
}

//修改Ui状态为等待
-(void)updateTableStateForWaiting
{
    for (int i=0; i<[downingArray count]; i++) {
        DownList *list = [downingArray objectAtIndex:i];
        if(list.d_state == 5)
        {
            list.is_Onece = YES;
        }
        else
        {
            list.d_state = 0;
        }
        list.curr_size = 0;
    }
    [self updateTable];
}

//修改Ui状态为暂停
-(void)updateTableStateForStop
{
    for (int i=0; i<[downingArray count]; i++) {
        DownList *list = [downingArray objectAtIndex:i];
        if(list.d_state == 5)
        {
            list.is_Onece = YES;
        }
        else
        {
            list.d_state = 2;
        }
        list.curr_size = 0;
    }
    [self updateTable];
}


//暂时所有下载
-(void)stopAllDown
{
    isAutoStart = NO;
    if(self.file)
    {
        [self.file cancelDownload];
    }
    isOpenedDown = FALSE;
    isStart = FALSE;
    [self updateTableStateForStop];
}
//删除一条上传
-(void)deleteOneDown:(NSInteger)selectIndex
{
    if([downingArray count]>selectIndex)
    {
        if(selectIndex==0 && self.file)
        {
            [self.file cancelDownload];
        }
        DownList *list = [downingArray objectAtIndex:selectIndex];
        [list deleteDownList];
        [downingArray removeObjectAtIndex:selectIndex];
    }
    [self startDown];
}

//删除所有上传
-(void)deleteAllDown
{
    
}

@end
