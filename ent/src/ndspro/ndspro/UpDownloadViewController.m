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
#import "PhotoLookViewController.h"
#import "OtherBrowserViewController.h"
#import "UIBarButtonItem+Yn.h"
#import "MyTabBarViewController.h"

#define UpTabBarHeight (49+20+44)
#define kActionSheetTagDelete 77
#define kActionSheetTagAllDelete 78

@interface UpDownloadViewController ()

@end

@implementation UpDownloadViewController
@synthesize table_view,upLoading_array,upLoaded_array,downLoading_array,downLoaded_array,customSelectButton,isShowUpload,deleteObject,menuView,editView,rightItem,hud,btnStart,selectAllIds;


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
    self.imageDownloadsInProgress = [[NSMutableDictionary alloc] init];
    
    UISwipeGestureRecognizer *recognizer;
    
    recognizer = [[UISwipeGestureRecognizer alloc]initWithTarget:self action:@selector(rightSwipeFrom)];
    [recognizer setDirection:(UISwipeGestureRecognizerDirectionRight)];
    [[self view] addGestureRecognizer:recognizer];
    recognizer = nil;
    recognizer = [[UISwipeGestureRecognizer alloc]initWithTarget:self action:@selector(leftSwipeFrom)];
    [recognizer setDirection:(UISwipeGestureRecognizerDirectionLeft)];
    [[self view] addGestureRecognizer:recognizer];
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
    CGRect table_rect = CGRectMake(0, customRect.origin.y+customRect.size.height, 320, self.view.frame.size.height-(customRect.origin.y+customRect.size.height)-TabBarHeight+10);
    if([[[UIDevice currentDevice] systemVersion] floatValue]<7.0)
    {
        table_rect.size.height = table_rect.size.height+TabBarHeight-10;
    }
    self.table_view = [[UITableView alloc] initWithFrame:table_rect];
    self.table_view.delegate = self;
    self.table_view.dataSource = self;
    [self.view addSubview:self.table_view];
}

-(void)viewDidAppear:(BOOL)animated
{
    //加载列表
    CGRect customRect = self.customSelectButton.frame;
    CGRect table_rect = CGRectMake(0, customRect.origin.y+customRect.size.height, 320, self.view.frame.size.height-(customRect.origin.y+customRect.size.height)-TabBarHeight+10);
    if([[[UIDevice currentDevice] systemVersion] floatValue]<7.0)
    {
        table_rect.size.height = table_rect.size.height+TabBarHeight-10;
    }
    [self.table_view setFrame:table_rect];
}

