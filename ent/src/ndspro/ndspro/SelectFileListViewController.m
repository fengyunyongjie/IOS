//
//  SelectFileListViewController.m
//  ndspro
//
//  Created by fengyongning on 13-10-8.
//  Copyright (c) 2013年 fengyongning. All rights reserved.
//

#import "SelectFileListViewController.h"
#import "SCBFileManager.h"
#import "MBProgressHUD.h"
#import "YNFunctions.h"
#import "IconDownloader.h"
@interface SelectFileListViewController ()<SCBFileManagerDelegate,UIScrollViewDelegate,UIAlertViewDelegate,UITextFieldDelegate,UIActionSheetDelegate>
@property (strong,nonatomic) SCBFileManager *fm;
@property(strong,nonatomic) MBProgressHUD *hud;
@end

@implementation SelectFileListViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}
- (void)viewWillAppear:(BOOL)animated
{
    [self updateFileList];
}
- (void)viewDidAppear:(BOOL)animated
{
    if (![YNFunctions systemIsLaterThanString:@"7.0"]) {
        self.toolbar.frame=CGRectMake(0, [UIScreen mainScreen].bounds.size.height-64-49, 320, 49);
        self.tableView.frame=CGRectMake(0, 0, self.view.frame.size.width, self.view.frame.size.height-49);
    }
}
- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    self.tableView=[[UITableView alloc] init];
    self.tableView.delegate=self;
    self.tableView.dataSource=self;
    [self.view addSubview:self.tableView];
    //Initialize the toolbar
    UIToolbar *toolbar=[[UIToolbar alloc] init];
    //Set the toolbar to fit the width of the app.
    [toolbar sizeToFit];
    //Calclulate the height of the toolbar
    CGFloat toolbarHeight=[toolbar frame].size.height;
    //Get the bounds of the parent view
    CGRect rootViewBounds=self.view.bounds;
    //Get the height of the parent view
    CGFloat rootViewHeight=CGRectGetHeight(rootViewBounds);
    //Get the width of the parent view
    CGFloat rootViewWidth=CGRectGetWidth(rootViewBounds);
    //Create a rectangle for the toolbar
    CGRect rectArea=CGRectMake(0, rootViewHeight-toolbarHeight, rootViewWidth, toolbarHeight);
    //Reposition and resize the receiver
    [toolbar setFrame:rectArea];
    //Add the toolbar as a subview to the navigation controller.
    [self.view addSubview:toolbar];
    self.toolbar=toolbar;
    UIBarButtonItem *ok_btn=[[UIBarButtonItem alloc] initWithTitle:@"    确 定    " style:UIBarButtonItemStyleDone target:self action:@selector(moveFileToHere:)];
    UIBarButtonItem *cancel_btn=[[UIBarButtonItem alloc] initWithTitle:@"    取 消    " style:UIBarButtonItemStyleBordered target:self action:@selector(moveCancel:)];
    UIBarButtonItem *fix=[[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace target:nil action:nil];
    [self.toolbar setItems:@[fix,cancel_btn,fix,ok_btn,fix]];
    //self.tableView.frame=CGRectMake(0, 0, self.view.frame.size.width, self.view.frame.size.height-toolbarHeight);
    self.tableView.frame=CGRectMake(0, 64, self.view.frame.size.width, [[UIScreen mainScreen] bounds].size.height-49-64);

}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
#pragma mark - 操作方法
- (void)updateFileList
{
    //加载本地缓存文件
    NSString *dataFilePath=[YNFunctions getDataCachePath];
    dataFilePath=[dataFilePath stringByAppendingPathComponent:[YNFunctions getFileNameWithFID:[NSString stringWithFormat:@"%@_%@",self.spid,self.f_id]]];
    if ([[NSFileManager defaultManager] fileExistsAtPath:dataFilePath])
    {
        NSError *jsonParsingError=nil;
        NSData *data=[NSData dataWithContentsOfFile:dataFilePath];
        self.dataDic=[NSJSONSerialization JSONObjectWithData:data options:0 error:&jsonParsingError];
        if (self.dataDic) {
            self.listArray=self.listArray=(NSArray *)[self.dataDic objectForKey:@"files"];
            if (self.listArray) {
                NSMutableArray *array=[[NSMutableArray alloc] init];
                for (NSDictionary *dic in self.listArray) {
                    NSString *fisdir=[dic objectForKey:@"fisdir"];
                    if ([fisdir isEqualToString:@"0"]) {
                        [array addObject:dic];
                    }
                }
                self.finderArray=array;
                [self.tableView reloadData];
            }
        }
    }
    [self.fm cancelAllTask];
    self.fm=nil;
    self.fm=[[SCBFileManager alloc] init];
    [self.fm setDelegate:self];
    [self.fm openFinderWithID:self.f_id sID:self.spid];
}
- (void)moveFileToHere:(id)sender
{
    switch (self.type) {
        case kSelectTypeDefault:
        case kSelectTypeMove:
            [self.delegate moveFileToID:self.f_id];
            break;
        case kSelectTypeCommit:
            [self.delegate commitFileToID:self.f_id sID:self.spid];
            break;
        case kSelectTypeResave:
            [self.delegate resaveFileToID:self.f_id];
            break;
        default:
            break;
    }
    [self dismissViewControllerAnimated:YES completion:nil];
}
- (void)moveCancel:(id)sender
{
    [self dismissViewControllerAnimated:YES completion:nil];
}
#pragma mark - Table view data source
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if (self.finderArray) {
        return self.finderArray.count;
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
    if (self.finderArray) {
        NSDictionary *dic=[self.finderArray objectAtIndex:indexPath.row];
        if (dic) {
            cell.textLabel.text=[dic objectForKey:@"fname"];
            NSString *fisdir=[dic objectForKey:@"fisdir"];
            if ([fisdir isEqualToString:@"0"]) {
                cell.detailTextLabel.text=[NSString stringWithFormat:@"%@",[dic objectForKey:@"fmodify"]];
                cell.imageView.image=[UIImage imageNamed:@"file_folder.png"];
            }
        }
    }
    return cell;
}
-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 50;
}

