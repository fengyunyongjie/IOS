//
//  FavoritesData.h
//  NetDisk
//
//  Created by fengyongning on 13-5-16.
//
//

#import <Foundation/Foundation.h>
@class FavoritesDBController;
@class SCBDownloader;
@class FavoritesViewController;

@interface FavoritesData : NSObject
@property (strong,nonatomic) NSArray *favoritesArray;
@property (strong,nonatomic) FavoritesDBController *favoriteController;
@property (strong,nonatomic) NSString *currentDownloadID;
@property (strong,nonatomic) SCBDownloader *currentDownloader;
@property (assign,nonatomic) BOOL isAllFileDownloadFinish;
@property (assign,nonatomic) FavoritesViewController *fviewController;
+(FavoritesData *)sharedFavoritesData;
- (void)setObject:(id)value forKey:(NSString *)defaultName;
-(BOOL)isExistsWithFID:(NSString *)f_id;
- (void)removeObjectForKey:(NSString *)defaultName;
- (int)count;
-(void)reloadData;
-(NSArray *)allValues;
-(void)startDownloading;
@end
