//
//  FavoritesData.h
//  NetDisk
//
//  Created by fengyongning on 13-5-16.
//
//

#import <Foundation/Foundation.h>

@interface FavoritesData : NSObject
@property (strong,nonatomic) NSMutableDictionary *favoriteDic;
+(FavoritesData *)sharedFavoritesData;
- (void)setObject:(id)value forKey:(NSString *)defaultName;
- (id)objectForKey:(NSString *)defaultName;
- (void)removeObjectForKey:(NSString *)defaultName;
- (int)count;
@end
