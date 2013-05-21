//
//  PhotoViewController.m
//  NetDisk
//
//  Created by Yangsl on 13-5-2.
//
//

#import "PhotoViewController.h"
#import "SBJSON.h"
#import "PhohoDemo.h"
#import "PhotoDetailViewController.h"
#import "PhotoImageButton.h"
#import "PhotoCell.h"
#import "SCBSession.h"
#import "AppDelegate.h"
#import <QuartzCore/QuartzCore.h>

@interface PhotoViewController ()

@end

@implementation PhotoViewController
@synthesize photoManager,allDictionary;
@synthesize table_view;
@synthesize activity_indicator;
@synthesize user_id,user_token;

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
    imageTa = 1000;
    //添加分享按钮
    UINavigationItem *nav_item = [self navigationItem];
    UIButton *right_button = [UIButton buttonWithType:UIButtonTypeCustom];
    CGRect rect = CGRectMake(300, 7, 24, 24);
    [right_button setFrame:rect];
    [right_button setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
    [right_button.titleLabel setFont:[UIFont boldSystemFontOfSize:15.0]];
    [right_button setTitle:@"返回" forState:UIControlStateNormal];
    [right_button setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [right_button setImage:[UIImage imageNamed:@"Selected.png"] forState:UIControlStateNormal];
    [right_button addTarget:self action:@selector(right_button_cilcked:) forControlEvents:UIControlEventTouchUpInside];
    UIBarButtonItem *right_item = [[UIBarButtonItem alloc] initWithCustomView:right_button];
    [nav_item setRightBarButtonItem:right_item];
    
//    //请求时间轴
//    photoManager = [[SCBPhotoManager alloc] init];
//    [photoManager setPhotoDelegate:self];
//    [photoManager getPhotoTimeLine];
    _dicReuseCells = [[NSMutableDictionary alloc] init];
    _arrVisibleCells = [[NSMutableArray alloc] init];
    //设置背景为黑色
    [self.view setBackgroundColor:[UIColor blackColor]];
    [super viewDidLoad];
	// Do any additional setup after loading the view.
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark -标题栏的提交按钮
-(void)right_button_cilcked:(id)sender
{
//    AppDelegate *app_delegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
//    [app_delegate sendImageContent];
    if(editBL)
    {
        editBL = FALSE;
        NSArray *array = table_view.visibleCells;
        for(int i=0;i<[array count];i++)
        {
            PhotoCell *cell = (PhotoCell *)[array objectAtIndex:i];
            if(cell.bg1.image)
            {
                cell.imageViewButton1.alpha = 1;
                [cell.imageViewButton1 setBackgroundImage:nil forState:UIControlStateNormal];
            }
            if(cell.bg2.image)
            {
                cell.imageViewButton2.alpha = 1;
                [cell.imageViewButton2 setBackgroundImage:nil forState:UIControlStateNormal];
            }
            if(cell.bg3.image)
            {
                cell.imageViewButton3.alpha = 1;
                [cell.imageViewButton3 setBackgroundImage:nil forState:UIControlStateNormal];
            }
            if(cell.bg4.image)
            {
                cell.imageViewButton4.alpha = 1;
                [cell.imageViewButton4 setBackgroundImage:nil forState:UIControlStateNormal];
            }
        }

    }
    else
    {
        editBL = YES;
        NSArray *array = table_view.visibleCells;
        for(int i=0;i<[array count];i++)
        {
            PhotoCell *cell = (PhotoCell *)[array objectAtIndex:i];
            if(cell.bg1.image)
            {
                cell.imageViewButton1.alpha = 0.5;
                [cell.imageViewButton1 setBackgroundImage:[UIImage imageNamed:@"icon_Load.png"] forState:UIControlStateNormal];
            }
            if(cell.bg2.image)
            {
                cell.imageViewButton2.alpha = 0.5;
                [cell.imageViewButton2 setBackgroundImage:[UIImage imageNamed:@"icon_Load.png"] forState:UIControlStateNormal];
            }
            if(cell.bg3.image)
            {
                cell.imageViewButton3.alpha = 0.5;
                [cell.imageViewButton3 setBackgroundImage:[UIImage imageNamed:@"icon_Load.png"] forState:UIControlStateNormal];
            }
            if(cell.bg4.image)
            {
                cell.imageViewButton4.alpha = 0.5;
                [cell.imageViewButton4 setBackgroundImage:[UIImage imageNamed:@"icon_Load.png"] forState:UIControlStateNormal];
            }
        }

    }
}

#pragma mark -得到时间轴的列表
-(void)getPhotoTiimeLine:(NSDictionary *)dictionary
{
    //解析时间轴
    NSString *timeLine = [dictionary objectForKey:@"timeline"];
    NSMutableArray *tableArray = [[NSMutableArray alloc] init];
    NSRange range = [timeLine rangeOfString:@"],"];
    while (range.length>0) {
        NSString *time_string = [timeLine substringToIndex:range.location];
        time_string = [time_string substringFromIndex:6];
        time_string = [time_string stringByReplacingOccurrencesOfString:@"[" withString:@""];
        time_string = [time_string stringByReplacingOccurrencesOfString:@"]" withString:@""];
        NSArray *array = [time_string componentsSeparatedByString:@","];
        for(int i=0;i<[array count];i++)
        {
            NSString *_string = [NSString stringWithFormat:@"%@-%@",[[timeLine substringToIndex:5] substringFromIndex:1],[array objectAtIndex:i]];
            NSLog(@"--------------------------------string:%@",_string);
            [tableArray addObject:_string];
            
        }
        timeLine = [timeLine substringFromIndex:range.location+2];
        range = [timeLine rangeOfString:@"],"];
    }
    if([timeLine length]>0)
    {
        NSString *time_string = [timeLine substringFromIndex:6];
        time_string = [time_string stringByReplacingOccurrencesOfString:@"[" withString:@""];
        time_string = [time_string stringByReplacingOccurrencesOfString:@"]" withString:@""];
        NSArray *array = [time_string componentsSeparatedByString:@","];
        for(int i=0;i<[array count];i++)
        {
            NSString *_string = [NSString stringWithFormat:@"%@-%@",[[timeLine substringToIndex:5] substringFromIndex:1],[array objectAtIndex:i]];
            NSLog(@"--------------------------------string:%@",_string);
            [tableArray addObject:_string];
            
        }
    }
    NSLog(@"解析时间轴:%@",tableArray);
    //判断时间轴是否有值
    if([tableArray count] == 0)
    {
        [activity_indicator stopAnimating];
        UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"提示" message:@"你还没有上传图片" delegate:nil cancelButtonTitle:@"确认" otherButtonTitles:nil, nil];
        [alertView show];
        [alertView release];
    }
    else
    {
        [photoManager getAllPhotoGeneral:tableArray];
    }
}

#pragma mark -得到时间轴的概要列表
-(void)getPhotoGeneral:(NSDictionary *)dictionary
{
    [activity_indicator stopAnimating];
    if(!table_view)
    {
        table_view = [[UITableView alloc] initWithFrame:CGRectMake(0, 0, 320, self.view.frame.size.height)];
        [self.view addSubview:table_view];
        [table_view setSeparatorStyle:UITableViewCellSeparatorStyleNone];
        table_view.delegate = self;
        table_view.dataSource = self;
    }
    allDictionary = [[NSMutableDictionary alloc] initWithDictionary:dictionary];
    allKeys = [allDictionary objectForKey:@"timeLine"];
    [table_view reloadData];
    [self firstLoad];
//    [NSTimer scheduledTimerWithTimeInterval:0.5 target:self selector:@selector(firstLoad) userInfo:nil repeats:NO];
}

-(void)firstLoad
{
    [self scrollViewDidEndDragging:nil willDecelerate:YES];
}

-(void)getPhotoDetail:(NSDictionary *)dictionary
{
    
}



#pragma mark 进入详细页面
-(void)image_button_click:(id)sender
{
    PhotoImageButton *image_button = sender;
    if(editBL)
    {
        [image_button setBackgroundImage:[UIImage imageNamed:@"interestSelected.png"] forState:UIControlStateNormal];
    }
    else
    {
        NSArray *array = [allDictionary objectForKey:image_button.timeLine];
        PhotoDetailViewController *photoDetalViewController = [[PhotoDetailViewController alloc] init];
        photoDetalViewController.deleteDelegate = self;
        [self presentViewController:photoDetalViewController animated:YES completion:^{
            [photoDetalViewController setTimeLine:image_button.timeLine];
            [photoDetalViewController loadAllDiction:array currtimeIdexTag:image_button.timeIndex];
            [photoDetalViewController release];
        }];
    }
}

#pragma mark 删除回调
-(void)deleteForDeleteArray:(NSInteger)page timeLine:(NSString *)timeLineString
{
    if(page == -1)
    {
        [allDictionary removeObjectForKey:timeLineString];
        for(int i=0;i<[allKeys count];i++)
        {
            NSString *keyString = [allKeys objectAtIndex:i];
            if([keyString isEqualToString:timeLineString])
            {
                [allKeys removeObjectAtIndex:i];
                [allDictionary setObject:allKeys forKey:@"timeLine"];
                break;
            }
        }
    }
    else
    {
        NSMutableArray *array = [allDictionary objectForKey:timeLineString];
        [array removeObjectAtIndex:page];
        [allDictionary setObject:array forKey:timeLineString];
    }
    [table_view reloadData];
}

#pragma mark 滑动结束后，加载数据
- (void)scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate
{
    NSArray *array = table_view.visibleCells;
    for(int i=0;i<[array count];i++)
    {
        PhotoCell *cell = (PhotoCell *)[array objectAtIndex:i];
        [cell downImage];
    }
}

#pragma mark UITableViewDelegate
-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return [allKeys count];
}

