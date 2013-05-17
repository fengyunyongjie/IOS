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

@interface PhotoViewController ()

@end

@implementation PhotoViewController
@synthesize photoManager,allDictionary;
@synthesize table_view;

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
    
    //请求时间轴
    photoManager = [[SCBPhotoManager alloc] init];
    [photoManager setPhotoDelegate:self];
    [photoManager getPhotoTimeLine];
    
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
    
}

#pragma mark -得到时间轴的列表
-(void)getPhotoTiimeLine:(NSDictionary *)dictionary
{
    //解析时间轴
    NSString *timeLine = [dictionary objectForKey:@"timeline"];
    NSMutableArray *tableArray = [[NSMutableArray alloc] init];
    NSRange range = [timeLine rangeOfString:@"],"];
    while (range.length>0) {
        NSString *time_string = [timeLine substringToIndex:range.location+1];
        time_string = [time_string stringByReplacingOccurrencesOfString:@",[" withString:@"-"];
        time_string = [time_string stringByReplacingOccurrencesOfString:@"[" withString:@""];
        time_string = [time_string stringByReplacingOccurrencesOfString:@"]" withString:@""];
        if([time_string length]>7)
        {
            time_string = [time_string substringToIndex:7];
        }
        [tableArray addObject:time_string];
        timeLine = [timeLine substringFromIndex:range.location+2];
        range = [timeLine rangeOfString:@"],"];
    }
    if([timeLine length]>0)
    {
        timeLine = [timeLine stringByReplacingOccurrencesOfString:@",[" withString:@"-"];
        timeLine = [timeLine stringByReplacingOccurrencesOfString:@"[" withString:@""];
        timeLine = [timeLine stringByReplacingOccurrencesOfString:@"]" withString:@""];
        if([timeLine length]>7)
        {
            timeLine = [timeLine substringToIndex:7];
        }
        [tableArray addObject:timeLine];
    }
    NSLog(@"解析时间轴:%@",tableArray);
    [photoManager getAllPhotoGeneral:tableArray];
}

#pragma mark -得到时间轴的概要列表
-(void)getPhotoGeneral:(NSDictionary *)dictionary
{
    table_view = [[UITableView alloc] initWithFrame:CGRectMake(0, 0, 320, self.view.frame.size.height)];
    [self.view addSubview:table_view];
    allDictionary = [[NSMutableDictionary alloc] initWithDictionary:dictionary];
    [table_view setSeparatorStyle:UITableViewCellSeparatorStyleNone];
    table_view.delegate = self;
    table_view.dataSource = self;
    [table_view reloadData];
    [NSTimer scheduledTimerWithTimeInterval:0.5 target:self selector:@selector(firstLoad) userInfo:nil repeats:NO];
}

-(void)firstLoad
{
    [self scrollViewDidEndDragging:nil willDecelerate:YES];
}

-(void)getPhotoDetail:(NSDictionary *)dictionary
{
    
}

#pragma mark 下载完成后的回调方法
-(void)appImageDidLoad:(NSInteger)indexTag urlImage:(UIImage *)image index:(int)index
{
    PhotoCell *cell = (PhotoCell *)[table_view viewWithTag:indexTag];
    switch (index) {
        case 1:
        {
            PhotoImageButton *image_button = cell.imageViewButton1;
            if(image_button)
            {
                [self loadImageView:image button:image_button];
                [image_button setIsShowImage:YES];
            }
        }
            break;
        case 2:
        {
            PhotoImageButton *image_button = cell.imageViewButton2;
            if(image_button)
            {
                [self loadImageView:image button:image_button];
                [image_button setIsShowImage:YES];
            }
        }
            break;
        case 3:
        {
            PhotoImageButton *image_button = cell.imageViewButton3;
            if(image_button)
            {
                [self loadImageView:image button:image_button];
                [image_button setIsShowImage:YES];
            }
        }
            break;
        case 4:
        {
            PhotoImageButton *image_button = cell.imageViewButton4;
            if(image_button)
            {
                [self loadImageView:image button:image_button];
                [image_button setIsShowImage:YES];
            }
        }
        default:
            break;
    }
}

#pragma mark 初始化试图
-(void)loadCellDefulImage:(PhotoImageButton *)image_button urlImage:(UIImage *)image
{
    if(image_button)
    {
        [self loadImageView:image button:image_button];
        [image_button setIsShowImage:YES];
    }
}

