//
//  NewUpload.m
//  NetDisk
//
//  Created by Yangsl on 13-9-26.
//
//

#import "NewUpload.h"
#import "YNFunctions.h"
#import "SCBoxConfig.h"
#import "SCBSession.h"
#import <AssetsLibrary/AssetsLibrary.h>
#import <CommonCrypto/CommonDigest.h>
#import "AppDelegate.h"

@implementation NewUpload
@synthesize connection,finishName,photoManger,uploderDemo,list,delegate,urlNameArray,urlIndex,file_data,md5String,netWorkOperation;

-(id)init
{
    self = [super init];
    photoManger = [[SCBPhotoManager alloc] init];
    [photoManger setPhotoDelegate:self];
    [photoManger setNewFoldDelegate:self];
    uploderDemo = [[SCBUploader alloc] init];
    [uploderDemo setUpLoadDelegate:self];
    return self;
}

//开始上传
-(void)startUpload
{
    dispatch_async(dispatch_get_main_queue(), ^{
        [NSThread detachNewThreadSelector:@selector(isNetWork) toTarget:self withObject:nil];
    });
}

//1.判断网络

-(void)isNetWork
{
    AppDelegate *appleDate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
    if(list.is_autoUpload)
    {
        if(appleDate.isAutomicUpload)
        {
            return;
        }
        appleDate.isAutomicUpload = YES;
    }
    if([self isConnection] == ReachableViaWiFi)
    {
        //WiFi 状态
        [self catchurl];
    }
    else if([self isConnection] == ReachableViaWWAN)
    {
        if(![YNFunctions isOnlyWifi])
        {
            [self catchurl];
        }
        else
        {
            [self updateAutoUploadState];
            //等待WiFi
            [delegate upWaitWiFi];
        }
    }
    else
    {
        [self updateAutoUploadState];
        //网络连接断开
        [delegate upNetworkStop];
    }
}

-(void)updateAutoUploadState
{
    AppDelegate *appleDate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
    appleDate.isAutomicUpload = FALSE;
}

-(void)updateNetWork
{
    [self updateAutoUploadState];
    [delegate upError];
}

//2.生成目录
-(void)catchurl
{
    AppDelegate *appleDate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
    if((list.is_autoUpload && appleDate.autoUpload.isStopCurrUpload && !appleDate.autoUpload.isGoOn) || (!list.is_autoUpload && appleDate.moveUpload.isStopCurrUpload))
    {
        [self updateAutoUploadState];
        [self updateNetWork];
        return;
    }
    NSURL *s_url=[NSURL URLWithString:[NSString stringWithFormat:@"%@%@",SERVER_URL,FM_GETFILEINFO]];
    NSMutableURLRequest *request=[NSMutableURLRequest requestWithURL:s_url cachePolicy:NSURLRequestReloadIgnoringLocalCacheData timeoutInterval:CONNECT_TIMEOUT];
    [request setValue:list.user_id forHTTPHeaderField:@"usr_id"];
    [request setValue:CLIENT_TAG forHTTPHeaderField:@"client_tag"];
    [request setValue:[[SCBSession sharedSession] userToken] forHTTPHeaderField:@"usr_token"];
    NSMutableString *body=[[NSMutableString alloc] init];
    [body appendFormat:@"f_id=%@",list.t_url_pid];
    NSLog(@"body:%@",body);
    NSMutableData *myRequestData=[NSMutableData data];
    [myRequestData appendData:[body dataUsingEncoding:NSUTF8StringEncoding]];
    [request setHTTPBody:myRequestData];
    [body release];
    [request setHTTPMethod:@"POST"];
    NSError *error;
    NSData *returnData = [NSURLConnection sendSynchronousRequest:request
                                               returningResponse:nil error:&error];
    if(!returnData || (list.is_autoUpload && appleDate.autoUpload.isStopCurrUpload && !appleDate.autoUpload.isGoOn) || (!list.is_autoUpload && appleDate.moveUpload.isStopCurrUpload))
    {
        [self updateAutoUploadState];
        if(returnData == nil)
        {
            [delegate webServiceFail];
        }
        else
        {
            [self updateNetWork];
        }
        return;
    }
    NSDictionary *dictionary = [NSJSONSerialization JSONObjectWithData:returnData options:NSJSONReadingMutableLeaves error:nil];
    
    NSLog(@"%@",dictionary);
    int index = [[dictionary objectForKey:@"code"] intValue];
    if(index == 0)
    {
        [self newRequestVerify];
    }
    else if(list.is_autoUpload)
    {
        urlNameArray = [list.t_url_name componentsSeparatedByString:@"/"];
        urlIndex = 0;
        [self newRequestIsHaveFileWithID:@"1"];
    }
    else
    {
        [self updateAutoUploadState];
        [delegate upNetworkStop];
    }
}