-(void)menuAction:(id)sender
{
    if (!self.menuView) {
        const float scale=1.3f;
        self.menuView =[[UIControl alloc] initWithFrame:CGRectMake(0, 0, 320, self.view.frame.size.height)];
        UIView * mView=[[UIView alloc] initWithFrame:CGRectMake(self.view.frame.size.width-(80*scale)-15, 0, 80*scale, 47*scale)];
        UIImageView *bgView=[[UIImageView alloc] initWithImage:[UIImage imageNamed:@"title_menu2@2x.png"]];
        [bgView setFrame:CGRectMake(0, 0, 80*scale, 47*scale)];
        [mView addSubview:bgView];
        UIButton *btnEdit;
        btnEdit=[[UIButton alloc] initWithFrame:CGRectMake(0, 7*scale, 40*scale, 40*scale)];
        [btnEdit setImage:[UIImage imageNamed:@"title_bt_edit_nor@2x.png"] forState:UIControlStateHighlighted];
        [btnEdit setImage:[UIImage imageNamed:@"title_bt_edit_se@2x.png"] forState:UIControlStateNormal];
        [btnEdit setBackgroundImage:[UIImage imageNamed:@"title_se.png"] forState:UIControlStateHighlighted];
        [btnEdit addTarget:self action:@selector(editAction:) forControlEvents:UIControlEventTouchUpInside];
        [mView addSubview:btnEdit];
        
        btnStart=[[UIButton alloc] initWithFrame:CGRectMake(40*scale, 7*scale, 40*scale, 40*scale)];
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
    
    DDLogCInfo(@"self.menuView.hidden:%i",self.menuView.hidden);
    
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
    
    if(isShowUpload)
    {
        if([self.upLoaded_array count] == 0 && [self.upLoading_array count] == 0)
        {
            [self.table_view setEditing:NO animated:YES];
        }
        else
        {
            [self.table_view setEditing:!self.table_view.editing animated:YES];
        }
    }
    else
    {
        if([self.downLoaded_array count] == 0 && [self.downLoading_array count] == 0)
        {
            [self.table_view setEditing:NO animated:YES];
        }
        else
        {
            [self.table_view setEditing:!self.table_view.editing animated:YES];
        }
    }
    
    
    
    [self.table_view reloadData];
    [self updateLoadData];
    
    BOOL isHideTabBar=self.table_view.editing;
    
    AppDelegate *appleDate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
    UIApplication *app = [UIApplication sharedApplication];
    if(isHideTabBar || app.applicationIconBadgeNumber==0)
    {
        [appleDate.myTabBarVC.imageView setHidden:YES];
    }
    else
    {
        [appleDate.myTabBarVC.imageView setHidden:NO];
    }
    
    for(UIView *view in self.tabBarController.view.subviews)
    {
        if([view isKindOfClass:[UITabBar class]])
        {
            if (isHideTabBar) { //if hidden tabBar
                [view setFrame:CGRectMake(view.frame.origin.x,[[UIScreen mainScreen]bounds].size.height+10, view.frame.size.width, view.frame.size.height)];
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
        [self.editView setBackgroundImage:[UIImage imageNamed:@"oper_bk.png"] forState:UIControlStateNormal];
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
        [self.editView setHidden:NO];
        [self.navigationItem setLeftBarButtonItem:[[UIBarButtonItem alloc] initWithTitleStr:@"取消" style:UIBarButtonItemStylePlain target:self action:@selector(editAction:)]];
        [self.navigationItem setRightBarButtonItem:[[UIBarButtonItem alloc] initWithTitleStr:@"全选" style:UIBarButtonItemStylePlain target:self action:@selector(selectAllCell:)]];
    }
    else
    {
        [self.editView setHidden:YES];
        [self.selectAllIds removeAllObjects];
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
        if(!appDelegate.uploadmanage.isStart)
        {
            [appDelegate.uploadmanage start];
        }
        else
        {
            [appDelegate.uploadmanage stopAllUpload];
        }
    }
    else
    {
        if(!appDelegate.downmange.isStart)
        {
            [appDelegate.downmange start];
        }
        else
        {
            [appDelegate.downmange stopAllDown];
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
            UIActionSheet *actionSheet = [[UIActionSheet alloc] initWithTitle:@"是否要删除选中的内容" delegate:self cancelButtonTitle:@"取消" destructiveButtonTitle:@"确定" otherButtonTitles:nil, nil];
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
    [self.navigationItem setRightBarButtonItem:[[UIBarButtonItem alloc] initWithTitleStr:@"取消全选" style:UIBarButtonItemStylePlain target:self action:@selector(cancelSelectAllCell:)]];
    [self updateSelectIndexPath];
}

- (void)selectRowAtIndexPath:(NSIndexPath *)indexPath animated:(BOOL)animated scrollPosition:(UITableViewScrollPosition)scrollPosition
{
    DDLogCInfo(@"进来");
}

-(void)updateSelectIndexPath
{
    self.selectAllIds = [self getSelectedIds];
}

-(void)updateLoadData
{
    if(!self.table_view.editing)
    {
        return;
    }
    if(isShowUpload)
    {
        NSInteger type = [self getUploadType];
        if(type == 1)
        {
            for (int i=0; i<self.upLoading_array.count; i++) {
                UpLoadList *list = [self.upLoading_array objectAtIndex:i];
                for(int j=0;j<self.selectAllIds.count;j++)
                {
                    UpLoadList *old_list = [self.selectAllIds objectAtIndex:j];
                    if(list.t_id == old_list.t_id)
                    {
                        [self.table_view selectRowAtIndexPath:[NSIndexPath indexPathForRow:i inSection:0] animated:YES scrollPosition:UITableViewScrollPositionNone];
                    }
                }
            }
        }
        else if(type == 2)
        {
            for (int i=0; i<self.upLoaded_array.count; i++) {
                UpLoadList *list = [self.upLoaded_array objectAtIndex:i];
                for(int j=0;j<self.selectAllIds.count;j++)
                {
                    UpLoadList *old_list = [self.selectAllIds objectAtIndex:j];
                    if(list.t_id == old_list.t_id)
                    {
                       [self.table_view selectRowAtIndexPath:[NSIndexPath indexPathForRow:i inSection:0] animated:YES scrollPosition:UITableViewScrollPositionNone];
                    }
                }
            }
        }
        else if(type == 3)
        {
            for (int i=0; i<self.upLoading_array.count; i++) {
                UpLoadList *list = [self.upLoading_array objectAtIndex:i];
                for(int j=0;j<self.selectAllIds.count;j++)
                {
                    UpLoadList *old_list = [self.selectAllIds objectAtIndex:j];
                    if(list.t_id == old_list.t_id)
                    {
                        [self.table_view selectRowAtIndexPath:[NSIndexPath indexPathForRow:i inSection:0] animated:YES scrollPosition:UITableViewScrollPositionNone];
                    }
                }
            }
            for (int i=0; i<self.upLoaded_array.count; i++) {
                UpLoadList *list = [self.upLoaded_array objectAtIndex:i];
                for(int j=0;j<self.selectAllIds.count;j++)
                {
                    UpLoadList *old_list = [self.selectAllIds objectAtIndex:j];
                    if(list.t_id == old_list.t_id)
                    {
                        [self.table_view selectRowAtIndexPath:[NSIndexPath indexPathForRow:i inSection:1] animated:YES scrollPosition:UITableViewScrollPositionNone];
                    }
                }
            }
        }
    }
    else
    {
        NSInteger type = [self getDownType];
        if(type == 1)
        {
            for (int i=0; i<self.downLoading_array.count; i++) {
                DownList *list = [self.downLoading_array objectAtIndex:i];
                for(int j=0;j<self.selectAllIds.count;j++)
                {
                    DownList *old_list = [self.selectAllIds objectAtIndex:j];
                    if(list.d_id == old_list.d_id)
                    {
                        [self.table_view selectRowAtIndexPath:[NSIndexPath indexPathForRow:i inSection:0] animated:YES scrollPosition:UITableViewScrollPositionNone];
                    }
                }
            }
        }
        else if(type == 2)
        {
            for (int i=0; i<self.downLoaded_array.count; i++) {
                DownList *list = [self.downLoaded_array objectAtIndex:i];
                for(int j=0;j<self.selectAllIds.count;j++)
                {
                    DownList *old_list = [self.selectAllIds objectAtIndex:j];
                    if(list.d_id == old_list.d_id)
                    {
                        [self.table_view selectRowAtIndexPath:[NSIndexPath indexPathForRow:i inSection:0] animated:YES scrollPosition:UITableViewScrollPositionNone];
                    }
                }
            }
        }
        else if(type == 3)
        {
            for (int i=0; i<self.downLoading_array.count; i++) {
                DownList *list = [self.downLoading_array objectAtIndex:i];
                for(int j=0;j<self.selectAllIds.count;j++)
                {
                    DownList *old_list = [self.selectAllIds objectAtIndex:j];
                    if(list.d_id == old_list.d_id)
                    {
                        [self.table_view selectRowAtIndexPath:[NSIndexPath indexPathForRow:i inSection:0] animated:YES scrollPosition:UITableViewScrollPositionNone];
                    }
                }
            }
            for (int i=0; i<self.downLoaded_array.count; i++) {
                DownList *list = [self.downLoaded_array objectAtIndex:i];
                for(int j=0;j<self.selectAllIds.count;j++)
                {
                    DownList *old_list = [self.selectAllIds objectAtIndex:j];
                    if(list.d_id == old_list.d_id)
                    {
                        [self.table_view selectRowAtIndexPath:[NSIndexPath indexPathForRow:i inSection:1] animated:YES scrollPosition:UITableViewScrollPositionNone];
                    }
                }
            }
        }
    }
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
    [self.navigationItem setRightBarButtonItem:[[UIBarButtonItem alloc] initWithTitleStr:@"全选" style:UIBarButtonItemStylePlain target:self action:@selector(selectAllCell:)]];
    [self updateSelectIndexPath];
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
    
    UIApplication *app = [UIApplication sharedApplication];
    app.applicationIconBadgeNumber = [delegate.uploadmanage.uploadArray count]+[delegate.downmange.downingArray count];
    [delegate.myTabBarVC addUploadNumber:app.applicationIconBadgeNumber];
    
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
    
    if(!bl)
    {
        DownList *list = [[DownList alloc] init];
        list.d_ure_id = [NSString formatNSStringForOjbect:[[SCBSession sharedSession] userId]];
        if(self.downLoaded_array == nil)
        {
            self.downLoaded_array = [[NSMutableArray alloc] initWithArray:[list selectDownedAll]];
        }
        else
        {
            DownList *ls = [self.downLoaded_array firstObject];
            if(ls!=nil)
            {
                list.d_id = ls.d_id;
            }
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
        UpLoadList *list = [[UpLoadList alloc] init];
        list.user_id = [NSString formatNSStringForOjbect:[[SCBSession sharedSession] userId]];
        if(self.upLoaded_array == nil)
        {
            self.upLoaded_array = [[NSMutableArray alloc] initWithArray:[list selectUploadListAllAndUploaded]];
        }
        else
        {
            UpLoadList *ls = [self.upLoaded_array firstObject];
            if(ls!=nil)
            {
                list.t_id = ls.t_id;
            }
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
    [self updateLoadData];
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
            else if(section==1 && [upLoaded_array count]>0)
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
            else if(section==1 && [downLoaded_array count]>0)
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
            else if(section==1 && [upLoaded_array count]>0)
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
            else if(section==1 && [downLoaded_array count]>0)
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
    return 60;
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UploadViewCell *cell;
    static NSString *cellString = @"upDownCell";
    cell = [self.table_view dequeueReusableCellWithIdentifier:cellString];
    if(cell==nil)
    {
        cell = [[UploadViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellString];
        [cell setSelectionStyle:UITableViewCellSelectionStyleGray];
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
                for(int j=0;j<self.selectAllIds.count;j++)
                {
                    UpLoadList *old_list = [self.selectAllIds objectAtIndex:j];
                    if(list.t_id == old_list.t_id)
                    {
                        [self.table_view selectRowAtIndexPath:indexPath animated:YES scrollPosition:UITableViewScrollPositionNone];
                    }
                }
                [cell setUploadDemo:list];
            }
        }
        else if(type == 2)
        {
            if(section==0 && indexPath.row<[self.upLoaded_array count])
            {
                UpLoadList *list = [self.upLoaded_array objectAtIndex:indexPath.row];
                for(int j=0;j<self.selectAllIds.count;j++)
                {
                    UpLoadList *old_list = [self.selectAllIds objectAtIndex:j];
                    if(list.t_id == old_list.t_id)
                    {
                        [self.table_view selectRowAtIndexPath:indexPath animated:YES scrollPosition:UITableViewScrollPositionNone];
                    }
                }
                [cell setUploadDemo:list];
            }
        }
        else if(type == 3)
        {
            if(section==0 && indexPath.row<[self.upLoading_array count])
            {
                UpLoadList *list = [self.upLoading_array objectAtIndex:indexPath.row];
                for(int j=0;j<self.selectAllIds.count;j++)
                {
                    UpLoadList *old_list = [self.selectAllIds objectAtIndex:j];
                    if(list.t_id == old_list.t_id)
                    {
                        [self.table_view selectRowAtIndexPath:indexPath animated:YES scrollPosition:UITableViewScrollPositionNone];
                    }
                }
                [cell setUploadDemo:list];
            }
            else if(section==1 && indexPath.row<[self.upLoaded_array count])
            {
                UpLoadList *list = [self.upLoaded_array objectAtIndex:indexPath.row];
                for(int j=0;j<self.selectAllIds.count;j++)
                {
                    UpLoadList *old_list = [self.selectAllIds objectAtIndex:j];
                    if(list.t_id == old_list.t_id)
                    {
                        [self.table_view selectRowAtIndexPath:indexPath animated:YES scrollPosition:UITableViewScrollPositionNone];
                    }
                }
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
                for(int j=0;j<self.selectAllIds.count;j++)
                {
                    DownList *old_list = [self.selectAllIds objectAtIndex:j];
                    if(list.d_id == old_list.d_id)
                    {
                        [self.table_view selectRowAtIndexPath:indexPath animated:YES scrollPosition:UITableViewScrollPositionNone];
                    }
                }
                [cell setDownDemo:list];
                
                NSString *fthumb=[NSString formatNSStringForOjbect:list.d_thumbUrl];
                NSString *localThumbPath=[YNFunctions getIconCachePath];
                fthumb =[YNFunctions picFileNameFromURL:fthumb];
                localThumbPath=[localThumbPath stringByAppendingPathComponent:fthumb];
                if (![[NSFileManager defaultManager] fileExistsAtPath:localThumbPath]) {
                    [self startIconDownload:[[NSDictionary alloc] initWithObjectsAndKeys:list.d_thumbUrl,@"fthumb", nil] forIndexPath:indexPath];
                }
            }
        }
        else if(type == 2)
        {
            if(section==0 && indexPath.row<[self.downLoaded_array count])
            {
                DownList *list = [self.downLoaded_array objectAtIndex:indexPath.row];
                for(int j=0;j<self.selectAllIds.count;j++)
                {
                    DownList *old_list = [self.selectAllIds objectAtIndex:j];
                    if(list.d_id == old_list.d_id)
                    {
                        [self.table_view selectRowAtIndexPath:indexPath animated:YES scrollPosition:UITableViewScrollPositionNone];
                    }
                }
                [cell setDownDemo:list];
                
                NSString *fthumb=[NSString formatNSStringForOjbect:list.d_thumbUrl];
                NSString *localThumbPath=[YNFunctions getIconCachePath];
                fthumb =[YNFunctions picFileNameFromURL:fthumb];
                localThumbPath=[localThumbPath stringByAppendingPathComponent:fthumb];
                if (![[NSFileManager defaultManager] fileExistsAtPath:localThumbPath]) {
                    [self startIconDownload:[[NSDictionary alloc] initWithObjectsAndKeys:list.d_thumbUrl,@"fthumb", nil] forIndexPath:indexPath];
                }
            }
        }
        else if(type == 3)
        {
            //下载部分
            if(section==0 && indexPath.row<[self.downLoading_array count])
            {
                DownList *list = [self.downLoading_array objectAtIndex:indexPath.row];
                for(int j=0;j<self.selectAllIds.count;j++)
                {
                    DownList *old_list = [self.selectAllIds objectAtIndex:j];
                    if(list.d_id == old_list.d_id)
                    {
                        [self.table_view selectRowAtIndexPath:indexPath animated:YES scrollPosition:UITableViewScrollPositionNone];
                    }
                }
                [cell setDownDemo:list];
                
                NSString *fthumb=[NSString formatNSStringForOjbect:list.d_thumbUrl];
                NSString *localThumbPath=[YNFunctions getIconCachePath];
                fthumb =[YNFunctions picFileNameFromURL:fthumb];
                localThumbPath=[localThumbPath stringByAppendingPathComponent:fthumb];
                if (![[NSFileManager defaultManager] fileExistsAtPath:localThumbPath]) {
                    [self startIconDownload:[[NSDictionary alloc] initWithObjectsAndKeys:list.d_thumbUrl,@"fthumb", nil] forIndexPath:indexPath];
                }
            }
            else if(section==1 && indexPath.row<[self.downLoaded_array count])
            {
                DownList *list = [self.downLoaded_array objectAtIndex:indexPath.row];
                for(int j=0;j<self.selectAllIds.count;j++)
                {
                    DownList *old_list = [self.selectAllIds objectAtIndex:j];
                    if(list.d_id == old_list.d_id)
                    {
                        [self.table_view selectRowAtIndexPath:indexPath animated:YES scrollPosition:UITableViewScrollPositionNone];
                    }
                }
                [cell setDownDemo:list];
                
                NSString *fthumb=[NSString formatNSStringForOjbect:list.d_thumbUrl];
                NSString *localThumbPath=[YNFunctions getIconCachePath];
                fthumb =[YNFunctions picFileNameFromURL:fthumb];
                localThumbPath=[localThumbPath stringByAppendingPathComponent:fthumb];
                if (![[NSFileManager defaultManager] fileExistsAtPath:localThumbPath]) {
                    [self startIconDownload:[[NSDictionary alloc] initWithObjectsAndKeys:list.d_thumbUrl,@"fthumb", nil] forIndexPath:indexPath];
                }
            }
        }
        
    }
    [cell showEdit:self.table_view.editing];
    [cell setDelegate:self];
    return cell;
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    if(self.table_view.isEditing)
    {
        [self updateSelectIndexPath];
        return;
    }
    
    if(!isShowUpload)
    {
        NSInteger type = [self getDownType];
        if(type == 2)
        {
            if(indexPath.row < [downLoaded_array count])
            {
                DownList *list = [downLoaded_array objectAtIndex:indexPath.row];
                NSString *f_name=list.d_name;
                NSString *documentDir = [YNFunctions getFMCachePath];
                NSArray *array=[f_name componentsSeparatedByString:@"/"];
                NSString *createPath = [NSString stringWithFormat:@"%@/%@",documentDir,list.d_file_id];
                [NSString CreatePath:createPath];
                NSString *savedPath = [NSString stringWithFormat:@"%@/%@",createPath,[array lastObject]];
                if ([[NSFileManager defaultManager] fileExistsAtPath:savedPath]) {
                    QLBrowserViewController *browser=[[QLBrowserViewController alloc] init];
                    browser.dataSource=browser;
                    browser.delegate=browser;
                    browser.currentPreviewItemIndex=0;
                    browser.title=f_name;
                    browser.filePath=savedPath;
                    browser.fileName=f_name;
                    [self presentViewController:browser animated:YES completion:nil];
                }else
                {
                    if (self.hud) {
                        [self.hud removeFromSuperview];
                    }
                    self.hud=nil;
                    self.hud=[[MBProgressHUD alloc] initWithView:self.view];
                    [self.view addSubview:self.hud];
                    [self.hud show:NO];
                    self.hud.labelText=@"文件不存在，请重新下载";
                    self.hud.mode=MBProgressHUDModeText;
                    self.hud.margin=10.f;
                    [self.hud show:YES];
                    [self.hud hide:YES afterDelay:1.0f];
                }
            }
        }
        else if(type == 3)
        {
            if(indexPath.section==0 && [downLoading_array count]>0)
            {
//                PhotoLookViewController *look = [[PhotoLookViewController alloc] init];
//                [look setTableArray:downLoading_array];
//                [self presentModalViewController:look animated:YES];
            }
            if(indexPath.section==1 && [downLoaded_array count]>0)
            {
                DownList *list = [downLoaded_array objectAtIndex:indexPath.row];
                NSString *f_name=list.d_name;
                NSString *documentDir = [YNFunctions getFMCachePath];
                NSArray *array=[f_name componentsSeparatedByString:@"/"];
                NSString *createPath = [NSString stringWithFormat:@"%@/%@",documentDir,list.d_file_id];
                [NSString CreatePath:createPath];
                NSString *savedPath = [NSString stringWithFormat:@"%@/%@",createPath,[array lastObject]];
                if ([[NSFileManager defaultManager] fileExistsAtPath:savedPath]) {
                    QLBrowserViewController *browser=[[QLBrowserViewController alloc] init];
                    browser.dataSource=browser;
                    browser.delegate=browser;
                    browser.currentPreviewItemIndex=0;
                    browser.title=f_name;
                    browser.filePath=savedPath;
                    browser.fileName=f_name;
                    [self presentViewController:browser animated:YES completion:nil];
                }else
                {
                    if (self.hud) {
                        [self.hud removeFromSuperview];
                    }
                    self.hud=nil;
                    self.hud=[[MBProgressHUD alloc] initWithView:self.view];
                    [self.view addSubview:self.hud];
                    [self.hud show:NO];
                    self.hud.labelText=@"文件不存在，请重新下载";
                    self.hud.mode=MBProgressHUDModeText;
                    self.hud.margin=10.f;
                    [self.hud show:YES];
                    [self.hud hide:YES afterDelay:1.0f];
                }
            }
        }
    }
}

-(void)tableView:(UITableView *)tableView didDeselectRowAtIndexPath:(NSIndexPath *)indexPath
{
    if(self.table_view.editing)
    {
        [self updateSelectIndexPath];
    }
}

#pragma mark - Table view delegate
- (UITableViewCellEditingStyle)tableView:(UITableView *)tableView editingStyleForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return UITableViewCellEditingStyleDelete | UITableViewCellEditingStyleInsert;
}

-(void)deletCell:(NSObject *)object
{
    deleteObject = object;
    if([deleteObject isKindOfClass:[UpLoadList class]])
    {
        UpLoadList *list = (UpLoadList *)deleteObject;
        if(list.t_state != 1)
        {
            UIActionSheet *actionSheet = [[UIActionSheet alloc] initWithTitle:@"你选择的文件中有正在上传的文件" delegate:self cancelButtonTitle:@"取消" destructiveButtonTitle:@"确定移除" otherButtonTitles:nil, nil];
            [actionSheet setTag:kActionSheetTagDelete];
            [actionSheet setActionSheetStyle:UIActionSheetStyleBlackOpaque];
            [actionSheet showInView:[[UIApplication sharedApplication] keyWindow]];
            return;
        }
    }
    else if([deleteObject isKindOfClass:[DownList class]])
    {
        DownList *list = (DownList *)deleteObject;
        if(list.d_state != 1 && list.d_state != 4)
        {
            UIActionSheet *actionSheet = [[UIActionSheet alloc] initWithTitle:@"你选择的文件中有正在下载的文件" delegate:self cancelButtonTitle:@"取消" destructiveButtonTitle:@"确定移除" otherButtonTitles:nil, nil];
            [actionSheet setTag:kActionSheetTagDelete];
            [actionSheet setActionSheetStyle:UIActionSheetStyleBlackOpaque];
            [actionSheet showInView:[[UIApplication sharedApplication] keyWindow]];
            return;
        }
    }
    UIActionSheet *actionSheet = [[UIActionSheet alloc] initWithTitle:@"是否要删除选中的内容" delegate:self cancelButtonTitle:@"取消" destructiveButtonTitle:@"确定" otherButtonTitles:nil, nil];
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
        [self deleteOldList:self.selectAllIds];
    }
}

-(void)deleteList
{
    [self deleteOldList:[NSMutableArray arrayWithObject:deleteObject]];
}

-(void)deleteOldList:(NSMutableArray *)array
{
    NSLog(@"删除文件大小：%i",[array count]);
    for (int i=0;i<[array count]; i++) {
        NSObject *object = [array objectAtIndex:i];
        if([object isKindOfClass:[UpLoadList class]])
        {
            for(int j=0;j<[upLoading_array count];j++)
            {
                UpLoadList *list = (UpLoadList *)[upLoading_array objectAtIndex:j];
                UpLoadList *oldList = (UpLoadList *)object;
                if(list.t_id == oldList.t_id)
                {
                    AppDelegate *delegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
                    [delegate.uploadmanage deleteOneUpload:j];
                    break;
                }
            }
            for(int j=0;j<[upLoaded_array count];j++)
            {
                UpLoadList *list = (UpLoadList *)[upLoaded_array objectAtIndex:j];
                UpLoadList *oldList = (UpLoadList *)object;
                if(list.t_id == oldList.t_id)
                {
                    [list deleteUploadList];
                    [upLoaded_array removeObjectAtIndex:j];
                    break;
                }
            }
        }
        else if([object isKindOfClass:[DownList class]])
        {
            for(int j=0;j<[downLoading_array count];j++)
            {
                DownList *list = (DownList *)[downLoading_array objectAtIndex:j];
                DownList *oldList = (DownList *)object;
                if(list.d_id == oldList.d_id)
                {
                    AppDelegate *delegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
                    [delegate.downmange deleteOneDown:j];
                    break;
                }
            }
            for(int j=0;j<[downLoaded_array count];j++)
            {
                DownList *list = (DownList *)[downLoaded_array objectAtIndex:j];
                DownList *oldList = (DownList *)object;
                if(list.d_id == oldList.d_id)
                {
                    [list deleteDownList];
                    [downLoaded_array removeObjectAtIndex:j];
                    break;
                }
            }
        }
    }
    [self isSelectedLeft:isShowUpload];
    if(self.table_view.editing)
    {
        [self editAction:nil];
    }
}



-(void)hiddenTabBar:(BOOL)isHideTabBar
{
    AppDelegate *appleDate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
    UIApplication *app = [UIApplication sharedApplication];
    if(isHideTabBar || app.applicationIconBadgeNumber==0)
    {
        [appleDate.myTabBarVC.imageView setHidden:YES];
    }
    else
    {
        [appleDate.myTabBarVC.imageView setHidden:NO];
    }
    
    for(UIView *view in self.tabBarController.view.subviews)
    {
        if([view isKindOfClass:[UITabBar class]])
        {
            if (isHideTabBar) { //if hidden tabBar
                [view setFrame:CGRectMake(view.frame.origin.x,[[UIScreen mainScreen]bounds].size.height+2, view.frame.size.width, view.frame.size.height)];
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

//文件夹不存在
-(void)showFloderNot:(NSString *)alertText
{
    if (self.hud) {
        [self.hud removeFromSuperview];
    }
    self.hud=nil;
    self.hud=[[MBProgressHUD alloc] initWithView:self.view];
    [self.view addSubview:self.hud];
    [self.hud show:NO];
    self.hud.labelText=alertText;
    self.hud.mode=MBProgressHUDModeText;
    self.hud.margin=10.f;
    [self.hud show:YES];
    [self.hud hide:YES afterDelay:1.0f];
}

//空间不足
-(void)showSpaceNot
{
    if (self.hud) {
        [self.hud removeFromSuperview];
    }
    self.hud=nil;
    self.hud=[[MBProgressHUD alloc] initWithView:self.view];
    [self.view addSubview:self.hud];
    [self.hud show:NO];
    self.hud.labelText=@"空间不足";
    self.hud.mode=MBProgressHUDModeText;
    self.hud.margin=10.f;
    [self.hud show:YES];
    [self.hud hide:YES afterDelay:1.0f];
}

- (void)startIconDownload:(NSDictionary *)dic forIndexPath:(NSIndexPath *)indexPath
{
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

- (void)appImageDidLoad:(NSIndexPath *)indexPath
{
    if(!isShowUpload)
    {
        IconDownloader *iconDownloader = [self.imageDownloadsInProgress objectForKey:indexPath];
        if (iconDownloader != nil)
        {
            UploadViewCell *cell = (UploadViewCell *)[self.table_view cellForRowAtIndexPath:indexPath];
            if(cell != nil && [cell isKindOfClass:[UploadViewCell class]])
            {
                [cell updateList];
            }
        }
        [self.imageDownloadsInProgress removeObjectForKey:indexPath];
    }
}

@end
