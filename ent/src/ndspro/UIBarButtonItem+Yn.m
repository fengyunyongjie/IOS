//
//  UIBarButtonItem+Yn.m
//  ndspro
//
//  Created by fengyongning on 13-10-21.
//  Copyright (c) 2013年 fengyongning. All rights reserved.
//

#import "UIBarButtonItem+Yn.h"
#import "YNFunctions.h"

@implementation UIBarButtonItem (Yn)
- (id)initWithTitleStr:(NSString *)title style:(UIBarButtonItemStyle)style target:(id)target action:(SEL)action
{
    if ([YNFunctions systemIsLaterThanString:@"7.0"]) {
        self=[[UIBarButtonItem alloc] initWithTitle:title style:style target:target action:action];
    }else{
        UIButton *button = [[UIButton alloc]initWithFrame:CGRectMake(0,0,71,33)];
        [button setTitle:title forState:UIControlStateNormal];
        button.titleLabel.font=[UIFont systemFontOfSize:14];
        [button sizeToFit];
        [button addTarget:target action:action forControlEvents:UIControlEventTouchUpInside];
        self=[[UIBarButtonItem alloc] initWithCustomView:button];
    }
    return self;
}
@end
