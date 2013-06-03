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
#import "YNFunctions.h"
#import "PhotoFile.h"
#import "PhotoFileCell.h"

@interface PhotoViewController ()

@end

@implementation PhotoViewController
@synthesize photoManager,allDictionary;
@synthesize table_view;
@synthesize activity_indicator;
@synthesize user_id,user_token;
@synthesize _arrVisibleCells,_dicReuseCells,bottonView,allKeys;
@synthesize deleteItem,right_item;
@synthesize done_item;

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
    right_item = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemEdit target:self action:@selector(right_button_cilcked:)];
    [nav_item setRightBarButtonItem:right_item];
    //添加删除按钮
    deleteItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemTrash target:self action:@selector(deleteButton)];
    //添加完成按钮
    done_item = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemDone target:self action:@selector(right_button_cilcked:)];
    
    //初始化基本数据
    _dicReuseCells = [[NSMutableDictionary alloc] init];
    _arrVisibleCells = [[NSMutableArray alloc] init];
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
    downArray = [[NSMutableArray alloc] init];
    tablediction = [[NSMutableDictionary alloc] init];
    sectionarray = [[NSMutableArray alloc] init];
    CGRect rect = CGRectMake(0, 0, 320, self.view.frame.size.height-49-44);
    table_view = [[UITableView alloc] initWithFrame:rect];
    [table_view setSeparatorStyle:UITableViewCellSeparatorStyleNone];
    [table_view setDataSource:self];
    [table_view setDelegate:self];
    [self.view addSubview:table_view];
    
    hud = [[MBProgressHUD alloc] initWithView:self.view];
    hud.mode=MBProgressHUDModeIndeterminate;
    hud.labelText=@"正在加载";
    [self.view addSubview:hud];
    [hud show:NO];
    selfLenght = self.view.frame.size.height-49-44;
    endFloat = 10000;
    [super viewDidLoad];
	// Do any additional setup after loading the view.
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
        NSArray *cellArrays = [table_view indexPathsForVisibleRows];
        for(int i=0;i<[cellArrays count];i++)
        {
            PhotoFileCell *cell = (PhotoFileCell *)[table_view cellForRowAtIndexPath:[cellArrays objectAtIndex:i]];
            NSArray *array = [cell cellArray];
            for(int j=0;j<[array count];j++)
            {
                CellTag *cellTag = [array objectAtIndex:j];
                for(int k=0;k<[[_dicReuseCells allKeys] count];k++)
                {
                    int fid = [[_dicReuseCells objectForKey:[[_dicReuseCells allKeys] objectAtIndex:k]] intValue];
                    if(cellTag.fileTag == fid)
                    {
                        UIButton *button = (UIButton *)[table_view viewWithTag:cellTag.buttonTag];
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

#pragma mark -得到时间轴的列表
-(void)getPhotoTiimeLine:(NSDictionary *)dictionary
{
    [hud show:YES];
    [table_view clearsContextBeforeDrawing];
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
    
    [table_view reloadData];
    [self scrollViewDidEndDecelerating:nil];
    
    [hud hide:YES afterDelay:0.5f];

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

-(void)getPhotoDetail:(NSDictionary *)dictionary
{
    
}



-(void)getAllDown
{
    NSAutoreleasePool *pool = [[NSAutoreleasePool alloc] init];
    NSArray *allArray = [photo_diction allKeys];
    int allcount = [allArray count];
    for(int i=0;i<allcount;i++)
    {
        PhohoDemo *demo = [photo_diction objectForKey:[allArray objectAtIndex:i]];
        DownImage *downImage = [[[DownImage alloc] init] autorelease];
        [downImage setFileId:demo.f_id];
        [downImage setImageUrl:demo.f_name];
        [downImage setImageViewIndex:demo.f_id];
        NSString *path = [self get_image_save_file_path:demo.f_name];
        if(![self image_exists_at_file_path:path])
        {
            [downArray addObject:downImage];
        }
        
    }
    [pool release];
    [self downImage];
}

-(void)downImage
{
    if(downNumber<[downArray count])
    {
        DownImage *downImage = [downArray objectAtIndex:downNumber];
        [downImage setDelegate:self];
        [downImage startDownload];
    }
}


#pragma mark 进入详细页面
-(void)image_button_click:(id)sender
{
    PhotoImageButton *image_button = sender;
    if(editBL)
    {
        PhohoDemo *demo = [photo_diction objectForKey:[NSString stringWithFormat:@"%i",image_button.tag]];
        if(demo.isSelected)
        {
            [demo setIsSelected:NO];
            [image_button.bgImageView setHidden:YES];
            [_dicReuseCells removeObjectForKey:[NSString stringWithFormat:@"%i",image_button.tag]];
        }
        else
        {
            [demo setIsSelected:YES];
            [image_button.bgImageView setHidden:NO];
            [_dicReuseCells setObject:demo forKey:[NSString stringWithFormat:@"%i",image_button.tag]];
        }
    }
    else
    {
        NSArray *array = [allDictionary objectForKey:image_button.timeLine];
        PhotoDetailViewController *photoDetalViewController = [[PhotoDetailViewController alloc] init];
        photoDetalViewController.deleteDelegate = self;
        [self presentViewController:photoDetalViewController animated:YES completion:^{
            [photoDetalViewController setPhoto_dictionary:photo_diction];
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

-(void)appImageDidLoad:(NSInteger)indexTag urlImage:(UIImage *)image index:(int)index
{
//    downNumber++;
    if(isLoadData)
    {
        __block NSArray *array = [table_view indexPathsForVisibleRows];
        for(int i=0;i<[array count];i++)
        {
            NSLog(@"cellForRowAtIndexPath:%i",i);
            PhotoFileCell *cell = (PhotoFileCell *)[table_view cellForRowAtIndexPath:[array objectAtIndex:i]];
            for(int j=0;j>[cell.cellArray count];j++)
            {
                CellTag *cT = [cell.cellArray objectAtIndex:j];
                if(cT.imageTag == indexTag)
                {
                    NSObject *obj = [table_view viewWithTag:cT.imageTag];
                    if(!obj)
                    {
                        return;
                    }
                    UIImageView *image_view = (UIImageView *)obj;
                    NSString *path = [self get_image_save_file_path:[NSString stringWithFormat:@"%i",cT.fileTag]];
                    UIImage *imageV = [UIImage imageWithContentsOfFile:path];
                    CGSize newImageSize;
                    if(imageV.size.width>=imageV.size.height && imageV.size.height>200)
                    {
                        newImageSize.height = 200;
                        newImageSize.width = 200*imageV.size.width/imageV.size.height;
                        UIImage *imageS = [self scaleFromImage:imageV toSize:newImageSize];
                        CGRect imageRect = CGRectMake((newImageSize.width-200)/2, 0, 200, 200);
                        imageS = [self imageFromImage:imageS inRect:imageRect];
                        if([image_view isKindOfClass:[UIImageView class]])
                        {
                            [image_view setImage:imageS];
                        }
                    }
                    else if(imageV.size.width<=imageV.size.height && imageV.size.width>200)
                    {
                        newImageSize.width = 200;
                        newImageSize.height = 200*imageV.size.height/imageV.size.width;
                        UIImage *imageS = [self scaleFromImage:imageV toSize:newImageSize];
                        CGRect imageRect = CGRectMake(0, (newImageSize.height-200)/2, 200, 200);
                        imageS = [self imageFromImage:imageS inRect:imageRect];
                        [image_view setImage:imageS];
                    }
                    else
                    {
                        [image_view setImage:imageV];
                    }
                    if(!editBL)
                    {
                        for(int i=0;i<[[_dicReuseCells allKeys] count];i++)
                        {
                            int fid = [[_dicReuseCells objectForKey:[[_dicReuseCells allKeys] objectAtIndex:i]] intValue];
                            if(cT.fileTag == fid)
                            {
                                UIButton *button = (UIButton *)[table_view viewWithTag:cT.buttonTag];
                                [button setBackgroundImage:[UIImage imageNamed:@"111.png"] forState:UIControlStateNormal];
                                [button setSelected:NO];
                            }
                        }
                    }
                    return;
                }
            }
        }
    }
//    [self downLoad];
}

#pragma mark UITableViewDelegate
-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return [sectionarray count];
}

-(NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{
    return [sectionarray objectAtIndex:section];
}

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
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

-(float)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    return 20;
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
    NSString *cellString = @"cellString";
    PhotoFileCell *cell = [table_view dequeueReusableHeaderFooterViewWithIdentifier:cellString];
    if(!cell)
    {
        cell = [[[PhotoFileCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellString] autorelease];
        [cell setSelectionStyle:UITableViewCellSelectionStyleNone];
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
        for(int i=0;i<number;i++)
        {
            CellTag *cellT = [[CellTag alloc] init];
            PhotoFile *demo = [array objectAtIndex:row*3+i];
            [cellT setFileTag:demo.f_id];
            CGRect rect = CGRectMake(i*105+5, 5, 100, 100);
            UIImageView *image = [[UIImageView alloc] initWithFrame:rect];
            image.tag = UIImageTag+demo.f_id;
            [cellT setImageTag:image.tag];
            UIImage *imageV = [UIImage imageNamed:@"icon_Load.png"];
            [image setImage:imageV];
            [cell.contentView addSubview:image];
            [image release];
            SelectButton *button = [[SelectButton alloc] initWithFrame:rect];
            [button setTag:UIButtonTag+demo.f_id];
            [cellT setButtonTag:button.tag];
            [cellT setSectionTag:section];
            [cellT setPageTag:row*3+i];
            [cellArray addObject:cellT];
            [button setCell:cellT];
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
        }
        [cell setCellArray:cellArray];
        [cellArray release];
    }
    else
    {
        cell.tag = row+UICellTag*section;
        NSMutableArray *cellArray = [[NSMutableArray alloc] init];
        for(int i=0;i<3;i++)
        {
            CellTag *cellT = [[CellTag alloc] init];
            PhotoFile *demo = [array objectAtIndex:row*3+i];
            [cellT setFileTag:demo.f_id];
            CGRect rect = CGRectMake(i*105+5, 5, 100, 100);
            UIImageView *image = [[UIImageView alloc] initWithFrame:rect];
            image.tag = UIImageTag+demo.f_id;
            [cellT setImageTag:image.tag];
            UIImage *imageV = [UIImage imageNamed:@"icon_Load.png"];
            [image setImage:imageV];
            [cell.contentView addSubview:image];
            [image release];
            SelectButton *button = [[SelectButton alloc] initWithFrame:rect];
            [button setTag:UIButtonTag+demo.f_id];
            [cellT setButtonTag:button.tag];
            [cellT setSectionTag:section];
            [cellT setPageTag:row*3+i];
            [cellArray addObject:cellT];
            [button setCell:cellT];
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
        }
        [cell setCellArray:cellArray];
        [cellArray release];
    }
    return cell;
}

-(void)getImageLoad
{
    NSAutoreleasePool *pool = [[NSAutoreleasePool alloc] init];
    if(!isLoadData)
    {
        isLoadData = TRUE;
        NSArray *cellArrays = [table_view visibleCells];
        if(!cellArrays)
        {
            return;
        }
        for(int i=0;i<[cellArrays count];i++)
        {
            PhotoFileCell *cell = (PhotoFileCell *)[cellArrays objectAtIndex:i];
            NSArray *array = [cell cellArray];
            if(!array)
            {
                return;
            }
            for(int j=0;j<[array count];j++)
            {
                CellTag *cellTag = [array objectAtIndex:j];
                if(!cellTag)
                {
                    return;
                }
                if([self image_exists_at_file_path:[NSString stringWithFormat:@"%i",cellTag.fileTag]])
                {
                    NSObject *obj = [table_view viewWithTag:cellTag.imageTag];
                    if(!obj)
                    {
                        return;
                    }
                    UIImageView *image_view = (UIImageView *)obj;
                    NSString *path = [self get_image_save_file_path:[NSString stringWithFormat:@"%i",cellTag.fileTag]];
                    UIImage *imageV = [UIImage imageWithContentsOfFile:path];
                    CGSize newImageSize;
                    if(imageV.size.width>=imageV.size.height && imageV.size.height>200)
                    {
                        newImageSize.height = 200;
                        newImageSize.width = 200*imageV.size.width/imageV.size.height;
                        UIImage *imageS = [self scaleFromImage:imageV toSize:newImageSize];
                        CGRect imageRect = CGRectMake((newImageSize.width-200)/2, 0, 200, 200);
                        imageS = [self imageFromImage:imageS inRect:imageRect];
                        if(!image_view || !imageS)
                        {
                            return;
                        }
                        [image_view setImage:imageS];
                    }
                    else if(imageV.size.width<=imageV.size.height && imageV.size.width>200)
                    {
                        newImageSize.width = 200;
                        newImageSize.height = 200*imageV.size.height/imageV.size.width;
                        UIImage *imageS = [self scaleFromImage:imageV toSize:newImageSize];
                        CGRect imageRect = CGRectMake(0, (newImageSize.height-200)/2, 200, 200);
                        imageS = [self imageFromImage:imageS inRect:imageRect];
                        if(!image_view || imageS)
                        {
                            return;
                        }
                        [image_view setImage:imageS];
                    }
                    else
                    {
                        [image_view setImage:imageV];
                    }
                    if(!editBL)
                    {
                        for(int i=0;i<[[_dicReuseCells allKeys] count];i++)
                        {
                            int fid = [[_dicReuseCells objectForKey:[[_dicReuseCells allKeys] objectAtIndex:i]] intValue];
                            if(cellTag.fileTag == fid)
                            {
                                UIButton *button = (UIButton *)[table_view viewWithTag:cellTag.buttonTag];
                                [button setBackgroundImage:[UIImage imageNamed:@"111.png"] forState:UIControlStateNormal];
                                [button setSelected:NO];
                            }
                        }
                    }
                }
                else
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
        isLoadData = FALSE;
    }
    [pool drain];
}

#pragma mark 滑动结束后，加载数据
//- (void)scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate
//{
//    if(!isLoadData)
//    {
//        isLoadImage = TRUE;
//        NSArray *cellArrays = [table_view indexPathsForVisibleRows];
//        for(int i=0;i<[cellArrays count];i++)
//        {
//            PhotoFileCell *cell = (PhotoFileCell *)[table_view cellForRowAtIndexPath:[cellArrays objectAtIndex:i]];
//            [NSThread detachNewThreadSelector:@selector(getImageLoad:) toTarget:self withObject:cell];
//            NSArray *array = [cell cellArray];
//            for(int j=0;j<[array count];j++)
//            {
//                CellTag *cellTag = [array objectAtIndex:j];
//                if(![self image_exists_at_file_path:[NSString stringWithFormat:@"%i",cellTag.fileTag]])
//                {
//                    DownImage *downImage = [[[DownImage alloc] init] autorelease];
//                    [downImage setFileId:cellTag.fileTag];
//                    [downImage setImageUrl:[NSString stringWithFormat:@"%i",cellTag.fileTag]];
//                    [downImage setImageViewIndex:cellTag.imageTag];
//                    [downImage setDelegate:self];
//                    [downImage startDownload];
//                }
//            }
//        }
//    }
//}

- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView
{
    NSLog(@"scrollViewDidEndDecelerating:%f",scrollView.contentOffset.y);
    if((endFloat >= 0 && endFloat > scrollView.contentOffset.y && endFloat - scrollView.contentOffset.y > 100) || (endFloat >= 0 && endFloat < scrollView.contentOffset.y && scrollView.contentOffset.y - endFloat > 100) )
    {
        endFloat = scrollView.contentOffset.y;
        [NSThread detachNewThreadSelector:@selector(getImageLoad) toTarget:self withObject:nil];
    }
    
//    [self downLoad];
}

-(void)downLoad
{
    if(downNumber<[downArray count] && isLoadData)
    {
        DownImage *downImage = [downArray objectAtIndex:downNumber];
        [downImage setDelegate:self];
        [downImage startDownload];
    }
}

-(void)scrollViewDidScroll:(UIScrollView *)scrollView
{
//    isLoadData = FALSE;
    
}

#pragma mark 按钮点击事件
-(void)clicked:(id)sender
{
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
        PhotoDetailViewController *photoDetalViewController = [[PhotoDetailViewController alloc] init];
        photoDetalViewController.deleteDelegate = self;
        [self presentViewController:photoDetalViewController animated:YES completion:^{
            NSString *sectionString = [sectionarray objectAtIndex:button.cell.sectionTag];
            [photoDetalViewController loadAllDiction:[tablediction objectForKey:sectionString] currtimeIdexTag:button.cell.pageTag];
        }];
        [photoDetalViewController release];
    }
    NSLog(@"button:%i",button.tag);
}

#pragma mark 分享到朋友圈或会话
-(void)shareButton
{
    NSLog(@"选中到了多少个：%i",[_dicReuseCells.allKeys count]);
    if([_dicReuseCells.allKeys count]>0)
    {
        UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"提示" message:@"是否要删除图片" delegate:self cancelButtonTitle:@"取消" otherButtonTitles:@"确认", nil];
        [alertView show];
        [alertView release];
    }
}

#pragma mark UIActionSheetDelegate
-(void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    NSLog(@"buttonIndex:%i",buttonIndex);
    if(buttonIndex == 1)
    {
        [photoManager setPhotoDelegate:self];
        [photoManager requestDeletePhoto:[_dicReuseCells allKeys]];
    }
    
//    AppDelegate *app_delegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
//    if(buttonIndex == 0)
//    {
//        //分享到朋友圈
//        [app_delegate sendImageContentIsFiends:YES];
//    }
//    if(buttonIndex == 1)
//    {
//        //分享到微信好友
//        [app_delegate sendImageContentIsFiends:NO];
//    }
//    if(buttonIndex == 2)
//    {
//        //分享到新浪微博
//    }
}

#pragma mark 删除选中的数据
-(void)deleteButton
{
    NSLog(@"选中到了多少个：%i",[_dicReuseCells.allKeys count]);
    if([_dicReuseCells.allKeys count]>0)
    {
        UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"提示" message:@"是否要删除图片" delegate:self cancelButtonTitle:@"取消" otherButtonTitles:@"确认", nil];
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
        [table_view reloadData];
        [self scrollViewDidEndDecelerating:nil];
        UINavigationItem *nav_item = [self navigationItem];
        [nav_item setRightBarButtonItem:done_item];
    }
}

-(void)viewWillAppear:(BOOL)animated
{
    [hud show:YES];
//    if(![[[SCBSession sharedSession] userId] isEqualToString:user_id] && ![[[SCBSession sharedSession] userToken] isEqualToString:user_token])
    if(photoManager)
    {
        [photoManager release];
        photoManager = nil;
    }
    //请求时间轴
    photoManager = [[SCBPhotoManager alloc] init];
    [photoManager setPhotoDelegate:self];
    if(!isFirst)
    {
        [photoManager getPhotoTimeLine:TRUE];
        isFirst = TRUE;
    }
    else
    {
        [photoManager getPhotoTimeLine:NO];
    }
    [self setUser_id:[[SCBSession sharedSession] userId]];
    [self setUser_token:[[SCBSession sharedSession] userToken]];
    [hud hide:YES afterDelay:0.5f];
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
    [table_view release];
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
    [cell release];
    [super dealloc];
}

@end

