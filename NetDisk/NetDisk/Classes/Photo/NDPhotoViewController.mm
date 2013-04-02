//
//  NDPhotoViewController.m
//  NetDisk
//
//  Created by jiangwei on 12-12-10.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import "NDPhotoViewController.h"
void callBackPhotoTimelineFunc(Value &jsonValue,void *s_pv);

@implementation NDPhotoViewController
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
    
    CGRect tRect = CGRectMake(0, 44, 320, 370);
    m_tableView = [[BIDragRefreshTableView alloc]initWithFrame:tRect];
    m_tableView.delegate = self;
    [m_tableView enableSectionSelected:YES];
    m_tableView.backgroundColor = [UIColor clearColor];
    [self.view addSubview:m_tableView];
    [m_tableView.dragRefreshTableView setSeparatorColor:[UIColor clearColor]];
    
    SevenCBoxClient::PhotoTimeline(callBackPhotoTimelineFunc,self);
    m_hud = [[ATMHud alloc] initWithDelegate:self];
	[self.view addSubview:m_hud.view];
    
    [m_hud setCaption:@"正在获取..."];
    [m_hud setActivity:YES];
    [m_hud show];
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
#pragma mark BIDragRefreshTableViewDelegate

-(void)refreshTableHeaderViewDataSourceDidStartLoad:(BIRefreshTableHeaderView *) refreshTableHeaderView{
    
    SevenCBoxClient::PhotoTimeline(callBackPhotoTimelineFunc,self);
    [m_hud setCaption:@"正在获取..."];
    [m_hud setActivity:YES];
    [m_hud show];
 /*   if (m_editButton.selected) { 
        [m_tableView dataSourceDidFinishedLoad:m_tableView.headerView];
        return ;
    }
    
 //   [self performSelector:@selector(hiddenSearchCancelButton) withObject:nil afterDelay:0.01f];
    
 //   [self getFileDataFromServer];*/
}
/*
- (void)hiddenSearchCancelButton
{
    
    [m_searchBar setText:@""];
}*/
#pragma mark - UITableViewDelegate Methods
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    
    NDPhotoDetailViewController *pdv=[[NDPhotoDetailViewController alloc]initWithNibName:@"NDPhotoDetailViewController" bundle:nil];
    pdv.m_timeLine = [m_listArray objectAtIndex:indexPath.row];
    [self.navigationController pushViewController:pdv animated:YES];
    [pdv release];
    
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 50;
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
    
    return [m_listArray count];    
}
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSInteger row = indexPath.row;
    static NSString *CellIdentifier = @"Cell";
        
    UITableViewCell *cell = (UITableViewCell *)[tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell ==nil){
    
        cell = [[UITableViewCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
        cell.selectionStyle = UITableViewCellSelectionStyleBlue;
        cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
        
        UIImageView *imageView = [[UIImageView alloc]initWithFrame:CGRectMake(10, 5, 40, 40)];
        imageView.image = [UIImage imageNamed:@"icon_Folder"];
        [cell.contentView addSubview:imageView];
        [imageView release];
        
        UIImageView *limageView = [[UIImageView alloc]initWithFrame:CGRectMake(0, 48, 320, 2)];
        limageView.image = [UIImage imageNamed:@"list_line"];
        [cell.contentView addSubview:limageView];
        [limageView release];
        
        UILabel *yearLabel = [[UILabel alloc]initWithFrame:CGRectMake(60, 15, 230, 20)];
    //    yearLabel.font = [UIFont systemFontOfSize:13.0f];
        yearLabel.tag = 1;
        yearLabel.backgroundColor = [UIColor clearColor];
        [cell.contentView addSubview:yearLabel];
        [yearLabel release];
    }
    
    UILabel *myLabel = (UILabel *)[cell.contentView viewWithTag:1];
    myLabel.text = [m_listArray objectAtIndex:row];

    return cell;
}
#pragma mark -
#pragma mark CallBack Funtion
void callBackPhotoTimelineFunc(Value &jsonValue,void *s_pv)
{
    
    string vall = jsonValue.toStyledString();
    printf("%s",vall.c_str());
    NSString *vallStr = [NSString stringWithCString:vall.c_str() encoding:NSUTF8StringEncoding];
    NSLog(@"%@",vallStr);
    [s_pv showMyView:vallStr];
}
- (void)showMyView:(NSString *)theData
{
    NSDictionary *valueDic = [theData JSONValue];
    NSLog(@"%@",valueDic);
    int code = [[valueDic objectForKey:@"code"]intValue];
    NSString *timeString = [valueDic objectForKey:@"timeline"];
    NSLog(@"%@",timeString);
    if (code==0&&timeString!=nil) {
        @try {
            Function *fun = [[Function alloc]init];
            NSArray *tArray = [self parseTimeLine:[NSString stringWithString:timeString]];
            [m_listArray release];
            m_listArray = [tArray retain];
            //      [m_listSourceArray release];
            //      m_listSourceArray = [tArray retain];
            //      counts = [m_listArray count];
        }
        @catch (NSException *exception) {
            CFShow(exception);
        }
        @finally {
            
        }
        
       
        
    }
    else {
        [m_listArray release];
        m_listArray = nil;
  //      counts = 0;
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
	
    [self performSelectorOnMainThread:@selector(hiddenHub) withObject:nil waitUntilDone:NO];
} 
- (NSMutableArray *)parseTimeLine:(NSString *)timeStr
{
    NSLog(@"fasfasdfasf");
    NSString *perfix= [NSString stringWithString:@"[20"];
    NSString *suffix= [NSString stringWithString:@"]]"];
    
    NSMutableArray *timeList = [NSMutableArray arrayWithCapacity:0];
    NSMutableString *sourceStr = [NSMutableString stringWithString:timeStr];
    
    while (1) {
        NSRange perRang = [sourceStr rangeOfString:perfix];
        if (perRang.location==NSNotFound) {
            break;
        }
        NSRange sufRang = [sourceStr rangeOfString:suffix];
        NSString *temp = [sourceStr substringWithRange:NSMakeRange(perRang.location, sufRang.location+sufRang.length)];
        NSMutableString *subSourceStr = [NSMutableString stringWithString:temp];
        NSString *year = [subSourceStr substringWithRange:NSMakeRange(perRang.location+1, 4)];
        subSourceStr = [NSMutableString stringWithString:[subSourceStr substringFromIndex:6]];
        
        NSString *subPerfix = @"[";
        NSString *subSuffix = @"]";
        NSRange subPerRang = [subSourceStr rangeOfString:subPerfix];
        NSRange subSufRang = [subSourceStr rangeOfString:subSuffix];
        if (subPerRang.location==NSNotFound) {
            break;
        }
        NSString *subTemp = [subSourceStr substringWithRange:NSMakeRange(subPerRang.location+1,subSufRang.location-1)];
        NSArray *subArray = [subTemp componentsSeparatedByString:@","];
        for(int i=0;i<[subArray count];i++)
        {
            NSString *month = [subArray objectAtIndex:i];
            [timeList addObject:[NSString stringWithFormat:@"%@-%@",year,month]];
        }
        
        if ([sourceStr length]>sufRang.location+sufRang.length+10) {
            sourceStr = [NSMutableString stringWithString:[sourceStr substringFromIndex:sufRang.location+3]];
        }
        else{
            break;
        }
        
        
    }
    return timeList;
}
- (void)hiddenHub
{
    [m_hud hideAfter:1.2f];
}
@end
