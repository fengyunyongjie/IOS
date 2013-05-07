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
@synthesize scrollView;

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
    CGRect scrollRect = CGRectMake(0, 0, 320, allHeight);
    scrollView = [[UIScrollView alloc] initWithFrame:scrollRect];
    [scrollView setPagingEnabled:YES];
    [self.view addSubview:scrollView];
    [self.view setBackgroundColor:[UIColor whiteColor]];
    [super viewDidLoad];
	// Do any additional setup after loading the view.
}

-(void)dealloc
{
    [scrollView release];
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
    for(int i=0;i<[allArray count];i++)
    {
        PhohoDemo *demo = (PhohoDemo *)[allArray objectAtIndex:i];
        CGRect detailRect =  CGRectMake(320*i, 0, 320, allHeight);
        PhotoDetailView *detailView = [[[PhotoDetailView alloc] initWithFrame:detailRect] autorelease];
        //设置返回按钮
        [detailView.topButton setTitle:@"返回" forState:UIControlStateNormal];
        [detailView.topButton addTarget:self action:@selector(backClick) forControlEvents:UIControlEventTouchUpInside ];
        //页数
        [detailView.pagLabel setText:[NSString stringWithFormat:@"%i/%i",i+1,[allArray count]]];
        //地址
        [detailView.addressLabel setText:@"蘑菇街"];
        //温度，天气
        [detailView.weatherLabel setText:@"23/多云"];
        //当天pm时间
        [detailView.dayTimeLabel setText:@"PM 2.5 38"];
        //分割线
        //日期
        [detailView.dateTimeLabel setText:@"2013/5/7 12:00"];
        //拍摄设备
        [detailView.clientLabel setText:@"iPhone5"];
        //分享，下载，删除，三个按钮
        [detailView.leftButton.titleLabel setText:@"分享"];
        [detailView.leftButton setBackgroundColor:[UIColor redColor]];
//        [detailView.centerButton.titleLabel setText:@"下载"];
//        [detailView.leftButton setBackgroundColor:[UIColor yellowColor]];
//        [detailView.rightButton.titleLabel setText:@"删除"];
//        [detailView.leftButton setBackgroundColor:[UIColor blueColor]];
        [scrollView addSubview:detailView];
        int indexTag = 10000;
        detailView.bgImageView.tag = indexTag+i;
        DownImage *downImage = [[[DownImage alloc] init] autorelease];
        [downImage setFileId:demo.f_id];
        [downImage setImageUrl:demo.f_name];
        [downImage setImageViewIndex:indexTag+i];
        [downImage setDelegate:self];
        [downImage startDownload];
//        detailView
    }
    [scrollView setContentSize:CGSizeMake(320*[allArray count], allHeight)];
    [scrollView setContentOffset:CGPointMake(320*indexTag, 0) animated:NO];
}

#pragma mark 下载完成后的回调方法
-(void)appImageDidLoad:(NSInteger)indexTag urlImage:image
{
    UIImageView *imageView = (UIImageView *)[scrollView viewWithTag:indexTag];
    UIImage *imageOk = image;
    CGSize imageSize = imageOk.size;
    CGRect imageRect = imageView.frame;
    //iphone5
    if(imageSize.height>allHeight)
    {
        imageRect.size.width = imageSize.width*allHeight/imageSize.height;
        imageRect.size.height = allHeight;
    }
    if(imageSize.width > 320)
    {
        imageRect.size.height = imageSize.height*320/imageSize.width;
        imageRect.size.width = 320;
    }
    imageRect.origin.y = (allHeight-imageRect.size.height)/2;
    [imageView setFrame:imageRect];
    [imageView setImage:image];
    
}

#pragma mark 按钮返回事件
-(void)backClick
{
    [self dismissViewControllerAnimated:YES completion:^{}];
}

@end
