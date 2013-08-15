//
//  UploadAll.m
//  NetDisk
//
//  Created by Yangsl on 13-7-31.
//
//

#import "UploadAll.h"

#import "TaskDemo.h"
#import "AppDelegate.h"
#import "ChangeUploadViewController.h"

@implementation UploadAll
@synthesize uploadAllList;
@synthesize isUpload;
@synthesize space_id;
@synthesize f_id;

-(id)init
{
    self = [super init];
    if(self)
    {
        TaskDemo *demo = [[TaskDemo alloc] init];
        self.uploadAllList = [demo selectAllTaskTable];
        [demo release];
    }
    return self;
}

-(void)changeUpload:(NSMutableOrderedSet *)array_
{
    NSLog(@"有多少:%@",self.space_id);
    NSLog(@"有多少:%@",space_id);
    int i=0;
    if([self.uploadAllList count]==0)
    {
        isUpload = FALSE;
    }
    else
    {
        i = self.uploadAllList.count-1;
    }
    if(!self.uploadAllList)
    {
        self.uploadAllList = [[NSMutableArray alloc] init];
    }
    BOOL bl = TRUE;
    for(ALAsset *asset in array_)
    {
        TaskDemo *demo = [[TaskDemo alloc] init];
        demo.f_state = 0;
        demo.f_data = nil;
        demo.f_lenght = 0;
        demo.index_id = i;
        demo.state = 0;
        demo.proess = 0;
        demo.result = [asset retain];
        demo.f_base_name = [[asset defaultRepresentation] filename];
        demo.deviceName = deviceName;
        demo.space_id = self.space_id;
        demo.p_id = [NSString stringWithFormat:@"%@",self.f_id];
        
        NSLog(@"demo.f_id:%@",demo.p_id);
        NSLog(@"demo.spcae_id:%@",demo.space_id);
        
        ALAsset *result = demo.result;
        NSError *error = nil;
        Byte *data = malloc(result.defaultRepresentation.size);
        //获得照片图像数据
        [result.defaultRepresentation getBytes:data fromOffset:0 length:result.defaultRepresentation.size error:&error];
        demo.f_data = [NSData dataWithBytesNoCopy:data length:result.defaultRepresentation.size];
        [demo insertTaskTable];
        
        UploadFile *upload_file = [[UploadFile alloc] init];
        [upload_file setDemo:demo];
        [upload_file setDeviceName:deviceName];
        [upload_file setSpace_id:self.space_id];
        [upload_file setF_id:self.f_id];
        [self.uploadAllList addObject:upload_file];
        [demo release];
        [upload_file release];
        i++;
        if(bl)
        {
            [self startUpload];
            bl = FALSE;
        }
    }
    NSLog(@"回到上传管理页面");
}

-(void)startUpload
{
    if([self.uploadAllList count]>0 && !isUpload)
    {
        UploadFile *upload_file = [self.uploadAllList objectAtIndex:0];
        upload_file.demo.state = 1;
        [upload_file setDelegate:self];
        [upload_file upload];
        isUpload = TRUE;
        AppDelegate *appleDate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
        UINavigationController *NavigationController = [[appleDate.myTabBarController viewControllers] objectAtIndex:2];
        ChangeUploadViewController *uploadView = (ChangeUploadViewController *)[NavigationController.viewControllers objectAtIndex:0];
        if([uploadView isKindOfClass:[ChangeUploadViewController class]])
        {
            if([uploadView.uploadingList count]==0)
            {
                [uploadView setUploadingList:self.uploadAllList];
                if(!uploadView.isUploadAll)
                {
                    [uploadView setIsUploadAll:YES];
                }
            }
        }
    }
}

-(void)changeDeviceName:(NSString *)device_name
{
    if([self.uploadAllList count]==0)
    {
        isUpload = FALSE;
    }
    deviceName = [[NSString alloc] initWithString:device_name];
    NSLog(@"deviceName:%@",deviceName);
}

-(void)changeFileId:(NSString *)f_id_
{
    f_id = f_id_;
}

//上传成功
-(void)upFinish:(NSInteger)fileTag
{
    if([self.uploadAllList count]>0)
    {
        AppDelegate *appleDate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
        UINavigationController *NavigationController = [[appleDate.myTabBarController viewControllers] objectAtIndex:2];
        ChangeUploadViewController *uploadView = (ChangeUploadViewController *)[NavigationController.viewControllers objectAtIndex:0];
        if([uploadView isKindOfClass:[ChangeUploadViewController class]])
        {
            [uploadView deleteUploadingIndexRow:0 isDeleteRecory:NO];
            if(!uploadView.isUploadAll)
            {
                [uploadView setIsUploadAll:YES];
            }
        }
        else
        {
            [self.uploadAllList removeObjectAtIndex:0];
            [self startUpload];
        }
    }
}

//上传进行时，发送上传进度数据
-(void)upProess:(float)proress fileTag:(NSInteger)fileTag
{
    AppDelegate *appleDate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
    UINavigationController *NavigationController = [[appleDate.myTabBarController viewControllers] objectAtIndex:2];
    ChangeUploadViewController *uploadView = (ChangeUploadViewController *)[NavigationController.viewControllers objectAtIndex:0];
    if([uploadView isKindOfClass:[ChangeUploadViewController class]])
    {
        if([uploadView.uploadingList count]==0 || !uploadView.uploadingList)
        {
            [uploadView setUploadingList:self.uploadAllList];
            [uploadView.uploadListTableView reloadData];
        }
        if(!uploadView.isUploadAll)
        {
            [uploadView setIsUploadAll:YES];
        }
        [uploadView upProess:proress fileTag:fileTag];
    }
}

//上传失败
-(void)upError:(NSInteger)fileTag
{
    
}

@end
