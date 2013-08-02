//
//  SCBAccountManager.m
//  NetDisk
//
//  Created by fengyongning on 13-4-12.
//
//

#import "SCBAccountManager.h"
#import "SCBoxConfig.h"
#import "SCBSession.h"
#import "MF_Base64Additions.h"
static SCBAccountManager *_sharedAccountManager;
@implementation SCBAccountManager
+(SCBAccountManager *)sharedManager
{
    if (_sharedAccountManager==nil) {
        _sharedAccountManager=[[self alloc] init];
    }
    return _sharedAccountManager;
}
-(void)currentUserSpace
{
    self.activeData=[NSMutableData data];
    self.type=kUserGetSpace;
    NSURL *s_url= [NSURL URLWithString:[NSString stringWithFormat:@"%@%@",SERVER_URL,USER_SPACE_URI]];
    NSMutableURLRequest *request=[NSMutableURLRequest requestWithURL:s_url cachePolicy:NSURLRequestReloadIgnoringLocalCacheData timeoutInterval:CONNECT_TIMEOUT];
    [request setValue:CLIENT_TAG forHTTPHeaderField:@"client_tag"];
    [request setValue:[[SCBSession sharedSession] userId] forHTTPHeaderField:@"usr_id"];
    [request setValue:[[SCBSession sharedSession] userToken] forHTTPHeaderField:@"usr_token"];
    [request setHTTPMethod:@"POST"];
    [[[NSURLConnection alloc] initWithRequest:request delegate:self] autorelease];
}
-(void)UserLoginWithName:(NSString *)user_name Password:(NSString *)user_pwd
{
    self.activeData=[NSMutableData data];
    self.type=kUserLogin;
    NSURL *s_url= [NSURL URLWithString:[NSString stringWithFormat:@"%@%@",SERVER_URL,USER_LOGIN_URI]];
    NSMutableURLRequest *request=[NSMutableURLRequest requestWithURL:s_url cachePolicy:NSURLRequestReloadIgnoringLocalCacheData timeoutInterval:CONNECT_TIMEOUT];
    NSMutableString *body=[[NSMutableString alloc] init];
    NSString *mi_ma =[user_pwd base64String];
    [body appendFormat:@"usr_name=%@&usr_pwd=%@",user_name,mi_ma];
    NSMutableData *myRequestData=[NSMutableData data];
    [myRequestData appendData:[body dataUsingEncoding:NSUTF8StringEncoding]];
    [request setValue:CLIENT_TAG forHTTPHeaderField:@"client_tag"];
    [request setHTTPBody:myRequestData];
    [request setHTTPMethod:@"POST"];
    [[[NSURLConnection alloc] initWithRequest:request delegate:self] autorelease];
    [body release];
}
-(void)UserLogout
{
    
}
-(void)UserRegisterWithName:(NSString *)user_name Password:(NSString *)user_pwd
{
    self.activeData=[NSMutableData data];
    self.type=kUserRegist;
    NSURL *s_url= [NSURL URLWithString:[NSString stringWithFormat:@"%@%@",SERVER_URL,USER_REGISTER_URI]];
    NSMutableURLRequest *request=[NSMutableURLRequest requestWithURL:s_url cachePolicy:NSURLRequestReloadIgnoringLocalCacheData timeoutInterval:CONNECT_TIMEOUT];
    NSMutableString *body=[[NSMutableString alloc] init];
    NSString *mi_ma =[user_pwd base64String];
    [body appendFormat:@"usr_name=%@&usr_pwd=%@&check_code=%@",user_name,mi_ma,@"23452"];
    NSMutableData *myRequestData=[NSMutableData data];
    [myRequestData appendData:[body dataUsingEncoding:NSUTF8StringEncoding]];
    [request setValue:CLIENT_TAG forHTTPHeaderField:@"client_tag"];
    [request setHTTPBody:myRequestData];
    [request setHTTPMethod:@"POST"];
    [[NSURLConnection alloc] initWithRequest:request delegate:self];
    [body release];
}
#pragma mark NSURLConnectionDelegate Method
- (void)connection:(NSURLConnection *)theConnection didReceiveResponse:(NSURLResponse *)response
// A delegate method called by the NSURLConnection when the request/response
// exchange is complete.  We look at the response to check that the HTTP
// status code is 2xx.  If it isn't, we fail right now.
{
    NSLog(@"connection:didReceiveResponse:");
#pragma unused(theConnection)
    NSHTTPURLResponse * httpResponse;
    
    //    assert(theConnection == self.connection);
    //
    httpResponse = (NSHTTPURLResponse *) response;
    assert( [httpResponse isKindOfClass:[NSHTTPURLResponse class]] );
    
    if ((httpResponse.statusCode / 100) != 2) {
        NSLog(@"HTTP error %zd",(ssize_t)httpResponse.statusCode);
    } else {
        NSLog(@"Response OK.");
    }
}

- (void)connection:(NSURLConnection *)theConnection didReceiveData:(NSData *)data
// A delegate method called by the NSURLConnection as data arrives.  The
// response data for a POST is only for useful for debugging purposes,
// so we just drop it on the floor.
{
    [self.activeData appendData:data];
    NSLog(@"connection:didReceiveData:");
    //    assert(theConnection == self.connection);
    
    // do nothing
}

