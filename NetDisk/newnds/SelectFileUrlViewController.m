//
//  SelectFileUrlViewController.m
//  NetDisk
//
//  Created by Yangsl on 13-8-13.
//
//

#import "SelectFileUrlViewController.h"
#import "SCBSession.h"
#import "AppDelegate.h"
#import "SelectDetailViewController.h"
#import "YNFunctions.h"

#define ChangeTabWidth 90
#define RightButtonBoderWidth 0
#define TableViewHeight self.view.frame.size.height-44

@interface SelectFileUrlViewController ()

@end

@implementation SelectFileUrlViewController
@synthesize table_view,fileManager,tableArray,showType,isAutomatic,delegate,isEdtion;

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
    
    [self.navigationController setNavigationBarHidden:YES];
    
    space_id = [[SCBSession sharedSession] spaceID];
    
    [self.view setBackgroundColor:[UIColor whiteColor]];
    UIView *nbar=[[UIView alloc] initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, 44)];
    UIImageView *niv=[[UIImageView alloc] initWithImage:[UIImage imageNamed:@"Bk_Title.png"]];
    niv.frame=nbar.frame;
    [nbar addSubview:niv];
    [self.view addSubview:nbar];
    
    //把色值转换成图片
    CGRect rect_image = CGRectMake(0, 0, ChangeTabWidth, 44);
    UIGraphicsBeginImageContext(rect_image.size);
    CGContextRef context = UIGraphicsGetCurrentContext();
    CGContextSetFillColorWithColor(context,
                                   [hilighted_color CGColor]);
    CGContextFillRect(context, rect_image);
    UIImage * imge = [[UIImage alloc] init];
    imge = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    //标题
    UILabel *titleLabel=[[UILabel alloc] init];
    if(isAutomatic)
    {
        titleLabel.text=@"选择自动备份目录";
        if (self.showType==1) {
            titleLabel.text=@"家庭空间";
        }
    }
    else
    {
        titleLabel.text=@"选择转存位置";
        if (self.showType==1) {
            titleLabel.text=@"家庭空间";
        }
    }
    titleLabel.font=[UIFont boldSystemFontOfSize:18];
    titleLabel.textAlignment=UITextAlignmentCenter;
    titleLabel.backgroundColor=[UIColor clearColor];
    titleLabel.frame=CGRectMake(60, 0, 200, 44);
    [nbar addSubview:titleLabel];
    
    //返回按钮
    UIImage *back_image = [UIImage imageNamed:@"Bt_Back.png"];
    UIButton *back_button = [[UIButton alloc] initWithFrame:CGRectMake(RightButtonBoderWidth, (44-back_image.size.height/2)/2, back_image.size.width/2, back_image.size.height/2)];
    [back_button addTarget:self action:@selector(clicked_back) forControlEvents:UIControlEventTouchUpInside];
    [back_button setBackgroundImage:imge forState:UIControlStateHighlighted];
    [back_button setImage:back_image forState:UIControlStateNormal];
    [nbar addSubview:back_button];
    
    if(showType == 1)
    {
        tableArray = [[NSMutableArray alloc] init];
        fileManager = [[SCBFileManager alloc] init];
        [fileManager setDelegate:self];
        [fileManager requestOpenFamily:@""];
    }
    
    CGRect table_rect = CGRectMake(0, 44, 320, TableViewHeight);
	table_view = [[[UITableView alloc] initWithFrame:table_rect style:UITableViewStylePlain] autorelease];
    table_view.dataSource=self;
    table_view.delegate=self;
    [self.view addSubview:table_view];
    [table_view setBackgroundColor:[UIColor whiteColor]];
    [table_view setBackgroundView:nil];
}

#pragma mark SCBFileManagerDelegate ----------
-(void)getOpenFamily:(NSDictionary *)dictionary
{
    NSLog(@"dictionary:%@",dictionary);
    NSArray *array = [dictionary objectForKey:@"spaces"];
    if([array count] > 0)
    {
        [tableArray addObjectsFromArray:array];
        [table_view reloadData];
        NSMutableArray *marray=[NSMutableArray array];
        for (NSDictionary *dic in array) {
            NSString *str=[dic objectForKey:@"space_id"];
            if (str) {
                [marray addObject:str];
            }
        }
        [YNFunctions setAllFamily:marray];
    }
}


-(void)clicked_back
{
    [self.navigationController popViewControllerAnimated:YES];
}

