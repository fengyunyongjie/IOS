//
//  SCBUploader.m
//  NetDisk
//
//  Created by fengyongning on 13-4-15.
//
//

#import "SCBUploader.h"
#import "SCBoxConfig.h"
#import "SCBSession.h"

@implementation SCBUploader
@synthesize upLoadDelegate;
@synthesize matableData;

//上传效验
-(void)requestUploadVerify:(int)f_pid f_name:(NSString *)f_name f_size:(NSString *)f_size f_md5:(NSString *)f_md5
{
    self.matableData = [NSMutableData data];
    NSURL *s_url=[NSURL URLWithString:[NSString stringWithFormat:@"%@%@",SERVER_URL,FM_UPLOAD_NEW_VERIFY]];
    NSMutableURLRequest *request=[NSMutableURLRequest requestWithURL:s_url cachePolicy:NSURLRequestReloadIgnoringLocalCacheData timeoutInterval:CONNECT_TIMEOUT];
    url_string = FM_UPLOAD_NEW_VERIFY;
    [request setValue:[[SCBSession sharedSession] userId] forHTTPHeaderField:@"usr_id"];
    [request setValue:CLIENT_TAG forHTTPHeaderField:@"client_tag"];
    [request setValue:[[SCBSession sharedSession] userToken] forHTTPHeaderField:@"usr_token"];
    NSMutableString *body=[[NSMutableString alloc] init];
    [body appendFormat:@"f_pid=%i&f_name=%@&f_size=%@&f_md5=%@",f_pid,f_name,f_size,f_md5];
    NSLog(@"body:%@",body);
    NSMutableData *myRequestData=[NSMutableData data];
    [myRequestData appendData:[body dataUsingEncoding:NSUTF8StringEncoding]];
    [request setHTTPBody:myRequestData];
    [body release];
    [request setHTTPMethod:@"POST"];
    NSLog(@"%@,%@",[[SCBSession sharedSession] userId],[[SCBSession sharedSession] userToken]);
    [[[NSURLConnection alloc] initWithRequest:request delegate:self] autorelease];
}

//
-(void)requestUploadState:(NSString *)s_name
{
    self.matableData = [NSMutableData data];
    NSURL *s_url=[NSURL URLWithString:[NSString stringWithFormat:@"%@%@",SERVER_URL,FM_UPLOAD_STATE]];
    NSMutableURLRequest *request=[NSMutableURLRequest requestWithURL:s_url cachePolicy:NSURLRequestReloadIgnoringLocalCacheData timeoutInterval:CONNECT_TIMEOUT];
    url_string = FM_UPLOAD_STATE;
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
    NSLog(@"%@,%@",[[SCBSession sharedSession] userId],[[SCBSession sharedSession] userToken]);
    [[[NSURLConnection alloc] initWithRequest:request delegate:self] autorelease];
}

//上传
-(NSURLConnection *)requestUploadFile:(NSString *)f_pid f_name:(NSString *)f_name s_name:(NSString *)s_name skip:(NSString *)skip f_md5:(NSString *)f_md5 Image:(NSData *)image
{
    self.matableData = [NSMutableData data];
    NSURL *s_url=[NSURL URLWithString:[NSString stringWithFormat:@"%@%@",SERVER_URL,FM_UPLOAD_NEW]];
    NSMutableURLRequest *request=[NSMutableURLRequest requestWithURL:s_url cachePolicy:NSURLRequestReloadIgnoringLocalCacheData timeoutInterval:CONNECT_TIMEOUT];
    url_string = FM_UPLOAD_NEW;
    [request setValue:[[SCBSession sharedSession] userId] forHTTPHeaderField:@"usr_id"];
    [request setValue:CLIENT_TAG forHTTPHeaderField:@"client_tag"];
    [request setValue:[[SCBSession sharedSession] userToken] forHTTPHeaderField:@"usr_token"];
    [request setValue:s_name forHTTPHeaderField:@"s_name"];
    [request setValue:[NSString stringWithFormat:@"bytes=0-%@",skip] forHTTPHeaderField:@"Range"];
    [request setHTTPBody:image];
    [request setHTTPMethod:@"PUT"];
    NSLog(@"上传请求：%@,%@",[[SCBSession sharedSession] userId],[[SCBSession sharedSession] userToken]);
    NSURLConnection *con = [[[NSURLConnection alloc] initWithRequest:request delegate:self] autorelease];
    return con;
}

