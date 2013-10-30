//
//  CustomViewController.h
//  ndspro
//
//  Created by Yangsl on 13-10-21.
//  Copyright (c) 2013年 fengyongning. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol CutomViewControllerDelegate <NSObject>

-(UIViewController *)popToViewController;

@end

@interface CustomViewController : UINavigationController

@property(nonatomic,strong) id<CutomViewControllerDelegate> cutomDelegate;

-(void)goonPopToVuew:(UIViewController *)viewController;

@end
