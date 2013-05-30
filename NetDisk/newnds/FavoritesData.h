//
//  FavoritesData.h
//  NetDisk
//
//  Created by fengyongning on 13-5-16.
//
//

#import <Foundation/Foundation.h>
@class FavoritesDBController;
@interface FavoritesData : NSObject
@property (strong,nonatomic) NSMutableDictionary *favoriteDic;
@property (strong,nonatomic) FavoritesDBController *favoriteController;
+(FavoritesData *)sharedFavoritesData;
- (void)setObject:(id)value forKey:(NSString *)defaultName;
//- (id)objectForKey:(NSString *)defaultName;
-(BOOL)isExistsWithFID:(NSString *)f_id;
- (void)removeObjectForKey:(NSString *)defaultName;
- (int)count;
-(void)reloadData;
-(NSArray *)allValues;
@end
