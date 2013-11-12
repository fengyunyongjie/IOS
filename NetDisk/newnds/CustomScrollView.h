//
//  CustomScrollView.h
//  NetDisk
//
//  Created by Yangsl on 13-11-11.
//
//

#import <UIKit/UIKit.h>

@interface CustomScrollView : UIScrollView

@property(nonatomic,assign) CGSize scrollViewSize;
@property(nonatomic,retain) UILabel *moveLabel;

@property(nonatomic,retain) UIImageView *back_image;

@end
