//
//  NDPhotoViewController.m
//  NetDisk
//
//  Created by jiangwei on 12-12-10.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import "NDPhotoDetailViewController.h"
void callBackPhotoDetailFunc(Value &jsonValue,void *s_pv);
void callBackSubPicDownloadFunc(Value &jsonValue,void *s_pv);

@implementation NDPhotoDetailViewController
@synthesize m_tableView,m_timeLine,m_titleLabel,m_bottomView;
@synthesize m_title;
- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
        tableTag = 0;
    }
    return self;
}
- (void)dealloc
{
    [m_tableView release];
    [m_timeLine release];
    [m_title release];
    [m_titleLabel release];
    [m_hud release];
    [m_bottomView release];
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
    m_titleLabel.text = m_timeLine;
        
    CGRect tRect = CGRectMake(0, 44, 320, 368);
    m_tableView = [[BIDragRefreshTableView alloc]initWithFrame:tRect isHiddenBottomView:NO];
    m_tableView.isHiddenBottomView=NO;
    m_tableView.delegate = self;
    [m_tableView enableSectionSelected:YES];
    m_tableView.backgroundColor = [UIColor clearColor];
    [self.view addSubview:m_tableView];
    [m_tableView.dragRefreshTableView setSeparatorColor:[UIColor clearColor]];
    
    SevenCBoxClient::PhotoDetail([m_timeLine cStringUsingEncoding:NSUTF8StringEncoding], 0, GET_COUNT, callBackPhotoDetailFunc, self);
    
    m_hud = [[ATMHud alloc] initWithDelegate:self];
	[self.view addSubview:m_hud.view];

    [m_hud setCaption:@"正在获取..."];
    [m_hud setActivity:YES];
    [m_hud show];
    
    [self.view bringSubviewToFront:m_bottomView];
}

