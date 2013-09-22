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
#import "UserInfo.h"

@implementation AutomaticUpload
@synthesize assetArray;
@synthesize f_id;
@synthesize deviceName;
@synthesize netWorkState;
@synthesize upload_timer;
@synthesize space_id;
@synthesize isUpload;
@synthesize operationQueue;

-(id)init
{
    self = [super init];
    if(self)
    {
        
    }
    return self;
}

//比对本地数据库
-(void)isHaveData
{
    if(![YNFunctions isAutoUpload])
    {
        return;
    }
    UserInfo *info = [[UserInfo alloc] init];
    info.keyString = @"自动备份目录";
    NSMutableArray *array = [info selectAllUserinfo];
    if([array count] == 0)
    {
        info.f_id = -1;
        info.descript = [NSString stringWithFormat:@"我的文件/手机照片/%@",[AppDelegate deviceString]];
        [info insertUserinfo];
        self.f_id = @"-1";
    }
    else
    {
        UserInfo *info = [array lastObject];
        self.f_id = [NSString stringWithFormat:@"%i",info.f_id];
    }
    isUpload = TRUE;
    NSLog(@"调用读取了。。。。。");
    if(!isLoadingRead)
    {
        NSLog(@"进来了。。。。。");
        isLoadingRead = TRUE;
        isGoOn = FALSE;
        if(![self isConnection])
        {
            isUpload = FALSE;
            AppDelegate *appleDate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
            UINavigationController *NavigationController = [[appleDate.myTabBarController viewControllers] objectAtIndex:2];
            ChangeUploadViewController *uploadViewController = (ChangeUploadViewController *)[NavigationController.viewControllers objectAtIndex:0];
            if(uploadViewController && [self.assetArray count]>0)
            {
                dispatch_async(dispatch_get_main_queue(), ^{
                    upload_file.demo.state = 2;
                    [uploadViewController startAutomatic:upload_file.demo.topImage progess:1 taskDemo:upload_file.demo total:[self.assetArray count]];
                });
            }
            isLoadingRead = FALSE;
            [self selectLibray];
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
                    NSString* assetType = [result valueForProperty:ALAssetPropertyType];
                    if ([assetType isEqualToString:ALAssetTypePhoto]) {
                        if(result)
                        {
                            WebData *webData = [[WebData alloc] init];
                            webData.p_id = self.f_id;
                            webData.photo_name = [[result defaultRepresentation] filename];
                            BOOL bl = [webData selectIsTrueForPhotoName];
                            if(!bl)
                            {
                                [self.assetArray addObject:result];
                            }
                            [webData release];
                        }
                    }
                    total++;
                }];
                if([group numberOfAssets]<=total-1)
                {
                    if(isGoOn)
                    {
                        isLoadingRead = FALSE;
                        NSLog(@"停止读取照片库1111");
                        if([YNFunctions isAutoUpload])
                        {
                            [self isHaveData];
                        }
                        if(self.assetArray)
                        {
                            [self.assetArray removeAllObjects];
                        }
                        return ;
                    }
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
    }
}

//打开上传
-(void)newTheadMain
{
    if(isGoOn)
    {
        isLoadingRead = FALSE;
        NSLog(@"停止读取照片库");
        if(self.assetArray)
        {
            [self.assetArray removeAllObjects];
        }
        return ;
    }
    //网络判断
    if([self isConnection])
    {
        
        //解析上传数据
        if([self.assetArray count]>0)
        {
            if(isGoOn)
            {
                isLoadingRead = FALSE;
                NSLog(@"停止读取照片库");
                if(self.assetArray)
                {
                    [self.assetArray removeAllObjects];
                }
                return ;
            }
            if(upload_timer)
            {
                [upload_timer invalidate];
                upload_timer = nil;
            }
            ALAsset *result = [self.assetArray objectAtIndex:0];
            if(result)
            {
                NSLog(@"[[result defaultRepresentation] filename]:%@",[[result defaultRepresentation] filename]);
                upload_file = [[UploadFile alloc] init];
                [upload_file setDeviceName:self.deviceName];
                [upload_file setSpace_id:space_id];
                [upload_file setF_id:self.f_id];
                [upload_file setF_pid:nil];
                [upload_file setAsset:result];
                [upload_file setDelegate:self];
                
                AppDelegate *appleDate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
                UINavigationController *NavigationController = [[appleDate.myTabBarController viewControllers] objectAtIndex:2];
                ChangeUploadViewController *uploadViewController = (ChangeUploadViewController *)[NavigationController.viewControllers objectAtIndex:0];
                if(uploadViewController && [uploadViewController respondsToSelector:@selector(startAutomatic:progess:taskDemo:total:)])
                {
                    dispatch_async(dispatch_get_main_queue(), ^{
                        [uploadViewController startAutomatic:upload_file.demo.topImage progess:0 taskDemo:upload_file.demo total:[self.assetArray count]];
                    });
                }
                if(isGoOn)
                {
                    isLoadingRead = FALSE;
                    NSLog(@"停止读取照片库");
                    if(self.assetArray)
                    {
                        [self.assetArray removeAllObjects];
                    }
                    return ;
                }
                [upload_file upload];
                isLoadingRead = FALSE;
            }
        }
        else
        {
            NSLog(@"没有数据了");
            AppDelegate *appleDate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
            UINavigationController *NavigationController = [[appleDate.myTabBarController viewControllers] objectAtIndex:2];
            ChangeUploadViewController *uploadViewController = (ChangeUploadViewController *)[NavigationController.viewControllers objectAtIndex:0];
            if(uploadViewController)
            {
                [uploadViewController stopAutomatic];
            }
            if(assetsLibrary)
            {
                [assetsLibrary release];
                assetsLibrary = nil;
            }
            [self selectLibray];
            isLoadingRead = FALSE;
        }
        NSLog(@"网络正常");
    }
    else
    {
        NSLog(@"网络不可用");
        isLoadingRead = FALSE;
        AppDelegate *appleDate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
        UINavigationController *NavigationController = [[appleDate.myTabBarController viewControllers] objectAtIndex:2];
        ChangeUploadViewController *uploadViewController = (ChangeUploadViewController *)[NavigationController.viewControllers objectAtIndex:0];
        if(uploadViewController)
        {
            dispatch_async(dispatch_get_main_queue(), ^{
                upload_file.demo.state = 2;
                [uploadViewController startAutomatic:upload_file.demo.topImage progess:1 taskDemo:upload_file.demo total:[self.assetArray count]];
            });
        }
        [self selectLibray];
    }
}