#pragma mark - Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (self.listArray) {
        NSDictionary *dic=[self.listArray objectAtIndex:indexPath.row];
        if (dic) {
            NSString *fisdir=[dic objectForKey:@"fisdir"];
            if ([fisdir isEqualToString:@"0"]) {
                SelectFileListViewController *flVC=[[SelectFileListViewController alloc] init];
                flVC.spid=self.spid;
                flVC.f_id=[dic objectForKey:@"fid"];
                flVC.title=[dic objectForKey:@"fname"];
                flVC.delegate=self.delegate;
                flVC.type=self.type;
                [self.navigationController pushViewController:flVC animated:YES];
            }
        }
    }
}
#pragma mark - SCBFileManagerDelegate
-(void)openFinderSucess:(NSDictionary *)datadic
{
    self.dataDic=datadic;
    if (self.dataDic) {
        self.listArray=self.listArray=(NSArray *)[self.dataDic objectForKey:@"files"];
        NSMutableArray *array=[[NSMutableArray alloc] init];
        for (NSDictionary *dic in self.listArray) {
            NSString *fisdir=[dic objectForKey:@"fisdir"];
            if ([fisdir isEqualToString:@"0"]) {
                [array addObject:dic];
            }
        }
        self.finderArray=array;
        [self.tableView reloadData];
        NSString *dataFilePath=[YNFunctions getDataCachePath];
        dataFilePath=[dataFilePath stringByAppendingPathComponent:[YNFunctions getFileNameWithFID:[NSString stringWithFormat:@"%@_%@",self.spid,self.f_id]]];
        
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
        [self updateFileList];
    }
    NSLog(@"openFinderSucess:");
    if (self.dataDic)
    {
        NSString *dataFilePath=[YNFunctions getDataCachePath];
        dataFilePath=[dataFilePath stringByAppendingPathComponent:[YNFunctions getFileNameWithFID:self.f_id]];
        
        NSError *jsonParsingError=nil;
        NSData *data=[NSJSONSerialization dataWithJSONObject:self.dataDic options:0 error:&jsonParsingError];
        BOOL isWrite=[data writeToFile:dataFilePath atomically:YES];
        if (isWrite) {
            NSLog(@"写入文件成功：%@",dataFilePath);
        }else
        {
            NSLog(@"写入文件失败：%@",dataFilePath);
        }
    }
    
}

@end
