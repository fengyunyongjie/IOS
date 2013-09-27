//
//  PhotoViewController.m
//  NetDisk
//
//  Created by Yangsl on 13-5-2.
//
//


#import "PhotoViewController.h"
#import "PhohoDemo.h"
#import "PhotoImageButton.h"
#import "PhotoCell.h"
#import "SCBSession.h"
#import "AppDelegate.h"
#import <QuartzCore/QuartzCore.h>
#import "YNFunctions.h"
#import "PhotoFile.h"
#import "PhotoFileCell.h"
#import "PhotoLookViewController.h"
#import "FileTableView.h"

#define TableViewHeight self.view.frame.size.height-TabBarHeight-44
#define ChangeTabWidth 90
#define RightButtonBoderWidth 0

@interface PhotoViewController ()

@end

@implementation PhotoViewController
@synthesize photoManager,allDictionary;
@synthesize table_view;
@synthesize activity_indicator;
@synthesize user_id,user_token;
@synthesize _arrVisibleCells,_dicReuseCells,bottonView,allKeys;
@synthesize deleteItem,right_item;
@synthesize done_item,downCellArray;
@synthesize isNeedBackButton;

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
    //添加头部试图
    [self.navigationController setNavigationBarHidden:YES];
    topView = [[[UIView alloc] initWithFrame:CGRectMake(0, 0, 320, 44)] autorelease];
    UIImageView *imageV = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, 320, 44)];
    [imageV setImage:[UIImage imageNamed:@"Bk_Title.png"]];
    [topView addSubview:imageV];
    [imageV release];
    //把色值转换成图片
    CGRect rect_image = CGRectMake(0, 0, ChangeTabWidth, 44);
    UIGraphicsBeginImageContext(rect_image.size);
    CGContextRef context = UIGraphicsGetCurrentContext();
    CGContextSetFillColorWithColor(context,
                                   [hilighted_color CGColor]);
    CGContextFillRect(context, rect_image);
    UIImage * imge = [[[UIImage alloc] init] autorelease];
    imge = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    //返回按钮
    if(isNeedBackButton)
    {
        UIImage *back_image = [UIImage imageNamed:@"Bt_Back.png"];
        UIButton *back_button = [[UIButton alloc] initWithFrame:CGRectMake(RightButtonBoderWidth, (44-back_image.size.height/2)/2, back_image.size.width/2, back_image.size.height/2)];
        [back_button setBackgroundImage:imge forState:UIControlStateHighlighted];
        [back_button setImage:back_image forState:UIControlStateNormal];
        [topView addSubview:back_button];
        [back_button release];
    }
    //选项卡栏目
    UIButton *phoot_button = [[UIButton alloc] init];
    [phoot_button setTag:23];
    [phoot_button setFrame:CGRectMake(320/2-ChangeTabWidth, 0, ChangeTabWidth, 44)];
    [phoot_button setTitle:@"文件" forState:UIControlStateNormal];
    [phoot_button setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
    [phoot_button addTarget:self action:@selector(clicked_file:) forControlEvents:UIControlEventTouchDown];
    [phoot_button setBackgroundImage:imge forState:UIControlStateHighlighted];
    [topView addSubview:phoot_button];
    [self clicked_file:phoot_button];
    [phoot_button release];
    
    UIButton *file_button = [[UIButton alloc] init];
    [file_button setTag:24];
    [file_button setFrame:CGRectMake(320/2, 0, ChangeTabWidth, 44)];
    [file_button setTitle:@"照片" forState:UIControlStateNormal];
    [file_button setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
    [file_button addTarget:self action:@selector(clicked_photo:) forControlEvents:UIControlEventTouchDown];
    [file_button setBackgroundImage:imge forState:UIControlStateHighlighted];
    [topView addSubview:file_button];
    
    [file_button release];
    
    
    
    //更多按钮
    UIButton *more_button = [[UIButton alloc] init];
    UIImage *moreImage = [UIImage imageNamed:@"Bt_More.png"];
    [more_button setFrame:CGRectMake(320-RightButtonBoderWidth-moreImage.size.width/2, (44-moreImage.size.height/2)/2, moreImage.size.width/2, moreImage.size.height/2)];
    [more_button setImage:moreImage forState:UIControlStateNormal];
    [more_button setBackgroundImage:imge forState:UIControlStateHighlighted];
    [more_button addTarget:self action:@selector(clicked_more:) forControlEvents:UIControlEventTouchDown];
    [topView addSubview:more_button];
    [more_button release];
    [self.view addSubview:topView];
    
    
    imageTa = 1000;
    operationQueue = [[NSOperationQueue alloc] init];
    //添加分享按钮
    UINavigationItem *nav_item = [self navigationItem];
    right_item = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemEdit target:self action:@selector(right_button_cilcked:)];
    [nav_item setRightBarButtonItem:right_item];
    //添加删除按钮
    deleteItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemTrash target:self action:@selector(deleteButton)];
    //添加完成按钮
    done_item = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemDone target:self action:@selector(right_button_cilcked:)];
    
    //初始化基本数据
    _dicReuseCells = [[NSMutableDictionary alloc] init];
    _arrVisibleCells = [[NSMutableArray alloc] init];
    self.downCellArray = [[NSMutableArray alloc] init];
    //设置背景为黑色
    [self.view setBackgroundColor:[UIColor blackColor]];
    if(activity_indicator)
    {
        [activity_indicator startAnimating];
    }
    else
    {
        CGRect activityRect = CGRectMake((320-20)/2, (self.view.frame.size.height-20-49)/2, 20, 20);
        activity_indicator = [[UIActivityIndicatorView alloc] initWithFrame:activityRect];
        [activity_indicator setActivityIndicatorViewStyle:UIActivityIndicatorViewStyleWhite];
        [activity_indicator startAnimating];
        [self.view addSubview:activity_indicator];
    }
    tablediction = [[NSMutableDictionary alloc] init];
    sectionarray = [[NSMutableArray alloc] init];
    
    
//    CGRect rect = CGRectMake(0, 44, 320, TableViewHeight);
//    self.table_view = [[UITableView alloc] initWithFrame:rect];
//    [self.table_view setSeparatorStyle:UITableViewCellSeparatorStyleNone];
//    [self.table_view setDataSource:self];
//    [self.table_view setDelegate:self];
//    self.table_view.showsVerticalScrollIndicator = NO;
//    self.table_view.alwaysBounceVertical = YES;
//    self.table_view.alwaysBounceHorizontal = NO;
//    [self.view addSubview:self.table_view];
//    selfLenght = self.view.frame.size.height-49-66;
//    endFloat = 10000;
//    isPhoto = TRUE;
//    
//    //请求时间轴
//    photoManager = [[SCBPhotoManager alloc] init];
//    [photoManager setPhotoDelegate:self];
    
    //请求文件
    CGRect rect = CGRectMake(0, 44, 320, TableViewHeight);
    FileTableView *file_tableview = [[FileTableView alloc] initWithFrame:rect];
    [file_tableview setAllHeight:self.view.frame.size.height];
    [self.view addSubview:file_tableview];
    [file_tableview requestFile:@"1" space_id:[[SCBSession sharedSession] spaceID]];
    [file_tableview release];
    
    [super viewDidLoad];
	// Do any additional setup after loading the view.
}