- (void)viewDidUnload
{
    [super viewDidUnload];
    
    
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

- (IBAction)refresh:(id)sender
{
    [m_hud setCaption:@"正在获取..."];
    [m_hud setActivity:YES];
    [m_hud show];
    
    tableTag = 0;
    SevenCBoxClient::PhotoDetail([m_timeLine cStringUsingEncoding:NSUTF8StringEncoding], 0, GET_COUNT, callBackPhotoDetailFunc, self);
}
- (IBAction)uploadFile:(id)sender
{  
    
    NDAppDelegate *appDelegate =  (NDAppDelegate *)[UIApplication sharedApplication].delegate;
    NDTaskManagerViewController *t_taskCont= appDelegate._taskMangeView;
    [self.navigationController pushViewController:t_taskCont animated:YES];
    t_taskCont.m_bottom_view.hidden = NO;
    t_taskCont.segment.hidden = YES;
    t_taskCont.segment.selectedSegmentIndex = 0;
    [t_taskCont valueChanged:t_taskCont.segment];
    t_taskCont.m_parentFID = @"1";//上传到根目录
}
- (IBAction)setting:(id)sender
{
    NDSettingViewController *_st = [[NDSettingViewController alloc] initWithNibName:@"NDSettingViewController" bundle:nil];
    [self.navigationController pushViewController:_st animated:YES];
    [_st release];
}

#pragma mark -
#pragma mark BILazyImageViewDelegate
- (void)lazyImageView:(BILazyImageView *)lazyImageView fileDic:(NSDictionary *)fileDic
{
    m_selectedImageDic =  fileDic;
    NSString *f_name = [m_selectedImageDic objectForKey:@"f_name"];
    NSNumber *daf =[m_selectedImageDic objectForKey:@"f_id"];
    string f_id = [[Function covertNumberToString:daf] cStringUsingEncoding:NSUTF8StringEncoding];
/*    UIActionSheet *as = [[UIActionSheet alloc] initWithTitle:f_name
                                                    delegate:self
                                           cancelButtonTitle:nil
                                      destructiveButtonTitle:nil
                                           otherButtonTitles:nil];
    as.delegate = self;
    NSString *imagePath=[[Function getImgCachePath] stringByAppendingPathComponent:f_name];
    if([Function fileSizeAtPath:imagePath]<2)
        [as addButtonWithTitle:NSLocalizedString(@"下 载",nil)];
    else
        [as addButtonWithTitle:NSLocalizedString(@"打开",nil)];
    [as addButtonWithTitle:NSLocalizedString(@"取 消",nil)];
    as.cancelButtonIndex = [as numberOfButtons] - 1;
    
    [as showInView:self.view];
    [as release];
 */
    NSString *imagePath=[[Function getImgCachePath] stringByAppendingPathComponent:f_name];
    if([Function fileSizeAtPath:imagePath]<2)
    {
        [m_hud setCaption:@"正在下载"];
        [m_hud setActivity:YES];
        [m_hud show];
        scBox.FmDownloadFile(f_id,[imagePath cStringUsingEncoding:NSUTF8StringEncoding],false,callBackSubPicDownloadFunc,self);
    }
    else
    {
        NSString *t_fl = [[m_selectedImageDic objectForKey:@"f_mime"] lowercaseString];
        if([t_fl isEqualToString:@"png"]||
           [t_fl isEqualToString:@"jpg"]||
           [t_fl isEqualToString:@"jpeg"]||
           [t_fl isEqualToString:@"bmp"])
        {
            ImageShowViewController *imageShow = [[ImageShowViewController alloc]initWithNibName:@"ImageShowViewController" bundle:nil];
            imageShow.picPath=imagePath;
            [self.navigationController pushViewController:imageShow animated:YES];
            [imageShow release];
        }
        else
        {
            [m_hud setCaption:NSLocalizedString(@"不提供此类文件预览",nil)];
            [m_hud setActivity:NO];
            [m_hud show];
            [m_hud hideAfter:0.8f];
        }
    }
    
}
#pragma mark - UIActionSheetDelegate Methods
- (void)actionSheet:(UIActionSheet *)as clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if (as.cancelButtonIndex == buttonIndex) {
        return;
    }
    
    NSString *f_name = [m_selectedImageDic objectForKey:@"f_name"];
    NSNumber *daf =[m_selectedImageDic objectForKey:@"f_id"];
    string f_id = [[Function covertNumberToString:daf] cStringUsingEncoding:NSUTF8StringEncoding];
    
    NSString *savedImagePath=[[Function getImgCachePath] stringByAppendingPathComponent:f_name];

    if([Function fileSizeAtPath:savedImagePath]<2)
    {
        [m_hud setCaption:@"正在下载"];
        [m_hud setActivity:YES];
        [m_hud show];
        scBox.FmDownloadFile(f_id,[savedImagePath cStringUsingEncoding:NSUTF8StringEncoding],false,callBackSubPicDownloadFunc,self);
    }
    else
    {
        NSString *t_fl = [[m_selectedImageDic objectForKey:@"f_mime"] lowercaseString];
        if([t_fl isEqualToString:@"png"]||
           [t_fl isEqualToString:@"jpg"]||
           [t_fl isEqualToString:@"jpeg"]||
           [t_fl isEqualToString:@"bmp"])
        {
            ImageShowViewController *imageShow = [[ImageShowViewController alloc]initWithNibName:@"ImageShowViewController" bundle:nil];
            imageShow.picPath=savedImagePath;
            [self.navigationController pushViewController:imageShow animated:YES];
            [imageShow release];
        }
        else
        {
            [m_hud setCaption:NSLocalizedString(@"不提供此类文件预览",nil)];
            [m_hud setActivity:NO];
            [m_hud show];
            [m_hud hideAfter:0.8f];
        }
    }
    
}

#pragma mark -
#pragma mark BIDragRefreshTableViewDelegate

-(void)refreshTableHeaderViewDataSourceDidStartLoad:(BIRefreshTableHeaderView *) refreshTableHeaderView{
    
    [m_hud setCaption:@"正在获取..."];
    [m_hud setActivity:YES];
    [m_hud show];

    if( m_listArray==nil||[m_listArray count]==0)
    {
        tableTag = 0;
        SevenCBoxClient::PhotoDetail([m_timeLine cStringUsingEncoding:NSUTF8StringEncoding], 0, GET_COUNT, callBackPhotoDetailFunc, self);
    }
    else
    {
        if (refreshTableHeaderView == m_tableView.headerView) {
            tableTag = 1;
            SevenCBoxClient::PhotoDetail([m_timeLine cStringUsingEncoding:NSUTF8StringEncoding], 0, GET_COUNT, callBackPhotoDetailFunc, self);
        }
        else if (refreshTableHeaderView == m_tableView.bottomView) {
            if( m_listArray==nil||[m_listArray count]==0){
                return;
            }
            tableTag = 2;
            SevenCBoxClient::PhotoDetail([m_timeLine cStringUsingEncoding:NSUTF8StringEncoding], [m_listArray count], GET_COUNT, callBackPhotoDetailFunc, self);
        }
    }
    

}
/*
 - (void)hiddenSearchCancelButton
 {
 
 [m_searchBar setText:@""];
 }*/