-(void)newRequestIsHaveFileWithID:(NSString *)fId
{
    AppDelegate *appleDate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
    if((list.is_autoUpload && appleDate.autoUpload.isStopCurrUpload && !appleDate.autoUpload.isGoOn) || (!list.is_autoUpload && appleDate.moveUpload.isStopCurrUpload))
    {
        [self updateAutoUploadState];
        [self updateNetWork];
        return;
    }
    NSURL *s_url=[NSURL URLWithString:[NSString stringWithFormat:@"%@%@",SERVER_URL,FM_URI]];
    NSMutableURLRequest *request=[NSMutableURLRequest requestWithURL:s_url cachePolicy:NSURLRequestReloadIgnoringLocalCacheData timeoutInterval:CONNECT_TIMEOUT];
    NSMutableString *body=[[NSMutableString alloc] init];
    [body appendFormat:@"f_id=%@&cursor=%d&offset=%d&space_id=%@&iszone=%@&sort=%@&sort_direct=%@",fId,0,-1,list.spaceId,@"1",@"f_modify",@"desc"];
    
    NSLog(@"%@",body);
    NSMutableData *myRequestData=[NSMutableData data];
    [myRequestData appendData:[body dataUsingEncoding:NSUTF8StringEncoding]];
    [body release];
    [request setValue:[[SCBSession sharedSession] userId] forHTTPHeaderField:@"usr_id"];
    [request setValue:CLIENT_TAG forHTTPHeaderField:@"client_tag"];
    [request setValue:[[SCBSession sharedSession] userToken] forHTTPHeaderField:@"usr_token"];
    [request setHTTPBody:myRequestData];
    [request setHTTPMethod:@"POST"];
    
    NSError *error;
    NSData *returnData = [NSURLConnection sendSynchronousRequest:request
                                               returningResponse:nil error:&error];
    if(!returnData || (list.is_autoUpload && appleDate.autoUpload.isStopCurrUpload && !appleDate.autoUpload.isGoOn) || (!list.is_autoUpload && appleDate.moveUpload.isStopCurrUpload))
    {
        [self updateAutoUploadState];
        if(returnData == nil)
        {
            [delegate webServiceFail];
        }
        else
        {
            [self updateNetWork];
        }
        return;
    }
    NSDictionary *dictionary = [NSJSONSerialization JSONObjectWithData:returnData options:NSJSONReadingMutableLeaves error:nil];
    NSLog(@"%@",dictionary);
    
    BOOL bl = TRUE;
    NSArray *array = [dictionary objectForKey:@"files"];
    for(NSDictionary *dic in array)
    {
        NSString *name = [dic objectForKey:@"f_name"];
        if(urlIndex<[urlNameArray count])
        {
            if([name isEqualToString:[urlNameArray objectAtIndex:urlIndex]])
            {
                bl = FALSE;
                list.t_url_pid = [dic objectForKey:@"f_id"];
                if(urlIndex+1 >= [urlNameArray count])
                {
                    //请求上传
                    [self newRequestVerify];
                }
                else
                {
                    urlIndex++;
                    [self newRequestIsHaveFileWithID:list.t_url_pid];
                }
                break;
            }
            else if([name isEqualToString:[urlNameArray lastObject]])
            {
                if(urlIndex+1 >= [urlNameArray count])
                {
                    bl = FALSE;
                    //请求上传
                    [self newRequestVerify];
                    break;
                }
            }
        }
        
    }
    if([array count]==0 || bl)
    {
        NSLog(@"创建手机照片目录------------------------------");
        [self newRequestNewFold:[urlNameArray objectAtIndex:urlIndex] FID:fId];
    }
}