-(void)clicked_photo:(id)sender
{
    
    UIButton *button = sender;
    //把色值转换成图片
    CGRect rect_image = CGRectMake(0, 0, ChangeTabWidth, 44);
    UIGraphicsBeginImageContext(rect_image.size);
    CGContextRef context = UIGraphicsGetCurrentContext();
    CGContextSetFillColorWithColor(context,
                                   [hilighted_color CGColor]);
    CGContextFillRect(context, rect_image);
    UIImage * imge = [[[UIImage alloc] init] autorelease];
    imge = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    [button setBackgroundImage:imge forState:UIControlStateNormal];
    [button setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    
    UIButton *photo_button = (UIButton *)[self.view viewWithTag:23];
    [photo_button setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
    [photo_button setBackgroundImage:nil forState:UIControlStateNormal];
    
    if(!isPhoto)
    {
        isPhoto = TRUE;
    }
    [self.table_view reloadData];
}

-(void)clicked_file:(id)sender
{
    UIButton *button = sender;
    //把色值转换成图片
    CGRect rect_image = CGRectMake(0, 0, ChangeTabWidth, 44);
    UIGraphicsBeginImageContext(rect_image.size);
    CGContextRef context = UIGraphicsGetCurrentContext();
    CGContextSetFillColorWithColor(context,
                                   [hilighted_color CGColor]);
    CGContextFillRect(context, rect_image);
    UIImage * imge = [[[UIImage alloc] init] autorelease];
    imge = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    [button setBackgroundImage:imge forState:UIControlStateNormal];
    [button setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    
    UIButton *file_button = (UIButton *)[self.view viewWithTag:24];
    [file_button setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
    [file_button setBackgroundImage:nil forState:UIControlStateNormal];
    
    if(isPhoto)
    {
        isPhoto = FALSE;
    }
}

-(void)clicked_more:(id)sender
{

}


- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark -标题栏的编辑按钮
-(void)right_button_cilcked:(id)sender
{
    UINavigationItem *nav_item = [self navigationItem];
    if(editBL)
    {
        editBL = FALSE;
        [nav_item setLeftBarButtonItem:nil];
        [nav_item setRightBarButtonItem:right_item];
        NSArray *cellArrays = [self.table_view indexPathsForVisibleRows];
        for(int i=0;i<[cellArrays count];i++)
        {
            PhotoFileCell *cell = (PhotoFileCell *)[self.table_view cellForRowAtIndexPath:[cellArrays objectAtIndex:i]];
            NSArray *array = [cell cellArray];
            for(int j=0;j<[array count];j++)
            {
                CellTag *cellTag = [array objectAtIndex:j];
                for(int k=0;k<[[_dicReuseCells allKeys] count];k++)
                {
                    int fid = [[_dicReuseCells objectForKey:[[_dicReuseCells allKeys] objectAtIndex:k]] intValue];
                    if(cellTag.fileTag == fid)
                    {
                        UIButton *button = (UIButton *)[self.table_view viewWithTag:cellTag.buttonTag];
                        [button setBackgroundImage:[UIImage imageNamed:@"111.png"] forState:UIControlStateNormal];
                        [button setSelected:NO];
                    }
                }
            }
        }
    }
    else
    {
        [_dicReuseCells removeAllObjects];
        [nav_item setLeftBarButtonItem:deleteItem];
        [nav_item setRightBarButtonItem:done_item];
        editBL = YES;
    }
}

-(void)didFailWithError
{
    isReload = FALSE;
}

#pragma mark -得到时间轴的列表

#pragma mark PhotoManagerDelegate

-(void)getFileDetail:(NSDictionary *)dictionary
{
    
}

-(void)getPhotoDetail:(NSDictionary *)dictionary
{
    
}

-(void)getPhotoTiimeLine:(NSDictionary *)dictionary
{
    if(hud == nil)
    {
        hud = [[MBProgressHUD alloc] initWithView:self.view];
        hud.mode=MBProgressHUDModeIndeterminate;
        hud.labelText=@"正在加载";
        [self.view addSubview:hud];
        [hud show:YES];
    }
    
    [self.table_view clearsContextBeforeDrawing];
    [tablediction removeAllObjects];
    [sectionarray removeAllObjects];
    NSCalendar *calendar = [NSCalendar currentCalendar];
    NSDate *todayDate = [NSDate date];
    NSDateComponents *todayComponent = [calendar components:NSEraCalendarUnit| NSYearCalendarUnit| NSMonthCalendarUnit| NSDayCalendarUnit| NSHourCalendarUnit| NSMinuteCalendarUnit | NSSecondCalendarUnit| NSWeekCalendarUnit | NSWeekdayCalendarUnit | NSWeekdayOrdinalCalendarUnit | NSQuarterCalendarUnit | NSWeekOfMonthCalendarUnit | NSWeekOfYearCalendarUnit | NSYearForWeekOfYearCalendarUnit fromDate:todayDate];
    
    //今天的起止时间
    NSString *eString  = [NSString stringWithFormat:@"%i-%i-%i %i:%i",todayComponent.year,todayComponent.month,todayComponent.day,todayComponent.hour,todayComponent.minute];
    NSString *sString  = [NSString stringWithFormat:@"%i-%i-%i 00:00",todayComponent.year,todayComponent.month,todayComponent.day];
    PhotoFile *photo_file = [[PhotoFile alloc] init];
    NSArray *timeArray = [photo_file selectMoreTaskTable:sString eDate:eString];
    if([timeArray count]>0)
    {
        [sectionarray addObject:timeLine1];
        [tablediction setObject:timeArray forKey:timeLine1];
    }
    NSLog(@"timeArray:%@ \n count:%i",timeArray,[timeArray count]);
    //昨天的起止时间
    if([self startTimeMoreThanEndTime:sString eTime:eString])
    {
        eString = sString;
    }
    if(todayComponent.day-2 == -1)
    {
        sString  = [NSString stringWithFormat:@"%i-%i-%i 00:00",todayComponent.year,todayComponent.month-1,[self theDaysInYear:todayComponent.year inMonth:todayComponent.month-1]];
    }
    else
    {
        sString  = [NSString stringWithFormat:@"%i-%i-%i 00:00",todayComponent.year,todayComponent.month,todayComponent.day-1];
    }
    
    timeArray = [photo_file selectMoreTaskTable:sString eDate:eString];
    if([timeArray count]>0)
    {
        [sectionarray addObject:timeLine2];
        [tablediction setObject:timeArray forKey:timeLine2];
    }
    NSLog(@"timeArray:%@ \n count:%i",timeArray,[timeArray count]);
    
    //本周的起止时间
    if([self startTimeMoreThanEndTime:sString eTime:eString])
    {
        eString = sString;
    }
    if(todayComponent.day-todayComponent.weekday < 0)
    {
        sString  = [NSString stringWithFormat:@"%i-%i-%i 00:00",todayComponent.year,todayComponent.month-1,[self theDaysInYear:todayComponent.year inMonth:todayComponent.month-1]+(todayComponent.day-todayComponent.weekday)+1];
    }
    else
    {
        sString  = [NSString stringWithFormat:@"%i-%i-%i 00:00",todayComponent.year,todayComponent.month,todayComponent.day-todayComponent.weekday+1];
    }
    timeArray = [photo_file selectMoreTaskTable:sString eDate:eString];
    if([timeArray count]>0)
    {
        [sectionarray addObject:timeLine3];
        [tablediction setObject:timeArray forKey:timeLine3];
    }
    NSLog(@"timeArray:%@ \n count:%i",timeArray,[timeArray count]);
    
    //上一周的起止时间
    if([self startTimeMoreThanEndTime:sString eTime:eString])
    {
        eString = sString;
    }
    if(todayComponent.day-(todayComponent.weekday+7)<0)
    {
        sString  = [NSString stringWithFormat:@"%i-%i-%i 00:00",todayComponent.year,todayComponent.month-1,[self theDaysInYear:todayComponent.year inMonth:todayComponent.month-1]+(todayComponent.day-(todayComponent.weekday+7))+1];
    }
    else
    {
        sString  = [NSString stringWithFormat:@"%i-%i-%i 00:00",todayComponent.year,todayComponent.month,todayComponent.day-(todayComponent.weekday+7)+1];
    }
    timeArray = [photo_file selectMoreTaskTable:sString eDate:eString];
    if([timeArray count]>0)
    {
        [sectionarray addObject:timeLine4];
        [tablediction setObject:timeArray forKey:timeLine4];
    }
    NSLog(@"timeArray:%@ \n count:%i",timeArray,[timeArray count]);
    
    //本月的起止时间
    if([self startTimeMoreThanEndTime:sString eTime:eString])
    {
        eString = sString;
    }
    sString  = [NSString stringWithFormat:@"%i-%i-%i 00:00",todayComponent.year,todayComponent.month,1];
    timeArray = [photo_file selectMoreTaskTable:sString eDate:eString];
    if([timeArray count]>0)
    {
        [sectionarray addObject:timeLine5];
        [tablediction setObject:timeArray forKey:timeLine5];
    }
    NSLog(@"timeArray:%@ \n count:%i",timeArray,[timeArray count]);
    
    //上个月的起止时间
    if([self startTimeMoreThanEndTime:sString eTime:eString])
    {
        eString = sString;
    }
    sString  = [NSString stringWithFormat:@"%i-%i-%i 00:00",todayComponent.year,todayComponent.month-1,1];
    timeArray = [photo_file selectMoreTaskTable:sString eDate:eString];
    if([timeArray count]>0)
    {
        [sectionarray addObject:timeLine6];
        [tablediction setObject:timeArray forKey:timeLine6];
    }
    NSLog(@"timeArray:%@ \n count:%i",timeArray,[timeArray count]);
    
    //本年的起止时间
    if([self startTimeMoreThanEndTime:sString eTime:eString])
    {
        eString = sString;
    }
    sString  = [NSString stringWithFormat:@"%i-%i-%i 00:00",todayComponent.year,1,1];
    timeArray = [photo_file selectMoreTaskTable:sString eDate:eString];
    if([timeArray count]>0)
    {
        [sectionarray addObject:timeLine7];
        [tablediction setObject:timeArray forKey:timeLine7];
    }
    NSLog(@"timeArray:%@ \n count:%i",timeArray,[timeArray count]);
    
    //十年内的数据
    for(int i=1;i<=10;i++)
    {
        if([self startTimeMoreThanEndTime:sString eTime:eString])
        {
            eString = sString;
        }
        sString  = [NSString stringWithFormat:@"%i-%i-%i 00:00",todayComponent.year-i,1,1];
        timeArray = [photo_file selectMoreTaskTable:sString eDate:eString];
        if([timeArray count]>0)
        {
            [sectionarray addObject:[NSString stringWithFormat:@"%i年",todayComponent.year-i]];
            [tablediction setObject:timeArray forKey:[NSString stringWithFormat:@"%i年",todayComponent.year-i]];
        }
        NSLog(@"timeArray:%@ \n count:%i",timeArray,[timeArray count]);
    }
    
    [self.table_view reloadData];
    
    isLoadImage = TRUE;
    isSort = TRUE;
    isReload = FALSE;
    
    [hud hide:YES afterDelay:0.8f];
    [hud release];
    hud = nil;
    
    [NSTimer scheduledTimerWithTimeInterval:0.5 target:self selector:@selector(FirstLoad) userInfo:nil repeats:NO];
}

-(BOOL)startTimeMoreThanEndTime:(NSString *)sTime eTime:(NSString *)eTime
{
    NSDateFormatter *dateFormatter = [[[NSDateFormatter alloc] init] autorelease];
    [dateFormatter setDateStyle:NSDateFormatterMediumStyle];
    [dateFormatter setTimeStyle:NSDateFormatterShortStyle];
    [dateFormatter setDateFormat:@"yyyy-MM-dd HH:mm"];
    NSDate *sDate = [dateFormatter dateFromString:sTime];
    NSDate *eDate = [dateFormatter dateFromString:eTime];
    if([sDate timeIntervalSince1970]<[eDate timeIntervalSince1970])
    {
        return YES;
    }
    return NO;
}

#pragma mark 得到月份天数
-(int)theDaysInYear:(int)year inMonth:(int)month
{
    if (month == 1||month == 3||month == 5||month == 7||month == 8||month == 10||month == 12) {
        return 31;
    }
    if (month == 4||month == 6||month == 9||month == 11) {
        return 30;
    }
    if ((year % 4 == 0 && year % 100 != 0) || year % 400 == 0) {
        return 29;
    }
    return 28;
}

#pragma mark -得到时间轴的概要列表
-(void)getPhotoGeneral:(NSDictionary *)dictionary photoDictioin:(NSMutableDictionary *)photoDic
{
    if(activity_indicator)
    {
        [activity_indicator startAnimating];
    }
    if(!allDictionary)
    {
        allDictionary = [[NSMutableDictionary alloc] initWithDictionary:dictionary];
    }
    
    if(photo_diction)
    {
        if([[photo_diction allKeys] count] != [[photoDic allKeys] count])
        {
            [allDictionary removeAllObjects];
            [allDictionary setDictionary:dictionary];
            
            [photo_diction removeAllObjects];
            [photo_diction setDictionary:photoDic];
            [allKeys removeAllObjects];
            [allKeys setArray:[allDictionary allKeys]];
        }
    }
    else
    {
        photo_diction = [[NSMutableDictionary alloc] initWithDictionary:photoDic];
    }
    if(!allKeys)
    {
        allKeys = [[NSMutableArray alloc] initWithArray:[allDictionary objectForKey:@"timeLine"]];
    }
    //    if(scroll_view)
    //    {
    //        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 0), ^{
    //            [self loadViewData];
    //        });
    //    }
    //    else
    {
        dispatch_async(dispatch_get_main_queue(), ^{
            [self loadViewData];
        });
    }
}

-(void)loadViewData
{
    if(scroll_view)
    {
        [scroll_view removeFromSuperview];
        [scroll_view release];
    }
    scroll_view = [[UIScrollView alloc] initWithFrame:CGRectMake(0, 0, 320, self.view.frame.size.height)];
    [scroll_view setBackgroundColor:[UIColor whiteColor]];
    [scroll_view setDelegate:self];
    [self.view addSubview:scroll_view];
    
    NSArray *array = [allDictionary objectForKey:@"timeLine"];
    int scrollview_heigth = 0;
    for(int i=0;i<[array count];i++)
    {
        NSArray *arrayA = [allDictionary objectForKey:[array objectAtIndex:i]];
        CGRect titleRect = CGRectMake(0, scrollview_heigth, 320, 25);
        UIImageView *titleImage = [[UIImageView alloc] initWithFrame:titleRect];
        CGRect titleLabelRect = CGRectMake(0, 2, 320, 25);
        UILabel *titleLabel = [[UILabel alloc] initWithFrame:titleLabelRect];
        [titleLabel setText:[array objectAtIndex:i]];
        [titleLabel setBackgroundColor:[UIColor clearColor]];
        [titleImage addSubview:titleLabel];
        [titleLabel release];
        [titleImage setImage:[UIImage imageNamed:@"title_bg.png"]];
        [scroll_view addSubview:titleImage];
        [titleImage release];
        scrollview_heigth += 29;
        for(int j=0;j<[arrayA count];j++)
        {
            PhohoDemo *demo = [photo_diction objectForKey:[arrayA objectAtIndex:j]];
            if(j%4==0&&j!=0)
            {
                scrollview_heigth += 79;
            }
            CGRect imageButtonRect = CGRectMake((j%4)*79+4, scrollview_heigth+4, 75, 75);
            PhotoImageButton *imageButton = [[[PhotoImageButton alloc] initWithFrame:imageButtonRect] autorelease];
            [imageButton addTarget:self action:@selector(image_button_click:) forControlEvents:UIControlEventTouchDown];
            [imageButton setDemo:demo];
            [imageButton setTag:demo.f_id];
            [imageButton setTimeLine:[array objectAtIndex:i]];
            [imageButton setTimeIndex:j];
            NSString *path = [self get_image_save_file_path:demo.f_name];
            if([self image_exists_at_file_path:path])
            {
                UIImage *imageDemo = [UIImage imageWithContentsOfFile:path];
                [imageButton setBackgroundImage:imageDemo forState:UIControlStateNormal];
            }
            else
            {
                UIImage *imageDemo = [UIImage imageNamed:@"icon_Load.png"];
                [imageButton setBackgroundImage:imageDemo forState:UIControlStateNormal];
            }
            [scroll_view addSubview:imageButton];
            [demo setIsSelected:NO];
        }
        scrollview_heigth += 79+4;
    }
    [scroll_view setContentSize:CGSizeMake(320, scrollview_heigth+10)];
    [self scrollViewDidEndDragging:scroll_view willDecelerate:YES];
}

-(void)firstLoad
{
    [self scrollViewDidEndDragging:nil willDecelerate:YES];
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
    [self.table_view reloadData];
}

-(void)appImageDidLoad:(NSInteger)indexTag urlImage:(UIImage *)image index:(int)index
{
    if(isLoadImage)
    {
        NSObject *obj = [self.table_view viewWithTag:indexTag];
        if(!obj)
        {
            return;
        }
        
        UIImageView *image_view = (UIImageView *)obj;
        UIImage *imageV = image;
        if(imageV.size.width>=imageV.size.height)
        {
            if(imageV.size.height<=200)
            {
                CGRect imageRect = CGRectMake((imageV.size.width-imageV.size.height)/2, 0, imageV.size.height, imageV.size.height);
                imageV = [self imageFromImage:imageV inRect:imageRect];
                [image_view performSelectorOnMainThread:@selector(setImage:) withObject:imageV waitUntilDone:YES];
            }
            else
            {
                CGSize newImageSize;
                newImageSize.height = 200;
                newImageSize.width = 200*imageV.size.width/imageV.size.height;
                UIImage *imageS = [self scaleFromImage:imageV toSize:newImageSize];
                CGRect imageRect = CGRectMake((newImageSize.width-200)/2, 0, 200, 200);
                imageS = [self imageFromImage:imageS inRect:imageRect];
                [image_view performSelectorOnMainThread:@selector(setImage:) withObject:imageS waitUntilDone:YES];
            }
        }
        else if(imageV.size.width<=imageV.size.height)
        {
            if(imageV.size.width<=200)
            {
                CGRect imageRect = CGRectMake(0, (imageV.size.height-imageV.size.width)/2, imageV.size.width, imageV.size.width);
                imageV = [self imageFromImage:imageV inRect:imageRect];
                [image_view performSelectorOnMainThread:@selector(setImage:) withObject:imageV waitUntilDone:YES];
            }
            else
            {
                CGSize newImageSize;
                newImageSize.width = 200;
                newImageSize.height = 200*imageV.size.height/imageV.size.width;
                UIImage *imageS = [self scaleFromImage:imageV toSize:newImageSize];
                CGRect imageRect = CGRectMake(0, (newImageSize.height-200)/2, 200, 200);
                imageS = [self imageFromImage:imageS inRect:imageRect];
                [image_view performSelectorOnMainThread:@selector(setImage:) withObject:imageS waitUntilDone:YES];
            }
        }
    }
}

#pragma mark UITableViewDelegate

-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    if(isPhoto)
    {
        return [sectionarray count];
    }
}

-(NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{
    if(isPhoto)
    {
        return [sectionarray objectAtIndex:section];
    }
}

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if(isPhoto)
    {
        NSArray *array = [tablediction objectForKey:[sectionarray objectAtIndex:section]];
        int number = [array count];
        if(number%3==0)
        {
            return number/3;
        }
        else
        {
            return number/3+1;
        }
    }
}

-(float)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    if(isPhoto)
    {
        return 20;
    }
}

-(float)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSArray *array = [tablediction objectForKey:[sectionarray objectAtIndex:[indexPath section]]];
    int number = [array count];
    if(([indexPath row]+1)*3 >= number)
    {
        return 110;
    }
    return 105;
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    int section = [indexPath section];
    int row = [indexPath row];
    static NSString *cellString = @"cellString";
    PhotoFileCell *cell = [table_view dequeueReusableCellWithIdentifier:cellString];
    if(cell == nil)
    {
        cell = [[[PhotoFileCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellString] autorelease];
        [cell setSelectionStyle:UITableViewCellSelectionStyleNone];
    }
    else
    {
        while ([cell.contentView.subviews lastObject] != nil) {
            [(UIView*)[cell.contentView.subviews lastObject] removeFromSuperview];  //删除并进行重新分配
        }
    }
    
    NSString *sectionNumber = [sectionarray objectAtIndex:section];
    NSArray *array = [tablediction objectForKey:sectionNumber];
    if([array count]/3 == row)
    {
        cell.tag = row+UICellTag*section;
        int number = 3;
        if([array count]%3>0)
        {
            number = [array count]%3;
        }
        NSMutableArray *cellArray = [[NSMutableArray alloc] init];
        NSMutableArray *imageArray = [[NSMutableArray alloc] init];
        for(int i=0;i<number;i++)
        {
            if(row*3+i>=[array count])
            {
                break;
            }
            CellTag *cellT = [[CellTag alloc] init];
            PhotoFile *demo = [array objectAtIndex:row*3+i];
            [cellT setFileTag:demo.f_id];
            CGRect rect = CGRectMake(i*105+5, 5, 100, 100);
            UIImageView *image = [[UIImageView alloc] initWithFrame:rect];
            image.tag = UIImageTag+demo.f_id;
            [cellT setImageTag:image.tag];
            
            
            
            {
                UIImage *imageV = [UIImage imageNamed:@"icon_Load.png"];
                [image performSelectorOnMainThread:@selector(setImage:) withObject:imageV waitUntilDone:YES];
            }
            
            dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_BACKGROUND, 0), ^{
                if([self image_exists_at_file_path:[NSString stringWithFormat:@"%i",demo.f_id]])
                {
                    NSString *path = [self get_image_save_file_path:[NSString stringWithFormat:@"%i",demo.f_id]];
                    UIImage *imageV = [UIImage imageWithContentsOfFile:path];
                    
                    if(imageV.size.width>=imageV.size.height)
                    {
                        if(imageV.size.height<=200)
                        {
                            CGRect imageRect = CGRectMake((imageV.size.width-imageV.size.height)/2, 0, imageV.size.height, imageV.size.height);
                            imageV = [self imageFromImage:imageV inRect:imageRect];
                            [image performSelectorOnMainThread:@selector(setImage:) withObject:imageV waitUntilDone:YES];
                        }
                        else
                        {
                            CGSize newImageSize;
                            newImageSize.height = 200;
                            newImageSize.width = 200*imageV.size.width/imageV.size.height;
                            UIImage *imageS = [self scaleFromImage:imageV toSize:newImageSize];
                            CGRect imageRect = CGRectMake((newImageSize.width-200)/2, 0, 200, 200);
                            imageS = [self imageFromImage:imageS inRect:imageRect];
                            [image performSelectorOnMainThread:@selector(setImage:) withObject:imageS waitUntilDone:YES];
                        }
                    }
                    else if(imageV.size.width<=imageV.size.height)
                    {
                        if(imageV.size.width<=200)
                        {
                            CGRect imageRect = CGRectMake(0, (imageV.size.height-imageV.size.width)/2, imageV.size.width, imageV.size.width);
                            imageV = [self imageFromImage:imageV inRect:imageRect];
                            [image performSelectorOnMainThread:@selector(setImage:) withObject:imageV waitUntilDone:YES];
                        }
                        else
                        {
                            CGSize newImageSize;
                            newImageSize.width = 200;
                            newImageSize.height = 200*imageV.size.height/imageV.size.width;
                            UIImage *imageS = [self scaleFromImage:imageV toSize:newImageSize];
                            CGRect imageRect = CGRectMake(0, (newImageSize.height-200)/2, 200, 200);
                            imageS = [self imageFromImage:imageS inRect:imageRect];
                            [image performSelectorOnMainThread:@selector(setImage:) withObject:imageS waitUntilDone:YES];
                        }
                    }
                }
            });
            
            [cell.contentView addSubview:image];
            [imageArray addObject:image];
            
            SelectButton *button = [[SelectButton alloc] initWithFrame:rect];
            [button setTag:UIButtonTag+demo.f_id];
            [cellT setButtonTag:button.tag];
            [cellT setSectionTag:section];
            [cellT setPageTag:row*3+i];
            [cellArray addObject:cellT];
            [button setCell:cellT];
            
            [image release];
            [cellT release];
            [button addTarget:self action:@selector(clicked:) forControlEvents:UIControlEventTouchUpInside];
            if(editBL)
            {
                for(int i=0;i<[[_dicReuseCells allKeys] count];i++)
                {
                    int fid = [[_dicReuseCells objectForKey:[[_dicReuseCells allKeys] objectAtIndex:i]] intValue];
                    if(demo.f_id == fid)
                    {
                        [button setBackgroundImage:[UIImage imageNamed:@"interestSelected.png"] forState:UIControlStateNormal];
                    }
                }
            }
            [cell.contentView addSubview:button];
            [button release];
            
            NSLog(@"imageCount:%i",image.retainCount);
        }
        if([downCellArray count]>5)
        {
            [downCellArray removeObjectAtIndex:0];
        }
        [downCellArray addObject:cell];
        //        operation *queue = [[operation alloc] init];
        //        [queue cellArray:cellArray imagev:imageArray];
        //        [operationQueue addOperation:queue];
        //        [queue release];
        [cell setCellArray:cellArray];
        [cellArray release];
        [imageArray release];
    }
    else
    {
        cell.tag = row+UICellTag*section;
        NSMutableArray *cellArray = [[NSMutableArray alloc] init];
        NSMutableArray *imageArray = [[NSMutableArray alloc] init];
        for(int i=0;i<3;i++)
        {
            CellTag *cellT = [[CellTag alloc] init];
            PhotoFile *demo = [array objectAtIndex:row*3+i];
            [cellT setFileTag:demo.f_id];
            CGRect rect = CGRectMake(i*105+5, 5, 100, 100);
            UIImageView *image = [[UIImageView alloc] initWithFrame:rect];
            image.tag = UIImageTag+demo.f_id;
            [cellT setImageTag:image.tag];
            
            {
                UIImage *imageV = [UIImage imageNamed:@"icon_Load.png"];
                [image performSelectorOnMainThread:@selector(setImage:) withObject:imageV waitUntilDone:YES];
            }
            
            dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_BACKGROUND, 0), ^{
                if([self image_exists_at_file_path:[NSString stringWithFormat:@"%i",demo.f_id]])
                {
                    NSString *path = [self get_image_save_file_path:[NSString stringWithFormat:@"%i",demo.f_id]];
                    UIImage *imageV = [UIImage imageWithContentsOfFile:path];
                    if(imageV.size.width>=imageV.size.height)
                    {
                        if(imageV.size.height<=200)
                        {
                            CGRect imageRect = CGRectMake((imageV.size.width-imageV.size.height)/2, 0, imageV.size.height, imageV.size.height);
                            imageV = [self imageFromImage:imageV inRect:imageRect];
                            [image performSelectorOnMainThread:@selector(setImage:) withObject:imageV waitUntilDone:YES];
                        }
                        else
                        {
                            CGSize newImageSize;
                            newImageSize.height = 200;
                            newImageSize.width = 200*imageV.size.width/imageV.size.height;
                            UIImage *imageS = [self scaleFromImage:imageV toSize:newImageSize];
                            CGRect imageRect = CGRectMake((newImageSize.width-200)/2, 0, 200, 200);
                            imageS = [self imageFromImage:imageS inRect:imageRect];
                            [image performSelectorOnMainThread:@selector(setImage:) withObject:imageS waitUntilDone:YES];
                        }
                    }
                    else if(imageV.size.width<=imageV.size.height)
                    {
                        if(imageV.size.width<=200)
                        {
                            CGRect imageRect = CGRectMake(0, (imageV.size.height-imageV.size.width)/2, imageV.size.width, imageV.size.width);
                            imageV = [self imageFromImage:imageV inRect:imageRect];
                            [image performSelectorOnMainThread:@selector(setImage:) withObject:imageV waitUntilDone:YES];
                        }
                        else
                        {
                            CGSize newImageSize;
                            newImageSize.width = 200;
                            newImageSize.height = 200*imageV.size.height/imageV.size.width;
                            UIImage *imageS = [self scaleFromImage:imageV toSize:newImageSize];
                            CGRect imageRect = CGRectMake(0, (newImageSize.height-200)/2, 200, 200);
                            imageS = [self imageFromImage:imageS inRect:imageRect];
                            [image performSelectorOnMainThread:@selector(setImage:) withObject:imageS waitUntilDone:YES];
                        }
                    }
                }
            });
            
            [cell.contentView addSubview:image];
            [imageArray addObject:image];
            
            SelectButton *button = [[SelectButton alloc] initWithFrame:rect];
            [button setTag:UIButtonTag+demo.f_id];
            [cellT setButtonTag:button.tag];
            [cellT setSectionTag:section];
            [cellT setPageTag:row*3+i];
            [cellArray addObject:cellT];
            [button setCell:cellT];
            
            [image release];
            [cellT release];
            [button addTarget:self action:@selector(clicked:) forControlEvents:UIControlEventTouchUpInside];
            if(editBL)
            {
                for(int i=0;i<[[_dicReuseCells allKeys] count];i++)
                {
                    int fid = [[_dicReuseCells objectForKey:[[_dicReuseCells allKeys] objectAtIndex:i]] intValue];
                    if(demo.f_id == fid)
                    {
                        [button setBackgroundImage:[UIImage imageNamed:@"interestSelected.png"] forState:UIControlStateNormal];
                    }
                }
            }
            [cell.contentView addSubview:button];
            [button release];
            
            NSLog(@"imageCount:%i",image.retainCount);
        }
        if([downCellArray count]>5)
        {
            [downCellArray removeObjectAtIndex:0];
        }
        [downCellArray addObject:cell];
        //        operation *queue = [[operation alloc] init];
        //        [queue cellArray:cellArray imagev:imageArray];
        //        [operationQueue addOperation:queue];
        //        [queue release];
        [cell setCellArray:cellArray];
        [cellArray release];
        [imageArray release];
    }
    NSLog(@"countdd:%i",cell.retainCount);
    return cell;
}

