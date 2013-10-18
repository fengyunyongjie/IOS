//
//  UpDownloadViewController.m
//  ndspro
//
//  Created by fengyongning on 13-9-29.
//  Copyright (c) 2013年 fengyongning. All rights reserved.
//

#import "UpDownloadViewController.h"
#import "AppDelegate.h"
#import "SCBSession.h"
#import "YNFunctions.h"

#define UpTabBarHeight (49+20+44)
#define kActionSheetTagDelete 77
#define kActionSheetTagAllDelete 78

@interface UpDownloadViewController ()

@end

@implementation UpDownloadViewController
@synthesize table_view,upLoading_array,upLoaded_array,downLoading_array,downLoaded_array,customSelectButton,isShowUpload,deleteObject,menuView,editView,rightItem,hud,isStartUpload,isStartDown,btnStart;


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
    UIButton*rightButton = [[UIButton alloc]initWithFrame:CGRectMake(0,0,40,40)];
    [rightButton setImage:[UIImage imageNamed:@"title_more.png"] forState:UIControlStateNormal];
    [rightButton setBackgroundImage:[UIImage imageNamed:@"title_bk.png"] forState:UIControlStateHighlighted];
    [rightButton addTarget:self action:@selector(menuAction:) forControlEvents:UIControlEventTouchUpInside];
    rightItem = [[UIBarButtonItem alloc] initWithCustomView:rightButton];
    self.navigationItem.rightBarButtonItem=rightItem;
    
    isShowUpload = YES;
    CGRect customRect = CGRectMake(0, 0, 320, 30);
    self.customSelectButton = [[CustomSelectButton alloc] initWithFrame:customRect leftText:@"正在上传" rightText:@"正在下载" isShowLeft:isShowUpload];
    [self.customSelectButton setDelegate:self];
    [self.customSelectButton setBackgroundColor:[UIColor lightGrayColor]];
    [self.view addSubview:self.customSelectButton];
    
    UISwipeGestureRecognizer *recognizer;
    
    recognizer = [[UISwipeGestureRecognizer alloc]initWithTarget:self action:@selector(rightSwipeFrom)];
    [recognizer setDirection:(UISwipeGestureRecognizerDirectionRight)];
    [[self view] addGestureRecognizer:recognizer];
    recognizer = nil;
    recognizer = [[UISwipeGestureRecognizer alloc]initWithTarget:self action:@selector(leftSwipeFrom)];
    [recognizer setDirection:(UISwipeGestureRecognizerDirectionLeft)];
    [[self view] addGestureRecognizer:recognizer];
    
    //加载列表
    CGRect table_rect = CGRectMake(0, customRect.origin.y+customRect.size.height, 320, self.view.frame.size.height-(customRect.origin.y+customRect.size.height)-UpTabBarHeight);
    self.table_view = [[UITableView alloc] initWithFrame:table_rect];
    self.table_view.delegate = self;
    self.table_view.dataSource = self;
    [self.view addSubview:self.table_view];
}