-(void)selectLibray
{
    if([YNFunctions isAutoUpload])
    {
        dispatch_async(dispatch_get_main_queue(), ^{
            if(upload_timer)
            {
                [upload_timer invalidate];
                upload_timer = nil;
            }
            upload_timer = [NSTimer scheduledTimerWithTimeInterval:15 target:self selector:@selector(isHaveData) userInfo:nil repeats:YES];
        });
    }
}

//开启自动上传
-(void)startAutomaticUpload
{
    dispatch_async(dispatch_get_main_queue(), ^{
        [NSThread detachNewThreadSelector:@selector(newTheadMain) toTarget:self withObject:nil];
    });
}

//关闭自动上传
-(void)colseAutomaticUpload
{
    dispatch_async(dispatch_get_main_queue(), ^{
    isUpload = FALSE;
    isGoOn = YES;
    if([self.assetArray count]>0)
    {
        [upload_file upStop];
    }
    AppDelegate *appleDate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
    UINavigationController *NavigationController = [[appleDate.myTabBarController viewControllers] objectAtIndex:2];
    ChangeUploadViewController *uploadViewController = (ChangeUploadViewController *)[NavigationController.viewControllers objectAtIndex:0];
    if(uploadViewController && [uploadViewController respondsToSelector:@selector(stopAutomatic)])
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
    });
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
    AppDelegate *appleDate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
    UINavigationController *NavigationController = [[appleDate.myTabBarController viewControllers] objectAtIndex:2];
    ChangeUploadViewController *uploadViewController = (ChangeUploadViewController *)[NavigationController.viewControllers objectAtIndex:0];
        
    if(uploadViewController && [uploadViewController respondsToSelector:@selector(startAutomatic:progess:taskDemo:total:)])
    {
        [uploadViewController startAutomatic:upload_file.demo.topImage progess:1 taskDemo:upload_file.demo total:[self.assetArray count]];
    }
    
    if([self.assetArray count]>0)
    {
        [self.assetArray removeObjectAtIndex:0];
    }
    if(upload_file.demo)
    {
        [upload_file.demo release];
    }
    if(upload_file)
    {
        [upload_file release];
    }
    [self startAutomaticUpload];
    });
}

//上传进行时，发送上传进度数据
-(void)upProess:(float)proress fileTag:(NSInteger)fileTag
{
    AppDelegate *appleDate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
    UINavigationController *NavigationController = [[appleDate.myTabBarController viewControllers] objectAtIndex:2];
    ChangeUploadViewController *uploadViewController = (ChangeUploadViewController *)[NavigationController.viewControllers objectAtIndex:0];
    if(uploadViewController && [uploadViewController respondsToSelector:@selector(startAutomatic:progess:taskDemo:total:)])
    {
        dispatch_async(dispatch_get_main_queue(), ^{
            [uploadViewController startAutomatic:upload_file.demo.topImage progess:proress taskDemo:upload_file.demo total:[self.assetArray count]];
        });
    }
}

//上传失败
-(void)upError:(NSInteger)fileTag
{
    NSLog(@"上传失败，过滤掉");
    [self startAutomaticUpload];
}

-(void)cleanStop
{
    AppDelegate *appleDate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
    UINavigationController *NavigationController = [[appleDate.myTabBarController viewControllers] objectAtIndex:2];
    ChangeUploadViewController *uploadViewController = (ChangeUploadViewController *)[NavigationController.viewControllers objectAtIndex:0];
    if(uploadViewController)
    {
        [uploadViewController stopAutomatic];
    }
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