-(void)FirstLoad
{
    isLoadData = TRUE;
    isOnece = TRUE;
    [NSThread detachNewThreadSelector:@selector(getImageLoad) toTarget:self withObject:nil];
}

-(void)getImageNewLoad:(CellTag *)cellT imageView:(UIImageView *)image_v
{
    CellTag *cellTag = [cellT copy];
    UIImageView *image_view = [image_v retain];
    if([self image_exists_at_file_path:[NSString stringWithFormat:@"%i",cellTag.fileTag]])
    {
        NSObject *obj = [self.table_view viewWithTag:cellTag.imageTag];
        if(!obj)
        {
            isLoadData = FALSE;
            return;
        }
        NSString *path = [self get_image_save_file_path:[NSString stringWithFormat:@"%i",cellTag.fileTag]];
        UIImage *imageV = [UIImage imageWithContentsOfFile:path];
        CGSize newImageSize;
        if(isLoadImage && imageV.size.width>=imageV.size.height && imageV.size.height>200)
        {
            newImageSize.height = 200;
            newImageSize.width = 200*imageV.size.width/imageV.size.height;
            UIImage *imageS = [self scaleFromImage:imageV toSize:newImageSize];
            CGRect imageRect = CGRectMake((newImageSize.width-200)/2, 0, 200, 200);
            imageS = [self imageFromImage:imageS inRect:imageRect];
            if(!isLoadImage || !image_view || !imageS || ![image_view isKindOfClass:[UIImageView class]])
            {
                isLoadData = FALSE;
                return;
            }
            dispatch_async(dispatch_get_main_queue(), ^{
                [image_view setImage:imageS];
            });
        }
        else if(isLoadImage && imageV.size.width<=imageV.size.height && imageV.size.width>200)
        {
            newImageSize.width = 200;
            newImageSize.height = 200*imageV.size.height/imageV.size.width;
            UIImage *imageS = [self scaleFromImage:imageV toSize:newImageSize];
            CGRect imageRect = CGRectMake(0, (newImageSize.height-200)/2, 200, 200);
            imageS = [self imageFromImage:imageS inRect:imageRect];
            if(!isLoadImage || !image_view || !imageS || ![image_view isKindOfClass:[UIImageView class]])
            {
                isLoadData = FALSE;
                return;
            }
            dispatch_async(dispatch_get_main_queue(), ^{
                [image_view setImage:imageS];
            });
        }
        else if(isLoadImage)
        {
            dispatch_async(dispatch_get_main_queue(), ^{
                [image_view setImage:imageV];
            });
        }
        if(!editBL)
        {
            for(int i=0;isLoadImage && i<[[_dicReuseCells allKeys] count];i++)
            {
                int fid = [[_dicReuseCells objectForKey:[[_dicReuseCells allKeys] objectAtIndex:i]] intValue];
                if(cellTag.fileTag == fid)
                {
                    UIButton *button = (UIButton *)[self.table_view viewWithTag:cellTag.buttonTag];
                    [button setBackgroundImage:[UIImage imageNamed:@"111.png"] forState:UIControlStateNormal];
                    [button setSelected:NO];
                }
            }
        }
    }
    else if(isLoadImage)
    {
        DownImage *downImage = [[[DownImage alloc] init] autorelease];
        [downImage setFileId:cellTag.fileTag];
        [downImage setImageUrl:[NSString stringWithFormat:@"%i",cellTag.fileTag]];
        [downImage setImageViewIndex:cellTag.imageTag];
        dispatch_async(dispatch_get_main_queue(), ^{
            [downImage setDelegate:self];
            [downImage startDownload];
        });
    }
    [cellTag release];
    [image_view release];
}