-(void)newRequestNewFold:(NSString *)name FID:(NSString *)fId
{
    AppDelegate *appleDate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
    if((list.is_autoUpload && appleDate.autoUpload.isStopCurrUpload && !appleDate.autoUpload.isGoOn) || (!list.is_autoUpload && appleDate.moveUpload.isStopCurrUpload))
    {
        [self updateNetWork];
        return;
    }
    NSURL *s_url=[NSURL URLWithString:[NSString stringWithFormat:@"%@%@",SERVER_URL,FM_MKDIR_URL]];
    NSMutableURLRequest *request=[NSMutableURLRequest requestWithURL:s_url cachePolicy:NSURLRequestReloadIgnoringLocalCacheData timeoutInterval:CONNECT_TIMEOUT];
    [request setValue:[[SCBSession sharedSession] userId] forHTTPHeaderField:@"usr_id"];
    [request setValue:CLIENT_TAG forHTTPHeaderField:@"client_tag"];
    [request setValue:[[SCBSession sharedSession] userToken] forHTTPHeaderField:@"usr_token"];
    NSMutableString *body=[[NSMutableString alloc] init];
    [body appendFormat:@"f_name=%@&f_pid=%@&space_id=%@",name,fId,list.spaceId];
    NSLog(@"body:%@",body);
    NSMutableData *myRequestData=[NSMutableData data];
    [myRequestData appendData:[body dataUsingEncoding:NSUTF8StringEncoding]];
    [request setHTTPBody:myRequestData];
    [body release];
    [request setHTTPMethod:@"POST"];
    NSError *error;
    NSData *returnData = [NSURLConnection sendSynchronousRequest:request
                                               returningResponse:nil error:&error];
    if(!returnData || (list.is_autoUpload && appleDate.autoUpload.isStopCurrUpload && !appleDate.autoUpload.isGoOn) || (!list.is_autoUpload && appleDate.moveUpload.isStopCurrUpload))
    {
        if(returnData == nil)
        {
            [delegate webServiceFail];
        }
        else
        {
            [self updateNetWork];
        }
        return;
    }
    NSDictionary *dictionary = [NSJSONSerialization JSONObjectWithData:returnData options:NSJSONReadingMutableLeaves error:nil];
    NSLog(@"%@",dictionary);
    
    
    NSLog(@"newFold dictionary:%@",dictionary);
    if([[dictionary objectForKey:@"code"] intValue] != 0)
    {
        NSLog(@"文件创建失败");
        [self updateNetWork];
        return;
    }
    
    list.t_url_pid = [dictionary objectForKey:@"f_id"];
    
    BOOL bl = TRUE;
    NSString *f_name = [dictionary objectForKey:@"f_name"];
    if(urlIndex<[urlNameArray count])
    {
        if([f_name isEqualToString:[urlNameArray objectAtIndex:urlIndex]])
        {
            if(urlIndex+1 >= [urlNameArray count])
            {
                bl = FALSE;
                //请求上传
                [self newRequestVerify];
            }
        }
        else if([name isEqualToString:[urlNameArray lastObject]])
        {
            if(urlIndex+1 >= [urlNameArray count])
            {
                bl = FALSE;
                //请求上传
                [self newRequestVerify];
            }
        }
    }
    
    if(bl)
    {
        NSLog(@"创建手机照片目录------------------------------");
        urlIndex++;
        [self newRequestNewFold:[urlNameArray objectAtIndex:urlIndex] FID:list.t_url_pid];
    }
}


