//
//  PhotoCell.h
//  NetDisk
//
//  Created by Yangsl on 13-5-13.
//
//

#import <UIKit/UIKit.h>
#import "PhotoImageButton.h"

@interface PhotoCell : UITableViewCell
{
    PhotoImageButton *imageViewButton1;
    PhotoImageButton *imageViewButton2;
    PhotoImageButton *imageViewButton3;
    PhotoImageButton *imageViewButton4;
}

@property(nonatomic,retain) PhotoImageButton *imageViewButton1;
@property(nonatomic,retain) PhotoImageButton *imageViewButton2;
@property(nonatomic,retain) PhotoImageButton *imageViewButton3;
@property(nonatomic,retain) PhotoImageButton *imageViewButton4;

@end
