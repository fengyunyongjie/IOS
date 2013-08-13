//
//  AutomaticUpload.m
//  NetDisk
//
//  Created by Yangsl on 13-8-7.
//
//

#import "AutomaticUpload.h"
#import "ALAsset+AGIPC.h"
#import "WebData.h"
#import "TaskDemo.h"
#import "AppDelegate.h"
#import "SCBSession.h"
#import "UploadFile.h"
#import "ChangeUploadViewController.h"

@implementation AutomaticUpload
@synthesize assetArray;
@synthesize f_id;
@synthesize deviceName;

//比对本地数据库
-(void)isHaveData
{
    space_id = [[SCBSession sharedSession] spaceID];
    self.deviceName = [NSString stringWithFormat:@"来自于-%@",[AppDelegate deviceString]];
    NSLog(@"deviceName:%@",self.deviceName);
    if(assetsLibrary == nil)
    {
        assetsLibrary = [[ALAssetsLibrary alloc] init];
    }
    if(self.assetArray == nil)
    {
        self.assetArray = [[NSMutableOrderedSet alloc] init];
    }
    [assetsLibrary enumerateGroupsWithTypes:ALAssetsGroupSavedPhotos usingBlock:^(ALAssetsGroup *group, BOOL *stop) {//获取所有groups
        __block int total = 0;
        dispatch_async(dispatch_get_main_queue(), ^{
        if([group numberOfAssets]>0)
        {
            [group enumerateAssetsUsingBlock:^(ALAsset *result, NSUInteger index, BOOL *stop) {
                if(result)
                {
                    WebData *webData = [[WebData alloc] init];
                    webData.photo_name = [[result defaultRepresentation] filename];
                    BOOL bl = [webData selectIsTrueForPhotoName];
                    if(!bl)
                    {
                        [self.assetArray addObject:result];
                    }
                }
                total++;
            }];
            if([group numberOfAssets]<=total-1)
            {
                [self startAutomaticUpload];
            }
        }
        });
    } failureBlock:^(NSError *error) {
        NSLog(@"[[UIDevice currentDevice] systemVersion]:%@",[[UIDevice currentDevice] systemVersion]);
        
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
    }];
}

//开启自动上传
-(void)startAutomaticUpload
{
    [self getUploadCotroller];
    if([self.assetArray count]>0)
    {
        dispatch_async(dispatch_get_main_queue(), ^{
            ALAsset *result = [self.assetArray objectAtIndex:0];
            if(result)
            {
                NSLog(@"[[result defaultRepresentation] filename]:%@",[[result defaultRepresentation] filename]);
                TaskDemo *demo = [[TaskDemo alloc] init];
                demo.f_state = 0;
                demo.f_lenght = 0;
                demo.index_id = 0;
                demo.state = 1;
                demo.proess = 0;
                demo.f_base_name = [[result defaultRepresentation] filename];
                demo.deviceName = self.deviceName;
                demo.space_id = space_id;
                demo.p_id = @"A";
                demo.is_automic_upload = 1;
                    
                NSError *error = nil;
                Byte *data = malloc(result.defaultRepresentation.size);
                //获得照片图像数据
                [result.defaultRepresentation getBytes:data fromOffset:0 length:result.defaultRepresentation.size error:&error];
                demo.f_data = [NSData dataWithBytesNoCopy:data length:result.defaultRepresentation.size];
                
                NSLog(@"demo.spcae_id:%@",demo.space_id);
                
                upload_file = [[UploadFile alloc] init];
                [upload_file setDemo:demo];
                [upload_file setDeviceName:self.deviceName];
                [upload_file setSpace_id:space_id];
                [upload_file setF_id:@"A"];
                [upload_file setF_pid:nil];
                [upload_file setDelegate:self];
                [upload_file upload];
                if(uploadViewController)
                {
                    [uploadViewController startAutomatic:[UIImage imageWithData:upload_file.demo.f_data] progess:0 taskDemo:upload_file.demo total:[self.assetArray count]];
                }
                [demo release];
                [upload_file release];
            }
        });
    }
    else
    {
        if(uploadViewController)
        {
            [uploadViewController stopAutomatic];
        }
        if(assetsLibrary)
        {
            [assetsLibrary release];
            assetsLibrary = nil;
        }
    }
}

//关闭自动上传
-(void)colseAutomaticUpload
{
    [self getUploadCotroller];
    if([self.assetArray count]>0)
    {
        [upload_file upStop];
    }
    if(uploadViewController)
    {
        [uploadViewController stopAutomatic];
    }
    if(assetsLibrary)
    {
        [assetsLibrary release];
        assetsLibrary = nil;
    }
}

-(void)getUploadCotroller
{
    if(uploadViewController == nil)
    {
        AppDelegate *appleDate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
        UINavigationController *NavigationController = [[appleDate.myTabBarController viewControllers] objectAtIndex:2];
        ChangeUploadViewController *uploadView = (ChangeUploadViewController *)[NavigationController.viewControllers objectAtIndex:0];
        if([uploadView isKindOfClass:[ChangeUploadViewController class]])
        {
            uploadViewController = uploadView;
        }
    }
}


//上传成功
-(void)upFinish:(NSInteger)fileTag
{
    [self getUploadCotroller];
    if([self.assetArray count]>0)
    {
        [self.assetArray removeObjectAtIndex:0];
    }
    [self startAutomaticUpload];
}

//上传进行时，发送上传进度数据
-(void)upProess:(float)proress fileTag:(NSInteger)fileTag
{
    [self getUploadCotroller];
    if(uploadViewController)
    {
        dispatch_async(dispatch_get_main_queue(), ^{
        [uploadViewController startAutomatic:[UIImage imageWithData:upload_file.demo.f_data] progess:proress taskDemo:upload_file.demo total:[self.assetArray count]];
        });
    }
}

//上传失败
-(void)upError:(NSInteger)fileTag
{
    
}

@end
