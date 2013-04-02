//
//  NDAppDelegate.m
//  NetDisk
//
//  Created by jiangwei on 12-11-12.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//
#import "MobClick.h"
#import "NDAppDelegate.h"

#import "NDViewController.h"
@implementation UINavigationBar(customImage)
- (UIImage *)barBackground{
    return [UIImage imageNamed:@"top_bg.png"];
}
@end

@implementation NDAppDelegate

@synthesize window = _window;
@synthesize viewController = _viewController;
@synthesize m_copyId,m_copyArray,m_copyParentId,m_isCut,m_pasteType,m_parentIdForFresh;
@synthesize m_listArray_uploaded,m_listArray_uploading,m_listArray_downloaded,m_listArray_downloading;
@synthesize _taskMangeView;
- (void)dealloc
{
    [_window release];
    [_viewController release];
    if (m_copyParentId) {
        [m_copyParentId release];
    }
    if (m_copyId) {
        [m_copyId release];
    }
    if (m_copyArray) {
        [m_copyArray removeAllObjects];
        [m_copyArray release],m_copyArray = nil;
    }
    if (m_parentIdForFresh) {
        [m_parentIdForFresh release];
    }

    if (m_listArray_uploaded!=nil) {
        [m_listArray_uploaded removeAllObjects],[m_listArray_uploaded release],m_listArray_uploaded=nil;
    }
    if (m_listArray_uploading!=nil) {
        [m_listArray_uploading removeAllObjects],[m_listArray_uploading release],m_listArray_uploading=nil;
    }
    if (m_listArray_downloaded!=nil) {
        [m_listArray_downloaded removeAllObjects],[m_listArray_downloaded release],m_listArray_downloaded=nil;
    }
    if (m_listArray_downloading!=nil) {
        [m_listArray_downloading removeAllObjects],[m_listArray_downloading release],m_listArray_downloading=nil;
    }
    
    [_taskMangeView release];
    
    [super dealloc];
}

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    [MobClick startWithAppkey:@"5158f8f056240bb70c030e97"];
/*    struct statfs buf;
    long long totalspace2 = 0;
    if(statfs("/private/var", &buf) >= 0){
        totalspace2 = (long long)buf.f_bsize * buf.f_blocks;
    }    
    totalspace2 = totalspace2/1024/1024/1024;
 
    NSLog(@"totalspace2=%llu",totalspace2);
    
*/    
    
    m_pasteType=0;
    m_copyArray = [[NSMutableArray alloc]initWithCapacity:0];
    NSLog(@"fasfasfsadfasdf");
    self.window = [[[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]] autorelease];
    // Override point for customization after application launch.
    self.viewController = [[NDViewController alloc] initWithNibName:@"NDViewController" bundle:nil];
    UINavigationController *nav = [[[UINavigationController alloc] initWithRootViewController:self.viewController] autorelease];
    nav.navigationBar.hidden = YES;
    /*    
    UINavigationBar *navBar = nav.navigationBar;  

#define kSCNavBarImageTag 10  
    if ([navBar respondsToSelector:@selector(setBackgroundImage:forBarMetrics:)])  
    {  
        //if iOS 5.0 and later  
        [navBar setBackgroundImage:[UIImage imageNamed:@"top_bg.jpg"] forBarMetrics:UIBarMetricsDefault];  
    }  
    else  
    {  
        UIImageView *imageView = (UIImageView *)[navBar viewWithTag:kSCNavBarImageTag]; 
        imageView.contentMode = UIViewContentModeScaleToFill;
        if (imageView == nil)  
        {  
            imageView = [[UIImageView alloc] initWithImage:  
                         [UIImage imageNamed:@"top_bg.jpg"]];  
            [imageView setTag:kSCNavBarImageTag];  
            [navBar insertSubview:imageView atIndex:0];  
            [imageView release];  
        }  
    }  
*/    
    self.window.rootViewController = nav;
    
    [self.window makeKeyAndVisible];

    NSArray*paths=NSSearchPathForDirectoriesInDomains(NSDocumentDirectory,NSUserDomainMask,YES);
    NSString *documentsDirectory=[paths objectAtIndex:0]; 
    NSString *dbPath=[NSString stringWithFormat:@"%@/",documentsDirectory]; 
 //   SevenCBoxClient::Config.SetDbFilePath([dbPath cStringUsingEncoding:NSUTF8StringEncoding]);
 //   NSString *logPath = [documentsDirectory stringByAppendingPathComponent:@"7cboxLog.txt"];
  //  SevenCBoxClient::Config.SetLogFile([logPath cStringUsingEncoding:NSUTF8StringEncoding]);
    
  //  NSString *uploadTempPath = [NSString stringWithFormat:@"%@/",[Function getUploadTempPath]]; 
  //  SevenCBoxClient::Config.SetTempFolder([uploadTempPath cStringUsingEncoding:NSUTF8StringEncoding]);
    
    m_listArray_uploaded = [[NSMutableArray alloc]initWithCapacity:0];
    m_listArray_uploading = [[NSMutableArray alloc]initWithCapacity:0];
    m_listArray_downloaded = [[NSMutableArray alloc]initWithCapacity:0];
    m_listArray_downloading = [[NSMutableArray alloc]initWithCapacity:0];
    
     _taskMangeView=[[NDTaskManagerViewController alloc]initWithNibName:@"NDTaskManagerViewController" bundle:nil];
    
    NSString *imageCachePath = [Function getImgCachePath];
    if (![[NSFileManager defaultManager] fileExistsAtPath:imageCachePath]) 
    {
        [[NSFileManager defaultManager] createDirectoryAtPath:imageCachePath 
                                  withIntermediateDirectories:YES 
                                                   attributes:nil 
                                                        error:nil];       
    }
    imageCachePath = [Function getTempCachePath];
    if (![[NSFileManager defaultManager] fileExistsAtPath:imageCachePath]) 
    {
        [[NSFileManager defaultManager] createDirectoryAtPath:imageCachePath 
                                  withIntermediateDirectories:YES 
                                                   attributes:nil 
                                                        error:nil];       
    }
    
    imageCachePath = [Function getUploadTempPath ];
    if (![[NSFileManager defaultManager] fileExistsAtPath:imageCachePath]) 
    {
        [[NSFileManager defaultManager] createDirectoryAtPath:imageCachePath 
                                  withIntermediateDirectories:YES 
                                                   attributes:nil 
                                                        error:nil];       
    }
    imageCachePath = [Function getKeepCachePath ];
    if (![[NSFileManager defaultManager] fileExistsAtPath:imageCachePath]) 
    {
        [[NSFileManager defaultManager] createDirectoryAtPath:imageCachePath 
                                  withIntermediateDirectories:YES 
                                                   attributes:nil 
                                                        error:nil];       
    }
    imageCachePath = [Function getThumbCachePath ];
    if (![[NSFileManager defaultManager] fileExistsAtPath:imageCachePath])
    {
        [[NSFileManager defaultManager] createDirectoryAtPath:imageCachePath
                                  withIntermediateDirectories:YES
                                                   attributes:nil
                                                        error:nil];
    }
    return YES;
}