//上传提交
-(void)requestUploadCommit:(NSString *)f_pid f_name:(NSString *)f_name s_name:(NSString *)s_name device:(NSString *)deviceName skip:(NSString *)skip f_md5:(NSString *)f_md5 img_createtime:(NSString *)dateString
{
    self.matableData = [NSMutableData data];
    NSURL *s_url=[NSURL URLWithString:[NSString stringWithFormat:@"%@%@",SERVER_URL,FM_UPLOAD_NEW_COMMIT]];
    NSMutableURLRequest *request=[NSMutableURLRequest requestWithURL:s_url cachePolicy:NSURLRequestReloadIgnoringLocalCacheData timeoutInterval:CONNECT_TIMEOUT];
    url_string = FM_UPLOAD_NEW_COMMIT;
    [request setValue:[[SCBSession sharedSession] userId] forHTTPHeaderField:@"usr_id"];
    [request setValue:CLIENT_TAG forHTTPHeaderField:@"client_tag"];
    [request setValue:[[SCBSession sharedSession] userToken] forHTTPHeaderField:@"usr_token"];
    NSMutableString *body=[[NSMutableString alloc] init];
    [body appendString:[NSString stringWithFormat:@"f_pid=%@",f_pid]];
    [body appendString:[NSString stringWithFormat:@"&f_name=%@",f_name]];
    [body appendString:[NSString stringWithFormat:@"&s_name=%@",s_name]];
    [body appendString:@"&img_device="];
    NSLog(@"uploadData:%@",f_md5);
    [body appendString:[NSString stringWithFormat:@"&f_md5=%@",f_md5]];
    [body appendString:@"&img_size="];
    [body appendString:@"&img_createtime="];
    NSLog(@"body:%@",body);
    NSMutableData *myRequestData=[NSMutableData data];
    [myRequestData appendData:[body dataUsingEncoding:NSUTF8StringEncoding]];
    [request setHTTPBody:myRequestData];
    [body release];
    [request setHTTPMethod:@"POST"];
    NSLog(@"上传完成后提交 %@,%@",[[SCBSession sharedSession] userId],[[SCBSession sharedSession] userToken]);
    [[[NSURLConnection alloc] initWithRequest:request delegate:self] autorelease];
}
-(void)request:(ASIHTTPRequest *)request didReceiveData:(NSData *)data
{
    [self.matableData appendData:data];
}
-(void)requestFinished:(ASIHTTPRequest *)request
{
//    NSLog(@"--------------------------------------------------太忙了");
//    NSDictionary *diction = [NSJSONSerialization JSONObjectWithData:self.matableData options:NSJSONReadingMutableLeaves error:nil];
//    NSLog(@"请求成功后，分发数据:%@",diction);
}


#pragma mark -请求成功后，分发数据
- (void)connection:(NSURLConnection *)connection didReceiveData:(NSData *)data
{
    [self.matableData appendData:data];
}

- (void)connectionDidFinishLoading:(NSURLConnection *)connection
{
    NSLog(@"--------------------------------------------------太忙了");
    NSDictionary *diction = [NSJSONSerialization JSONObjectWithData:self.matableData options:NSJSONReadingMutableLeaves error:nil];
    NSLog(@"请求成功后，分发数据:%@",diction);
    NSString *type_string = [[[[[connection originalRequest] URL] path] componentsSeparatedByString:@"/"] lastObject];
    NSLog(@"type_string:%@",type_string);
    if([type_string isEqualToString:[[FM_UPLOAD_NEW_VERIFY componentsSeparatedByString:@"/"] lastObject]])
    {
        [upLoadDelegate uploadVerify:diction];
    }
    else if([type_string isEqualToString:[[FM_UPLOAD_NEW componentsSeparatedByString:@"/"] lastObject]])
    {
        [upLoadDelegate uploadFinish:diction];
    }
    else if([type_string isEqualToString:[[FM_UPLOAD_STATE componentsSeparatedByString:@"/"] lastObject]])
    {
        [upLoadDelegate requestUploadState:diction];
    }
    else if([type_string isEqualToString:[[FM_UPLOAD_NEW_COMMIT componentsSeparatedByString:@"/"] lastObject]])
    {
        [upLoadDelegate uploadCommit:diction];
    } 
}

-(void)dealloc
{
    [matableData release];
    [upLoadDelegate release];
    [super dealloc];
}

@end
