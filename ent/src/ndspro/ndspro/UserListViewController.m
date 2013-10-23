//
//  UserListViewController.m
//  ndspro
//
//  Created by fengyongning on 13-10-10.
//  Copyright (c) 2013年 fengyongning. All rights reserved.
//

#import "UserListViewController.h"
#import "YNFunctions.h"
#import "SCBAccountManager.h"

@implementation FileItem

+ (FileItem*) fileItem
{
	return [[self alloc] init];
}
@end

@interface UserListViewController ()<SCBAccountManagerDelegate>
@property (strong,nonatomic) SCBAccountManager *am;
@end

@implementation UserListViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}
-(void)viewWillAppear:(BOOL)animated
{
    [self updateList];
}
-(void)viewDidAppear:(BOOL)animated
{
    CGRect r=self.view.frame;
    r.size.height=[[UIScreen mainScreen] bounds].size.height-r.origin.y;
    self.view.frame=r;
    if ([YNFunctions systemIsLaterThanString:@"7.0"]) {
        self.tableView.frame=CGRectMake(0, 0, self.view.frame.size.width, self.view.frame.size.height);
    }else
    {
        self.tableView.frame=CGRectMake(0, 0, self.view.frame.size.width, self.view.frame.size.height-64);
    }
    
    NSLog(@"self.view.frame:%@",NSStringFromCGRect(self.view.frame));
    NSLog(@"self.tableview.frame:%@",NSStringFromCGRect(self.tableView.frame));
}
- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    self.tableView=[[UITableView alloc] init];
    self.tableView.delegate=self;
    self.tableView.dataSource=self;
    [self.view addSubview:self.tableView];
    self.tableView.frame=CGRectMake(0, 0, self.view.frame.size.width, self.view.frame.size.height);
    UIBarButtonItem *barItem=[[UIBarButtonItem alloc] initWithTitle:@"确定" style:UIBarButtonItemStylePlain target:self action:@selector(okAction:)];
    self.navigationItem.rightBarButtonItem=barItem;
    [self.tableView setEditing:YES];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
#pragma mark - 操作方法
- (void)updateList
{
    //加载本地缓存文件
    NSString *dataFilePath=[YNFunctions getDataCachePath];
    dataFilePath=[dataFilePath stringByAppendingPathComponent:[YNFunctions getFileNameWithFID:@"UserList"]];
    if ([[NSFileManager defaultManager] fileExistsAtPath:dataFilePath])
    {
        NSError *jsonParsingError=nil;
        NSData *data=[NSData dataWithContentsOfFile:dataFilePath];
        self.dataDic=[NSJSONSerialization JSONObjectWithData:data options:0 error:&jsonParsingError];
        if (self.dataDic) {
            self.listArray=(NSArray *)[self.dataDic objectForKey:@"userList"];
            if (self.listArray) {
                NSMutableArray *a=[NSMutableArray array];
                for (int i=0; i<self.listArray.count; i++) {
                    FileItem *fileItem=[[FileItem alloc]init];
                    [a addObject:fileItem];
                    [fileItem setChecked:NO];
                }
                self.userItems=a;
                [self.tableView reloadData];
            }
        }
    }
    
//    [self.am cancelAllTask];
    self.am=nil;
    self.am=[[SCBAccountManager alloc] init];
    [self.am setDelegate:self];
    [self.am getUserList];
}
-(void)okAction:(id)sender
{
    NSMutableArray *ids=[NSMutableArray array];
    NSMutableArray *names=[NSMutableArray array];
    for (int i=0;i<self.userItems.count; i++) {
        FileItem *item=[self.userItems objectAtIndex:i];
        if ([item checked]) {
            NSDictionary *dic=[self.listArray objectAtIndex:i];
            NSString *id=[dic objectForKey:@"usrid"];
            NSString *name=[dic objectForKey:@"usrturename"];
            [ids addObject:id];
            [names addObject:name];
        }
    }
    [self.delegate didSelectUserIDS:ids Names:names];
    [self.navigationController popViewControllerAnimated:YES];
}
#pragma mark - Table view data source
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if (self.listArray) {
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
        cell.selectionStyle = UITableViewCellSelectionStyleDefault;
//        NSString *osVersion = [[UIDevice currentDevice] systemVersion];
//        NSString *versionWithoutRotation = @"7.0";
//        BOOL noRotationNeeded = ([versionWithoutRotation compare:osVersion options:NSNumericSearch]
//                                 != NSOrderedDescending);
//        if (noRotationNeeded) {
//            cell.accessoryType=UITableViewCellAccessoryDetailButton;
//        }else
//        {
//            cell.accessoryType=UITableViewCellAccessoryDetailDisclosureButton;
//        }
    }
    if (self.listArray) {
        NSDictionary *dic=[self.listArray objectAtIndex:indexPath.row];
        if (dic)
        {
            cell.textLabel.text=[dic objectForKey:@"usrturename"];
        }
    }
    return cell;
}
-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 50;
}
- (UITableViewCellEditingStyle)tableView:(UITableView *)tableView editingStyleForRowAtIndexPath:(NSIndexPath *)indexPath
{
	return UITableViewCellEditingStyleDelete|UITableViewCellEditingStyleInsert;
}
#pragma mark - Table view delegate
- (void)tableView:(UITableView *)tableView accessoryButtonTappedForRowWithIndexPath:(NSIndexPath *)indexPath
{
    //    self.selectedIndexPath=indexPath;
    //    [self toMore:self];
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    FileItem* fileItem = [self.userItems objectAtIndex:indexPath.row];
    fileItem.checked = YES;
    return;
}
-(void)tableView:(UITableView *)tableView didDeselectRowAtIndexPath:(NSIndexPath *)indexPath
{
    FileItem* fileItem = [self.userItems objectAtIndex:indexPath.row];
    fileItem.checked = NO;
    return;
}

#pragma mark -SCBAccountManagerDelegate
-(void)getUserListSucceed:(NSDictionary *)datadic
{
    self.dataDic=datadic;
    if (self.dataDic) {
        self.listArray=(NSArray *)[self.dataDic objectForKey:@"userList"];
        if (self.listArray) {
            NSMutableArray *a=[NSMutableArray array];
            for (int i=0; i<self.listArray.count; i++) {
                FileItem *fileItem=[[FileItem alloc]init];
                [a addObject:fileItem];
                [fileItem setChecked:NO];
            }
            self.userItems=a;
            [self.tableView reloadData];
        }
        NSString *dataFilePath=[YNFunctions getDataCachePath];
        dataFilePath=[dataFilePath stringByAppendingPathComponent:[YNFunctions getFileNameWithFID:@"UserList"]];
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
        [self updateList];
    }
}
-(void)getUserListFail
{
}
@end