-(void)menuAction:(id)sender
{
    if (!self.menuView) {
        self.menuView =[[UIControl alloc] initWithFrame:CGRectMake(0, 0, 320, self.view.frame.size.height)];
        UIView * mView=[[UIView alloc] initWithFrame:CGRectMake(220, 0, 80, 47)];
        UIImageView *bgView=[[UIImageView alloc] initWithImage:[UIImage imageNamed:@"title_menu2@2x.png"]];
        [bgView setFrame:CGRectMake(0, 0, 80, 47)];
        [mView addSubview:bgView];
        UIButton *btnEdit;
        btnEdit=[[UIButton alloc] initWithFrame:CGRectMake(0, 7, 40, 40)];
        [btnEdit setImage:[UIImage imageNamed:@"title_bt_edit_nor@2x.png"] forState:UIControlStateHighlighted];
        [btnEdit setImage:[UIImage imageNamed:@"title_bt_edit_se@2x.png"] forState:UIControlStateNormal];
        [btnEdit setBackgroundImage:[UIImage imageNamed:@"title_se.png"] forState:UIControlStateHighlighted];
        [btnEdit addTarget:self action:@selector(editAction:) forControlEvents:UIControlEventTouchUpInside];
        [mView addSubview:btnEdit];
        
        btnStart=[[UIButton alloc] initWithFrame:CGRectMake(40, 7, 40, 40)];
        [btnStart setImage:[UIImage imageNamed:@"title_bt_start_nor.png"] forState:UIControlStateHighlighted];
        [btnStart setImage:[UIImage imageNamed:@"title_bt_start_se.png"] forState:UIControlStateNormal];
        [btnStart setBackgroundImage:[UIImage imageNamed:@"title_se.png"] forState:UIControlStateHighlighted];
        [btnStart addTarget:self action:@selector(start:) forControlEvents:UIControlEventTouchUpInside];
        [mView addSubview:btnStart];
        
        [self.menuView addSubview:mView];
        [self.menuView addTarget:self action:@selector(hideMenu) forControlEvents:UIControlEventTouchUpInside];
        [self.view addSubview:self.menuView];
    }
    else
    {
        [self.menuView setHidden:!self.menuView.hidden];
    }
    
    AppDelegate *delegate = [[UIApplication sharedApplication] delegate];
    
    if(isShowUpload)
    {
        if(delegate.uploadmanage.isStart)
        {
            [btnStart setImage:[UIImage imageNamed:@"title_bt_pause_nor.png"] forState:UIControlStateHighlighted];
            [btnStart setImage:[UIImage imageNamed:@"title_bt_pause_se.png"] forState:UIControlStateNormal];
            [btnStart setBackgroundImage:[UIImage imageNamed:@"title_se.png"] forState:UIControlStateHighlighted];
        }
        else
        {
            [btnStart setImage:[UIImage imageNamed:@"title_bt_start_nor.png"] forState:UIControlStateHighlighted];
            [btnStart setImage:[UIImage imageNamed:@"title_bt_start_se.png"] forState:UIControlStateNormal];
            [btnStart setBackgroundImage:[UIImage imageNamed:@"title_se.png"] forState:UIControlStateHighlighted];
        }
    }
    else
    {
        if(delegate.downmange.isStart)
        {
            [btnStart setImage:[UIImage imageNamed:@"title_bt_pause_nor.png"] forState:UIControlStateHighlighted];
            [btnStart setImage:[UIImage imageNamed:@"title_bt_pause_se.png"] forState:UIControlStateNormal];
            [btnStart setBackgroundImage:[UIImage imageNamed:@"title_se.png"] forState:UIControlStateHighlighted];
        }
        else
        {
            [btnStart setImage:[UIImage imageNamed:@"title_bt_start_nor.png"] forState:UIControlStateHighlighted];
            [btnStart setImage:[UIImage imageNamed:@"title_bt_start_se.png"] forState:UIControlStateNormal];
            [btnStart setBackgroundImage:[UIImage imageNamed:@"title_se.png"] forState:UIControlStateHighlighted];
        }
    }
}

