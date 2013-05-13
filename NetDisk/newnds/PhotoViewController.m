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

@interface PhotoViewController ()

@end

@implementation PhotoViewController
@synthesize photoManager,scroll_View,allDictionary;

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
    [right_button setBackgroundImage:[UIImage imageNamed:@"u102_normal"] forState:UIControlStateNormal];
    [right_button setTitle:@"提交" forState:UIControlStateNormal];
    [right_button addTarget:self action:@selector(right_button_cilcked:) forControlEvents:UIControlEventTouchUpInside];
    UIBarButtonItem *right_item = [[UIBarButtonItem alloc] initWithCustomView:right_button];
    [nav_item setRightBarButtonItem:right_item];
    photoManager = [[SCBPhotoManager alloc] init];
    [photoManager setPhotoDelegate:self];
    [photoManager getPhotoTimeLine];
    scroll_View = [[UIScrollView alloc] initWithFrame:CGRectMake(0, 0, 320, self.view.frame.size.height-49-44)];
    [scroll_View setBackgroundColor:[UIColor clearColor]];
    scroll_View.delegate = self;
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
    allDictionary = dictionary;
    NSLog(@"时间轴 diction:%@",[dictionary allKeys]);
    NSArray *allKeys = [dictionary objectForKey:@"timeLine"];
    for(int i=0;i<[allKeys count];i++)
    {
        NSArray *array = [dictionary objectForKey:[allKeys objectAtIndex:i]];
        [self showTimeLine:array titleString:[allKeys objectAtIndex:i]];
    }
    [self scrollViewDidEndDragging:scroll_View willDecelerate:YES];
}

-(void)getPhotoDetail:(NSDictionary *)dictionary
{
    
}

-(void)showTimeLine:(NSArray *)array titleString:(NSString *)titleString
{
    NSLog(@"height:%i",show_height);
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
            image_height += 79;
        }
        CGRect image_rect = CGRectMake(79*(i%4)+4, image_height, 75, 75);
        PhotoImageButton *image_button = [[PhotoImageButton alloc] initWithFrame:image_rect];
        imageTa++;
        [image_button setTag:imageTa];
        [image_button setTimeIndex:i];
        [image_button setDemo:demo];
        
        [image_button setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
        [image_button addTarget:self action:@selector(image_button_click:) forControlEvents:UIControlEventTouchUpInside];
        [image_button setTimeLine:titleString];
        [scroll_View addSubview:image_button];
        [image_button release];
        show_height = image_button.frame.origin.y + image_button.frame.size.height;
        [scroll_View setContentSize:CGSizeMake(320, show_height+10)];
    }
}

#pragma mark 下载完成后的回调方法
-(void)appImageDidLoad:(NSInteger)indexTag urlImage:image
{
    PhotoImageButton *image_button = (PhotoImageButton *)[scroll_View viewWithTag:indexTag];
    
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
    [self presentViewController:photoDetalViewController animated:YES completion:^{
        [photoDetalViewController loadAllDiction:array currtimeIdexTag:image_button.timeIndex];
        [photoDetalViewController release];
    }];
}


- (void)scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate
{
//	BOOL offset_distance = scrollView.contentOffset.y + (scrollView.frame.size.height) > scrollView.contentSize.height*3/4;
    int loadIndex = scroll_View.contentOffset.y/90*4;
    int imageIndex = 1000;
    if(loadIndex>0)
    {
        for(int i = imageIndex+loadIndex-28;i<imageIndex+loadIndex+1;i++)
        {
            if(i>=imageTa+1)
            {
                break;
            }
            if(i<1000)
            {
                continue;
            }
            else
            {
                PhotoImageButton *image_button = (PhotoImageButton *)[scroll_View viewWithTag:i];
                if(![image_button isShowImage])
                {
                    DownImage *downImage = [[DownImage alloc] init];
                    [downImage setFileId:image_button.demo.f_id];
                    [downImage setImageUrl:image_button.demo.f_name];
                    [downImage setImageViewIndex:i];
                    [downImage setDelegate:self];
                    [downImage startDownload];
                    [downImage release];
                }
            }
        }
    }
    for(int i = imageIndex+loadIndex-1;i<imageIndex+loadIndex+28;i++)
    {
        if(i>=imageTa+1)
        {
            break;
        }
        if(i<1000)
        {
            continue;
        }
        else
        {
            PhotoImageButton *image_button = (PhotoImageButton *)[scroll_View viewWithTag:i];
            if(![image_button isShowImage])
            {
                DownImage *downImage = [[DownImage alloc] init];
                [downImage setFileId:image_button.demo.f_id];
                [downImage setImageUrl:image_button.demo.f_name];
                [downImage setImageViewIndex:i];
                [downImage setDelegate:self];
                [downImage startDownload];
                [downImage release];
            }
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
    [scroll_View release];
    [allDictionary release];
    [super dealloc];
}

@end