-(void)getImageLoad
{
    dispatch_async(dispatch_get_main_queue(), ^{
        NSAutoreleasePool *pool = [[NSAutoreleasePool alloc] init];
        if(!self.downCellArray)
        {
            isLoadData = FALSE;
            return;
        }
        for(int i=0;isLoadData && isLoadImage && i<[self.downCellArray count];i++)
        {
            PhotoFileCell *cell = (PhotoFileCell *)[self.downCellArray objectAtIndex:i];
            NSArray *array = [cell cellArray];
            if(!array)
            {
                isLoadData = FALSE;
                return;
            }
            for(int j=0;isLoadData && isLoadImage && j<[array count];j++)
            {
                CellTag *cellTag = [array objectAtIndex:j];
                if(!cellTag)
                {
                    isLoadData = FALSE;
                    return;
                }
                if(![self image_exists_at_file_path:[NSString stringWithFormat:@"%i",cellTag.fileTag]])
                {
                    dispatch_async(dispatch_get_main_queue(), ^{
                        DownImage *downImage = [[[DownImage alloc] init] autorelease];
                        [downImage setFileId:cellTag.fileTag];
                        [downImage setImageUrl:[NSString stringWithFormat:@"%i",cellTag.fileTag]];
                        [downImage setImageViewIndex:cellTag.imageTag];
                        [downImage setDelegate:self];
                        [downImage startDownload];
                    });
                }
            }
        }
        //    dispatch_async(dispatch_get_main_queue(), ^{
        isLoadData = FALSE;
        [self.downCellArray removeAllObjects];
        //    });
        [pool release];
    });
}

- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView
{
    if(isPhoto)
    {
        isLoadImage = TRUE;
        if(!isLoadData && scrollView.contentOffset.y >= 0 && endFloat > scrollView.contentOffset.y && scrollView.contentOffset.y <= scrollView.contentSize.height)
        {
            isSort = TRUE;
            endFloat = scrollView.contentOffset.y;
            isLoadData = TRUE;
            NSLog(@"isLoadData11111:%i",isLoadData);
            [NSThread detachNewThreadSelector:@selector(getImageLoad) toTarget:self withObject:nil];
        }
        
        if(!isLoadData && scrollView.contentOffset.y >= 0 && endFloat < scrollView.contentOffset.y && scrollView.contentOffset.y <= scrollView.contentSize.height)
        {
            isSort = FALSE;
            endFloat = scrollView.contentOffset.y;
            isLoadData = TRUE;
            NSLog(@"isLoadData11111:%i",isLoadData);
            [NSThread detachNewThreadSelector:@selector(getImageLoad) toTarget:self withObject:nil];
        }
    }
}

-(void)scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate
{
    if(isPhoto)
    {
        isLoadImage = TRUE;
        if(!isLoadData && scrollView.contentOffset.y >= 0 && endFloat > scrollView.contentOffset.y && scrollView.contentOffset.y <= scrollView.contentSize.height)
        {
            isSort = TRUE;
            endFloat = scrollView.contentOffset.y;
            isLoadData = TRUE;
            NSLog(@"isLoadData222222:%i",isLoadData);
            [NSThread detachNewThreadSelector:@selector(getImageLoad) toTarget:self withObject:nil];
        }
        
        if(!isLoadData && scrollView.contentOffset.y >= 0 && endFloat < scrollView.contentOffset.y && scrollView.contentOffset.y <= scrollView.contentSize.height)
        {
            isSort = FALSE;
            endFloat = scrollView.contentOffset.y;
            isLoadData = TRUE;
            NSLog(@"isLoadData222222:%i",isLoadData);
            [NSThread detachNewThreadSelector:@selector(getImageLoad) toTarget:self withObject:nil];
        }
    }
}