- (void)applicationWillResignActive:(UIApplication *)application
{
    /*
     Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
     Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
     */
}

- (void)applicationDidEnterBackground:(UIApplication *)application
{
    /*
     Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later. 
     If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
     */
}

- (void)applicationWillEnterForeground:(UIApplication *)application
{
    /*
     Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
     */
}

- (void)applicationDidBecomeActive:(UIApplication *)application
{
    /*
     Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
     */
}

- (void)applicationWillTerminate:(UIApplication *)application
{
    /*
     Called when the application is about to terminate.
     Save data if appropriate.
     See also applicationDidEnterBackground:.
     */
}
-(void)clearCopyCache
{
    if(m_copyParentId!=nil)
        [m_copyParentId release],m_copyParentId=nil;
    if(m_copyId!=nil)
        [m_copyId release],m_copyId=nil;
    if (m_copyArray&&[m_copyArray count]>0) {
        [m_copyArray removeAllObjects];
    }
}
-(void)clearFreshID
{
    if (m_parentIdForFresh!=nil) {
        [m_parentIdForFresh release];
        m_parentIdForFresh = nil;
    }
}
/*
-(void)setTaskUploadedList:(NSMutableArray *)theUploadedList 
          theUploadingList:(NSMutableArray *)theUploadingList 
         theDownloadedList:(NSMutableArray *)theDownloadedList 
         theDownloadingList:(NSMutableArray *)theDownloadingList 
{
    
    theUploadedList = m_listArray_uploaded;
    theUploadingList = m_listArray_uploading;
    theDownloadedList = m_listArray_downloaded;
    theDownloadingList = m_listArray_downloading;
}*/
@end
