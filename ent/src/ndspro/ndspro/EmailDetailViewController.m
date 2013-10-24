//
//  EmailDetailViewController.m
//  ndspro
//
//  Created by fengyongning on 13-10-9.
//  Copyright (c) 2013年 fengyongning. All rights reserved.
//

#import "EmailDetailViewController.h"
#import "SCBEmailManager.h"
#import "MBProgressHUD.h"
#import "YNFunctions.h"
#import "IconDownloader.h"
#import "AppDelegate.h"
#import "MainViewController.h"
#import "SCBFileManager.h"

@interface EmailDetailViewController ()<SCBFileManagerDelegate,SCBEmailManagerDelegate,IconDownloaderDelegate,UIAlertViewDelegate,UIActionSheetDelegate>
{
    BOOL _isDetail;
}
@property (strong,nonatomic) SCBEmailManager *em;
@property (strong,nonatomic) SCBEmailManager *em_list;
@property(strong,nonatomic) MBProgressHUD *hud;
@property (strong,nonatomic) UIToolbar *moreEditBar;
@property (strong,nonatomic) SCBFileManager *fm_move;
@property (strong,nonatomic) UIBarButtonItem *backBarButtonItem;
@property (strong,nonatomic) UIView *headerView;
@property (strong,nonatomic) UIView *footerView;
@property (strong,nonatomic) UILabel *personLabel;
@property (strong,nonatomic) UILabel *titleLabel;
@property (strong,nonatomic) UILabel *contentLabel;
@property (strong,nonatomic) UILabel *timeLabel;
@property (strong,nonatomic) UIButton *switchButton;
@property (strong,nonatomic) UIView *contentBgView;
@end