-(void)loadImageView:(UIImage *)image button:(PhotoImageButton *)image_button
{
    [image_button setIsShowImage:YES];
    UIImage *image1 = (UIImage *)image;
    CGSize imageS = image1.size;
    if(imageS.width == imageS.height)
    {
        if(imageS.width>=75)
        {
            imageS.height = 75;
            imageS.width = 75;
            image = [self scaleFromImage:image toSize:imageS];
            [image_button setBackgroundImage:image forState:UIControlStateNormal];
        }
        else
        {
            CGRect imageRect = image_button.frame;
            imageRect.size.width = imageS.width;
            imageRect.size.height = imageS.height;
            [image_button setFrame:imageRect];
        }
    }
    else if(imageS.width < imageS.height)
    {
        if(imageS.width>=75)
        {
            imageS.height = 75*imageS.height/imageS.width;
            image = [self scaleFromImage:image toSize:CGSizeMake(75, imageS.height)];
            UIImage *endImage = [self imageFromImage:image inRect:CGRectMake(0, (imageS.height-75)/2, 75, 75)];
            [image_button setBackgroundImage:endImage forState:UIControlStateNormal];
        }
        else if(imageS.height<75)
        {
            CGRect imageRect = image_button.frame;
            imageRect.size.width = imageS.width;
            imageRect.size.height = imageS.height;
            [image_button setFrame:imageRect];
            [image_button setBackgroundImage:image forState:UIControlStateNormal];
        }
        else
        {
            UIImage *endImage = [self imageFromImage:image inRect:CGRectMake((75-imageS.width)/2, (imageS.height-75)/2, imageS.width, 75)];
            [image_button setBackgroundImage:endImage forState:UIControlStateNormal];
            CGRect imageRect = image_button.frame;
            imageRect.size.width = imageS.width;
            imageRect.size.height = 75;
            [image_button setFrame:imageRect];
        }
    }
    else
    {
        if(imageS.height>=75)
        {
            imageS.width = 75*imageS.width/imageS.height;
            image = [self scaleFromImage:image toSize:CGSizeMake(imageS.width, 75)];
            UIImage *endImage = [self imageFromImage:image inRect:CGRectMake((imageS.width-75)/2, 0, 75, 75)];
            [image_button setBackgroundImage:endImage forState:UIControlStateNormal];
        }
        else if(imageS.width<75)
        {
            CGRect imageRect = image_button.frame;
            imageRect.size.width = imageS.width;
            imageRect.size.height = imageS.height;
            [image_button setFrame:imageRect];
            [image_button setBackgroundImage:image forState:UIControlStateNormal];
        }
        else
        {
            UIImage *endImage = [self imageFromImage:image inRect:CGRectMake((imageS.width-75)/2, (75-imageS.height)/2, 75, imageS.height)];
            [image_button setBackgroundImage:endImage forState:UIControlStateNormal];
            CGRect imageRect = image_button.frame;
            imageRect.size.width = 75;
            imageRect.size.height = imageS.height;
            [image_button setFrame:imageRect];
        }
    }
}

#pragma mark 进入详细页面
-(void)image_button_click:(id)sender
{
    PhotoImageButton *image_button = sender;
    NSArray *array = [allDictionary objectForKey:image_button.timeLine];
    PhotoDetailViewController *photoDetalViewController = [[PhotoDetailViewController alloc] init];
    photoDetalViewController.deleteDelegate = self;
    [self presentViewController:photoDetalViewController animated:YES completion:^{
        [photoDetalViewController setTimeLine:image_button.timeLine];
        [photoDetalViewController loadAllDiction:array currtimeIdexTag:image_button.timeIndex];
        [photoDetalViewController release];
    }];
}

