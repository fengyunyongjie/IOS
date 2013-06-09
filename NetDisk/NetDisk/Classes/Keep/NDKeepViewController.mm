//
//  NDKeepViewController.m
//  NetDisk
//
//  Created by jiangwei on 12-11-12.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import "NDKeepViewController.h"

@implementation NDKeepViewController
@synthesize m_tableView;
- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}
- (void)dealloc
{
    [m_hud release];
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
    m_tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    
    self.navigationItem.title = @"我的收藏";
    
    [self moveItemToFinshed];
    
    m_hud = [[ATMHud alloc] initWithDelegate:self];
	[self.view addSubview:m_hud.view];

}
- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [self startTimer];
    
}
- (void)startTimer
{
    NSTimeInterval timeInterval =2.0f ;
    m_timer = [NSTimer scheduledTimerWithTimeInterval:timeInterval 
                                               target:self
                                             selector:@selector(moveItemToFinshed)
                                             userInfo:nil 
                                              repeats:YES];
}
- (void)stopTimer
{
    if ([m_timer isValid]) {
        [m_timer invalidate];
    }
}
- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    [self stopTimer];
}
-(void)moveItemToFinshed
{
    NSMutableIndexSet *moveIndexSet = [[NSMutableIndexSet alloc] init];
    [m_keeped_listArray release];
    [m_keeping_listArray release];
    m_keeped_listArray = [[NSMutableArray arrayWithArray:[[NSUserDefaults standardUserDefaults] objectForKey:@"nd_keeped_list"]] retain];
    m_keeping_listArray = [[NSMutableArray arrayWithArray:[[NSUserDefaults standardUserDefaults] objectForKey:@"nd_keeping_list"]] retain];
    for (int i=0; i<[m_keeping_listArray count]; i++) {
        NSDictionary *dic = [m_keeping_listArray objectAtIndex:i];
        NSString *f_name = [dic objectForKey:@"f_name"];
        NSString *savedImagePath=[[Function getKeepCachePath] stringByAppendingPathComponent:f_name];
        NSString *tempPath=[[Function getImgCachePath] stringByAppendingPathComponent:f_name];
     /*   UIAlertView *al = [[UIAlertView alloc]initWithTitle:savedImagePath message:nil delegate:nil cancelButtonTitle:nil otherButtonTitles:nil, nil];
        [al show];*/
        if([Function fileSizeAtPath:savedImagePath]>2 || [Function fileSizeAtPath:tempPath]>2){
            [moveIndexSet addIndex:i];
            [m_keeped_listArray insertObject:dic atIndex:0];
        }
    }
    if ([moveIndexSet count]>0) {
        [m_keeping_listArray removeObjectsAtIndexes:moveIndexSet];
        
        [[NSUserDefaults standardUserDefaults] setObject:m_keeped_listArray forKey:@"nd_keeped_list"];
        [[NSUserDefaults standardUserDefaults] setObject:m_keeping_listArray forKey:@"nd_keeping_list"];
        [[NSUserDefaults standardUserDefaults] synchronize];
        
        [m_tableView reloadData];
    }

    [moveIndexSet removeAllIndexes],[moveIndexSet release],moveIndexSet=nil;
}