#pragma mark - UITableViewDelegate Methods
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    
    
    
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 90;
}
- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath
{
    return NO;
}
#pragma mark - UITableViewDataSource Methods
- (UITableViewCellEditingStyle)tableView:(UITableView *)tableView editingStyleForRowAtIndexPath:(NSIndexPath *)indexPath
{
	return  (UITableViewCellEditingStyle)(UITableViewCellEditingStyleDelete|UITableViewCellEditingStyleInsert); 
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{
    
    return nil;
	
}
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    
    if (m_listArray==nil||[m_listArray count]==0) {
        return 0;
    }
    
    int ji = [m_listArray count]/3;
    int yu = [m_listArray count]%3;
    
    return ji+(yu==0?0:1);       
}
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSInteger row = indexPath.row;
    static NSString *CellIdentifier = @"Cell";
    
    UITableViewCell *cell = (UITableViewCell *)[tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell ==nil){
        
        cell = [[UITableViewCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
        cell.accessoryType = UITableViewCellAccessoryNone;
        //cell.delegate = self;

        //cell.delegate = self;
        BILazyImageView *imageView = [[BILazyImageView alloc]initWithFrame:CGRectMake(20, 5, 80, 80)];
        imageView.tag = 1;
        imageView.delegate = self;
        imageView.contentMode=UIViewContentModeScaleAspectFit;
        [cell.contentView addSubview:imageView];
        [imageView release];
        
        UIImageView *flagView = [[UIImageView alloc]initWithFrame:CGRectMake(80, 45, 30, 30)];
        flagView.image = [UIImage imageNamed:@"login_check"];
        flagView.tag = 11;
        [cell.contentView addSubview:flagView];
        [flagView release];
        
        
        imageView = [[BILazyImageView alloc]initWithFrame:CGRectMake(120, 5, 80, 80)];
        imageView.tag = 2;
        imageView.delegate = self;
        imageView.contentMode=UIViewContentModeScaleAspectFit;
        [cell.contentView addSubview:imageView];
        [imageView release];
        
        flagView = [[UIImageView alloc]initWithFrame:CGRectMake(180, 45, 30, 30)];
        flagView.image = [UIImage imageNamed:@"login_check"];
        flagView.tag = 12;
        [cell.contentView addSubview:flagView];
        [flagView release];
        
        
        imageView = [[BILazyImageView alloc]initWithFrame:CGRectMake(220, 5, 80, 80)];
        imageView.tag = 3;
        imageView.delegate = self;
        imageView.contentMode=UIViewContentModeScaleAspectFit;
        [cell.contentView addSubview:imageView];
        [imageView release];
        
        flagView = [[UIImageView alloc]initWithFrame:CGRectMake(280, 45, 30, 30)];
        flagView.image = [UIImage imageNamed:@"login_check"];
        flagView.tag = 13;
        [cell.contentView addSubview:flagView];
        [flagView release];
    }
    UIImageView *flagImage1= (UIImageView *)[cell.contentView viewWithTag:11];
    flagImage1.hidden = YES;
    UIImageView *flagImage2= (UIImageView *)[cell.contentView viewWithTag:12];
    flagImage2.hidden = YES;
    UIImageView *flagImage3= (UIImageView *)[cell.contentView viewWithTag:13];
    flagImage3.hidden = YES;
    
    BILazyImageView *imageView1 = (BILazyImageView *)[cell.contentView viewWithTag:1];
    int rex1 = imageView1.tag-1+row*3;
    if (rex1<[m_listArray count]) {
        NSDictionary *pDic1 = [m_listArray objectAtIndex:rex1];
        imageView1.m_picDic = pDic1;
        if ([self isDownloadedImage:[pDic1 objectForKey:@"f_name"]]) {
            flagImage1.hidden = NO;
        }
    }
    
    BILazyImageView *imageView2 = (BILazyImageView *)[cell.contentView viewWithTag:2];
    int rex2 = imageView2.tag-1+row*3;
    if (rex2<[m_listArray count]) {
        NSDictionary *pDic2 = [m_listArray objectAtIndex:rex2];
        imageView2.m_picDic = pDic2;
        if ([self isDownloadedImage:[pDic2 objectForKey:@"f_name"]]) {
            flagImage2.hidden = NO;
        }
    }
    
    
    BILazyImageView *imageView3 = (BILazyImageView *)[cell.contentView viewWithTag:3];
    int rex3 = imageView3.tag-1+row*3;
    if (rex3<[m_listArray count]){
        NSDictionary *pDic3 = [m_listArray objectAtIndex:rex3];
        imageView3.m_picDic = pDic3;
        if ([self isDownloadedImage:[pDic3 objectForKey:@"f_name"]]) {
            flagImage3.hidden = NO;
        }
    }
    
    return cell;
}
- (BOOL)isDownloadedImage:(NSString *)theImageName
{
    NSString *filePath=[[Function getImgCachePath] stringByAppendingPathComponent:theImageName];
    if([Function fileSizeAtPath:filePath]>2)
    {
        return YES;
    }
    return NO;
}
#pragma mark -
#pragma mark CallBack Funtion
void callBackPhotoDetailFunc(Value &jsonValue,void *s_pv)
{
    
    string vall = jsonValue.toStyledString().c_str();
    NSString *vallStr = [NSString stringWithCString:vall.c_str() encoding:NSUTF8StringEncoding];
    NSLog(@"%@",vallStr);
    [s_pv showMyView:vallStr];
}
void callBackSubPicDownloadFunc(Value &jsonValue,void *s_pv)
{
    
    string vall = jsonValue.toStyledString().c_str();
    NSString *vallStr = [NSString stringWithCString:vall.c_str() encoding:NSUTF8StringEncoding];
    [s_pv downloadFileSucess:vallStr];
}
- (void)showMyView:(NSString *)theData
{

    NSDictionary *valueDic = [theData JSONValue];
    
    int code = [[valueDic objectForKey:@"code"]intValue];
    int total = [[valueDic objectForKey:@"total"] intValue];
    if (code==0&&total>0) {
        NSArray *tArray = [valueDic objectForKey:@"photos"];
        if (tableTag==0||tableTag==1) {
            [m_listArray release],m_listArray=nil;
            m_listArray = [[NSMutableArray alloc]initWithArray:tArray];
        }
        else
        {
            NSRange _range = NSMakeRange([m_listArray count], [tArray count]);
            NSIndexSet *set = [NSIndexSet indexSetWithIndexesInRange:_range];
            [m_listArray insertObjects:tArray atIndexes:set];
        }
    }
    else {
        [m_listArray release];
        m_listArray = nil;
    }
    [self.m_tableView reloadData];
    
    [m_tableView dataSourceDidFinishedLoad:m_tableView.headerView];
    
    if (code==0)
    {
    }    
    else
    {
        [m_hud setCaption:@"获取失败!"];
        [m_hud setImage:[UIImage imageNamed:@"11-x"]];
        [m_hud setActivity:NO];
        [m_hud update];
    }
    [m_tableView dataSourceDidFinishedLoad:m_tableView.headerView];
    [m_tableView dataSourceDidFinishedLoad:m_tableView.bottomView];
    [self performSelectorOnMainThread:@selector(hiddenHub) withObject:nil waitUntilDone:NO];
} 
- (void)downloadFileSucess:(NSString *)theData
{
    NSDictionary *valueDic = [theData JSONValue];
    
    int code = [[valueDic objectForKey:@"code"]intValue];
    if (code == 0) {
        //  [self performSelector:@selector(startTask) withObject:nil afterDelay:0.3f];
        [m_hud setCaption:@"已加入下载队列"];
    }
    else{
        [m_hud setCaption:@"加入下载对列失败"];
    }
    [m_hud setActivity:NO];
    [m_hud update];
    [self performSelectorOnMainThread:@selector(hiddenHub) withObject:nil waitUntilDone:NO];
}

- (void)hiddenHub
{
    [m_hud hideAfter:1.2f];
}
@end
