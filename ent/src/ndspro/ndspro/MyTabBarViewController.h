//
//  MyTabBarViewController.h
//  ndspro
//
//  Created by fengyongning on 13-9-26.
//  Copyright (c) 2013年 fengyongning. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface MyTabBarViewController : UITabBarController
@property(nonatomic,strong) UIImageView *imageView;
@property(nonatomic,strong) UILabel *label;
-(void)addUploadNumber:(NSInteger)count;

@end