- (void)viewDidUnload
{
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
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

#pragma mark - UITableViewDelegate Methods
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.section==1) {
        NSDictionary *dic = [m_keeped_listArray objectAtIndex:indexPath.row];
        NSString *f_name = [dic objectForKey:@"f_name"];
        
        NSString *savedImagePath=[[Function getKeepCachePath] stringByAppendingPathComponent:f_name];
        NSString *tempImagePath=[[Function getImgCachePath] stringByAppendingPathComponent:f_name];
        if([Function fileSizeAtPath:savedImagePath]<2 && [Function fileSizeAtPath:tempImagePath]<2)
        {
            [m_hud setCaption:@"文件不存在，请重新收藏"];
            [m_hud setActivity:YES];
            [m_hud show];
            
        }
        else
        {
            NSString *t_fl = [[dic objectForKey:@"f_mime"] lowercaseString];
            if([t_fl isEqualToString:@"png"]||
               [t_fl isEqualToString:@"jpg"]||
               [t_fl isEqualToString:@"jpeg"]||
               [t_fl isEqualToString:@"bmp"])
            {
                NSLog(@"选中的是图片文件，所有直接进入图片预览！！！！,index=%d,count=%d",indexPath.row,m_keeped_listArray.count);
                //NSString *savedImagePath=[[Function getImgCachePath] stringByAppendingPathComponent:f_name];
                ImageShowViewController *imageShow = [[ImageShowViewController alloc]initWithNibName:@"ImageShowViewController" bundle:nil];
                imageShow.picPath=savedImagePath;
                imageShow.m_index=indexPath.row;
                imageShow.m_listArray=m_keeped_listArray;
                [self.navigationController pushViewController:imageShow animated:YES];
                [imageShow release];
            }
            else
            {
                [m_hud setCaption:NSLocalizedString(@"不提供此类文件预览",nil)];
                [m_hud setActivity:NO];
                [m_hud show];
                
            }
        }
        [m_hud hideAfter:0.8f];
    }
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 50;
}
#pragma mark - UITableViewDataSource Methods
- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{
	switch (section) {
        case 0:
            return [NSString stringWithFormat:@"%d个文件正在云端下载中...",[m_keeping_listArray count]];
            break;
        case 1:
            return [NSString stringWithFormat:@"已成功收藏%d个文件",[m_keeped_listArray count]];
            break;
        default:
            return nil;
            break;
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
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 2;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    switch (section) {
        case 0:
            return m_keeping_listArray==nil?0:[m_keeping_listArray count];
            break;
        case 1:
            return m_keeped_listArray==nil?0:[m_keeped_listArray count];;
            break;
        default:
            return 0;
            break;
    }
    
}
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSInteger section = indexPath.section;
    NSInteger row = indexPath.row;
    static NSString *CellIdentifier = @"Cell";
    
    NDKeepCell *cell = (NDKeepCell *)[tableView dequeueReusableCellWithIdentifier:CellIdentifier];
	if (cell ==nil){
		NSArray *nib = [[NSBundle mainBundle] loadNibNamed:@"NDKeepCell" owner:self options:nil];
		cell = [nib objectAtIndex:0];
		cell.selectionStyle=UITableViewCellSelectionStyleNone;
        cell.accessoryType = UITableViewCellAccessoryNone;
		cell.delegate = self;
	}
    NSDictionary *dic = nil;
    if (section==0) {
        dic = [m_keeping_listArray objectAtIndex:row];
    }
    else{
        dic = [m_keeped_listArray objectAtIndex:row];
    }
    [cell setData:indexPath dataDic:dic];
    
    
    
    return cell;
}
#pragma mark - NDKeepCellDelegate Methods
- (void)removeKeepCell:(NDKeepCell *)cell
{
    [self stopTimer];
    
    int section = cell.m_indexPath.section;
    int row = cell.m_indexPath.row;
    switch (section) {
        case 0:
        {
            [m_keeping_listArray removeObjectAtIndex:row];
            [[NSUserDefaults standardUserDefaults] setObject:m_keeping_listArray forKey:@"nd_keeping_list"];
            [[NSUserDefaults standardUserDefaults] synchronize];
        }
            break;
        case 1:
        {
            NSDictionary *rDic = [m_keeped_listArray objectAtIndex:row];
            NSString *f_name = [rDic objectForKey:@"f_name"];
            NSString *removeImagePath=[[Function getKeepCachePath] stringByAppendingPathComponent:f_name];
            [[NSFileManager defaultManager] removeItemAtPath:removeImagePath error:nil];
            [m_keeped_listArray removeObjectAtIndex:row];
            [[NSUserDefaults standardUserDefaults] setObject:m_keeped_listArray forKey:@"nd_keeped_list"];
            [[NSUserDefaults standardUserDefaults] synchronize];
        }
            break;
        default:
            break;
    }
    [m_hud setCaption:@"操作成功"];
    [m_hud setActivity:NO];
    [m_hud show];
    [m_hud hideAfter:0.5f];
    
    [m_tableView reloadData];
    [self performSelector:@selector(startTimer) withObject:nil afterDelay:0.2f];
}
@end
