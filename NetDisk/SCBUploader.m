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
-(void)requestUploadVerify:(int)f_pid f_name:(NSString *)f_name f_size:(NSString *)f_size
{
    self.matableData = [NSMutableData data];
    NSURL *s_url=[NSURL URLWithString:[NSString stringWithFormat:@"%@%@",SERVER_URL,FM_UPLOAD_VERIFY]];
    NSMutableURLRequest *request=[NSMutableURLRequest requestWithURL:s_url cachePolicy:NSURLRequestReloadIgnoringLocalCacheData timeoutInterval:CONNECT_TIMEOUT];
    url_string = FM_UPLOAD_VERIFY;
    [request setValue:[[SCBSession sharedSession] userId] forHTTPHeaderField:@"usr_id"];
    [request setValue:CLIENT_TAG forHTTPHeaderField:@"client_tag"];
    [request setValue:[[SCBSession sharedSession] userToken] forHTTPHeaderField:@"usr_token"];
    NSMutableString *body=[[NSMutableString alloc] init];
    [body appendFormat:@"f_pid=%i&f_name=%@&f_size=%@",f_pid,f_name,f_size];
    NSLog(@"body:%@",body);
    NSMutableData *myRequestData=[NSMutableData data];
    [myRequestData appendData:[body dataUsingEncoding:NSUTF8StringEncoding]];
    [request setHTTPBody:myRequestData];
    
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
    
    [request setHTTPMethod:@"POST"];
    NSLog(@"%@,%@",[[SCBSession sharedSession] userId],[[SCBSession sharedSession] userToken]);
    [[[NSURLConnection alloc] initWithRequest:request delegate:self] autorelease];
}

//上传
-(void)requestUploadFile:(NSString *)f_pid f_name:(NSString *)f_name s_name:(NSString *)s_name skip:(NSString *)skip f_md5:(NSString *)f_md5 Image:(NSData *)image
{
    self.matableData = [NSMutableData data];
    NSURL *s_url=[NSURL URLWithString:[NSString stringWithFormat:@"%@%@",SERVER_URL,FM_UPLOAD]];
    NSMutableURLRequest *request=[NSMutableURLRequest requestWithURL:s_url cachePolicy:NSURLRequestReloadIgnoringLocalCacheData timeoutInterval:CONNECT_TIMEOUT];
    url_string = FM_UPLOAD;
    [request setValue:[[SCBSession sharedSession] userId] forHTTPHeaderField:@"usr_id"];
    [request setValue:CLIENT_TAG forHTTPHeaderField:@"client_tag"];
    [request setValue:[[SCBSession sharedSession] userToken] forHTTPHeaderField:@"usr_token"];
    NSMutableString *body=[[NSMutableString alloc] init];
    [body appendFormat:@"f_pid=%@&f_name=%@&s_name=%@&skip=%@&md5=%@",f_pid,f_name,s_name,skip,f_md5];
    NSMutableData *myRequestData=[NSMutableData data];
    [myRequestData appendData:[body dataUsingEncoding:NSUTF8StringEncoding]];
    NSLog(@"body:%@",body);
    [request setHTTPBody:myRequestData];
    NSInputStream *inputStream = [NSInputStream inputStreamWithData:image];
    [request setHTTPBodyStream:inputStream];
    [request setHTTPMethod:@"POST"];
    NSLog(@"%@,%@",[[SCBSession sharedSession] userId],[[SCBSession sharedSession] userToken]);
    [[[NSURLConnection alloc] initWithRequest:request delegate:self] autorelease];
    
//    self.matableData = [NSMutableData data];
//    
//    NSURL *url=[NSURL URLWithString:[NSString stringWithFormat:@"%@%@",SERVER_URL,FM_UPLOAD]];
//    ASIFormDataRequest *request = [ASIFormDataRequest requestWithURL:url];
//    [request addRequestHeader:@"usr_id" value:[[SCBSession sharedSession] userId]];
//    [request addRequestHeader:@"client_tag" value:CLIENT_TAG];
//    [request addRequestHeader:@"usr_token" value:[[SCBSession sharedSession] userToken]];
    
//    [request addRequestHeader:@"f_pid" value:f_pid];
//    [request addRequestHeader:@"f_name" value:f_name];
//    [request addRequestHeader:@"s_name" value:s_name];
//    [request addRequestHeader:@"skip" value:skip];
//    [request addRequestHeader:@"md5" value:f_md5];
    
//    [request setPostValue:f_pid forKey:@"f_pid"];
//    [request setPostValue:f_name forKey:@"f_name"];
//    [request setPostValue:s_name forKey:@"s_name"];
//    [request setPostValue:skip forKey:@"skip"];
//    [request setPostValue:f_md5 forKey:@"md5"];
//    NSMutableData *imageData = [NSMutableData dataWithData:image];
//    NSLog(@"imageData:%@",imageData);
//    [request setPostBody:imageData];
//    [request setTimeOutSeconds:30];
    
    
//    [request setPostValue:[[SCBSession sharedSession] userId] forKey:@"usr_id"];
//    [request setPostValue:CLIENT_TAG forKey:@"usr_id"];
//    [request setPostValue:[[SCBSession sharedSession] userToken] forKey:@"usr_token"];
//    url_string = FM_UPLOAD;
//    NSMutableString *body=[[NSMutableString alloc] init];
//    [body appendFormat:@"f_pid=%@&f_name=%@&s_name=%@&skip=%@&md5=%@",f_pid,f_name,s_name,skip,f_md5];
//    NSMutableData *myRequestData=[NSMutableData data];
//    [myRequestData appendData:[body dataUsingEncoding:NSUTF8StringEncoding]];
//    NSLog(@"body:%@",body);
//    [request setPostBody:myRequestData];
//    [body release];
    
    
//    [request addData:imageData withFileName:s_name andContentType:@"image/png" forKey:@"image"];
//    [request setShouldStreamPostDataFromDisk:YES];
//    [request setRequestMethod:@"POST"];
//    [request setDelegate:self];
//    [request startSynchronous];
//    NSLog(@"%@",[request responseString]);
    
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
    if([type_string isEqualToString:[[FM_UPLOAD_VERIFY componentsSeparatedByString:@"/"] lastObject]])
    {
        [upLoadDelegate uploadVerify:diction];
    }
    else if([type_string isEqualToString:[[FM_UPLOAD componentsSeparatedByString:@"/"] lastObject]])
    {
        [upLoadDelegate uploadFinish:diction];
    }
    else if([type_string isEqualToString:[[FM_UPLOAD_STATE componentsSeparatedByString:@"/"] lastObject]])
    {
        [upLoadDelegate requestUploadState:diction];
    }
    
}

-(void)dealloc
{
    [matableData release];
    [upLoadDelegate release];
    [super dealloc];
}

@end