-(void)editAction:(id)sender
{
    [self.menuView setHidden:YES];
    [self.table_view setEditing:!self.table_view.editing animated:YES];
    [self.table_view reloadData];
    
    BOOL isHideTabBar=self.table_view.editing;
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
    if(self.editView == nil)
    {
        self.editView = [[UIButton alloc] initWithFrame:CGRectMake(0, self.view.frame.size.height-49, 320, 60)];
        [self.editView setBackgroundImage:[UIImage imageNamed:@"bk_select.png"] forState:UIControlStateNormal];
        [self.editView addTarget:self action:@selector(deleteAll:) forControlEvents:UIControlEventTouchUpInside];
        [self.view addSubview:self.editView];
        //删除
        UIButton *btn_del=[[UIButton alloc] initWithFrame:CGRectMake((320-29)/2, 5, 29, 39)];
        [btn_del setImage:[UIImage imageNamed:@"del_nor.png"] forState:UIControlStateNormal];
        [btn_del setImage:[UIImage imageNamed:@"del_se.png"] forState:UIControlStateHighlighted];
        [btn_del setUserInteractionEnabled:NO];
        [self.editView addSubview:btn_del];
        
    }
    //隐藏按钮
    if (isHideTabBar) {
        [self.navigationItem setLeftBarButtonItem:[[UIBarButtonItem alloc] initWithTitle:@"取消" style:UIBarButtonItemStylePlain target:self action:@selector(editAction:)]];
        [self.navigationItem setRightBarButtonItem:[[UIBarButtonItem alloc] initWithTitle:@"全选" style:UIBarButtonItemStylePlain target:self action:@selector(selectAllCell:)]];
    }else
    {
        [self.navigationItem setLeftBarButtonItem:nil];
        [self.navigationItem setRightBarButtonItem:self.rightItem];
    }
}

-(void)hideMenu
{
    [self.menuView setHidden:YES];
}

-(void)start:(id)sender
{
    [self.menuView setHidden:YES];
    AppDelegate *appDelegate = [[UIApplication sharedApplication] delegate];
    if(isShowUpload)
    {
        if(!isStartUpload)
        {
            [appDelegate.uploadmanage start];
            isStartUpload = YES;
        }
        else
        {
            [appDelegate.uploadmanage stopAllUpload];
            isStartUpload = NO;
        }
    }
    else
    {
        if(!isStartDown)
        {
            [appDelegate.downmange start];
            isStartDown = YES;
        }
        else
        {
            [appDelegate.downmange stopAllDown];
            isStartDown = NO;
        }
    }
}

-(void)deleteAll:(id)sender
{
    if (self.table_view.editing) {
        NSArray *array=[self.table_view indexPathsForSelectedRows];
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
        else
        {
            UIActionSheet *actionSheet = [[UIActionSheet alloc] initWithTitle:@"确定要删除文件" delegate:self cancelButtonTitle:@"取消" destructiveButtonTitle:@"确定" otherButtonTitles:nil, nil];
            [actionSheet setTag:kActionSheetTagAllDelete];
            [actionSheet setActionSheetStyle:UIActionSheetStyleBlackOpaque];
            [actionSheet showInView:[[UIApplication sharedApplication] keyWindow]];
        }
    }
}

-(void)selectAllCell:(id)sender
{
    if(isShowUpload)
    {
        NSInteger type = [self getUploadType];
        if(type == 1)
        {
            for (int i=0; i<self.upLoading_array.count; i++) {
                [self.table_view selectRowAtIndexPath:[NSIndexPath indexPathForRow:i inSection:0] animated:YES scrollPosition:UITableViewScrollPositionNone];
            }
        }
        else if(type == 2)
        {
            for (int i=0; i<self.upLoaded_array.count; i++) {
                [self.table_view selectRowAtIndexPath:[NSIndexPath indexPathForRow:i inSection:0] animated:YES scrollPosition:UITableViewScrollPositionNone];
            }
        }
        else if(type == 3)
        {
            for (int i=0; i<self.upLoading_array.count; i++) {
                [self.table_view selectRowAtIndexPath:[NSIndexPath indexPathForRow:i inSection:0] animated:YES scrollPosition:UITableViewScrollPositionNone];
            }
            for (int i=0; i<self.upLoaded_array.count; i++) {
                [self.table_view selectRowAtIndexPath:[NSIndexPath indexPathForRow:i inSection:1] animated:YES scrollPosition:UITableViewScrollPositionNone];
            }
        }
    }
    else
    {
        NSInteger type = [self getDownType];
        if(type == 1)
        {
            for (int i=0; i<self.downLoading_array.count; i++) {
                [self.table_view selectRowAtIndexPath:[NSIndexPath indexPathForRow:i inSection:0] animated:YES scrollPosition:UITableViewScrollPositionNone];
            }
        }
        else if(type == 2)
        {
            for (int i=0; i<self.downLoaded_array.count; i++) {
                [self.table_view selectRowAtIndexPath:[NSIndexPath indexPathForRow:i inSection:0] animated:YES scrollPosition:UITableViewScrollPositionNone];
            }
        }
        else if(type == 3)
        {
            for (int i=0; i<self.downLoading_array.count; i++) {
                [self.table_view selectRowAtIndexPath:[NSIndexPath indexPathForRow:i inSection:0] animated:YES scrollPosition:UITableViewScrollPositionNone];
            }
            for (int i=0; i<self.downLoaded_array.count; i++) {
                [self.table_view selectRowAtIndexPath:[NSIndexPath indexPathForRow:i inSection:1] animated:YES scrollPosition:UITableViewScrollPositionNone];
            }
        }
    }
    [self.navigationItem setRightBarButtonItem:[[UIBarButtonItem alloc] initWithTitle:@"取消全选" style:UIBarButtonItemStylePlain target:self action:@selector(cancelSelectAllCell:)]];
}

