//
//  FileTableViewCell.h
//  NetDisk
//
//  Created by Yangsl on 13-8-26.
//
//

#import <UIKit/UIKit.h>

@interface FileTableViewCell : UITableViewCell
{
    UIButton *select_button;
    UIImageView *image_view;
}

@property(nonatomic,retain) UIButton *select_button;
@property(nonatomic,retain) UIImageView *image_view;

@end
