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
@synthesize _arrVisibleCells,_dicReuseCells,bottonView,allKeys;

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
    for(int i=0;i<[[_dicReuseCells allKeys] count];i++)
    {
        PhotoImageButton *imageButton = (PhotoImageButton *)[scroll_view viewWithTag:[[[_dicReuseCells allKeys] objectAtIndex:i] intValue]];
        [imageButton.bgImageView setHidden:YES];
    }
    [_dicReuseCells removeAllObjects];
    if(editBL)
    {
        editBL = FALSE;
        AppDelegate *app_delegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
        [app_delegate.myTabBarController setHidesTabBarWithAnimate:NO];
        if(bottonView)
        {
            CATransition *animation = [CATransition animation];
            animation.duration = 0.35f;
            animation.timingFunction = UIViewAnimationCurveEaseInOut;
            animation.fillMode = kCAFillModeForwards;
            animation.type = kCATransitionPush;
            animation.subtype = kCATransitionFromBottom;
            
            CGRect frame = [bottonView frame];
            frame.origin.y = self.view.frame.size.height;
            [bottonView setFrame:frame];
            [bottonView.layer removeAllAnimations];
            [bottonView.layer addAnimation:animation forKey:@"animated"];
        }
    }
    else
    {
        if(!bottonView)
        {
            //底部试图
            CGRect bottonRect = CGRectMake(0, self.view.frame.size.height-49, 320, 49);
            bottonView = [[UIView alloc] initWithFrame:bottonRect];
            bottonRect.origin.y = 0;
            UIImageView *bottonImage = [[UIImageView alloc] initWithFrame:bottonRect];
            [bottonImage setImage:[UIImage imageNamed:@"tab_bg.png"]];
            [bottonView addSubview:bottonImage];
            //删除按钮
            CGRect deleteRect = CGRectMake(0, 0, 320, 50);
            UIButton *deleteButton = [[UIButton alloc] initWithFrame:deleteRect];
            [deleteButton setTitle:@"删除" forState:UIControlStateNormal];
            [deleteButton addTarget:self action:@selector(deleteButton) forControlEvents:UIControlEventTouchUpInside];
            [deleteButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
            [bottonView addSubview:deleteButton];
            [self.view addSubview:bottonView];
        }
        CATransition *animation = [CATransition animation];
        animation.duration = 0.35f;
        animation.timingFunction = UIViewAnimationCurveEaseInOut;
        animation.fillMode = kCAFillModeForwards;
        animation.type = kCATransitionPush;
        animation.subtype = kCATransitionFromTop;
        CGRect frame = [bottonView frame];
        frame.origin.y = self.view.frame.size.height-49;
        [bottonView setFrame:frame];
        [bottonView.layer removeAllAnimations];
        [bottonView.layer addAnimation:animation forKey:@"animated"];
        editBL = YES;
        AppDelegate *app_delegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
        [app_delegate.myTabBarController setHidesTabBarWithAnimate:YES];
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
    scroll_view = [[UIScrollView alloc] initWithFrame:CGRectMake(0, 0, 320, self.view.frame.size.height-49)];
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
            [imageButton addTarget:self action:@selector(image_button_click:) forControlEvents:UIControlEventTouchUpInside];
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
}

-(void)firstLoad
{
    [self scrollViewDidEndDragging:nil willDecelerate:YES];
}

-(void)getPhotoDetail:(NSDictionary *)dictionary
{
    
}

#pragma mark 滑动结束后，加载数据
- (void)scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate
{
    NSLog(@"太快了吧");
    dispatch_async(dispatch_get_main_queue(), ^{
        [self getAllDown];
    });
//    int number = [scrollView contentOffset].y/80*4;
//    NSArray *allArray = [photo_diction allKeys];
//    int allcount = [allArray count];
//    if(number>allcount&&allcount>10)
//    {
//        for(int i=allcount-1;i>=allcount-10;i--)
//        {
//            PhohoDemo *demo = [photo_diction objectForKey:[allArray objectAtIndex:i]];
//            DownImage *downImage = [[[DownImage alloc] init] autorelease];
//            [downImage setFileId:demo.f_id];
//            [downImage setImageUrl:demo.f_name];
//            [downImage setImageViewIndex:demo.f_id];
//            [downImage setDelegate:self];
//            [downImage startDownload];
//        }
//    }
//    else if(number<allcount&&number+10<allcount)
//    {
//        for(int i=number;i<number+10;i++)
//        {
//            PhohoDemo *demo = [photo_diction objectForKey:[allArray objectAtIndex:i]];
//            DownImage *downImage = [[[DownImage alloc] init] autorelease];
//            [downImage setFileId:demo.f_id];
//            [downImage setImageUrl:demo.f_name];
//            [downImage setImageViewIndex:demo.f_id];
//            [downImage setDelegate:self];
//            [downImage startDownload];
//        }
//    }
//    else if(number<allcount&&number+10>allcount)
//    {
//        for(int i=number;i<allcount;i++)
//        {
//            PhohoDemo *demo = [photo_diction objectForKey:[allArray objectAtIndex:i]];
//            DownImage *downImage = [[[DownImage alloc] init] autorelease];
//            [downImage setFileId:demo.f_id];
//            [downImage setImageUrl:demo.f_name];
//            [downImage setImageViewIndex:demo.f_id];
//            [downImage setDelegate:self];
//            [downImage startDownload];
//        }
//    }  
//    NSLog(@"结束");
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
    downNumber++;
    PhotoImageButton *image_button = (PhotoImageButton *)[scroll_view viewWithTag:indexTag];
    [image_button setBackgroundImage:image forState:UIControlStateNormal];
    [self downImage];
//    [self loadImageView:image button:imagebutton number:index];
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
    NSString *cellString = [NSString stringWithFormat:@"allHeight:%i %i",section,row];
    PhotoCell *photoCell = [tableView dequeueReusableCellWithIdentifier:cellString];
    if(!photoCell)
    {
        photoCell = [[[PhotoCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellString] autorelease];
        [photoCell setSelectionStyle:UITableViewCellSelectionStyleNone];
        [photoCell.imageViewButton1 addTarget:self action:@selector(image_button_click:) forControlEvents:UIControlEventTouchUpInside];
        [photoCell.imageViewButton2 addTarget:self action:@selector(image_button_click:) forControlEvents:UIControlEventTouchUpInside];
        [photoCell.imageViewButton3 addTarget:self action:@selector(image_button_click:) forControlEvents:UIControlEventTouchUpInside];
        [photoCell.imageViewButton4 addTarget:self action:@selector(image_button_click:) forControlEvents:UIControlEventTouchUpInside];
        
        UIImage *imageDemo = [UIImage imageNamed:@"icon_Load.png"];
        [photoCell.bg1 setImage:imageDemo];
        [photoCell.bg2 setImage:imageDemo];
        [photoCell.bg3 setImage:imageDemo];
        [photoCell.bg4 setImage:imageDemo];
        
        [photoCell.imageViewButton2.layer setBorderWidth:0];
        [photoCell.imageViewButton3.layer setBorderWidth:0];
        [photoCell.imageViewButton4.layer setBorderWidth:0];
    }
    [photoCell.imageViewButton1 setHidden:NO];
    [photoCell.bg1 setHidden:NO];
    [photoCell.imageViewButton2 setHidden:NO];
    [photoCell.bg2 setHidden:NO];
    [photoCell.imageViewButton3 setHidden:NO];
    [photoCell.bg3 setHidden:NO];
    [photoCell.imageViewButton4 setHidden:NO];
    [photoCell.bg4 setHidden:NO];
    [photoCell setIsSelected:editBL];
    if([array count]/4>=row+1)
    {
        PhohoDemo *demo = [photo_diction objectForKey:[array objectAtIndex:row*4]];
        [photoCell.imageViewButton1 setDemo:demo];
        [photoCell.imageViewButton1 setTag:demo.f_id];
        [photoCell.imageViewButton1 setTimeLine:timeLine];
        [photoCell.imageViewButton1 setTimeIndex:row*4];
        NSString *path = [photoCell get_image_save_file_path:demo.f_name];
        UIImage *imageDemo = [UIImage imageNamed:@"icon_Load.png"];
        [photoCell.bg1 setImage:imageDemo];
        if([photoCell image_exists_at_file_path:path])
        {
            imageDemo = [UIImage imageWithContentsOfFile:path];
            [photoCell loadImageView:imageDemo button:photoCell.bg1 number:1];
        }
        if(editBL && demo.isSelected)
        {
            [photoCell.imageViewButton1 setBackgroundImage:[UIImage imageNamed:@"interestSelected.png"] forState:UIControlStateNormal];
        }
        else
        {
            [photoCell.imageViewButton1 setBackgroundImage:imageDemo forState:UIControlStateNormal];
            [demo setIsSelected:NO];
        }
        
        demo = [photo_diction objectForKey:[array objectAtIndex:row*4+1]];
        [photoCell.imageViewButton2 setDemo:demo];
        [photoCell.imageViewButton2 setTag:demo.f_id];
        [photoCell.imageViewButton2 setTimeLine:timeLine];
        [photoCell.imageViewButton2 setTimeIndex:row*4+1];
        path = [photoCell get_image_save_file_path:demo.f_name];
        imageDemo = [UIImage imageNamed:@"icon_Load.png"];
        [photoCell.bg2 setImage:imageDemo];
        if([photoCell image_exists_at_file_path:path])
        {
            imageDemo = [UIImage imageWithContentsOfFile:path];
            [photoCell loadImageView:imageDemo button:photoCell.bg2 number:1];
        }
        if(editBL && demo.isSelected)
        {
            [photoCell.imageViewButton2 setBackgroundImage:[UIImage imageNamed:@"interestSelected.png"] forState:UIControlStateNormal];
        }
        else
        {
            [photoCell.imageViewButton2 setBackgroundImage:imageDemo forState:UIControlStateNormal];
            [demo setIsSelected:NO];
        }
        
        demo = [photo_diction objectForKey:[array objectAtIndex:row*4+2]];
        [photoCell.imageViewButton3 setDemo:demo];
        [photoCell.imageViewButton3 setTag:demo.f_id];
        [photoCell.imageViewButton3 setTimeLine:timeLine];
        [photoCell.imageViewButton3 setTimeIndex:row*4+2];
        path = [photoCell get_image_save_file_path:demo.f_name];
        imageDemo = [UIImage imageNamed:@"icon_Load.png"];
        [photoCell.bg3 setImage:imageDemo];
        if([photoCell image_exists_at_file_path:path])
        {
            imageDemo = [UIImage imageWithContentsOfFile:path];
            [photoCell loadImageView:imageDemo button:photoCell.bg3 number:1];
        }
        if(editBL && demo.isSelected)
        {
            [photoCell.imageViewButton3 setBackgroundImage:[UIImage imageNamed:@"interestSelected.png"] forState:UIControlStateNormal];
        }
        else
        {
            [photoCell.imageViewButton3 setBackgroundImage:imageDemo forState:UIControlStateNormal];
            [demo setIsSelected:NO];
        }
        
        demo = [photo_diction objectForKey:[array objectAtIndex:row*4+3]];
        [photoCell.imageViewButton4 setDemo:demo];
        [photoCell.imageViewButton4 setTag:demo.f_id];
        [photoCell.imageViewButton4 setTimeLine:timeLine];
        [photoCell.imageViewButton4 setTimeIndex:row*4+3];
        path = [photoCell get_image_save_file_path:demo.f_name];
        imageDemo = [UIImage imageNamed:@"icon_Load.png"];
        [photoCell.bg4 setImage:imageDemo];
        if([photoCell image_exists_at_file_path:path])
        {
            imageDemo = [UIImage imageWithContentsOfFile:path];
            [photoCell loadImageView:imageDemo button:photoCell.bg4 number:1];
        }
        if(editBL && demo.isSelected)
        {
            [photoCell.imageViewButton4 setBackgroundImage:[UIImage imageNamed:@"interestSelected.png"] forState:UIControlStateNormal];
        }
        else
        {
            [photoCell.imageViewButton4 setBackgroundImage:imageDemo forState:UIControlStateNormal];
            [demo setIsSelected:NO];
        }
    }
    else
    {
        int number = [array count]%4;
        PhohoDemo *demo = [photo_diction objectForKey:[array objectAtIndex:row*4]];
        [photoCell.imageViewButton1 setDemo:demo];
        [photoCell.imageViewButton1 setTag:demo.f_id];
        [photoCell.imageViewButton1 setTimeLine:timeLine];
        [photoCell.imageViewButton1 setTimeIndex:row*4];
        NSString *path = [photoCell get_image_save_file_path:demo.f_name];
        UIImage *imageDemo = [UIImage imageNamed:@"icon_Load.png"];
        [photoCell.bg1 setImage:imageDemo];
        if([photoCell image_exists_at_file_path:path])
        {
            imageDemo = [UIImage imageWithContentsOfFile:path];
            [photoCell loadImageView:imageDemo button:photoCell.bg1 number:1];
        }
        if(editBL && demo.isSelected)
        {
            [photoCell.imageViewButton1 setBackgroundImage:[UIImage imageNamed:@"interestSelected.png"] forState:UIControlStateNormal];
        }
        else
        {
            [photoCell.imageViewButton1 setBackgroundImage:imageDemo forState:UIControlStateNormal];
            [demo setIsSelected:NO];
        }
        
        if(number == 1)
        {
            [photoCell.imageViewButton2 setHidden:YES];
            [photoCell.bg2 setHidden:YES];
            [photoCell.imageViewButton3 setHidden:YES];
            [photoCell.bg3 setHidden:YES];
            [photoCell.imageViewButton4 setHidden:YES];
            [photoCell.bg4 setHidden:YES];
            return photoCell;
        }
        demo = [photo_diction objectForKey:[array objectAtIndex:row*4+1]];
        [photoCell.imageViewButton2 setDemo:demo];
        [photoCell.imageViewButton2 setTag:demo.f_id];
        [photoCell.imageViewButton2 setTimeLine:timeLine];
        [photoCell.imageViewButton2 setTimeIndex:row*4+1];
        path = [photoCell get_image_save_file_path:demo.f_name];
        imageDemo = [UIImage imageNamed:@"icon_Load.png"];
        [photoCell.bg2 setImage:imageDemo];
        if([photoCell image_exists_at_file_path:path])
        {
            imageDemo = [UIImage imageWithContentsOfFile:path];
            [photoCell loadImageView:imageDemo button:photoCell.bg2 number:1];
        }
        if(editBL && demo.isSelected)
        {
            [photoCell.imageViewButton2 setBackgroundImage:[UIImage imageNamed:@"interestSelected.png"] forState:UIControlStateNormal];
        }
        else
        {
            [photoCell.imageViewButton2 setBackgroundImage:imageDemo forState:UIControlStateNormal];
            [demo setIsSelected:NO];
        }
        
        if(number==2)
        {
            [photoCell.imageViewButton3 setHidden:YES];
            [photoCell.bg3 setHidden:YES];
            [photoCell.imageViewButton4 setHidden:YES];
            [photoCell.bg4 setHidden:YES];
            return photoCell;
        }
        demo = [photo_diction objectForKey:[array objectAtIndex:row*4+2]];
        [photoCell.imageViewButton3 setDemo:demo];
        [photoCell.imageViewButton3 setTag:demo.f_id];
        [photoCell.imageViewButton3 setTimeLine:timeLine];
        [photoCell.imageViewButton3 setTimeIndex:row*4+2];
        path = [photoCell get_image_save_file_path:demo.f_name];
        imageDemo = [UIImage imageNamed:@"icon_Load.png"];
        [photoCell.bg3 setImage:imageDemo];
        if([photoCell image_exists_at_file_path:path])
        {
            imageDemo = [UIImage imageWithContentsOfFile:path];
            [photoCell loadImageView:imageDemo button:photoCell.bg3 number:1];
        }
        if(editBL && demo.isSelected)
        {
            [photoCell.imageViewButton3 setBackgroundImage:[UIImage imageNamed:@"interestSelected.png"] forState:UIControlStateNormal];
        }
        else
        {
            [photoCell.imageViewButton3 setBackgroundImage:imageDemo forState:UIControlStateNormal];
            [demo setIsSelected:NO];
        }
        
        if(number==3)
        {
            [photoCell.imageViewButton4 setHidden:YES];
            [photoCell.bg4 setHidden:YES];
            return photoCell;
        }
//        
//        [photoCell array:array index:row*4 timeLine:timeLine nunber:number];
    }
    return photoCell;
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
            PhohoDemo *demo = [_dicReuseCells objectForKey:[array objectAtIndex:k]];
            NSMutableArray *tableArray = [allDictionary objectForKey:demo.timeLine];
            for(int j=0;j<[tableArray count];)
            {
                int f_id = [[tableArray objectAtIndex:j] intValue];
                if(demo.f_id == f_id)
                {
                    [tableArray removeObjectAtIndex:j];
                }
                else
                {
                    j++;
                }
            }
        }
        [self loadViewData];
    }
}