-(NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{
    return [allKeys objectAtIndex:section];
}

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    NSArray *array = [allDictionary objectForKey:[allKeys objectAtIndex:section]];
    int number = [array count];
    if(number%4==0)
    {
        return number/4;
    }
    else
    {
        return number/4+1;
    }
}

-(float)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    return 20;
}

-(float)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 83;
}


-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    int section = [indexPath section];
    int row = [indexPath row];
    NSString *timeLine = [allKeys objectAtIndex:section];
    NSArray *array = [allDictionary objectForKey:timeLine];
    static  NSString *cellString = @"cellLoad";
    PhotoCell *photoCell = [tableView dequeueReusableCellWithIdentifier:cellString];
    if(!photoCell)
    {
        photoCell = [[[PhotoCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellString] autorelease];
        [photoCell setSelectionStyle:UITableViewCellSelectionStyleNone];
        [photoCell.imageViewButton1 addTarget:self action:@selector(image_button_click:) forControlEvents:UIControlEventTouchUpInside];
        [photoCell.imageViewButton2 addTarget:self action:@selector(image_button_click:) forControlEvents:UIControlEventTouchUpInside];
        [photoCell.imageViewButton3 addTarget:self action:@selector(image_button_click:) forControlEvents:UIControlEventTouchUpInside];
        [photoCell.imageViewButton4 addTarget:self action:@selector(image_button_click:) forControlEvents:UIControlEventTouchUpInside];
        
        [photoCell.bg1 setImage:nil];
        [photoCell.bg2 setImage:nil];
        [photoCell.bg3 setImage:nil];
        [photoCell.bg4 setImage:nil];
        
        [photoCell.imageViewButton2.layer setBorderWidth:0];
        [photoCell.imageViewButton3.layer setBorderWidth:0];
        [photoCell.imageViewButton4.layer setBorderWidth:0];
        
        [photoCell setOpaque:YES];
    }
    
    [photoCell.imageViewButton2 setDemo:nil];
    [photoCell.imageViewButton3 setDemo:nil];
    [photoCell.imageViewButton4 setDemo:nil];
    
    [photoCell.imageViewButton2 setIsShowImage:NO];
    [photoCell.imageViewButton3 setIsShowImage:NO];
    [photoCell.imageViewButton4 setIsShowImage:NO];
    photoCell.tag = 20000*(section+1)+row;
    if([array count]/4>=row+1)
    {
        [photoCell array:array index:row*4 timeLine:timeLine nunber:4];
    }
    else
    {
        int number = [array count]%4;
        [photoCell array:array index:row*4 timeLine:timeLine nunber:number];
    }
    [photoCell setNeedsDisplay];
    return photoCell;
}