#pragma mark UITableVieDelegate

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if(showType == 0)
    {
        return 4;
    }
    else
    {
        if([tableArray count] == 0)
        {
            return 1;
        }
        else
        {
            return [tableArray count];
        }
    }
}

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 50;
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *celleString = @"automicCell";
    UITableViewCell *cell = [table_view dequeueReusableCellWithIdentifier:celleString];
    if (cell == nil) {
        cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:celleString] autorelease];
        cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
        CGRect rect = cell.imageView.frame;
        rect.origin.x = 40;
        cell.imageView.frame = rect;
    }
    if(showType == 1)
    {
        if([tableArray count] == 0)
        {
            cell.textLabel.backgroundColor = [UIColor clearColor];
            cell.detailTextLabel.backgroundColor = [UIColor clearColor];
            cell.textLabel.text = @"等待中...";
            return cell;
        }
        else
        {
            NSDictionary *dictionary = (NSDictionary *)[tableArray objectAtIndex:indexPath.row];
            
            cell.textLabel.text = [NSString stringWithFormat:@"%@",[dictionary objectForKey:@"space_comment"]];
            cell.textLabel.textColor=[UIColor colorWithRed:66/255.0 green:75/255.0 blue:83/255.0 alpha:1.0f];
            [cell.imageView initWithImage:[UIImage imageNamed:@"Bt_PartakeshareDef.png"] highlightedImage:[UIImage imageNamed:@"Bt_PersonspaceCh.png"]];
            return cell;
        }
    }
    
    int row = [indexPath row];
    if(row == 0)
    {
        cell.textLabel.text = @"我的文件";
        cell.textLabel.textColor=[UIColor colorWithRed:66/255.0 green:75/255.0 blue:83/255.0 alpha:1.0f];
        [cell.imageView initWithImage:[UIImage imageNamed:@"Bt_PersonspaceDef.png"] highlightedImage:[UIImage imageNamed:@"Bt_PersonspaceCh.png"]];
    }
    else if(row == 1)
    {
        cell.textLabel.text = @"我创建的共享";
        cell.textLabel.textColor=[UIColor colorWithRed:66/255.0 green:75/255.0 blue:83/255.0 alpha:1.0f];
        [cell.imageView initWithImage:[UIImage imageNamed:@"Bt_MyShareDef.png"] highlightedImage:[UIImage imageNamed:@"Bt_MyShareCh.png"]];
    }
    else if(row == 2)
    {
        cell.textLabel.text = @"我参与的共享";
        cell.textLabel.textColor=[UIColor colorWithRed:66/255.0 green:75/255.0 blue:83/255.0 alpha:1.0f];
        [cell.imageView initWithImage:[UIImage imageNamed:@"Bt_PartakeshareDef.png"] highlightedImage:[UIImage imageNamed:@"Bt_PartakeshareCh.png"]];
    }
    else if(row == 3)
    {
        cell.textLabel.text = @"家庭空间";
        cell.textLabel.textColor=[UIColor colorWithRed:66/255.0 green:75/255.0 blue:83/255.0 alpha:1.0f];
        [cell.imageView initWithImage:[UIImage imageNamed:@"Bt_PartakeshareDef.png"] highlightedImage:[UIImage imageNamed:@"Bt_PartakeshareCh.png"]];
    }
    return cell;
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    AppDelegate *app_delegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
    
    if(showType == 0)
    {
        int row = [indexPath row];
        if(row == 0)
        {
            SelectDetailViewController *select_detailview = [[SelectDetailViewController alloc] init];
            select_detailview.space_id = @"1";
            select_detailview.title_string = @"我的文件";
            [app_delegate.title_string addObject:@"我的文件"];
            select_detailview.f_id = @"1";
            select_detailview.isAutomatic = isAutomatic;
            select_detailview.isEdtion = isEdtion;
            select_detailview.delegate = self;
            [self.navigationController pushViewController:select_detailview animated:YES];
            [select_detailview release];
        }
        else if(row == 1)
        {
            SelectDetailViewController *select_detailview = [[SelectDetailViewController alloc] init];
            select_detailview.space_id = @"2";
            select_detailview.title_string = @"我创建的共享";
            [app_delegate.title_string addObject:@"我创建的共享"];
            select_detailview.f_id = @"1";
            select_detailview.isAutomatic = isAutomatic;
            select_detailview.isEdtion = isEdtion;
            select_detailview.delegate = self;
            [self.navigationController pushViewController:select_detailview animated:YES];
            [select_detailview release];
        }
        else if(row == 2)
        {
            SelectDetailViewController *select_detailview = [[SelectDetailViewController alloc] init];
            select_detailview.space_id = @"3";
            select_detailview.title_string = @"我参与的共享";
            [app_delegate.title_string addObject:@"我参与的共享"];
            select_detailview.f_id = @"1";
            select_detailview.isAutomatic = isAutomatic;
            select_detailview.isEdtion = isEdtion;
            select_detailview.delegate = self;
            [self.navigationController pushViewController:select_detailview animated:YES];
            [select_detailview release];
        }
        else if(row == 3)
        {
            SelectFileUrlViewController *selectFileView = [[SelectFileUrlViewController alloc] init];
            selectFileView.showType = 1;
            selectFileView.isAutomatic = isAutomatic;
            selectFileView.isEdtion = isEdtion;
            selectFileView.delegate = self;
            [self.navigationController pushViewController:selectFileView animated:YES];
            [selectFileView release];
        }
    }
    else
    {
        NSDictionary *dictionary = (NSDictionary *)[tableArray objectAtIndex:indexPath.row];
        SelectDetailViewController *select_detailview = [[SelectDetailViewController alloc] init];
        select_detailview.space_id = [NSString stringWithFormat:@"%@",[dictionary objectForKey:@"space_id"]];
        select_detailview.title_string = [NSString stringWithFormat:@"%@",[dictionary objectForKey:@"space_comment"]];
        [app_delegate.title_string addObject:[NSString stringWithFormat:@"%@",[dictionary objectForKey:@"space_comment"]]];
        select_detailview.f_id = @"1";
        select_detailview.isAutomatic = isAutomatic;
        select_detailview.isEdtion = isEdtion;
        select_detailview.delegate = self;
        [self.navigationController pushViewController:select_detailview animated:YES];
        [select_detailview release];
    }
}

-(void)setFileSpace:(NSString *)spaceID withFileFID:(NSString *)fID
{
    if(self.delegate)
    {
        [self.delegate setFileSpace:spaceID withFileFID:fID];
    }
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void)dealloc
{
    if(tableArray)
    {
        [tableArray release];
    }
    if(fileManager)
    {
        [fileManager release];
    }
    [super dealloc];
}

@end
