//
//  AutomaticUpload.m
//  NetDisk
//
//  Created by Yangsl on 13-8-7.
//
//

#import "AutomaticUpload.h"
#import "ALAsset+AGIPC.h"
#import "Reachability.h"
#import "WebData.h"
#import "TaskDemo.h"
#import "AppDelegate.h"
#import "SCBSession.h"
#import "UploadFile.h"
#import "ChangeUploadViewController.h"
#import "YNFunctions.h"
#import "MyndsViewController.h"

@implementation AutomaticUpload
@synthesize assetArray;
@synthesize f_id;
@synthesize deviceName;
@synthesize netWorkState;
@synthesize upload_timer;
@synthesize space_id;

//比对本地数据库
-(void)isHaveData
{
    isGoOn = FALSE;
    dispatch_async(dispatch_get_main_queue(), ^{
    if(![self isConnection])
    {
        [self getUploadCotroller];
        if(uploadViewController)
        {
            dispatch_async(dispatch_get_main_queue(), ^{
                upload_file.demo.state = 2;
                [uploadViewController startAutomatic:upload_file.demo.topImage progess:1 taskDemo:upload_file.demo total:[self.assetArray count]];
            });
        }
        return;
    }
    if(!space_id)
    {
        space_id = [[SCBSession sharedSession] spaceID];
    }
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
    else
    {
        [self.assetArray removeAllObjects];
    }
    [assetsLibrary enumerateGroupsWithTypes:ALAssetsGroupSavedPhotos usingBlock:^(ALAssetsGroup *group, BOOL *stop) {//获取所有groups
        __block int total = 0;
        if([group numberOfAssets]>0)
        {
            [group enumerateAssetsUsingBlock:^(ALAsset *result, NSUInteger index, BOOL *stop) {
                if(result)
                {
                    WebData *webData = [[WebData alloc] init];
                    webData.p_id = f_id;
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
    });
}

//打开上传
-(void)newTheadMain
{
    //网络判断
    if([self isConnection])
    {
        //获取上传界面
        [self getUploadCotroller];
        
        //解析上传数据
        if([self.assetArray count]>0)
        {
            if(upload_timer)
            {
                [upload_timer invalidate];
                upload_timer = nil;
            }
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
                demo.p_id = f_id;
                demo.is_automic_upload = 1;
                demo.topImage = [UIImage imageWithCGImage:[[result defaultRepresentation] fullScreenImage]];
                NSError *error = nil;
                Byte *data = malloc(result.defaultRepresentation.size);
                //获得照片图像数据
                [result.defaultRepresentation getBytes:data fromOffset:0 length:result.defaultRepresentation.size error:&error];
                demo.f_data = [NSData dataWithBytesNoCopy:data length:result.defaultRepresentation.size];
                
                NSLog(@"视频有多大:%i",[demo.f_data length]);
                
                NSLog(@"demo.spcae_id:%@",demo.space_id);
                
                upload_file = [[UploadFile alloc] init];
                [upload_file setDemo:demo];
                [upload_file setDeviceName:self.deviceName];
                [upload_file setSpace_id:space_id];
                [upload_file setF_id:self.f_id];
                [upload_file setF_pid:nil];
                [upload_file setDelegate:self];
                
                if(uploadViewController && [uploadViewController isKindOfClass:[ChangeUploadViewController class]])
                {
                    dispatch_async(dispatch_get_main_queue(), ^{
                        [uploadViewController startAutomatic:demo.topImage progess:0 taskDemo:demo total:[self.assetArray count]];
                    });
                }
                
                [upload_file upload];
                
                [demo release];
                [upload_file release];
            }
        }
        else
        {
            NSLog(@"没有数据了");
            if(uploadViewController)
            {
                [uploadViewController stopAutomatic];
            }
            if(assetsLibrary)
            {
                [assetsLibrary release];
                assetsLibrary = nil;
            }
            if([YNFunctions isAutoUpload])
            {
                dispatch_async(dispatch_get_main_queue(), ^{
                    if(upload_timer)
                    {
                        [upload_timer invalidate];
                    }
                    upload_timer = [NSTimer scheduledTimerWithTimeInterval:15 target:self selector:@selector(isHaveData) userInfo:nil repeats:YES];
                });
            }
        }
        NSLog(@"网络正常");
    }
    else
    {
        NSLog(@"网络不可用");
    }
}

//开启自动上传
-(void)startAutomaticUpload
{
    [NSThread detachNewThreadSelector:@selector(newTheadMain) toTarget:self withObject:nil];
    return;
    
    if(isGoOn)
    {
        return;
    }
    isGoOn = FALSE;
    NSLog(@"开始下载-----------------------");
    if([self isConnection])
    {
        [self getUploadCotroller];
        if([self.assetArray count]>0)
        {
            if(upload_timer)
            {
                [upload_timer invalidate];
                upload_timer = nil;
            }
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
                demo.p_id = f_id;
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
                [upload_file setF_id:self.f_id];
                [upload_file setF_pid:nil];
                [upload_file setDelegate:self];
                [upload_file upload];
                if(uploadViewController && [uploadViewController isKindOfClass:[ChangeUploadViewController class]])
                {
                    dispatch_async(dispatch_get_main_queue(), ^{
                        [uploadViewController startAutomatic:[UIImage imageWithData:upload_file.demo.f_data] progess:0 taskDemo:upload_file.demo total:[self.assetArray count]];
                    });
                }
                [demo release];
                [upload_file release];
            }
        }
        else
        {
            NSLog(@"没有数据了");
            if(uploadViewController)
            {
                [uploadViewController stopAutomatic];
            }
            if(assetsLibrary)
            {
                [assetsLibrary release];
                assetsLibrary = nil;
            }
            if([YNFunctions isAutoUpload])
            {
                dispatch_async(dispatch_get_main_queue(), ^{
                    if(upload_timer)
                    {
                        [upload_timer invalidate];
                    }
                    upload_timer = [NSTimer scheduledTimerWithTimeInterval:15 target:self selector:@selector(isHaveData) userInfo:nil repeats:YES];
                });
            }
        }
    }
    else if([YNFunctions isAutoUpload])
    {
        [self getUploadCotroller];
        dispatch_async(dispatch_get_main_queue(), ^{
            if(uploadViewController && [uploadViewController isKindOfClass:[ChangeUploadViewController class]])
            {
                upload_file.demo.state = 2;
//                UIImage *data_image = [UIImage imageWithData:upload_file.demo.f_data];
//                UIImage *state_image = [self scaleFromImage:data_image toSize:CGSizeMake(data_image.size.width/4, data_image.size.height/4)];
//                NSData *newData = UIImageJPEGRepresentation(state_image, 1.0);
                [uploadViewController startAutomatic:upload_file.demo.topImage progess:1 taskDemo:upload_file.demo total:[self.assetArray count]];
                
            }
            if(upload_timer)
            {
                [upload_timer invalidate];
            }
            upload_timer = [NSTimer scheduledTimerWithTimeInterval:15 target:self selector:@selector(isHaveData) userInfo:nil repeats:YES];
        });
    }
}

//关闭自动上传
-(void)colseAutomaticUpload
{
    dispatch_async(dispatch_get_main_queue(), ^{
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
    if(upload_timer)
    {
        [upload_timer invalidate];
        upload_timer = nil;
    }
    if(assetArray)
    {
        [assetArray removeAllObjects];
    }
    isGoOn = YES;
    });
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
    NSLog(@"继续下载-----------------------");
    dispatch_async(dispatch_get_main_queue(), ^{
    if(isGoOn)
    {
        return;
    }
    [self getUploadCotroller];
    if(uploadViewController && [uploadViewController isKindOfClass:[ChangeUploadViewController class]])
    {
//        UIImage *data_image = [UIImage imageWithData:upload_file.demo.f_data];
//        UIImage *state_image = [self scaleFromImage:data_image toSize:CGSizeMake(data_image.size.width/4, data_image.size.height/4)];
//        NSData *newData = UIImageJPEGRepresentation(state_image, 1.0);
        [uploadViewController startAutomatic:upload_file.demo.topImage progess:1 taskDemo:upload_file.demo total:[self.assetArray count]];
    }
    
    if([self.assetArray count]>0)
    {
        [self.assetArray removeObjectAtIndex:0];
    }
    [NSTimer scheduledTimerWithTimeInterval:0.5 target:self selector:@selector(startAutomaticUpload) userInfo:nil repeats:NO];
    });
}

//上传进行时，发送上传进度数据
-(void)upProess:(float)proress fileTag:(NSInteger)fileTag
{
    [self getUploadCotroller];
    if(uploadViewController && [uploadViewController isKindOfClass:[ChangeUploadViewController class]])
    {
        dispatch_async(dispatch_get_main_queue(), ^{
            [uploadViewController startAutomatic:upload_file.demo.topImage progess:proress taskDemo:upload_file.demo total:[self.assetArray count]];
        });
    }
}

//上传失败
-(void)upError:(NSInteger)fileTag
{
    
}

//判断当前的网络是3g还是wifi
-(BOOL) isConnection
{
    __block BOOL bl;
//    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 0), ^{
        Reachability *hostReach = [Reachability reachabilityWithHostName:@"www.baidu.com"];
        switch ([hostReach currentReachabilityStatus]) {
            case NotReachable:
            {
                netWorkState = 3;
                //"没有网络链接"
                bl = NO;
            }
                break;
            case ReachableViaWiFi:
            {
                // "WIFI";
                netWorkState = 1;
                bl = YES;
            }
                break;
            case ReachableViaWWAN:
            {
                // @"WLAN";
                netWorkState = 2;
                if([YNFunctions isOnlyWifi])
                {
                    bl = NO;
                }
                else
                {
                    bl = YES;
                }
            }
                break;
            default:
                break;
        }
//    });
    return bl;
}

-(UIImage *)scaleFromImage:(UIImage *)image toSize:(CGSize)size
{
    UIGraphicsBeginImageContext(size);
    [image drawInRect:CGRectMake(0, 0, size.width, size.height)];
    UIImage *newImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return newImage;
}

@end
