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

@interface PhotoDetailViewController ()

@end

@implementation PhotoDetailViewController
@synthesize scroll_View;
@synthesize topBar,bottonBar,pageLabel;
@synthesize deleteDelegate;
@synthesize timeLine;
@synthesize photo_dictionary;
@synthesize hud;

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
    [self.navigationController.navigationBar setHidden:YES];
    [self hideTabBar:YES];
    
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
    
    //添加头部试图
    CGRect topRect = CGRectMake(0, 0, 320, 44);
    topBar = [[UINavigationBar alloc] initWithFrame:topRect];
    [self.view addSubview:topBar];
    CGRect backRect = CGRectMake(7, 7, 70, 30);
    UIButton *backButton = [[UIButton alloc] initWithFrame:backRect];
    //    [backButton setBackgroundImage:[UIImage imageNamed:@"Selected.png"] forState:UIControlStateNormal];
    [backButton setTitle:@"返回" forState:UIControlStateNormal];
    [backButton addTarget:self action:@selector(backClick:) forControlEvents:UIControlEventTouchUpInside];
    [backButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [topBar addSubview:backButton];
    [topBar setAlpha:0.7];
    [backButton release];
    
    CGRect pageRect = CGRectMake(130, 12, 60, 20);
    pageLabel = [[UILabel alloc] initWithFrame:pageRect];
    [pageLabel setBackgroundColor:[UIColor clearColor]];
    [pageLabel setTextColor:[UIColor whiteColor]];
    [pageLabel setTextAlignment:NSTextAlignmentCenter];
    [topBar addSubview:pageLabel];
    
    //添加底部试图
    CGRect bottonRect = CGRectMake(0, allHeight-44, 320, 44);
    bottonBar = [[UINavigationBar alloc] initWithFrame:bottonRect];
    [self.view addSubview:bottonBar];
    [bottonBar setAlpha:0.7];
    
    CGRect bottonImageRect = CGRectMake(0, 0, 320, 44);
    UIImageView *bottonImage = [[UIImageView alloc] initWithFrame:bottonImageRect];
    //    [bottonImage setImage:[UIImage imageNamed:@"Selected.png"]];
    [bottonBar addSubview:bottonImage];
    [bottonImage release];
    
    CGRect leftRect = CGRectMake(36, 5, 35, 33);
    UIButton *leftButton = [[UIButton alloc] initWithFrame:leftRect];
    [leftButton.titleLabel setFont:[UIFont systemFontOfSize:14]];
    [leftButton.titleLabel setTextColor:[UIColor blackColor]];
    //    [leftButton setBackgroundImage:[UIImage imageNamed:@"Selected.png"] forState:UIControlStateNormal];
    [leftButton addTarget:self action:@selector(clipClicked:) forControlEvents:UIControlEventTouchUpInside];
    [leftButton setTitle:@"收藏" forState:UIControlStateNormal];
    [leftButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [leftButton setBackgroundColor:[UIColor clearColor]];
    [bottonBar addSubview:leftButton];
    [leftButton release];
    
    CGRect centerRect = CGRectMake(107+36, 5, 35, 33);
    UIButton *centerButton = [[UIButton alloc] initWithFrame:centerRect];
    [centerButton.titleLabel setFont:[UIFont systemFontOfSize:14]];
    [centerButton.titleLabel setTextColor:[UIColor blackColor]];
    [centerButton addTarget:self action:@selector(shareClicked:) forControlEvents:UIControlEventTouchUpInside];
    //    [centerButton setBackgroundImage:[UIImage imageNamed:@"Selected.png"] forState:UIControlStateNormal];
    [centerButton setTitle:@"分享" forState:UIControlStateNormal];
    [centerButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [centerButton setBackgroundColor:[UIColor clearColor]];
    [bottonBar addSubview:centerButton];
    
    CGRect rightRect = CGRectMake(213+36, 5, 35, 33);
    UIButton *rightButton = [[UIButton alloc] initWithFrame:rightRect];
    [rightButton.titleLabel setFont:[UIFont systemFontOfSize:14]];
    [rightButton.titleLabel setTextColor:[UIColor blackColor]];
    [rightButton addTarget:self action:@selector(deleteClicked:) forControlEvents:UIControlEventTouchUpInside];
    //    [rightButton setBackgroundImage:[UIImage imageNamed:@"Selected.png"] forState:UIControlStateNormal];
    [rightButton setTitle:@"删除" forState:UIControlStateNormal];
    [rightButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [rightButton setBackgroundColor:[UIColor clearColor]];
    [bottonBar addSubview:rightButton];
    
    [self.topBar setHidden:YES];
    [self.bottonBar setHidden:YES];
    
    hud = [[MBProgressHUD alloc] initWithView:self.view];
    [self.view addSubview:hud];
    [super viewDidLoad];
}

- (void) hideTabBar:(BOOL) hidden
{
    [UIView beginAnimations:nil context:NULL];
    [UIView setAnimationDuration:0];
}

-(void)dealloc
{
    [scroll_View release];
    [topBar release];
    [bottonBar release];
    [pageLabel release];
    [timeLine release];
    [hud release];
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
    }
    [scroll_View setContentOffset:CGPointMake(320*indexTag, 0) animated:NO];
    //页数
    [self.pageLabel setText:[NSString stringWithFormat:@"%i/%i",indexTag+1,[allPhotoDemoArray count]]];
    
    CGSize maximumLabelSize = CGSizeMake(2000,20);
    CGSize expectedLabelSize = [self.pageLabel.text sizeWithFont:self.pageLabel.font
                                       constrainedToSize:maximumLabelSize
                                           lineBreakMode:self.pageLabel.lineBreakMode];//假定label_1的字体确定，自适应宽
    CGRect pageRect = self.pageLabel.frame;
    pageRect.origin.x = (320-expectedLabelSize.width)/2;
    pageRect.size.width = expectedLabelSize.width;
    [self.pageLabel setFrame:pageRect];
    [self showIndexTag:indexTag];
    [scroll_View setDelegate:self];
}

#pragma mark 添加图片
-(void)addCenterImageView:(PhohoDemo *)demo currPage:(NSInteger)pageIndex totalCount:(NSInteger)count
{
    CGRect detailRect =  CGRectMake(320*pageIndex, 0, 320, allHeight);
    PhotoDetailView *detailView = [[[PhotoDetailView alloc] initWithFrame:detailRect] autorelease];
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
    [scroll_View setContentSize:CGSizeMake(320*[allPhotoDemoArray count], allHeight)];
}

#pragma mark 滑动隐藏
-(void)scrollViewDidScroll:(UIScrollView *)scrollView
{
    if(!topBar.hidden)
    {
        [self.topBar setHidden:YES];
        [self.bottonBar setHidden:YES];
    }
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
            PhohoDemo *demo = nil;
            if([[allPhotoDemoArray objectAtIndex:i] isKindOfClass:[NSString class]])
            {
                demo = (PhohoDemo *)[photo_dictionary objectForKey:[allPhotoDemoArray objectAtIndex:i]];
            }
            else if([[allPhotoDemoArray objectAtIndex:i] isKindOfClass:[PhohoDemo class]])
            {
                demo = [allPhotoDemoArray objectAtIndex:i];
            }
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
            PhohoDemo *demo = nil;
            if([[allPhotoDemoArray objectAtIndex:i] isKindOfClass:[NSString class]])
            {
                demo = (PhohoDemo *)[photo_dictionary objectForKey:[allPhotoDemoArray objectAtIndex:i]];
            }
            else if([[allPhotoDemoArray objectAtIndex:i] isKindOfClass:[PhohoDemo class]])
            {
                demo = [allPhotoDemoArray objectAtIndex:i];
            }
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
            PhohoDemo *demo = nil;
            if([[allPhotoDemoArray objectAtIndex:i] isKindOfClass:[NSString class]])
            {
                demo = (PhohoDemo *)[photo_dictionary objectForKey:[allPhotoDemoArray objectAtIndex:i]];
            }
            else if([[allPhotoDemoArray objectAtIndex:i] isKindOfClass:[PhohoDemo class]])
            {
                demo = [allPhotoDemoArray objectAtIndex:i];
            }
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
    [self dismissViewControllerAnimated:YES completion:^{}];
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
        if(topBar.hidden)
        {
            [self.pageLabel setText:[NSString stringWithFormat:@"%i/%i",button.tag%20000+1,[allPhotoDemoArray count]]];
            [self.topBar setHidden:NO];
            [self.bottonBar setHidden:NO];
        }
        else
        {
            [self.topBar setHidden:YES];
            [self.bottonBar setHidden:YES];
        }
    }
}

- (void)scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate
{
	int page = scrollView.contentOffset.x/320;
    [self showIndexTag:page];
}

#pragma mark 收藏按钮事件
-(void)clipClicked:(id)sender
{
    int page = [[[pageLabel.text componentsSeparatedByString:@"/"] objectAtIndex:0] intValue]-1;
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
    if ([[FavoritesData sharedFavoritesData].favoriteDic objectForKey:f_id]) {
        hud.labelText=@"图片已经收藏过";
        hud.mode=MBProgressHUDModeText;
        [hud show:YES];
        [self.hud hide:YES afterDelay:0.5f];
    }
    else
    {
        NSMutableDictionary *dic = [[NSMutableDictionary alloc] init];
        [dic setObject:demo.f_name forKey:@"f_name"];
        [dic setObject:[NSNumber numberWithInteger:demo.f_size] forKey:@"f_size"];
        [dic setObject:[NSNumber numberWithInteger:demo.f_id] forKey:@"f_id"];
        [dic setObject:demo.f_create forKey:@"f_create"];
        [dic setObject:demo.f_mime forKey:@"f_mime"];
        [dic setObject:demo.f_pids forKey:@"pids"];
        [dic setObject:demo.f_name forKey:@"f_modify"];
        [dic setObject:demo.f_owername forKey:@"f_owner_name"];
        [dic setObject:demo.compressaddr forKey:@"compressaddr"];
        [dic setObject:[NSNumber numberWithInteger:demo.f_ownerid] forKey:@"f_ownerid"];
        [[FavoritesData sharedFavoritesData] setObject:dic forKey:f_id];
        NSLog(@"%@",[FavoritesData sharedFavoritesData].favoriteDic);
        NSLog(@"增加一个收藏，收藏总数: %d",[[FavoritesData sharedFavoritesData] count]);
        hud.labelText=@"收藏成功";
        hud.mode=MBProgressHUDModeText;
        [hud show:YES];
        [self.hud hide:YES afterDelay:0.5f];
    }
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
    int page = [[[pageLabel.text componentsSeparatedByString:@"/"] objectAtIndex:0] intValue]-1;
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
            [app_delegate sendImageContentIsFiends:YES path:demo.f_name];
        }
    }
    if(buttonIndex == 1)
    {
        if([app_delegate respondsToSelector:@selector(sendImageContentIsFiends:path:)])
        {
            //微信好友
            [app_delegate sendImageContentIsFiends:NO path:demo.f_name];
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
        int page = [[[pageLabel.text componentsSeparatedByString:@"/"] objectAtIndex:0] intValue]-1;
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
//        [hud show:YES];
        [self.hud hide:YES afterDelay:0.5f];
        
        [scroll_View removeFromSuperview];
        [scroll_View release];
        //创建滚动条
        CGRect scrollRect = CGRectMake(0, 0, 320, allHeight);
        scroll_View = [[UIScrollView alloc] initWithFrame:scrollRect];
        [scroll_View setPagingEnabled:YES];
        [scroll_View setScrollEnabled:YES];
        [self.view addSubview:scroll_View];
        [self.view bringSubviewToFront:self.topBar];
        [self.view bringSubviewToFront:self.bottonBar];
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
    if(allPhotoDemoArray == 0)
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
        else
        {
//            [self dismissViewControllerAnimated:YES completion:^{}];
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
