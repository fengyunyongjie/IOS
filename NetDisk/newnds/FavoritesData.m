//
//  FavoritesData.m
//  NetDisk
//
//  Created by fengyongning on 13-5-16.
//
//

#import "FavoritesData.h"
#import "YNFunctions.h"
#import "FavoritesDBController.h"
static FavoritesData *_sharedFavoritesData;
@implementation FavoritesData
+(FavoritesData *)sharedFavoritesData
{
    if (_sharedFavoritesData==nil) {
        _sharedFavoritesData=[[self alloc] init];
        _sharedFavoritesData.favoriteController=[[[FavoritesDBController alloc] init] autorelease];
        [_sharedFavoritesData reloadData];
    }
    return _sharedFavoritesData;
}
-(NSArray *)allValues
{
    if (self.favoritesArray) {
        return self.favoritesArray;
    }
    self.favoritesArray=[self.favoriteController getAllDatas];
    return self.favoritesArray;
}
-(void)reloadData
{
    self.favoritesArray=[self.favoriteController getAllDatas];
}
- (void)setObject:(id)value forKey:(NSString *)defaultName
{
    [self.favoriteController insertDic:value];
    [self reloadData];
}

-(BOOL)isExistsWithFID:(NSString *)f_id
{
    return [self.favoriteController isExistsWithF_ID:f_id];
}
- (void)removeObjectForKey:(NSString *)defaultName
{
    [self.favoriteController deleteWithF_ID:defaultName];
    [self reloadData];
}
- (int)count
{
    return self.favoritesArray.count;
}
@end
