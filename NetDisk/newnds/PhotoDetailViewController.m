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
#import "AppDelegate.h"
#import "FavoritesData.h"
#import "PhotoFile.h"
#import "YNFunctions.h"

@interface PhotoDetailViewController ()

@end

@implementation PhotoDetailViewController
@synthesize scroll_View;
@synthesize deleteDelegate;
@synthesize timeLine;
@synthesize photo_dictionary;
@synthesize hud;
@synthesize isCliped;
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
//    [self.navigationController.navigationBar setHidden:YES];
    
    
    //初始化基本数据
    allHeight = self.view.frame.size.height;
    imageTag = 10000;
    
    //创建滚动条
    CGRect scrollRect = CGRectMake(0, 0, 320, allHeight);
    scroll_View = [[UIScrollView alloc] initWithFrame:scrollRect];
    [scroll_View setPagingEnabled:YES];
    [scroll_View setScrollEnabled:YES];
    [self.view addSubview:scroll_View];
    
    //设置背景为黑色
    [self.view setBackgroundColor:[UIColor blackColor]];
    
//    //添加头部视图
//    CGRect topRect = CGRectMake(0, 0, 320, 44);
//    topToolBar = [[UIToolbar alloc] initWithFrame:topRect];
//    [topToolBar setBarStyle:UIBarStyleBlackTranslucent];
//    UIImage *imageS = [UIImage imageNamed:@"CustBack.png"];
//    imageS = [self scaleFromImage:imageS toSize:CGSizeMake(25*imageS.size.width/imageS.size.height, 25)];
//    UIBarButtonItem *leftButton1 = self.navigationItem.backBarButtonItem;
//    NSArray *topArray = [[NSArray alloc] initWithObjects:leftButton1, nil];
//    [leftButton1 release];
//    [topToolBar setItems:topArray];
//    [topArray release];
//
//    CGRect pageRect = CGRectMake(130, 12, 60, 20);
//    pageLabel = [[UILabel alloc] initWithFrame:pageRect];
//    [pageLabel setBackgroundColor:[UIColor clearColor]];
//    [pageLabel setTextColor:[UIColor whiteColor]];
//    [pageLabel setTextAlignment:NSTextAlignmentCenter];
//    [topToolBar addSubview:pageLabel];
//    [self.view addSubview:topToolBar];
    
    //添加底部试图
    CGRect bottonRect = CGRectMake(0, allHeight-44, 320, 44);
    bottonToolBar = [[UIToolbar alloc] initWithFrame:bottonRect];
    [bottonToolBar setBarStyle:UIBarStyleBlackTranslucent];
    
    
    CGRect leftRect = CGRectMake(36, 5, 35, 33);
    leftButton = [[UIButton alloc] initWithFrame:leftRect];
    [leftButton.titleLabel setFont:[UIFont systemFontOfSize:14]];
    [leftButton.titleLabel setTextColor:[UIColor blackColor]];
    [leftButton addTarget:self action:@selector(clipClicked:) forControlEvents:UIControlEventTouchUpInside];
    [leftButton setTitle:@"收藏" forState:UIControlStateNormal];
    [leftButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [leftButton setBackgroundColor:[UIColor clearColor]];
    [bottonToolBar addSubview:leftButton];
    leftButton.showsTouchWhenHighlighted = YES;

    CGRect centerRect = CGRectMake(107+36, 5, 35, 33);
    centerButton = [[UIButton alloc] initWithFrame:centerRect];
    [centerButton.titleLabel setFont:[UIFont systemFontOfSize:14]];
    [centerButton.titleLabel setTextColor:[UIColor blackColor]];
    [centerButton addTarget:self action:@selector(shareClicked:) forControlEvents:UIControlEventTouchUpInside];
    [centerButton setTitle:@"分享" forState:UIControlStateNormal];
    [centerButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [centerButton setBackgroundColor:[UIColor clearColor]];
    [bottonToolBar addSubview:centerButton];
    centerButton.showsTouchWhenHighlighted = YES;

    CGRect rightRect = CGRectMake(213+36, 5, 35, 33);
    rightButton = [[UIButton alloc] initWithFrame:rightRect];
    [rightButton.titleLabel setFont:[UIFont systemFontOfSize:14]];
    [rightButton.titleLabel setTextColor:[UIColor blackColor]];
    [rightButton addTarget:self action:@selector(deleteClicked:) forControlEvents:UIControlEventTouchUpInside];
    [rightButton setTitle:@"删除" forState:UIControlStateNormal];
    [rightButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [rightButton setBackgroundColor:[UIColor clearColor]];
    rightButton.showsTouchWhenHighlighted = YES;
    [bottonToolBar addSubview:rightButton];
    
    [self.view addSubview:bottonToolBar];
    
    [self.navigationController.navigationBar setBarStyle:UIBarStyleBlackTranslucent];
    [self.navigationController setNavigationBarHidden:YES];
    [bottonToolBar setHidden:YES];
    
//    //添加头部试图
//    CGRect topRect = CGRectMake(0, 0, 320, 44);
//    topBar = [[UINavigationBar alloc] initWithFrame:topRect];
//    [self.view addSubview:topBar];
//    CGRect backRect = CGRectMake(7, 7, 70, 30);
//    
//    UIButton *backButton = [[UIButton alloc] initWithFrame:backRect];
//    //    [backButton setBackgroundImage:[UIImage imageNamed:@"Selected.png"] forState:UIControlStateNormal];
//    [backButton setTitle:@"返回" forState:UIControlStateNormal];
//    [backButton addTarget:self action:@selector(backClick:) forControlEvents:UIControlEventTouchUpInside];
//    [backButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
//    [topBar addSubview:backButton];
//    [topBar setAlpha:0.7];
//    [backButton release];
//    
//    CGRect pageRect = CGRectMake(130, 12, 60, 20);
//    pageLabel = [[UILabel alloc] initWithFrame:pageRect];
//    [pageLabel setBackgroundColor:[UIColor clearColor]];
//    [pageLabel setTextColor:[UIColor whiteColor]];
//    [pageLabel setTextAlignment:NSTextAlignmentCenter];
//    [topBar addSubview:pageLabel];
//    
//    //添加底部试图
//    CGRect bottonRect = CGRectMake(0, allHeight-44, 320, 44);
//    bottonBar = [[UINavigationBar alloc] initWithFrame:bottonRect];
//    [self.view addSubview:bottonBar];
//    [bottonBar setAlpha:0.7];
//    
//    CGRect bottonImageRect = CGRectMake(0, 0, 320, 44);
//    UIImageView *bottonImage = [[UIImageView alloc] initWithFrame:bottonImageRect];
//    //    [bottonImage setImage:[UIImage imageNamed:@"Selected.png"]];
//    [bottonBar addSubview:bottonImage];
//    [bottonImage release];
//    
//    UIToolbar *toolBar = [[UIToolbar alloc] initWithFrame:CGRectMake(0, allHeight-49, 320, 49)];
//    [toolBar setBarStyle:UIBarStyleBlackTranslucent];
//    NSMutableArray *array = [[NSMutableArray alloc] init];
//    UIBarButtonItem *leftButtons = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemEdit target:self action:@selector(right_button_cilcked:)];;
//    [array addObject:leftButtons];
//    [leftButtons release];
//    [toolBar setItems:array];
//    [self.view addSubview:toolBar];
//    [array release];
//    
//    CGRect leftRect = CGRectMake(36, 5, 35, 33);
//    leftButton = [[UIButton alloc] initWithFrame:leftRect];
//    [leftButton.titleLabel setFont:[UIFont systemFontOfSize:14]];
//    [leftButton.titleLabel setTextColor:[UIColor blackColor]];
//    //    [leftButton setBackgroundImage:[UIImage imageNamed:@"Selected.png"] forState:UIControlStateNormal];
//    [leftButton addTarget:self action:@selector(clipClicked:) forControlEvents:UIControlEventTouchUpInside];
//    [leftButton setTitle:@"收藏" forState:UIControlStateNormal];
//    [leftButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
//    [leftButton setBackgroundColor:[UIColor clearColor]];
//    [bottonBar addSubview:leftButton];
//    [leftButton release];
//    
//    CGRect centerRect = CGRectMake(107+36, 5, 35, 33);
//    centerButton = [[UIButton alloc] initWithFrame:centerRect];
//    [centerButton.titleLabel setFont:[UIFont systemFontOfSize:14]];
//    [centerButton.titleLabel setTextColor:[UIColor blackColor]];
//    [centerButton addTarget:self action:@selector(shareClicked:) forControlEvents:UIControlEventTouchUpInside];
//    //    [centerButton setBackgroundImage:[UIImage imageNamed:@"Selected.png"] forState:UIControlStateNormal];
//    [centerButton setTitle:@"分享" forState:UIControlStateNormal];
//    [centerButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
//    [centerButton setBackgroundColor:[UIColor clearColor]];
//    [bottonBar addSubview:centerButton];
//    
//    CGRect rightRect = CGRectMake(213+36, 5, 35, 33);
//    rightButton = [[UIButton alloc] initWithFrame:rightRect];
//    [rightButton.titleLabel setFont:[UIFont systemFontOfSize:14]];
//    [rightButton.titleLabel setTextColor:[UIColor blackColor]];
//    [rightButton addTarget:self action:@selector(deleteClicked:) forControlEvents:UIControlEventTouchUpInside];
//    //    [rightButton setBackgroundImage:[UIImage imageNamed:@"Selected.png"] forState:UIControlStateNormal];
//    [rightButton setTitle:@"删除" forState:UIControlStateNormal];
//    [rightButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
//    [rightButton setBackgroundColor:[UIColor clearColor]];
//    [bottonBar addSubview:rightButton];
    
    
    [super viewDidLoad];
}

-(UIImage *)scaleFromImage:(UIImage *)image toSize:(CGSize)size
{
    UIGraphicsBeginImageContext(size);
    [image drawInRect:CGRectMake(0, 0, size.width, size.height)];
    UIImage *newImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return newImage;
}

- (void) hideTabBar:(BOOL) hidden
{
    [UIView beginAnimations:nil context:NULL];
    MYTabBarController *tabBar = (MYTabBarController *)self.tabBarController;
    [tabBar setHidesTabBarWithAnimate:YES];
    [UIView setAnimationDuration:0];
}

-(void)isHiddenDelete:(BOOL)bl
{
    if(bl)
    {
        CGRect leftRect = CGRectMake((160-100)/2, 5, 100, 33);
        [leftButton setTitle:@"取消收藏" forState:UIControlStateNormal];
        [leftButton.titleLabel setTextAlignment:NSTextAlignmentCenter];
        [leftButton setFrame:leftRect];
        CGRect centerRect = CGRectMake(160+(160-35)/2, 5, 35, 33);
        [centerButton setFrame:centerRect];
        [rightButton setHidden:YES];
    }
    else
    {
        CGRect leftRect = CGRectMake(36, 5, 35, 33);
        [leftButton setTitle:@"收藏" forState:UIControlStateNormal];
        [leftButton setFrame:leftRect];
        CGRect centerRect = CGRectMake(107+36, 5, 35, 33);
        [centerButton setFrame:centerRect];
        [rightButton setHidden:NO];
    }
}

-(void)dealloc
{
    [scroll_View release];
    [timeLine release];
    if(hud != nil)
    {
        [hud release];
    }
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
    NSMutableArray *tables = [[NSMutableArray alloc] init];
    BOOL bl = FALSE;
    for(int i=0;i<[allArray count];i++)
    {
        if([[allArray objectAtIndex:i] isKindOfClass:[NSString class]])
        {
            PhohoDemo *demo = [photo_dictionary objectForKey:[allPhotoDemoArray objectAtIndex:i]];
            [self addCenterImageView:demo currPage:i totalCount:[allPhotoDemoArray count]];
        }
        else if([[allArray objectAtIndex:i] isKindOfClass:[PhohoDemo class]])
        {
            PhohoDemo *demo = [allArray objectAtIndex:i];
            [self addCenterImageView:demo currPage:i totalCount:[allArray count]];
        }
        else if([[allArray objectAtIndex:i] isKindOfClass:[PhotoFile class]])
        {
            bl = TRUE;
            PhotoFile *file = [allArray objectAtIndex:i];
            PhohoDemo *demo = [[PhohoDemo alloc] init];
            demo.f_id = file.f_id;
            demo.f_name = [NSString stringWithFormat:@"%i",file.f_id];
            demo.f_mime = @"png";
            demo.f_create = file.f_date;
            demo.compressaddr = demo.f_name;
            demo.f_pids = @"";
            demo.f_ownerid = 0;
            demo.f_owername = @"";
            demo.f_modify = @"";
            [self addCenterImageView:demo currPage:i totalCount:[allArray count]];
            [tables addObject:demo];
            [demo release];
        }
    }
    if(bl)
    {
        allPhotoDemoArray = [[NSMutableArray alloc] initWithArray:tables];
    }
    [tables release];
    [scroll_View setContentOffset:CGPointMake(320*indexTag, 0) animated:NO];
    //页数
//    [self.pageLabel setText:[NSString stringWithFormat:@"%i/%i",indexTag+1,[allPhotoDemoArray count]]];
    self.navigationItem.title = [NSString stringWithFormat:@"%i/%i",indexTag+1,[allPhotoDemoArray count]];
//    
//    CGSize maximumLabelSize = CGSizeMake(2000,20);
//    CGSize expectedLabelSize = [self.pageLabel.text sizeWithFont:self.pageLabel.font
//                                               constrainedToSize:maximumLabelSize
//                                                   lineBreakMode:self.pageLabel.lineBreakMode];//假定label_1的字体确定，自适应宽
//    CGRect pageRect = self.pageLabel.frame;
//    pageRect.origin.x = (320-expectedLabelSize.width)/2;
//    pageRect.size.width = expectedLabelSize.width;
//    [self.pageLabel setFrame:pageRect];
    [self showIndexTag:indexTag];
    [scroll_View setDelegate:self];
}

#pragma mark 添加图片
-(void)addCenterImageView:(PhohoDemo *)demo currPage:(NSInteger)pageIndex totalCount:(NSInteger)count
{
    CGRect detailRect =  CGRectMake(320*pageIndex, 0, 320, allHeight);
    PhotoDetailView *detailView = [[PhotoDetailView alloc] initWithFrame:detailRect];
    detailView.clickButton.tag = 20000+pageIndex;
    [detailView.clickButton addTarget:self action:@selector(multipleTap:withEvent:) forControlEvents:UIControlEventTouchUpInside];
    
    //    [detailView.clickButton addTarget:self action:@selector(showHidden:) forControlEvents:UIControlEventTouchUpInside];
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
    detailView.rightButton.tag = 40000+pageIndex;
    [detailView.rightButton addTarget:self action:@selector(deleteClicked:) forControlEvents:UIControlEventTouchUpInside];
    [detailView hiddenNewview];
    detailView.bgImageView.tag = imageTag+pageIndex;
    detailView.tag = 30000+pageIndex;
    [detailView setContentSize:CGSizeMake(320, allHeight)];
    [detailView setScrollEnabled:YES];
    [detailView setUserInteractionEnabled:YES];
    
    [scroll_View addSubview:detailView];
    [detailView clearsContextBeforeDrawing];
    [detailView release];
    [scroll_View setContentSize:CGSizeMake(320*[allPhotoDemoArray count], allHeight)];
}




-(void)showIndexTag:(NSInteger)indexTag
{
    if([allPhotoDemoArray count]<=3)
    {
        for(int i =0;i<[allPhotoDemoArray count];i++)
        {
            PhohoDemo *demo = nil;
            if([[allPhotoDemoArray objectAtIndex:i] isKindOfClass:[NSString class]])
            {
                demo = (PhohoDemo *)[photo_dictionary objectForKey:[allPhotoDemoArray objectAtIndex:i]];
            }
            else if([[allPhotoDemoArray objectAtIndex:i] isKindOfClass:[PhohoDemo class]])
            {
                demo = [allPhotoDemoArray objectAtIndex:i];
            }
            DownImage *downImage = [[DownImage alloc] init];
            [downImage setFileId:demo.f_id];
            [downImage setImageUrl:[NSString stringWithFormat:@"%i",demo.f_id]];
            [downImage setImageViewIndex:imageTag+i];
            [downImage setDelegate:self];
            [downImage startDownload];
            [downImage release];
        }
    }
    else if(indexTag==0)
    {
        for(int i =0;i<3;i++)
        {
            PhohoDemo *demo = nil;
            if([[allPhotoDemoArray objectAtIndex:i] isKindOfClass:[NSString class]])
            {
                demo = (PhohoDemo *)[photo_dictionary objectForKey:[allPhotoDemoArray objectAtIndex:i]];
            }
            else if([[allPhotoDemoArray objectAtIndex:i] isKindOfClass:[PhohoDemo class]])
            {
                demo = [allPhotoDemoArray objectAtIndex:i];
            }
            DownImage *downImage = [[DownImage alloc] init];
            [downImage setFileId:demo.f_id];
            [downImage setImageUrl:[NSString stringWithFormat:@"%i",demo.f_id]];
            [downImage setImageViewIndex:imageTag+i];
            [downImage setDelegate:self];
            [downImage startDownload];
            [downImage release];
        }
    }
    else if(indexTag+1==[allPhotoDemoArray count])
    {
        for(int i =indexTag-2;i<indexTag+1;i++)
        {
            PhohoDemo *demo = nil;
            if([[allPhotoDemoArray objectAtIndex:i] isKindOfClass:[NSString class]])
            {
                demo = (PhohoDemo *)[photo_dictionary objectForKey:[allPhotoDemoArray objectAtIndex:i]];
            }
            else if([[allPhotoDemoArray objectAtIndex:i] isKindOfClass:[PhohoDemo class]])
            {
                demo = [allPhotoDemoArray objectAtIndex:i];
            }
            DownImage *downImage = [[DownImage alloc] init];
            [downImage setFileId:demo.f_id];
            [downImage setImageUrl:[NSString stringWithFormat:@"%i",demo.f_id]];
            [downImage setImageViewIndex:imageTag+i];
            [downImage setDelegate:self];
            [downImage startDownload];
            [downImage release];
        }
    }
    else if(indexTag+1<[allPhotoDemoArray count]&&indexTag>0)
    {
        for(int i =indexTag-1;i<indexTag+2;i++)
        {
            PhohoDemo *demo = nil;
            if([[allPhotoDemoArray objectAtIndex:i] isKindOfClass:[NSString class]])
            {
                demo = (PhohoDemo *)[photo_dictionary objectForKey:[allPhotoDemoArray objectAtIndex:i]];
            }
            else if([[allPhotoDemoArray objectAtIndex:i] isKindOfClass:[PhohoDemo class]])
            {
                demo = [allPhotoDemoArray objectAtIndex:i];
            }
            DownImage *downImage = [[DownImage alloc] init];
            [downImage setFileId:demo.f_id];
            [downImage setImageUrl:[NSString stringWithFormat:@"%i",demo.f_id]];
            [downImage setImageViewIndex:imageTag+i];
            [downImage setDelegate:self];
            [downImage startDownload];
            [downImage release];
        }
    }
}

#pragma mark 下载完成后的回调方法
-(void)appImageDidLoad:(NSInteger)indexTag urlImage:image index:(int)index
{
    PhotoDetailView *detailView = (PhotoDetailView *)[scroll_View viewWithTag:30000+(indexTag-10000)];
    [detailView.activity_indicator stopAnimating];
    if(detailView)
    {
        CGRect detailRect = detailView.frame;
        detailRect.size.width = 320;
        detailRect.size.height = allHeight;
        [detailView setFrame:detailRect];
        [detailView setContentSize:CGSizeMake(320, allHeight)];
    }
    
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
-(void)backClick:(id)sender
{
    [scroll_View clearsContextBeforeDrawing];
    [self dismissViewControllerAnimated:YES completion:^{
        
    }];
}

#pragma mrak 手势事件
-(void)multipleTap:(id)sender withEvent:(UIEvent*)event {
    
    UITouch* touch = [[event allTouches] anyObject];
    UIButton *button = sender;
    PhotoDetailView *detailView = (PhotoDetailView *)[scroll_View viewWithTag:30000+(button.tag-20000)];
    if (touch.tapCount == 2)
    {
        //双击放大
        [detailView initImageView];
    }
    else if(touch.tapCount ==1)
    {
        //单击头部和底部出现
        if(bottonToolBar.hidden)
        {
            self.navigationItem.title = [NSString stringWithFormat:@"%i/%i",button.tag%20000+1,[allPhotoDemoArray count]];
            [self.navigationController setNavigationBarHidden:NO];
            [bottonToolBar setHidden:NO];
            
            int page = [[[self.navigationItem.title componentsSeparatedByString:@"/"] objectAtIndex:0] intValue]-1;
            PhohoDemo *demo = nil;
            if([[allPhotoDemoArray objectAtIndex:page] isKindOfClass:[NSString class]])
            {
                demo = (PhohoDemo *)[photo_dictionary objectForKey:[allPhotoDemoArray objectAtIndex:page]];
            }
            else if([[allPhotoDemoArray objectAtIndex:page] isKindOfClass:[PhohoDemo class]])
            {
                demo = [allPhotoDemoArray objectAtIndex:page];
            }
            NSString *f_id = [NSString stringWithFormat:@"%i",demo.f_id];
            if ([[FavoritesData sharedFavoritesData] isExistsWithFID:f_id]) {
                [self isHiddenDelete:YES];
            }
            else
            {   
                [self isHiddenDelete:NO];
            }
        }
        else
        {
            [self.navigationController setNavigationBarHidden:YES];
            [bottonToolBar setHidden:YES];
        }
    }
}

- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView
{
    [scroll_View clearsContextBeforeDrawing];
	int page = scrollView.contentOffset.x/320;
    [self showIndexTag:page];
}

#pragma mark 滑动隐藏
-(void)scrollViewWillBeginDragging:(UIScrollView *)scrollView
{
    [self.navigationController setNavigationBarHidden:YES];
    [bottonToolBar setHidden:YES];
}

#pragma mark 收藏按钮事件
-(void)clipClicked:(id)sender
{
    int page = [[[self.navigationItem.title componentsSeparatedByString:@"/"] objectAtIndex:0] intValue]-1;
    PhohoDemo *demo = nil;
    if([[allPhotoDemoArray objectAtIndex:page] isKindOfClass:[NSString class]])
    {
        demo = (PhohoDemo *)[photo_dictionary objectForKey:[allPhotoDemoArray objectAtIndex:page]];
    }
    else if([[allPhotoDemoArray objectAtIndex:page] isKindOfClass:[PhohoDemo class]])
    {
        demo = [allPhotoDemoArray objectAtIndex:page];
    }
    NSString *f_id = [NSString stringWithFormat:@"%i",demo.f_id];
    if ([[FavoritesData sharedFavoritesData] isExistsWithFID:f_id]) {
        [[FavoritesData sharedFavoritesData] removeObjectForKey:f_id];
        hud = [[MBProgressHUD alloc] initWithView:self.view];
        [self.view addSubview:hud];
        hud.labelText=@"取消收藏成功";
        hud.mode=MBProgressHUDModeText;
        [hud show:YES];
        [hud hide:YES afterDelay:1.0f];
        [hud release];
        hud = nil;
        if(!isCliped)
        {
            [self isHiddenDelete:NO];
        }
        else
        {
            [leftButton setTitle:@"收藏" forState:UIControlStateNormal];
        }
    }
    else
    {
        NSMutableDictionary *dic = [[NSMutableDictionary alloc] init];
        if(demo.f_id)
        {
            [dic setObject:[NSString stringWithFormat:@"%i",demo.f_id] forKey:@"f_name"];
        }
        else
        {
            [dic setObject:@"" forKey:@"f_name"];
        }
        if(demo.f_size)
        {
            [dic setObject:[NSNumber numberWithInteger:demo.f_size] forKey:@"f_size"];
        }
        else
        {
            [dic setObject:@"" forKey:@"f_size"];
        }
        if(demo.f_id)
        {
            [dic setObject:[NSNumber numberWithInteger:demo.f_id] forKey:@"f_id"];
        }
        else
        {
            [dic setObject:@"" forKey:@"f_id"];
        }
        if(demo.f_create)
        {
            [dic setObject:demo.f_create forKey:@"f_create"];
        }
        else
        {
            [dic setObject:@"" forKey:@"f_create"];
        }
        if(demo.f_mime)
        {
            [dic setObject:demo.f_mime forKey:@"f_mime"];
        }
        else
        {
            [dic setObject:@"png" forKey:@"f_mime"];
        }
        if(demo.f_pids)
        {
            [dic setObject:demo.f_pids forKey:@"pids"];
        }
        else
        {
            [dic setObject:@"" forKey:@"pids"];
        }
        if(demo.f_name)
        {
            [dic setObject:demo.f_name forKey:@"f_modify"];
        }
        else
        {
            [dic setObject:@"" forKey:@"f_modify"];
        }
        if(demo.f_owername)
        {
            [dic setObject:demo.f_owername forKey:@"f_owner_name"];
        }
        else
        {
            [dic setObject:@"" forKey:@"f_owner_name"];
        }
        if(demo.f_id)
        {
            [dic setObject:[NSString stringWithFormat:@"%i",demo.f_id] forKey:@"compressaddr"];
        }
        else
        {
            [dic setObject:@"" forKey:@"compressaddr"];
        }
        if(demo.f_ownerid)
        {
            [dic setObject:[NSNumber numberWithInteger:demo.f_ownerid] forKey:@"f_ownerid"];
        }
        else
        {
            [dic setObject:@"" forKey:@"f_ownerid"];
        }
        NSData *f_size = [NSData dataWithContentsOfFile:[self  get_image_save_file_path:[NSString stringWithFormat:@"%i",demo.f_id]]];
        [dic setObject:[NSNumber numberWithInt:[f_size length]] forKey:@"f_size"];
        [[FavoritesData sharedFavoritesData] setObject:dic forKey:f_id];
        NSLog(@"增加一个收藏，收藏总数: %d",[[FavoritesData sharedFavoritesData] count]);
        hud = [[MBProgressHUD alloc] initWithView:self.view];
        [self.view addSubview:hud];
        hud.labelText=@"收藏成功";
        hud.mode=MBProgressHUDModeText;
        [hud show:YES];
        [hud hide:YES afterDelay:1.0f];
        [hud release];
        hud = nil;
        [self isHiddenDelete:YES];
    }
}

//获取图片路径
- (NSString*)get_image_save_file_path:(NSString*)image_path
{
    NSString *documentDir = [YNFunctions getProviewCachePath];
    NSArray *array=[image_path componentsSeparatedByString:@"/"];
    NSString *path=[NSString stringWithFormat:@"%@/%@",documentDir,[array lastObject]];
    return path;
}

#pragma mark 分享按钮事件
-(void)shareClicked:(id)sender
{
    UIActionSheet *actionSheet = [[UIActionSheet alloc] initWithTitle:@"分享到" delegate:self cancelButtonTitle:@"取消" destructiveButtonTitle:@"微信朋友圈" otherButtonTitles:@"微信好友", nil];
    [actionSheet showInView:self.view];
    [actionSheet release];
}

#pragma mark UIActionSheetDelegate
-(void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex
{
    AppDelegate *app_delegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
    int page = [[[self.navigationItem.title componentsSeparatedByString:@"/"] objectAtIndex:0] intValue]-1;
    PhohoDemo *demo = nil;
    if([[allPhotoDemoArray objectAtIndex:page] isKindOfClass:[NSString class]])
    {
        demo = (PhohoDemo *)[photo_dictionary objectForKey:[allPhotoDemoArray objectAtIndex:page]];
    }
    else if([[allPhotoDemoArray objectAtIndex:page] isKindOfClass:[PhohoDemo class]])
    { 
        demo = [allPhotoDemoArray objectAtIndex:page];
    }
    if(buttonIndex == 0)
    {
        if([app_delegate respondsToSelector:@selector(sendImageContentIsFiends:path:)])
        {
        //微信朋友圈
            [app_delegate sendImageContentIsFiends:YES path:[NSString stringWithFormat:@"%i",demo.f_id]];
        }
    }
    if(buttonIndex == 1)
    {
        if([app_delegate respondsToSelector:@selector(sendImageContentIsFiends:path:)])
        {
            //微信好友
            [app_delegate sendImageContentIsFiends:NO path:[NSString stringWithFormat:@"%i",demo.f_id]];
        }
    }
    if(buttonIndex == 2)
    {
        //新浪微博
//        [app_delegate ssoButtonPressed];
    }
    if(buttonIndex == 3)
    {
        
        
    }
}

#pragma mark 删除按钮事件
-(void)deleteClicked:(id)sender
{
    UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"提示" message:@"是否要删除图片" delegate:self cancelButtonTitle:@"取消" otherButtonTitles:@"确认", nil];
    [alertView show];
    [alertView release];
}

#pragma mark UIAalertViewDelegate
-(void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if(buttonIndex == 1)
    {
        int page = [[[self.navigationItem.title componentsSeparatedByString:@"/"] objectAtIndex:0] intValue]-1;
        deletePage = page;
        PhohoDemo *demo = nil;
        if([[allPhotoDemoArray objectAtIndex:page] isKindOfClass:[NSString class]])
        {
            demo = (PhohoDemo *)[photo_dictionary objectForKey:[allPhotoDemoArray objectAtIndex:page]];
        }
        else if([[allPhotoDemoArray objectAtIndex:page] isKindOfClass:[PhohoDemo class]])
        {
            demo = [allPhotoDemoArray objectAtIndex:page];
        }
        SCBPhotoManager *photoManager = [[[SCBPhotoManager alloc] init] autorelease];
        [photoManager setPhotoDelegate:self];
        NSArray *array = [NSArray arrayWithObject:[NSString stringWithFormat:@"%i",demo.f_id]];
        [photoManager requestDeletePhoto:array];
        
        hud = [[MBProgressHUD alloc] initWithView:self.view];
        [self.view addSubview:hud];
        hud.mode=MBProgressHUDModeIndeterminate;
        hud.labelText=@"正在删除";
        [hud show:YES];
    }
}


#pragma mark SCBPhotoDelegate
-(void)requstDelete:(NSDictionary *)dictioinary
{
    if([[dictioinary objectForKey:@"code"] intValue] == 0)
    {
        hud.labelText=@"删除成功";
        hud.mode=MBProgressHUDModeText;
        [hud hide:YES afterDelay:1.0f];
        [hud removeFromSuperview];
        [hud release];
        hud = nil;
        [scroll_View clearsContextBeforeDrawing];
        [scroll_View removeFromSuperview];
        [scroll_View release];
        //创建滚动条
        CGRect scrollRect = CGRectMake(0, 0, 320, allHeight);
        scroll_View = [[UIScrollView alloc] initWithFrame:scrollRect];
        [scroll_View setPagingEnabled:YES];
        [scroll_View setScrollEnabled:YES];
        [self.view addSubview:scroll_View];
        [self.view bringSubviewToFront:self.navigationController.navigationBar];
        [self.view bringSubviewToFront:bottonToolBar];
        [allPhotoDemoArray removeObjectAtIndex:deletePage];
        if(deletePage==0)
        {
            [self loadAllDiction:allPhotoDemoArray currtimeIdexTag:deletePage];
        }
        else
        {
            [self loadAllDiction:allPhotoDemoArray currtimeIdexTag:deletePage-1];
        }
    }
    if([allPhotoDemoArray count] == 0)
    {
        [deleteDelegate  deleteForDeleteArray:-1 timeLine:timeLine];
        [self dismissViewControllerAnimated:YES completion:^{}];
    }
    else
    {
        if([deleteDelegate respondsToSelector:@selector(deleteForDeleteArray:timeLine:)])
        {
            [deleteDelegate  deleteForDeleteArray:deletePage timeLine:timeLine];
        }
    }
}

-(void)getPhotoTiimeLine:(NSDictionary *)dictionary
{
    
}

-(void)getPhotoGeneral:(NSDictionary *)dictionary photoDictioin:(NSMutableDictionary *)photoDic
{
    
}

-(void)getPhotoDetail:(NSDictionary *)dictionary
{
    
}

@end
