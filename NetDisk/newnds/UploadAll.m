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

@implementation UploadAll
@synthesize uploadAllList;


#pragma mark ------照片库代理方法
-(void)changeUpload:(NSMutableOrderedSet *)array_
{
    uploadAllList = [[NSMutableArray alloc] init];
        int i=[array_ count];
        for(ALAsset *asset in array_)
        {
            TaskDemo *demo = [[TaskDemo alloc] init];
            demo.f_state = 3;
            demo.f_data = nil;
            demo.f_lenght = 0;
            i-=1;
            demo.index_id = i;
            NSLog(@"i--------------:%i",i);
            demo.proess = 0;
            demo.result = [asset retain];
            demo.f_base_name = [[asset defaultRepresentation] filename];
            //            dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_BACKGROUND, 0), ^{
            //                [demo insertTaskTable];
            //            });
            UploadFile *upload_file = [[UploadFile alloc] init];
            [upload_file setDemo:demo];
            [demo release];
            [upload_file setDeviceName:deviceName];
            [uploadAllList addObject:upload_file];
            [upload_file release];
        }
        if([uploadAllList count]>0)
        {
            UploadFile *upload_file = [uploadAllList objectAtIndex:0];
            upload_file.demo.f_state = 2;
            [upload_file setDelegate:self];
            [upload_file upload];
        }
    NSLog(@"回到上传管理页面");
}

-(void)changeDeviceName:(NSString *)device_name
{
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
    if([uploadAllList count]>0)
    {
        [uploadAllList removeObjectAtIndex:0];
        if([uploadAllList count]>0)
        {
            UploadFile *upload_file = [uploadAllList objectAtIndex:0];
            upload_file.demo.f_state = 2;
            [upload_file setDelegate:self];
            [upload_file upload];
        }
    }
}
//上传进行时，发送上传进度数据
-(void)upProess:(float)proress fileTag:(NSInteger)fileTag
{
    
}
//上传失败
-(void)upError:(NSInteger)fileTag
{
    
}

@end
