
#import "Function.h"
#import "SevenCBoxClient.h"
#import "ImageShowViewController.h"

dispatch_queue_t t_queue;

@implementation ImageShowViewController
@synthesize picPath,m_title;
@synthesize leftBtn,rightBtn,titleItem,navBar,m_titleLabel;
@synthesize scrollView;
@synthesize m_bottomView,m_topView;
@synthesize m_listArray,m_index;
- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}



- (void)didReceiveMemoryWarning
{
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
    
    // Release any cached data, images, etc that aren't in use.
}
- (int)currentIndex
{
    int current_index=[scrollView contentOffset].x/[UIScreen mainScreen].bounds.size.width;
    return current_index;
}
- (UIImageView *)currentView
{
    return (UIImageView *)[[scrollView subviews] objectAtIndex:[self currentIndex]];
}
- (void)setPage:(int)page
{
    last_index=page;
    [scrollView setContentOffset:CGPointMake(page*320, scrollView.contentOffset.y)];
    NSDictionary *dataDic=[m_imgListArray objectAtIndex:page];
    NSString *f_name = [dataDic objectForKey:@"f_name"];
    
    NSString *savedImagePath=[[Function getImgCachePath] stringByAppendingPathComponent:f_name];
    NSString *f_id = [Function covertNumberToString:[dataDic objectForKey:@"f_id"]];
    if([Function fileSizeAtPath:savedImagePath]<2)
    {
        NSString *keepedImagePath=[[Function getKeepCachePath] stringByAppendingPathComponent:f_name];
        if([Function fileSizeAtPath:keepedImagePath]<2)//下载
        {
            SevenCBoxClient::FmDownloadFile([f_id cStringUsingEncoding:NSUTF8StringEncoding],[savedImagePath cStringUsingEncoding:NSUTF8StringEncoding]);
            SevenCBoxClient::StartTaskMonitor();
        }
    }
    [self loadImage:page];
    //再加载左右各两张图片
    [self loadImage:page+1];
    [self loadImage:page+2];
    [self loadImage:page-1];
    [self loadImage:page-2];
}
-(void)loadImage:(int)index
{
    if (index<0||index>=[m_imgListArray count]) {
        return;
    }
    UIImageView *iv=(UIImageView *)[[scrollView subviews] objectAtIndex:index];
    if (iv.image && iv.tag==3) {
        return;
    }
    NSDictionary *dataDic=[m_imgListArray objectAtIndex:index];
    NSString *f_name=[dataDic objectForKey:@"f_name"];
    NSString *savedImagePath=[[Function getImgCachePath] stringByAppendingPathComponent:f_name];
    if ([Function fileSizeAtPath:savedImagePath]<2) {
        if (iv.tag==2) {
            return;
        }
        NSString *picName = [Function picFileNameFromURL:[dataDic objectForKey:@"compressaddr"]];
        NSString *path = [NSString stringWithFormat:@"%@/%@",[Function getTempCachePath],picName];
        iv.image=[UIImage imageWithContentsOfFile:path];
        [iv setTag:2];
    }else
    {
        UIImage *newImg=[UIImage imageWithContentsOfFile:savedImagePath];
        NSLog(@"原图大小：width: %f, height: %f, 占用内存: %ld",newImg.size.width,newImg.size.height,sizeof(newImg));
        float s_w=newImg.size.width/640.0f;
        float s_h=newImg.size.height/960.0f;
        UIImage *s_img=nil;
        if (s_w>1.5&s_h>1.5) {
            if (s_w>s_h) {
                s_img=[self scaleImage:newImg toScale:s_w];
            }else
            {
                s_img=[self scaleImage:newImg toScale:s_h];
            }
        }
        if (s_img!=nil) {
            iv.image=s_img;
        }else
        {
            iv.image=newImg;
        }
        //NSData *dataObj=UIImageJPEGRepresentation(newImg);
       // NSLog(@"修改之后：width: %f, height: %f, 占用内存: %ld",iv.ima ge.size.width,iv.image.size.height,);
        [iv setTag:3];
    }
}
-(void)releaseImage:(int)index
{
    if (index<0||index>=[m_imgListArray count]) {
        return;
    }
    UIImageView *iv=(UIImageView *)[ [scrollView subviews] objectAtIndex:index];
    iv.image =nil;
    [iv setTag:1];
}
- (void)layoutScrollImages
{
	UIImageView *view = nil;
	NSArray *subviews = [scrollView subviews];
    
	// reposition all image subviews in a horizontal serial fashion
	CGFloat curXLoc = - [UIScreen mainScreen].bounds.size.width;
	for (view in subviews)
	{
		if ([view isKindOfClass:[UIImageView class]] && view.tag >= 0)
		{
			CGRect frame = view.frame;
			frame.origin = CGPointMake(curXLoc, 0);
			view.frame = frame;
			
			curXLoc += ([UIScreen mainScreen].bounds.size.width);
		}
	}
	// set the content size so it can be scrollable
	[scrollView setContentSize:CGSizeMake((m_imgListArray.count * [UIScreen mainScreen].bounds.size.width), [UIScreen mainScreen].bounds.size.height-80)];
}

