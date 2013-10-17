//
//  EmailListViewController.m
//  ndspro
//
//  Created by fengyongning on 13-10-9.
//  Copyright (c) 2013年 fengyongning. All rights reserved.
//

#import "EmailListViewController.h"
#import "SCBEmailManager.h"
#import "MBProgressHUD.h"
#import "YNFunctions.h"
#import "EmailDetailViewController.h"


@interface EmailListViewController ()<SCBEmailManagerDelegate,UIAlertViewDelegate,UIActionSheetDelegate>
@property (strong,nonatomic) SCBEmailManager *em;
@property(strong,nonatomic) MBProgressHUD *hud;
@property(strong,nonatomic) UISegmentedControl *segmentedControl;
@end

@implementation EmailListViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}
- (void)viewDidAppear:(BOOL)animated
{
    CGRect r=self.view.frame;
    r.size.height=[[UIScreen mainScreen] bounds].size.height-r.origin.y;
    self.view.frame=r;
    self.tableView.frame=CGRectMake(0, 0, self.view.frame.size.width, self.view.frame.size.height-49);
}
- (void)viewDidLoad
{
    [super viewDidLoad];
    if ([self respondsToSelector:@selector(setEdgesForExtendedLayout:)]) {
        [self setEdgesForExtendedLayout:UIRectEdgeNone];
    }
    // Do any additional setup after loading the view from its nib.
    self.tableView=[[UITableView alloc] init];
    self.tableView.delegate=self;
    self.tableView.dataSource=self;
    [self.view addSubview:self.tableView];
    self.tableView.frame=CGRectMake(0, 0, self.view.frame.size.width, self.view.frame.size.height);
    self.segmentedControl=[[UISegmentedControl alloc] initWithItems:@[@"收件箱",@"发件箱"]];
    self.segmentedControl.frame=CGRectMake(10, 8, 300, 29);
    [self.segmentedControl setTintColor:[UIColor whiteColor]];
    [self.segmentedControl addTarget:self action:@selector(segmentAction:) forControlEvents:UIControlEventValueChanged];
    [self.navigationItem setTitleView:self.segmentedControl];
    [self.segmentedControl setSelectedSegmentIndex:0];
    
    if (_refreshHeaderView==nil) {
        EGORefreshTableHeaderView *view = [[EGORefreshTableHeaderView alloc] initWithFrame:CGRectMake(0.0f, 0.0f - self.tableView.bounds.size.height, self.view.frame.size.width, self.tableView.bounds.size.height)];
		view.delegate = self;
		[self.tableView addSubview:view];
		_refreshHeaderView = view;
    }
    [_refreshHeaderView refreshLastUpdatedDate];
}
-(void)viewWillAppear:(BOOL)animated
{
    [self updateEmailList];
}
- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
#pragma mark -
#pragma mark Data Source Loading / Reloading Methods

- (void)reloadTableViewDataSource{
	
	//  should be calling your tableviews data source model to reload
	//  put here just for demo
	_reloading = YES;
    [self updateEmailList];
}

- (void)doneLoadingTableViewData{
	
	//  model should call this when its done loading
	_reloading = NO;
	[_refreshHeaderView egoRefreshScrollViewDataSourceDidFinishedLoading:self.tableView];
	
}
#pragma mark -
#pragma mark EGORefreshTableHeaderDelegate Methods

- (void)egoRefreshTableHeaderDidTriggerRefresh:(EGORefreshTableHeaderView*)view{
	
	[self reloadTableViewDataSource];
    //	[self performSelector:@selector(doneLoadingTableViewData) withObject:nil afterDelay:3.0];
	
}

- (BOOL)egoRefreshTableHeaderDataSourceIsLoading:(EGORefreshTableHeaderView*)view{
	
	return _reloading; // should return if data source model is reloading
	
}

