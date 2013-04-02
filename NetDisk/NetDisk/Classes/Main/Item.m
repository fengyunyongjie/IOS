//
//  Item.m
//  NetDisk
//
//  Created by jiangwei on 13-1-20.
//  Copyright (c) 2013年 __MyCompanyName__. All rights reserved.
//

#import "Item.h"

@implementation Item
@synthesize title = _title;
@synthesize isChecked = _isChecked;
- (void)dealloc{
    [_title release];
    [super dealloc];
}

@end
