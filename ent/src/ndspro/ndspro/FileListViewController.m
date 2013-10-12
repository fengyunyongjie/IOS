//
//  FileListViewController.m
//  ndspro
//
//  Created by fengyongning on 13-9-26.
//  Copyright (c) 2013年 fengyongning. All rights reserved.
//

#import "FileListViewController.h"
#import "SCBFileManager.h"
#import "MBProgressHUD.h"
#import "YNFunctions.h"
#import "IconDownloader.h"
#import "SelectFileListViewController.h"
#import "MainViewController.h"
#import "SendEmailViewController.h"

typedef enum{
    kAlertTagDeleteOne,
    kAlertTagDeleteMore,
    kAlertTagRename,
    kAlertTagNewFinder,
    kAlertTagMailAddr,
}AlertTag;
typedef enum{
    kActionSheetTagShare,
    kActionSheetTagMore,
    kActionSheetTagDeleteOne,
    kActionSheetTagDeleteMore,
    kActionSheetTagPhoto,
    kActionSheetTagSend,
    kActionSheetTagSort,
}ActionSheetTag;

@interface FileListViewController ()<SCBFileManagerDelegate,IconDownloaderDelegate,UIScrollViewDelegate,UIAlertViewDelegate,UITextFieldDelegate,UIActionSheetDelegate>
@property (strong,nonatomic) SCBFileManager *fm;
@property (strong,nonatomic) SCBFileManager *fm_move;
@property (strong,nonatomic) MBProgressHUD *hud;

@property (strong,nonatomic) UIToolbar *singleEditBar;
@property (strong,nonatomic) UIToolbar *moreEditBar;
@property (strong,nonatomic) UIView *menuView;

@property (strong,nonatomic) UIBarButtonItem *titleRightBtn;
@end