-(void)cancelSelectAllCell:(id)sender
{
    if(isShowUpload)
    {
        NSInteger type = [self getUploadType];
        if(type == 1)
        {
            for (int i=0; i<self.upLoading_array.count; i++) {
                [self.table_view deselectRowAtIndexPath:[NSIndexPath indexPathForRow:i inSection:0] animated:YES];
            }
        }
        else if(type == 2)
        {
            for (int i=0; i<self.upLoaded_array.count; i++) {
                [self.table_view deselectRowAtIndexPath:[NSIndexPath indexPathForRow:i inSection:0] animated:YES];
            }
        }
        else if(type == 3)
        {
            for (int i=0; i<self.upLoading_array.count; i++) {
                [self.table_view deselectRowAtIndexPath:[NSIndexPath indexPathForRow:i inSection:0] animated:YES];
            }
            for (int i=0; i<self.upLoaded_array.count; i++) {
                [self.table_view deselectRowAtIndexPath:[NSIndexPath indexPathForRow:i inSection:1] animated:YES];
            }
        }
    }
    else
    {
        NSInteger type = [self getDownType];
        if(type == 1)
        {
            for (int i=0; i<self.downLoading_array.count; i++) {
                [self.table_view deselectRowAtIndexPath:[NSIndexPath indexPathForRow:i inSection:0] animated:YES];
            }
        }
        else if(type == 2)
        {
            for (int i=0; i<self.downLoaded_array.count; i++) {
                [self.table_view deselectRowAtIndexPath:[NSIndexPath indexPathForRow:i inSection:0] animated:YES];
            }
        }
        else if(type == 3)
        {
            for (int i=0; i<self.downLoading_array.count; i++) {
                [self.table_view deselectRowAtIndexPath:[NSIndexPath indexPathForRow:i inSection:0] animated:YES];
            }
            for (int i=0; i<self.downLoaded_array.count; i++) {
                [self.table_view deselectRowAtIndexPath:[NSIndexPath indexPathForRow:i inSection:1] animated:YES];
            }
        }
    }
    [self.navigationItem setRightBarButtonItem:[[UIBarButtonItem alloc] initWithTitle:@"全选" style:UIBarButtonItemStylePlain target:self action:@selector(selectAllCell:)]];
}

-(void)viewWillAppear:(BOOL)animated
{
    [self.navigationController setNavigationBarHidden:NO];
    [self hiddenTabBar:NO];
    [self isSelectedLeft:isShowUpload];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}

