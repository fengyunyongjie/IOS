//
//  CustomControl.h
//  NetDisk
//
//  Created by Yangsl on 13-8-22.
//
//

#import <UIKit/UIKit.h>

@interface CustomControl : UIControl
{
    NSIndexPath *indexPath;
}

@property(nonatomic,retain) NSIndexPath *indexPath;

@end
