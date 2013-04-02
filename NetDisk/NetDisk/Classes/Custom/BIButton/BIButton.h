//
//  BIButton.h
//  NewsRain
//
//  Created by yinhh on 12-11-21.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//


#import <Foundation/Foundation.h>

typedef enum{
    BIButtonTypeSmall =1,
    BIButtonTypeLocation,
} BIButtonType;

@interface BIButton : UIButton
{
    BIButtonType m_buttonType;
}
@property (nonatomic,assign) BIButtonType m_buttonType;

@end