-(void)scrollViewWillBeginDragging:(UIScrollView *)scrollView
{
    if(isPhoto)
    {
        isLoadImage = FALSE;
    }
}

-(void)scrollViewWillEndDragging:(UIScrollView *)scrollView withVelocity:(CGPoint)velocity targetContentOffset:(inout CGPoint *)targetContentOffset
{
    NSLog(@"-------------\n\nvelocity:%@\n\n--------------",NSStringFromCGPoint(velocity));
}

#pragma mark 按钮点击事件
-(void)clicked:(id)sender
{
    isLoadImage = FALSE;
    SelectButton *button = sender;
    int fid = button.tag-UIButtonTag;
    if(editBL)
    {
        
        if(button.selected)
        {
            [button setSelected:NO];
            [_dicReuseCells removeObjectForKey:[NSString stringWithFormat:@"%i",fid]];
            [button setBackgroundImage:[UIImage imageNamed:@"111.png"] forState:UIControlStateNormal];
        }
        else
        {
            [button setSelected:YES];
            [_dicReuseCells setObject:[NSNumber numberWithInt:fid] forKey:[NSString stringWithFormat:@"%i",fid]];
            [button setBackgroundImage:[UIImage imageNamed:@"interestSelected.png"] forState:UIControlStateNormal];
        }
    }
    else
    {
        PhotoLookViewController *photo_look_view = [[PhotoLookViewController alloc] init];
        [photo_look_view setHidesBottomBarWhenPushed:YES];
        //        [photo_look_view.navigationController setNavigationBarHidden:YES];
        NSString *sectionString = [sectionarray objectAtIndex:button.cell.sectionTag];
        NSArray *array = [tablediction objectForKey:sectionString];
        [photo_look_view setTableArray:[NSMutableArray arrayWithArray:[array retain]]];
        [array release];
        [photo_look_view setCurrPage:button.cell.pageTag];
        [self presentModalViewController:photo_look_view animated:YES];
        //        [self.navigationController pushViewController:photo_look_view animated:YES];
        [photo_look_view release];
        
    }
    NSLog(@"button:%i",button.tag);
}