-(void)updateTableViewCount
{
    AppDelegate *delegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
    [delegate.downmange updateLoad];
    [delegate.uploadmanage updateLoad];

    NSString *leftTitle;
    if([upLoading_array count]>0)
    {
        leftTitle = [NSString stringWithFormat:@"正在上传(%i)",[upLoading_array count]];
    }
    else
    {
        leftTitle = @"上传";
    }
    NSString *rightTitle;
    if([downLoading_array count]>0)
    {
        rightTitle = [NSString stringWithFormat:@"正在下载(%i)",[downLoading_array count]];
    }
    else
    {
        rightTitle = @"下载";
    }
    [self.customSelectButton updateCount:leftTitle downCount:rightTitle];
}

#pragma mark CustomSelectButtonDelegate -------------------

-(void)isSelectedLeft:(BOOL)bl
{
    DDLogCInfo(@"滑动：%i",bl);
    if(self.table_view.editing && bl!=isShowUpload)
    {
        [self editAction:nil];
    }
    isShowUpload = bl;
    
    [self updateTableViewCount];
    //测试代码
    //打开照片库
    if(!bl)
    {
        AppDelegate *delegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
        [delegate.downmange updateLoad];
        DownList *list = [[DownList alloc] init];
        list.d_ure_id = [NSString formatNSStringForOjbect:[[SCBSession sharedSession] userId]];
        if(self.downLoaded_array == nil)
        {
            self.downLoaded_array = [[NSMutableArray alloc] initWithArray:[list selectDownedAll]];
        }
        else
        {
            DownList *ls = [self.downLoaded_array firstObject];
            list.d_id = ls.d_id;
            NSArray *array = [list selectDownedAll];
            NSMutableIndexSet *indexSet = [[NSMutableIndexSet alloc] init];
            for(int i=0;i<[array count];i++)
            {
                [indexSet addIndex:i];
            }
            [self.downLoaded_array insertObjects:array atIndexes:indexSet];
        }
    }
    else
    {
        AppDelegate *delegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
        [delegate.uploadmanage updateLoad];
        UpLoadList *list = [[UpLoadList alloc] init];
        list.user_id = [NSString formatNSStringForOjbect:[[SCBSession sharedSession] userId]];
        if(self.upLoaded_array == nil)
        {
            self.upLoaded_array = [[NSMutableArray alloc] initWithArray:[list selectUploadListAllAndUploaded]];
        }
        else
        {
            UpLoadList *ls = [self.upLoaded_array firstObject];
            list.t_id = ls.t_id;
            NSArray *array = [list selectUploadListAllAndUploaded];
            NSMutableIndexSet *indexSet = [[NSMutableIndexSet alloc] init];
            for(int i=0;i<[array count];i++)
            {
                [indexSet addIndex:i];
            }
            [self.upLoaded_array insertObjects:array atIndexes:indexSet];
        }
    }
    [self.table_view reloadData];
}

-(void)leftSwipeFrom
{
    [self.customSelectButton showLeftWithIsSelected:NO];
}

-(void)rightSwipeFrom
{
    [self.customSelectButton showLeftWithIsSelected:YES];
}

#pragma mark UITableViewDelegate ---------------------------

-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    NSInteger count = 0;
    if(isShowUpload)
    {
        if([upLoading_array count]>0)
        {
            count++;
        }
        if([upLoaded_array count]>0)
        {
            count++;
        }
    }
    else
    {
        if([downLoading_array count]>0)
        {
            count++;
        }
        if([downLoaded_array count]>0)
        {
            count++;
        }
    }
    return count;
}

