//
//  YNZoomingScrollView.h
//  NetDisk
//
//  Created by fengyongning on 13-4-8.
//
//

#import <UIKit/UIKit.h>
#import "MWTapDetectingImageView.h"
#import "MWTapDetectingView.h"

@interface YNZoomingScrollView : UIScrollView<UIScrollViewDelegate,MWTapDetectingImageViewDelegate,MWTapDetectingViewDelegate>
{
    id _photoBrowser;
    
    MWTapDetectingView *_tapView; //for background taps
    MWTapDetectingImageView *_photoImageView;
}
-(id)initWithBrowser:(id)browser;
-(void)displayImage;
-(void)displayImageFailure;
-(void)setMaxMinZoomScalesForCurrentBounds;
-(void)prepareForReuse;
@end
