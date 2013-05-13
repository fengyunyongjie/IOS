//
//  PhotoDetailViewController.m
//  NetDisk
//
//  Created by Yangsl on 13-5-6.
//
//

#import "PhotoDetailViewController.h"
#import "PhohoDemo.h"
#import "PhotoDetailView.h"

@interface PhotoDetailViewController ()

@end

@implementation PhotoDetailViewController
@synthesize scroll_View;

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
    allHeight = self.view.frame.size.height;
    imageTag = 10000;
    CGRect scrollRect = CGRectMake(0, 0, 320, allHeight);
    scroll_View = [[UIScrollView alloc] initWithFrame:scrollRect];
    [scroll_View setPagingEnabled:YES];
    [scroll_View setScrollEnabled:YES];
    [self.view addSubview:scroll_View];
    [self.view setBackgroundColor:[UIColor whiteColor]];
    [super viewDidLoad];
	// Do any additional setup after loading the view.
}

-(void)dealloc
{
    [scroll_View release];
    [super dealloc];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark 加载所有数据
-(void)loadAllDiction:(NSArray *)allArray currtimeIdexTag:(int)indexTag
{
    allPhotoDemoArray = [[NSMutableArray alloc] initWithArray:allArray];
    currPageNumber = indexTag;
    for(int i=0;i<[allArray count];i++)
    {
        PhohoDemo *demo = (PhohoDemo *)[allPhotoDemoArray objectAtIndex:i];
        [self addCenterImageView:demo currPage:i totalCount:[allPhotoDemoArray count]];
    }
    [scroll_View setContentOffset:CGPointMake(320*indexTag, 0) animated:NO];
    [self showIndexTag:indexTag];
    [scroll_View setDelegate:self];
}

#pragma mark 添加图片
-(void)addCenterImageView:(PhohoDemo *)demo currPage:(NSInteger)pageIndex totalCount:(NSInteger)count
{
    CGRect detailRect =  CGRectMake(320*pageIndex, 0, 320, allHeight);
    PhotoDetailView *detailView = [[[PhotoDetailView alloc] initWithFrame:detailRect] autorelease];
    //设置返回按钮
    [detailView.topButton setTitle:@"返回" forState:UIControlStateNormal];
    [detailView.topButton addTarget:self action:@selector(backClick) forControlEvents:UIControlEventTouchUpInside];
    detailView.clickButton.tag = 20000+pageIndex;
    [detailView.clickButton addTarget:self action:@selector(multipleTap:withEvent:) forControlEvents:UIControlEventTouchUpInside];
    
//    [detailView.clickButton addTarget:self action:@selector(showHidden:) forControlEvents:UIControlEventTouchUpInside];
    //页数
    [detailView.pagLabel setText:[NSString stringWithFormat:@"%i/%i",pageIndex+1,count]];
    //地址
    [detailView.addressLabel setText:@"蘑菇街"];
    //温度，天气
    [detailView.weatherLabel setText:@"23/多云"];
    //当天pm时间
    [detailView.dayTimeLabel setText:@"PM 2.5 38"];
    //分割线
    //日期
    NSDateFormatter *dateFormatter = [[[NSDateFormatter alloc] init] autorelease];
    [dateFormatter setDateStyle:NSDateFormatterMediumStyle];
    [dateFormatter setTimeStyle:NSDateFormatterShortStyle];
    [dateFormatter setDateFormat:@"yyyy/MM/dd HH:mm:dd"];
    [detailView.dateTimeLabel setText:demo.f_create];
    //拍摄设备
    [detailView.clientLabel setText:@"iPhone5"];
    //分享，下载，删除，三个按钮
    //        [detailView.leftButton.titleLabel setText:@"分享"];
    //        [detailView.leftButton setBackgroundColor:[UIColor redColor]];
    //        [detailView.centerButton.titleLabel setText:@"下载"];
    detailView.rightButton.tag = 40000+pageIndex;
    [detailView.rightButton addTarget:self action:@selector(deleteClicked:) forControlEvents:UIControlEventTouchUpInside];
    [detailView hiddenNewview];
    detailView.bgImageView.tag = imageTag+pageIndex;
    detailView.tag = 30000+pageIndex;
    [scroll_View addSubview:detailView];
    [scroll_View setContentSize:CGSizeMake(320*[allPhotoDemoArray count], allHeight)];
}

-(void)showIndexTag:(NSInteger)indexTag
{
    if([allPhotoDemoArray count]<=3)
    {
        for(int i =0;i<[allPhotoDemoArray count];i++)
        {
            PhohoDemo *demo = (PhohoDemo *)[allPhotoDemoArray objectAtIndex:i];
            DownImage *downImage = [[[DownImage alloc] init] autorelease];
            [downImage setFileId:demo.f_id];
            [downImage setImageUrl:demo.f_name];
            [downImage setImageViewIndex:imageTag+i];
            [downImage setDelegate:self];
            [downImage startDownload];
        }
    }
    else if(indexTag==0)
    {
        for(int i =0;i<3;i++)
        {
            PhohoDemo *demo = (PhohoDemo *)[allPhotoDemoArray objectAtIndex:i];
            DownImage *downImage = [[[DownImage alloc] init] autorelease];
            [downImage setFileId:demo.f_id];
            [downImage setImageUrl:demo.f_name];
            [downImage setImageViewIndex:imageTag+i];
            [downImage setDelegate:self];
            [downImage startDownload];
        }
    }
    else if(indexTag+1==[allPhotoDemoArray count])
    {
        for(int i =indexTag-2;i<indexTag+1;i++)
        {
            PhohoDemo *demo = (PhohoDemo *)[allPhotoDemoArray objectAtIndex:i];
            DownImage *downImage = [[[DownImage alloc] init] autorelease];
            [downImage setFileId:demo.f_id];
            [downImage setImageUrl:demo.f_name];
            [downImage setImageViewIndex:imageTag+i];
            [downImage setDelegate:self];
            [downImage startDownload];
        }
    }
    else if(indexTag+1<[allPhotoDemoArray count]&&indexTag>0)
    {
        for(int i =indexTag-1;i<indexTag+2;i++)
        {
            PhohoDemo *demo = (PhohoDemo *)[allPhotoDemoArray objectAtIndex:i];
            DownImage *downImage = [[[DownImage alloc] init] autorelease];
            [downImage setFileId:demo.f_id];
            [downImage setImageUrl:demo.f_name];
            [downImage setImageViewIndex:imageTag+i];
            [downImage setDelegate:self];
            [downImage startDownload];
        }
    }
}

#pragma mark 下载完成后的回调方法
-(void)appImageDidLoad:(NSInteger)indexTag urlImage:image
{
    UIImageView *imageView = (UIImageView *)[scroll_View viewWithTag:indexTag];
    UIImage *imageOk = image;
    CGSize imageSize = imageOk.size;
    CGRect imageRect = imageView.frame;
    int x = 0;
    int y = 0;
    //iphone5
    if(imageSize.height == imageSize.width)
    {
        if(imageSize.width<=320)
        {
            imageSize.width = imageSize.width;
            imageSize.height = imageSize.height;
            x = (320-imageSize.width)/2;
            y = (allHeight-imageSize.height)/2;
        }
        else
        {
            imageSize.width = 320;
            imageSize.height = 320;
            y = (allHeight-imageSize.height)/2;
        }
    }
    else if(imageSize.height>imageSize.width)
    {
        if(imageSize.height>=allHeight)
        {
            imageSize.width = imageSize.width*allHeight/imageSize.height;
            imageSize.height = allHeight;
            if(imageSize.width<=320)
            {
                x = (320-imageSize.width)/2;
            }
            else
            {
                imageSize.height = 320*imageSize.height/imageSize.width;
                imageSize.width = 320;
                y = (allHeight-imageSize.height)/2;
            }
        }
        else if(imageSize.width>320)
        {
            imageSize.height = 320*imageSize.height/imageSize.width;
            imageSize.width = 320;
            y = (allHeight-imageSize.height)/2;
        }
        else
        {
            x = (320-imageSize.width)/2;
            y = (allHeight-imageSize.height)/2;
        }
            
    }
    else
    {
        imageSize.height = 320*imageSize.height/imageSize.width;
        imageSize.width = 320;
        y = (allHeight-imageSize.height)/2;
    }
    imageRect.origin.x = x;
    imageRect.origin.y = y;
    imageRect.size.width = imageSize.width;
    imageRect.size.height = imageSize.height;
    [imageView setFrame:imageRect];
    [imageView setImage:image];
}

#pragma mark 按钮返回事件
-(void)backClick
{
    [self dismissViewControllerAnimated:YES completion:^{}];
}

#pragma mrak 双击放大事件
-(void)multipleTap:(id)sender withEvent:(UIEvent*)event {
    
    UITouch* touch = [[event allTouches] anyObject];
    UIButton *button = sender;
    PhotoDetailView *detailView = (PhotoDetailView *)[scroll_View viewWithTag:30000+(button.tag-20000)];
    if (touch.tapCount == 2)
    {
        CGRect bgRect = detailView.bgImageView.frame;
        if(bgRect.size.width>500)
        {
            [self appImageDidLoad:detailView.bgImageView.tag urlImage:detailView.bgImageView.image];
        }
        else
        {
            CGPoint point = detailView.bgImageView.center;
            bgRect.origin.x = 0;
            bgRect.origin.y = 0;
            bgRect.size.width = bgRect.size.width*2;
            bgRect.size.height = bgRect.size.height*2;
            [detailView.bgImageView setFrame:bgRect];
            [detailView.bgImageView setCenter:point];
        }
    }
    else if(touch.tapCount ==1)
    {
        
        if(detailView.topButton.hidden)
        {
            [detailView showNewview];
        }
        else
        {
            [detailView hiddenNewview];
        }
    }
}

- (void)scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate
{
	int page = scrollView.contentOffset.x/320;
    [self showIndexTag:page];
}

#pragma mark 删除按钮
-(void)deleteClicked:(id)sender
{
    UIButton *button = sender;
    PhotoDetailView *detailView = (PhotoDetailView *)[scroll_View viewWithTag:30000+(button.tag-40000)];
    
}

@end
