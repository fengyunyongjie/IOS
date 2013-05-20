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
-(void)UserLoginWithName:(NSString *)user_name Password:(NSString *)user_pwd
{
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
    NSURLConnection *conn=[[NSURLConnection alloc] initWithRequest:request delegate:self];
}
-(void)UserLogout
{
    
}
-(void)UserRegisterWithName:(NSString *)user_name Password:(NSString *)user_pwd
{
    
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
    NSLog(@"connection:didReceiveData:");
    NSError *jsonParsingError=nil;
    NSDictionary *dic=[NSJSONSerialization JSONObjectWithData:data options:0 error:&jsonParsingError];
    NSLog(@"%@",[dic objectForKey:@"usr_id"] );
    NSLog(@"%@",[dic objectForKey:@"code"] );
    NSLog(@"%@",[dic objectForKey:@"usr_token"] );
    if ([[dic objectForKey:@"code"] intValue]==0) {
        NSLog(@"safafaf");
        [[SCBSession sharedSession] setUserId:(NSString *)[dic objectForKey:@"usr_id"]];
        [[SCBSession sharedSession] setUserToken:(NSString *)[dic objectForKey:@"usr_token"]];
        
        [[NSUserDefaults standardUserDefaults] setObject:(NSString *)[dic objectForKey:@"usr_id"] forKey:@"usr_id"];
        [[NSUserDefaults standardUserDefaults] setObject:(NSString *)[dic objectForKey:@"usr_token"]  forKey:@"usr_token"];
        [[NSUserDefaults standardUserDefaults] synchronize];
        
        NSLog(@"%@",[[SCBSession sharedSession] userId]);
        NSLog(@"%@",[[SCBSession sharedSession] userToken]);
        [self.delegate loginSucceed:self];
    }else
    {
        [self.delegate loginUnsucceed:self];
    }
    
    //NSLog(@"%@",[[NSString alloc]initWithData:data encoding:NSUTF8StringEncoding]);
#pragma unused(theConnection)
#pragma unused(data)
    
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
}

- (void)connectionDidFinishLoading:(NSURLConnection *)theConnection
// A delegate method called by the NSURLConnection when the connection has been
// done successfully.  We shut down the connection with a nil status, which
// causes the image to be displayed.
{
    NSLog(@"connectionDidFinishLoading");
    //#pragma unused(theConnection)
    //    assert(theConnection == self.connection);
    //
    //    [self stopSendWithStatus:nil];
}
@end
