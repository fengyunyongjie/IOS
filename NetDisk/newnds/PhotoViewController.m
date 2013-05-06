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

@interface PhotoViewController ()

@end

@implementation PhotoViewController
@synthesize photoManager,scroll_View;

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
    //添加分享按钮
    UINavigationItem *nav_item = [self navigationItem];
    UIButton *right_button = [UIButton buttonWithType:UIButtonTypeCustom];
    CGRect rect = CGRectMake(300, 7, 24, 24);
    [right_button setFrame:rect];
    [right_button setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
    [right_button.titleLabel setFont:[UIFont boldSystemFontOfSize:15.0]];
    [right_button setBackgroundImage:[UIImage imageNamed:@"u102_normal"] forState:UIControlStateNormal];
    [right_button setTitle:@"提交" forState:UIControlStateNormal];
    [right_button addTarget:self action:@selector(right_button_cilcked:) forControlEvents:UIControlEventTouchUpInside];
    UIBarButtonItem *right_item = [[UIBarButtonItem alloc] initWithCustomView:right_button];
    [nav_item setRightBarButtonItem:right_item];
    photoManager = [[SCBPhotoManager alloc] init];
    [photoManager setPhotoDelegate:self];
    [photoManager getPhotoTimeLine];
    scroll_View = [[UIScrollView alloc] initWithFrame:CGRectMake(0, 0, 320, 180)];
    [scroll_View setBackgroundColor:[UIColor clearColor]];
    [self.view addSubview:scroll_View];
    [self.view setBackgroundColor:[UIColor whiteColor]];
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
        [tableArray addObject:time_string];
        timeLine = [timeLine substringFromIndex:12];
        range = [timeLine rangeOfString:@"],"];
    }
    if([timeLine length]>0)
    {
        timeLine = [timeLine stringByReplacingOccurrencesOfString:@",[" withString:@"-"];
        timeLine = [timeLine stringByReplacingOccurrencesOfString:@"[" withString:@""];
        timeLine = [timeLine stringByReplacingOccurrencesOfString:@"]" withString:@""];
        [tableArray addObject:timeLine];
    }
    [photoManager getAllPhotoGeneral:tableArray];
    //昨天
    //本周
    //上一周
    //本月
    //上一月
    //本年
    //xxxx年
}

#pragma mark -得到时间轴的概要列表
-(void)getPhotoGeneral:(NSDictionary *)dictionary
{
    allDictionary = dictionary;
    NSLog(@"diction:%@",[dictionary allKeys]);
    //今天
    if([dictionary objectForKey:timeLine1]!=nil)
    {
        NSArray *array = [dictionary objectForKey:timeLine1];
        [self showTimeLine:array titleString:timeLine1];
    }
    //昨天
    if([dictionary objectForKey:timeLine2]!=nil)
    {
        NSArray *array = [dictionary objectForKey:timeLine2];
        [self showTimeLine:array titleString:timeLine2];
    }
    //本周
    if([dictionary objectForKey:timeLine3]!=nil)
    {
        NSArray *array = [dictionary objectForKey:timeLine3];
        [self showTimeLine:array titleString:timeLine3];
    }
    //上一周
    if([dictionary objectForKey:timeLine4]!=nil)
    {
        NSArray *array = [dictionary objectForKey:timeLine4];
        [self showTimeLine:array titleString:timeLine4];
    }
    //本月
    if([dictionary objectForKey:timeLine5]!=nil)
    {
        NSArray *array = [dictionary objectForKey:timeLine5];
        [self showTimeLine:array titleString:timeLine5];
    }
    //上一月
    if([dictionary objectForKey:timeLine6]!=nil)
    {
        NSArray *array = [dictionary objectForKey:timeLine6];
        [self showTimeLine:array titleString:timeLine6];
    }
    //本年
    if([dictionary objectForKey:timeLine7]!=nil)
    {
        NSArray *array = [dictionary objectForKey:timeLine7];
        [self showTimeLine:array titleString:timeLine7];
    }
    //xxxx年
    if([dictionary objectForKey:@"xxxx年"]!=nil)
    {
        NSArray *array = [dictionary objectForKey:timeLine3];
        [self showTimeLine:array titleString:timeLine3];
    }
}

-(void)getPhotoDetail:(NSDictionary *)dictionary
{
    
}

