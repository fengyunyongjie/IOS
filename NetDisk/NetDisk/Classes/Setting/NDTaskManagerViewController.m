//
//  NDTaskManagerViewController.m
//  NetDisk
//
//  Created by jiangwei on 13-1-7.
//  Copyright (c) 2013年 __MyCompanyName__. All rights reserved.
//

#import "NDTaskManagerViewController.h"
#include "NDAppDelegate.h"
void callBackPhotoSpaceFunc(Value &jsonValue,void *s_pv);
void callBackPhotoFmMkdirFunc(Value &jsonValue,void *s_pv);
void callBackPhotoSubFunc(Value &jsonValue,void *s_pv);
void callBackPhotoUploadFunc(Value &jsonValue,void *s_pv);
static void CreateTaskList(void* task);
static void UpdateTaskList(void* task);
static id s_pv;

@implementation NDTaskManagerViewController
@synthesize m_tableView,m_bottom_view,segment,m_camerUploadButton;
@synthesize selectedPhotos,m_parentFID;
- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        
        s_pv = self;
        m_isUpload = YES;
        
        m_listArray_uploaded = [[NSMutableArray alloc]initWithCapacity:0];
        m_listArray_uploading = [[NSMutableArray alloc]initWithCapacity:0];
        m_listArray_downloaded = [[NSMutableArray alloc]initWithCapacity:0];
        m_listArray_downloading = [[NSMutableArray alloc]initWithCapacity:0];
        
        m_isContinus = YES;

    }
    return self;
}
- (void)dealloc{
    [m_tableView release];
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
    
    [segment release];
    [m_bottom_view release];
    [m_camerUploadButton release];
    
    [m_hud release];
    [m_parentFID release];
 /*   
    if (imagePickerController) {
        [imagePickerController release];
    }
 */   
    [super dealloc];
}

- (void)didReceiveMemoryWarning
{
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
    
    // Release any cached data, images, etc that aren't in use.
}

