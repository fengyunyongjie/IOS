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
@synthesize uploadAllDelegate;
@synthesize isUpload;

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

#pragma mark ------照片库代理方法
-(void)changeUpload:(NSMutableOrderedSet *)array_
{
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
//        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 0), ^{
            ALAsset *result = demo.result;
            NSError *error = nil;
            Byte *data = malloc(result.defaultRepresentation.size);
            //获得照片图像数据
            [result.defaultRepresentation getBytes:data fromOffset:0 length:result.defaultRepresentation.size error:&error];
            demo.f_data = [NSData dataWithBytesNoCopy:data length:result.defaultRepresentation.size];
            [demo insertTaskTable];
//        });
        UploadFile *upload_file = [[UploadFile alloc] init];
        [upload_file setDemo:demo];
        [upload_file setDeviceName:deviceName];
        [self.uploadAllList addObject:upload_file];
        [demo release];
        [upload_file release];
        i++;
        if(i==1)
        {
            [self startUpload];
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
            [uploadView setUploadingList:self.uploadAllList];
            [uploadView.uploadListTableView reloadData];
        }
    }
}

-(void)changeDeviceName:(NSString *)device_name
{
    if([self.uploadAllList count]==0)
    {
        isUpload = FALSE;
    }
    NSRange deviceRange = [device_name rangeOfString:@"来自于-"];
    if(deviceRange.length>0)
    {
        deviceName = [[NSString alloc] initWithString:device_name];
    }
    else
    {
        if([device_name isEqualToString:@"(null)"] || [device_name length]==0)
        {
            device_name = [AppDelegate deviceString];
        }
        deviceName = [[NSString alloc] initWithFormat:@"来自于-%@",device_name];
    }
    NSLog(@"deviceName:%@",deviceName);
}

//上传成功
-(void)upFinish:(NSInteger)fileTag
{
    
    if([self.uploadAllList count]>0)
    {
        [self.uploadAllDelegate upFinish:fileTag];
        [self.uploadAllList removeObjectAtIndex:0];
        if([self.uploadAllList count]>0)
        {
            UploadFile *upload_file = [self.uploadAllList objectAtIndex:0];
            upload_file.demo.state = 1;
            [upload_file setDelegate:self];
            [upload_file upload];
        }
    }
    AppDelegate *appleDate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
    UINavigationController *NavigationController = [[appleDate.myTabBarController viewControllers] objectAtIndex:2];
    ChangeUploadViewController *uploadView = (ChangeUploadViewController *)[NavigationController.viewControllers objectAtIndex:0];
    if([uploadView isKindOfClass:[ChangeUploadViewController class]])
    {
        [uploadView setUploadingList:self.uploadAllList];
        [uploadView.uploadListTableView reloadData];
    }
}
//上传进行时，发送上传进度数据
-(void)upProess:(float)proress fileTag:(NSInteger)fileTag
{
    [self.uploadAllDelegate upProess:proress fileTag:fileTag];
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
        [uploadView upProess:proress fileTag:0];
    }
}

//上传失败
-(void)upError:(NSInteger)fileTag
{
    
}

@end
