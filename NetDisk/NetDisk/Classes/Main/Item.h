//
//  Item.h
//  NetDisk
//
//  Created by jiangwei on 13-1-20.
//  Copyright (c) 2013年 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface Item : NSObject
{
    NSString *_title;
    BOOL _isChecked;
}
@property (retain, nonatomic) NSString *title;

@property (assign, nonatomic) BOOL isChecked;

@end
