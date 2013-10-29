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
#import "UIBarButtonItem+Yn.h"
@interface SelectFileListViewController ()<SCBFileManagerDelegate,UIScrollViewDelegate,UIAlertViewDelegate,UITextFieldDelegate,UIActionSheetDelegate>
@property (strong,nonatomic) SCBFileManager *fm;
@property(strong,nonatomic) MBProgressHUD *hud;
@end

@implementation SelectFileListViewController
//<ios 6.0
- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation
{
    return NO;
}

//>ios 6.0
- (BOOL)shouldAutorotate{
    return NO;
}
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
    CGRect r=self.view.frame;
    r.size.height=[[UIScreen mainScreen] bounds].size.height-r.origin.y;
    self.view.frame=r;
    if ([YNFunctions systemIsLaterThanString:@"7.0"]) {
        self.tableView.frame=CGRectMake(0, 0, self.view.frame.size.width, self.view.frame.size.height-49);
    }else
    {
        self.tableView.frame=CGRectMake(0, 0, self.view.frame.size.width, self.view.frame.size.height-49-64);
    }
    if (![YNFunctions systemIsLaterThanString:@"7.0"]) {
        self.toolbar.frame=CGRectMake(0, [UIScreen mainScreen].bounds.size.height-64-49, 320, 49);
    }else
    {
        self.toolbar.frame=CGRectMake(0, ([[UIScreen mainScreen] bounds].size.height-49)-self.view.frame.origin.y, 320, 49);
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
    [self.toolbar setBackgroundImage:[UIImage imageNamed:@"oper_bk.png"] forToolbarPosition:UIBarPositionAny barMetrics:UIBarMetricsDefault];
    
    UIButton *btn_download ,*btn_resave;
    UIBarButtonItem  *item_download, *item_resave;
    
    btn_resave =[[UIButton alloc] initWithFrame:CGRectMake(0, 0, 134, 35)];
    [btn_resave setBackgroundImage:[UIImage imageNamed:@"oper_bt_nor.png"] forState:UIControlStateNormal];
    [btn_resave setBackgroundImage:[UIImage imageNamed:@"oper_bt_se.png"] forState:UIControlStateHighlighted];
    [btn_resave setTitle:@"确 定" forState:UIControlStateNormal];
    [btn_resave addTarget:self action:@selector(moveFileToHere:) forControlEvents:UIControlEventTouchUpInside];
    item_resave=[[UIBarButtonItem alloc] initWithCustomView:btn_resave];
    
    btn_download =[[UIButton alloc] initWithFrame:CGRectMake(0, 0, 134, 35)];
    [btn_download setBackgroundImage:[UIImage imageNamed:@"oper_bt_nor.png"] forState:UIControlStateNormal];
    [btn_download setBackgroundImage:[UIImage imageNamed:@"oper_bt_se.png"] forState:UIControlStateHighlighted];
    [btn_download setTitle:@"取 消" forState:UIControlStateNormal];
    [btn_download addTarget:self action:@selector(moveCancel:) forControlEvents:UIControlEventTouchUpInside];
    item_download=[[UIBarButtonItem alloc] initWithCustomView:btn_download];
    
//    UIBarButtonItem *ok_btn=[[UIBarButtonItem alloc] initWithTitleStr:@"    确 定    " style:UIBarButtonItemStyleDone target:self action:@selector(moveFileToHere:)];
//    UIBarButtonItem *cancel_btn=[[UIBarButtonItem alloc] initWithTitleStr:@"    取 消    " style:UIBarButtonItemStyleBordered target:self action:@selector(moveCancel:)];
    UIBarButtonItem *fix=[[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace target:nil action:nil];
    [self.toolbar setItems:@[fix,item_download,fix,item_resave,fix]];
    //self.tableView.frame=CGRectMake(0, 0, self.view.frame.size.width, self.view.frame.size.height-toolbarHeight);
    self.tableView.frame=CGRectMake(0, 64, self.view.frame.size.width, [[UIScreen mainScreen] bounds].size.height-49-64);
    
    //初始化返回按钮
    UIButton*backButton = [[UIButton alloc]initWithFrame:CGRectMake(0,0,35,29)];
    [backButton setImage:[UIImage imageNamed:@"title_back.png"] forState:UIControlStateNormal];
    [backButton addTarget:self.navigationController action:@selector(popViewControllerAnimated:) forControlEvents:UIControlEventTouchUpInside];
    UIBarButtonItem *backItem=[[UIBarButtonItem alloc] initWithCustomView:backButton];
    //self.backBarButtonItem=backItem;
    
    if ([YNFunctions systemIsLaterThanString:@"7.0"]) {
        UIBarButtonItem *temporaryBarButtonItem = [[UIBarButtonItem alloc] init];
        temporaryBarButtonItem.title = @"";
        self.navigationItem.backBarButtonItem = temporaryBarButtonItem;
    }else if(self.f_id.intValue!=0)
    {
        self.navigationItem.leftBarButtonItem = backItem;
    }
    
    UIButton*rightButton = [[UIButton alloc]initWithFrame:CGRectMake(0,0,40,40)];
    [rightButton setImage:[UIImage imageNamed:@"title_bt_new_nor.png"] forState:UIControlStateHighlighted];
    [rightButton setImage:[UIImage imageNamed:@"title_bt_new_se.png"] forState:UIControlStateNormal];
    [rightButton setBackgroundImage:[UIImage imageNamed:@"title_bk.png"] forState:UIControlStateHighlighted];
    [rightButton addTarget:self action:@selector(newFinder:) forControlEvents:UIControlEventTouchUpInside];
    UIBarButtonItem *rightItem = [[UIBarButtonItem alloc] initWithCustomView:rightButton];
    self.navigationItem.rightBarButtonItem=rightItem;
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
                    NSString *fid=[dic objectForKey:@"fid"];
                    BOOL isTarget=NO;
                    if ((self.type==kSelectTypeMove&&self.targetsArray!=nil)) {
                        for (NSString *f_id in self.targetsArray) {
                            NSString *str1=[NSString stringWithFormat:@"%@",f_id];
                            NSString *str2=[NSString stringWithFormat:@"%@",fid];
                            if ([str1 isEqualToString:str2]) {
                                isTarget=YES;
                                break;
                            }
                        }
                    }
                    if ([fisdir isEqualToString:@"0"]&&!isTarget) {
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
- (void)operateUpdate
{
    [self.fm cancelAllTask];
    self.fm=nil;
    self.fm=[[SCBFileManager alloc] init];
    [self.fm setDelegate:self];
    [self.fm operateUpdateWithID:self.f_id sID:self.spid];
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
-(void)newFinder:(id)sender
{
    NSLog(@"点击新建文件夹");
    UIAlertView *alert=[[UIAlertView alloc] initWithTitle:@"新建文件夹" message:@"" delegate:self cancelButtonTitle:@"取消" otherButtonTitles:@"确定", nil];
    [alert setAlertViewStyle:UIAlertViewStylePlainTextInput];
    //[[alert textFieldAtIndex:0] setText:@"新建文件夹"];
    [[alert textFieldAtIndex:0] setDelegate:self];
    [[alert textFieldAtIndex:0] setPlaceholder:@"请输入名称"];
    [alert show];
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
        
        UIImageView *imageView=[[UIImageView alloc] initWithFrame:CGRectMake(15, 5, 40, 40)];
        UILabel *textLabel=[[UILabel alloc] initWithFrame:CGRectMake(70, 5, 200, 21)];
        UILabel *detailTextLabel=[[UILabel alloc] initWithFrame:CGRectMake(70, 30, 200, 21)];
        [cell.contentView addSubview:imageView];
        [cell.contentView addSubview:textLabel];
        [cell.contentView addSubview:detailTextLabel];
        imageView.tag=1;
        textLabel.tag=2;
        detailTextLabel.tag=3;
        [textLabel setFont:[UIFont systemFontOfSize:16]];
        [detailTextLabel setFont:[UIFont systemFontOfSize:13]];
        [detailTextLabel setTextColor:[UIColor grayColor]];
    }
    UIImageView *imageView=(UIImageView *)[cell.contentView viewWithTag:1];
    UILabel *textLabel=(UILabel *)[cell.contentView viewWithTag:2];
    UILabel *detailTextLabel=(UILabel *)[cell.contentView viewWithTag:3];
    if (self.finderArray) {
        NSDictionary *dic=[self.finderArray objectAtIndex:indexPath.row];
        if (dic) {
            textLabel.text=[dic objectForKey:@"fname"];
            NSString *fisdir=[dic objectForKey:@"fisdir"];
            if ([fisdir isEqualToString:@"0"]) {
                detailTextLabel.text=[NSString stringWithFormat:@"%@",[dic objectForKey:@"fmodify"]];
                imageView.image=[UIImage imageNamed:@"file_folder.png"];
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
                flVC.targetsArray=self.targetsArray;
                [self.navigationController pushViewController:flVC animated:YES];
            }
        }
    }
}
#pragma mark - SCBFileManagerDelegate
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
//    [self doneLoadingTableViewData];
}
-(void)openFinderSucess:(NSDictionary *)datadic
{
    self.dataDic=datadic;
    if (self.dataDic) {
        self.listArray=self.listArray=(NSArray *)[self.dataDic objectForKey:@"files"];
        NSMutableArray *array=[[NSMutableArray alloc] init];
        for (NSDictionary *dic in self.listArray) {
            NSString *fisdir=[dic objectForKey:@"fisdir"];
            NSString *fid=[dic objectForKey:@"fid"];
            BOOL isTarget=NO;
            if ((self.type==kSelectTypeMove&&self.targetsArray!=nil)) {
                for (NSString *f_id in self.targetsArray) {
                    NSString *str1=[NSString stringWithFormat:@"%@",f_id];
                    NSString *str2=[NSString stringWithFormat:@"%@",fid];
                    if ([str1 isEqualToString:str2]) {
                        isTarget=YES;
                        break;
                    }
                }
            }
            if ([fisdir isEqualToString:@"0"]&&!isTarget) {
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
-(void)operateSucess:(NSDictionary *)datadic
{
    [self openFinderSucess:datadic];
    if (self.hud) {
        [self.hud removeFromSuperview];
    }
    self.hud=nil;
    self.hud=[[MBProgressHUD alloc] initWithView:self.view];
    [self.view addSubview:self.hud];
    [self.hud show:NO];
    self.hud.labelText=@"操作成功";
    self.hud.mode=MBProgressHUDModeText;
    self.hud.margin=10.f;
    [self.hud show:YES];
    [self.hud hide:YES afterDelay:1.0f];
}
-(void)newFinderSucess
{
    [self operateUpdate];
}
-(void)newFinderUnsucess;
{
    if (self.hud) {
        [self.hud removeFromSuperview];
    }
    self.hud=nil;
    self.hud=[[MBProgressHUD alloc] initWithView:self.view];
    [self.view addSubview:self.hud];
    
    [self.hud show:NO];
    self.hud.labelText=@"操作失败";
    self.hud.mode=MBProgressHUDModeText;
    self.hud.margin=10.f;
    [self.hud show:YES];
    [self.hud hide:YES afterDelay:1.0f];
}
#pragma mark - UIAlertViewDelegate Methods
- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if (buttonIndex==1) {
        NSString *fildtext=[[alertView textFieldAtIndex:0] text];
        if (![fildtext isEqualToString:@""]) {
            NSLog(@"重命名");
            [self.fm cancelAllTask];
            self.fm=[[SCBFileManager alloc] init];
            [self.fm newFinderWithName:fildtext pID:self.f_id sID:self.spid];
            [self.fm setDelegate:self];
        }
    }else
    {
        NSLog(@"点击其它");
    }

}
@end