-(float)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    return 20;
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
    CGRect header_rect = CGRectMake(0, 0, 320, 20);
    UILabel *title_leble = [[UILabel alloc] initWithFrame:header_rect];
    NSString *title_State = @"";
    if(isShowUpload)
    {
        NSInteger type = [self getUploadType];
        if(type == 1)
        {
            title_State = [NSString stringWithFormat:@" 正在上传(%i)",[upLoading_array count]];
        }
        else if(type == 2)
        {
            title_State = [NSString stringWithFormat:@" 上传完成(%i)",[upLoaded_array count]];
        }
        else if(type == 3)
        {
            if(section==0 && [upLoading_array count]>0)
            {
                title_State = [NSString stringWithFormat:@" 正在上传(%i)",[upLoading_array count]];
            }
            if(section==1 && [upLoaded_array count]>0)
            {
                title_State = [NSString stringWithFormat:@" 上传完成(%i)",[upLoaded_array count]];
            }
        }
    }
    else
    {
        NSInteger type = [self getDownType];
        if(type == 1)
        {
            title_State = [NSString stringWithFormat:@" 正在下载(%i)",[downLoading_array count]];
        }
        else if(type == 2)
        {
            title_State = [NSString stringWithFormat:@" 下载完成(%i)",[downLoaded_array count]];
        }
        else if(type == 3)
        {
            if(section==0 && [downLoading_array count]>0)
            {
                title_State = [NSString stringWithFormat:@" 正在下载(%i)",[downLoading_array count]];
            }
            if(section==1 && [downLoaded_array count]>0)
            {
                title_State = [NSString stringWithFormat:@" 下载完成(%i)",[downLoaded_array count]];
            }
        }
    }
    
    
    title_leble.text = [NSString formatNSStringForOjbect:title_State];
    [title_leble setTextColor:[UIColor whiteColor]];
    [title_leble setBackgroundColor:[UIColor colorWithRed:71.0/255.0 green:85.0/255.0 blue:96.0/255.0 alpha:1]];
    [title_leble setFont:[UIFont systemFontOfSize:14]];
    return title_leble;
}

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    NSInteger count = 0;
    if(isShowUpload)
    {
        NSInteger type = [self getUploadType];
        if(type == 1)
        {
            count = [upLoading_array count];
        }
        else if(type == 2)
        {
            count = [upLoaded_array count];
        }
        else if(type == 3)
        {
            if(section==0 && [upLoading_array count]>0)
            {
                count = [upLoading_array count];
            }
            if(section==1 && [upLoaded_array count]>0)
            {
                count = [upLoaded_array count];
            }
        }
    }
    else
    {
        NSInteger type = [self getDownType];
        if(type == 1)
        {
            count = [downLoading_array count];
        }
        else if(type == 2)
        {
            count = [downLoaded_array count];
        }
        else if(type == 3)
        {
            if(section==0 && [downLoading_array count]>0)
            {
                count = [downLoading_array count];
            }
            if(section==1 && [downLoaded_array count]>0)
            {
                count = [downLoaded_array count];
            }
        }
    }
    DDLogInfo(@"count:%i",count);
    return count;
}