@implementation FileListViewController

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
- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    self.tableView=[[UITableView alloc] init];
    self.tableView.delegate=self;
    self.tableView.dataSource=self;
    [self.view addSubview:self.tableView];
    self.tableView.frame=CGRectMake(0, 0, self.view.frame.size.width, self.view.frame.size.height);
    NSMutableArray *items=[NSMutableArray array];
    for (int i=0; i<1;i++) {
        UIButton*rightButton = [[UIButton alloc]initWithFrame:CGRectMake(0,0,40,40)];
        [rightButton setImage:[UIImage imageNamed:@"title_more.png"] forState:UIControlStateNormal];
        [rightButton setBackgroundImage:[UIImage imageNamed:@"title_bk.png"] forState:UIControlStateHighlighted];
        [rightButton addTarget:self action:@selector(menuAction:) forControlEvents:UIControlEventTouchUpInside];
        UIBarButtonItem *rightItem = [[UIBarButtonItem alloc] initWithCustomView:rightButton];
        [items addObject:rightItem];
        self.titleRightBtn=rightItem;
    }

    self.navigationItem.rightBarButtonItem=self.titleRightBtn;
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
-(void)hideMenu
{
    [self.menuView setHidden:YES];
}
-(void)hideSingleBar
{
    [self.singleEditBar setHidden:YES];
}
-(void)menuAction:(id)sender
{
    [self hideSingleBar];
    if (!self.menuView) {
        self.menuView=[[UIView alloc] initWithFrame:CGRectMake(150, 64, 161, 47)];
        UIImageView *bgView=[[UIImageView alloc] initWithImage:[UIImage imageNamed:@"title_menu4.png"]];
        [self.menuView addSubview:bgView];
        UIButton *btnUpload,*btnNewFinder,*btnEdit,*btnSort;
        btnUpload=[[UIButton alloc] initWithFrame:CGRectMake(0, 7, 40, 40)];
        [btnUpload setImage:[UIImage imageNamed:@"title_bt_upload_nor.png"] forState:UIControlStateHighlighted];
        [btnUpload setImage:[UIImage imageNamed:@"title_bt_upload_se.png"] forState:UIControlStateNormal];
        [btnUpload setBackgroundImage:[UIImage imageNamed:@"title_se.png"] forState:UIControlStateHighlighted];
        [btnUpload addTarget:self action:@selector(uploadAction:) forControlEvents:UIControlEventTouchUpInside];
        btnNewFinder=[[UIButton alloc] initWithFrame:CGRectMake(40, 7, 40, 40)];
        [btnNewFinder setImage:[UIImage imageNamed:@"title_bt_new_nor.png"] forState:UIControlStateHighlighted];
        [btnNewFinder setImage:[UIImage imageNamed:@"title_bt_new_se.png"] forState:UIControlStateNormal];
        [btnNewFinder setBackgroundImage:[UIImage imageNamed:@"title_se.png"] forState:UIControlStateHighlighted];
        [btnNewFinder addTarget:self action:@selector(newFinder:) forControlEvents:UIControlEventTouchUpInside];
        btnEdit=[[UIButton alloc] initWithFrame:CGRectMake(80, 7, 40, 40)];
        [btnEdit setImage:[UIImage imageNamed:@"title_bt_edit_nor.png"] forState:UIControlStateHighlighted];
        [btnEdit setImage:[UIImage imageNamed:@"title_bt_edit_se.png"] forState:UIControlStateNormal];
        [btnEdit setBackgroundImage:[UIImage imageNamed:@"title_se.png"] forState:UIControlStateHighlighted];
        [btnEdit addTarget:self action:@selector(editAction:) forControlEvents:UIControlEventTouchUpInside];
        btnSort=[[UIButton alloc] initWithFrame:CGRectMake(120, 7, 40, 40)];
        [btnSort setImage:[UIImage imageNamed:@"title_bt_sort_nor.png"] forState:UIControlStateHighlighted];
        [btnSort setImage:[UIImage imageNamed:@"title_bt_sort_se.png"] forState:UIControlStateNormal];
        [btnSort setBackgroundImage:[UIImage imageNamed:@"title_se.png"] forState:UIControlStateHighlighted];
        [btnSort addTarget:self action:@selector(sortAction:) forControlEvents:UIControlEventTouchUpInside];
        [self.menuView addSubview:btnUpload];
        [self.menuView addSubview:btnNewFinder];
        [self.menuView addSubview:btnEdit];
        [self.menuView addSubview:btnSort];
        [self.view addSubview:self.menuView];
    }
    [self.menuView setHidden:!self.menuView.hidden];
}
-(void)uploadAction:(id)sender
{
    [self hideMenu];
}
-(void)newFinder:(id)sender
{
    [self hideMenu];
    NSLog(@"点击新建文件夹");
    UIAlertView *alert=[[UIAlertView alloc] initWithTitle:@"新建文件夹" message:@"" delegate:self cancelButtonTitle:@"取消" otherButtonTitles:@"确定", nil];
    [alert setAlertViewStyle:UIAlertViewStylePlainTextInput];
    [[alert textFieldAtIndex:0] setText:@"新建文件夹"];
    [[alert textFieldAtIndex:0] setDelegate:self];
    [alert setTag:kAlertTagNewFinder];
    [alert show];
}
-(void)editAction:(id)sender
{
    [self hideMenu];
    [self.tableView setEditing:!self.tableView.editing animated:YES];
    BOOL isHideTabBar=self.tableView.editing;
    //isHideTabBar=!isHideTabBar;
    for(UIView *view in self.tabBarController.view.subviews)
    {
        if([view isKindOfClass:[UITabBar class]])
        {
            if (isHideTabBar) { //if hidden tabBar
                [view setFrame:CGRectMake(view.frame.origin.x,[[UIScreen mainScreen]bounds].size.height, view.frame.size.width, view.frame.size.height)];
            }else {
                NSLog(@"isHideTabBar %@",NSStringFromCGRect(view.frame));
                [view setFrame:CGRectMake(view.frame.origin.x, [[UIScreen mainScreen]bounds].size.height-49, view.frame.size.width, view.frame.size.height)];
            }
        }else
        {
            if (isHideTabBar) {
                NSLog(@"%@",NSStringFromCGRect(view.frame));
                [view setFrame:CGRectMake(view.frame.origin.x, view.frame.origin.y, view.frame.size.width, [[UIScreen mainScreen]bounds].size.height)];
                NSLog(@"%@",NSStringFromCGRect(view.frame));
            }else {
                NSLog(@"%@",NSStringFromCGRect(view.frame));
                [view setFrame:CGRectMake(view.frame.origin.x, view.frame.origin.y, view.frame.size.width,[[UIScreen mainScreen]bounds].size.height-49)];
            }
        }
    }
    
    //隐藏返回按钮
    if (isHideTabBar) {
        [self.navigationItem setLeftBarButtonItem:[[UIBarButtonItem alloc] initWithTitle:@"取消" style:UIBarButtonItemStylePlain target:self action:@selector(editAction:)]];
        [self.navigationItem setRightBarButtonItem:nil];
    }else
    {
        [self.navigationItem setLeftBarButtonItem:nil];
        [self.navigationItem setRightBarButtonItem:self.titleRightBtn];
    }
    
    if (!self.moreEditBar) {
        self.moreEditBar=[[UIToolbar alloc] initWithFrame:CGRectMake(0, self.view.frame.size.height-49, 320, 49)];
        if ([YNFunctions systemIsLaterThanString:@"7.0"]) {
            [self.moreEditBar setBarTintColor:[UIColor blueColor]];
        }else
        {
            [self.moreEditBar setTintColor:[UIColor blueColor]];
        }
        [self.view addSubview:self.moreEditBar];
        //发送 删除 提交 移动 全选
        UIButton *btn_send, *btn_commit ,*btn_del ,*btn_more;
        UIBarButtonItem *item_send, *item_commit ,*item_del ,*item_more, *item_flexible;
        
        btn_send =[[UIButton alloc] initWithFrame:CGRectMake(0, 0, 29, 39)];
        [btn_send setImage:[UIImage imageNamed:@"send_nor.png"] forState:UIControlStateNormal];
        [btn_send setImage:[UIImage imageNamed:@"send_se.png"] forState:UIControlStateHighlighted];
        [btn_send addTarget:self action:@selector(toSend:) forControlEvents:UIControlEventTouchUpInside];
        item_send=[[UIBarButtonItem alloc] initWithCustomView:btn_send];
        
        btn_commit =[[UIButton alloc] initWithFrame:CGRectMake(0, 0, 29, 39)];
        [btn_commit setImage:[UIImage imageNamed:@"tj_nor.png"] forState:UIControlStateNormal];
        [btn_commit setImage:[UIImage imageNamed:@"tj_se.png"] forState:UIControlStateHighlighted];
        [btn_commit addTarget:self action:@selector(toCommitOrResave:) forControlEvents:UIControlEventTouchUpInside];
        item_commit=[[UIBarButtonItem alloc] initWithCustomView:btn_commit];
        
        btn_del =[[UIButton alloc] initWithFrame:CGRectMake(0, 0, 29, 39)];
        [btn_del setImage:[UIImage imageNamed:@"del_nor.png"] forState:UIControlStateNormal];
        [btn_del setImage:[UIImage imageNamed:@"del_se.png"] forState:UIControlStateHighlighted];
        [btn_del addTarget:self action:@selector(toDelete:) forControlEvents:UIControlEventTouchUpInside];
        item_del=[[UIBarButtonItem alloc] initWithCustomView:btn_del];
        
        btn_more =[[UIButton alloc] initWithFrame:CGRectMake(0, 0, 29, 39)];
        [btn_more setImage:[UIImage imageNamed:@"move_nor.png"] forState:UIControlStateNormal];
        [btn_more setImage:[UIImage imageNamed:@"move_se.png"] forState:UIControlStateHighlighted];
        [btn_more addTarget:self action:@selector(toMove:) forControlEvents:UIControlEventTouchUpInside];
        item_more=[[UIBarButtonItem alloc] initWithCustomView:btn_more];
        
        item_flexible=[[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace target:nil action:nil];
        //    for (NSString *str in buttons) {
        //        UIButton *button=[[UIButton alloc] initWithFrame:CGRectMake(0, 0, 29, 39)];
        //        [button setImage:[UIImage imageNamed:@"rename_nor.png"] forState:UIControlStateNormal];
        //        [button setImage:[UIImage imageNamed:@"rename_se.png"] forState:UIControlStateHighlighted];
        //        //UIBarButtonItem *item1=[[UIBarButtonItem alloc] initWithTitle:str style:UIBarButtonItemStylePlain target:nil action:nil];
        //        UIBarButtonItem *item1=[[UIBarButtonItem alloc] initWithCustomView:button];
        //        [barItems addObject:item1];
        //    }
        [self.moreEditBar setItems:@[item_send,item_flexible,item_commit,item_flexible,item_del,item_flexible,item_more]];
    }
}
-(void)sortAction:(id)sender
{
    [self hideMenu];
    UIActionSheet *actionSheet=[[UIActionSheet alloc]  initWithTitle:@"排序" delegate:self cancelButtonTitle:@"取消" destructiveButtonTitle:nil otherButtonTitles:@"按时间排序",@"按名称排序",@"按大小排序", nil];
    [actionSheet setTag:kActionSheetTagSort];
    [actionSheet setActionSheetStyle:UIActionSheetStyleDefault];
    [actionSheet showInView:[[UIApplication sharedApplication] keyWindow]];
}
-(void)toMore:(id)sender
{
    UIActionSheet *actionSheet=[[UIActionSheet alloc]  initWithTitle:@"更多" delegate:self cancelButtonTitle:@"取消" destructiveButtonTitle:nil otherButtonTitles:@"移动",@"重命名",@"删除",@"下载",@"发送",@"提交/转存", nil];
    [actionSheet setTag:kActionSheetTagMore];
    [actionSheet setActionSheetStyle:UIActionSheetStyleBlackOpaque];
    [actionSheet showInView:[[UIApplication sharedApplication] keyWindow]];
}
-(void)toRename:(id)sender
{
    NSDictionary *dic=[self.listArray objectAtIndex:self.selectedIndexPath.row];
    NSString *name=[dic objectForKey:@"fname"];
    UIAlertView *alert=[[UIAlertView alloc] initWithTitle:@"重命名" message:@"" delegate:self cancelButtonTitle:@"取消" otherButtonTitles:@"确定", nil];
    [alert setAlertViewStyle:UIAlertViewStylePlainTextInput];
    [[alert textFieldAtIndex:0] setText:name];
    [alert setTag:kAlertTagRename];
    [alert show];
}
-(void)toDelete:(id)sender
{
    //    UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"提示" message:@"是否要删除文件" delegate:self cancelButtonTitle:@"取消" otherButtonTitles:@"确定", nil];
    //    [alertView show];
    //    [alertView setTag:kAlertTagDeleteOne];
    //    [alertView release];
    UIActionSheet *actionSheet=[[UIActionSheet alloc]  initWithTitle:@"是否要删除文件" delegate:self cancelButtonTitle:@"取消" destructiveButtonTitle:@"删除" otherButtonTitles: nil];
    [actionSheet setTag:kActionSheetTagDeleteOne];
    [actionSheet setActionSheetStyle:UIActionSheetStyleBlackOpaque];
    [actionSheet showInView:[[UIApplication sharedApplication] keyWindow]];
}
-(void)toCommitOrResave:(id)sender
{
    NSLog(@"提交或转存！！！");
    if ([self.roletype isEqualToString:@"9999"]) {
        NSLog(@"提交");
        MainViewController *flvc=[[MainViewController alloc] init];
        flvc.title=@"选择提交的位置";
        flvc.delegate=self;
        flvc.type=kTypeCommit;
        UINavigationController *nav=[[UINavigationController alloc] initWithRootViewController:flvc];
        [self presentViewController:nav animated:YES completion:nil];

    }else
    {
        NSLog(@"转存");
        MainViewController *flvc=[[MainViewController alloc] init];
        flvc.title=@"选择转存的位置";
        flvc.delegate=self;
        flvc.type=kTypeResave;
        UINavigationController *nav=[[UINavigationController alloc] initWithRootViewController:flvc];
        [self presentViewController:nav animated:YES completion:nil];
    }
}
-(void)toSend:(id)sender
{
    NSLog(@"发送");
    UIActionSheet *actionSheet=[[UIActionSheet alloc]  initWithTitle:@"发送" delegate:self cancelButtonTitle:@"取消" destructiveButtonTitle:nil otherButtonTitles: @"站内发送",@"站外发送",nil];
    [actionSheet setTag:kActionSheetTagSend];
    [actionSheet setActionSheetStyle:UIActionSheetStyleBlackOpaque];
    [actionSheet showInView:[[UIApplication sharedApplication] keyWindow]];
}
-(void)toMove:(id)sender
{
//    if (self.tableView.editing) {
//        NSMutableArray *f_ids=[NSMutableArray array];
//        for (int i=0;i<self.m_fileItems.count;i++) {
//            FileItem *fileItem=[self.m_fileItems objectAtIndex:i];
//            if (fileItem.checked) {
//                NSDictionary *dic=[self.listArray objectAtIndex:i];
//                NSString *f_id=[dic objectForKey:@"f_id"];
//                [f_ids addObject:f_id];
//            }
//        }
//        if ([f_ids count]==0) {
//            if (self.hud) {
//                [self.hud removeFromSuperview];
//            }
//            self.hud=nil;
//            self.hud=[[MBProgressHUD alloc] initWithView:self.view];
//            [self.view addSubview:self.hud];    [self.hud show:NO];
//            self.hud.labelText=@"未选中任何文件(夹)";
//            self.hud.mode=MBProgressHUDModeText;
//            self.hud.margin=10.f;
//            [self.hud show:YES];
//            [self.hud hide:YES afterDelay:1.0f];
//            return;
//        }
//    }
//    NSMutableArray *willMoveObjects=[[[NSMutableArray alloc] init] autorelease];
//    if ([self.tableView isEditing]) {
//        for (int i=0;i<self.m_fileItems.count;i++) {
//            FileItem *fileItem=[self.m_fileItems objectAtIndex:i];
//            if (fileItem.checked) {
//                NSDictionary *dic=[self.listArray objectAtIndex:i];
//                NSString *m_fid=[dic objectForKey:@"f_id"];
//                [willMoveObjects addObject:m_fid];
//            }
//        }
//        if ([willMoveObjects count]<=0) {
//            return;
//        }
//    }else
//    {
//        NSDictionary *dic=[self.listArray objectAtIndex:self.selectedIndexPath.row-1];
//        NSString *m_fid=[dic objectForKey:@"f_id"];
//        willMoveObjects=@[m_fid];
//    }
//    MyndsViewController *moveViewController=[[[MyndsViewController alloc] init] autorelease];
//    moveViewController.f_id=@"1";
//    moveViewController.movefIds=willMoveObjects;
//    switch (self.myndsType) {
//        case kMyndsTypeDefault:
//        case kMyndsTypeDefaultSearch:
//        {
//            moveViewController.myndsType=kMyndsTypeSelect;
//            //moveViewController.title=@"我的文件";
//            moveViewController.title=@"选择移动位置";
//        }
//            break;
//        case kMyndsTypeShare:
//        case kMyndsTypeShareSearch:
//        {
//            moveViewController.myndsType=kMyndsTypeShareSelect;
//            //moveViewController.title=@"参与共享";
//            moveViewController.title=@"选择移动位置";
//        }
//            break;
//        case kMyndsTypeMyShare:
//        case kMyndsTypeMyShareSearch:
//        {
//            moveViewController.myndsType=kMyndsTypeMyShareSelect;
//            //moveViewController.title=@"我的共享";
//            moveViewController.title=@"选择移动位置";
//        }
//            break;
//        default:
//            break;
//    }
//    moveViewController.delegate=self;
//    UINavigationController *nav=[[UINavigationController alloc] initWithRootViewController:moveViewController];
//    [self presentViewController:nav animated:YES completion:nil];
    SelectFileListViewController *flvc=[[SelectFileListViewController alloc] init];
    flvc.f_id=@"0";
    flvc.roletype=self.roletype;
    flvc.spid=self.spid;
    flvc.title=@"选择移动的位置";
    flvc.delegate=self;
    UINavigationController *nav=[[UINavigationController alloc] initWithRootViewController:flvc];
    [self presentViewController:nav animated:YES completion:nil];
}
-(void)toDownload:(id)sender
{
    NSLog(@"下载");
}
-(void)commitFileToID:(NSString *)f_id sID:(NSString *)s_pid
{
    NSDictionary *dic=[self.listArray objectAtIndex:self.selectedIndexPath.row];
    NSString *fid=[dic objectForKey:@"fid"];
    if (self.fm_move) {
        [self.fm_move cancelAllTask];
    }else
    {
        self.fm_move=[[SCBFileManager alloc] init];
    }
    self.fm_move.delegate=self;
    [self.fm_move commitFileIDs:@[fid] toPID:f_id sID:s_pid];
}
-(void)resaveFileToID:(NSString *)f_id
{
    NSDictionary *dic=[self.listArray objectAtIndex:self.selectedIndexPath.row];
    NSString *fid=[dic objectForKey:@"fid"];
    if (self.fm_move) {
        [self.fm_move cancelAllTask];
    }else
    {
        self.fm_move=[[SCBFileManager alloc] init];
    }
    self.fm_move.delegate=self;
    [self.fm_move resaveFileIDs:@[fid] toPID:f_id];
}
-(void)moveFileToID:(NSString *)f_id
{
    NSDictionary *dic=[self.listArray objectAtIndex:self.selectedIndexPath.row];
    NSString *fid=[dic objectForKey:@"fid"];
    if (self.fm_move) {
        [self.fm_move cancelAllTask];
    }else
    {
        self.fm_move=[[SCBFileManager alloc] init];
    }
    self.fm_move.delegate=self;
    [self.fm_move moveFileIDs:@[fid] toPID:f_id sID:self.spid];
//    NSMutableArray *willMoveObjects=[[[NSMutableArray alloc] init] autorelease];
//    if ([self.tableView isEditing]) {
//        for (int i=0;i<self.m_fileItems.count;i++) {
//            FileItem *fileItem=[self.m_fileItems objectAtIndex:i];
//            if (fileItem.checked) {
//                NSDictionary *dic=[self.listArray objectAtIndex:i];
//                NSString *m_fid=[dic objectForKey:@"f_id"];
//                if ([f_id intValue]==[m_fid intValue]) {
//                    if (self.hud) {
//                        [self.hud removeFromSuperview];
//                    }
//                    self.hud=nil;
//                    self.hud=[[MBProgressHUD alloc] initWithView:self.view];
//                    [self.view addSubview:self.hud];
//                    [self.hud show:NO];
//                    self.hud.labelText=@"您当前操作有误";
//                    self.hud.mode=MBProgressHUDModeText;
//                    self.hud.margin=10.f;
//                    [self.hud show:YES];
//                    [self.hud hide:YES afterDelay:1.0f];
//                    return;
//                }
//                [willMoveObjects addObject:m_fid];
//            }
//        }
//        if ([willMoveObjects count]<=0) {
//            return;
//        }
//    }else
//    {
//        NSDictionary *dic=[self.listArray objectAtIndex:self.selectedIndexPath.row-1];
//        NSString *m_fid=[dic objectForKey:@"f_id"];
//        if ([f_id intValue]==[m_fid intValue]) {
//            if (self.hud) {
//                [self.hud removeFromSuperview];
//            }
//            self.hud=nil;
//            self.hud=[[MBProgressHUD alloc] initWithView:self.view];
//            [self.view addSubview:self.hud];
//            [self.hud show:NO];
//            self.hud.labelText=@"您当前操作有误";
//            self.hud.mode=MBProgressHUDModeText;
//            self.hud.margin=10.f;
//            [self.hud show:YES];
//            [self.hud hide:YES afterDelay:1.0f];
//            return;
//        }
//        willMoveObjects=@[m_fid];
//    }
//    switch (self.myndsType) {
//        case kMyndsTypeDefault:
//        case kMyndsTypeDefaultSearch:
//        {
//            if (self.fm_move) {
//                [self.fm_move cancelAllTask];
//            }else
//            {
//                self.fm_move=[[[SCBFileManager alloc] init] autorelease];
//            }
//            self.fm_move.delegate=self;
//            [self.fm_move moveFileIDs:willMoveObjects toPID:f_id];
//        }
//            break;
//        case kMyndsTypeMyShareSearch:
//        case kMyndsTypeShare:
//        case kMyndsTypeMyShare:
//        case kMyndsTypeShareSearch:
//        {
//            if (self.sm_move) {
//                [self.sm_move cancelAllTask];
//            }else
//            {
//                self.sm_move=[[[SCBShareManager alloc] init] autorelease];
//            }
//            self.sm_move.delegate=self;
//            [self.sm_move moveFileIDs:willMoveObjects toPID:f_id];
//        }
//            break;
//        default:
//            break;
//    }
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
        
        NSString *osVersion = [[UIDevice currentDevice] systemVersion];
        NSString *versionWithoutRotation = @"7.0";
        BOOL noRotationNeeded = ([versionWithoutRotation compare:osVersion options:NSNumericSearch]
                                 != NSOrderedDescending);
        if (noRotationNeeded) {
            cell.accessoryType=UITableViewCellAccessoryDetailButton;
        }else
        {
            cell.accessoryType=UITableViewCellAccessoryDetailDisclosureButton;
        }
    }
    if (self.listArray) {
        NSDictionary *dic=[self.listArray objectAtIndex:indexPath.row];
        if (dic) {
            cell.textLabel.text=[dic objectForKey:@"fname"];
            NSString *fisdir=[dic objectForKey:@"fisdir"];
            if ([fisdir isEqualToString:@"0"]) {
                cell.detailTextLabel.text=[NSString stringWithFormat:@"%@",[dic objectForKey:@"fmodify"]];
                cell.imageView.image=[UIImage imageNamed:@"file_folder.png"];
            }else
            {
                cell.imageView.image=[UIImage imageNamed:@"file_other.png"];
                cell.detailTextLabel.text=[NSString stringWithFormat:@"%@ %@",[dic objectForKey:@"fmodify"],[YNFunctions convertSize:[dic objectForKey:@"fsize"]]];
                NSString *fname=[dic objectForKey:@"fname"];
                NSString *fmime=[[fname pathExtension] lowercaseString];
//                NSString *fmime=[[dic objectForKey:@"fmime"] lowercaseString];
                NSLog(@"fmime:%@",fmime);
                if ([fmime isEqualToString:@"png"]||
                    [fmime isEqualToString:@"jpg"]||
                    [fmime isEqualToString:@"jpeg"]||
                    [fmime isEqualToString:@"bmp"]||
                    [fmime isEqualToString:@"gif"])
                {
                    NSString *fthumb=[dic objectForKey:@"fthumb"];
                    NSString *localThumbPath=[YNFunctions getIconCachePath];
                    fthumb =[YNFunctions picFileNameFromURL:fthumb];
                    localThumbPath=[localThumbPath stringByAppendingPathComponent:fthumb];
                    NSLog(@"是否存在文件：%@",localThumbPath);
                    if ([[NSFileManager defaultManager] fileExistsAtPath:localThumbPath]) {
                        NSLog(@"存在文件：%@",localThumbPath);
                        UIImage *icon=[UIImage imageWithContentsOfFile:localThumbPath];
                        CGSize itemSize = CGSizeMake(100, 100);
                        UIGraphicsBeginImageContext(itemSize);
                        CGRect theR=CGRectMake(0, 0, itemSize.width, itemSize.height);
                        if (icon.size.width>icon.size.height) {
                            theR.size.width=icon.size.width/(icon.size.height/itemSize.height);
                            theR.origin.x=-(theR.size.width/2)-itemSize.width;
                        }else
                        {
                            theR.size.height=icon.size.height/(icon.size.width/itemSize.width);
                            theR.origin.y=-(theR.size.height/2)-itemSize.height;
                        }
                        CGRect imageRect = CGRectMake(2, 2, 96, 96);
//                        CGSize size=icon.size;
//                        if (size.width>size.height) {
//                            imageRect.size.height=size.height*(30.0f/imageRect.size.width);
//                            imageRect.origin.y+=(30-imageRect.size.height)/2;
//                        }else{
//                            imageRect.size.width=size.width*(30.0f/imageRect.size.height);
//                            imageRect.origin.x+=(30-imageRect.size.width)/2;
//                        }
                        [icon drawInRect:imageRect];
                        UIImage *image = UIGraphicsGetImageFromCurrentImageContext();
                        UIGraphicsEndImageContext();
                        cell.imageView.image = image;
                        CGRect r=cell.imageView.frame;
                        r.size.width=r.size.height=30;
                        cell.imageView.frame=r;

                    }else{
                        NSLog(@"将要下载的文件：%@",localThumbPath);
                        [self startIconDownload:dic forIndexPath:indexPath];
                    }
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
    return cell;
}
-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 50;
}

#pragma mark - Table view delegate
- (UITableViewCellEditingStyle)tableView:(UITableView *)tableView editingStyleForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return UITableViewCellEditingStyleDelete | UITableViewCellEditingStyleInsert;
}
- (void)tableView:(UITableView *)tableView accessoryButtonTappedForRowWithIndexPath:(NSIndexPath *)indexPath
{
    self.selectedIndexPath=indexPath;
    //显示单选操作菜单
    if (!self.singleEditBar) {
        self.singleEditBar=[[UIToolbar alloc] initWithFrame:CGRectMake(0, 0, 320, 50)];
        if ([YNFunctions systemIsLaterThanString:@"7.0"]) {
            [self.singleEditBar setBarTintColor:[UIColor blueColor]];
        }else
        {
            [self.singleEditBar setTintColor:[UIColor blueColor]];
        }
        //[self.singleEditBar setBackgroundImage:[UIImage imageNamed:@"title_se.png"] forToolbarPosition:UIBarPositionAny barMetrics:UIBarMetricsDefault];
        [self.singleEditBar setBarStyle:UIBarStyleBlackOpaque];
        [self.tableView addSubview:self.singleEditBar];
        [self.tableView bringSubviewToFront:self.singleEditBar];
    }
    [self.singleEditBar setHidden:NO];
    CGRect r=self.singleEditBar.frame;
    r.origin.y=(indexPath.row+1) * 50;
    self.singleEditBar.frame=r;
    
//    NSArray *buttons=@[@"移动",@"重命名",@"删除",@"下载",@"发送",@"提交/转存"];
    //发送 提交 删除 更多
//    NSMutableArray *barItems=[NSMutableArray array];
    UIButton *btn_send, *btn_commit ,*btn_del ,*btn_more;
    UIBarButtonItem *item_send, *item_commit ,*item_del ,*item_more, *item_flexible;
    
    btn_send =[[UIButton alloc] initWithFrame:CGRectMake(0, 0, 29, 39)];
    [btn_send setImage:[UIImage imageNamed:@"send_nor.png"] forState:UIControlStateNormal];
    [btn_send setImage:[UIImage imageNamed:@"send_se.png"] forState:UIControlStateHighlighted];
    [btn_send addTarget:self action:@selector(toSend:) forControlEvents:UIControlEventTouchUpInside];
    item_send=[[UIBarButtonItem alloc] initWithCustomView:btn_send];
    
    btn_commit =[[UIButton alloc] initWithFrame:CGRectMake(0, 0, 29, 39)];
    [btn_commit setImage:[UIImage imageNamed:@"tj_nor.png"] forState:UIControlStateNormal];
    [btn_commit setImage:[UIImage imageNamed:@"tj_se.png"] forState:UIControlStateHighlighted];
    [btn_commit addTarget:self action:@selector(toCommitOrResave:) forControlEvents:UIControlEventTouchUpInside];
    item_commit=[[UIBarButtonItem alloc] initWithCustomView:btn_commit];
    
    btn_del =[[UIButton alloc] initWithFrame:CGRectMake(0, 0, 29, 39)];
    [btn_del setImage:[UIImage imageNamed:@"del_nor.png"] forState:UIControlStateNormal];
    [btn_del setImage:[UIImage imageNamed:@"del_se.png"] forState:UIControlStateHighlighted];
    [btn_del addTarget:self action:@selector(toDelete:) forControlEvents:UIControlEventTouchUpInside];
    item_del=[[UIBarButtonItem alloc] initWithCustomView:btn_del];
    
    btn_more =[[UIButton alloc] initWithFrame:CGRectMake(0, 0, 29, 39)];
    [btn_more setImage:[UIImage imageNamed:@"more_nor.png"] forState:UIControlStateNormal];
    [btn_more setImage:[UIImage imageNamed:@"more_se.png"] forState:UIControlStateHighlighted];
    [btn_more addTarget:self action:@selector(toMore:) forControlEvents:UIControlEventTouchUpInside];
    item_more=[[UIBarButtonItem alloc] initWithCustomView:btn_more];
    
    item_flexible=[[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace target:nil action:nil];
//    for (NSString *str in buttons) {
//        UIButton *button=[[UIButton alloc] initWithFrame:CGRectMake(0, 0, 29, 39)];
//        [button setImage:[UIImage imageNamed:@"rename_nor.png"] forState:UIControlStateNormal];
//        [button setImage:[UIImage imageNamed:@"rename_se.png"] forState:UIControlStateHighlighted];
//        //UIBarButtonItem *item1=[[UIBarButtonItem alloc] initWithTitle:str style:UIBarButtonItemStylePlain target:nil action:nil];
//        UIBarButtonItem *item1=[[UIBarButtonItem alloc] initWithCustomView:button];
//        [barItems addObject:item1];
//    }
    [self.singleEditBar setItems:@[item_send,item_flexible,item_commit,item_flexible,item_del,item_flexible,item_more]];
 //   [self toMore:self];
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (self.tableView.editing) {
        return;
    }
    if (self.listArray) {
        NSDictionary *dic=[self.listArray objectAtIndex:indexPath.row];
        if (dic) {
            NSString *fisdir=[dic objectForKey:@"fisdir"];
            if ([fisdir isEqualToString:@"0"]) {
                FileListViewController *flVC=[[FileListViewController alloc] init];
                flVC.spid=self.spid;
                flVC.f_id=[dic objectForKey:@"fid"];
                flVC.title=[dic objectForKey:@"fname"];
                [self.navigationController pushViewController:flVC animated:YES];
            }
        }
    }
}
- (void)tableView:(UITableView *)tableView didDeselectRowAtIndexPath:(NSIndexPath *)indexPath{
    if (self.tableView.editing) {
        return;
    }
}
#pragma mark - SCBFileManagerDelegate
-(void)openFinderSucess:(NSDictionary *)datadic
{
    self.dataDic=datadic;
    if (self.dataDic) {
        self.listArray=self.listArray=(NSArray *)[self.dataDic objectForKey:@"files"];
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
-(void)renameSucess
{
    [self operateUpdate];
}
-(void)renameUnsucess
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
-(void)removeSucess
{
//    if (self.willDeleteObjects) {
//        [self removeFromDicWithObjects:self.willDeleteObjects];
//        [self.tableView reloadData];
//    }
    
    //[self.tableView reloadData];
    [self operateUpdate];
//    if (self.hud) {
//        [self.hud removeFromSuperview];
//    }
//    self.hud=nil;
//    self.hud=[[MBProgressHUD alloc] initWithView:self.view];
//    [self.view addSubview:self.hud];    [self.hud show:NO];
//    self.hud.labelText=@"操作成功";
//    self.hud.mode=MBProgressHUDModeText;
//    self.hud.margin=10.f;
//    [self.hud show:YES];
//    [self.hud hide:YES afterDelay:1.0f];
}
-(void)removeUnsucess
{
    NSLog(@"openFinderUnsucess: 网络连接失败!!");
    [self updateFileList];
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
    [self operateUpdate];
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
    if ([self.listArray count] > 0)
    {
        NSArray *visiblePaths = [self.tableView indexPathsForVisibleRows];
        for (NSIndexPath *indexPath in visiblePaths)
        {
            NSDictionary *dic = [self.listArray objectAtIndex:indexPath.row];
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
#pragma mark - UIAlertViewDelegate Methods
- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    switch (alertView.tag) {
        case kAlertTagDeleteOne:
        {
        }
        case kAlertTagRename:
        {
            if (buttonIndex==1) {
                NSDictionary *dic=[self.listArray objectAtIndex:self.selectedIndexPath.row];
                NSString *name=[dic objectForKey:@"fname"];
                NSString *f_id=[dic objectForKey:@"fid"];
                NSString *fildtext=[[alertView textFieldAtIndex:0] text];
                if (![fildtext isEqualToString:name]) {
                    NSLog(@"重命名");
                    [self.fm cancelAllTask];
                    self.fm=[[SCBFileManager alloc] init];
                    [self.fm renameWithID:f_id newName:fildtext sID:self.spid];
                    [self.fm setDelegate:self];
                }
                NSLog(@"点击确定");
            }else
            {
                NSLog(@"点击其它");
            }
            //[self hideOptionCell];
            break;
        }
        case kAlertTagMailAddr:
        {
//            if (buttonIndex==1) {
//                NSString *fildtext=[[alertView textFieldAtIndex:0] text];
//                if (![self checkIsEmail:fildtext])
//                {
//                    if (self.hud) {
//                        [self.hud removeFromSuperview];
//                    }
//                    self.hud=nil;
//                    self.hud=[[MBProgressHUD alloc] initWithView:self.view];
//                    [self.view addSubview:self.hud];
//                    [self.hud show:NO];
//                    self.hud.labelText=@"输入的邮箱地址非法";
//                    //self.hud.labelText=error_info;
//                    self.hud.mode=MBProgressHUDModeText;
//                    self.hud.margin=10.f;
//                    [self.hud show:YES];
//                    [self.hud hide:YES afterDelay:1.0f];
//                    return;
//                }
//                if (self.tableView.editing) {
//                    NSMutableArray *f_ids=[NSMutableArray array];
//                    BOOL hasDir=NO;
//                    for (int i=0;i<self.m_fileItems.count;i++) {
//                        FileItem *fileItem=[self.m_fileItems objectAtIndex:i];
//                        if (fileItem.checked) {
//                            NSDictionary *dic=[self.listArray objectAtIndex:i];
//                            NSString *f_id=[dic objectForKey:@"f_id"];
//                            NSString *f_mime=[[dic objectForKey:@"f_mime"] lowercaseString];
//                            if (![f_mime isEqualToString:@"directory"]) {
//                                [f_ids addObject:f_id];
//                            }else
//                            {
//                                hasDir=YES;
//                            }
//                        }
//                    }
//                    SCBLinkManager *lm_temp=[[[SCBLinkManager alloc] init] autorelease];
//                    [lm_temp setDelegate:self];
//                    [lm_temp releaseLinkEmail:f_ids l_pwd:@"a1b2" receiver:@[fildtext]];
//                    
//                }else
//                {
//                    if (self.selectedIndexPath) {
//                        NSDictionary *dic=[self.listArray objectAtIndex:self.selectedIndexPath.row-1];
//                        NSString *f_id=[dic objectForKey:@"f_id"];
//                        
//                        SCBLinkManager *lm_temp=[[[SCBLinkManager alloc] init] autorelease];
//                        [lm_temp setDelegate:self];
//                        //                        [lm_temp linkWithIDs:@[f_id]];
//                        [lm_temp releaseLinkEmail:@[f_id] l_pwd:@"a1b2" receiver:@[fildtext]];
//                        [self hideOptionCell];
//                    }
//                }
//                
//                NSLog(@"点击确定");
//            }else
//            {
//                NSLog(@"点击其它");
//            }
//            [self hideOptionCell];
            break;
        }
        case kAlertTagDeleteMore:
        {
            break;
        }
        case kAlertTagNewFinder:
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
            //[self hideOptionCell];
            break;
        }
        default:
            break;
    }
}
#pragma mark - UIActionSheetDelegate
- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex
{
    switch ([actionSheet tag]) {
        case kActionSheetTagSort:
        {
            if (buttonIndex==0) {
                //时间排序
                [YNFunctions setDesc:@"time"];
                [self updateFileList];
            }else if(buttonIndex==1)
            {
                //名称排序
                [YNFunctions setDesc:@"name"];
                [self updateFileList];
            }else if (buttonIndex==2)
            {
                //大小排序
                [YNFunctions setDesc:@"size"];
                [self updateFileList];
            }
        }
            break;
        case kActionSheetTagSend:
        {
            NSDictionary *dic=[self.listArray objectAtIndex:self.selectedIndexPath.row];
            NSString *fid=[dic objectForKey:@"fid"];
            SendEmailViewController *sevc=[[SendEmailViewController alloc] init];
            sevc.title=@"新邮件";
            sevc.fids=@[fid];
            if (buttonIndex==0) {
                //站内发送
                sevc.tyle=kTypeSentIn;
            }else if(buttonIndex==1)
            {
                //站外发送
                sevc.tyle=kTypeSendEx;
            }
            UINavigationController *nav=[[UINavigationController alloc] initWithRootViewController:sevc];
            [self presentViewController:nav animated:YES completion:nil];
        }
            break;
        case kActionSheetTagDeleteOne:
        {
            if (buttonIndex==0) {
                NSDictionary *dic=[self.listArray objectAtIndex:self.selectedIndexPath.row];
                NSString *f_id=[dic objectForKey:@"fid"];
                [self.fm cancelAllTask];
                self.fm=[[SCBFileManager alloc] init];
                self.fm.delegate=self;
                [self.fm removeFileWithIDs:@[f_id]];
            }
//            [self hideOptionCell];
            break;
        }
        case kActionSheetTagDeleteMore:
        {
//            if (buttonIndex==0) {
//                NSMutableArray *f_ids=[NSMutableArray array];
//                NSMutableArray *deleteObjects=[NSMutableArray array];
//                for (int i=0;i<self.m_fileItems.count;i++) {
//                    FileItem *fileItem=[self.m_fileItems objectAtIndex:i];
//                    if (fileItem.checked) {
//                        NSDictionary *dic=[self.listArray objectAtIndex:i];
//                        NSString *f_id=[dic objectForKey:@"f_id"];
//                        [f_ids addObject:f_id];
//                        [deleteObjects addObject:dic];
//                    }
//                }
//                self.willDeleteObjects=deleteObjects;
//                //[self removeFromDicWithObjects:deleteObjects];
//                //[self.tableView reloadData];
//                if (f_ids.count>0) {
//                    
//                    switch (self.myndsType) {
//                        case kMyndsTypeDefault:
//                        case kMyndsTypeDefaultSearch:
//                        {
//                            [self.fm cancelAllTask];
//                            self.fm=[[[SCBFileManager alloc] init] autorelease];
//                            self.fm.delegate=self;
//                            [self.fm removeFileWithIDs:f_ids];
//                        }
//                            break;
//                        case kMyndsTypeMyShareSearch:
//                        case kMyndsTypeShare:
//                        case kMyndsTypeMyShare:
//                        case kMyndsTypeShareSearch:
//                        {
//                            [self.sm cancelAllTask];
//                            self.sm=[[[SCBShareManager alloc] init] autorelease];
//                            self.sm.delegate=self;
//                            [self.sm removeFileWithIDs:f_ids];
//                        }
//                            break;
//                        default:
//                            break;
//                    }
//                }
//                
//            }
            break;
        }
            
        case kActionSheetTagMore:
            if (buttonIndex == 0) {
                NSLog(@"移动");
                [self toMove:nil];
            }else if (buttonIndex == 1) {
                NSLog(@"重命名");
                [self toRename:nil];
            }else if(buttonIndex == 2) {
                NSLog(@"删除");
                [self toDelete:nil];
            }else if(buttonIndex == 3) {
                NSLog(@"下载");
            }else if(buttonIndex == 4) {
                NSLog(@"发送");
                [self toSend:nil];
            }else if(buttonIndex == 5) {
                NSLog(@"提交/转存");
                [self toCommitOrResave:nil];
            }
            else if(buttonIndex == 6) {
                NSLog(@"取消");
            }
            break;
        case kActionSheetTagShare:
            {
//            if (buttonIndex == 0) {
//                NSLog(@"短信分享");
//                //[self toDelete:nil];
//                [self messageShare:actionSheet.title];
//            }else if (buttonIndex == 1) {
//                NSLog(@"邮件分享");
//                //[self toShared:nil];
//                //[self mailShare:actionSheet.title];
//                [self praMailShare:actionSheet.title];
//            }else if(buttonIndex == 2) {
//                NSLog(@"复制");
//                [self pasteBoard:actionSheet.title];
//            }else if(buttonIndex == 3) {
//                NSLog(@"微信");
//                [self weixin:actionSheet.title];
//            }else if(buttonIndex == 4) {
//                NSLog(@"朋友圈");
//                [self frends:actionSheet.title];
//            }else if(buttonIndex == 5) {
//                NSLog(@"新浪");
//            }else if(buttonIndex == 6) {
//                NSLog(@"取消");
//            }
            }
            break;
        case kActionSheetTagPhoto:
        {
//            NSDictionary *dic=[self.listArray objectAtIndex:[actionSheet.title intValue]];
//            if (buttonIndex==0) {
//                NSMutableArray *array=[NSMutableArray array];
//                int index=0;
//                for (int i=0;i<self.listArray.count;i++) {
//                    NSDictionary *dict=[self.listArray objectAtIndex:i];
//                    NSString *f_mime=[[dict objectForKey:@"f_mime"] lowercaseString];
//                    if ([f_mime isEqualToString:@"png"]||
//                        [f_mime isEqualToString:@"jpg"]||
//                        [f_mime isEqualToString:@"jpeg"]||
//                        [f_mime isEqualToString:@"bmp"]||
//                        [f_mime isEqualToString:@"gif"]) {
//                        PhotoFile *demo = [[PhotoFile alloc] init];
//                        [demo setF_date:[dict objectForKey:@"f_create"]];
//                        [demo setF_id:[[dict objectForKey:@"f_id"] intValue]];
//                        [demo setF_name:[dic objectForKey:@"f_name"]];
//                        [array addObject:demo];
//                        
//                        if (i==[actionSheet.title intValue]) {
//                            index=array.count-1;
//                        }
//                        [demo release];
//                    }
//                }
//                PhotoLookViewController *photoLookViewController = [[PhotoLookViewController alloc] init];
//                [photoLookViewController setHidesBottomBarWhenPushed:YES];
//                [photoLookViewController setCurrPage:index];
//                [photoLookViewController setTableArray:array];
//                [self presentModalViewController:photoLookViewController animated:YES];
//                [photoLookViewController release];
//            }else if(buttonIndex==1)
//            {
//                NSString *filePath=[YNFunctions getFMCachePath];
//                filePath=[filePath stringByAppendingPathComponent:[dic objectForKey:@"f_name"]];
//                if ([[NSFileManager defaultManager] fileExistsAtPath:filePath]) {
//                    QLBrowserViewController *previewController=[[QLBrowserViewController alloc] init];
//                    previewController.dataSource=self;
//                    previewController.delegate=self;
//                    
//                    previewController.currentPreviewItemIndex=0;
//                    [previewController setHidesBottomBarWhenPushed:YES];
//                    //            [self.navigationController pushViewController:previewController animated:YES];
//                    //[self presentModalViewController:previewController animated:YES];
//                    [self presentViewController:previewController animated:YES completion:^(void){
//                        NSLog(@"%@",previewController);
//                    }];
//                    //            [self.navigationController.toolbar setBarStyle:UIBarStyleBlack];
//                }else{
//                    OtherBrowserViewController *otherBrowser=[[[OtherBrowserViewController alloc] initWithNibName:@"OtherBrowser" bundle:nil]  autorelease];
//                    //[otherBrowser setHidesBottomBarWhenPushed:YES];
//                    otherBrowser.dataDic=dic;
//                    NSString *f_name=[dic objectForKey:@"f_name"];
//                    otherBrowser.title=f_name;
//                    [self.navigationController pushViewController:otherBrowser animated:YES];
//                    MYTabBarController *myTabbar = (MYTabBarController *)[self tabBarController];
//                    [myTabbar setHidesTabBarWithAnimate:YES];
//                }
//            }else
//            {
//            }
        }
            break;
        default:
            break;
    }
}
@end