-(void)update:(NSTimer*)theTimer{
 
    int current_index=[self currentIndex];
    UIImageView *iv=[[scrollView subviews] objectAtIndex:current_index];
    if (iv.tag!=3) {
        [self loadImage:current_index];
    }
}

-(void)loadImages
{
    m_imgListArray=[[NSMutableArray alloc] init];
    for (int i=0;i<m_listArray.count;i++)
    {
        NSDictionary *dic=[m_listArray objectAtIndex:i];
        NSString *t_fl=[[dic objectForKey:@"f_mime"] lowercaseString];
        if ([t_fl isEqualToString:@"png"]||
            [t_fl isEqualToString:@"jpg"]||
            [t_fl isEqualToString:@"jpeg"]||
            [t_fl isEqualToString:@"bmp"]) {
            [m_imgListArray addObject:dic];
            if (i==m_index) {
                new_index=m_imgListArray.count-1;
            }
        }
    }
    
    for (int i=0;i<m_imgListArray.count;i++)
    {
        NSDictionary *dic=[m_imgListArray objectAtIndex:i];
        NSString *f_name=[dic objectForKey:@"f_name"];
        NSString *t_fl=[[dic objectForKey:@"f_mime"] lowercaseString];
        if ([t_fl isEqualToString:@"png"]||
            [t_fl isEqualToString:@"jpg"]||
            [t_fl isEqualToString:@"jpeg"]||
            [t_fl isEqualToString:@"bmp"]) {
            //不在这里加载图片，加载的太多，占用内存太大，造成程序崩溃
            //NSLog(@"f_name=%@,i=%d, f_mime=%@",f_name,i,t_fl);
//            NSString *path=[[Function getImgCachePath] stringByAppendingPathComponent:f_name];
//            if (path==nil||[path isEqualToString:@""]) {
//                path=@"u0_original.png";
//            }
//            else
//            {
//                UIImage *image= [UIImage imageWithContentsOfFile:path];
//                if (image) {
//                }else
//                {
//                    NSString *picName = [Function picFileNameFromURL:[dic objectForKey:@"compressaddr"]];
//                    path = [NSString stringWithFormat:@"%@/%@",[Function getTempCachePath],picName];
//                    image=[UIImage imageWithContentsOfFile:path];              }
//                UIImageView *_imageView=[[UIImageView alloc] initWithImage:image];
//                _imageView.contentMode=UIViewContentModeScaleAspectFit;
//                CGRect rect=_imageView.frame;
//                rect.size.height=[[UIScreen mainScreen] bounds].size.height;
//                rect.size.width=[[UIScreen mainScreen] bounds].size.width;
//                _imageView.frame=rect;
//                _imageView.tag=i;
//                [scrollView addSubview:_imageView];
//                [_imageView release];
//            }
            UIImageView *_imageView=[[UIImageView alloc] init];
            _imageView.contentMode=UIViewContentModeScaleAspectFit;
            CGRect rect=_imageView.frame;
            rect.size.height=[[UIScreen mainScreen] bounds].size.height;
            rect.size.width=[[UIScreen mainScreen] bounds].size.width;
            _imageView.frame=rect;
            _imageView.tag=1;           //imageView.tag :      1:为无图， 2：为小图， 3：大图
            [scrollView addSubview:_imageView];
            [_imageView release];
        }
        
    }
    [self layoutScrollImages];
    [self setPage:new_index];
}
-(id)userInfo
{
    return @"userinfo";
}
-(void)invocationMethod:(NSDate *)date{
    NSLog(@"Invocation for timer started on %@",date);
}
#pragma mark - View lifecycle

- (void)viewDidLoad
{
    [super viewDidLoad];
    updateTimer=[NSTimer scheduledTimerWithTimeInterval:1.0f target:self selector:@selector(update:) userInfo:[self userInfo] repeats:YES];
    
    //添加单击手势
    UITapGestureRecognizer *singleTapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(hidenTopView)];
    singleTapGesture.numberOfTouchesRequired = 1;
    singleTapGesture.numberOfTapsRequired = 1;
    singleTapGesture.delegate = self;
    [scrollView addGestureRecognizer:singleTapGesture];
    [singleTapGesture release];
    
    m_titleLabel.text = m_title;
    [m_topView setHidden:NO];
    self.navigationItem.title = @"图片";
    
    self.view.backgroundColor = [UIColor colorWithRed:0.0 green:0.0 blue:0.0 alpha:0.9];
