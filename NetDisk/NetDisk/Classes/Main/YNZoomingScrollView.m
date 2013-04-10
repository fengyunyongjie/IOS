//
//  YNZoomingScrollView.m
//  NetDisk
//
//  Created by fengyongning on 13-4-8.
//
//

#import "YNZoomingScrollView.h"
#import "Function.h"

@interface YNZoomingScrollView()
@property(nonatomic,assign) id photoBrowser;
-(void)handleSingleTap:(CGPoint)touchPoint;
-(void)handleDoubleTap:(CGPoint)touchPoint;

@end

@implementation YNZoomingScrollView
@synthesize photoBrowser=_photoBrowser;
- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
    }
    return self;
}
-(id)initWithBrowser:(id)browser
{
    if ((self=[super init])) {
        //Delegate
        self.photoBrowser=browser;
        
        //Tap View for background
        _tapView=[[MWTapDetectingView alloc] initWithFrame:self.bounds];
        _tapView.tapDelegate=self;
        _tapView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
		_tapView.backgroundColor = [UIColor blackColor];
		[self addSubview:_tapView];
        
        // Image view
		_photoImageView = [[MWTapDetectingImageView alloc] initWithFrame:CGRectZero];
		_photoImageView.tapDelegate = self;
		_photoImageView.contentMode = UIViewContentModeCenter;
		_photoImageView.backgroundColor = [UIColor blackColor];
		[self addSubview:_photoImageView];
        
        // Setup
		self.backgroundColor = [UIColor blackColor];
		self.delegate = self;
		self.showsHorizontalScrollIndicator = NO;
		self.showsVerticalScrollIndicator = NO;
		self.decelerationRate = UIScrollViewDecelerationRateFast;
		self.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
        self.frame=[[UIScreen mainScreen] bounds];
    }
    return self;
}
-(void)dealloc{
    [_tapView release];
	[_photoImageView release];
	[super dealloc];
    
}
- (void)prepareForReuse {
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
-(void)updateImage
{
    if (self.imgTag!=2) {
        return;
    }
    NSString *oPath=[[Function getImgCachePath] stringByAppendingPathComponent:[[self dataDic] objectForKey:@"f_name"]];
//    NSString *tPath=[NSString stringWithFormat:@"%@/%@",[Function getTempCachePath],[Function picFileNameFromURL:[[self dataDic] objectForKey:@"compressaddr"]]];
    if ([Function fileSizeAtPath:oPath]<2) {
        oPath=[[Function getKeepCachePath] stringByAppendingPathComponent:[[self dataDic] objectForKey:@"f_name"]];
        if ([Function fileSizeAtPath:oPath]<2) {
            return;
        }
    }
    UIImage *img=[UIImage imageWithContentsOfFile:oPath];
    float s_w=img.size.width/1024.0f;
    float s_h=img.size.height/1024.0f;
    //UIImage *s_img=nil;
    if (s_w>1.5&s_h>1.5) {
        if (s_w>s_h) {
            img=[self scaleImage:img toScale:s_w];
        }else
        {
            img=[self scaleImage:img toScale:s_h];
        }
    }
    if (img) {
        // Set image
        _photoImageView.image = img;
        _photoImageView.hidden = NO;
        
        // Setup photo frame
        CGRect photoImageViewFrame;
        photoImageViewFrame.origin = CGPointZero;
        photoImageViewFrame.size = img.size;
        _photoImageView.frame = photoImageViewFrame;
        self.contentSize = photoImageViewFrame.size;
        // Set zoom to minimum zoom
        [self setMaxMinZoomScalesForCurrentBounds];
        
    }
    [self setNeedsLayout];
    self.imgTag=3;
}
#pragma mark - Image
-(void)testDisplayImage:(NSDictionary *)datadic{
    self.dataDic=datadic;
    if (_photoImageView.image==nil) {
		// Reset
		self.maximumZoomScale = 1;
		self.minimumZoomScale = 1;
		self.zoomScale = 1;
		self.contentSize = CGSizeMake(0, 0);
        
        NSString *oPath=[[Function getImgCachePath] stringByAppendingPathComponent:[datadic objectForKey:@"f_name"]];
        //NSString *savedImagePath=[[Function getKeepCachePath] stringByAppendingPathComponent:[datadic objectForKey:@"f_name"]];
        NSString *tPath=[NSString stringWithFormat:@"%@/%@",[Function getTempCachePath],[Function picFileNameFromURL:[datadic objectForKey:@"compressaddr"]]];
        if ([Function fileSizeAtPath:oPath]<2) {
            oPath=[[Function getKeepCachePath] stringByAppendingPathComponent:[datadic objectForKey:@"f_name"]];
        }
		// Get image from browser as it handles ordering of fetching
		UIImage *img;
        if ([Function fileSizeAtPath:oPath]<2) {
            img= [UIImage imageWithContentsOfFile:tPath];
            self.imgTag=2;
        }else{
            self.imgTag=3;
            img= [UIImage imageWithContentsOfFile:oPath];
            float s_w=img.size.width/1024.0f;
            float s_h=img.size.height/1024.0f;
            //UIImage *s_img=nil;
            if (s_w>1.5&s_h>1.5) {
                if (s_w>s_h) {
                    img=[self scaleImage:img toScale:s_w];
                }else
                {
                    img=[self scaleImage:img toScale:s_h];
                }
            }
//            if (s_img!=nil) {
//                [img release];
//                img=s_img;
//            }
        }
        //img= [UIImage imageWithContentsOfFile:tPath];
		if (img) {
			// Set image
			_photoImageView.image = img;
			_photoImageView.hidden = NO;

			// Setup photo frame
			CGRect photoImageViewFrame;
			photoImageViewFrame.origin = CGPointZero;
			photoImageViewFrame.size = img.size;
			_photoImageView.frame = photoImageViewFrame;
			self.contentSize = photoImageViewFrame.size;
			// Set zoom to minimum zoom
			[self setMaxMinZoomScalesForCurrentBounds];
			
		} else {
			
			// Hide image view
			_photoImageView.hidden = YES;
			
		}
		[self setNeedsLayout];
    }
}
// Get and display image
- (void)displayImage {
//	if (_photo && _photoImageView.image == nil) {
//		
//		// Reset
//		self.maximumZoomScale = 1;
//		self.minimumZoomScale = 1;
//		self.zoomScale = 1;
//		self.contentSize = CGSizeMake(0, 0);
//		
//		// Get image from browser as it handles ordering of fetching
//		UIImage *img = [self.photoBrowser imageForPhoto:_photo];
//		if (img) {
//			
//			// Hide spinner
//			[_spinner stopAnimating];
//			
//			// Set image
//			_photoImageView.image = img;
//			_photoImageView.hidden = NO;
//			
//			// Setup photo frame
//			CGRect photoImageViewFrame;
//			photoImageViewFrame.origin = CGPointZero;
//			photoImageViewFrame.size = img.size;
//			_photoImageView.frame = photoImageViewFrame;
//			self.contentSize = photoImageViewFrame.size;
//            
//			// Set zoom to minimum zoom
//			[self setMaxMinZoomScalesForCurrentBounds];
//			
//		} else {
//			
//			// Hide image view
//			_photoImageView.hidden = YES;
//			[_spinner startAnimating];
//			
//		}
//		[self setNeedsLayout];
//	}
}

// Image failed so just show black!
- (void)displayImageFailure {
//	[_spinner stopAnimating];
}

#pragma mark - Setup

- (void)setMaxMinZoomScalesForCurrentBounds {
	
	// Reset
	self.maximumZoomScale = 1;
	self.minimumZoomScale = 1;
	self.zoomScale = 1;
	
	// Bail
	if (_photoImageView.image == nil) return;
	
	// Sizes
    CGSize boundsSize = self.bounds.size;
    CGSize imageSize = _photoImageView.frame.size;
    
    // Calculate Min
    CGFloat xScale = boundsSize.width / imageSize.width;    // the scale needed to perfectly fit the image width-wise
    CGFloat yScale = boundsSize.height / imageSize.height;  // the scale needed to perfectly fit the image height-wise
    CGFloat minScale = MIN(xScale, yScale);                 // use minimum of these to allow the image to become fully visible
	
	// If image is smaller than the screen then ensure we show it at
	// min scale of 1
	if (xScale > 1 && yScale > 1) {
		minScale = 1.0;
	}
    
	// Calculate Max
	CGFloat maxScale = 2.0; // Allow double scale
    // on high resolution screens we have double the pixel density, so we will be seeing every pixel if we limit the
    // maximum zoom scale to 0.5.
	if ([UIScreen instancesRespondToSelector:@selector(scale)]) {
		maxScale = maxScale / [[UIScreen mainScreen] scale];
	}
	
	// Set
	self.maximumZoomScale = maxScale;
	self.minimumZoomScale = minScale;
	self.zoomScale = minScale;
	
	// Reset position
	_photoImageView.frame = CGRectMake(0, 0, _photoImageView.frame.size.width, _photoImageView.frame.size.height);
	[self setNeedsLayout];
    
}
#pragma mark - Layout

- (void)layoutSubviews {
	
	// Update tap view frame
	_tapView.frame = self.bounds;
	
	// Spinner
//	if (!_spinner.hidden) _spinner.center = CGPointMake(floorf(self.bounds.size.width/2.0),
//                                                        floorf(self.bounds.size.height/2.0));
	// Super
	[super layoutSubviews];
	
    // Center the image as it becomes smaller than the size of the screen
    CGSize boundsSize = self.bounds.size;
    CGRect frameToCenter = _photoImageView.frame;
    
    // Horizontally
    if (frameToCenter.size.width < boundsSize.width) {
        frameToCenter.origin.x = floorf((boundsSize.width - frameToCenter.size.width) / 2.0);
	} else {
        frameToCenter.origin.x = 0;
	}
    
    // Vertically
    if (frameToCenter.size.height < boundsSize.height) {
        frameToCenter.origin.y = floorf((boundsSize.height - frameToCenter.size.height) / 2.0);
	} else {
        frameToCenter.origin.y = 0;
	}
    
	// Center
	if (!CGRectEqualToRect(_photoImageView.frame, frameToCenter))
		_photoImageView.frame = frameToCenter;
	
}

#pragma mark - UIScrollViewDelegate

- (UIView *)viewForZoomingInScrollView:(UIScrollView *)scrollView {
	return _photoImageView;
}

- (void)scrollViewWillBeginDragging:(UIScrollView *)scrollView {
	//[_photoBrowser cancelControlHiding];
}

- (void)scrollViewWillBeginZooming:(UIScrollView *)scrollView withView:(UIView *)view {
	//[_photoBrowser cancelControlHiding];
}

- (void)scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate {
	//[_photoBrowser hideControlsAfterDelay];
}

#pragma mark - Tap Detection

- (void)handleSingleTap:(CGPoint)touchPoint {
	//[_photoBrowser performSelector:@selector(toggleControls) withObject:nil afterDelay:0.2];
}

- (void)handleDoubleTap:(CGPoint)touchPoint {
	
	// Cancel any single tap handling
	//[NSObject cancelPreviousPerformRequestsWithTarget:_photoBrowser];
	
	// Zoom
	if (self.zoomScale == self.maximumZoomScale) {
		
		// Zoom out
		[self setZoomScale:self.minimumZoomScale animated:YES];
		
	} else {
		
		// Zoom in
		[self zoomToRect:CGRectMake(touchPoint.x, touchPoint.y, 1, 1) animated:YES];
		
	}
	
	// Delay controls
	//[_photoBrowser hideControlsAfterDelay];
	
}
#pragma mark - MWTapDetectingImageViewDelegate Method
// Image View
- (void)imageView:(UIImageView *)imageView singleTapDetected:(UITouch *)touch {
    [self handleSingleTap:[touch locationInView:imageView]];
}
- (void)imageView:(UIImageView *)imageView doubleTapDetected:(UITouch *)touch {
    [self handleDoubleTap:[touch locationInView:imageView]];
}

// Background View
- (void)view:(UIView *)view singleTapDetected:(UITouch *)touch {
    [self handleSingleTap:[touch locationInView:view]];
}
- (void)view:(UIView *)view doubleTapDetected:(UITouch *)touch {
    [self handleDoubleTap:[touch locationInView:view]];
}

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect
{
    // Drawing code
}
*/

@end