-(void)newRequestVerify
{
    AppDelegate *appleDate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
    if((list.is_autoUpload && appleDate.autoUpload.isStopCurrUpload && !appleDate.autoUpload.isGoOn) || (!list.is_autoUpload && appleDate.moveUpload.isStopCurrUpload))
    {
        [self updateAutoUploadState];
        [self updateNetWork];
        return;
    }
    @try {
        ALAssetsLibrary *libary = [[[ALAssetsLibrary alloc] init] autorelease];
        [libary assetForURL:[NSURL URLWithString:list.t_fileUrl] resultBlock:^(ALAsset *result)
        {
            NSError *error = nil;
            Byte *byte_data = malloc(result.defaultRepresentation.size);
            //获得照片图像数据
            [result.defaultRepresentation getBytes:byte_data fromOffset:0 length:result.defaultRepresentation.size error:&error];
            file_data = [[NSData alloc] initWithData:[NSData dataWithBytesNoCopy:byte_data length:result.defaultRepresentation.size]];
            NSLog(@"1:申请效验:%i",[file_data length]);
            
            md5String = [[NSString alloc] initWithString:[self md5:file_data]];
            NSURL *s_url = nil;
            if(list.is_share)
            {
                s_url=[NSURL URLWithString:[NSString stringWithFormat:@"%@%@",SERVER_URL,FM_SHARE_UPLOAD_NEW_VERIFY]];
            }
            else
            {
                s_url=[NSURL URLWithString:[NSString stringWithFormat:@"%@%@",SERVER_URL,FM_UPLOAD_NEW_VERIFY]];
            }
            NSMutableURLRequest *request=[NSMutableURLRequest requestWithURL:s_url cachePolicy:NSURLRequestReloadIgnoringLocalCacheData timeoutInterval:CONNECT_TIMEOUT];
            [request setValue:[[SCBSession sharedSession] userId] forHTTPHeaderField:@"usr_id"];
            [request setValue:CLIENT_TAG forHTTPHeaderField:@"client_tag"];
            [request setValue:[[SCBSession sharedSession] userToken] forHTTPHeaderField:@"usr_token"];
            NSMutableString *body=[[NSMutableString alloc] init];
            [body appendFormat:@"f_pid=%@&f_name=%@&f_size=%@&f_md5=%@&space_id=%@",list.t_url_pid,list.t_name,[NSString stringWithFormat:@"%i",list.t_lenght],md5String,list.spaceId];
            NSLog(@"body:%@",body);
            NSLog(@"userid:%@",[[SCBSession sharedSession] userId]);
            NSMutableData *myRequestData=[NSMutableData data];
            [myRequestData appendData:[body dataUsingEncoding:NSUTF8StringEncoding]];
            [request setHTTPBody:myRequestData];
            [body release];
            [request setHTTPMethod:@"POST"];
            NSData *returnData = [NSURLConnection sendSynchronousRequest:request
                                                       returningResponse:nil error:&error];
            if(!returnData || (list.is_autoUpload && appleDate.autoUpload.isStopCurrUpload && !appleDate.autoUpload.isGoOn) || (!list.is_autoUpload && appleDate.moveUpload.isStopCurrUpload))
            {
                [self updateAutoUploadState];
                [file_data release];
                [md5String release];
                if(returnData == nil)
                {
                    [delegate webServiceFail];
                }
                else
                {
                    [self updateNetWork];
                }
                return;
            }
            NSDictionary *dictionary = [NSJSONSerialization JSONObjectWithData:returnData options:NSJSONReadingMutableLeaves error:nil];
            NSLog(@"%@",dictionary);
            NSString *upload_fid = [dictionary objectForKey:@"f_id"];
            if([upload_fid length]>0)
            {
                [self updateAutoUploadState];
                [delegate upFinish:dictionary];
                [file_data release];
                [md5String release];
                return;
            }
            if([[dictionary objectForKey:@"code"] intValue] == 0 )
            {
                [self newRequestUploadState:list.t_name];
            }
            else if([[dictionary objectForKey:@"code"] intValue] == 5 )
            {
                [self updateAutoUploadState];
                [file_data release];
                [md5String release];
                //重命名
                [delegate upReName];
            }
            else if([[dictionary objectForKey:@"code"] intValue] == 7 )
            {
                [self updateAutoUploadState];
                [file_data release];
                [md5String release];
                //重命名
                [delegate upNotUpload];
            }
            else if([[dictionary objectForKey:@"code"] intValue] == 4 )
            {
                [self updateAutoUploadState];
                [file_data release];
                [md5String release];
                //重命名
                [delegate upUserSpaceLass];
            }
            else
            {
                [self updateAutoUploadState];
                [file_data release];
                [md5String release];
                //失败
                [self updateNetWork];
            }
            
        } failureBlock:^(NSError *error)
        {
            NSLog(@"error:%@",error);
        }];
    }
    @catch (NSException *exception) {
        NSLog(@"exception:%@",exception);
    }
    @finally {
        
    }
}

