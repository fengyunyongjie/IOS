//
//  BIButton.m
//  NewsRain
//
//  Created by jiangwei on 12-11-21.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import "BIButton.h"

@implementation BIButton
@synthesize m_buttonType;

- (CGRect)imageRectForContentRect:(CGRect)contentRect
{
    switch (m_buttonType) {
            
        case BIButtonTypeSmall:
            return CGRectMake(12, 12, 25, 25);
            break;
            
        case BIButtonTypeLocation:
        {
            CGRect rect = contentRect;
            rect.origin.x = 8;
            return rect;
        }
            break;  
            
        default:
            return contentRect;
            break;
    }
}

@end