-(float)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 50;
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UploadViewCell *cell;
    static NSString *cellString = @"upDownCell";
    cell = [tableView dequeueReusableCellWithIdentifier:cellString];
    if(cell==nil)
    {
        cell = [[UploadViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellString];
        [cell setSelectionStyle:UITableViewCellSelectionStyleDefault];
    }
    int section = indexPath.section;
    if(isShowUpload)
    {
        NSInteger type = [self getUploadType];
        if(type == 1)
        {
            if(section==0 && indexPath.row<[self.upLoading_array count])
            {
                UpLoadList *list = [self.upLoading_array objectAtIndex:indexPath.row];
                [cell setUploadDemo:list];
            }
        }
        else if(type == 2)
        {
            if(section==0 && indexPath.row<[self.upLoaded_array count])
            {
                UpLoadList *list = [self.upLoaded_array objectAtIndex:indexPath.row];
                [cell setUploadDemo:list];
            }
        }
        else if(type == 3)
        {
            if(section==0 && indexPath.row<[self.upLoading_array count])
            {
                UpLoadList *list = [self.upLoading_array objectAtIndex:indexPath.row];
                [cell setUploadDemo:list];
            }
            else if(section==1 && indexPath.row<[self.upLoaded_array count])
            {
                UpLoadList *list = [self.upLoaded_array objectAtIndex:indexPath.row];
                [cell setUploadDemo:list];
            }
        }
    }
    else
    {
        NSInteger type = [self getDownType];
        if(type == 1)
        {
            if(section==0 && indexPath.row<[self.downLoading_array count])
            {
                DownList *list = [self.downLoading_array objectAtIndex:indexPath.row];
                [cell setDownDemo:list];
            }
        }
        else if(type == 2)
        {
            if(section==0 && indexPath.row<[self.downLoaded_array count])
            {
                DownList *list = [self.downLoaded_array objectAtIndex:indexPath.row];
                [cell setDownDemo:list];
            }
        }
        else if(type == 3)
        {
            //下载部分
            if(section==0 && indexPath.row<[self.downLoading_array count])
            {
                DownList *list = [self.downLoading_array objectAtIndex:indexPath.row];
                [cell setDownDemo:list];
            }
            else if(section==1 && indexPath.row<[self.downLoaded_array count])
            {
                DownList *list = [self.downLoaded_array objectAtIndex:indexPath.row];
                [cell setDownDemo:list];
            }
        }
        
    }
    [cell showEdit:self.table_view.editing];
    [cell setDelegate:self];
    return cell;
}

#pragma mark - Table view delegate
- (UITableViewCellEditingStyle)tableView:(UITableView *)tableView editingStyleForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return UITableViewCellEditingStyleDelete | UITableViewCellEditingStyleInsert;
}

-(void)deletCell:(NSObject *)object
{
    deleteObject = object;
    UIActionSheet *actionSheet = [[UIActionSheet alloc] initWithTitle:@"确定要删除此文件" delegate:self cancelButtonTitle:@"取消" destructiveButtonTitle:@"确定" otherButtonTitles:nil, nil];
    [actionSheet setTag:kActionSheetTagDelete];
    [actionSheet setActionSheetStyle:UIActionSheetStyleBlackOpaque];
    [actionSheet showInView:[[UIApplication sharedApplication] keyWindow]];
}

-(NSMutableArray *)getSelectedIds
{
    NSMutableArray *array = [[NSMutableArray alloc] init];
    for(int i=0;i<self.table_view.indexPathsForSelectedRows.count;i++)
    {
        NSLog(@"多少次：%i",i);
        NSIndexPath *indexPath = [self.table_view.indexPathsForSelectedRows objectAtIndex:i];
        if(isShowUpload)
        {
            NSInteger type = [self getUploadType];
            if(type == 1)
            {
                if(indexPath.row<[self.upLoading_array count])
                {
                    UpLoadList *list = [self.upLoading_array objectAtIndex:indexPath.row];
                    [array addObject:list];
                }
            }
            else if(type == 2)
            {
                if(indexPath.row<[self.upLoaded_array count])
                {
                    UpLoadList *list = [self.upLoaded_array objectAtIndex:indexPath.row];
                    [array addObject:list];
                }
            }
            else if(type == 3)
            {
                if(indexPath.section==0 && indexPath.row<[self.upLoading_array count])
                {
                    UpLoadList *list = [self.upLoading_array objectAtIndex:indexPath.row];
                    [array addObject:list];
                }
                if(indexPath.section==1  && indexPath.row<[self.upLoaded_array count])
                {
                    UpLoadList *list = [self.upLoaded_array objectAtIndex:indexPath.row];
                    [array addObject:list];
                }
            }
        }
        else
        {
            NSInteger type = [self getDownType];
            if(type == 1)
            {
                if(indexPath.row<[self.downLoading_array count])
                {
                    DownList *list = [self.downLoading_array objectAtIndex:indexPath.row];
                    [array addObject:list];
                }
            }
            else if(type == 2)
            {
                if(indexPath.row<[self.downLoaded_array count])
                {
                    DownList *list = [self.downLoaded_array objectAtIndex:indexPath.row];
                    [array addObject:list];
                }
            }
            else if(type == 3)
            {
                if(indexPath.section==0 && indexPath.row<[self.downLoading_array count])
                {
                    DownList *list = [self.downLoading_array objectAtIndex:indexPath.row];
                    [array addObject:list];
                }
                if(indexPath.section==1 && indexPath.row<[self.downLoaded_array count])
                {
                    DownList *list = [self.downLoaded_array objectAtIndex:indexPath.row];
                    [array addObject:list];
                }
            }
        }
    }
    return array;
}