-(void)newRequestUploadState:(NSString *)s_name
{
    AppDelegate *appleDate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
    if((list.is_autoUpload && appleDate.autoUpload.isStopCurrUpload && !appleDate.autoUpload.isGoOn) || (!list.is_autoUpload && appleDate.moveUpload.isStopCurrUpload))
    {
        [self updateAutoUploadState];
        [file_data release];
        [md5String release];
        [self updateNetWork];
        return;
    }
    NSURL *s_url=[NSURL URLWithString:[NSString stringWithFormat:@"%@%@",SERVER_URL,FM_UPLOAD_STATE]];
    NSMutableURLRequest *request=[NSMutableURLRequest requestWithURL:s_url cachePolicy:NSURLRequestReloadIgnoringLocalCacheData timeoutInterval:CONNECT_TIMEOUT];
    [request setValue:[[SCBSession sharedSession] userId] forHTTPHeaderField:@"usr_id"];
    [request setValue:CLIENT_TAG forHTTPHeaderField:@"client_tag"];
    [request setValue:[[SCBSession sharedSession] userToken] forHTTPHeaderField:@"usr_token"];
    NSMutableString *body=[[NSMutableString alloc] init];
    [body appendFormat:@"s_name=%@",s_name];
    NSLog(@"body:%@",body);
    NSMutableData *myRequestData=[NSMutableData data];
    [myRequestData appendData:[body dataUsingEncoding:NSUTF8StringEncoding]];
    [request setHTTPBody:myRequestData];
    [body release];
    [request setHTTPMethod:@"POST"];
    
    NSError *error;
    NSData *returnData = [NSURLConnection sendSynchronousRequest:request
                                               returningResponse:nil error:&error];
    if(!returnData || (list.is_autoUpload && appleDate.autoUpload.isStopCurrUpload && !appleDate.autoUpload.isGoOn) || (!list.is_autoUpload && appleDate.moveUpload.isStopCurrUpload))
    {
        [self updateAutoUploadState];
        [file_data release];
        [md5String release];
        if(returnData == nil)
        {
            [delegate webServiceFail];
        }
        else
        {
            [self updateNetWork];
        }
        return;
    }
    NSDictionary *dictionary = [NSJSONSerialization JSONObjectWithData:returnData options:NSJSONReadingMutableLeaves error:nil];
    NSLog(@"%@",dictionary);
    dispatch_async(dispatch_get_main_queue(), ^{
        if([[dictionary objectForKey:@"code"] intValue] == 0)
        {
            finishName = [dictionary objectForKey:@"sname"];
            
            NSLog(@"3:开始上传：%@",finishName);
            NSLog(@"文件大小：%i",[file_data length]);
            connection = [uploderDemo requestUploadFile:finishName skip:[NSString stringWithFormat:@"%i",list.t_lenght] Image:file_data];
        }
        else
        {
            [self updateAutoUploadState];
            [file_data release];
            [md5String release];
            [self updateNetWork];
        }
    });
}


-(void)comeBackNewTheadMian:(NSDictionary *)dictionary
{
    AppDelegate *appleDate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
    if((list.is_autoUpload && appleDate.autoUpload.isStopCurrUpload && !appleDate.autoUpload.isGoOn) || (!list.is_autoUpload && appleDate.moveUpload.isStopCurrUpload))
    {
        [self updateAutoUploadState];
        [file_data release];
        [md5String release];
        [self updateNetWork];
        return;
    }
    if([[dictionary objectForKey:@"code"] intValue] == 0)
    {
        NSLog(@"4:提交上传表单:%@",finishName);
        [self newRequestUploadCommit:list.t_url_pid f_name:list.t_name s_name:finishName skip:[NSString stringWithFormat:@"%i",list.t_lenght] space_id:list.spaceId];
    }
    else
    {
        [self updateAutoUploadState];
        NSLog(@"上传失败");
        [file_data release];
        [md5String release];
        [self updateNetWork];
    }
}