//    UITapGestureRecognizer *singleTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(handleSingleTap:)];
    
    [scrollView setBackgroundColor:[UIColor blackColor]];
    [scrollView setCanCancelContentTouches:NO];
    scrollView.indicatorStyle=UIScrollViewIndicatorStyleWhite;
    scrollView.clipsToBounds=YES;
    scrollView.scrollEnabled=YES;
    scrollView.pagingEnabled=YES;
    //t_queue =dispatch_queue_create("netdisk.image", NULL);
    
    [self performSelector:@selector(loadImages) withObject:self afterDelay:0];
    
    
    //[NSThread detachNewThreadSelector:@selector(loadImages) toTarget:self withObject:nil];
    //[self loadImages];
//    NSLog(@"new_index=%d",new_index);
/*
    CGRect frame = CGRectMake(0, 0, 320, 460);
    // Create a scroll view
  //  scrollView = [[UIScrollView alloc] initWithFrame:frame];
  //  scrollView.delegate = self;
    scrollView.bouncesZoom = YES;
    scrollView.backgroundColor = [UIColor clearColor];
    
    // Create a container view. We need to return this in -viewForZoomingInScrollView: below.
    containerView = [[UIView alloc] initWithFrame:CGRectZero];
    containerView.backgroundColor = [UIColor blackColor];
    [scrollView addSubview:containerView];
    
    // Create an image view for each of our images
    CGFloat maximumWidth = 0.0;
    CGFloat totalHeight = 0.0;

 //   UIImage *image =  [UIImage imageNamed:@"1.jpg"];
 //   CGSize imageSize = CGSizeMake(image.size.width, image.size.height);
 //   picPath = @"http://ww4.sinaimg.cn/bmiddle/4e5b54d8gw1dvjy5v3e0tj.jpg";
    
//    frame.size = imageSize;
    imageView = [[UIImageView alloc] initWithFrame:frame];
    UIImage *_image = nil;
    if (picPath==nil||[picPath isEqualToString:@""]) {
        picPath=@"u0_original.png";
        _image = [UIImage imageNamed:picPath];
    }
    else
    {
        _image = [UIImage imageWithContentsOfFile:picPath];
    }
    
    imageView.image= _image;
  //  imageView.contentMode = UIViewContentModeTop;
//    [imageView setUrl:[NSURL URLWithString:picPath]];
    
  //  imageView.image = image;
    
    
    CGSize imageSize= CGSizeMake(320, 436);
    
    // Add it as a subview of the container view.
    [containerView addSubview:imageView];
    

    // Increment our maximum width & total height.
    maximumWidth = MAX(maximumWidth, imageSize.width);
    totalHeight = imageSize.height;

    
    // Size the container view to fit. Use its size for the scroll view's content size as well.
    containerView.frame = CGRectMake(0, 0, maximumWidth, totalHeight);
    scrollView.contentSize = containerView.frame.size;
    
    // Minimum and maximum zoom scales
    scrollView.minimumZoomScale = scrollView.frame.size.width / maximumWidth;
    scrollView.maximumZoomScale = 2.0;
    
 //   [self.view addSubview:scrollView];
    
    [containerView addGestureRecognizer:singleTap];
    [singleTap release];
   
  /*  
    indicatorView = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhite];
    [self.view addSubview:indicatorView];
    [indicatorView setCenter:CGPointMake(self.view.frame.size.width/2, self.view.frame.size.height/2)];
    
  */
}
- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
  //  navBar.hidden = YES;
    [indicatorView stopAnimating];
}
- (void)viewDidUnload
{
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}
- (void)setData:(NSDictionary *)theNewsData
{

    newsData = theNewsData;
    
}
- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    // Return YES for supported orientations
    //return (interfaceOrientation == UIInterfaceOrientationPortrait);
    return NO;
}
- (void)handleSingleTap:(UIGestureRecognizer *)gestureRecognizer {
    
  //  navBar.hidden = !navBar.hidden;
    m_topView.hidden = !m_topView.hidden;
}
- (IBAction)comeBack:(id)sender
{
    [self.navigationController popViewControllerAnimated:YES];
    [updateTimer invalidate];
}
-(IBAction)pushButtonAction:(id)sender
{
    UIActionSheet *as_d = [[UIActionSheet alloc] initWithTitle:nil
                                                      delegate:nil
                                             cancelButtonTitle:nil
                                        destructiveButtonTitle:nil
                                             otherButtonTitles:nil];
    as_d.tag = 1;
    [as_d addButtonWithTitle:NSLocalizedString(@"移动至其他文件夹",nil)];
    [as_d addButtonWithTitle:NSLocalizedString(@"设为收藏",nil)];
    [as_d addButtonWithTitle:NSLocalizedString(@"共享给好友",nil)];
    [as_d addButtonWithTitle:NSLocalizedString(@"取消",nil)];
    as_d.cancelButtonIndex = [as_d numberOfButtons]-1;
    
    [as_d showInView:self.view];
    [as_d release];
}
-(IBAction)restoreButtonAction:(id)sender
{
    UIImageWriteToSavedPhotosAlbum([self currentView].image, self,@selector(image:didFinishSavingWithError:contextInfo:), nil);
}