#pragma makr UIActionSheetDelegate

-(void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if(actionSheet.tag == kActionSheetTagDelete && buttonIndex == 0)
    {
        [self deleteList];
    }
    else if(actionSheet.tag == kActionSheetTagAllDelete && buttonIndex == 0)
    {
        [self deleteOldList:[self getSelectedIds]];
    }
}

-(void)deleteList
{
    [self deleteOldList:[NSMutableArray arrayWithObject:deleteObject]];
}

-(void)deleteOldList:(NSMutableArray *)array
{
    for (int i=0;i<[array count]; i++) {
        NSObject *object = [array objectAtIndex:i];
        if([object isKindOfClass:[UpLoadList class]])
        {
            for(int i=0;i<[upLoading_array count];i++)
            {
                UpLoadList *list = (UpLoadList *)[upLoading_array objectAtIndex:i];
                UpLoadList *oldList = (UpLoadList *)object;
                if(list.t_id == oldList.t_id)
                {
                    AppDelegate *delegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
                    [delegate.uploadmanage deleteOneUpload:i];
                    break;
                }
            }
            for(int i=0;i<[upLoaded_array count];i++)
            {
                UpLoadList *list = (UpLoadList *)[upLoaded_array objectAtIndex:i];
                UpLoadList *oldList = (UpLoadList *)object;
                if(list.t_id == oldList.t_id)
                {
                    [list deleteUploadList];
                    [upLoaded_array removeObjectAtIndex:i];
                    break;
                }
            }
        }
        else if([object isKindOfClass:[DownList class]])
        {
            for(int i=0;i<[downLoading_array count];i++)
            {
                DownList *list = (DownList *)[downLoading_array objectAtIndex:i];
                DownList *oldList = (DownList *)object;
                if(list.d_id == oldList.d_id)
                {
                    AppDelegate *delegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
                    [delegate.downmange deleteOneDown:i];
                    break;
                }
            }
            for(int i=0;i<[downLoaded_array count];i++)
            {
                DownList *list = (DownList *)[downLoaded_array objectAtIndex:i];
                DownList *oldList = (DownList *)object;
                if(list.d_id == oldList.d_id)
                {
                    [list deleteDownList];
                    [downLoaded_array removeObjectAtIndex:i];
                    break;
                }
            }
        }
    }
    AppDelegate *delegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
    [delegate.uploadmanage updateTable];
    [delegate.downmange updateTable];
    [self isSelectedLeft:isShowUpload];
}



-(void)hiddenTabBar:(BOOL)isHideTabBar
{
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
}

//type ,0:没有数据，1：准备数据，2：完成数据，3：1、2都有
-(NSInteger)getUploadType
{
    NSInteger type = 0;
    if([upLoading_array count]>0)
    {
        type = 1;
    }
    if([upLoaded_array count]>0)
    {
        if(type==1)
        {
            type = 3;
        }
        else
        {
            type = 2;
        }
    }
    return type;
}

//type ,0:没有数据，1：准备数据，2：完成数据，3：1、2都有
-(NSInteger)getDownType
{
    NSInteger type = 0;
    if([downLoading_array count]>0)
    {
        type = 1;
    }
    if([downLoaded_array count]>0)
    {
        if(type==1)
        {
            type = 3;
        }
        else
        {
            type = 2;
        }
    }
    return type;
}

@end