-(void)showTimeLine:(NSArray *)array titleString:(NSString *)titleString
{
    if(show_height>0)
    {
        show_height += 10;
    }
    else
    {
        show_height = 2;
    }
    //标题
    CGRect title_rect = CGRectMake(2, show_height, 200, 20);
    UILabel *title_label = [[UILabel alloc] initWithFrame:title_rect];
    [title_label setText:titleString];
    [title_label setFont:[UIFont systemFontOfSize:12]];
    [title_label setBackgroundColor:[UIColor clearColor]];
    [scroll_View addSubview:title_label];
    float image_height = title_label.frame.origin.y+title_label.frame.size.height+3;
    for(int i=0;i<[array count];i++)
    {
        //图片
        PhohoDemo *demo = (PhohoDemo *)[array objectAtIndex:i];
        if(i%4==0&i!=0)
        {
            //换行
            image_height += 85;
        }
        CGRect image_rect = CGRectMake(80*(i%4)+2, image_height, (320-(2*5))/4, 80);
        UIButton *image_button = [[UIButton alloc] initWithFrame:image_rect];
        int indexTag = 0;
        if([titleString isEqualToString:timeLine1])
        {
            indexTag = 1000;
        }
        if([titleString isEqualToString:timeLine2])
        {
            indexTag = 2000;
        }
        if([titleString isEqualToString:timeLine3])
        {
            indexTag = 3000;
        }
        if([titleString isEqualToString:timeLine4])
        {
            indexTag = 4000;
        }
        if([titleString isEqualToString:timeLine5])
        {
            indexTag = 5000;
        }
        if([titleString isEqualToString:timeLine6])
        {
            indexTag = 6000;
        }
        if([titleString isEqualToString:timeLine7])
        {
            indexTag = 7000;
        }
        [image_button setTag:indexTag+i];
        DownImage *downImage = [[[DownImage alloc] init] autorelease];
        [downImage setFileId:demo.f_id];
        [downImage setImageUrl:demo.f_name];
        [downImage setImageViewIndex:indexTag+i];
        [downImage setDelegate:self];
        [image_button setTitle:@"A" forState:UIControlStateNormal];
        [image_button setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
        [image_button addTarget:self action:@selector(image_button_click:) forControlEvents:UIControlEventTouchUpInside];
        [scroll_View addSubview:image_button];
        [downImage startDownload];
        show_height = image_button.frame.origin.y + image_button.frame.size.height;
    }
}

-(void)appImageDidLoad:(NSInteger)indexTag urlImage:image
{
    UIButton *image_button = (UIButton *)[scroll_View viewWithTag:indexTag];
    [image_button setBackgroundImage:image forState:UIControlStateNormal];
    CGRect imageRect = image_button.imageView.frame;
    imageRect.size.width = (320-(2*5))/4;
    imageRect.size.height = 80;
    [image_button.imageView setFrame:imageRect];
    
}

#pragma mark 进入详细页面
-(void)image_button_click:(id)sender
{
    UIButton *image_button = sender;
    int type = image_button.tag/1000;
    NSArray *array = nil;
    //今天
    if(type ==1 && [allDictionary objectForKey:timeLine1]!=nil)
    {
        array = [allDictionary objectForKey:timeLine1];
    }
    //昨天
    if(type ==2 && [allDictionary objectForKey:timeLine2]!=nil)
    {
        array = [allDictionary objectForKey:timeLine2];
    }
    //本周
    if(type ==3 && [allDictionary objectForKey:timeLine3]!=nil)
    {
        array = [allDictionary objectForKey:timeLine3];
    }
    //上一周
    if(type ==4 && [allDictionary objectForKey:timeLine4]!=nil)
    {
       array = [allDictionary objectForKey:timeLine4];
    }
    //本月
    if(type ==5 && [allDictionary objectForKey:timeLine5]!=nil)
    {
        array = [allDictionary objectForKey:timeLine5];
    }
    //上一月
    if(type ==6 && [allDictionary objectForKey:timeLine6]!=nil)
    {
        array = [allDictionary objectForKey:timeLine6];
    }
    //本年
    if(type ==7 && [allDictionary objectForKey:timeLine7]!=nil)
    {
        array = [allDictionary objectForKey:timeLine7];
    }
    //xxxx年
    if(type ==8 && [allDictionary objectForKey:@"xxxx年"]!=nil)
    {
        array = [allDictionary objectForKey:timeLine3];
    }
    PhotoDetailViewController *photoDetalViewController = [[PhotoDetailViewController alloc] init];
    [photoDetalViewController loadAllDiction:array currtimeIdexTag:image_button.tag%(1000*type)];
    [self presentViewController:photoDetalViewController animated:YES completion:^{}];
    [photoDetalViewController release];
}

-(void)dealloc
{
    [photoManager release];
    [scroll_View release];
    [super dealloc];
}

@end