#pragma mark - View lifecycle

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.selectedPhotos = [NSMutableArray array];
    m_hud = [[ATMHud alloc] initWithDelegate:self];
	[self.view addSubview:m_hud.view];
    
    [self performSelector:@selector(OnPrepare) withObject:nil afterDelay:0.3f];
    
    NSArray *objects = [NSArray arrayWithObjects:@"上传管理", @"下载管理", nil];
    segment = [[STSegmentedControl alloc] initWithItems:objects];
    segment.backgroundColor = [UIColor clearColor];
    segment.frame = CGRectMake(85, 9, 150, 20);
    [segment addTarget:self action:@selector(valueChanged:) forControlEvents:UIControlEventValueChanged];
    segment.selectedSegmentIndex = 0;
    segment.autoresizingMask = UIViewAutoresizingFlexibleWidth;
    [self.view addSubview:segment];
    
    BOOL hasCamera = [UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeCamera];
    if (!hasCamera) {
        m_camerUploadButton.enabled = NO;
    }
}
- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    NSTimeInterval timeInterval =2.0f ;
    m_timer = [NSTimer scheduledTimerWithTimeInterval:timeInterval 
                                               target:self
                                             selector:@selector(reloadTableView)
                                             userInfo:nil 
                                              repeats:YES];
    
}
- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    if ([m_timer isValid]) {
        [m_timer invalidate];
    }
}
- (void)reloadTableView
{
    m_isContinus = NO;
    [m_tableView reloadData];
}
- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
/*    NDAppDelegate *appDelegate =  (NDAppDelegate *)[UIApplication sharedApplication].delegate;
    m_listArray_uploading = appDelegate.m_listArray_uploading;
    m_listArray_uploaded = appDelegate.m_listArray_uploaded;
    m_listArray_downloading = appDelegate.m_listArray_downloading;
    m_listArray_downloaded = appDelegate.m_listArray_downloaded;
    
    
    [self OnPrepare];*/
}
- (void)viewDidUnload
{
    //SevenCBoxClient::StopTaskMonitor();
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}
- (void)valueChanged:(id)sender {
    STSegmentedControl *control = sender;
    if (control.selectedSegmentIndex==0) {
        m_isUpload = YES;
    }
    else {
        m_isUpload = NO;
    }

    [self.m_tableView reloadData];
}
- (void)OnPrepare
{
    SevenCBoxClient::SetTaskViewNewTaskCallBack(CreateTaskList);
	SevenCBoxClient::SetTaskViewUpdateTaskCallBack(UpdateTaskList);
    SevenCBoxClient::StartTaskMonitor();
}
static void CreateTaskList(void* pTask)
{
    CTask* task = (CTask*)pTask;
	if (task->IsBackGround()) return;
    NSMutableDictionary *taskDic = [NSMutableDictionary dictionaryWithCapacity:0];
    [taskDic setObject:[NSString stringWithFormat:@"%d",task->GetTaskId()] forKey:@"taskId"];
    [taskDic setObject:[NSString stringWithCString:task->GetFileName() encoding:NSUTF8StringEncoding]  forKey:@"fileName"];
    [taskDic setObject:[NSString stringWithFormat:@"%d",task->GetTaskPercentage()]                     forKey:@"percentage"];
    [taskDic setObject:[NSString stringWithFormat:@"%f KB/S",task->GetTrransfSpeed()]                  forKey:@"speed"];
    [taskDic setObject:[NSString stringWithFormat:@"%d",task->IsUpload()]                              forKey:@"isUpload"];
    [taskDic setObject:[NSString stringWithFormat:@"%d",task->GetTaskState()]                          forKey:@"state"];
    
    [s_pv addListItem:taskDic isUpload:task->IsUpload() state:task->GetTaskState()];
}
//state任务状态0:停止,1:正在进行,2:暂停,3:完成
- (void)addListItem:(NSMutableDictionary *)taskItemStr isUpload:(bool)isUpload state:(int)state
{
    if (isUpload) {//上传
        if (state==0||state==1||state==2 ) {
            [m_listArray_uploading addObject:taskItemStr];
        }
        else if (state==3){
            [m_listArray_uploaded addObject:taskItemStr];
        }
        
    }
    else//下载
    {
        if (state==0||state==1||state==2 ) {
            [m_listArray_downloading addObject:taskItemStr];
        }
        else if (state==3){
            [m_listArray_downloaded addObject:taskItemStr];
        }
    }
 //   [m_tableView reloadData];
    
}
static void UpdateTaskList(void* pTask)
{
    CTask* task = (CTask*)pTask;
	if (task->IsBackGround()) return;
    NSMutableDictionary *taskDic = [NSMutableDictionary dictionaryWithCapacity:0];
    [taskDic setObject:[NSString stringWithFormat:@"%d",task->GetTaskId()] forKey:@"taskId"];
    [taskDic setObject:[NSString stringWithCString:task->GetFileName() encoding:NSUTF8StringEncoding]  forKey:@"fileName"];
    [taskDic setObject:[NSString stringWithFormat:@"%d",task->GetTaskPercentage()]                     forKey:@"percentage"];
    [taskDic setObject:[NSString stringWithFormat:@"%f KB/S",task->GetTrransfSpeed()]                  forKey:@"speed"];
    [taskDic setObject:[NSString stringWithFormat:@"%d",task->IsUpload()]                              forKey:@"isUpload"];
    [taskDic setObject:[NSString stringWithFormat:@"%d",task->GetTaskState()]                          forKey:@"state"];
    //NSLog(@"%@",taskDic.description);
    [s_pv updateListItem:taskDic isUpload:task->IsUpload()];
}
- (void)updateListItem:(NSMutableDictionary *)taskItemStr isUpload:(bool)isUpload
{
    if (m_isContinus==NO) {
        sleep(0.5);
        m_isContinus = YES;
    }
    if (isUpload) {//上传
        
        for (NSMutableDictionary *dic in m_listArray_uploading) {
            if ([[dic objectForKey:@"taskId"] intValue]==[[taskItemStr objectForKey:@"taskId"] intValue]) {
                [dic setObject:[taskItemStr objectForKey:@"percentage"] forKey:@"percentage"];
                [dic setObject:[taskItemStr objectForKey:@"state"]      forKey:@"state"];
                if ([[dic objectForKey:@"state"] intValue]==3) {
                    [dic setObject:[NSString stringWithFormat:@"%d",100] forKey:@"percentage"];
                    [m_listArray_uploaded addObject:dic];
                    [m_listArray_uploading removeObject:dic];
                    break;
                }
            }
        }
        
    }
    else//下载
    {
        for (NSMutableDictionary *dic in m_listArray_downloading) {
            if ([[dic objectForKey:@"taskId"] intValue]==[[taskItemStr objectForKey:@"taskId"] intValue]) {
                [dic setObject:[taskItemStr objectForKey:@"percentage"] forKey:@"percentage"];
                [dic setObject:[taskItemStr objectForKey:@"state"]      forKey:@"state"];
                if ([[dic objectForKey:@"state"] intValue]==3) {
                    [dic setObject:[NSString stringWithFormat:@"%d",100] forKey:@"percentage"];
                    [m_listArray_downloaded addObject:dic];
                    [m_listArray_downloading removeObject:dic];
                    break;
                }
            }
        }
    }
  //  [m_tableView reloadData];

}
- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    // Return YES for supported orientations
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}
- (IBAction)comeBack:(id)sender
{
    [self.navigationController popViewControllerAnimated:YES];
}
- (IBAction)allStart:(id)sender
{
    SevenCBoxClient::StartTaskMonitor();
    [m_tableView reloadData];
}
- (IBAction)allPause:(id)sender
{
    SevenCBoxClient::StopTaskMonitor();
    [m_tableView reloadData];
}
- (IBAction)allCancle:(id)sender
{
    
    
}
- (BOOL)isUpload
{
    BOOL isSwitchOn = YES;
    NSString *ttStr = [[NSUserDefaults standardUserDefaults]objectForKey:@"switch_flag"];
    if (ttStr==nil) {
        isSwitchOn = YES;
    }
    else
    {
        isSwitchOn = [ttStr boolValue];
    }
    
    BOOL isCurrentWifiCon  = [CheckConnectionKind IsWIFIConnection];//当前网络是否是WIFI
    if (isSwitchOn&&!isCurrentWifiCon) {
        
        
        [m_hud setCaption:@"当前网络非WIFI，请前往本软件“设置”进行修改。"];
        [m_hud setActivity:NO];
        [m_hud show];
        [m_hud hideAfter:1.5f];
        
        return NO;
    }
    return YES;
}
- (IBAction)uploadFromLib:(id)sender
{
    if (![self isUpload]) {
        return;
    }
    [self openAction];
/*    
#if TARGET_IPHONE_SIMULATOR
    
    
    
#elif TARGET_OS_IPHONE
    NSString *isFirstUse = [[NSUserDefaults standardUserDefaults]objectForKey:@"first_use"];
    if (isFirstUse==nil) {//首次运行，不需要检查是否开启定位服务
        [[NSUserDefaults standardUserDefaults]setObject:@"no first" forKey:@"first_use"];
        [[NSUserDefaults standardUserDefaults]synchronize];
        [self openAction];
        return;
    }
    if ([CLLocationManager locationServicesEnabled] && [CLLocationManager authorizationStatus] == kCLAuthorizationStatusAuthorized )  
    {  
        [self openAction];
    }  
    else  
    {  
        
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"请开启本软件定位服务"  
                                                        message: @"可进入系统“设置”-“定位服务” 开启 虹盘 定位服务"  
                                                       delegate: nil  
                                              cancelButtonTitle: @"确定"
                                              otherButtonTitles: nil];  
        
        [alert show]; 
        [alert release];
    } 

    
//#endif
    
    */
}