- (NSDate*)egoRefreshTableHeaderDataSourceLastUpdated:(EGORefreshTableHeaderView*)view{
	
	return [NSDate date]; // should return date data source was last changed
	
}
#pragma mark - 操作方法
- (void)updateEmailList
{
    //加载本地缓存文件
    NSString *dataFilePath=[YNFunctions getDataCachePath];
    dataFilePath=[dataFilePath stringByAppendingPathComponent:[YNFunctions getFileNameWithFID:@"EmailList"]];
    if ([[NSFileManager defaultManager] fileExistsAtPath:dataFilePath])
    {
        NSError *jsonParsingError=nil;
        NSData *data=[NSData dataWithContentsOfFile:dataFilePath];
        self.dataDic=[NSJSONSerialization JSONObjectWithData:data options:0 error:&jsonParsingError];
        if (self.dataDic) {
            NSArray *emails=(NSArray *)[self.dataDic objectForKey:@"emails"];
            NSMutableArray *tempInArray=[NSMutableArray array];
            NSMutableArray *tempOutArray=[NSMutableArray array];
            for (NSDictionary *dic in emails)
            {
                int etype=[[dic objectForKey:@"etype"] intValue];
                //etype	邮件类型	String，0为收件箱，1为发件箱
                if (etype ==0) {
                    [tempInArray addObject:dic];
                }else if(etype==1)
                {
                    [tempOutArray addObject:dic];
                }else
                {
                    NSLog(@"邮件类型出错：%d",etype);
                }
            }
            self.inArray=tempInArray;
            self.outArray=tempOutArray;
            [self.tableView reloadData];
        }
    }

    [self.em cancelAllTask];
    self.em=nil;
    self.em=[[SCBEmailManager alloc] init];
    [self.em setDelegate:self];
//    if (self.segmentedControl.selectedSegmentIndex==0) {
//        [self.em listEmailWithType:@"0"];
//    }else
//    {
//        [self.em listEmailWithType:@"1"];
//    }
    [self.em listEmailWithType:@"2"];
}
-(void)segmentAction:(UISegmentedControl *)seg
{
    [self updateEmailList];
}
#pragma mark - Table view data source
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if (self.segmentedControl.selectedSegmentIndex==0) {
        //收件箱
        if (self.inArray) {
            return self.inArray.count;
        }
    }else
    {
        //发件箱
        if (self.outArray) {
            return self.outArray.count;
        }
    }
    return 1;
}
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"Cell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle
                                      reuseIdentifier:CellIdentifier];
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
        cell.accessoryType=UITableViewCellAccessoryDisclosureIndicator;
        
        UIImageView *unread_tag=[[UIImageView alloc] initWithFrame:CGRectMake(10, 10, 10, 10)];
        UILabel *lab_role=[[UILabel alloc] initWithFrame:CGRectMake(30, 4, 150, 21)];
        UILabel *lab_title=[[UILabel alloc] initWithFrame:CGRectMake(30, 24, 150, 21)];
        UILabel *lab_time=[[UILabel alloc] initWithFrame:CGRectMake(190, 4, 130, 21)];
        UILabel *lab_econtent=[[UILabel alloc] initWithFrame:CGRectMake(30, 44, 270, 55)];
        [cell.contentView addSubview:lab_role];
        [cell.contentView addSubview:lab_title];
        [cell.contentView addSubview:lab_time];
        [cell.contentView addSubview:lab_econtent];
        [cell.contentView addSubview:unread_tag];
        
        [lab_role setFont:[UIFont boldSystemFontOfSize:16]];
        [lab_title setFont:[UIFont systemFontOfSize:14]];
        [lab_econtent setFont:[UIFont systemFontOfSize:14]];
        [lab_time setFont:[UIFont systemFontOfSize:13]];
        
        [lab_econtent setTextColor:[UIColor grayColor]];
        [lab_time setTextColor:[UIColor grayColor]];
        
        [lab_econtent setNumberOfLines:0];
        
        
        
        
        unread_tag.tag=1;
        lab_role.tag=2;
        lab_title.tag=3;
        lab_time.tag=4;
        lab_econtent.tag=5;
    }
    UIImageView *unread_tag=(UIImageView *)[cell.contentView viewWithTag:1];
    UILabel *lab_role=(UILabel *)[cell.contentView viewWithTag:2];
    UILabel *lab_title=(UILabel *)[cell.contentView viewWithTag:3];
    UILabel *lab_time=(UILabel *)[cell.contentView viewWithTag:4];
    UILabel *lab_econtent=(UILabel *)[cell.contentView viewWithTag:5];
    NSDictionary *dic;
    if (self.segmentedControl.selectedSegmentIndex==0) {
        //收件箱
        if (self.inArray) {
            dic=[self.inArray objectAtIndex:indexPath.row];
            if (dic) {
                NSString *sender=(NSString *)[dic objectForKey:@"sender"];
                 if (![sender isKindOfClass:NSClassFromString(@"NSNull")]) {
                    lab_role.text=sender;
                }else
                {
                    lab_role.text=@"";
                }
                
            }
        }
    }else
    {
        //发件箱
        if (self.outArray) {
            dic=[self.outArray objectAtIndex:indexPath.row];
            if (dic) {
                NSString *sender=(NSString *)[dic objectForKey:@"receivelist"];
                if (![sender isKindOfClass:NSClassFromString(@"NSNull")]) {
                    lab_role.text=sender;
                }else
                {
                    lab_role.text=@"";
                }
            }
        }
    }
    if (dic) {
//        cell.textLabel.text=[dic objectForKey:@"etitle"];
//        cell.detailTextLabel.text=[dic objectForKey:@"sendtime"];
        lab_title.text=[dic objectForKey:@"etitle"];
        if ([lab_title.text isEqualToString:@""]) {
            lab_title.text=@"无主题";
        }
        lab_econtent.text=[dic objectForKey:@"econtent"];
        if ([lab_econtent.text isEqualToString:@""]) {
            lab_econtent.text=@"此邮件中无内容";
        }
        lab_time.text=[dic objectForKey:@"sendtime"];
        
        int readstate=-1;
        readstate=[[dic objectForKey:@"readstate"] intValue];
        if (readstate==0) {
//            cell.imageView.image=[UIImage imageNamed:@"mail_unread.png"];
            unread_tag.image=[UIImage imageNamed:@"mail_unread.png"];
        }else
        {
//            cell.imageView.image=[UIImage imageNamed:@"mail_readed.png"];
            unread_tag.image=[UIImage imageNamed:@"mail_readed.png"];
        }
    }
    return cell;
}
-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 100;
}

