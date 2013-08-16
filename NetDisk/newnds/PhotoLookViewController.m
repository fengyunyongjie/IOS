//
//  PhotoLookViewController.m
//  NetDisk
//
//  Created by Yangsl on 13-6-5.
//
//

#import "PhotoLookViewController.h"
#import "PhotoFile.h"
#import "YNFunctions.h"
#import "FavoritesData.h"
#import "AppDelegate.h"

#define ACTNUMBER 400000
#define ScrollViewTag 100000
#define ImageViewTag 200000
#define ScollviewHeight self.view.frame.size.height //当前屏幕的高度
#define ScollviewWidth self.view.frame.size.width //当前屏幕的宽度

#define ImageContentSize CGSizeMake(320,ScollviewHeight) //每个UIScrollView的大小
#define ScrollRect(index,size) CGRectMake(320*index, 0, 320, ScollviewHeight) //每个UIScrollView的坐标
#define ImagePoint(size) CGPointMake((320-size.width)/2, (ScollviewHeight-size.height)/2) //imageview的起始点
#define GetHeight(size) 320*size.height/size.width //获取等比例高度
#define GetWidth(size) ScollviewHeight*size.width/size.height //获取等比例宽度

//横屏后
#define ScapeScrollviewRect CGRectMake(0, 0, ScollviewHeight+20, 300)
#define ScapeTopLeftRect CGRectMake(0, 0, ScollviewHeight+20, 44)
#define ScapeScrollRect(index,size) CGRectMake((ScollviewHeight+20)*index, 0, ScollviewHeight+20, 300) //每个UIScrollView的坐标
#define ScapeImagePoint(size) CGPointMake((ScollviewHeight+20-size.width)/2, (300-size.height)/2) //imageview的起始点
#define GetScapeHeight(size) (ScollviewHeight+20)*size.height/size.width //获取等比例高度
#define GetScapeWidth(size) 300*size.width/size.height //获取等比例宽度

@interface PhotoLookViewController ()
@property float scale_;
@end