@implementation EmailDetailViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    _isDetail=NO;
    // Do any additional setup after loading the view from its nib.
    self.tableView=[[UITableView alloc] init];
    self.tableView.delegate=self;
    self.tableView.dataSource=self;
    [self.view addSubview:self.tableView];
    self.tableView.frame=CGRectMake(0, 0, self.view.frame.size.width, self.view.frame.size.height);
    [self.tableView setEditing:YES];
    
    //初始化返回按钮
    UIButton*backButton = [[UIButton alloc]initWithFrame:CGRectMake(0,0,35,29)];
    [backButton setImage:[UIImage imageNamed:@"title_back.png"] forState:UIControlStateNormal];
    [backButton addTarget:self.navigationController action:@selector(popViewControllerAnimated:) forControlEvents:UIControlEventTouchUpInside];
    UIBarButtonItem *backItem=[[UIBarButtonItem alloc] initWithCustomView:backButton];
    self.backBarButtonItem=backItem;
    
    if ([YNFunctions systemIsLaterThanString:@"7.0"]) {
        UIBarButtonItem *temporaryBarButtonItem = [[UIBarButtonItem alloc] init];
        temporaryBarButtonItem.title = @"";
        self.navigationItem.backBarButtonItem = temporaryBarButtonItem;
    }else
    {
        self.navigationItem.leftBarButtonItem = backItem;
    }
}
-(void)viewDidAppear:(BOOL)animated
{
    self.tableView.frame=CGRectMake(0, 0, self.view.frame.size.width, self.view.frame.size.height-49);
    
    if (!self.moreEditBar) {
        self.moreEditBar=[[UIToolbar alloc] initWithFrame:CGRectMake(0, ([[UIScreen mainScreen] bounds].size.height-49)-self.view.frame.origin.y, 320, 49)];
        [self.moreEditBar setBackgroundImage:[UIImage imageNamed:@"oper_bk.png"] forToolbarPosition:UIBarPositionAny barMetrics:UIBarMetricsDefault];
        if ([YNFunctions systemIsLaterThanString:@"7.0"]) {
            [self.moreEditBar setBarTintColor:[UIColor blueColor]];
        }else
        {
            [self.moreEditBar setTintColor:[UIColor blueColor]];
        }
        [self.view addSubview:self.moreEditBar];
        //发送 删除 提交 移动 全选
        UIButton *btn_download ,*btn_resave;
        UIBarButtonItem  *item_download, *item_resave,*item_flexible;
        
        btn_resave =[[UIButton alloc] initWithFrame:CGRectMake(0, 0, 134, 35)];
//        [btn_resave setImage:[UIImage imageNamed:@"zc_nor.png"] forState:UIControlStateNormal];
//        [btn_resave setImage:[UIImage imageNamed:@"zc_se.png"] forState:UIControlStateHighlighted];
        [btn_resave setBackgroundImage:[UIImage imageNamed:@"oper_bt_nor.png"] forState:UIControlStateNormal];
        [btn_resave setBackgroundImage:[UIImage imageNamed:@"oper_bt_se.png"] forState:UIControlStateHighlighted];
        [btn_resave setTitle:@"转存" forState:UIControlStateNormal];
        [btn_resave addTarget:self action:@selector(toResave:) forControlEvents:UIControlEventTouchUpInside];
        item_resave=[[UIBarButtonItem alloc] initWithCustomView:btn_resave];
        
        btn_download =[[UIButton alloc] initWithFrame:CGRectMake(0, 0, 134, 35)];
//        [btn_download setImage:[UIImage imageNamed:@"download_nor.png"] forState:UIControlStateNormal];
//        [btn_download setImage:[UIImage imageNamed:@"download_se.png"] forState:UIControlStateHighlighted];
        [btn_download setBackgroundImage:[UIImage imageNamed:@"oper_bt_nor.png"] forState:UIControlStateNormal];
        [btn_download setBackgroundImage:[UIImage imageNamed:@"oper_bt_se.png"] forState:UIControlStateHighlighted];
        [btn_download setTitle:@"下载" forState:UIControlStateNormal];
        [btn_download addTarget:self action:@selector(toDownload:) forControlEvents:UIControlEventTouchUpInside];
        item_download=[[UIBarButtonItem alloc] initWithCustomView:btn_download];
        
        item_flexible=[[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace target:nil action:nil];

        [self.moreEditBar setItems:@[item_flexible,item_download,item_flexible,item_resave,item_flexible]];

    }
    if (![YNFunctions systemIsLaterThanString:@"7.0"]) {
        //self.tableView.frame=CGRectMake(0, 0, self.view.frame.size.width, self.view.frame.size.height-49-64);
        self.moreEditBar.frame=CGRectMake(0, [UIScreen mainScreen].bounds.size.height-64-49, 320, 49);
    }
}
-(void)viewWillAppear:(BOOL)animated
{
    [self updateEmailList];
    [self updateFileList];
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
    dataFilePath=[dataFilePath stringByAppendingPathComponent:[YNFunctions getFileNameWithFID:[NSString stringWithFormat:@"%@.EmailFileList",self.eid]]];
    if ([[NSFileManager defaultManager] fileExistsAtPath:dataFilePath])
    {
        NSError *jsonParsingError=nil;
        NSData *data=[NSData dataWithContentsOfFile:dataFilePath];
        self.fileArray=[NSJSONSerialization JSONObjectWithData:data options:0 error:&jsonParsingError];
        if (self.fileArray) {
            [self.tableView reloadData];
        }
    }

    
    [self.em_list cancelAllTask];
    self.em_list=nil;
    self.em_list=[[SCBEmailManager alloc] init];
    [self.em_list setDelegate:self];
    [self.em_list fileListWithID:self.eid];
}
- (void)updateEmailList
{
    //加载本地缓存文件
    NSString *dataFilePath=[YNFunctions getDataCachePath];
    dataFilePath=[dataFilePath stringByAppendingPathComponent:[YNFunctions getFileNameWithFID:[NSString stringWithFormat:@"%@.Email",self.eid]]];
    if ([[NSFileManager defaultManager] fileExistsAtPath:dataFilePath])
    {
        NSError *jsonParsingError=nil;
        NSData *data=[NSData dataWithContentsOfFile:dataFilePath];
        self.dataDic=[NSJSONSerialization JSONObjectWithData:data options:0 error:&jsonParsingError];
        if (self.dataDic) {
//            NSArray *emails=(NSArray *)[self.dataDic objectForKey:@"emails"];
//            NSMutableArray *tempInArray=[NSMutableArray array];
//            NSMutableArray *tempOutArray=[NSMutableArray array];
//            for (NSDictionary *dic in emails)
//            {
//                int etype=[[dic objectForKey:@"etype"] intValue];
//                //etype	邮件类型	String，0为收件箱，1为发件箱
//                if (etype ==0) {
//                    [tempInArray addObject:dic];
//                }else if(etype==1)
//                {
//                    [tempOutArray addObject:dic];
//                }else
//                {
//                    NSLog(@"邮件类型出错：%d",etype);
//                }
//            }
//            self.inArray=tempInArray;
//            self.outArray=tempOutArray;
            [self.tableView reloadData];
        }
    }
    
    [self.em cancelAllTask];
    self.em=nil;
    self.em=[[SCBEmailManager alloc] init];
    [self.em setDelegate:self];
    [self.em detailEmailWithID:self.eid type:self.etype];
}
-(NSArray *)selectedIDs
{
    NSMutableArray *ids=[[NSMutableArray alloc] init];
    for (NSIndexPath *indexpath in [self selectedIndexPaths]) {
        if (indexpath.section!=5) {
            continue;
        }
        NSDictionary *dic=[self.fileArray objectAtIndex:indexpath.row];
        NSString *fid=[dic objectForKey:@"fid"];
        [ids addObject:fid];
    }
    return ids;
}
-(NSArray *)selectedIndexPaths
{
    NSArray *retVal=nil;
    retVal=self.tableView.indexPathsForSelectedRows;
    return retVal;
}
-(void)toDownload:(id)sender
{
    if (self.tableView.isEditing) {
        NSArray *selectArray=[self selectedIndexPaths];
        for (NSIndexPath *indexPath in selectArray) {
            if (indexPath.section!=5) {
                continue;
            }
            NSDictionary *dic=[self.fileArray objectAtIndex:indexPath.row];
            
            long fsize=[[dic objectForKey:@"fsize"] longValue];

            BOOL isDir;
            if (fsize==0) {
                if (self.hud)
                {
                    [self.hud removeFromSuperview];
                }
                self.hud=nil;
                self.hud=[[MBProgressHUD alloc] initWithView:self.view];
                [self.view addSubview:self.hud];
                [self.hud show:NO];
                self.hud.labelText=@"不能下载文件夹";
                self.hud.mode=MBProgressHUDModeText;
                self.hud.margin=10.f;
                [self.hud show:YES];
                [self.hud hide:YES afterDelay:1.0f];
                return;
            }
        }
        for (NSIndexPath *indexPath in selectArray) {
            if (indexPath.section!=5) {
                continue;
            }
            NSDictionary *dic=[self.fileArray objectAtIndex:indexPath.row];
            NSString *file_id = [NSString formatNSStringForOjbect:[dic objectForKey:@"fid"]];
            NSString *thumb = [NSString formatNSStringForOjbect:[dic objectForKey:@"fthumb"]];
            if([thumb length]==0)
            {
                thumb = @"0";
            }
            NSString *name = [NSString formatNSStringForOjbect:[dic objectForKey:@"fname"]];
            NSInteger fsize = [[dic objectForKey:@"fsize"] integerValue];
            AppDelegate *delegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
            [delegate.downmange addDownList:name thumbName:thumb d_fileId:file_id d_downSize:fsize];
        }
        
    }
}
-(void)toResave:(id)sender
{
    if (self.tableView.editing) {
        NSArray *array=[self selectedIDs];
        NSLog(@"%@",array);
        if (array.count==0) {
            if (self.hud) {
                [self.hud removeFromSuperview];
            }
            self.hud=nil;
            self.hud=[[MBProgressHUD alloc] initWithView:self.view];
            [self.view addSubview:self.hud];
            [self.hud show:NO];
            self.hud.labelText=@"未选中任何文件（夹）";
            self.hud.mode=MBProgressHUDModeText;
            self.hud.margin=10.f;
            [self.hud show:YES];
            [self.hud hide:YES afterDelay:1.0f];
            return;
        }
    }
    NSLog(@"转存");
    MainViewController *flvc=[[MainViewController alloc] init];
    flvc.title=@"选择转存的位置";
    flvc.delegate=self;
    flvc.type=kTypeResave;
    UINavigationController *nav=[[UINavigationController alloc] initWithRootViewController:flvc];
    [self presentViewController:nav animated:YES completion:nil];
}
-(void)loadEmail
{
    NSDictionary *dic=[self.dataDic objectForKey:@"email"];
    if (self.headerView&&dic) {
        //[dic objectForKey:@"receivelist"];
        int etype=[[dic objectForKey:@"etype"] intValue];
        if (etype==0) {
            self.personLabel.text=[dic objectForKey:@"sender"];
        }else
        {
            self.personLabel.text=[dic objectForKey:@"receivelist"];
        }
        
        self.titleLabel.text=[dic objectForKey:@"etitle"];
        self.timeLabel.text=[dic objectForKey:@"sendtime"];
        self.contentLabel.text=[dic objectForKey:@"econtent"];
    }
}
-(void)switchAction:(id)sender
{
    _isDetail=!_isDetail;
    [self.tableView reloadData];
}
-(void)resaveFileToID:(NSString *)f_id
{
    NSDictionary *dic=[self.fileArray objectAtIndex:self.selectedIndexPath.row];
    NSString *fid=[dic objectForKey:@"fid"];
    if (self.fm_move) {
        [self.fm_move cancelAllTask];
    }else
    {
        self.fm_move=[[SCBFileManager alloc] init];
    }
    self.fm_move.delegate=self;
    if (self.tableView.isEditing) {
        
        [self.fm_move resaveFileIDs:[self selectedIDs] toPID:f_id];
        
    }else
    {
        [self.fm_move resaveFileIDs:@[fid] toPID:f_id];
    }
    
}
#pragma mark - Table view data source
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView              // Default is 1 if not implemented
{
    return 1;
}
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if (self.fileArray) {
        return self.fileArray.count;
    }
    return 0;
}
//- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
//{
//    // fixed font style. use custom view (UILabel) if you want something different
////    switch (section) {
////        case 0:
////            return @"发送人：";
////            break;
////        case 1:
////            return @"接收人：";
////            break;
////        case 2:
////            return @"标题：";
////            break;
////        case 3:
////            return @"时间：";
////            break;
////        case 4:
////            return @"内容：";
////            break;
////        case 5:
////            return @"文件：";
////            break;
////        default:
////            break;
////    }
//    return @"";
//}
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"Cell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle
                                      reuseIdentifier:CellIdentifier];
        //cell.selectionStyle = UITableViewCellSelectionStyleNone;
    }
    cell.textLabel.text=@"";
    cell.textLabel.font=[UIFont systemFontOfSize:15];
    cell.detailTextLabel.text=@"";
    [cell.detailTextLabel setTextColor:[UIColor grayColor]];
    cell.imageView.image=nil;
    if (self.dataDic) {
        NSDictionary *dic=[self.dataDic objectForKey:@"email"];
        if (self.fileArray) {
            NSDictionary *dic=[self.fileArray objectAtIndex:indexPath.row];
            if (dic) {
                cell.textLabel.text=[dic objectForKey:@"fname"];
                //NSString *fisdir=[dic objectForKey:@"fisdir"];
                long fsize=[[dic objectForKey:@"fsize"] longValue];
                if (fsize==0) {
                    //                            cell.detailTextLabel.text=[NSString stringWithFormat:@"%@",[dic objectForKey:@"fmodify"]];
                    cell.imageView.image=[UIImage imageNamed:@"file_folder.png"];
                }else
                {
                    cell.imageView.image=[UIImage imageNamed:@"file_other.png"];
                    cell.detailTextLabel.text=[NSString stringWithFormat:@"%@",[YNFunctions convertSize:[dic objectForKey:@"fsize"]]];
                    NSString *fname=[dic objectForKey:@"fname"];
                    NSString *fmime=[[fname pathExtension] lowercaseString];
                    //                NSString *fmime=[[dic objectForKey:@"fmime"] lowercaseString];
                    NSLog(@"fmime:%@",fmime);
                    if ([fmime isEqualToString:@"png"]||
                        [fmime isEqualToString:@"jpg"]||
                        [fmime isEqualToString:@"jpeg"]||
                        [fmime isEqualToString:@"bmp"]||
                        [fmime isEqualToString:@"gif"]){
                        cell.imageView.image = [UIImage imageNamed:@"file_pic.png"];
                    }else if ([fmime isEqualToString:@"doc"]||
                              [fmime isEqualToString:@"docx"])
                    {
                        cell.imageView.image = [UIImage imageNamed:@"file_doc.png"];
                    }else if ([fmime isEqualToString:@"mp3"])
                    {
                        cell.imageView.image = [UIImage imageNamed:@"file_music.png"];
                    }else if ([fmime isEqualToString:@"mov"])
                    {
                        cell.imageView.image = [UIImage imageNamed:@"file_moving.png"];
                    }else if ([fmime isEqualToString:@"ppt"])
                    {
                        cell.imageView.image = [UIImage imageNamed:@"file_other.png"];
                    }else
                    {
                        cell.imageView.image = [UIImage imageNamed:@"file_other.png"];
                    }
                }
            }
        }
    }
