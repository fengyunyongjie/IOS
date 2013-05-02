//
//  SCBPhotoManager.m
//  NetDisk
//
//  Created by fengyongning on 13-4-15.
//
//

#import "SCBPhotoManager.h"
#import "SCBSession.h"
#import "SCBoxConfig.h"

@implementation SCBPhotoManager
@synthesize photoDelegate;

-(void)getPhotoTimeLine
{
//    ASIFormDataRequest *request = [ASIFormDataRequest requestWithURL:[NSURL URLWithString:[NSString stringWithFormat:@"%@%@",SERVER_URL,PHOTO_TIMERLINE]]];
//    [request setRequestMethod:@"POST"];
//    [request setPostValue:[[SCBSession sharedSession] userId] forKey:@"usr_id"];
//    [request setPostValue:[NSNumber numberWithInt:3] forKey:@"client_tag"];
//    [request setPostValue:[[SCBSession sharedSession] userToken] forKey:@"usr_token"];
//    [request setTimeOutSeconds:60];
//    [request startSynchronous];
//    NSData *response = [request responseData];
//    NSObject *obj = [NSJSONSerialization JSONObjectWithData:response options:nil error:nil];
//    NSLog(@"obj:%@",[request responseString]);
    
    
    NSURL *s_url=[NSURL URLWithString:[NSString stringWithFormat:@"%@%@",SERVER_URL,PHOTO_TIMERLINE]];
    NSMutableURLRequest *request=[NSMutableURLRequest requestWithURL:s_url cachePolicy:NSURLRequestReloadIgnoringLocalCacheData timeoutInterval:CONNECT_TIMEOUT];
    url_string = PHOTO_TIMERLINE;
//    NSMutableString *body=[[NSMutableString alloc] init];
//    [body appendFormat:@"f_id=%@&cursor=%d&offset=%d",@"1",0,-1];
//    NSMutableData *myRequestData=[NSMutableData data];
//    [myRequestData appendData:[body dataUsingEncoding:NSUTF8StringEncoding]];
    
    [request setValue:[[SCBSession sharedSession] userId] forHTTPHeaderField:@"usr_id"];
    [request setValue:CLIENT_TAG forHTTPHeaderField:@"client_tag"];
    [request setValue:[[SCBSession sharedSession] userToken] forHTTPHeaderField:@"usr_token"];
    [request setHTTPMethod:@"POST"];
    
    [[[NSURLConnection alloc] initWithRequest:request delegate:self] autorelease];
}

#pragma mark -请求成功后，分发数据
- (void)connection:(NSURLConnection *)connection didReceiveData:(NSData *)data
{
    NSDictionary *diction = [NSJSONSerialization JSONObjectWithData:data options:nil error:nil];
    NSString *type_string = [[[[[connection originalRequest] URL] path] componentsSeparatedByString:@"/"] lastObject];
    if([type_string isEqualToString:[[PHOTO_TIMERLINE componentsSeparatedByString:@"/"] lastObject]])
    {
        [photoDelegate getPhotoTiimeLine:diction];
    }
    else if([type_string isEqualToString:[[PHOTO_GENERAL componentsSeparatedByString:@"/"] lastObject]])
    {
        [photoDelegate getPhotoGeneral:diction];
    }
    else if([type_string isEqualToString:[[PHOTO_DETAIL componentsSeparatedByString:@"/"] lastObject]])
    {
        [photoDelegate getPhotoDetail:diction];
    }
}

@end