@implementation PhotoLookViewController
@synthesize imageScrollView;
@synthesize scale_,tableArray;
@synthesize currPage;
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
    [super viewDidLoad];
    downArray = [[NSMutableArray alloc] init];
    
    activityDic = [[NSMutableDictionary alloc] init];
    currWidth = ScollviewWidth;
    currHeight = ScollviewHeight;
    self.view.backgroundColor = [UIColor blackColor];
    self.offset = 0.0;
    scale_ = 1.0;
    currWidth = 320;
    currHeight = self.view.frame.size.height;
    
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
    NSLog(@"320*currPage:%i",320*currPage);
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
    
    
    int width = (currWidth-36*4)/3;
    
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
    
    CGRect centerRect = CGRectMake(width+36*2, 5, width, 33);
    self.centerButton = [[UIButton alloc] initWithFrame:centerRect];
    [self.centerButton.titleLabel setFont:[UIFont systemFontOfSize:14]];
    [self.centerButton.titleLabel setTextColor:[UIColor blackColor]];
    [self.centerButton setTitle:@"分享" forState:UIControlStateNormal];
    [self.centerButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [self.centerButton addTarget:self action:@selector(shareClicked:) forControlEvents:UIControlEventTouchUpInside];
    [self.centerButton setBackgroundColor:[UIColor clearColor]];
    [self.bottonToolBar addSubview:self.centerButton];
    self.centerButton.showsTouchWhenHighlighted = YES;
    
    CGRect rightRect = CGRectMake(width*2+36*3, 5, width, 33);
    self.rightButton = [[UIButton alloc] initWithFrame:rightRect];
    [self.rightButton.titleLabel setFont:[UIFont systemFontOfSize:14]];
    [self.rightButton.titleLabel setTextColor:[UIColor blackColor]];
    [self.rightButton setTitle:@"删除" forState:UIControlStateNormal];
    [self.rightButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [self.rightButton addTarget:self action:@selector(deleteClicked:) forControlEvents:UIControlEventTouchUpInside];
    [self.rightButton setBackgroundColor:[UIColor clearColor]];
    self.rightButton.showsTouchWhenHighlighted = YES;
    [self.bottonToolBar addSubview:self.rightButton];
    
    [self.view addSubview:self.bottonToolBar];
    
    [self.topToolBar setHidden:YES];
    [self.bottonToolBar setHidden:YES];
}

-(void)backClick
{
    [self dismissModalViewControllerAnimated:YES];
    for(int i=0;i<[downArray count];i++)
    {
        DownImage *down = [downArray objectAtIndex:i];
        [down setDelegate:nil];
    }
    [downArray release];
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
    NSLog(@"停止了。。。");
//    if (scrollView == imageScrollView){
//        CGFloat x = scrollView.contentOffset.x;
//        self.endFloat = x;
//        if (x==self.offset){
//            
//        }
//        else {
//            self.offset = x;
//            for (UIScrollView *s in scrollView.subviews){
//                if ([s isKindOfClass:[UIScrollView class]]){
//                    [s setZoomScale:1.0];
//                    UIImageView *image = [[s subviews] objectAtIndex:0];
//                    CGSize imaSize;
//                    CGRect imageFrame = image.frame;
//                    if(self.isScape)
//                    {
//                        imaSize = [self getSacpeImageSize:image.image];
//                        [s setContentSize:imaSize];
//                        int x = s.tag-ScrollViewTag;
//                        [s setFrame:CGRectMake(currWidth*x, 0, currWidth, currHeight)];
//                        imageFrame.origin = CGPointMake((currWidth-imaSize.width)/2, (currHeight-imaSize.height)/2);
//                    }
//                    else
//                    {
//                        imaSize = [self getImageSize:image.image];
//                        [s setContentSize:imaSize];
//                        int x = s.tag-ScrollViewTag;
//                        [s setFrame:ScrollRect(x,size)];
//                        imageFrame.origin = ImagePoint(imaSize);
//                    }
//                    imageFrame.size = imaSize;
//                    [image setFrame:imageFrame];
//                }
//            }
//        }
//    }
}

#pragma mark 滑动隐藏
-(void)scrollViewWillBeginDragging:(UIScrollView *)scrollView
{
    [self.topToolBar setHidden:YES];
    [self.bottonToolBar setHidden:YES];
    
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 0), ^{
        
        if(isLoadImage)
        {
            NSLog(@"不进行预加载。。。");
            return ;
        }
        
        if(!isLoadImage)
        {
            NSLog(@"预加载开始。。。");
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
                }
            }
            
            //向右滑动
            NSLog(@"向右滑动:%i",[imageScrollView.subviews count]);
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
                }
            }
            //向左滑动
            NSLog(@"向左滑动:%i",[imageScrollView.subviews count]);
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
        NSLog(@"预加载结束。。。");
    });
}

-(void)scrollViewDidZoom:(UIScrollView *)scrollView{
    NSLog(@"Did zoom!:%@",NSStringFromCGSize(scrollView.contentSize));
    
    UIImageView *imageview = (UIImageView *)[scrollView viewWithTag:ImageViewTag+scrollView.tag-ScrollViewTag];
    CGFloat xcenter = scrollView.center.x , ycenter = scrollView.center.y;
    ycenter = scrollView.contentSize.height > scrollView.frame.size.height ? scrollView.contentSize.height/2 : ycenter;
    
    NSLog(@"------xcenter:%f,ycenter:%f",xcenter,ycenter);
    
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
    //加载数据
    int page = imageScrollView.contentOffset.x/320;
    PhotoFile *demo = [tableArray objectAtIndex:page];
    if(![[activityDic objectForKey:[NSString stringWithFormat:@"%i",demo.f_id]] isKindOfClass:[PhotoFile class]])
    {
        CGRect activityRect = CGRectMake(320*(page-1)+(320-20)/2, (ScollviewHeight-20)/2, 20, 20);
        UIActivityIndicatorView *activity_indicator = [[[UIActivityIndicatorView alloc] initWithFrame:activityRect] autorelease];
        [activity_indicator setActivityIndicatorViewStyle:UIActivityIndicatorViewStyleWhite];
        [activity_indicator startAnimating];
        [activity_indicator setTag:ACTNUMBER+page];
        [imageScrollView addSubview:activity_indicator];
        [activityDic setObject:demo forKey:[NSString stringWithFormat:@"%i",demo.f_id]];
    }
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
            NSLog(@"重新加载：%i",i);
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
            NSLog(@"重新加载：%i",i);
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
            NSLog(@"重新加载：%i",i);
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
            NSLog(@"重新加载：%i",i);
            [self loadPageColoumn:i];
        }
    }
}