-(BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath
{
    return NO;
}


-(void)viewWillAppear:(BOOL)animated
{
    if(![[[SCBSession sharedSession] userId] isEqualToString:user_id] && ![[[SCBSession sharedSession] userToken] isEqualToString:user_token])
    {
        if(photoManager)
        {
            [photoManager release];
            if(table_view)
            {
                [table_view removeFromSuperview];
                [table_view release];
            }
        }
        
        //请求时间轴
        photoManager = [[SCBPhotoManager alloc] init];
        [photoManager setPhotoDelegate:self];
        [photoManager getPhotoTimeLine];
        CGRect activityRect = CGRectMake((320-20)/2, (self.view.frame.size.height-20)/2, 20, 20);
        activity_indicator = [[UIActivityIndicatorView alloc] initWithFrame:activityRect];
        [activity_indicator setActivityIndicatorViewStyle:UIActivityIndicatorViewStyleWhite];
        [activity_indicator startAnimating];
        [self.view addSubview:activity_indicator];
        [self setUser_id:[[SCBSession sharedSession] userId]];
        [self setUser_token:[[SCBSession sharedSession] userToken]];
    }
}

-(void)dealloc
{
    [photoManager release];
    [table_view release];
    [allDictionary release];
    [activity_indicator release];
    [user_token release];
    [user_id release];
    [super dealloc];
}

@end
