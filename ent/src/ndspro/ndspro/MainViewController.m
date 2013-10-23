//
//  MainViewController.m
//  ndspro
//
//  Created by fengyongning on 13-9-26.
//  Copyright (c) 2013年 fengyongning. All rights reserved.
//

#import "MainViewController.h"
#import "SCBFileManager.h"
#import "YNFunctions.h"
#import "SelectFileListViewController.h"
#import "UIBarButtonItem+Yn.h"
#import "MBProgressHUD.h"
#define AUTHOR_MENU @"AuthorMenus"
@interface MainViewController()<SCBFileManagerDelegate>
@property (strong,nonatomic) SCBFileManager *fm;
@property (strong,nonatomic) NSArray *commitList;
@property (strong,nonatomic) MBProgressHUD *hud;
@end

@implementation MainViewController

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
    CGSize winSize=[UIScreen mainScreen].bounds.size;
    //self.view.frame=CGRectMake(0, 64, winSize.width,winSize.height-64 );
    self.tableView.frame=CGRectMake(0, 0, winSize.width, self.view.frame.size.height);
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
    if (self.type==kTypeCommit||self.type==kTypeResave) {
        [self.navigationItem setLeftBarButtonItem:[[UIBarButtonItem alloc] initWithTitleStr:@"取消" style:UIBarButtonItemStylePlain target:self action:@selector(dissmissSelf:)]];
    }
    if ([YNFunctions systemIsLaterThanString:@"7.0"]) {
        UIBarButtonItem *temporaryBarButtonItem = [[UIBarButtonItem alloc] init];
        temporaryBarButtonItem.title = @"";
        self.navigationItem.backBarButtonItem = temporaryBarButtonItem;
    }
    
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
    [self updateFileList];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
- (void)updateFileList
{
    //加载本地缓存文件
    NSString *dataFilePath=[YNFunctions getDataCachePath];
    dataFilePath=[dataFilePath stringByAppendingPathComponent:[YNFunctions getFileNameWithFID:AUTHOR_MENU]];
    if ([[NSFileManager defaultManager] fileExistsAtPath:dataFilePath])
    {
        NSError *jsonParsingError=nil;
        NSData *data=[NSData dataWithContentsOfFile:dataFilePath];
        self.listArray=[NSJSONSerialization JSONObjectWithData:data options:0 error:&jsonParsingError];
        if (self.listArray) {
            [self.tableView reloadData];
        }
    }
    [self.fm cancelAllTask];
    self.fm=nil;
    self.fm=[[SCBFileManager alloc] init];
    [self.fm setDelegate:self];
    [self.fm authorMenus];
}
-(void)dissmissSelf:(id)sender
{
    [self dismissViewControllerAnimated:YES completion:Nil];
}
#pragma mark -
#pragma mark Data Source Loading / Reloading Methods

- (void)reloadTableViewDataSource{
	
	//  should be calling your tableviews data source model to reload
	//  put here just for demo
	_reloading = YES;
    [self updateFileList];
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
#pragma mark - Deferred image loading (UIScrollViewDelegate)
- (void)scrollViewDidScroll:(UIScrollView *)scrollView{
	
	[_refreshHeaderView egoRefreshScrollViewDidScroll:scrollView];
}
- (void)scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate
{
    [_refreshHeaderView egoRefreshScrollViewDidEndDragging:scrollView];
}
#pragma mark - Table view data source
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if (self.listArray) {
        if (self.type==kTypeCommit) {
            NSMutableArray *array=[NSMutableArray array];
            for (NSDictionary *dic in self.listArray) {
                NSString *roleType=[dic objectForKey:@"roletype"];
                if ([roleType isEqualToString:@"0"]||[roleType isEqualToString:@"1"]) {
                    [array addObject:dic];
                }
            }
            self.commitList=array;
            return self.commitList.count;
        }else if(self.type==kTypeResave)
        {
            return 1;
        }
        return self.listArray.count;
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
    }
    if (self.listArray) {
        NSDictionary *dic;
        if (self.type==kTypeCommit) {
            dic=[self.commitList objectAtIndex:indexPath.row];
        }else{
            dic=[self.listArray objectAtIndex:indexPath.row];
        }
        if (dic) {
            cell.textLabel.text=[dic objectForKey:@"spname"];
            //加载工作区图标
            NSString *roleType=[dic objectForKey:@"roletype"];;
            if ([roleType isEqualToString:@"9999"]) {
                cell.imageView.image=[UIImage imageNamed:@"ownerfiles.png"];
            }else
            {
                cell.imageView.image=[UIImage imageNamed:@"bizfiles.png"];
            }
            //显示工作区大小
            NSString *totalspace=[dic objectForKey:@"totalspace"];
            NSString *usedspace=[dic objectForKey:@"usedspace"];
            if (totalspace==nil||usedspace==nil) {
                cell.detailTextLabel.text=@"1.23G/5G";
            }else
            {
                cell.detailTextLabel.text=[NSString stringWithFormat:@"%@/%@",[YNFunctions convertSize:usedspace],[YNFunctions convertSize:totalspace]];
            }
        }
    }
    [cell.detailTextLabel setTextColor:[UIColor grayColor]];
    return cell;
}
-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 60;
}