-(void)loadPageColoumn:(int)i
{
    NSLog(@"开始加载。。。");
    UIView *view = [imageScrollView viewWithTag:i+ScrollViewTag];
    if(view)
    {
        return;
    }
    if(self.isScape)
    {
        PhotoFile *demo = [tableArray objectAtIndex:i];
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
        if([self image_exists_at_file_path:[NSString stringWithFormat:@"%iT",demo.f_id]])
        {
            NSString *path = [self get_image_save_file_path:[NSString stringWithFormat:@"%iT",demo.f_id]];
            oldImge = [UIImage imageWithContentsOfFile:path];
        }
        else
        {
            NSString *path = [self get_image_save_file_path:[NSString stringWithFormat:@"%i",demo.f_id]];
            oldImge = [UIImage imageWithContentsOfFile:path];
            isAction = YES;
            dispatch_async(dispatch_get_main_queue(), ^{
                DownImage *downImage = [[[DownImage alloc] init] autorelease];
                [downImage setFileId:demo.f_id];
                [downImage setImageUrl:[NSString stringWithFormat:@"%iT",demo.f_id]];
                [downImage setImageViewIndex:ImageViewTag+i];
                [downImage setIndex:ACTNUMBER+i];
                NSLog(@"downImage index-------------:%i",ACTNUMBER+i);
                [downImage setShowType:1];
                [downImage setDelegate:self];
                [downImage startDownload];
                [downArray addObject:downImage];
            });
        }
        
        CGSize size = [self getSacpeImageSize:oldImge];
//            UIImage *scaleImage = [self scaleFromImage:oldImge toSize:size];
        imageview.image = oldImge;
        
        [s setFrame:CGRectMake(currWidth*i, 0, currWidth, 300)];
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
            NSLog(@"activity_indicator index-------------:%i",activity_indicator.tag);
            [activity_indicator startAnimating];
            [activity_indicator release];
        }

        [imageScrollView addSubview:s];
        [onceTap release];
        [doubleTap release];
        [imageview release];
        [s release];
    }
    else
    {
        PhotoFile *demo = [tableArray objectAtIndex:i];
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
        if([self image_exists_at_file_path:[NSString stringWithFormat:@"%iT",demo.f_id]])
        {
            NSString *path = [self get_image_save_file_path:[NSString stringWithFormat:@"%iT",demo.f_id]];
            oldImge = [UIImage imageWithContentsOfFile:path];
        }
        else
        {
            NSString *path = [self get_image_save_file_path:[NSString stringWithFormat:@"%i",demo.f_id]];
            oldImge = [UIImage imageWithContentsOfFile:path];
            isAction = YES;
            dispatch_async(dispatch_get_main_queue(), ^{
                DownImage *downImage = [[[DownImage alloc] init] autorelease];
                [downImage setFileId:demo.f_id];
                [downImage setImageUrl:[NSString stringWithFormat:@"%iT",demo.f_id]];
                [downImage setImageViewIndex:ImageViewTag+i];
                [downImage setIndex:ACTNUMBER+i];
                NSLog(@"downImage index-------------:%i",ACTNUMBER+i);
                [downImage setShowType:1];
                [downImage setDelegate:self];
                [downImage startDownload];
                [downArray addObject:downImage];
            });
        }
        
        CGSize size = [self getSacpeImageSize:oldImge];
//            UIImage *scaleImage = [self scaleFromImage:oldImge toSize:size];
        imageview.image = oldImge;
        
        [s setFrame:ScrollRect(i,size)];
        CGRect imageFrame = imageview.frame;
        imageFrame.origin = ImagePoint(size);
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
            NSLog(@"activity_indicator index-------------:%i",activity_indicator.tag);
            [activity_indicator startAnimating];
            [activity_indicator release];
        }
        [imageScrollView addSubview:s];
        
        [onceTap release];
        [doubleTap release];
        [imageview release];
        [s release];
    }
    NSLog(@"加载完成。。。");
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
        size.height = GetHeight(size);
        size.width = 320;
    }
    
    if(size.height>ScollviewHeight)
    {
        size.width = GetWidth(size);
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
    NSLog(@"ScollviewWidth:%f,ScollviewHeight:%f",ScollviewWidth,ScollviewHeight);
    NSLog(@"currWidth:%f,currHeight:%f",currWidth,currHeight);
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
        int page = self.page;
        self.topTitleLabel.text = [NSString stringWithFormat:@"%i/%i",self.page+1,[self.tableArray count]];
        [self.topToolBar setHidden:NO];
        [self.bottonToolBar setHidden:NO];
        if([[tableArray objectAtIndex:page] isKindOfClass:[PhotoFile class]])
        {
            PhotoFile *demo = [tableArray objectAtIndex:page];
            NSString *f_id = [NSString stringWithFormat:@"%i",demo.f_id];
            if ([[FavoritesData sharedFavoritesData] isExistsWithFID:f_id]) {
//                [self isHiddenDelete:YES];
            }
            else
            {
                [self isHiddenDelete:NO];
            }
        }
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

#pragma mark  这个路径下是否存在此图片
- (BOOL)image_exists_at_file_path:(NSString *)image_path
{
    NSFileManager *file_manager = [NSFileManager defaultManager];
    NSString *documentDir = [YNFunctions getProviewCachePath];
    NSArray *array=[image_path componentsSeparatedByString:@"/"];
    NSString *path=[NSString stringWithFormat:@"%@/%@",documentDir,[array lastObject]];
    return [file_manager fileExistsAtPath:path];
}

#pragma mark  获取图片路径
- (NSString*)get_image_save_file_path:(NSString*)image_path
{
    NSString *documentDir = [YNFunctions getProviewCachePath];
    NSArray *array=[image_path componentsSeparatedByString:@"/"];
    NSString *path=[NSString stringWithFormat:@"%@/%@",documentDir,[array lastObject]];
    return path;
}

-(void)isHiddenDelete:(BOOL)bl
{
    if(bl)
    {
        float fWidth = (currWidth-36*3)/2;
        CGRect leftRect = CGRectMake(36, 5, fWidth, 33);
        [self.leftButton setTitle:@"下载" forState:UIControlStateNormal];
        [self.leftButton.titleLabel setTextAlignment:NSTextAlignmentCenter];
        [self.leftButton setFrame:leftRect];
        CGRect centerRect = CGRectMake(36*2+fWidth, 5, fWidth, 33);
        [self.centerButton setFrame:centerRect];
        [self.rightButton setHidden:YES];
    }
    else
    {
        float fWidth = (currWidth-36*4)/3;
        CGRect leftRect = CGRectMake(36, 5, fWidth, 33);
        [self.leftButton setTitle:@"下载" forState:UIControlStateNormal];
        [self.leftButton setFrame:leftRect];
        CGRect centerRect = CGRectMake(fWidth+36*2, 5, fWidth, 33);
        [self.centerButton setFrame:centerRect];
        [self.rightButton setHidden:NO];
        CGRect rightRect = CGRectMake(fWidth*2+36*3, 5, fWidth, 33);
        [self.rightButton setFrame:rightRect];
        if(isCliped)
        {
            fWidth = (currWidth-36*3)/2;
            CGRect leftRect = CGRectMake(36, 5, fWidth, 33);
            [self.leftButton setTitle:@"下载" forState:UIControlStateNormal];
            [self.leftButton.titleLabel setTextAlignment:NSTextAlignmentCenter];
            [self.leftButton setFrame:leftRect];
            CGRect centerRect = CGRectMake(36*2+fWidth, 5, fWidth, 33);
            [self.centerButton setFrame:centerRect];
            [self.rightButton setHidden:YES];
        }
    }
}

#pragma mark 收藏按钮事件
-(void)clipClicked:(id)sender
{
    int page = [[[self.topTitleLabel.text componentsSeparatedByString:@"/"] objectAtIndex:0] intValue]-1;
    PhotoFile *demo = nil;
    if([[tableArray objectAtIndex:page] isKindOfClass:[PhotoFile class]])
    {
        demo = [tableArray objectAtIndex:page];
    }
    NSString *f_id = [NSString stringWithFormat:@"%i",demo.f_id];
    NSString *fileName=nil;
    if ([[FavoritesData sharedFavoritesData] isExistsWithFID:f_id]) {
        for (NSDictionary *dic in [[FavoritesData sharedFavoritesData] allValues]) {
            if ([[dic objectForKey:@"f_id"] isEqualToString:f_id]) {
                fileName=[dic objectForKey:@"f_name"];
                break;
            }
        }
        if (fileName) {
            NSString *filePath=[YNFunctions getFMCachePath];
            filePath=[filePath stringByAppendingPathComponent:fileName];
            if ([[NSFileManager defaultManager] fileExistsAtPath:filePath]) {
                NSError *error=[[NSError alloc] init];
                if ([[NSFileManager defaultManager] removeItemAtPath:filePath error:&error]) {
                    NSLog(@"删除本地收藏文件成功：%@",filePath);
                }else
                {
                    NSLog(@"删除本地收藏文件失败：%@",filePath);
                }
            }
        }
        [[FavoritesData sharedFavoritesData] removeObjectForKey:f_id];
//        hud = [[MBProgressHUD alloc] initWithView:self.view];
//        [self.view addSubview:hud];
//        hud.labelText=@"取消收藏成功";
//        hud.mode=MBProgressHUDModeText;
//        [hud show:YES];
//        [hud hide:YES afterDelay:0.8f];
//        [hud release];
//        hud = nil;
        if(!isCliped)
        {
            [self isHiddenDelete:NO];
        }
        else
        {
            [self.leftButton setTitle:@"下载" forState:UIControlStateNormal];
        }
    }
    else
    {
        //收藏
        /*
         请求详细数据
         */
        SCBPhotoManager *photoManager = [[[SCBPhotoManager alloc] init] autorelease];
        [photoManager setPhotoDelegate:self];
        [photoManager getDetail:demo.f_id];
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
    int page = [[[self.topTitleLabel.text componentsSeparatedByString:@"/"] objectAtIndex:0] intValue]-1;
    PhotoFile *demo = nil;
    if([[tableArray objectAtIndex:page] isKindOfClass:[PhotoFile class]])
    {
        demo = [tableArray objectAtIndex:page];
    }
    if(buttonIndex == 0)
    {
        if([app_delegate respondsToSelector:@selector(sendImageContentIsFiends:path:)])
        {
            //微信朋友圈
            [app_delegate sendImageContentIsFiends:YES path:[NSString stringWithFormat:@"%iT",demo.f_id]];
        }
    }
    if(buttonIndex == 1)
    {
        if([app_delegate respondsToSelector:@selector(sendImageContentIsFiends:path:)])
        {
            //微信好友
            [app_delegate sendImageContentIsFiends:NO path:[NSString stringWithFormat:@"%iT",demo.f_id]];
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
    UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"提示" message:@"是否要删除图片" delegate:self cancelButtonTitle:@"取消" otherButtonTitles:@"确定", nil];
    [alertView show];
    [alertView release];
}

#pragma mark UIAalertViewDelegate
-(void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if(buttonIndex == 1)
    {
        int page = [[[self.topTitleLabel.text componentsSeparatedByString:@"/"] objectAtIndex:0] intValue]-1;
        deletePage = page;
        PhotoFile *demo = nil;
        if([[tableArray objectAtIndex:page] isKindOfClass:[PhotoFile class]])
        {
            demo = [tableArray objectAtIndex:page];
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
        /*
         重新添加数据
         */
        if(deletePage<[tableArray count])
        {
            [tableArray removeObjectAtIndex:deletePage];
        }
        
        if(imageScrollView)
        {
            [imageScrollView removeFromSuperview];
            [imageScrollView release];
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
        [hud release];
        hud = nil;
    }
    else
    {
        hud.labelText=@"删除失败";
        hud.mode=MBProgressHUDModeText;
        [hud hide:YES afterDelay:0.8f];
        [hud release];
        hud = nil;
    }
}

-(void)getFileDetail:(NSDictionary *)dictionary
{
    NSLog(@"dictionary:%@",dictionary);
    if([[dictionary objectForKey:@"code"] intValue] == 0)
    {
        /*
         得到数据后，添加到收藏
         */
        NSDictionary *dic = [[dictionary objectForKey:@"files"] objectAtIndex:0];
        NSString *f_id = [dic objectForKey:@"f_id"];
        [[FavoritesData sharedFavoritesData] setObject:dic forKey:f_id];
        NSLog(@"增加一个收藏，收藏总数: %d",[[FavoritesData sharedFavoritesData] count]);
        hud = [[MBProgressHUD alloc] initWithView:self.view];
        [self.view addSubview:hud];
        hud.labelText=@"下载成功";
        hud.mode=MBProgressHUDModeText;
        [hud show:YES];
        [hud hide:YES afterDelay:0.8f];
        [hud release];
        hud = nil;
//        [self isHiddenDelete:YES];
    }
    else
    {
//        hud = [[MBProgressHUD alloc] initWithView:self.view];
//        [self.view addSubview:hud];
//        hud.labelText=@"收藏失败";
//        hud.mode=MBProgressHUDModeText;
//        [hud show:YES];
//        [hud hide:YES afterDelay:0.8f];
//        [hud release];
//        hud = nil;
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
    if([[imageScrollView viewWithTag:ACTNUMBER+self.page] isKindOfClass:[UIActivityIndicatorView class]])
    {
        UIActivityIndicatorView *activity_indicator = (UIActivityIndicatorView *)[imageScrollView viewWithTag:ACTNUMBER+self.page];
        [activity_indicator stopAnimating];
        [activity_indicator removeFromSuperview];
    }
}


#pragma mark 下载回调
-(void)appImageDidLoad:(NSInteger)indexTag urlImage:(UIImage *)image index:(int)index
{
    dispatch_async(dispatch_get_main_queue(), ^{
    NSLog(@"下载完成后显示开始。。。");
        if([[imageScrollView viewWithTag:indexTag] isKindOfClass:[UIImageView class]])
        {
            UIImage *scaleImage = image;
            UIImageView *imageV = (UIImageView *)[imageScrollView viewWithTag:indexTag];
            if(self.isScape)
            {
                CGSize size = [self getSacpeImageSize:image];
//                scaleImage = [self scaleFromImage:image toSize:size];
                UIScrollView *s = (UIScrollView *)[self.view viewWithTag:indexTag-ImageViewTag+ScrollViewTag];
                s.zoomScale = 1.0;
                [s setContentSize:size];
                int x = s.tag-ScrollViewTag;
                [s setFrame:CGRectMake(currWidth*x, 0, currWidth, currHeight)];
                NSLog(@"第%i个 s:%@",x,NSStringFromCGRect(s.frame));
                CGRect imageFrame = imageV.frame;
                imageFrame.origin = CGPointMake((currWidth-size.width)/2, (currHeight-size.height)/2);
                NSLog(@"imageFrame.origin:%@;size:%@",NSStringFromCGPoint(imageFrame.origin),NSStringFromCGSize(size));
                imageFrame.size = size;
                [imageV setFrame:imageFrame];
            }
            else
            {
                CGSize size = [self getImageSize:image];
//                scaleImage = [self scaleFromImage:image toSize:size];
                UIScrollView *s = (UIScrollView *)[self.view viewWithTag:indexTag-ImageViewTag+ScrollViewTag];
                s.zoomScale = 1.0;
                [s setContentSize:size];
                int x = s.tag-ScrollViewTag;
                [s setFrame:ScrollRect(x,size)];
                CGRect imageFrame = imageV.frame;
                imageFrame.origin = ImagePoint(size);
                imageFrame.size = size;
                [imageV setFrame:imageFrame];
            }
            [imageV performSelectorOnMainThread:@selector(setImage:) withObject:scaleImage waitUntilDone:YES];
            NSLog(@"image:%i",image.retainCount);
        }
        NSLog(@"appImageDidLoad index-------------:%i",index);
        if([[imageScrollView viewWithTag:index] isKindOfClass:[UIActivityIndicatorView class]])
        {
            UIActivityIndicatorView *activity_indicator = (UIActivityIndicatorView *)[imageScrollView viewWithTag:index];
            [activity_indicator stopAnimating];
            [activity_indicator removeFromSuperview];
        }
    NSLog(@"下载完成后显示结束。。。");
    });
}

//<ios 6.0
- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation
{
    return YES;
}

//>ios 6.0
- (BOOL)shouldAutorotate{
    return YES;
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
    NSLog(@"5");
}

//横屏后，修改试图
-(void)isScapeLeftOrRight:(BOOL)bl
{
    NSLog(@"ScollviewWidth:%f,ScollviewHeight:%f",ScollviewWidth,ScollviewHeight);
    if(!self.page)
    {
        self.page = currPage;
    }
    if(bl)
    {
        currWidth = ScollviewHeight+20;
        currHeight = ScollviewWidth-20;
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
                NSLog(@"size1:%@",NSStringFromCGSize(imageview.image.size));
                size = [self getSacpeImageSize:imageview.image];
                NSLog(@"size2:%@",NSStringFromCGSize(size));
                [s setContentSize:size];
                int x = s.tag-ScrollViewTag;
                [s setFrame:CGRectMake(currWidth*x, 0, currWidth, currHeight)];
                CGRect imageFrame = imageview.frame;
                imageFrame.origin = CGPointMake((currWidth-size.width)/2, (currHeight-size.height)/2);
                NSLog(@"size3:%@",NSStringFromCGSize(size));
                imageFrame.size = size;
                [imageview setFrame:imageFrame];
                NSLog(@"size4:%@",NSStringFromCGSize(imageview.image.size));
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
            [self.centerButton setFrame:CGRectMake(36*2+width, 0, width, 44)];
            [self.rightButton setFrame:CGRectMake(36*3+width*2, 0, width, 44)];
        }
        else
        {
            int width = (currWidth-36*4)/3;
            [self.leftButton setFrame:CGRectMake(36, 0, width, 44)];
            [self.centerButton setFrame:CGRectMake(36*2+width, 0, width, 44)];
            [self.rightButton setFrame:CGRectMake(36*3+width*2, 0, width, 44)];
        }
        
    }
    else
    {
        currWidth = ScollviewWidth+20;
        currHeight = ScollviewHeight-20;
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
                NSLog(@"size1:%@",NSStringFromCGSize(imageview.image.size));
                size = [self getImageSize:imageview.image];
                NSLog(@"size2:%@",NSStringFromCGSize(size));
                [s setContentSize:size];
                int x = s.tag-ScrollViewTag;
                [s setFrame:ScrollRect(x,size)];
                CGRect imageFrame = imageview.frame;
                imageFrame.origin = ImagePoint(size);
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
            [self.centerButton setFrame:CGRectMake(36*2+width, 0, width, 44)];
            [self.rightButton setFrame:CGRectMake(36*3+width*2, 0, width, 44)];
        }
        else
        {
            int width = (currWidth-36*4)/3;
            [self.leftButton setFrame:CGRectMake(36, 0, width, 44)];
            [self.centerButton setFrame:CGRectMake(36*2+width, 0, width, 44)];
            [self.rightButton setFrame:CGRectMake(36*3+width*2, 0, width, 44)];
        }
    }
}

-(void)dealloc
{
    NSLog(@"图片预览类死亡 tableArray:%i,imageScrollView:%i",tableArray.retainCount,imageScrollView.retainCount);
    [imageScrollView release];
    [super dealloc];
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

@end