#pragma mark 删除回调
-(void)deleteForDeleteArray:(NSInteger)page timeLine:(NSString *)timeLineString
{
    if(page == -1)
    {
        [allDictionary removeObjectForKey:timeLineString];
        NSMutableArray *allKeys = [allDictionary objectForKey:@"timeLine"];
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
        if(!cell.imageViewButton1.isShowImage)
        {
            PhohoDemo *demo = cell.imageViewButton1.demo;
            DownImage *downImage = [[DownImage alloc] init];
            [downImage setFileId:demo.f_id];
            [downImage setImageUrl:demo.f_name];
            [downImage setImageViewIndex:cell.tag];
            [downImage setIndex:1];
            [downImage setDelegate:self];
            [downImage startDownload];
            [downImage release];
        }
        if(!cell.imageViewButton1.isShowImage)
        {
            PhohoDemo *demo = cell.imageViewButton2.demo;
            DownImage *downImage = [[DownImage alloc] init];
            [downImage setFileId:demo.f_id];
            [downImage setImageUrl:demo.f_name];
            [downImage setImageViewIndex:cell.tag];
            [downImage setIndex:2];
            [downImage setDelegate:self];
            [downImage startDownload];
            [downImage release];
        }
        if(!cell.imageViewButton1.isShowImage)
        {
            PhohoDemo *demo = cell.imageViewButton3.demo;
            DownImage *downImage = [[DownImage alloc] init];
            [downImage setFileId:demo.f_id];
            [downImage setImageUrl:demo.f_name];
            [downImage setImageViewIndex:cell.tag];
            [downImage setIndex:3];
            [downImage setDelegate:self];
            [downImage startDownload];
            [downImage release];
        }
        if(!cell.imageViewButton1.isShowImage)
        {
            PhohoDemo *demo = cell.imageViewButton4.demo;
            DownImage *downImage = [[DownImage alloc] init];
            [downImage setFileId:demo.f_id];
            [downImage setImageUrl:demo.f_name];
            [downImage setImageViewIndex:cell.tag];
            [downImage setIndex:4];
            [downImage setDelegate:self];
            [downImage startDownload];
            [downImage release];
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

#pragma mark UITableViewDelegate
-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return [[allDictionary objectForKey:@"timeLine"] count];
}

-(NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{
    return [[allDictionary objectForKey:@"timeLine"] objectAtIndex:section];
}

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    NSArray *allKeys = [allDictionary objectForKey:@"timeLine"];
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
    NSArray *allKeys = [allDictionary objectForKey:@"timeLine"];
    NSString *timeLine = [allKeys objectAtIndex:section];
    NSArray *array = [allDictionary objectForKey:timeLine];
    NSString *cellString = [NSString stringWithFormat:@"cellLoad:%i %i",section,row];
    PhotoCell *photoCell = [table_view dequeueReusableCellWithIdentifier:cellString];
    if(!photoCell)
    {
        photoCell = [[PhotoCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellString];
        [photoCell setSelectionStyle:UITableViewCellSelectionStyleNone];
    }
    photoCell.tag = 20000*(section+1)+row;
    if([array count]/4>=row+1)
    {
        PhohoDemo *demo = (PhohoDemo *)[array objectAtIndex:row*4];
        [photoCell.imageViewButton1 setDemo:demo];
        [photoCell.imageViewButton1 addTarget:self action:@selector(image_button_click:) forControlEvents:UIControlEventTouchUpInside];
        [photoCell.imageViewButton1 setTimeLine:timeLine];
        [photoCell.imageViewButton1 setTimeIndex:row*4];
        NSString *path = [self get_image_save_file_path:demo.f_name];
        UIImage *imageDemo;
        if([self image_exists_at_file_path:path])
        {
            imageDemo = [UIImage imageWithContentsOfFile:path];
            [self loadCellDefulImage:photoCell.imageViewButton1 urlImage:imageDemo];
        }
        else
        {
            imageDemo = [UIImage imageNamed:@"icon_Load.png"];
            [photoCell.imageViewButton1 setBackgroundImage:imageDemo forState:UIControlStateNormal];
        }
        
        demo = (PhohoDemo *)[array objectAtIndex:row*4+1];
        [photoCell.imageViewButton2 setDemo:demo];
        [photoCell.imageViewButton2 addTarget:self action:@selector(image_button_click:) forControlEvents:UIControlEventTouchUpInside];
        [photoCell.imageViewButton2 setTimeLine:timeLine];
        [photoCell.imageViewButton2 setTimeIndex:row*4+1];
        path = [self get_image_save_file_path:demo.f_name];
        if([self image_exists_at_file_path:path])
        {
            imageDemo = [UIImage imageWithContentsOfFile:path];
            [self loadCellDefulImage:photoCell.imageViewButton2 urlImage:imageDemo];
        }
        else
        {
            imageDemo = [UIImage imageNamed:@"icon_Load.png"];
            [photoCell.imageViewButton2 setBackgroundImage:imageDemo forState:UIControlStateNormal];
        }
        
        demo = (PhohoDemo *)[array objectAtIndex:row*4+2];
        [photoCell.imageViewButton3 setDemo:demo];
        [photoCell.imageViewButton3 addTarget:self action:@selector(image_button_click:) forControlEvents:UIControlEventTouchUpInside];
        [photoCell.imageViewButton3 setTimeLine:timeLine];
        [photoCell.imageViewButton3 setTimeIndex:row*4+2];
        path = [self get_image_save_file_path:demo.f_name];
        if([self image_exists_at_file_path:path])
        {
            imageDemo = [UIImage imageWithContentsOfFile:path];
            [self loadCellDefulImage:photoCell.imageViewButton3 urlImage:imageDemo];
        }
        else
        {
            imageDemo = [UIImage imageNamed:@"icon_Load.png"];
            [photoCell.imageViewButton3 setBackgroundImage:imageDemo forState:UIControlStateNormal];
        }
        
        demo = (PhohoDemo *)[array objectAtIndex:row*4+3];
        [photoCell.imageViewButton4 setDemo:demo];
        [photoCell.imageViewButton4 addTarget:self action:@selector(image_button_click:) forControlEvents:UIControlEventTouchUpInside];
        [photoCell.imageViewButton4 setTimeLine:timeLine];
        [photoCell.imageViewButton4 setTimeIndex:row*4+3];
        path = [self get_image_save_file_path:demo.f_name];
        if([self image_exists_at_file_path:path])
        {
            imageDemo = [UIImage imageWithContentsOfFile:path];
            [self loadCellDefulImage:photoCell.imageViewButton4 urlImage:imageDemo];
        }
        else
        {
            imageDemo = [UIImage imageNamed:@"icon_Load.png"];
            [photoCell.imageViewButton4 setBackgroundImage:imageDemo forState:UIControlStateNormal];
        }
    }
    else
    {
        int number = [array count]%4;
        PhohoDemo *demo;
        if(number==1)
        {
            demo = (PhohoDemo *)[array objectAtIndex:row*4];
            [photoCell.imageViewButton1 setDemo:demo];
            [photoCell.imageViewButton1 addTarget:self action:@selector(image_button_click:) forControlEvents:UIControlEventTouchUpInside];
            [photoCell.imageViewButton1 setTimeLine:timeLine];
            [photoCell.imageViewButton1 setTimeIndex:row*4];
            NSString *path = [self get_image_save_file_path:demo.f_name];
            UIImage *imageDemo;
            if([self image_exists_at_file_path:path])
            {
                imageDemo = [UIImage imageWithContentsOfFile:path];
                [self loadCellDefulImage:photoCell.imageViewButton1 urlImage:imageDemo];
            }
            else
            {
                imageDemo = [UIImage imageNamed:@"icon_Load.png"];
                [photoCell.imageViewButton1 setBackgroundImage:imageDemo forState:UIControlStateNormal];
            }
            
            [photoCell.imageViewButton2 setDemo:nil];
            [photoCell.imageViewButton3 setDemo:nil];
            [photoCell.imageViewButton4 setDemo:nil];
        }
        else if(number==2)
        {
            demo = (PhohoDemo *)[array objectAtIndex:row*4];
            [photoCell.imageViewButton1 setDemo:demo];
            [photoCell.imageViewButton1 addTarget:self action:@selector(image_button_click:) forControlEvents:UIControlEventTouchUpInside];
            [photoCell.imageViewButton1 setTimeLine:timeLine];
            [photoCell.imageViewButton1 setTimeIndex:row*4];
            NSString *path = [self get_image_save_file_path:demo.f_name];
            UIImage *imageDemo;
            if([self image_exists_at_file_path:path])
            {
                imageDemo = [UIImage imageWithContentsOfFile:path];
                [self loadCellDefulImage:photoCell.imageViewButton1 urlImage:imageDemo];
            }
            else
            {
                imageDemo = [UIImage imageNamed:@"icon_Load.png"];
                [photoCell.imageViewButton1 setBackgroundImage:imageDemo forState:UIControlStateNormal];
            }
            
            demo = (PhohoDemo *)[array objectAtIndex:row*4+1];
            [photoCell.imageViewButton2 setDemo:demo];
            [photoCell.imageViewButton2 addTarget:self action:@selector(image_button_click:) forControlEvents:UIControlEventTouchUpInside];
            [photoCell.imageViewButton2 setTimeLine:timeLine];
            [photoCell.imageViewButton2 setTimeIndex:row*4+1];
            path = [self get_image_save_file_path:demo.f_name];
            if([self image_exists_at_file_path:path])
            {
                imageDemo = [UIImage imageWithContentsOfFile:path];
                [self loadCellDefulImage:photoCell.imageViewButton2 urlImage:imageDemo];
            }
            else
            {
                imageDemo = [UIImage imageNamed:@"icon_Load.png"];
                [photoCell.imageViewButton2 setBackgroundImage:imageDemo forState:UIControlStateNormal];
            }
            
            [photoCell.imageViewButton3 setDemo:nil];
            [photoCell.imageViewButton4 setDemo:nil];
        }
        else if(number==3)
        {
            demo = (PhohoDemo *)[array objectAtIndex:row*4];
            [photoCell.imageViewButton1 setDemo:demo];
            [photoCell.imageViewButton1 addTarget:self action:@selector(image_button_click:) forControlEvents:UIControlEventTouchUpInside];
            [photoCell.imageViewButton1 setTimeLine:timeLine];
            [photoCell.imageViewButton1 setTimeIndex:row*4];
            NSString *path = [self get_image_save_file_path:demo.f_name];
            UIImage *imageDemo;
            if([self image_exists_at_file_path:path])
            {
                imageDemo = [UIImage imageWithContentsOfFile:path];
                [self loadCellDefulImage:photoCell.imageViewButton1 urlImage:imageDemo];
            }
            else
            {
                imageDemo = [UIImage imageNamed:@"icon_Load.png"];
                [photoCell.imageViewButton1 setBackgroundImage:imageDemo forState:UIControlStateNormal];
            }
            
            demo = (PhohoDemo *)[array objectAtIndex:row*4+1];
            [photoCell.imageViewButton2 setDemo:demo];
            [photoCell.imageViewButton2 addTarget:self action:@selector(image_button_click:) forControlEvents:UIControlEventTouchUpInside];
            [photoCell.imageViewButton2 setTimeLine:timeLine];
            [photoCell.imageViewButton2 setTimeIndex:row*4+1];
            path = [self get_image_save_file_path:demo.f_name];
            if([self image_exists_at_file_path:path])
            {
                imageDemo = [UIImage imageWithContentsOfFile:path];
                [self loadCellDefulImage:photoCell.imageViewButton2 urlImage:imageDemo];
            }
            else
            {
                imageDemo = [UIImage imageNamed:@"icon_Load.png"];
                [photoCell.imageViewButton2 setBackgroundImage:imageDemo forState:UIControlStateNormal];
            }
            
            demo = (PhohoDemo *)[array objectAtIndex:row*4+2];
            [photoCell.imageViewButton3 setDemo:demo];
            [photoCell.imageViewButton3 addTarget:self action:@selector(image_button_click:) forControlEvents:UIControlEventTouchUpInside];
            [photoCell.imageViewButton3 setTimeLine:timeLine];
            [photoCell.imageViewButton3 setTimeIndex:row*4+2];
            path = [self get_image_save_file_path:demo.f_name];
            if([self image_exists_at_file_path:path])
            {
                imageDemo = [UIImage imageWithContentsOfFile:path];
                [self loadCellDefulImage:photoCell.imageViewButton3 urlImage:imageDemo];
            }
            else
            {
                imageDemo = [UIImage imageNamed:@"icon_Load.png"];
                [photoCell.imageViewButton3 setBackgroundImage:imageDemo forState:UIControlStateNormal];
            }
            
            [photoCell.imageViewButton4 setDemo:nil];
        }
    }
    return photoCell;
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

-(void)viewWillAppear:(BOOL)animated
{
    [table_view reloadData];
}

-(void)dealloc
{
    [photoManager release];
    [table_view release];
    [allDictionary release];
    [super dealloc];
}

@end