- (IBAction)uploadFromCamer:(id)sender
{
    if (![self isUpload]) {
        return;
    }
    [self showImagePicker:YES];
}
- (void)showImagePicker:(BOOL)hasCamera{
	imagePickerController = [[UIImagePickerController alloc] init];
    imagePickerController.delegate = self;
    
	if (hasCamera) 
		imagePickerController.sourceType = UIImagePickerControllerSourceTypeCamera;
	else
		imagePickerController.sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
	
    [self presentModalViewController:imagePickerController animated:YES];
    [imagePickerController release];
}
- (void)errorShow
{
    if ([CLLocationManager locationServicesEnabled] && [CLLocationManager authorizationStatus] == kCLAuthorizationStatusAuthorized )  
    {  
        
    }  
    else  
    {  
        NSString *msgTitle= nil;
        NSString *msgContent = nil;
        if ([[UIDevice currentDevice].systemVersion floatValue] >= 6.0)
        {
            msgTitle = @"请开启本软件授权服务";
            msgContent = @"可进入系统“设置”-“隐私”-“照片” 开启 虹盘的授权";
        }
        else
        {
            msgTitle = @"请开启本软定位权服务";
            msgContent = @"可进入系统“设置”-“定位服务” 开启 虹盘 定位服务";
        }
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:msgTitle 
                                                        message: msgContent 
                                                       delegate: nil  
                                              cancelButtonTitle: @"确定"
                                              otherButtonTitles: nil];  
        
        [alert show]; 
        [alert release];
    } 
}
- (void)openAction
{
    AGImagePickerController *imagePickerControllerAG = [[AGImagePickerController alloc] initWithFailureBlock:^(NSError *error) {
        
        NSLog(@"Fail. Error: %@", error);
        
        if (error == nil) {
            [self.selectedPhotos removeAllObjects];
            NSLog(@"hh-User has cancelled.");
            [self dismissModalViewControllerAnimated:YES];
        } else {
            [self performSelectorOnMainThread:@selector(errorShow) withObject:nil waitUntilDone:YES];
            // We need to wait for the view controller to appear first.
            double delayInSeconds = 0.5;
            dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, delayInSeconds * NSEC_PER_SEC);
            dispatch_after(popTime, dispatch_get_main_queue(), ^(void){
                [self dismissModalViewControllerAnimated:YES];
            });
        }
        
        [[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleDefault animated:YES];
        
    } andSuccessBlock:^(NSArray *info) {


        [self.selectedPhotos setArray:info];
       // [self performSelector:@selector(uploadFileMuti) withObject:nil afterDelay:0.1f];
        [self performSelectorInBackground:@selector(uploadFileMuti) withObject:nil];
        [self dismissModalViewControllerAnimated:YES];
        
        [[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleDefault animated:YES];
        
        [m_hud setCaption:@"正在上传图片"];
        [m_hud update];
        [m_hud setActivity:YES];
        [m_hud show];
        
       // [self performSelectorOnMainThread:@selector(showTub:) withObject:@"正在上传图片..." waitUntilDone:NO];
            }];
    
    // Show saved photos on top
    imagePickerControllerAG.shouldShowSavedPhotosOnTop = YES;
 //   imagePickerControllerAG.selection = self.selectedPhotos;
    
    // Custom toolbar items
    AGIPCToolbarItem *selectAll = [[AGIPCToolbarItem alloc] initWithBarButtonItem:[[[UIBarButtonItem alloc] initWithTitle:@"全选" style:UIBarButtonItemStyleBordered target:nil action:nil] autorelease] andSelectionBlock:^BOOL(NSUInteger index, ALAsset *asset) {
        return YES;
    }];
    AGIPCToolbarItem *flexible = [[AGIPCToolbarItem alloc] initWithBarButtonItem:[[[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace target:nil action:nil] autorelease] andSelectionBlock:nil]; 
    AGIPCToolbarItem *selectOdd = [[AGIPCToolbarItem alloc] initWithBarButtonItem:[[[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace target:nil action:nil] autorelease] andSelectionBlock:nil]; 
    
    AGIPCToolbarItem *deselectAll = [[AGIPCToolbarItem alloc] initWithBarButtonItem:[[[UIBarButtonItem alloc] initWithTitle:@"全不选" style:UIBarButtonItemStyleBordered target:nil action:nil] autorelease] andSelectionBlock:^BOOL(NSUInteger index, ALAsset *asset) {
        return NO;
    }];  
    imagePickerControllerAG.toolbarItemsForSelection = [NSArray arrayWithObjects:selectAll, flexible, selectOdd, flexible, deselectAll, nil];
    //    imagePickerController.toolbarItemsForSelection = [NSArray array];
    [selectOdd release];
    [flexible release];
    [selectAll release];
    [deselectAll release];
    
    //    imagePickerController.maximumNumberOfPhotos = 3;
    [self presentModalViewController:imagePickerControllerAG animated:YES];
    [imagePickerControllerAG release];
}
- (void)showTub:(NSString *)msg
{
    [m_hud setCaption:msg];
    [m_hud setActivity:YES];
    [m_hud show];
}

- (void)uploadFileMuti
{
 //   NSMutableArray *tempPaths=[NSMutableArray arrayWithCapacity:0];
    
    
    paths.clear();
    NSString *tempPath = [Function getTempCachePath];
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    NSLocale *locale = [[[NSLocale alloc] initWithLocaleIdentifier:@"en_US"] autorelease];
    [dateFormatter setLocale:locale];
    [dateFormatter setDateFormat:@"yyyyMMddHHmmss"];
    
    for( int i=0;i<[self.selectedPhotos count];i++ )
    {
@autoreleasepool {
        ALAsset *alAsset = [self.selectedPhotos objectAtIndex:i ];
      //  UIImage *image = [UIImage imageWithCGImage:[[alAsset defaultRepresentation] fullScreenImage]];//全屏图
        UIImage *image = [UIImage imageWithCGImage:[[alAsset defaultRepresentation] fullResolutionImage]];//高清图

        NSString * picType = [ [alAsset defaultRepresentation] UTI ] ;
        NSString *timeStr = [NSString stringWithFormat:@"%@%d",[dateFormatter stringFromDate:[NSDate date]],i];

        picType = [picType pathExtension];

        NSData *imagedata = nil;
        NSString *savedImagePath = nil;
        

        if ([picType isEqualToString:@"png"]) {
            imagedata=UIImagePNGRepresentation(image);
            savedImagePath=[tempPath stringByAppendingPathComponent:[NSString stringWithFormat:@"%@.png",timeStr]];
        }
        else if ([picType isEqualToString:@"gif"]){
            imagedata=UIImageJPEGRepresentation(image, 0);
            savedImagePath=[tempPath stringByAppendingPathComponent:[NSString stringWithFormat:@"%@.gif",timeStr]];
        }
        else {
            imagedata=UIImageJPEGRepresentation(image, 0);
            savedImagePath=[tempPath stringByAppendingPathComponent:[NSString stringWithFormat:@"%@.jpg",timeStr]];
        }
        [imagedata writeToFile:savedImagePath atomically:YES];
       
        
        string path([savedImagePath cStringUsingEncoding:NSUTF8StringEncoding]);
        paths.push_back(path);
        
        [m_hud setCaption:[NSString stringWithFormat:@"正在上传图片(%d/%d)",i+1,[self.selectedPhotos count]]];
        [m_hud update];
        [m_hud setActivity:YES];
 //   [tempPaths addObject:savedImagePath];
}
       
        
        
    }
    [dateFormatter release];
   
/*    tempPaths=[[NSUserDefaults standardUserDefaults] objectForKey:@"paths"];
    for(NSString *savedImagePath in tempPaths)
    {
        string path([savedImagePath cStringUsingEncoding:NSUTF8StringEncoding]);
        paths.push_back(path);
    }
    if ([tempPaths count]>0) {
        [self getUploadFmID];
    }*/
    if ([self.selectedPhotos count]>0) {
   //     [[NSUserDefaults standardUserDefaults]setObject:tempPaths forKey:@"paths"];
   //     [[NSUserDefaults standardUserDefaults]synchronize];
        [self getUploadFmID];
    }
}
- (void)getUploadFmID
{
    //查询iOS目录是否存在之前，先计算判断网盘空间是否够用
  //  scBox.FMOpenFolder("1",0,-1,callBackPhotoSubFunc,self);
    
    scBox.GetUsrSpace(callBackPhotoSpaceFunc,self);
}
- (void)makeIOSFm
{
    
}
#pragma mark - NDTaskCellDelegate Methods
- (void)removeTaskCell:(NDTaskCell *)cell
{
    int section = cell.m_indexPath.section;
    NSDictionary *cellDic = cell.m_dataDic;
    NSString *isUpload = [cellDic objectForKey:@"isUpload"];
    BOOL isB = [isUpload boolValue];
    if(isB)
    {
        if (section==0) {
            [m_listArray_uploading removeObject:cellDic];
        }
        else
        {
            [m_listArray_uploaded removeObject:cellDic];
        }
    }
    else
    {
        if (section==0) {
            [m_listArray_downloading removeObject:cellDic];
        }
        else
        {
            [m_listArray_downloaded removeObject:cellDic];
        }
    }
    
}

#pragma mark - UIImagePickerController Methods
- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingImage:(UIImage *)image editingInfo:(NSDictionary *)editingInfo
{
    [m_hud setCaption:@"正在上传图片..."];
    [m_hud setActivity:YES];
    [m_hud show];
    
	//[self performSelector:@selector(uploadCanerFile:) withObject:image afterDelay:0.1f];
    [self performSelectorInBackground:@selector(uploadCanerFile:)  withObject:image];
	[picker dismissModalViewControllerAnimated:YES];
//	[imagePickerController.view removeFromSuperview];
    
    
}
- (void)uploadCanerFile:(UIImage *)image
{
        //需要修改未temp目录下保存	
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    NSLocale *locale = [[[NSLocale alloc] initWithLocaleIdentifier:@"en_US"] autorelease];
    [dateFormatter setLocale:locale];
    [dateFormatter setDateFormat:@"yyyyMMddHHmmss"];
    NSString *timeStr = [dateFormatter stringFromDate:[NSDate date]];
    [dateFormatter release];
    
    NSData *imagedata=UIImagePNGRepresentation(image);
    
    NSString *savedImagePath=[[Function getTempCachePath] stringByAppendingPathComponent:[NSString stringWithFormat:@"%@.png",timeStr]];
    [imagedata writeToFile:savedImagePath atomically:YES];
    
    
    [self uploadPic:savedImagePath];
 //   [self performSelector:@selector(uploadPic:) withObject:savedImagePath afterDelay:0.0f];
}
- (void)uploadPic:(NSString *)theFileName
{
 /*   
    scBox.FmUpload([m_parentFID cStringUsingEncoding:NSUTF8StringEncoding], [theFileName cStringUsingEncoding:NSUTF8StringEncoding], "png",callBackPhotoUploadFunc,self);
  */
    paths.clear();
    string path([theFileName cStringUsingEncoding:NSUTF8StringEncoding]);
    paths.push_back(path);
    
    
    [self getUploadFmID];
}

- (void)imagePickerControllerDidCancel:(UIImagePickerController *)picker
{
	[picker dismissModalViewControllerAnimated:true];
}
#pragma mark - UITableViewDelegate Methods
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 50;
}

#pragma mark - UITableViewDataSource Methods

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{
	if (m_isUpload) {
        switch (section) {
            case 0:
                return @"未上传";
                break;
            case 1:
                return @"已上传";
                break;
                
            default:
                break;
        }
    }
    else{
        switch (section) {
            case 0:
                return @"未下载";
                break;
            case 1:
                return @"已下载";
                break;
                
            default:
                break;
        }
    }
    
	return nil;
    
}
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 2;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if (m_isUpload) {
        switch (section) {
            case 0:
                return [m_listArray_uploading count];
                break;
            case 1:
                return [m_listArray_uploaded count];
                break;
                
            default:
                return 0;
                break;
        }
    }
    else {
        switch (section) {
            case 0:
                return [m_listArray_downloading count];
                break;
            case 1:
                return [m_listArray_downloaded count];
                break;
                
            default:
                return 0;
                break;
        }
    }
    
    
}
- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    return 30;
}
- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
    
    NSString *sectionTitle = [self tableView:tableView titleForHeaderInSection:section];
    if (sectionTitle == nil) {
        return  nil;
    }
    
    UILabel * label = [[[UILabel alloc] init] autorelease];
    label.frame = CGRectMake(10, 0, 320, 30);
    label.backgroundColor = [UIColor clearColor];
    label.font=[UIFont fontWithName:@"Arial" size:14];
    label.textColor = [UIColor whiteColor];
    label.text = sectionTitle;
    
    UIView * sectionView = [[[UIView alloc] initWithFrame:CGRectMake(0, 0, tableView.bounds.size.width, 30)] autorelease];
    [sectionView setBackgroundColor:[UIColor colorWithPatternImage:[UIImage imageNamed:@"title_bg"]]];
    [sectionView addSubview:label];
    return sectionView;
}
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSInteger section = indexPath.section;
    NSInteger row = indexPath.row;
    static NSString *CellIdentifier = @"NDTaskCell";
    
    NDTaskCell *cell = (NDTaskCell *)[tableView dequeueReusableCellWithIdentifier:CellIdentifier];
	if (cell ==nil){
        NSArray *nib = [[NSBundle mainBundle] loadNibNamed:@"NDTaskCell" owner:self options:nil];
        cell = [nib objectAtIndex:0];
        cell.selectionStyle=UITableViewCellSelectionStyleNone;
        cell.delegate = self;
    }   
    NSDictionary *taskDic = nil;
    if (m_isUpload) {
        switch (section) {
            case 0:
                if (row>=[m_listArray_uploading count]) {
                    return cell;
                }
                taskDic=[m_listArray_uploading objectAtIndex:row];
                break;
            case 1:  
                if (row>=[m_listArray_uploaded count]) {
                    return cell;
                }
                taskDic=[m_listArray_uploaded objectAtIndex:row];
                break;
            default:
                break;
        }
    }
    else {
        switch (section) {
            case 0:
                if (row>=[m_listArray_downloading count]) {
                    return cell;
                }
                taskDic=[m_listArray_downloading objectAtIndex:row];
                break;
            case 1:    
                if (row>=[m_listArray_downloaded count]) {
                    return cell;
                }
                taskDic=[m_listArray_downloaded objectAtIndex:row];
                break;
            default:
                break;
        }
    }
    [cell setData:taskDic];
    cell.m_indexPath = indexPath;
    return cell;
}
#pragma mark - callBack Methods
void callBackPhotoFmMkdirFunc(Value &jsonValue,void *s_pv)
{
    
    string vall = jsonValue.toStyledString().c_str();
    NSString *vallStr = [NSString stringWithCString:vall.c_str() encoding:NSUTF8StringEncoding];
    [s_pv showFmMkdirView:vallStr];
}
void callBackPhotoSubFunc(Value &jsonValue,void *s_pv)
{
    string vall = jsonValue.toStyledString().c_str();
    NSString *vallStr = [NSString stringWithCString:vall.c_str() encoding:NSUTF8StringEncoding];
    [s_pv showMyView:vallStr];
}