- (void)connection:(NSURLConnection *)theConnection didFailWithError:(NSError *)error
// A delegate method called by the NSURLConnection if the connection fails.
// We shut down the connection and display the failure.  Production quality code
// would either display or log the actual error.
{
    NSLog(@"connection:didFailWithError");
#pragma unused(theConnection)
#pragma unused(error)
    //    assert(theConnection == self.connection);
    //
    //    [self stopSendWithStatus:@"Connection failed"];
    switch (self.type) {
        case kUserLogin:
            [self.delegate loginUnsucceed:self];
            break;
        case kUserRegist:
            [self.delegate registUnsucceed:self];
            break;
        case kUserGetSpace:
            break;
        default:
            break;
    }
}

- (void)connectionDidFinishLoading:(NSURLConnection *)theConnection
// A delegate method called by the NSURLConnection when the connection has been
// done successfully.  We shut down the connection with a nil status, which
// causes the image to be displayed.
{
    NSLog(@"connectionDidFinishLoading");
    NSError *jsonParsingError=nil;
    if (self.activeData==nil) {
        NSLog(@"!!!数据错误!!");
        return;
    }
    NSDictionary *dic=[NSJSONSerialization JSONObjectWithData:self.activeData options:0 error:&jsonParsingError];
    if ([[dic objectForKey:@"code"] intValue]==0) {
    }else
    {
        NSLog(@"网络操作失败：");
        NSLog(@"%@",dic);
    }
    switch (self.type) {
        case kUserLogin:
            if ([[dic objectForKey:@"code"] intValue]==0) {
                NSLog(@"登录成功:\n%@",dic);
                [[SCBSession sharedSession] setUserId:(NSString *)[dic objectForKey:@"usr_id"]];
                [[SCBSession sharedSession] setUserToken:(NSString *)[dic objectForKey:@"usr_token"]];
                [[SCBSession sharedSession] setHomeID:(NSString *)[dic objectForKey:@"home_id"]];
                [[SCBSession sharedSession] setSpaceID:(NSString *)[dic objectForKey:@"space_id"]];
                [[SCBSession sharedSession] setUserTag:(NSString *)[dic objectForKey:@"usr_tag"]];
                
                
                [[NSUserDefaults standardUserDefaults] setObject:(NSString *)[dic objectForKey:@"usr_id"] forKey:@"usr_id"];
                [[NSUserDefaults standardUserDefaults] setObject:(NSString *)[dic objectForKey:@"usr_token"]  forKey:@"usr_token"];
                [[NSUserDefaults standardUserDefaults] setObject:(NSString *)[dic objectForKey:@"home_id"]  forKey:@"home_id"];
                [[NSUserDefaults standardUserDefaults] setObject:(NSString *)[dic objectForKey:@"space_id"]  forKey:@"space_id"];
                [[NSUserDefaults standardUserDefaults] setObject:(NSString *)[dic objectForKey:@"usr_tag"]  forKey:@"usr_tag"];
                [[NSUserDefaults standardUserDefaults] synchronize];
                
                NSLog(@"%@",[[SCBSession sharedSession] userId]);
                NSLog(@"%@",[[SCBSession sharedSession] userToken]);
                [self.delegate loginSucceed:self];
            }else
            {
                [self.delegate loginUnsucceed:self];
            }

            break;
        case kUserRegist:
            if ([[dic objectForKey:@"code"] intValue]==0) {
                NSLog(@"注册成功:\n%@",dic);
                [[SCBSession sharedSession] setUserId:(NSString *)[dic objectForKey:@"usr_id"]];
                [[SCBSession sharedSession] setUserToken:(NSString *)[dic objectForKey:@"usr_token"]];
                [[SCBSession sharedSession] setHomeID:(NSString *)[dic objectForKey:@"home_id"]];
                [[SCBSession sharedSession] setSpaceID:(NSString *)[dic objectForKey:@"space_id"]];
                [[SCBSession sharedSession] setUserTag:(NSString *)[dic objectForKey:@"usr_tag"]];
                
                [[NSUserDefaults standardUserDefaults] setObject:(NSString *)[dic objectForKey:@"usr_id"] forKey:@"usr_id"];
                [[NSUserDefaults standardUserDefaults] setObject:(NSString *)[dic objectForKey:@"usr_token"]  forKey:@"usr_token"];
                [[NSUserDefaults standardUserDefaults] setObject:(NSString *)[dic objectForKey:@"home_id"]  forKey:@"home_id"];
                [[NSUserDefaults standardUserDefaults] setObject:(NSString *)[dic objectForKey:@"space_id"]  forKey:@"space_id"];
                [[NSUserDefaults standardUserDefaults] setObject:(NSString *)[dic objectForKey:@"usr_tag"]  forKey:@"usr_tag"];
                [[NSUserDefaults standardUserDefaults] synchronize];
                [self.delegate registSucceed];
            }else
            {
                NSLog(@"注册失败！！！");
                [self.delegate registUnsucceed:self];
            }
            break;
        case kUserGetSpace:
            if ([[dic objectForKey:@"code"] intValue]==0) {
                NSLog(@"空间（已用大小/总大小） ： %@/%@",[dic objectForKey:@"space_used"],[dic objectForKey:@"space_total"]);
                [self.delegate spaceSucceedUsed:[dic objectForKey:@"space_used"] total:[dic objectForKey:@"space_total"]];
            }else
            {
                
            }
            break;
        default:
            break;
    }
    self.activeData=nil;
}
@end