#pragma mark 分享到朋友圈或会话
-(void)shareButton
{
    
}

#pragma mark UIActionSheetDelegate
-(void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if(buttonIndex == 1)
    {
        hud = [[MBProgressHUD alloc] initWithView:self.view];
        [self.view addSubview:hud];
        hud.mode=MBProgressHUDModeIndeterminate;
        hud.labelText=@"正在删除";
        [hud show:YES];
        [photoManager requestDeletePhoto:[_dicReuseCells allKeys]];
    }
}

#pragma mark 删除选中的数据
-(void)deleteButton
{
    NSLog(@"选中到了多少个：%i",[_dicReuseCells.allKeys count]);
    if([_dicReuseCells.allKeys count]>0)
    {
        UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"提示" message:@"是否要删除图片" delegate:self cancelButtonTitle:@"取消" otherButtonTitles:@"确定", nil];
        [alertView show];
        [alertView release];
    }
}

#pragma mark 删除成功后回调
-(void)requstDelete:(NSDictionary *)dictionary
{
    if([[dictionary objectForKey:@"code"] intValue] == 0)
    {
        NSArray *array = [_dicReuseCells allKeys];
        for(int k=0;k<[array count];k++)
        {
            int fid = [[_dicReuseCells objectForKey:[array objectAtIndex:k]] intValue];
            PhotoFile *photo = [[PhotoFile alloc] init];
            photo.f_id = fid;
            [photo deletePhotoFileTable];
            [photo release];
            for(int j=0;j<[sectionarray count];j++)
            {
                NSMutableArray *tableA = [tablediction objectForKey:[sectionarray objectAtIndex:j]];
                for(int i=0;i<[tableA count];)
                {
                    PhotoFile *demo = [tableA objectAtIndex:i];
                    if(demo.f_id == fid)
                    {
                        [tableA removeObjectAtIndex:i];
                    }
                    else
                    {
                        i++;
                    }
                }
                if([tableA count]==0)
                {
                    [sectionarray removeObjectAtIndex:j];
                }
            }
        }
        [_dicReuseCells removeAllObjects];
        [self.table_view reloadData];
        isLoadImage = TRUE;
        isSort = FALSE;
        UINavigationItem *nav_item = [self navigationItem];
        [nav_item setRightBarButtonItem:done_item];
        
        isLoadImage = TRUE;
        isSort = TRUE;
        isLoadData = TRUE;
        [NSThread detachNewThreadSelector:@selector(getImageLoad) toTarget:self withObject:nil];
        
        hud.labelText=@"删除成功";
        hud.mode=MBProgressHUDModeText;
        [hud hide:YES afterDelay:0.8f];
        [hud release];
        hud = nil;
    }
    else
    {
        hud.labelText=@"删除失败";
        hud.mode=MBProgressHUDModeText;
        [hud hide:YES afterDelay:0.8f];
        [hud release];
        hud = nil;
    }
}

-(void)viewWillAppear:(BOOL)animated
{
    [self.navigationController.navigationBar setBarStyle:UIBarStyleBlack];
    if(isPhoto)
    {
        [table_view reloadData];
        
        isLoadImage = TRUE;
        isSort = TRUE;
        isLoadData = TRUE;
        [NSTimer scheduledTimerWithTimeInterval:0.5 target:self selector:@selector(FirstLoad) userInfo:nil repeats:NO];
        
        if(!isReload)
        {
            isReload = TRUE;
            [NSThread detachNewThreadSelector:@selector(requestPhotoTimeLine) toTarget:self withObject:nil];
        }
        
        [self setUser_id:[[SCBSession sharedSession] userId]];
        [self setUser_token:[[SCBSession sharedSession] userToken]];
    }
}

