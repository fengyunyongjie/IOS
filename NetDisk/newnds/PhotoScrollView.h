//
//  PhotoScrollView.h
//  NetDisk
//
//  Created by Yangsl on 13-11-13.
//
//

#import <UIKit/UIKit.h>

@protocol PhotoScrollViewDelegate <NSObject>

-(void)updateScrollView:(CGPoint)point;

@end

@interface PhotoScrollView : UIScrollView<UIScrollViewDelegate>

@property(nonatomic,retain) UIImageView *bookImageView;
@property(nonatomic,retain) id<PhotoScrollViewDelegate> delegate;

-(void)updateScrollView:(float)height;

@end
