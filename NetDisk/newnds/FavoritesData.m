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
//        NSString *dataFilePath=[YNFunctions getUserFavoriteDataPath];
//        if ([[NSFileManager defaultManager] fileExistsAtPath:dataFilePath])
//        {
//            [_sharedFavoritesData readFromFile];
//        }else
//        {
//            _sharedFavoritesData.favoriteDic=[NSMutableDictionary dictionary];
//        }
    }
    return _sharedFavoritesData;
}
-(NSArray *)allValues
{
    return self.favoriteController.getAllDatas;
}
-(void)reloadData
{
//    NSString *dataFilePath=[YNFunctions getUserFavoriteDataPath];
//    if ([[NSFileManager defaultManager] fileExistsAtPath:dataFilePath])
//    {
//        [self readFromFile];
//    }else
//    {
//        self.favoriteDic=[NSMutableDictionary dictionary];
//    }
}
- (void)setObject:(id)value forKey:(NSString *)defaultName
{
//    [self.favoriteDic setObject:value forKey:defaultName];
//    [self writeToFile];
    [self.favoriteController insertDic:value];
}
-(void)readFromFile
{
//    NSString *dataFilePath=[YNFunctions getUserFavoriteDataPath];
////    NSError *jsonParsingError=nil;
//    NSData *data=[NSData dataWithContentsOfFile:dataFilePath];
////    NSMutableDictionary *dic=[NSJSONSerialization JSONObjectWithData:data options:0 error:&jsonParsingError];
//    NSMutableDictionary *dic=[NSKeyedUnarchiver unarchiveObjectWithData:data];
//    if (dic) {
//        NSLog(@"收藏文件读取成功");
//        self.favoriteDic=dic;
//    }else
//    {
//        NSLog(@"收藏文件读取失败");
//        self.favoriteDic=[NSMutableDictionary dictionary];
//    }
}
-(void)writeToFile
{
////    if (![[NSFileManager defaultManager] fileExistsAtPath:[YNFunctions getUserFavoriteDataPath]]) {
////        [[NSFileManager defaultManager] createFileAtPath:[YNFunctions getUserFavoriteDataPath] contents:nil attributes:nil];
////    }
////    [self.favoriteDic writeToFile:[YNFunctions getUserFavoriteDataPath] atomically:YES];
//    NSString *dataFilePath=[YNFunctions getUserFavoriteDataPath];
////    NSError *jsonParsingError=nil;
////    NSData *data=[NSJSONSerialization dataWithJSONObject:self.favoriteDic options:0 error:&jsonParsingError];
//    NSData *data=[NSKeyedArchiver archivedDataWithRootObject:self.favoriteDic];
//    BOOL isWrite=[data writeToFile:dataFilePath atomically:YES];
//    if (isWrite) {
//        NSLog(@"写入文件成功：%@",dataFilePath);
//    }else
//    {
//        NSLog(@"写入文件失败：%@",dataFilePath);
//    }
    
}
-(BOOL)isExistsWithFID:(NSString *)f_id
{
    return [self.favoriteController isExistsWithF_ID:f_id];
}
//- (id)objectForKey:(NSString *)defaultName
//{
////    return [self.favoriteDic objectForKey:defaultName];
//}
- (void)removeObjectForKey:(NSString *)defaultName
{
    [self.favoriteController deleteWithF_ID:defaultName];
}
- (int)count
{
    return self.favoriteController.getAllDatas.count;
}
@end