#if 1  
- (void)image:(UIImage *)image didFinishSavingWithError:(NSError *)error contextInfo:(void *)contextInfo  
{  
    if (error == nil)  
    {
        UIAlertView* alertView = [[UIAlertView alloc]initWithTitle:@"提示" 
                                                           message:@"图片保存成功！" 
                                                          delegate:self
                                                 cancelButtonTitle:@"确定" 
                                                 otherButtonTitles:nil];
        [alertView show];
        [alertView release];
    }
    else  
    {

        UIAlertView* alertView = [[UIAlertView alloc]initWithTitle:@"提示" 
                                                           message:@"图片保存失败！" 
                                                          delegate:self
                                                 cancelButtonTitle:@"取消" 
                                                 otherButtonTitles:@"重试",nil];
        [alertView show];
        [alertView release];
    }
}  
#endif
#pragma mark - UIAlertViewDelegate Methods

- (void)alertView:(UIAlertView *)alertView didDismissWithButtonIndex:(NSInteger)buttonIndex
{
    if (buttonIndex==1) {
        UIImageWriteToSavedPhotosAlbum(imageView.image, self,@selector(image:didFinishSavingWithError:contextInfo:), nil);
    }
}

- (UIView *)viewForZoomingInScrollView:(UIScrollView *)scrollView
{
    return containerView;
}
- (void)dealloc {
    [imageView release];
    [indicatorView release],indicatorView=nil;
    [scrollView release];
    [containerView release];
    
    if (leftBtn!=nil) [leftBtn release];
    if (rightBtn!=nil) [rightBtn release];
    if (navBar!=nil) [navBar release];
    if (titleItem!=nil) [titleItem release];
    if (m_topView!=nil) [m_topView release];
    
    [picPath release];
    [super dealloc];
}

#pragma mark - UIScrollViewDelegate Methods
- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView
{
    int index=[self currentIndex];
    NSDictionary *dataDic=[m_imgListArray objectAtIndex:index];
    NSString *f_name = [dataDic objectForKey:@"f_name"];
    
    NSString *savedImagePath=[[Function getImgCachePath] stringByAppendingPathComponent:f_name];
    NSString *f_id = [Function covertNumberToString:[dataDic objectForKey:@"f_id"]];
    if([Function fileSizeAtPath:savedImagePath]<2)
    {
        SevenCBoxClient::FmDownloadFile([f_id cStringUsingEncoding:NSUTF8StringEncoding],[savedImagePath cStringUsingEncoding:NSUTF8StringEncoding]);
    }
    NSLog(@"scrollViewDidScroll:index=%d",index);
    UIImageView *iv=(UIImageView *)[[scrollView subviews] objectAtIndex:index];
    if (!iv.image) {
        [self loadImage:index];
    }
    if (last_index<index) {
        [self loadImage:index+2];
        [self releaseImage:index-3];
    }else if(last_index>index){
        [self loadImage:index-2];
        [self releaseImage:index+3];
    }
    last_index=index;
    //[self performSelector:@selector(load5Image) withObject:self afterDelay:0.1];
}
-(void)load5Image
{
    int index=[self currentIndex];
    [self loadImage:index+2];
    [self releaseImage:index+3];
    [self loadImage:index-2];
    [self releaseImage:index-3];
}

//单击隐藏顶部view，再单击显示
-(void)hidenTopView{
    [m_topView setHidden:!(m_topView.hidden)];
    [[UIApplication sharedApplication] setStatusBarHidden:![UIApplication sharedApplication].statusBarHidden];
}

#pragma mark - UIImage Methods
-(UIImage *)scaleImage:(UIImage*)image toScale:(float)scaleSize
{
    UIGraphicsBeginImageContext(CGSizeMake(image.size.width/scaleSize,image.size.height/scaleSize));
    [image drawInRect:CGRectMake(0, 0, image.size.width/scaleSize,image.size.height/scaleSize)];
    UIImage *scaledImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return scaledImage;
}

@end