-(void)viewWillAppear:(BOOL)animated
{
    if(![[[SCBSession sharedSession] userId] isEqualToString:user_id] && ![[[SCBSession sharedSession] userToken] isEqualToString:user_token])
    {
        if(photoManager)
        {
            [photoManager release];
        }
        //请求时间轴
        photoManager = [[SCBPhotoManager alloc] init];
        [photoManager setPhotoDelegate:self];
        [photoManager getPhotoTimeLine];
        [self setUser_id:[[SCBSession sharedSession] userId]];
        [self setUser_token:[[SCBSession sharedSession] userToken]];
    }
}

//获取图片路径
- (NSString*)get_image_save_file_path:(NSString*)image_path
{
    NSArray *path_array = NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES);
    NSString *documentDir = [path_array objectAtIndex:0];
    NSArray *array=[image_path componentsSeparatedByString:@"/"];
    NSString *path=[NSString stringWithFormat:@"%@/%@",documentDir,[array lastObject]];
    return path;
}

//这个路径下是否存在此图片
- (BOOL)image_exists_at_file_path:(NSString *)image_path
{
    NSFileManager *file_manager = [NSFileManager defaultManager];
    NSArray *path_array = NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES);
    NSString *documentDir = [path_array objectAtIndex:0];
    NSArray *array=[image_path componentsSeparatedByString:@"/"];
    NSString *path=[NSString stringWithFormat:@"%@/%@",documentDir,[array lastObject]];
    return [file_manager fileExistsAtPath:path];
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
    [super dealloc];
}

@end