void callBackPhotoUploadFunc(Value &jsonValue,void *s_pv)
{
    
    string vall = jsonValue.toStyledString().c_str();
    NSString *vallStr = [NSString stringWithCString:vall.c_str() encoding:NSUTF8StringEncoding];
    [s_pv uploadFileSucess:vallStr];
    
}
void callBackPhotoSpaceFunc(Value &jsonValue,void *s_pv)
{
    string vall = jsonValue.toStyledString().c_str();
    NSString *vallStr = [NSString stringWithCString:vall.c_str() encoding:NSUTF8StringEncoding];
    [s_pv showUserSpaceView:vallStr];
    /*
     int code = jsonValue["code"].asInt();
     if (code == 0) {
     string totalStr = jsonValue["space_total"].asCString();
     string usedStr = jsonValue["space_used"].asCString();
     [((NDSettingViewController *)s_pv).m_tableView reloadData];
     }
     else
     {
     
     }*/
}
#pragma mark - pri Methods
- (void)showFmMkdirView:(NSString *)theData
{
    
    NSDictionary *valueDic = [theData JSONValue];
    
    int code = [[valueDic objectForKey:@"code"]intValue];
    NSString *p_id = [Function covertNumberToString:[valueDic objectForKey:@"f_id"]];
    if (code==0) {
        [self uploadPhotos:p_id];
    }
    else{
        [m_hud setCaption:@"图片上传目录创建失败"];
        [m_hud setImage:[UIImage imageNamed:@"11-x"]];
        [m_hud setActivity:NO];
        [m_hud update];
        [self performSelectorOnMainThread:@selector(hiddenHub) withObject:nil waitUntilDone:NO];
    }
}
- (void)startUploadTimer
{
    NSTimeInterval timeInterval =5.0f ;
    m_timer_upload = [NSTimer scheduledTimerWithTimeInterval:timeInterval 
                                                      target:self
                                                    selector:@selector(uploadPhotos)
                                                    userInfo:nil 
                                                     repeats:NO]; 
}
- (void)showMyView:(NSString *)theData
{
    NSDictionary *valueDic = [theData JSONValue];
    
    int code = [[valueDic objectForKey:@"code"]intValue];
//    int total = [[valueDic objectForKey:@"total"]intValue];
    if (code==0) 
    {
        NSString *p_id = nil;
        NSArray *tArray = [valueDic objectForKey:@"files"];
        for(NSDictionary *dic in tArray){
            NSString *tFileName = [dic objectForKey:@"f_name"];
            if ([tFileName isEqualToString:@"iOS"]) {
                p_id = [Function covertNumberToString:[dic objectForKey:@"f_id"]];
             //   [[NSNotificationCenter defaultCenter] postNotificationName:ND_SEND_UPLOADPHOTOS object:p_id];
                [self uploadPhotos:p_id];
                break; 
            }
        }
        if (p_id==nil) {//新建文件夹iOS
            //[self performSelectorOnMainThread:@selector(createPhotosFm) withObject:nil waitUntilDone:NO];
            [self createPhotosFm];
        }
    }
    else {
        [m_hud setCaption:@"获取传输目录失败!"];
        [m_hud setImage:[UIImage imageNamed:@"11-x"]];
        [m_hud setActivity:NO];
        [m_hud update];
        [self performSelectorOnMainThread:@selector(hiddenHub) withObject:nil waitUntilDone:NO];
    }

    
}
- (void)uploadPhotos:(NSString *)sPID
{
  //  NSString *sPID = m_parentFID;
    scBox.FmUploadFiles([sPID cStringUsingEncoding:NSUTF8StringEncoding], paths, "png", callBackPhotoUploadFunc, self);
}
- (void)createPhotosFm
{
    scBox.FmMKdir("iOS","1",callBackPhotoFmMkdirFunc,self);
}
- (void)uploadFileSucess:(NSString *)theData
{
    NSDictionary *valueDic = [theData JSONValue];
    
    int code = [[valueDic objectForKey:@"code"]intValue];
    if (code == 0) {
        [m_hud setCaption:@"已加入上传队列"];
    }
    else{
        [m_hud setCaption:@"加入上传队列失败"];
    }
    [m_hud setActivity:NO];
    [m_hud update];
    [self performSelectorOnMainThread:@selector(hiddenHub) withObject:nil waitUntilDone:NO]; 
}
- (void)showUserSpaceView:(NSString *)theData
{
    NSDictionary *valueDic = [theData JSONValue];
    
    int code = [[valueDic objectForKey:@"code"]intValue];
    if (code==0) {
        double totalStr = [[valueDic objectForKey:@"space_total"] doubleValue];
        double usedStr = [[valueDic objectForKey:@"space_used"] doubleValue];
        
        double currentStr = [self getFilesSize];
        if (currentStr+usedStr<totalStr) {
            scBox.FMOpenFolder("1",0,-1,callBackPhotoSubFunc,self);
        }
        else{
            [m_hud setActivity:NO];
            [m_hud setCaption:@"网盘空间不足，无法上传！"];
            [m_hud update];
            [self performSelectorOnMainThread:@selector(hiddenHub) withObject:nil waitUntilDone:NO];
        }
    }
    else{
        [m_hud setActivity:NO];
        [m_hud setCaption:@"判断网盘空间失败，无法上传，请重试"];
        [m_hud setImage:[UIImage imageNamed:@"11-x"]];
        [m_hud update];
        [self performSelectorOnMainThread:@selector(hiddenHub) withObject:nil waitUntilDone:NO];
    }
    
    
}
- (void)hiddenHub
{
    [m_hud hideAfter:0.6f];
}
- (double)getFilesSize
{
    NSFileManager* manager = [NSFileManager defaultManager];  
    long long totalSize;
    totalSize = 0;
    
    for(vector<string>::size_type i = 0; i < paths.size(); ++i)
    {
        string path = paths[i];
        NSString *s_path = [NSString stringWithUTF8String:path.c_str()];
        if ([manager fileExistsAtPath:s_path]){  
            totalSize += [[manager attributesOfItemAtPath:s_path error:nil] fileSize];  
        }
    }
    
    return (double)totalSize;
}

@end
