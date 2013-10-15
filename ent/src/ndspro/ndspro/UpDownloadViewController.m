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

#define kActionSheetTagDelete 77

@interface UpDownloadViewController ()

@end

@implementation UpDownloadViewController
@synthesize table_view,upLoading_array,upLoaded_array,downLoading_array,downLoaded_array,customSelectButton,isShowUpload,deleteObject;


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
    isShowUpload = YES;
    float topHeigth = 0;
    if([[[UIDevice currentDevice] systemVersion] floatValue] >=7.0)
    {
        topHeigth = 64;
    }
    CGRect customRect = CGRectMake(0, topHeigth, 320, 30);
    self.customSelectButton = [[CustomSelectButton alloc] initWithFrame:customRect leftText:@"正在上传" rightText:@"正在下载" isShowLeft:isShowUpload];
    [self.customSelectButton setDelegate:self];
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
    CGRect table_rect = CGRectMake(0, customRect.origin.y+customRect.size.height, 320, self.view.bounds.size.height-(customRect.origin.y+customRect.size.height)-TabBarHeight);
    self.table_view = [[UITableView alloc] initWithFrame:table_rect];
    self.table_view.delegate = self;
    self.table_view.dataSource = self;
    [self.view addSubview:self.table_view];
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
        leftTitle = [NSString stringWithFormat:@"上传(%i)",[upLoading_array count]];
    }
    else
    {
        leftTitle = @"上传";
    }
    NSString *rightTitle;
    if([downLoading_array count]>0)
    {
        rightTitle = [NSString stringWithFormat:@"下载(%i)",[downLoading_array count]];
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
    isShowUpload = bl;
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
            DownList *ls = [self.downLoaded_array lastObject];
            list.d_id = ls.d_id;
            [self.downLoaded_array addObjectsFromArray:[list selectDownedAll]];
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
            UpLoadList *ls = [self.upLoaded_array lastObject];
            list.t_id = ls.t_id;
            [self.upLoaded_array addObjectsFromArray:[list selectUploadListAllAndUploaded]];
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
    [self updateTableViewCount];
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
        [cell setSelectionStyle:UITableViewCellSelectionStyleNone];
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
    [cell setDelegate:self];
    return cell;
}

-(void)deletCell:(NSObject *)object
{
    deleteObject = object;
    UIActionSheet *actionSheet = [[UIActionSheet alloc] initWithTitle:@"确定要删除此文件" delegate:self cancelButtonTitle:@"取消" destructiveButtonTitle:@"确定" otherButtonTitles:nil, nil];
    [actionSheet setTag:kActionSheetTagDelete];
    [actionSheet setActionSheetStyle:UIActionSheetStyleBlackOpaque];
    [actionSheet showInView:[[UIApplication sharedApplication] keyWindow]];
}

#pragma makr UIActionSheetDelegate

-(void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if(actionSheet.tag == kActionSheetTagDelete && buttonIndex == 0)
    {
        [self deleteList];
    }
}

-(void)deleteList
{
    NSObject *object = deleteObject;
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
                [table_view reloadData];
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
                [table_view reloadData];
                break;
            }
        }
    }
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
