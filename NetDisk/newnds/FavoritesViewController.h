//
//  FavoritesViewController.h
//  NetDisk
//
//  Created by fengyongning on 13-5-16.
//
//

#import <UIKit/UIKit.h>
#import "IconDownloader.h"

@interface FavoritesViewController : UITableViewController<IconDownloaderDelegate,UIDocumentInteractionControllerDelegate>
@property (strong,nonatomic) NSMutableDictionary *imageDownloadsInProgress;
@property (strong,nonatomic) NSString *text;
@end