-(void)requestPhotoTimeLine
{
    dispatch_async(dispatch_get_main_queue(), ^{
        if(photoManager)
        {
            [photoManager release];
            photoManager = nil;
        }
        hud = [[MBProgressHUD alloc] initWithView:self.view];
        hud.mode=MBProgressHUDModeIndeterminate;
        hud.labelText=@"正在加载";
        [self.view addSubview:hud];
        [hud show:YES];
        if(!isFirst)
        {
            [photoManager getPhotoTimeLine:TRUE];
            isFirst = TRUE;
        }
        else
        {
            [hud hide:YES afterDelay:0.8f];
            [hud release];
            hud = nil;
            [photoManager getPhotoTimeLine:NO];
        }
    });
}

//这个路径下是否存在此图片
- (BOOL)image_exists_at_file_path:(NSString *)image_path
{
    NSFileManager *file_manager = [NSFileManager defaultManager];
    NSString *documentDir = [YNFunctions getProviewCachePath];
    NSArray *array=[image_path componentsSeparatedByString:@"/"];
    NSString *path=[NSString stringWithFormat:@"%@/%@",documentDir,[array lastObject]];
    return [file_manager fileExistsAtPath:path];
}


//获取图片路径
- (NSString*)get_image_save_file_path:(NSString*)image_path
{
    NSString *documentDir = [YNFunctions getProviewCachePath];
    NSArray *array=[image_path componentsSeparatedByString:@"/"];
    NSString *path=[NSString stringWithFormat:@"%@/%@",documentDir,[array lastObject]];
    return path;
}

-(void)loadImageView:(UIImage *)image button:(PhotoImageButton *)image_button number:(int)number
{
    UIImage *image1 = (UIImage *)image;
    CGSize imageS = image1.size;
    if(imageS.width == imageS.height)
    {
        if(imageS.width>=75)
        {
            imageS.height = 75;
            imageS.width = 75;
            image = [self scaleFromImage:image toSize:imageS];
            CGRect imageRect = image_button.frame;
            imageRect.size.width = imageS.width;
            imageRect.size.height = imageS.height;
            imageRect.origin.x = (number-1)*79+4;
            imageRect.origin.y = 4;
            [image_button setFrame:imageRect];
            [image_button setBackgroundImage:image forState:UIControlStateNormal];
        }
        else
        {
            CGRect imageRect = image_button.frame;
            imageRect.size.width = imageS.width;
            imageRect.size.height = imageS.height;
            imageRect.origin.x = 79*(number-1)+4+(75-imageS.width)/2;
            imageRect.origin.y = 4+(75-imageS.height)/2;
            [image_button setFrame:imageRect];
            [image_button setBackgroundImage:image forState:UIControlStateNormal];
        }
    }
    else if(imageS.width < imageS.height)
    {
        if(imageS.width>=75)
        {
            imageS.height = 75*imageS.height/imageS.width;
            image = [self scaleFromImage:image toSize:CGSizeMake(75, imageS.height)];
            
            CGRect imageRect = image_button.frame;
            imageRect.size.width = 75;
            imageRect.size.height = 75;
            imageRect.origin.x = (number-1)*79+4;
            imageRect.origin.y = 4;
            [image_button setFrame:imageRect];
            
            UIImage *endImage = [self imageFromImage:image inRect:CGRectMake(0, (imageS.height-75)/2, 75, 75)];
            [image_button setBackgroundImage:endImage forState:UIControlStateNormal];
        }
        else if(imageS.height<75)
        {
            CGRect imageRect = image_button.frame;
            imageRect.size.width = imageS.width;
            imageRect.size.height = imageS.height;
            imageRect.origin.x = (number-1)*79+4+(75-imageS.width)/2;
            imageRect.origin.y = 4+(75-imageS.height)/2;
            [image_button setFrame:imageRect];
            [image_button setBackgroundImage:image forState:UIControlStateNormal];
        }
        else
        {
            UIImage *endImage = [self imageFromImage:image inRect:CGRectMake((75-imageS.width)/2, (imageS.height-75)/2, imageS.width, 75)];
            CGRect imageRect = image_button.frame;
            imageRect.size.width = imageS.width;
            imageRect.size.height = 75;
            imageRect.origin.x = (number-1)*79+4+(75-imageS.width)/2;
            imageRect.origin.y = 4;
            [image_button setFrame:imageRect];
            [image_button setBackgroundImage:endImage forState:UIControlStateNormal];
        }
    }
    else
    {
        if(imageS.height>=75)
        {
            imageS.width = 75*imageS.width/imageS.height;
            image = [self scaleFromImage:image toSize:CGSizeMake(imageS.width, 75)];
            UIImage *endImage = [self imageFromImage:image inRect:CGRectMake((imageS.width-75)/2, 0, 75, 75)];
            CGRect imageRect = image_button.frame;
            imageRect.size.width = 75;
            imageRect.size.height = 75;
            imageRect.origin.x = (number-1)*79+4;
            imageRect.origin.y = 4;
            [image_button setFrame:imageRect];
            [image_button setBackgroundImage:endImage forState:UIControlStateNormal];
        }
        else if(imageS.width<75)
        {
            CGRect imageRect = image_button.frame;
            imageRect.size.width = imageS.width;
            imageRect.size.height = imageS.height;
            imageRect.origin.x = (number-1)*79+4+(75-imageS.width)/2;
            imageRect.origin.y = 4+(75-imageS.height)/2;
            [image_button setFrame:imageRect];
            [image_button setBackgroundImage:image forState:UIControlStateNormal];
        }
        else
        {
            UIImage *endImage = [self imageFromImage:image inRect:CGRectMake((imageS.width-75)/2, (75-imageS.height)/2, 75, imageS.height)];
            CGRect imageRect = image_button.frame;
            imageRect.size.width = 75;
            imageRect.size.height = imageS.height;
            imageRect.origin.x = (number-1)*79+4;
            imageRect.origin.y = 4+(75-imageS.height)/2;
            [image_button setFrame:imageRect];
            [image_button setBackgroundImage:endImage forState:UIControlStateNormal];
        }
    }
}


-(UIImage *)imageFromImage:(UIImage *)image inRect:(CGRect)rect{
	CGImageRef sourceImageRef = [image CGImage];
	CGImageRef newImageRef = CGImageCreateWithImageInRect(sourceImageRef, rect);
	UIImage *newImage = [UIImage imageWithCGImage:newImageRef];
    CGImageRelease(newImageRef);
	return newImage;
}


-(UIImage *)scaleFromImage:(UIImage *)image toSize:(CGSize)size
{
    UIGraphicsBeginImageContext(size);
    [image drawInRect:CGRectMake(0, 0, size.width, size.height)];
    UIImage *newImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return newImage;
}

-(void)dealloc
{
    [photoManager release];
    [self.table_view release];
    [allDictionary release];
    [activity_indicator release];
    [user_token release];
    [user_id release];
    [allKeys release];
    [_dicReuseCells release];
    [_arrVisibleCells release];
    [bottonView release];
    [deleteItem release];
    [right_item release];
    [done_item release];
    [operationQueue release];
    [downCellArray release];
    [super dealloc];
}

@end

@implementation CellTag
@synthesize fileTag,imageTag,buttonTag,pageTag,sectionTag;

@end

@implementation SelectButton
@synthesize cell;
-(void)dealloc
{
    NSLog(@" cellTag 死了");
    [super dealloc];
}

@end

