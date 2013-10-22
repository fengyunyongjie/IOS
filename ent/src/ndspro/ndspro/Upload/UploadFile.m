//
//  UploadFile.m
//  ndspro
//
//  Created by Yangsl on 13-10-11.
//  Copyright (c) 2013年 fengyongning. All rights reserved.
//

#import "UploadFile.h"
#import "YNFunctions.h"
#import "SCBoxConfig.h"
#import "SCBSession.h"
#import <AssetsLibrary/AssetsLibrary.h>
#import <CommonCrypto/CommonDigest.h>
#import "AppDelegate.h"
#import "Reachability.h"

@implementation UploadFile
@synthesize connection,finishName,list,delegate,urlNameArray,urlIndex,file_data,md5String,uploderDemo;

-(id)init
{
    self = [super init];
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
    if(appleDate.isStopUpload)
    {
        return;
    }
    appleDate.isStopUpload = YES;
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
    appleDate.isStopUpload = FALSE;
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
    if(appleDate.uploadmanage.isStopCurrUpload)
    {
        [self updateAutoUploadState];
        [delegate upNetworkStop];
        return;
    }
    NSURL *s_url=[NSURL URLWithString:[NSString stringWithFormat:@"%@%@",SERVER_URL,FM_INFO]];
    NSMutableURLRequest *request=[NSMutableURLRequest requestWithURL:s_url cachePolicy:NSURLRequestReloadIgnoringLocalCacheData timeoutInterval:CONNECT_TIMEOUT];
    NSMutableString *body=[[NSMutableString alloc] init];
    [body appendFormat:@"fid=%@",list.t_url_pid];
    NSLog(@"body:%@",body);
    NSMutableData *myRequestData=[NSMutableData data];
    [myRequestData appendData:[body dataUsingEncoding:NSUTF8StringEncoding]];
    [request setHTTPBody:myRequestData];
    
    [request setHTTPMethod:@"POST"];
    NSError *error;
    NSData *returnData = [NSURLConnection sendSynchronousRequest:request
                                               returningResponse:nil error:&error];
    if(!returnData || appleDate.uploadmanage.isStopCurrUpload)
    {
        [self updateAutoUploadState];
        if(returnData == nil)
        {
            [delegate webServiceFail];
        }
        else
        {
            [delegate upNetworkStop];
        }
        return;
    }
    NSDictionary *dictionary = [NSJSONSerialization JSONObjectWithData:returnData options:NSJSONReadingMutableLeaves error:nil];
    
    NSLog(@"%@",dictionary);
    if([list.t_url_pid isEqualToString:[NSString formatNSStringForOjbect:[dictionary objectForKey:@"fid"]]])
    {
        [self newRequestVerify];
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
    if(appleDate.uploadmanage.isStopCurrUpload)
    {
        [self updateAutoUploadState];
        [delegate upNetworkStop];
        return;
    }
    NSURL *s_url=[NSURL URLWithString:[NSString stringWithFormat:@"%@%@",SERVER_URL,FM_URI]];
    DDLogCInfo(@"%@",s_url);
    NSMutableURLRequest *request=[NSMutableURLRequest requestWithURL:s_url cachePolicy:NSURLRequestReloadIgnoringLocalCacheData timeoutInterval:CONNECT_TIMEOUT];
    NSMutableString *body=[[NSMutableString alloc] init];
    NSString *desc=[YNFunctions getDesc];
    [body appendFormat:@"fpid=%@&cursor=%d&offset=%d&spid=%@&order=%@&desc=%@",fId,0,0,list.spaceId,desc,@"desc"];
    DDLogCInfo(@"%@",body);
    NSMutableData *myRequestData=[NSMutableData data];
    [myRequestData appendData:[body dataUsingEncoding:NSUTF8StringEncoding]];
    [request setHTTPBody:myRequestData];
    [request setHTTPMethod:@"POST"];
    [request setValue:[[SCBSession sharedSession] userId] forHTTPHeaderField:@"ent_uid"];
    [request setValue:CLIENT_TAG forHTTPHeaderField:@"ent_uclient"];
    [request setValue:[[SCBSession sharedSession] userToken] forHTTPHeaderField:@"ent_utoken"];
    [request setValue:[[SCBSession sharedSession] ent_utype] forHTTPHeaderField:@"ent_utype"];
    NSError *error;
    NSData *returnData = [NSURLConnection sendSynchronousRequest:request
                                               returningResponse:nil error:&error];
    if(appleDate.uploadmanage.isStopCurrUpload)
    {
        [self updateAutoUploadState];
        if(returnData == nil)
        {
            [delegate webServiceFail];
        }
        else
        {
            [delegate upNetworkStop];
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
    if(appleDate.uploadmanage.isStopCurrUpload)
    {
        [self updateAutoUploadState];
        [delegate upNetworkStop];
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
    
    [request setHTTPMethod:@"POST"];
    NSError *error;
    NSData *returnData = [NSURLConnection sendSynchronousRequest:request
                                               returningResponse:nil error:&error];
    if(!returnData || appleDate.uploadmanage.isStopCurrUpload)
    {
        [self updateAutoUploadState];
        if(returnData == nil)
        {
            [delegate webServiceFail];
        }
        else
        {
            [delegate upNetworkStop];
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
    if(appleDate.uploadmanage.isStopCurrUpload)
    {
        [self updateAutoUploadState];
        [delegate upNetworkStop];
        return;
    }
    NSURL *s_url=[NSURL URLWithString:[NSString stringWithFormat:@"%@%@",SERVER_URL,FM_UPLOAD_NEW_VERIFY]];
    NSMutableURLRequest *request=[NSMutableURLRequest requestWithURL:s_url cachePolicy:NSURLRequestReloadIgnoringLocalCacheData timeoutInterval:CONNECT_TIMEOUT];
    NSMutableString *body=[[NSMutableString alloc] init];
    [body appendFormat:@"f_pid=%@&f_name=%@&f_size=%@&space_id=%@",list.t_url_pid,list.t_name,[NSString stringWithFormat:@"%i",list.t_lenght],list.spaceId];
    NSLog(@"body:%@",body);
    NSLog(@"userid:%@",[[SCBSession sharedSession] userId]);
    NSMutableData *myRequestData=[NSMutableData data];
    [myRequestData appendData:[body dataUsingEncoding:NSUTF8StringEncoding]];
    [request setHTTPBody:myRequestData];
    [request setValue:[[SCBSession sharedSession] userId] forHTTPHeaderField:@"ent_uid"];
    [request setValue:CLIENT_TAG forHTTPHeaderField:@"ent_uclient"];
    [request setValue:[[SCBSession sharedSession] userToken] forHTTPHeaderField:@"ent_utoken"];
    [request setValue:[[SCBSession sharedSession] ent_utype] forHTTPHeaderField:@"ent_utype"];
    [request setHTTPMethod:@"POST"];
    
    NSError *error = nil;
    NSData *returnData = [NSURLConnection sendSynchronousRequest:request
                                               returningResponse:nil error:&error];
             if(!returnData || appleDate.uploadmanage.isStopCurrUpload)
             {
                 [self updateAutoUploadState];
                 if(returnData == nil)
                 {
                     [delegate webServiceFail];
                 }
                 else
                 {
                     [delegate upNetworkStop];
                 }
                 return;
             }
    NSDictionary *dictionary = [NSJSONSerialization JSONObjectWithData:returnData options:NSJSONReadingMutableLeaves error:nil];
    NSLog(@"%@",dictionary);
    
    if([[dictionary objectForKey:@"code"] intValue] == 0 )
    {
        finishName = [dictionary objectForKey:@"s_name"];
        NSLog(@"3:开始上传：%@",list.t_fileUrl);
        
        
        ALAssetsLibrary *libary = [[ALAssetsLibrary alloc] init];
        [libary assetForURL:[NSURL URLWithString:list.t_fileUrl] resultBlock:^(ALAsset *result)
         {
             NSError *error = nil;
             Byte *byte_data = malloc((unsigned)result.defaultRepresentation.size);
             //获得照片图像数据
             [result.defaultRepresentation getBytes:byte_data fromOffset:0 length:(unsigned)result.defaultRepresentation.size error:&error];
             file_data = [[NSData alloc] initWithData:[NSData dataWithBytesNoCopy:byte_data length:(unsigned)result.defaultRepresentation.size]];
             NSLog(@"文件大小：%i",[file_data length]);
             dispatch_async(dispatch_get_main_queue(), ^{
                 connection = [uploderDemo requestUploadFile:finishName skip:[NSString stringWithFormat:@"%i",list.upload_size] Image:file_data];
             });
             
         } failureBlock:^(NSError *error)
         {
             NSLog(@"error:%@",error);
         }];
    }
    else if([[dictionary objectForKey:@"code"] intValue] == 5 )
    {
        [self updateAutoUploadState];
        //重命名
        [delegate upReName];
    }
    else if([[dictionary objectForKey:@"code"] intValue] == 7 )
    {
        [self updateAutoUploadState];
        //重命名
        [delegate upNotUpload];
    }
    else if([[dictionary objectForKey:@"code"] intValue] == 4 )
    {
        [self updateAutoUploadState];
        //重命名
        [delegate upUserSpaceLass];
    }
    else
    {
        [self updateAutoUploadState];
        //失败
        [self updateNetWork];
    }
}

-(void)newRequestUploadState:(NSString *)s_name
{
    AppDelegate *appleDate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
    if(appleDate.uploadmanage.isStopCurrUpload)
    {
        [self updateAutoUploadState];
        [delegate upNetworkStop];
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
    
    [request setHTTPMethod:@"POST"];
    
    NSError *error;
    NSData *returnData = [NSURLConnection sendSynchronousRequest:request
                                               returningResponse:nil error:&error];
    if(!returnData || appleDate.uploadmanage.isStopCurrUpload)
    {
        [self updateAutoUploadState];
        if(returnData == nil)
        {
            [delegate webServiceFail];
        }
        else
        {
            [delegate upNetworkStop];
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
            
            ALAssetsLibrary *libary = [[ALAssetsLibrary alloc] init];
            [libary assetForURL:[NSURL URLWithString:list.t_fileUrl] resultBlock:^(ALAsset *result)
             {
                 NSError *error = nil;
                 Byte *byte_data = malloc((long)result.defaultRepresentation.size);
                 //获得照片图像数据
                 [result.defaultRepresentation getBytes:byte_data fromOffset:0 length:(long)result.defaultRepresentation.size error:&error];
                 file_data = [[NSData alloc] initWithData:[NSData dataWithBytesNoCopy:byte_data length:(long)result.defaultRepresentation.size]];
                 DDLogCInfo(@"1:申请效验:%i",[file_data length]);
                 connection = [uploderDemo requestUploadFile:finishName skip:[NSString stringWithFormat:@"%i",list.upload_size] Image:[NSData dataWithBytesNoCopy:byte_data length:(long)result.defaultRepresentation.size]];
             } failureBlock:^(NSError *error)
             {
                 NSLog(@"error:%@",error);
             }];
        }
        else
        {
            [self updateAutoUploadState];
            [self updateNetWork];
        }
    });
}


-(void)comeBackNewTheadMian:(NSDictionary *)dictionary
{
    AppDelegate *appleDate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
    if(appleDate.uploadmanage.isStopCurrUpload)
    {
        [self updateAutoUploadState];
        [delegate upNetworkStop];
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
        [self updateNetWork];
    }
}


#pragma mark 新的上传 提交上传表单
-(void)newRequestUploadCommit:(NSString *)fPid f_name:(NSString *)f_name s_name:(NSString *)s_name skip:(NSString *)skip space_id:(NSString *)spaceId
{
    AppDelegate *appleDate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
    if(appleDate.uploadmanage.isStopCurrUpload)
    {
        [self updateAutoUploadState];
        [delegate upNetworkStop];
        return;
    }
    NSURL *s_url=[NSURL URLWithString:[NSString stringWithFormat:@"%@%@",SERVER_URL,FM_UPLOAD_NEW_COMMIT]];
    
    NSData *returnData;
    NSError *error;
    @try {
        NSMutableURLRequest *request=[NSMutableURLRequest requestWithURL:s_url cachePolicy:NSURLRequestReloadIgnoringLocalCacheData timeoutInterval:CONNECT_TIMEOUT];
        NSLog(@"request1:%@",request);
        [request setValue:[[SCBSession sharedSession] userId] forHTTPHeaderField:@"ent_uid"];
        [request setValue:CLIENT_TAG forHTTPHeaderField:@"ent_uclient"];
        [request setValue:[[SCBSession sharedSession] userToken] forHTTPHeaderField:@"ent_utoken"];
        [request setValue:[[SCBSession sharedSession] ent_utype] forHTTPHeaderField:@"ent_utype"];
        NSMutableString *body=[[NSMutableString alloc] init];
        [body appendString:[NSString stringWithFormat:@"fpid=%@",fPid]];
        [body appendString:[NSString stringWithFormat:@"&fname=%@",f_name]];
        [body appendString:[NSString stringWithFormat:@"&sname=%@",s_name]];
        [body appendString:[NSString stringWithFormat:@"&spaceid=%@",list.spaceId]];
        NSLog(@"body:%@",body);
        NSMutableData *myRequestData=[NSMutableData data];
        [myRequestData appendData:[body dataUsingEncoding:NSUTF8StringEncoding]];
        [request setHTTPBody:myRequestData];
        [request setHTTPMethod:@"POST"];
        returnData = [NSURLConnection sendSynchronousRequest:request
                                           returningResponse:nil error:&error];
        if(returnData == nil || appleDate.uploadmanage.isStopCurrUpload)
        {
            [self updateAutoUploadState];
            if(returnData == nil)
            {
                [delegate webServiceFail];
            }
            else
            {
                [delegate upNetworkStop];
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
        [delegate upFinish:dictionary];
    }
    else
    {
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
    if(appleDate.uploadmanage.isStopCurrUpload)
    {
        [self updateAutoUploadState];
        [delegate upNetworkStop];
        return;
    }
    dispatch_async(dispatch_get_main_queue(), ^{
        [self uploadFiles:list.t_lenght sudu:list.sudu];
        connection = nil;
        [NSThread detachNewThreadSelector:@selector(comeBackNewTheadMian:) toTarget:self withObject:dictionary];
    });
}

//申请上传状态
-(void)requestUploadState:(NSDictionary *)dictionary{}

//查看上传记录
-(void)lookDescript:(NSDictionary *)dictionary{}

//上传文件流
-(void)uploadFiles:(int)proress sudu:(NSInteger)sudu
{
    AppDelegate *appleDate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
    if(appleDate.uploadmanage.isStopCurrUpload)
    {
        [self updateAutoUploadState];
        [connection cancel];
        connection = nil;
        [delegate upNetworkStop];
        return;
    }
    [delegate upProess:proress fileTag:sudu];
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
//    NSString *url = [NSString stringWithFormat:@"%@%@",SERVER_URL,FM_UPLOAD_NEW];
//    NSMutableDictionary *dictionary = [[[NSMutableDictionary alloc] init] autorelease];
//    [dictionary setValue:[[SCBSession sharedSession] userId] forKey:@"usr_id"];
//    [dictionary setValue:CLIENT_TAG forKey:@"client_tag"];
//    [dictionary setValue:[[SCBSession sharedSession] userToken] forKey:@"usr_token"];
//    [dictionary setValue:s_name forKey:@"s_name"];
//    [dictionary setValue:[NSString stringWithFormat:@"bytes=0-%@",skip] forKey:@"Range"];
//    
//    netWorkOperation = [[MKNetworkOperation alloc] initWithURLString:url params:dictionary httpMethod:@"PUT"];
//    [netWorkOperation onUploadProgressChanged:^(double proess){
//        NSLog(@"proess:%f",proess);
//    }];
//    
//    [netWorkOperation addData:image forKey:[[list.t_name componentsSeparatedByString:@"."] lastObject]];
//    [netWorkOperation onCompletion:^(MKNetworkOperation *respnose){
//        NSLog(@"respnose:%@",respnose);
//        [self uploadFinish:nil];
//    } onError:^(NSError *error){
//        NSLog(@"error:%@",error);
//    }];
//    [netWorkOperation main];
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