#pragma mark 新的上传 提交上传表单
-(void)newRequestUploadCommit:(NSString *)fPid f_name:(NSString *)f_name s_name:(NSString *)s_name skip:(NSString *)skip space_id:(NSString *)spaceId
{
    AppDelegate *appleDate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
    if((list.is_autoUpload && appleDate.autoUpload.isStopCurrUpload && !appleDate.autoUpload.isGoOn) || (!list.is_autoUpload && appleDate.moveUpload.isStopCurrUpload))
    {
        [self updateAutoUploadState];
        [file_data release];
        [md5String release];
        [self updateNetWork];
        return;
    }
    NSURL *s_url=[NSURL URLWithString:[NSString stringWithFormat:@"%@%@",SERVER_URL,FM_UPLOAD_NEW_COMMIT]];
    
    NSData *returnData;
    NSError *error;
    @try {
        NSMutableURLRequest *request=[NSMutableURLRequest requestWithURL:s_url cachePolicy:NSURLRequestReloadIgnoringLocalCacheData timeoutInterval:CONNECT_TIMEOUT];
        NSLog(@"request1:%@",request);
        [request setValue:[[SCBSession sharedSession] userId] forHTTPHeaderField:@"usr_id"];
        [request setValue:CLIENT_TAG forHTTPHeaderField:@"client_tag"];
        [request setValue:[[SCBSession sharedSession] userToken] forHTTPHeaderField:@"usr_token"];
        NSMutableString *body=[[[NSMutableString alloc] init] autorelease];
        [body appendString:[NSString stringWithFormat:@"f_pid=%@",fPid]];
        [body appendString:[NSString stringWithFormat:@"&f_name=%@",f_name]];
        [body appendString:[NSString stringWithFormat:@"&s_name=%@",s_name]];
        [body appendString:@"&img_device="];
        [body appendString:[NSString stringWithFormat:@"&f_md5=%@",md5String]];
        [body appendString:@"&img_size="];
        [body appendString:@"&img_createtime="];
        [body appendFormat:@"&space_id=%@",spaceId];
        NSLog(@"body:%@",body);
        NSMutableData *myRequestData=[NSMutableData data];
        [myRequestData appendData:[body dataUsingEncoding:NSUTF8StringEncoding]];
        [request setHTTPBody:myRequestData];
        [request setHTTPMethod:@"POST"];
        returnData = [NSURLConnection sendSynchronousRequest:request
                                           returningResponse:nil error:&error];
        if(returnData == nil || (list.is_autoUpload && appleDate.autoUpload.isStopCurrUpload && !appleDate.autoUpload.isGoOn) || (!list.is_autoUpload && appleDate.moveUpload.isStopCurrUpload))
        {
            [self updateAutoUploadState];
            [file_data release];
            [md5String release];
            if(returnData == nil)
            {
                [delegate webServiceFail];
            }
            else
            {
                [self updateNetWork];
            }
            return;
        }
    }
    @catch (NSException *exception) {
        NSLog(@"exception:%@",exception);
    }
    @finally {
        NSLog(@"准备上传提交");
    }
    
    NSDictionary *dictionary = [NSJSONSerialization JSONObjectWithData:returnData options:NSJSONReadingMutableLeaves error:nil];
    NSLog(@"%@",dictionary);
    
    NSLog(@"5:完成");
    [self updateAutoUploadState];
    if([[dictionary objectForKey:@"code"] intValue] == 0)
    {
        [file_data release];
        [md5String release];
        [delegate upFinish:dictionary];
    }
    else
    {
        [file_data release];
        [md5String release];
        [self updateNetWork];
    }
}

#pragma mark SCBPhotoDelegate

-(void)getPhotoTiimeLine:(NSDictionary *)dictionary{}

-(void)getPhotoGeneral:(NSDictionary *)dictionary photoDictioin:(NSMutableDictionary *)photoDic{}

-(void)getPhotoDetail:(NSDictionary *)dictionary{}

-(void)requstDelete:(NSDictionary *)dictionary{}

-(void)getFileDetail:(NSDictionary *)dictionary{}


-(void)getPhotoArrayTimeline:(NSDictionary *)dictionary{}

-(void)getPhotoDetailTimeImage:(NSDictionary *)dictionary{}


#pragma mark NewFoldDelegate 

-(void)newFold:(NSDictionary *)dictionary{}

