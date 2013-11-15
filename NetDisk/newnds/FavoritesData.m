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
#import "SCBDownloader.h"
#import "FavoritesViewController.h"
#import "ALAsset+AGIPC.h"
#import "AutoUploadList.h"
#import "NSString+Format.h"
#import "SCBSession.h"

static FavoritesData *_sharedFavoritesData;
@implementation FavoritesData
+(FavoritesData *)sharedFavoritesData
{
    if (_sharedFavoritesData==nil) {
        _sharedFavoritesData=[[self alloc] init];
        _sharedFavoritesData.isAllFileDownloadFinish=YES;
        _sharedFavoritesData.favoriteController=[[[FavoritesDBController alloc] init] autorelease];
        _sharedFavoritesData.fviewController=nil;
        [_sharedFavoritesData reloadData];
        [_sharedFavoritesData startDownloading];
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
    [self startDownloading];
}

-(BOOL)isExistsWithFID:(NSString *)f_id
{
    return [self.favoriteController isExistsWithF_ID:f_id];
}
- (void)removeObjectForKey:(NSString *)defaultName
{
    NSString *f_id=[NSString stringWithFormat:@"%@",defaultName];
    [self.favoriteController deleteWithF_ID:defaultName];
    [self reloadData];
    if ([f_id isEqualToString:self.currentDownloadID] && !self.isAllFileDownloadFinish) {
        [self.currentDownloader cancelDownload];
        [self startDownload];
    }
}
- (int)count
{
    if (!self.favoritesArray) {
        self.favoritesArray=[self.favoriteController getAllDatas];
    }
    return self.favoritesArray.count;
}
-(NSDictionary *)findNextDownloadObject
{
    for (int i=0; i<self.count; i++) {
        NSDictionary *dic=[self.favoritesArray objectAtIndex:i];
        NSString *fileName=[dic objectForKey:@"f_name"];
        NSString *filePath=[YNFunctions getFMCachePath];
        filePath=[filePath stringByAppendingPathComponent:fileName];
        if (![[NSFileManager defaultManager] fileExistsAtPath:filePath]) {
            return dic;
        }
    }
    return nil;
}
-(void)stopDownloading
{
    self.currentDownloadID=nil;
    [self.currentDownloader cancelDownload];
    self.currentDownloader=nil;
    self.isAllFileDownloadFinish=YES;
}
-(void)startDownloading
{
    if (self.isAllFileDownloadFinish) {
        self.isAllFileDownloadFinish=NO;
        [self startDownload];
    }else
    {
        NSLog(@"下载任务队列正常进行中。。。");
    }
    return;
}
-(void)startDownload
{
    if ([YNFunctions networkStatus]==NotReachable) {
        NSLog(@"无网络");
        self.currentDownloadID=nil;
        self.isAllFileDownloadFinish=YES;
        [self downloadFail:0];
        return;
    }
    if ([YNFunctions isOnlyWifi] && [YNFunctions networkStatus]!=ReachableViaWiFi) {
        NSLog(@"设置为仅Wifi上传下载，但Wifi网络不通！！！");
        self.currentDownloadID=nil;
        self.isAllFileDownloadFinish=YES;
        [self downloadFail:0];
        return;
    }
    
    if (!self.currentDownloader) {
        self.currentDownloader=[[[SCBDownloader alloc] init] autorelease];
    }
    NSDictionary *dic=[self findNextDownloadObject];
    if (dic) {
        NSString *f_id=[dic objectForKey:@"f_id"];
        NSString *f_name=[dic objectForKey:@"f_name"];
        NSString *savedPath=[YNFunctions getFMCachePath];
        savedPath=[savedPath stringByAppendingPathComponent:f_name];
        self.currentDownloadID=f_id;
        self.currentDownloader.fileId=self.currentDownloadID;
        self.currentDownloader.index=0;
        self.currentDownloader.savedPath=savedPath;
        self.currentDownloader.delegate=self;
        [self.currentDownloader startDownload];
        NSLog(@"开始下载文件：%@",f_name);
    }else
    {
        NSLog(@"所有文件下载完成");
        self.currentDownloadID=nil;
        self.isAllFileDownloadFinish=YES;
    }
}
-(int)getIndexWithCurrentFID
{
    for (int i=0; i<self.count; i++) {
        NSDictionary *dic=[self.favoritesArray objectAtIndex:i];
        NSString *f_id=[dic objectForKey:@"f_id"];
        if ([f_id isEqualToString:self.currentDownloadID]) {
            return i;
        }
    }
    return -1;
}
#pragma mark - SCBDownloaderDelegate Methods
-(void)fileDidDownload:(int)index
{
    NSLog(@"文件下载完成");
    int theIndex=-1;
    theIndex=[self getIndexWithCurrentFID];
    NSDictionary *dic=[self.favoritesArray objectAtIndex:theIndex];
    NSString *t_fl=[[dic objectForKey:@"f_mime"] lowercaseString];
    if ([t_fl isEqualToString:@"png"]||
        [t_fl isEqualToString:@"jpg"]||
        [t_fl isEqualToString:@"jpeg"]||
        [t_fl isEqualToString:@"bmp"]||
        [t_fl isEqualToString:@"gif"]){
        NSString *filePath=[YNFunctions getFMCachePath];
        NSString *f_name=[dic objectForKey:@"f_name"];
        filePath=[filePath stringByAppendingPathComponent:f_name];
        UIImage *image=[UIImage imageWithContentsOfFile:filePath];
        ALAssetsLibrary *library=[[ALAssetsLibrary alloc] init];
        [library writeImageToSavedPhotosAlbum:[image CGImage] orientation:(ALAssetOrientation)[image imageOrientation] completionBlock:^(NSURL *assetURL, NSError *error) {
            [library assetForURL:assetURL resultBlock:^(ALAsset *asset)
             {
                 AutoUploadList *ls = [[[AutoUploadList alloc] init] autorelease];
                 ls.a_name = [NSString formatNSStringForOjbect:asset.defaultRepresentation.filename];
                 ls.a_user_id = [NSString formatNSStringForOjbect:[[SCBSession sharedSession] userId]];
                 ls.a_state = 1;
                 BOOL bl = [ls selectAutoUploadList];
                 if(!bl)
                 {
                     [ls insertAutoUploadList];
                 }
             }failureBlock:^(NSError *error)
             {
                 NSLog(@"error:%@",error);
             }];
        }];
    }
    if (self.fviewController && [self.fviewController respondsToSelector:@selector(fileDidDownload:)]) {

        if (theIndex>=[self count]||theIndex<0) {
            NSLog(@"数组下标越界：：：：%d",theIndex);
            return;
        }else
        {
            
        }
        [self.fviewController fileDidDownload:[self getIndexWithCurrentFID]];
    }
    
    [self startDownload];
//    [self.downloadProgress setHidden:YES];
//    [self.downloadLabel setText:@"下载完成"];
//    UIDocumentInteractionController *docIC=[[UIDocumentInteractionController interactionControllerWithURL:[NSURL fileURLWithPath:self.savePath]] autorelease];
//    docIC.delegate=self;
//    [docIC presentPreviewAnimated:YES];
//    [self.openItem setEnabled:YES];
}
-(void)updateProgress:(long)size index:(int)index
{
    if (self.fviewController && [self.fviewController respondsToSelector:@selector(updateProgress:index:)]) {
        int theIndex=-1;
        theIndex=[self getIndexWithCurrentFID];
        if (theIndex>=[self count]||theIndex<0) {
            NSLog(@"数组下标越界：：：：%d",theIndex);
            return;
        }else
        {
            
        }
        [self.fviewController updateProgress:size index:[self getIndexWithCurrentFID]];
    }
//    long t_size=[[self.dataDic objectForKey:@"f_size"] intValue];
//    [self.downloadProgress setProgress:(float)size/t_size];
//    NSString *s_size=[YNFunctions convertSize:[NSString stringWithFormat:@"%ld",size]];
//    NSString *s_tsize=[YNFunctions convertSize:[NSString stringWithFormat:@"%ld",t_size]];
//    NSString *text=[NSString stringWithFormat:@"正在下载...(%@/%@)",s_size,s_tsize];
//    [self.downloadLabel setText:text];
}
-(void)downloadFail:(int)error
{
    if (error==1) {
        [self removeObjectForKey:self.currentDownloadID];
        [self.fviewController updateCell];
        NSLog(@"%@:文件在服务器不存在，在本地收藏列表删除！！！",self.currentDownloadID);
        return;
    }
    self.currentDownloadID=nil;
    self.isAllFileDownloadFinish=YES;
    [self performSelector:@selector(startDownloading) withObject:self afterDelay:10.0f];
}
@end
