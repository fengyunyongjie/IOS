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

@implementation AutomaticUpload
@synthesize uploadAllDelegate;
@synthesize assetArray;

//比对本地数据库
-(NSMutableArray *)isHaveData
{
    space_id = [[SCBSession sharedSession] spaceID];
    deviceName = [AppDelegate deviceString];
    if(self.assetArray==nil)
    {
        self.assetArray = [[NSMutableArray alloc] init];
    }
//    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 0), ^{
        ALAssetsLibrary *assetsLibrary = [[ALAssetsLibrary alloc]init];//生成整个photolibrary句柄的实例
        //    NSMutableArray *mediaArray = [[NSMutableArray alloc]init];//存放media的数组
        __block BOOL first = TRUE;
        __block int groupIndex = 0;
        int i=0;
        [assetsLibrary enumerateGroupsWithTypes:ALAssetsGroupSavedPhotos usingBlock:^(ALAssetsGroup *group, BOOL *stop) {//获取所有group
            if(first)
            {
                [group enumerateAssetsUsingBlock:^(ALAsset *result, NSUInteger index, BOOL *stop) {
                    if (result) {
                        //对比本地数据库
                        WebData *web = [[WebData alloc] init];
                        web.photo_name = [[result defaultRepresentation] filename];
                        BOOL bl = [web selectIsTrueForPhotoName];
                        [web release];
                        if(!bl)
                        {
                            
                            TaskDemo *demo = [[TaskDemo alloc] init];
                            demo.f_state = 0;
                            demo.f_data = nil;
                            demo.f_lenght = 0;
                            demo.index_id = i;
                            demo.state = 0;
                            demo.proess = 0;
                            demo.result = [result retain];
                            demo.f_base_name = [[result defaultRepresentation] filename];
                            demo.deviceName = deviceName;
                            demo.space_id = space_id;
                            NSLog(@"demo.spcae_id:%@",demo.space_id);
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
                            [upload_file setSpace_id:space_id];
                            [self.assetArray addObject:upload_file];
                            [demo release];
                            [upload_file release];
                        }
                    }
                }];
                first = FALSE;
                groupIndex++;
            }
        } failureBlock:^(NSError *error) {
//            dispatch_sync(dispatch_get_main_queue(), ^{
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
//            });
        }];
//    });
    return self.assetArray;
}

//开启自动上传
-(void)startAutomaticUpload
{
    if([self.assetArray count]>0)
    {
        UploadFile *upload_file = [self.assetArray objectAtIndex:0];
        upload_file.demo.state = 1;
        [upload_file setDelegate:self];
        [upload_file upload];
    }
}

//关闭自动上传
-(void)colseAutomaticUpload
{
    if([self.assetArray count]>0)
    {
        UploadFile *upload_file = [self.assetArray objectAtIndex:0];
        [upload_file upStop];
    }
}


//上传成功
-(void)upFinish:(NSInteger)fileTag
{
    if([self.assetArray count]>0)
    {
        [self.assetArray removeObjectAtIndex:0];
        [self.uploadAllDelegate upFinish:0];
        [self startAutomaticUpload];
    }
}

//上传进行时，发送上传进度数据
-(void)upProess:(float)proress fileTag:(NSInteger)fileTag
{
    [self.uploadAllDelegate upProess:proress fileTag:fileTag];
}

//上传失败
-(void)upError:(NSInteger)fileTag
{
    
}

@end
