//
//  PhotoLookViewController.m
//  NetDisk
//
//  Created by Yangsl on 13-6-5.
//
//

#import "PhotoLookViewController.h"
#import "YNFunctions.h"
#import "AppDelegate.h"
#import "DownList.h"

#define ACTNUMBER 400000
#define ScrollViewTag 100000
#define ImageViewTag 200000
#define kAlertTagMailAddr 72
#define kActionSheetTagShare 74
#define kActionSheetTagDelete 77

@interface PhotoLookViewController ()
@property float scale_;
@end

@implementation PhotoLookViewController
@synthesize imageScrollView;
@synthesize scale_,tableArray;
@synthesize currPage;
@synthesize isHaveDelete;
@synthesize linkManager;
@synthesize selected_id;
@synthesize hud;

//<ios 6.0
- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation
{
    return YES;
}

//>ios 6.0
- (BOOL)shouldAutorotate{
    return YES;
}

- (BOOL)prefersStatusBarHidden
{
    return YES;
}

- (UIStatusBarStyle)preferredStatusBarStyle
{
    return UIStatusBarStyleLightContent;
}

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
    [super viewDidLoad];
    if([[[UIDevice currentDevice] systemVersion] floatValue]<7.0)
    {
        [[UIApplication sharedApplication] setStatusBarHidden:YES];
    }
    else
    {
        [self setNeedsStatusBarAppearanceUpdate];
    }
    
    downArray = [[NSMutableArray alloc] init];
    linkManager = [[SCBLinkManager alloc] init];
    activityDic = [[NSMutableArray alloc] init];
    
    self.view.backgroundColor = [UIColor blackColor];
    self.offset = 0.0;
    scale_ = 1.0;
    if([[[UIDevice currentDevice] systemVersion] floatValue]<7.0)
    {
        ScollviewHeight = self.view.frame.size.height+20;
        ScollviewWidth = self.view.frame.size.width;
    }
    else
    {
        ScollviewHeight = self.view.frame.size.height;
        ScollviewWidth = self.view.frame.size.width;
    }
    currWidth = ScollviewWidth;
    currHeight = ScollviewHeight;
    
    imageScrollView = [[UIScrollView alloc] initWithFrame:self.view.bounds];
    imageScrollView.backgroundColor = [UIColor clearColor];
    imageScrollView.scrollEnabled = YES;
    imageScrollView.pagingEnabled = YES;
    imageScrollView.showsHorizontalScrollIndicator = NO;
    imageScrollView.delegate = self;
    imageScrollView.contentSize = CGSizeMake(320*[tableArray count], ScollviewHeight);
    
    if(currPage==0&&[tableArray count]>=3)
    {
        startPage = 0;
        endPage = currPage+2;
        for (int i = 0; i<currPage+3; i++){
            if(i>=[tableArray count])
            {
                break;
            }
            [self loadPageColoumn:i];
        }
    }
    
    if(currPage==0&&[tableArray count]<=3)
    {
        startPage = 0;
        endPage = [tableArray count]-1;
        for (int i = 0; i<[tableArray count]; i++){
            if(i>=[tableArray count])
            {
                break;
            }
            [self loadPageColoumn:i];
        }
    }
    
    if(currPage>0&&currPage+1<[tableArray count])
    {
        startPage = currPage-1;
        endPage = currPage+1;
        for (int i = currPage-1; i<currPage+2; i++){
            if(i>=[tableArray count])
            {
                break;
            }
            [self loadPageColoumn:i];
        }
    }
    
    if(currPage+1==[tableArray count] && [tableArray count]>=3)
    {
        startPage = currPage-2;
        endPage = currPage-1;
        for (int i = currPage-2; i<=currPage; i++){
            if(i>=[tableArray count])
            {
                break;
            }
            
            [self loadPageColoumn:i];
        }
    }
    
    if(currPage+1==[tableArray count] && [tableArray count]<3)
    {
        startPage = 0;
        endPage = currPage-1;
        for (int i = 0; i<=currPage; i++){
            if(i>=[tableArray count])
            {
                break;
            }
            [self loadPageColoumn:i];
        }
    }
    
    [imageScrollView setContentOffset:CGPointMake(320*currPage, 0) animated:NO];
    [self.view addSubview:imageScrollView];
    
    
    //添加头部试图
    CGRect topRect = CGRectMake(0, 0, 320, 44);
    self.topToolBar = [[UIToolbar alloc] initWithFrame:topRect];
    [self.topToolBar setBarStyle:UIBarStyleBlackTranslucent];
    CGRect topLeftRect = CGRectMake(2, 7, 48, 30);
    self.topLeftButton = [[UIButton alloc] initWithFrame:topLeftRect];
    [self.topLeftButton.titleLabel setFont:[UIFont systemFontOfSize:14]];
    [self.topLeftButton.titleLabel setTextColor:[UIColor blackColor]];
    [self.topLeftButton setTitle:@" 返回" forState:UIControlStateNormal];
    [self.topLeftButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [self.topLeftButton addTarget:self action:@selector(backClick) forControlEvents:UIControlEventTouchUpInside];
    [self.topLeftButton setBackgroundImage:[UIImage imageNamed:@"Back_Normal.png"] forState:UIControlStateNormal];
    [self.topLeftButton setBackgroundColor:[UIColor clearColor]];
    self.topLeftButton.showsTouchWhenHighlighted = YES;
    [self.topToolBar addSubview:self.topLeftButton];
    
    CGRect topTitleRect = CGRectMake(0, 0, 320, 44);
    self.topTitleLabel = [[UILabel alloc] initWithFrame:topTitleRect];
    [self.topTitleLabel setTextColor:[UIColor whiteColor]];
    [self.topTitleLabel setBackgroundColor:[UIColor clearColor]];
    [self.topTitleLabel setText:[NSString stringWithFormat:@"1/%i",[tableArray count]]];
    [self.topTitleLabel setTextAlignment:NSTextAlignmentCenter];
    [self.topToolBar addSubview:self.topTitleLabel];
    
    [self.view addSubview:self.topToolBar];
    
    //添加底部试图
    CGRect bottonRect = CGRectMake(0, ScollviewHeight-44, 320, 44);
    self.bottonToolBar = [[UIToolbar alloc] initWithFrame:bottonRect];
    [self.bottonToolBar setBarStyle:UIBarStyleBlackTranslucent];
    
    if(isHaveDelete)
    {
        int width = (currWidth-36*3)/2;
        
        CGRect leftRect = CGRectMake(36, 5, width, 33);
        self.leftButton = [[UIButton alloc] initWithFrame:leftRect];
        [self.leftButton.titleLabel setFont:[UIFont systemFontOfSize:14]];
        [self.leftButton.titleLabel setTextColor:[UIColor blackColor]];
        [self.leftButton setTitle:@"下载" forState:UIControlStateNormal];
        [self.leftButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        [self.leftButton addTarget:self action:@selector(clipClicked:) forControlEvents:UIControlEventTouchUpInside];
        [self.leftButton setBackgroundColor:[UIColor clearColor]];
        [self.bottonToolBar addSubview:self.leftButton];
        self.leftButton.showsTouchWhenHighlighted = YES;
        
        CGRect rightRect = CGRectMake(width*1+36*2, 5, width, 33);
        self.rightButton = [[UIButton alloc] initWithFrame:rightRect];
        [self.rightButton.titleLabel setFont:[UIFont systemFontOfSize:14]];
        [self.rightButton.titleLabel setTextColor:[UIColor blackColor]];
        [self.rightButton setTitle:@"删除" forState:UIControlStateNormal];
        [self.rightButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        [self.rightButton addTarget:self action:@selector(deleteClicked:) forControlEvents:UIControlEventTouchUpInside];
        [self.rightButton setBackgroundColor:[UIColor clearColor]];
        self.rightButton.showsTouchWhenHighlighted = YES;
        [self.bottonToolBar addSubview:self.rightButton];
    }
    else
    {
        int width = currWidth-36*2;
        
        CGRect leftRect = CGRectMake(36, 5, width, 33);
        self.leftButton = [[UIButton alloc] initWithFrame:leftRect];
        [self.leftButton.titleLabel setFont:[UIFont systemFontOfSize:14]];
        [self.leftButton.titleLabel setTextColor:[UIColor blackColor]];
        [self.leftButton setTitle:@"下载" forState:UIControlStateNormal];
        [self.leftButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        [self.leftButton addTarget:self action:@selector(clipClicked:) forControlEvents:UIControlEventTouchUpInside];
        [self.leftButton setBackgroundColor:[UIColor clearColor]];
        [self.bottonToolBar addSubview:self.leftButton];
        self.leftButton.showsTouchWhenHighlighted = YES;
    }
    [self.view addSubview:self.bottonToolBar];
    
    [self.topToolBar setHidden:YES];
    [self.bottonToolBar setHidden:YES];
}

-(void)backClick
{
    if([[[UIDevice currentDevice] systemVersion] floatValue]<7.0)
    {
        [[UIApplication sharedApplication] setStatusBarHidden:NO];
    }
    [self dismissModalViewControllerAnimated:YES];
    for(int i=0;i<[downArray count];i++)
    {
        LookDownFile *down = [downArray objectAtIndex:i];
        [down cancelDownload];
    }
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void)changeCenter:(id)sender{
    
}

#pragma mark - ScrollView delegate
-(UIView *)viewForZoomingInScrollView:(UIScrollView *)scrollView{
    
    for (UIView *v in scrollView.subviews){
        return v;
    }
    return nil;
}

- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView
{
    self.page = imageScrollView.contentOffset.x/currWidth;
    
    currPage = self.page;
    
    int page = self.page;
    if(page>=[tableArray count])
    {
        return;
    }
    [self loadPageColoumn:page];
}

#pragma mark 滑动隐藏
-(void)scrollViewWillBeginDragging:(UIScrollView *)scrollView
{
    [self.topToolBar setHidden:YES];
    [self.bottonToolBar setHidden:YES];
    
//    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 0), ^{
    
        if(isLoadImage)
        {
            return ;
        }
        
        if(!isLoadImage)
        {
            isLoadImage = TRUE;
        }
        
        if(isLoadImage&&scrollView.contentOffset.x>enFloat)
        {
            for(int i=0;isLoadImage&&i<[imageScrollView.subviews count];i++)
            {
                UIScrollView *s = [imageScrollView.subviews objectAtIndex:i];
                if(s.tag-ScrollViewTag!=self.page && s.tag-ScrollViewTag!=self.page+1 && s.tag-ScrollViewTag!=self.page+2)
                {
                    [s removeFromSuperview];
                    s = nil;
                }
            }
            
            //向右滑动
            DDLogCInfo(@"向右滑动:%i",[imageScrollView.subviews count]);
            //加载数据
            self.page = imageScrollView.contentOffset.x/currWidth;
            int page = self.page;
            for(int i=page;i<page+3;i++)
            {
                if(i>=[tableArray count])
                {
                    break;
                }
                [self loadPageColoumn:i];
            }
        }
        
        if(isLoadImage&&scrollView.contentOffset.x<enFloat)
        {
            for(int i=0;isLoadImage&&i<[imageScrollView.subviews count];i++)
            {
                UIScrollView *s = [imageScrollView.subviews objectAtIndex:i];
                if(s.tag-ScrollViewTag!=self.page && s.tag-ScrollViewTag!=self.page-1 && s.tag-ScrollViewTag!=self.page-2)
                {
                    [s removeFromSuperview];
                    s = nil;
                }
            }
            //向左滑动
            DDLogCInfo(@"向左滑动:%i",[imageScrollView.subviews count]);
            //加载数据
            self.page = imageScrollView.contentOffset.x/currWidth;
            int page = self.page;
            for(int i=page;i>page-3;i--)
            {
                if(i>=[tableArray count])
                {
                    break;
                }
                [self loadPageColoumn:i];
            }
        }
        enFloat = scrollView.contentOffset.x;
        isLoadImage = FALSE;
//    });
}

-(void)scrollViewDidZoom:(UIScrollView *)scrollView{
    UIImageView *imageview = (UIImageView *)[scrollView viewWithTag:ImageViewTag+scrollView.tag-ScrollViewTag];
    CGFloat xcenter = scrollView.center.x , ycenter = scrollView.center.y;
    ycenter = scrollView.contentSize.height > scrollView.frame.size.height ? scrollView.contentSize.height/2 : ycenter;
    
    xcenter = currWidth*(scrollView.tag-ScrollViewTag) + scrollView.contentSize.width > scrollView.frame.size.width ? scrollView.contentSize.width/2: xcenter;
    if(scrollView.contentSize.width<=currWidth)
    {
        xcenter = (currWidth-scrollView.contentSize.width)/2+scrollView.contentSize.width/2;
    }
    if(scrollView.contentSize.height>=currHeight)
    {
        ycenter = scrollView.contentSize.height/2;
    }
    imageview.center = CGPointMake(xcenter, ycenter);
}

#pragma mark 加载符
-(void)loadActivity
{
//    //加载数据
//    int page = imageScrollView.contentOffset.x/320;
//    DownList *demo = [tableArray objectAtIndex:page];
//    if(![[activityDic objectForKey:[NSString stringWithFormat:@"%@",demo.d_name]] isKindOfClass:[DownList class]])
//    {
//        CGRect activityRect = CGRectMake(320*(page-1)+(320-20)/2, (ScollviewHeight-20)/2, 20, 20);
//        UIActivityIndicatorView *activity_indicator = [[UIActivityIndicatorView alloc] initWithFrame:activityRect];
//        [activity_indicator setActivityIndicatorViewStyle:UIActivityIndicatorViewStyleWhite];
//        [activity_indicator startAnimating];
//        [activity_indicator setTag:ACTNUMBER+page];
//        [imageScrollView addSubview:activity_indicator];
//        [activityDic setObject:demo forKey:[NSString stringWithFormat:@"%@",demo.d_name]];
//    }
}

#pragma mark 加载数据
-(void)loadImage
{
    self.page = imageScrollView.contentOffset.x/currWidth;
    //加载数据
    int page = self.page;
    //判断是否加载图片
    if(page-3>=0)
    {
        for(int i=page-1;isLoadImage&&i>page-3;i--)
        {
            if(i>=[tableArray count])
            {
                break;
            }
            DDLogCInfo(@"重新加载：%i",i);
            [self loadPageColoumn:i];
        }
    }
    else
    {
        for(int i=page-1;isLoadImage&&i>0;i--)
        {
            if(i>=[tableArray count])
            {
                break;
            }
            DDLogCInfo(@"重新加载：%i",i);
            [self loadPageColoumn:i];
        }
    }
    
    if(page+3<=[tableArray count])
    {
        for(int i=page;isLoadImage&&i<page+3;i++)
        {
            if(i>=[tableArray count])
            {
                break;
            }
            DDLogCInfo(@"重新加载：%i",i);
            [self loadPageColoumn:i];
        }
    }
    else
    {
        for(int i=page;isLoadImage&&i<[tableArray count];i++)
        {
            if(i>=[tableArray count])
            {
                break;
            }
            DDLogCInfo(@"重新加载：%i",i);
            [self loadPageColoumn:i];
        }
    }
}

-(void)loadPageColoumn:(int)i
{
    UIView *view = [imageScrollView viewWithTag:i+ScrollViewTag];
    if(view)
    {
        return;
    }
    if(self.isScape)
    {
        DownList *demo = [tableArray objectAtIndex:i];
        UITapGestureRecognizer *doubleTap =[[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(handleDoubleTap:)];
        [doubleTap setNumberOfTapsRequired:2];
        UITapGestureRecognizer *onceTap =[[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(handleOnceTap:)];
        [onceTap setNumberOfTapsRequired:1];
        
        UIScrollView *s = [[UIScrollView alloc] init];
        s.backgroundColor = [UIColor clearColor];
        s.showsHorizontalScrollIndicator = NO;
        s.showsVerticalScrollIndicator = NO;
        s.delegate = self;
        s.minimumZoomScale = 1.0;
        s.maximumZoomScale = 3.0;
        s.tag = i+ScrollViewTag;
        [s setZoomScale:1.0];
        
        UIImageView *imageview = [[UIImageView alloc] init];
        imageview.userInteractionEnabled = YES;
        imageview.tag = ImageViewTag+i;
        [imageview addGestureRecognizer:doubleTap];
        
        __block BOOL isAction = FALSE;
        [s addGestureRecognizer:onceTap];
        UIImage *oldImge = nil;
        
        NSString *documentDir = [YNFunctions getFMCachePath];
        NSArray *array=[demo.d_name componentsSeparatedByString:@"/"];
        NSString *createPath = [NSString stringWithFormat:@"%@/%@",documentDir,demo.d_file_id];
        [NSString CreatePath:createPath];
        NSString *url_path = [NSString stringWithFormat:@"%@/%@",createPath,[array lastObject]];
        if([NSString image_exists_FM_file_path:url_path])
        {
            oldImge = [UIImage imageWithContentsOfFile:url_path];
        }
        else
        {
            AppDelegate *app_delegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
            documentDir = [YNFunctions getProviewCachePath];
            
            createPath = [NSString stringWithFormat:@"%@/%@",documentDir,demo.d_file_id];
            [NSString CreatePath:createPath];
            url_path = [NSString stringWithFormat:@"%@/%@",createPath,[array lastObject]];
            if([NSString image_exists_FM_file_path:url_path])
            {
                oldImge = [UIImage imageWithContentsOfFile:url_path];
            }
            else if(!app_delegate.isConnection)
            {
                oldImge = [UIImage imageNamed:@"pic_err.png"];
            }
            if(!oldImge)
            {
                NSString *fthumb=[NSString formatNSStringForOjbect:demo.d_thumbUrl];
                NSString *localThumbPath=[YNFunctions getIconCachePath];
                fthumb =[YNFunctions picFileNameFromURL:fthumb];
                url_path=[localThumbPath stringByAppendingPathComponent:fthumb];
                oldImge = [UIImage imageWithContentsOfFile:url_path];
                isAction = YES;
                LookDownFile *downImage = [[LookDownFile alloc] init];
                [downImage setFile_id:demo.d_file_id];
                [downImage setFileName:demo.d_name];
                [downImage setImageViewIndex:ImageViewTag+i];
                [downImage setIndexPath:[NSIndexPath indexPathForRow:ACTNUMBER+i inSection:0]];
                [downImage setDelegate:self];
                [downImage startDownload];
                [downArray addObject:downImage];
            }
        }
        CGSize size = [self getSacpeImageSize:oldImge];
        imageview.image = oldImge;
        
        [s setFrame:CGRectMake(currWidth*i, 0, currWidth, 320)];
        CGRect imageFrame = imageview.frame;
        imageFrame.origin = CGPointMake((currWidth-size.width)/2, (currHeight-size.height)/2);
        imageFrame.size = size;
        imageview.contentMode = UIViewContentModeScaleAspectFit;
        [imageview setFrame:imageFrame];
        [s addSubview:imageview];
        [s setContentSize:size];
        if(isAction)
        {
            CGRect activityRect = CGRectMake((currWidth-20)/2, (currHeight-20)/2, 20, 20);
            UIActivityIndicatorView *activity_indicator = [[UIActivityIndicatorView alloc] initWithFrame:activityRect];
            [activity_indicator setActivityIndicatorViewStyle:UIActivityIndicatorViewStyleWhite];
            [activity_indicator setTag:ACTNUMBER+i];
            
            [s addSubview:activity_indicator];
            [activity_indicator startAnimating];
            [activityDic addObject:activity_indicator];
        }
        [imageScrollView addSubview:s];
    }
    else
    {
        DownList *demo = [tableArray objectAtIndex:i];
        UITapGestureRecognizer *doubleTap =[[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(handleDoubleTap:)];
        [doubleTap setNumberOfTapsRequired:2];
        UITapGestureRecognizer *onceTap =[[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(handleOnceTap:)];
        [onceTap setNumberOfTapsRequired:1];
        
        UIScrollView *s = [[UIScrollView alloc] init];
        s.backgroundColor = [UIColor clearColor];
        s.showsHorizontalScrollIndicator = NO;
        s.showsVerticalScrollIndicator = NO;
        s.delegate = self;
        s.minimumZoomScale = 1.0;
        s.maximumZoomScale = 3.0;
        s.tag = i+ScrollViewTag;
        [s setZoomScale:1.0];
        
        UIImageView *imageview = [[UIImageView alloc] init];
        imageview.userInteractionEnabled = YES;
        imageview.tag = ImageViewTag+i;
        [imageview addGestureRecognizer:doubleTap];
        
        [s addGestureRecognizer:onceTap];
        __block BOOL isAction = FALSE;
        UIImage *oldImge = nil;
        
        NSString *documentDir = [YNFunctions getFMCachePath];
        NSArray *array=[demo.d_name componentsSeparatedByString:@"/"];
        NSString *createPath = [NSString stringWithFormat:@"%@/%@",documentDir,demo.d_file_id];
        [NSString CreatePath:createPath];
        NSString *url_path = [NSString stringWithFormat:@"%@/%@",createPath,[array lastObject]];
        if([NSString image_exists_FM_file_path:url_path])
        {
            oldImge = [UIImage imageWithContentsOfFile:url_path];
        }
        else
        {
            AppDelegate *app_delegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
            documentDir = [YNFunctions getProviewCachePath];
            createPath = [NSString stringWithFormat:@"%@/%@",documentDir,demo.d_file_id];
            [NSString CreatePath:createPath];
            url_path = [NSString stringWithFormat:@"%@/%@",createPath,[array lastObject]];
            if([NSString image_exists_FM_file_path:url_path])
            {
                oldImge = [UIImage imageWithContentsOfFile:url_path];
            }
            else if(!app_delegate.isConnection)
            {
                oldImge = [UIImage imageNamed:@"pic_err.png"];
            }
            if(!oldImge)
            {
                NSString *fthumb=[NSString formatNSStringForOjbect:demo.d_thumbUrl];
                NSString *localThumbPath=[YNFunctions getIconCachePath];
                fthumb =[YNFunctions picFileNameFromURL:fthumb];
                url_path=[localThumbPath stringByAppendingPathComponent:fthumb];
                oldImge = [UIImage imageWithContentsOfFile:url_path];
                isAction = YES;
                LookDownFile *downImage = [[LookDownFile alloc] init];
                [downImage setFile_id:demo.d_file_id];
                [downImage setFileName:demo.d_name];
                [downImage setImageViewIndex:ImageViewTag+i];
                [downImage setIndexPath:[NSIndexPath indexPathForRow:ACTNUMBER+i inSection:0]];
                [downImage setDelegate:self];
                [downImage startDownload];
                [downArray addObject:downImage];
            }
        }
        
        CGSize size = [self getSacpeImageSize:oldImge];
        imageview.image = oldImge;
        [s setFrame:[self ScrollRect:i size:size]];
        CGRect imageFrame = imageview.frame;
        imageFrame.origin = [self ImagePoint:size];
        imageFrame.size = size;
        imageview.contentMode = UIViewContentModeScaleAspectFit;
        [imageview setFrame:imageFrame];
        [s addSubview:imageview];
        [s setContentSize:size];
        if(isAction)
        {
            CGRect activityRect = CGRectMake((currWidth-20)/2, (currHeight-20)/2, 20, 20);
            UIActivityIndicatorView *activity_indicator = [[UIActivityIndicatorView alloc] initWithFrame:activityRect];
            [activity_indicator setActivityIndicatorViewStyle:UIActivityIndicatorViewStyleWhite];
            [activity_indicator setTag:ACTNUMBER+i];
            [s addSubview:activity_indicator];
            [activity_indicator startAnimating];
            [activityDic addObject:activity_indicator];
        }
        [imageScrollView addSubview:s];
    }
}

//竖屏
-(CGSize)getImageSize:(UIImage *)imageV
{
    CGSize size = imageV.size;
    if(size.width==0 || size.height == 0)
    {
        return size;
    }
    if(size.width>320)
    {
        size.height = [self GetHeight:size]; //GetHeight(size);
        size.width = 320;
    }
    
    if(size.height>ScollviewHeight)
    {
        size.width = [self GetWidth:size];//GetWidth(size);
        size.height = ScollviewHeight;
    }
    return size;
}

//横屏
-(CGSize)getSacpeImageSize:(UIImage *)imageV
{
    CGSize size = imageV.size;
    if(size.width==0 || size.height == 0)
    {
        return size;
    }
    if(size.width>currWidth)
    {
        size.height = currWidth*size.height/size.width;
        size.width = currWidth;
    }
    
    if(size.height>currHeight)
    {
        size.width = currHeight*size.width/size.height;
        size.height = currHeight;
    }
    return size;
}


#pragma mark -
-(void)handleDoubleTap:(UIGestureRecognizer *)gesture{
    float newScale = 1;
    UIView *view = gesture.view.superview;
    if ([view isKindOfClass:[UIScrollView class]]){
        UIScrollView *s = (UIScrollView *)view;
        if(!self.isDoubleClick || s.zoomScale<=1.0)
        {
            self.isDoubleClick = TRUE;
            newScale = [(UIScrollView*)gesture.view.superview zoomScale] * 3.0;
        }
        else
        {
            self.isDoubleClick = FALSE;
        }
        CGRect zoomRect = [self zoomRectForScale:newScale  inView:(UIScrollView*)gesture.view.superview withCenter:[gesture locationInView:gesture.view]];
        [s zoomToRect:zoomRect animated:YES];
    }
}

-(void)handleOnceTap:(UIGestureRecognizer *)gesture{
    //单击头部和底部出现
    if(self.bottonToolBar.hidden)
    {
        CGFloat x = imageScrollView.contentOffset.x;
        self.page = x/currWidth;
        currPage = self.page;
        self.topTitleLabel.text = [NSString stringWithFormat:@"%i/%i",self.page+1,[self.tableArray count]];
        [self.topToolBar setHidden:NO];
        [self.bottonToolBar setHidden:NO];
    }
    else
    {
        [self.topToolBar setHidden:YES];
        [self.bottonToolBar setHidden:YES];
    }
    
}

#pragma mark - Utility methods

-(CGRect)zoomRectForScale:(float)scale inView:(UIScrollView*)scrollView withCenter:(CGPoint)center {
    
    CGRect zoomRect;
    
    zoomRect.size.height = [scrollView frame].size.height / scale;
    zoomRect.size.width  = [scrollView frame].size.width  / scale;
    
    zoomRect.origin.x    = center.x - (zoomRect.size.width  / 2.0);
    zoomRect.origin.y    = center.y - (zoomRect.size.height / 2.0);
    
    return zoomRect;
}

#pragma mark 收藏按钮事件
-(void)clipClicked:(id)sender
{
    int page = [[[self.topTitleLabel.text componentsSeparatedByString:@"/"] objectAtIndex:0] intValue]-1;
    DownList *demo = nil;
    if([[tableArray objectAtIndex:page] isKindOfClass:[DownList class]])
    {
        demo = [tableArray objectAtIndex:page];
        AppDelegate *delegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
        [delegate.downmange addDownList:demo.d_name thumbName:demo.d_thumbUrl d_fileId:demo.d_file_id d_downSize:demo.d_downSize];
    }
}

#pragma mark 分享按钮事件
-(void)shareClicked:(id)sender
{
    UIActionSheet *actionSheet=[[UIActionSheet alloc]  initWithTitle:@"分享" delegate:self cancelButtonTitle:@"取消" destructiveButtonTitle:nil otherButtonTitles:@"短信分享",@"邮件分享",@"复制链接",@"分享到微信好友",@"分享到微信朋友圈", nil];
    NSString *l_url=@"分享";
    [actionSheet setTitle:l_url];
    [actionSheet setTag:kActionSheetTagShare];
    [actionSheet setActionSheetStyle:UIActionSheetStyleBlackOpaque];
    [actionSheet showInView:[[UIApplication sharedApplication] keyWindow]];
}

#pragma mark UIActionSheetDelegate
-(void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if(actionSheet.tag == kActionSheetTagShare)
    {
        int page = [[[self.topTitleLabel.text componentsSeparatedByString:@"/"] objectAtIndex:0] intValue]-1;
        DownList *demo = nil;
        if([[tableArray objectAtIndex:page] isKindOfClass:[DownList class]])
        {
            demo = [tableArray objectAtIndex:page];
        }
        selected_id = [NSString stringWithFormat:@"%@",demo.d_name];
        
        if (buttonIndex == 0) {
            //[self toDelete:nil];
            [self messageShare:actionSheet.title];
        }else if (buttonIndex == 1) {
            NSString *name=@"";
            UIAlertView *alert=[[UIAlertView alloc] initWithTitle:@"邮件分享" message:@"请您输入分享人的邮件地址：" delegate:self cancelButtonTitle:@"取消" otherButtonTitles:@"确定", nil];
            [alert setAlertViewStyle:UIAlertViewStylePlainTextInput];
            [[alert textFieldAtIndex:0] setText:name];
            [alert setTag:kAlertTagMailAddr];
            [alert show];
        }else if(buttonIndex == 2) {
            [self pasteBoard:actionSheet.title];
        }else if(buttonIndex == 3) {
            [self weixin:actionSheet.title];
        }else if(buttonIndex == 4) {
            [self frends:actionSheet.title];
        }else if(buttonIndex == 5) {
        }else if(buttonIndex == 6) {
        }
    }
    else if (actionSheet.tag == kActionSheetTagDelete)
    {
        if(buttonIndex == 0)
        {
            int page = [[[self.topTitleLabel.text componentsSeparatedByString:@"/"] objectAtIndex:0] intValue]-1;
            deletePage = page;
            DownList *demo = nil;
            if([[tableArray objectAtIndex:page] isKindOfClass:[DownList class]])
            {
                demo = [tableArray objectAtIndex:page];
            }
            if (buttonIndex==0) {
                [self.fm cancelAllTask];
                self.fm=[[SCBFileManager alloc] init];
                self.fm.delegate=self;
                [self.fm removeFileWithIDs:@[demo.d_file_id]];
            }
            hud = [[MBProgressHUD alloc] initWithView:self.view];
            [self.view addSubview:hud];
            hud.mode=MBProgressHUDModeIndeterminate;
            hud.labelText=@"正在删除";
            [hud show:YES];
        }
    }
}

-(void)networkError
{
    if (self.hud) {
        [self.hud removeFromSuperview];
    }
    self.hud=nil;
    self.hud=[[MBProgressHUD alloc] initWithView:self.view];
    [self.view addSubview:self.hud];
    [self.hud show:NO];
    self.hud.labelText=@"链接失败，请检查网络";
    self.hud.mode=MBProgressHUDModeText;
    self.hud.margin=10.f;
    [self.hud show:YES];
    [self.hud hide:YES afterDelay:1.0f];
}

-(void)mailShare:(NSString *)content
{
    sharedType = 2;
    [self getPubSharedLink];
}

-(void)pasteBoard:(NSString *)content
{
    sharedType = 3;
    [self getPubSharedLink];
    //    [[UIPasteboard generalPasteboard] setString:content];
}

-(void)messageShare:(NSString *)content
{
    sharedType = 1;
    [self getPubSharedLink];
}

-(void)weixin:(NSString *)content
{
    sharedType = 4;
    [self getPubSharedLink];
}

-(void)frends:(NSString *)content
{
    sharedType = 5;
    [self getPubSharedLink];
}

#pragma mark 请求外链
-(void)getPubSharedLink
{
    linkManager.delegate = self;
    NSMutableArray *array = [NSMutableArray array];
    if(selected_id)
    {
        [array addObject:selected_id];
    }
    
    if([array count]>0)
    {
        [linkManager linkWithIDs:array];
    }
}

#pragma mark 删除按钮事件
-(void)deleteClicked:(id)sender
{
    UIActionSheet *actionSheet = [[UIActionSheet alloc] initWithTitle:@"是否要删除选中的内容" delegate:self cancelButtonTitle:@"取消" destructiveButtonTitle:@"确定" otherButtonTitles:nil, nil];
    [actionSheet setTag:kActionSheetTagDelete];
    [actionSheet setActionSheetStyle:UIActionSheetStyleBlackOpaque];
    [actionSheet showInView:self.imageScrollView];
}

#pragma mark UIAalertViewDelegate
-(void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    
}


#pragma mark SCBPhotoDelegate
-(void)requstDelete:(NSDictionary *)dictioinary
{
    
}

-(void)getFileDetail:(NSDictionary *)dictionary
{
    if([[dictionary objectForKey:@"code"] intValue] == 0)
    {
        hud = [[MBProgressHUD alloc] initWithView:self.view];
        [self.view addSubview:hud];
        hud.labelText=@"下载成功";
        hud.mode=MBProgressHUDModeText;
        [hud show:YES];
        [hud hide:YES afterDelay:0.8f];
        hud = nil;
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

-(void)didFailWithError
{
    AppDelegate *app_delegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
    app_delegate.isConnection = NO;
    
    [self updateAllView];
    
    if (self.hud) {
        [self.hud removeFromSuperview];
    }
    self.hud=nil;
    self.hud=[[MBProgressHUD alloc] initWithView:self.view];
    [self.view.superview addSubview:self.hud];
    [self.hud show:NO];
    self.hud.labelText=@"链接失败，请检查网络";
    self.hud.mode=MBProgressHUDModeText;
    self.hud.margin=10.f;
    [self.hud show:YES];
    [self.hud hide:YES afterDelay:1.0f];
}

-(void)updateAllView
{
    dispatch_async(dispatch_get_main_queue(), ^{
        if(imageScrollView)
        {
            [imageScrollView removeFromSuperview];
            imageScrollView = nil;
        }
        
        self.offset = 0.0;
        scale_ = 1.0;
        currPage = self.page;
        imageScrollView = [[UIScrollView alloc] initWithFrame:CGRectMake(0, 0, currWidth, currHeight)];
        imageScrollView.backgroundColor = [UIColor clearColor];
        imageScrollView.scrollEnabled = YES;
        imageScrollView.pagingEnabled = YES;
        imageScrollView.showsHorizontalScrollIndicator = NO;
        imageScrollView.delegate = self;
        
        if(currPage==0&&[tableArray count]>=3)
        {
            startPage = 0;
            endPage = currPage+2;
            for (int i = 0; i<currPage+3; i++){
                if(i>=[tableArray count])
                {
                    break;
                }
                [self loadPageColoumn:i];
            }
        }
        
        if(currPage==0&&[tableArray count]<=3)
        {
            startPage = 0;
            endPage = [tableArray count]-1;
            for (int i = 0; i<[tableArray count]; i++){
                if(i>=[tableArray count])
                {
                    break;
                }
                if(i<0)
                {
                    continue;
                }
                [self loadPageColoumn:i];
            }
        }
        
        if(currPage>0&&currPage+1<[tableArray count])
        {
            startPage = currPage-1;
            endPage = currPage+1;
            for (int i = currPage-1; i<currPage+2; i++){
                if(i>=[tableArray count])
                {
                    break;
                }
                if(i<0)
                {
                    continue;
                }
                [self loadPageColoumn:i];
            }
        }
        
        if(currPage+1==[tableArray count] && [tableArray count]>=3)
        {
            startPage = currPage-2;
            endPage = currPage-1;
            for (int i = currPage-2; i<=currPage; i++){
                if(i>=[tableArray count])
                {
                    break;
                }
                if(i<0)
                {
                    continue;
                }
                [self loadPageColoumn:i];
            }
        }
        
        if(currPage+1==[tableArray count] && [tableArray count]<3)
        {
            startPage = 0;
            endPage = currPage-1;
            for (int i = 0; i<=currPage; i++){
                if(i>=[tableArray count])
                {
                    break;
                }
                
                [self loadPageColoumn:i];
            }
        }
        [self.view addSubview:imageScrollView];
        [self.view bringSubviewToFront:self.topToolBar];
        [self.view bringSubviewToFront:self.bottonToolBar];
        
        imageScrollView.contentSize = CGSizeMake(currWidth*[tableArray count], currHeight);
        [imageScrollView setContentOffset:CGPointMake(currWidth*currPage, 0) animated:NO];
        [self handleOnceTap:nil];
    });
}

#pragma mark 下载回调
- (void)downFinish:(NSString *)baseUrl{}
-(void)downFile:(NSInteger)downSize totalSize:(NSInteger)sudu{}

-(void)appImageDidLoad:(NSInteger)indexTag urlImage:(NSString *)path index:(NSIndexPath *)indexPath
{
    dispatch_async(dispatch_get_main_queue(), ^{
        if([[imageScrollView viewWithTag:indexTag] isKindOfClass:[UIImageView class]])
        {
            UIImage *scaleImage = [UIImage imageWithContentsOfFile:path];
            UIImageView *imageV = (UIImageView *)[imageScrollView viewWithTag:indexTag];
            if(self.isScape)
            {
                CGSize size = [self getSacpeImageSize:scaleImage];
                UIScrollView *s = (UIScrollView *)[self.view viewWithTag:indexTag-ImageViewTag+ScrollViewTag];
                s.zoomScale = 1.0;
                [s setContentSize:size];
                int x = s.tag-ScrollViewTag;
                [s setFrame:CGRectMake(currWidth*x, 0, currWidth, currHeight)];
                CGRect imageFrame = imageV.frame;
                imageFrame.origin = CGPointMake((currWidth-size.width)/2, (currHeight-size.height)/2);
                imageFrame.size = size;
                [imageV setFrame:imageFrame];
            }
            else
            {
                CGSize size = [self getImageSize:scaleImage];
                UIScrollView *s = (UIScrollView *)[self.view viewWithTag:indexTag-ImageViewTag+ScrollViewTag];
                s.zoomScale = 1.0;
                [s setContentSize:size];
                int x = s.tag-ScrollViewTag;
                [s setFrame:[self ScrollRect:x size:size]];
                CGRect imageFrame = imageV.frame;
                imageFrame.origin = [self ImagePoint:size];//ImagePoint(size);
                imageFrame.size = size;
                [imageV setFrame:imageFrame];
            }
            [imageV performSelectorOnMainThread:@selector(setImage:) withObject:scaleImage waitUntilDone:YES];
        }
        if([[imageScrollView viewWithTag:indexPath.row] isKindOfClass:[UIActivityIndicatorView class]])
        {
            UIActivityIndicatorView *activity_indicator = (UIActivityIndicatorView *)[imageScrollView viewWithTag:indexPath.row];
            [activity_indicator stopAnimating];
            [activity_indicator removeFromSuperview];
            activity_indicator = nil;
        }
        if (self.hud) {
            [self.hud removeFromSuperview];
        }
    });
}

#pragma mark SCBLinkManagerDelegate -------------
-(void)releaseEmailSuccess:(NSString *)l_url
{
    
}

-(void)releaseLinkSuccess:(NSString *)l_url
{
    if(sharedType == 1)
    {
        //短信分享
        NSString *text=[NSString stringWithFormat:@"%@想和您分享虹盘的文件，链接地址：%@",[[NSUserDefaults standardUserDefaults] objectForKey:@"usr_name"],l_url];
        
        if ([MFMessageComposeViewController canSendText]) {
            MFMessageComposeViewController *picker = [[MFMessageComposeViewController alloc] init];
            picker.messageComposeDelegate = self;
            
            [picker setBody:text];
            [self presentModalViewController:picker animated:YES];
        }
    }
    else if(sharedType == 2)
    {
        //邮件分享
        NSString *text=[NSString stringWithFormat:@"%@想和您分享虹盘的文件，链接地址：%@",[[NSUserDefaults standardUserDefaults] objectForKey:@"usr_name"],l_url];
        
        if ([MFMailComposeViewController canSendMail]) {
            MFMailComposeViewController *picker = [[MFMailComposeViewController alloc] init];
            picker.mailComposeDelegate = self;
            
            [picker setSubject:text];
            
            NSString *emailBody = text;
            [picker setMessageBody:emailBody isHTML:NO];
            
            [self presentModalViewController:picker animated:YES];
        }
    }
    else if(sharedType == 3)
    {
        //复制
        [[UIPasteboard generalPasteboard] setString:l_url];
        if (self.hud) {
            [self.hud removeFromSuperview];
        }
        self.hud=nil;
        self.hud=[[MBProgressHUD alloc] initWithView:self.view];
        [self.view.superview addSubview:self.hud];
        [self.hud show:NO];
        self.hud.labelText=@"已经复制成功";
        self.hud.mode=MBProgressHUDModeText;
        self.hud.margin=10.f;
        [self.hud show:YES];
        [self.hud hide:YES afterDelay:1.0f];
    }
}

-(void)releaseLinkUnsuccess:(NSString *)error_info
{
    if (self.hud) {
        [self.hud removeFromSuperview];
    }
    self.hud=nil;
    self.hud=[[MBProgressHUD alloc] initWithView:self.view];
    [self.view.superview addSubview:self.hud];
    [self.hud show:NO];
    if (error_info==nil||[error_info isEqualToString:@""]) {
        self.hud.labelText=@"获取外链失败";
    }else
    {
        self.hud.labelText=error_info;
    }
    self.hud.mode=MBProgressHUDModeText;
    self.hud.margin=10.f;
    [self.hud show:YES];
    [self.hud hide:YES afterDelay:1.0f];
}

#pragma mark SCBFileManagerDelegate

-(void)authorMenusSuccess:(NSData*)data
{

}
-(void)searchSucess:(NSDictionary *)datadic
{

}
-(void)operateSucess:(NSDictionary *)datadic
{

}
-(void)openFinderSucess:(NSDictionary *)datadic
{

}
//打开家庭成员
-(void)getOpenFamily:(NSDictionary *)dictionary{}
-(void)openFinderUnsucess{}
-(void)removeSucess
{
    if(deletePage<[tableArray count])
    {
        [tableArray removeObjectAtIndex:deletePage];
    }
    
    if(imageScrollView)
    {
        [imageScrollView removeFromSuperview];
        imageScrollView = nil;
        [activityDic removeAllObjects];
    }
    
    if([tableArray count]==0)
    {
        [self dismissModalViewControllerAnimated:YES];
    }
    
    self.offset = 0.0;
    scale_ = 1.0;
    if(deletePage==[tableArray count])
    {
        currPage = deletePage-1;
    }
    imageScrollView = [[UIScrollView alloc] initWithFrame:CGRectMake(0, 0, currWidth, currHeight)];
    imageScrollView.backgroundColor = [UIColor clearColor];
    imageScrollView.scrollEnabled = YES;
    imageScrollView.pagingEnabled = YES;
    imageScrollView.showsHorizontalScrollIndicator = NO;
    imageScrollView.delegate = self;
    
    if(currPage==0&&[tableArray count]>=3)
    {
        startPage = 0;
        endPage = currPage+2;
        for (int i = 0; i<currPage+3; i++){
            if(i>=[tableArray count])
            {
                break;
            }
            [self loadPageColoumn:i];
        }
    }
    
    if(currPage==0&&[tableArray count]<=3)
    {
        startPage = 0;
        endPage = [tableArray count]-1;
        for (int i = 0; i<[tableArray count]; i++){
            if(i>=[tableArray count])
            {
                break;
            }
            if(i<0)
            {
                continue;
            }
            [self loadPageColoumn:i];
        }
    }
    
    if(currPage>0&&currPage+1<[tableArray count])
    {
        startPage = currPage-1;
        endPage = currPage+1;
        for (int i = currPage-1; i<currPage+2; i++){
            if(i>=[tableArray count])
            {
                break;
            }
            if(i<0)
            {
                continue;
            }
            [self loadPageColoumn:i];
        }
    }
    
    if(currPage+1==[tableArray count] && [tableArray count]>=3)
    {
        startPage = currPage-2;
        endPage = currPage-1;
        for (int i = currPage-2; i<=currPage; i++){
            if(i>=[tableArray count])
            {
                break;
            }
            if(i<0)
            {
                continue;
            }
            [self loadPageColoumn:i];
        }
    }
    
    if(currPage+1==[tableArray count] && [tableArray count]<3)
    {
        startPage = 0;
        endPage = currPage-1;
        for (int i = 0; i<=currPage; i++){
            if(i>=[tableArray count])
            {
                break;
            }
            
            [self loadPageColoumn:i];
        }
    }
    
    [self.view addSubview:imageScrollView];
    [self.view bringSubviewToFront:self.topToolBar];
    [self.view bringSubviewToFront:self.bottonToolBar];
    
    imageScrollView.contentSize = CGSizeMake(currWidth*[tableArray count], currHeight);
    [imageScrollView setContentOffset:CGPointMake(currWidth*currPage, 0) animated:NO];
    [self handleOnceTap:nil];
    
    hud.labelText=@"删除成功";
    hud.mode=MBProgressHUDModeText;
    [hud hide:YES afterDelay:0.8f];
    hud = nil;
}
-(void)removeUnsucess
{
    hud.labelText=@"删除失败";
    hud.mode=MBProgressHUDModeText;
    [hud hide:YES afterDelay:0.8f];
    hud = nil;
}
-(void)renameSucess{}
-(void)renameUnsucess{}
-(void)moveSucess{}
-(void)moveUnsucess{}
-(void)newFinderSucess{}
-(void)newFinderUnsucess{}

- (void)messageComposeViewController:(MFMessageComposeViewController *)controller
                 didFinishWithResult:(MessageComposeResult)result {
	NSString *resultValue=@"";
	switch (result)
	{
		case MessageComposeResultCancelled:
			resultValue = @"Result: SMS sending canceled";
			break;
		case MessageComposeResultSent:
			resultValue = @"Result: SMS sent";
			break;
		case MessageComposeResultFailed:
			resultValue = @"Result: SMS sending failed";
			break;
		default:
			resultValue = @"Result: SMS not sent";
			break;
	}
	[self dismissModalViewControllerAnimated:YES];
}


//旋转方向发生改变时
-(void)willAnimateRotationToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation duration:(NSTimeInterval)duration {
    
}
//视图旋转动画前一半发生之前自动调用

-(void)willAnimateFirstHalfOfRotationToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation duration:(NSTimeInterval)duration {
    
}
//视图旋转动画后一半发生之前自动调用

-(void)willAnimateSecondHalfOfRotationFromInterfaceOrientation:(UIInterfaceOrientation)fromInterfaceOrientation duration:(NSTimeInterval)duration {
   
}
//视图旋转之前自动调用

-(void)willRotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation duration:(NSTimeInterval)duration {
    if(UIDeviceOrientationLandscapeRight == toInterfaceOrientation || UIDeviceOrientationLandscapeLeft == toInterfaceOrientation)
    {
        [self isScapeLeftOrRight:YES];
        self.isScape = TRUE;
    }
    else
    {
        [self isScapeLeftOrRight:NO];
        self.isScape = FALSE;
    }
}
//视图旋转完成之后自动调用
-(void)didRotateFromInterfaceOrientation:(UIInterfaceOrientation)fromInterfaceOrientation {
    [UIView animateWithDuration:0.0 animations:^{
        [self scrollViewDidEndDecelerating:imageScrollView];
    }];
}
//视图旋转动画前一半发生之后自动调用

-(void)didAnimateFirstHalfOfRotationToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation {
    
}

//横屏后，修改试图
-(void)isScapeLeftOrRight:(BOOL)bl
{
    if(!self.page)
    {
        self.page = currPage;
    }
    if(bl)
    {
        currWidth = ScollviewHeight;
        currHeight = ScollviewWidth;
        
        //整个视图大小调整
        [imageScrollView setFrame:CGRectMake(0, 0, currWidth, currHeight)];
        [imageScrollView setContentSize:CGSizeMake(currWidth*[self.tableArray count], currHeight)];
        
        //头部视图大小调整
        CGSize size = CGSizeMake(currWidth, self.bottonToolBar.frame.size.height);
        CGRect rect = self.topToolBar.frame;
        rect.size = size;
        [self.topToolBar setFrame:rect];
        [self.topTitleLabel setFrame:CGRectMake(0, 0, currWidth, 44)];
        
        //滚动视图大小调整
        for(int i=0;i<[imageScrollView.subviews count];i++)
        {
            if([[imageScrollView.subviews objectAtIndex:i] isKindOfClass:[UIScrollView class]])
            {
                UIScrollView *s = [imageScrollView.subviews objectAtIndex:i];
                s.zoomScale = 1.0;
                UIImageView *imageview = (UIImageView *)[s viewWithTag:ImageViewTag+s.tag-ScrollViewTag];
                size = [self getSacpeImageSize:imageview.image];
                [s setContentSize:size];
                int x = s.tag-ScrollViewTag;
                [s setFrame:CGRectMake(currWidth*x, 0, currWidth, currHeight)];
                CGRect imageFrame = imageview.frame;
                imageFrame.origin = CGPointMake((currWidth-size.width)/2, (currHeight-size.height)/2);
                imageFrame.size = size;
                [imageview setFrame:imageFrame];
            }
        }
        [imageScrollView reloadInputViews];
        [imageScrollView setContentOffset:CGPointMake(currWidth*currPage, 0) animated:NO];
        
        //底部视图大小调整
        size = CGSizeMake(currWidth, self.bottonToolBar.frame.size.height);
        rect = self.topToolBar.frame;
        rect.origin = CGPointMake(0, currHeight-44);
        rect.size = size;
        [self.bottonToolBar setFrame:rect];
        if(self.rightButton.hidden)
        {
            int width = (currWidth-36*3)/2;
            [self.leftButton setFrame:CGRectMake(36, 0, width, 44)];
            [self.rightButton setFrame:CGRectMake(36*2+width*1, 0, width, 44)];
        }
        else
        {
            int width = (currWidth-36*3)/2;
            [self.leftButton setFrame:CGRectMake(36, 0, width, 44)];
            [self.rightButton setFrame:CGRectMake(36*2+width*1, 0, width, 44)];
        }
        
    }
    else
    {
        currWidth = ScollviewWidth;
        currHeight = ScollviewHeight;
        //整个视图大小调整
        [imageScrollView setFrame:CGRectMake(0, 0, currWidth, currHeight)];
        [imageScrollView setContentSize:CGSizeMake(currWidth*[self.tableArray count], currWidth)];
        
        //头部视图大小调整
        CGSize size = CGSizeMake(320, self.bottonToolBar.frame.size.height);
        CGRect rect = self.topToolBar.frame;
        rect.size = size;
        [self.topToolBar setFrame:rect];
        [self.topTitleLabel setFrame:CGRectMake(0, 0, 320, 44)];
        
        //滚动视图大小调整
        for(int i=0;i<[imageScrollView.subviews count];i++)
        {
            if([[imageScrollView.subviews objectAtIndex:i] isKindOfClass:[UIScrollView class]])
            {
                UIScrollView *s = [imageScrollView.subviews objectAtIndex:i];
                s.zoomScale = 1.0;
                UIImageView *imageview = (UIImageView *)[s viewWithTag:ImageViewTag+s.tag-ScrollViewTag];
                size = [self getImageSize:imageview.image];
                [s setContentSize:size];
                int x = s.tag-ScrollViewTag;
                [s setFrame:[self ScrollRect:x size:size]];
                CGRect imageFrame = imageview.frame;
                imageFrame.origin = [self ImagePoint:size];//ImagePoint(size);
                imageFrame.size = size;
                [imageview setFrame:imageFrame];
            }
        }
        [imageScrollView reloadInputViews];
        [imageScrollView setContentOffset:CGPointMake(320*currPage, 0) animated:NO];
        
        //底部视图大小调整
        size = CGSizeMake(currWidth, self.bottonToolBar.frame.size.height);
        rect = self.topToolBar.frame;
        rect.origin = CGPointMake(0, currHeight-44);
        rect.size = size;
        [self.bottonToolBar setFrame:rect];
        if(self.rightButton.hidden)
        {
            int width = (currWidth-36*3)/2;
            [self.leftButton setFrame:CGRectMake(36, 0, width, 44)];
            [self.rightButton setFrame:CGRectMake(36*3+width*2, 0, width, 44)];
        }
        else
        {
            int width = (currWidth-36*3)/2;
            [self.leftButton setFrame:CGRectMake(36, 0, width, 44)];
            [self.rightButton setFrame:CGRectMake(36*2+width*1, 0, width, 44)];
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

//每个UIScrollView的大小
-(CGSize)ImageContentSize
{
    return CGSizeMake(320,ScollviewHeight);
}

//每个UIScrollView的坐标
-(CGRect)ScrollRect:(int)index size:(CGSize)size
{
    return CGRectMake(320*index, 0, 320, ScollviewHeight);
}

//imageview的起始点
-(CGPoint)ImagePoint:(CGSize)size
{
    return CGPointMake((320-size.width)/2, (ScollviewHeight-size.height)/2);
}

//获取等比例高度
-(CGFloat)GetHeight:(CGSize)size
{
    return 320*size.height/size.width;
}

-(CGFloat)GetWidth:(CGSize)size
{
    return ScollviewHeight*size.width/size.height;
}

@end