#pragma mark - Table view delegate
- (void)tableView:(UITableView *)tableView accessoryButtonTappedForRowWithIndexPath:(NSIndexPath *)indexPath
{
//    self.selectedIndexPath=indexPath;
//    [self toMore:self];
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSDictionary *dic;
    if (self.segmentedControl.selectedSegmentIndex==0) {
        //收件箱
        if (self.inArray) {
            dic=[self.inArray objectAtIndex:indexPath.row];
        }
    }else
    {
        //发件箱
        if (self.outArray) {
            dic=[self.outArray objectAtIndex:indexPath.row];
        }
    }
    if (dic) {
        NSString *eid=[dic objectForKey:@"eid"];
        NSString *etype=[dic objectForKey:@"etype"];
        EmailDetailViewController *edvc=[[EmailDetailViewController alloc] init];
        edvc.eid=eid;
        edvc.etype=etype;
        edvc.title=[dic objectForKey:@"etitle"];
        [self.navigationController pushViewController:edvc animated:YES];
    }

}


#pragma mark - Deferred image loading (UIScrollViewDelegate)
- (void)scrollViewDidScroll:(UIScrollView *)scrollView{
	
	[_refreshHeaderView egoRefreshScrollViewDidScroll:scrollView];
}
- (void)scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate
{
    [_refreshHeaderView egoRefreshScrollViewDidEndDragging:scrollView];
}


#pragma mark - SCBEmailManagerDelegate
-(void)listEmailSucceed:(NSDictionary *)datadic
{
    self.dataDic=datadic;
    if (self.dataDic) {
        NSArray *emails=(NSArray *)[self.dataDic objectForKey:@"emails"];
        NSMutableArray *tempInArray=[NSMutableArray array];
        NSMutableArray *tempOutArray=[NSMutableArray array];
        for (NSDictionary *dic in emails)
        {
            int etype=[[dic objectForKey:@"etype"] intValue];
            //etype	邮件类型	String，0为收件箱，1为发件箱
            if (etype ==0) {
                [tempInArray addObject:dic];
            }else if(etype==1)
            {
                [tempOutArray addObject:dic];
            }else
            {
                NSLog(@"邮件类型出错：%d",etype);
            }
        }
        self.inArray=tempInArray;
        self.outArray=tempOutArray;
        [self doneLoadingTableViewData];
        [self.tableView reloadData];

        NSString *dataFilePath=[YNFunctions getDataCachePath];
        dataFilePath=[dataFilePath stringByAppendingPathComponent:[YNFunctions getFileNameWithFID:@"EmailList"]];
        
        NSError *jsonParsingError=nil;
        NSData *data=[NSJSONSerialization dataWithJSONObject:self.dataDic options:0 error:&jsonParsingError];
        BOOL isWrite=[data writeToFile:dataFilePath atomically:YES];
        if (isWrite) {
            NSLog(@"写入文件成功：%@",dataFilePath);
        }else
        {
            NSLog(@"写入文件失败：%@",dataFilePath);
        }
    }else
    {
        [self updateEmailList];
    }
    NSLog(@"openFinderSucess:");
//    if (self.dataDic)
//    {
//        NSString *dataFilePath=[YNFunctions getDataCachePath];
//        dataFilePath=[dataFilePath stringByAppendingPathComponent:[YNFunctions getFileNameWithFID:self.f_id]];
//        
//        NSError *jsonParsingError=nil;
//        NSData *data=[NSJSONSerialization dataWithJSONObject:self.dataDic options:0 error:&jsonParsingError];
//        BOOL isWrite=[data writeToFile:dataFilePath atomically:YES];
//        if (isWrite) {
//            NSLog(@"写入文件成功：%@",dataFilePath);
//        }else
//        {
//            NSLog(@"写入文件失败：%@",dataFilePath);
//        }
//    }
}
@end
