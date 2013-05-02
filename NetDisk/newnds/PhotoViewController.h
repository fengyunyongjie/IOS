//
//  PhotoViewController.h
//  NetDisk
//
//  Created by Yangsl on 13-5-2.
//
//

#import <UIKit/UIKit.h>
#import "SCBPhotoManager.h"

@interface PhotoViewController : UIViewController<SCBPhotoDelegate>
{
    SCBPhotoManager *photoManager;
}

@property(nonatomic,retain) SCBPhotoManager *photoManager;

@end
