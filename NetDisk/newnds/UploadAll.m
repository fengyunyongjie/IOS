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
#import "MyndsViewController.h"

@implementation UploadAll
@synthesize uploadAllList;
@synthesize isUpload;
@synthesize space_id;
@synthesize f_id;
@synthesize asetArray;

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

-(void)changeSpaceId:(NSString *)s_id
{
    space_id = s_id;
}

-(void)changeUpload:(NSMutableOrderedSet *)array_
{
    NSLog(@"有多少:%@",self.space_id);
    NSLog(@"有多少:%@",space_id);
    if(self.asetArray == nil)
    {
        self.asetArray = array_;
    }
    else
    {
        for(ALAsset *result in array_)
        {
            [self.asetArray addObject:result];
        }
    }
    int i=0;
    if([self.uploadAllList count]==0)
    {
        isUpload = FALSE;
    }
//    else
//    {
//        i = self.uploadAllList.count-1;
//    }
    if(!self.uploadAllList)
    {
        self.uploadAllList = [[NSMutableArray alloc] init];
    }
    else
    {
        [self.uploadAllList removeAllObjects];
    }
    
    BOOL bl = TRUE;
    
    if([self.asetArray count]<10)
    {
        for(int j=0;j<[self.asetArray count];j++)
        {
            ALAsset *asset = [self.asetArray objectAtIndex:j];
//            TaskDemo *demo = [[TaskDemo alloc] init];
//            demo.f_state = 0;
//            demo.f_data = nil;
//            demo.f_lenght = 0;
//            demo.index_id = i;
//            demo.state = 0;
//            demo.proess = 0;
//            demo.result = [asset retain];
//            demo.f_base_name = [[asset defaultRepresentation] filename];
//            demo.deviceName = deviceName;
//            demo.space_id = self.space_id;
//            demo.p_id = [NSString stringWithFormat:@"%@",self.f_id];
//            demo.topImage = [UIImage imageWithCGImage:[[asset defaultRepresentation] fullScreenImage]];
//            
//            NSLog(@"demo.f_id:%@",demo.p_id);
//            NSLog(@"demo.spcae_id:%@",demo.space_id);
//            
//            ALAsset *result = demo.result;
//            NSError *error = nil;
//            Byte *data = malloc(result.defaultRepresentation.size);
//            //获得照片图像数据
//            [result.defaultRepresentation getBytes:data fromOffset:0 length:result.defaultRepresentation.size error:&error];
//            demo.f_data = [NSData dataWithBytesNoCopy:data length:result.defaultRepresentation.size];
//            [demo insertTaskTable];
            
            UploadFile *upload_file = [[UploadFile alloc] init];
            [upload_file setAsset:asset];
            [upload_file setDeviceName:deviceName];
            [upload_file setSpace_id:self.space_id];
            [upload_file setF_id:self.f_id];
            [self.uploadAllList addObject:upload_file];
            [upload_file release];
            i++;
            if(bl)
            {
                [self startUpload];
                bl = FALSE;
            }
        }
    }
    else
    {
        for(int j=0;j<10;j++)
        {
            ALAsset *asset = [self.asetArray objectAtIndex:j];
            UploadFile *upload_file = [[UploadFile alloc] init];
            [upload_file setAsset:asset];
            [upload_file setDeviceName:deviceName];
            [upload_file setSpace_id:self.space_id];
            [upload_file setF_id:self.f_id];
            [self.uploadAllList addObject:upload_file];
            [upload_file release];
            i++;
            if(bl)
            {
                [self startUpload];
                bl = FALSE;
            }
        }
    }
    
    NSLog(@"回到上传管理页面");
}

-(void)startUpload
{
    dispatch_async(dispatch_get_main_queue(), ^{
        if([self.uploadAllList count]<10 && [self.uploadAllList count]<[self.asetArray count])
        {
            ALAsset *asset = [self.asetArray objectAtIndex:[self.uploadAllList count]];
            UploadFile *upload_file = [[UploadFile alloc] init];
            [upload_file setAsset:asset];
            [upload_file setDeviceName:deviceName];
            [upload_file setSpace_id:self.space_id];
            [upload_file setF_id:self.f_id];
            [self.uploadAllList addObject:upload_file];
            [upload_file release];
        }
        [NSThread detachNewThreadSelector:@selector(newTheadMainUpload) toTarget:self withObject:nil];
    });
}

-(void)newTheadMainUpload
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
            if(!uploadView.isUploadAll)
            {
                [uploadView setIsUploadAll:YES];
            }
            [uploadView updateReloadData];
            [uploadView.uploadListTableView reloadData];
        }
    }
}

-(void)changeDeviceName:(NSString *)device_name
{
    if(device_name == nil)
    {
        device_name = @"手机照片";
    }
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
    dispatch_async(dispatch_get_main_queue(), ^{
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
            [self.asetArray removeObjectAtIndex:0];
            [self startUpload];
        }
    }
    });
}

//上传进行时，发送上传进度数据
-(void)upProess:(float)proress fileTag:(NSInteger)fileTag
{
    dispatch_async(dispatch_get_main_queue(), ^{
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
    });
}

//上传失败
-(void)upError:(NSInteger)fileTag
{
    NSLog(@"上传失败，过滤");
    [self upFinish:fileTag];
}

@end
