//
//  SCBFileManager.h
//  NetDisk
//
//  Created by fengyongning on 13-4-15.
//
//

#import <Foundation/Foundation.h>
typedef enum {
    kFMTypeOpenFinder,
    kFMTypeOpenCategoryFile,
    kFMTypeOpenCategoryDir,
    kFMTypeRemove,
    kFMTypeRename,
    kFMTypeMove,
    kFMTypeOperateUpdate,
    kFMTypeNewFinder,
    kFMTypeSearch,
    kFMTypeFamily
}kFMType;
@protocol SCBFileManagerDelegate;
@interface SCBFileManager : NSObject
{
    BOOL isFamily;
}
@property (nonatomic,assign)id<SCBFileManagerDelegate> delegate;
@property (strong,nonatomic) NSMutableData *activeData;
@property (assign,nonatomic) kFMType fm_type;
@property (nonatomic,assign) BOOL isFamily;
-(void)cancelAllTask;
//打开网盘/fm
-(void)openFinderWithID:(NSString *)f_id sID:(NSString *)s_id;      //无分页：所以cursor=0,offset=-1;
-(void)operateUpdateWithID:(NSString *)f_id;
//打开移动目录
-(void)requestMoveFile:(NSString *)f_pid fIds:(NSArray *)f_ids;
//新建/fm/mkdir
-(void)newFinderWithName:(NSString *)f_name pID:(NSString*)f_pid sID:(NSString *)s_id;
//重命名/fm/rename
-(void)renameWithID:(NSString *)f_id newName:(NSString *)f_name;
//复制粘贴/fm/copypaste
-(void)copyFileIDs:(NSArray *)f_ids toPID:(NSString *)f_pid toSpaceId:(NSString *)spaceId toPidSpaceId:(NSString *)sp_id;
//剪切粘贴/fm/cutpaste
-(void)moveFileIDs:(NSArray *)f_ids toPID:(NSString *)f_pid;
//移除/fm/rm
-(void)removeFileWithIDs:(NSArray*)f_ids;
//搜索/fm/search
-(void)searchWithQueryparam:(NSString *)f_queryparam;
//根据类别查看文件夹/fm/category_dir
-(void)openFinderWithCategory:(NSString *)category;
//查看类别文件/fm/category_file
-(void)openFileWithID:(NSString *)f_id category:(NSString *)category;
//打开空间成员
-(void)requestOpenFamily:(NSString *)space_id;
//打开网盘收站/fm/trash
//彻底删除/fm/trash/del
//清空回收站/fm/trash/delall
//恢复/fm/trash/resume
//恢复所有/fm/trash/resumeall
//上传状态/fm/upload/state
//上传/fm/upload
//上传校验/fm/upload/verify
//下载/fm/download
//获取文件信息/fm/getFileInfo
//查看图片文件夹/fm/pic_dir
//查看图片/fm/pic_file
//查看上传记录/fm/recent_upload
//上传/fm/upload_put
//上传校验/fm/upload/new/verify
//上传/fm/upload/new/
//上传提交/fm/upload/new/commit
//下载/fm/download/new/
@end
@protocol SCBFileManagerDelegate
@optional
-(void)searchSucess:(NSDictionary *)datadic;
-(void)operateSucess:(NSDictionary *)datadic;
-(void)openFinderSucess:(NSDictionary *)datadic;
//打开家庭成员
-(void)getOpenFamily:(NSDictionary *)dictionary;
-(void)openFinderUnsucess;
-(void)removeSucess;
-(void)removeUnsucess;
-(void)renameSucess;
-(void)renameUnsucess;
-(void)moveSucess;
-(void)moveUnsucess;
-(void)newFinderSucess;
-(void)newFinderUnsucess;
@end