#pragma mark - Table view delegate
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (self.listArray) {
        NSDictionary *dic;
        if (self.type==kTypeCommit) {
            dic=[self.commitList objectAtIndex:indexPath.row];
            if (dic) {
                SelectFileListViewController *flVC=[[SelectFileListViewController alloc] init];
                flVC.spid=[dic objectForKey:@"spid"];
                flVC.f_id=@"0";
                flVC.title=[dic objectForKey:@"spname"];
                flVC.roletype=[dic objectForKey:@"roletype"];
                flVC.delegate=self.delegate;
                flVC.type=kSelectTypeCommit;
                [self.navigationController pushViewController:flVC animated:YES];
            }
        }else if(self.type==kTypeResave)
        {
            dic=[self.listArray objectAtIndex:indexPath.row];
            if (dic) {
                SelectFileListViewController *flVC=[[SelectFileListViewController alloc] init];
                flVC.spid=[dic objectForKey:@"spid"];
                flVC.f_id=@"0";
                flVC.title=[dic objectForKey:@"spname"];
                flVC.roletype=[dic objectForKey:@"roletype"];
                flVC.delegate=self.delegate;
                flVC.type=kSelectTypeResave;
                [self.navigationController pushViewController:flVC animated:YES];
            }
        }else{
            dic=[self.listArray objectAtIndex:indexPath.row];
            if (dic) {
                FileListViewController *flVC=[[FileListViewController alloc] init];
                flVC.spid=[dic objectForKey:@"spid"];
                flVC.f_id=@"0";
                flVC.title=[dic objectForKey:@"spname"];
                flVC.roletype=[dic objectForKey:@"roletype"];
                [self.navigationController pushViewController:flVC animated:YES];
            }
        }
    }
}

#pragma mark - SCBFileManagerDelegate
-(void)authorMenusSuccess:(NSData*)data
{
    NSError *jsonParsingError=nil;
    self.listArray=[NSJSONSerialization JSONObjectWithData:data options:0 error:&jsonParsingError];
    if (self.listArray) {
        [self.tableView reloadData];
        NSString *dataFilePath=[YNFunctions getDataCachePath];
        dataFilePath=[dataFilePath stringByAppendingPathComponent:[YNFunctions getFileNameWithFID:AUTHOR_MENU]];
        BOOL isWrite=[data writeToFile:dataFilePath atomically:YES];
        if (isWrite) {
            NSLog(@"写入文件成功：%@",dataFilePath);
        }else
        {
            NSLog(@"写入文件失败：%@",dataFilePath);
        }
    }else
    {
        [self updateFileList];
    }
    [self doneLoadingTableViewData];
}
-(void)networkError
{
    if (self.hud) {
        [self.hud removeFromSuperview];
    }
    self.hud=nil;
    self.hud=[[MBProgressHUD alloc] initWithView:self.view];
    [self.view addSubview:self.hud];
    
    [self.hud show:NO];
    self.hud.labelText=@"链接失败，请检查网络";
    self.hud.mode=MBProgressHUDModeText;
    self.hud.margin=10.f;
    [self.hud show:YES];
    [self.hud hide:YES afterDelay:1.0f];
    [self doneLoadingTableViewData];
}
@end
