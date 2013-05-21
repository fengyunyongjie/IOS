//
//  FavoritesViewController.h
//  NetDisk
//
//  Created by fengyongning on 13-5-16.
//
//

#import <UIKit/UIKit.h>
#import "IconDownloader.h"

@interface FavoritesViewController : UITableViewController<IconDownloaderDelegate>
@property (strong,nonatomic) NSMutableDictionary *imageDownloadsInProgress;
@end