-(void)openFile:(NSDictionary *)dictionary{}


#pragma mark UpLoadDelegate

//上传效验
-(void)uploadVerify:(NSDictionary *)dictionary{}

//上传文件完成
-(void)uploadFinish:(NSDictionary *)dictionary
{
    AppDelegate *appleDate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
    if((list.is_autoUpload && appleDate.autoUpload.isStopCurrUpload && !appleDate.autoUpload.isGoOn) || (!list.is_autoUpload && appleDate.moveUpload.isStopCurrUpload))
    {
        [self updateAutoUploadState];
        [file_data release];
        [md5String release];
        [self updateNetWork];
        return;
    }
    dispatch_async(dispatch_get_main_queue(), ^{
        [self uploadFiles:list.t_lenght];
        connection = nil;
        [NSThread detachNewThreadSelector:@selector(comeBackNewTheadMian:) toTarget:self withObject:dictionary];
    });
}

//申请上传状态
-(void)requestUploadState:(NSDictionary *)dictionary{}

//查看上传记录
-(void)lookDescript:(NSDictionary *)dictionary{}

//上传文件流
-(void)uploadFiles:(int)proress
{
    AppDelegate *appleDate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
    if((list.is_autoUpload && appleDate.autoUpload.isStopCurrUpload && !appleDate.autoUpload.isGoOn) || (!list.is_autoUpload && appleDate.moveUpload.isStopCurrUpload))
    {
        [connection cancel];
        connection = nil;
        [self updateNetWork];
        return;
    }
    [delegate upProess:proress fileTag:0];
}

//上传提交
-(void)uploadCommit:(NSDictionary *)dictionary{}

#pragma mark 公用代理方法

//上传失败
-(void)didFailWithError
{
    [self updateAutoUploadState];
    [self updateNetWork];
}


#pragma mark MKNetworkKit

//上传
-(void)newRequestUploadFile:(NSString *)s_name skip:(NSString *)skip Image:(NSData *)image
{
    NSString *url = [NSString stringWithFormat:@"%@%@",SERVER_URL,FM_UPLOAD_NEW];
    NSMutableDictionary *dictionary = [[[NSMutableDictionary alloc] init] autorelease];
    [dictionary setValue:[[SCBSession sharedSession] userId] forKey:@"usr_id"];
    [dictionary setValue:CLIENT_TAG forKey:@"client_tag"];
    [dictionary setValue:[[SCBSession sharedSession] userToken] forKey:@"usr_token"];
    [dictionary setValue:s_name forKey:@"s_name"];
    [dictionary setValue:[NSString stringWithFormat:@"bytes=0-%@",skip] forKey:@"Range"];
    
    netWorkOperation = [[MKNetworkOperation alloc] initWithURLString:url params:dictionary httpMethod:@"PUT"];
    [netWorkOperation onUploadProgressChanged:^(double proess){
        NSLog(@"proess:%f",proess);
    }];
    
    [netWorkOperation addData:image forKey:[[list.t_name componentsSeparatedByString:@"."] lastObject]];
    [netWorkOperation onCompletion:^(MKNetworkOperation *respnose){
        NSLog(@"respnose:%@",respnose);
        [self uploadFinish:nil];
    } onError:^(NSError *error){
        NSLog(@"error:%@",error);
    }];
    [netWorkOperation main];
}

#pragma mark 常用方法

//判断当前的网络是3g还是wifi
-(NetworkStatus) isConnection
{
    Reachability *hostReach = [Reachability reachabilityWithHostName:@"www.baidu.com"];
    return [hostReach currentReachabilityStatus];
}

-(NSString *)md5:(NSData *)concat {
    CC_MD5_CTX md5_ctx;
    CC_MD5_Init(&md5_ctx);
    
    NSData* filedata = concat;
    CC_MD5_Update(&md5_ctx, [filedata bytes], [filedata length]);
    unsigned char result[CC_MD5_DIGEST_LENGTH];
    CC_MD5_Final(result, &md5_ctx);
    NSMutableString *hash = [NSMutableString string];
    for(int i=0;i<CC_MD5_DIGEST_LENGTH;i++)
    {
        [hash appendFormat:@"%02x",result[i]];
    }
    return [hash lowercaseString];
}

@end