//        switch (indexPath.section) {
//            case 0:
////                return @"发送人：";
//                cell.textLabel.text=[dic objectForKey:@"sender"];
//                break;
//            case 1:
////                return @"接收人：";
//                cell.textLabel.text=[dic objectForKey:@"receivelist"];
//                break;
//            case 2:
////                return @"标题：";
//                cell.textLabel.text=[dic objectForKey:@"etitle"];
//                if ([cell.textLabel.text isEqualToString:@""]) {
//                    cell.textLabel.text=@"无主题";
//                }
//                break;
//            case 3:
////                return @"时间：";
//                cell.textLabel.text=[dic objectForKey:@"sendtime"];
//                break;
//            case 4:
////                return @"内容：";
//            {
////                UILabel *label=[[UILabel alloc] init];
////                label.text=[dic objectForKey:@"econtent"];
////                label.frame=CGRectMake(0, 0, 320, 200);
////                label.numberOfLines=0;
////                [cell.contentView addSubview:label];
//                cell.textLabel.text=[dic objectForKey:@"econtent"];
//                cell.textLabel.numberOfLines=0;
//                [cell.textLabel sizeToFit];
//                [cell.contentView sizeToFit];
//                float cellHeight=cell.textLabel.frame.size.height;
//                cell.frame=CGRectMake(cell.frame.origin.x, cell.frame.origin.x, cell.frame.size.height, cellHeight);
//            }
//                break;
//            case 5:
////                return @"文件：";
//            {
//                break;
//            default:
//                break;
//        }
    return cell;
}
-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.section==4) {
        UITableViewCell *cell = [self tableView:tableView cellForRowAtIndexPath:indexPath];
        return cell.frame.size.height+30;
    }
    return 50;
}
-(CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    if (_isDetail) {
        [self.contentLabel setNumberOfLines:0];
        CGSize size = CGSizeMake(280,2000);
        CGSize bestSize=[self.contentLabel sizeThatFits:size];
        if (bestSize.height<34) {
            bestSize.height=34;
        }
        self.contentLabel.frame=CGRectMake(20, 50, bestSize.width, bestSize.height);
        self.headerView.frame=CGRectMake(0, 0, 320, bestSize.height+50+16);
        self.contentBgView.frame=CGRectMake(0, 50, 320, self.headerView.frame.size.height-50);
        self.switchButton.frame=CGRectMake(320-60, self.headerView.frame.size.height-21, 50, 21);
        [self.switchButton setTitle:@"收起" forState:UIControlStateNormal];
        return self.headerView.frame.size.height;
    }else
    {
        [self.contentLabel setNumberOfLines:2];
        self.contentLabel.frame=CGRectMake(20, 50, 280, 34);
        self.headerView.frame=CGRectMake(0, 0, 320, 100);
        self.contentBgView.frame=CGRectMake(0, 50, 320, self.headerView.frame.size.height-50);
        self.switchButton.frame=CGRectMake(320-60, self.headerView.frame.size.height-21, 50, 21);
        [self.switchButton setTitle:@"展开" forState:UIControlStateNormal];
    }
    return 100;
}
-(CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section
{
    if (self.footerView) {
        return self.footerView.frame.size.height;
    }
    return 100;
}
#pragma mark - Table view delegate
- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section   // custom view for header. will be adjusted to default or specified header height
{
    NSDictionary *dic=[self.dataDic objectForKey:@"email"];
    
    if (!self.headerView) {
        UIView *view=[[UIView alloc] initWithFrame:CGRectMake(0, 0, 320, 100)];
        UILabel *p_label= [[UILabel alloc] initWithFrame:CGRectMake(20, 4, 170, 21)];
        UILabel *title_lbl=[[UILabel alloc] initWithFrame:CGRectMake(20, 25, 280, 21)];
        UILabel *time_lbl=[[UILabel alloc] initWithFrame:CGRectMake(200, 4, 120, 21)];
        UILabel *content_lbl=[[UILabel alloc] initWithFrame:CGRectMake(20, 50, 280, 34)];
        
        [p_label setFont:[UIFont boldSystemFontOfSize:16]];
        [title_lbl setFont:[UIFont systemFontOfSize:14]];
        [content_lbl setFont:[UIFont systemFontOfSize:14]];
        [time_lbl setFont:[UIFont systemFontOfSize:13]];
        
        [content_lbl setTextColor:[UIColor grayColor]];
        [time_lbl setTextColor:[UIColor grayColor]];
        [content_lbl setNumberOfLines:2];
        //[content_lbl setLineBreakMode:NSLineBreakByWordWrapping];
        
        [view addSubview:p_label];
        [view addSubview:title_lbl];
        [view addSubview:time_lbl];
        [view addSubview:content_lbl];
        
        self.personLabel=p_label;
        self.titleLabel=title_lbl;
        self.timeLabel=time_lbl;
        self.contentLabel=content_lbl;
        view.backgroundColor=[UIColor whiteColor];
        
        UIView *bgView=[[UIView alloc] initWithFrame:CGRectMake(0, 50, 320, 50)];
        bgView.layer.borderWidth=0.5;
        bgView.layer.borderColor=[UIColor grayColor].CGColor;
        self.contentBgView=bgView;
        [view addSubview:bgView];
        UIButton *on_off_btn=[[UIButton alloc] initWithFrame:CGRectMake(320-50,100-21,50,21)];
        [on_off_btn setTitle:@"展开" forState:UIControlStateNormal];
        [on_off_btn setTitleColor:[UIColor blueColor] forState:UIControlStateNormal];
        [on_off_btn.titleLabel setFont:[UIFont systemFontOfSize:15]];
        [on_off_btn addTarget:self action:@selector(switchAction:) forControlEvents:UIControlEventTouchUpInside];
        [view addSubview:on_off_btn];
        self.switchButton=on_off_btn;
        self.headerView=view;
    }
    [self loadEmail];
    return self.headerView;
}
- (UIView *)tableView:(UITableView *)tableView viewForFooterInSection:(NSInteger)section   // custom view for footer. will be adjusted to default or specified footer height
{
    if (!self.footerView) {
        UIView *view=[[UIView alloc] initWithFrame:CGRectMake(0, 0, 320, 100)];
//        UIButton *download_button=[[UIButton alloc] initWithFrame:CGRectMake(40, 33, 100, 34)];
//        [download_button setImage:[UIImage imageNamed:@"send_download_nor.png"] forState:UIControlStateNormal];
//        [download_button setImage:[UIImage imageNamed:@"send_download_se.png"] forState:UIControlStateHighlighted];
//        [download_button addTarget:self  action:@selector(toDownload:) forControlEvents:UIControlEventTouchUpInside];
//        UIButton *resave_button=[[UIButton alloc] initWithFrame:CGRectMake(180, 33, 100, 34)];
//        [resave_button setImage:[UIImage imageNamed:@"send_zc_nor.png"] forState:UIControlStateNormal];
//        [resave_button setImage:[UIImage imageNamed:@"send_zc_se.png"] forState:UIControlStateHighlighted];
//        [resave_button addTarget:self  action:@selector(toResave:) forControlEvents:UIControlEventTouchUpInside];
//        [view addSubview:download_button];
//        [view addSubview:resave_button];
        self.footerView=view;
    }
    
    return self.footerView;
}
- (UITableViewCellEditingStyle)tableView:(UITableView *)tableView editingStyleForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return UITableViewCellEditingStyleDelete | UITableViewCellEditingStyleInsert;
}
- (void)tableView:(UITableView *)tableView accessoryButtonTappedForRowWithIndexPath:(NSIndexPath *)indexPath
{
    //    self.selectedIndexPath=indexPath;
    //    [self toMore:self];
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
//    NSDictionary *dic;
//    if (self.segmentedControl.selectedSegmentIndex==0) {
//        //收件箱
//        if (self.inArray) {
//            dic=[self.inArray objectAtIndex:indexPath.row];
//        }
//    }else
//    {
//        //发件箱
//        if (self.outArray) {
//            dic=[self.outArray objectAtIndex:indexPath.row];
//        }
//    }
//    if (dic) {
//    }
//    
}
#pragma mark - SCBEmailManagerDelegate
-(void)detailEmailSucceed:(NSDictionary *)datadic
{
    self.dataDic=datadic;
    if (self.dataDic) {
//        NSArray *emails=(NSArray *)[self.dataDic objectForKey:@"emails"];
//        NSMutableArray *tempInArray=[NSMutableArray array];
//        NSMutableArray *tempOutArray=[NSMutableArray array];
//        for (NSDictionary *dic in emails)
//        {
//            int etype=[[dic objectForKey:@"etype"] intValue];
//            //etype	邮件类型	String，0为收件箱，1为发件箱
//            if (etype ==0) {
//                [tempInArray addObject:dic];
//            }else if(etype==1)
//            {
//                [tempOutArray addObject:dic];
//            }else
//            {
//                NSLog(@"邮件类型出错：%d",etype);
//            }
//        }
//        self.inArray=tempInArray;
//        self.outArray=tempOutArray;
        [self.tableView reloadData];
        [self loadEmail];
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
}
-(void)fileListSucceed:(NSData *)data
{
    NSError *jsonParsingError=nil;
    self.fileArray=[NSJSONSerialization JSONObjectWithData:data options:0 error:&jsonParsingError];
    if (self.fileArray) {
        [self.tableView reloadData];
        NSString *dataFilePath=[YNFunctions getDataCachePath];
        dataFilePath=[dataFilePath stringByAppendingPathComponent:[YNFunctions getFileNameWithFID:[NSString stringWithFormat:@"%@.EmailFileList",self.eid]]];
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

}
#pragma mark - SCBEmailManagerDelegate
-(void)moveUnsucess
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
-(void)moveSucess
{
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
#pragma mark - Deferred image loading (UIScrollViewDelegate)

// Load images for all onscreen rows when scrolling is finished
- (void)scrollViewWillBeginDragging:(UIScrollView *)scrollView
{
    //   [self.ctrlView setHidden:YES];
}
- (void)scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate
{
    if (!decelerate)
	{
        //        if (self.selectedIndexPath) {
        //            //[self hideOptionCell];
        //            return;
        //        }
        [self loadImagesForOnscreenRows];
    }
}

- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView
{
    //    if (self.selectedIndexPath) {
    //        //[self hideOptionCell];
    //        return;
    //    }
    [self loadImagesForOnscreenRows];
}

// this method is used in case the user scrolled into a set of cells that don't have their app icons yet
- (void)loadImagesForOnscreenRows
{
    if ([self.fileArray count] > 0)
    {
        NSArray *visiblePaths = [self.tableView indexPathsForVisibleRows];
        for (NSIndexPath *indexPath in visiblePaths)
        {
            NSDictionary *dic = [self.fileArray objectAtIndex:indexPath.row];
            if (dic==nil) {
                break;
            }
            NSString *fmime=[[dic objectForKey:@"f_mime"] lowercaseString];
            if ([fmime isEqualToString:@"png"]||
                [fmime isEqualToString:@"jpg"]||
                [fmime isEqualToString:@"jpeg"]||
                [fmime isEqualToString:@"bmp"]||
                [fmime isEqualToString:@"gif"]){
                
                NSString *compressaddr=[dic objectForKey:@"fthumb"];
                assert(compressaddr!=nil);
                compressaddr =[YNFunctions picFileNameFromURL:compressaddr];
                NSString *path=[YNFunctions getIconCachePath];
                path=[path stringByAppendingPathComponent:compressaddr];
                
                //"compressaddr":"cimage/cs860183fc-81bd-40c2-817a-59653d0dc513.jpg"
                if (![[NSFileManager defaultManager] fileExistsAtPath:path]) // avoid the app icon download if the app already has an icon
                {
                    NSLog(@"将要下载的文件：%@",path);
                    [self startIconDownload:dic forIndexPath:indexPath];
                }
            }
        }
    }
}
- (void)startIconDownload:(NSDictionary *)dic forIndexPath:(NSIndexPath *)indexPath
{
    if (!self.imageDownloadsInProgress) {
        self.imageDownloadsInProgress=[NSMutableDictionary dictionary];
    }
    IconDownloader *iconDownloader = [self.imageDownloadsInProgress objectForKey:indexPath];
    if (iconDownloader == nil)
    {
        iconDownloader = [[IconDownloader alloc] init];
        iconDownloader.data_dic=dic;
        iconDownloader.indexPathInTableView = indexPath;
        iconDownloader.delegate = self;
        [self.imageDownloadsInProgress setObject:iconDownloader forKey:indexPath];
        [iconDownloader startDownload];
    }
}
- (void)appImageDidLoad:(NSIndexPath *)indexPath;
{
    IconDownloader *iconDownloader = [self.imageDownloadsInProgress objectForKey:indexPath];
    if (iconDownloader != nil)
    {
        [self.tableView reloadRowsAtIndexPaths:@[iconDownloader.indexPathInTableView] withRowAnimation:UITableViewRowAnimationNone];
    }
    
    // Remove the IconDownloader from the in progress list.
    // This will result in it being deallocated.
    [self.imageDownloadsInProgress removeObjectForKey:indexPath];
}

@end
