//
//  SCBoxConfig.h
//  NetDisk
//
//  Created by fengyongning on 13-4-18.
//
//

#ifndef NetDisk_SCBoxConfig_h
#define NetDisk_SCBoxConfig_h

#define CLIENT_TAG @"3"
#define CONNECT_TIMEOUT 15
#define RESPONSE_TIMEOUT 10
#define SERVER_URL @"http://7cbox.cn/nds/api"
//#define SERVER_URL_NEW @"http://7cbox.cn/nds/api"
//#define SERVER_URL @"http://192.168.1.5/nds/api"	//local host
//#define SERVER_URL @"http://xianzhouhe.eicp.net/nds/api"	//local host

#pragma mark - 用户管理
//用户注册
#define USER_REGISTER_URI @"/usr/register"
//用户登录
#define USER_LOGIN_URI @"/usr/login"
//用户注销
#define USER_LOGOUT_URI @"/usr/logout"
//获取用户当前存储空间信息；
#define USER_SPACE_URI @"/usr/space"


#pragma mark - 好友管理
#pragma mark - 短消息管理


#pragma mark - 文件管理
//打开网盘
#define FM_URI @"/fm"
//移除/fm/rm
#define FM_RM_URI @"/fm/rm"
//重命名/fm/rename
#define FM_RENAME_URI @"/fm/rename"
//移动文件＝＝剪切粘贴 /fm/cutpaste
#define FM_MOVE_URI @"/fm/cutpaste"
//文件下载
#define FM_DOWNLOAD_URI @"/fm/download"
#define FM_DOWNLOAD_NEW_URI @"/fm/download/new"

//缩略图下载
#define FM_DOWNLOAD_THUMB_URI @"/fm/download/thumb/"
//预览图下载
#define FM_DOWNLOAD_Look @"/fm/download/preview"
//获取文件详细信息
#define FM_GETFILEINFO @"/fm/getFileInfo"

#pragma mark - 共享管理


#pragma mark - 意见管理

#pragma mark - 照片管理
#pragma mark - 获取用户的所有的拍摄信息
#define PHOTO_ALL  @"/photo/all"
//获取时间分组
#define PHOTO_TIMERLINE @"/photo/timeline"
//获取按年或月查询的概要照片
#define PHOTO_GENERAL @"/photo/general"
//获取按月或日查询的所有照片（分页）
#define PHOTO_DETAIL @"/photo/detail"
//移除
#define PHOTO_Delete @"/fm/rm"
//新建
#define FM_MKDIR_URL @"/fm/mkdir"
//上传校验
#define FM_UPLOAD_VERIFY @"/fm/upload/verify"
//上传
#define FM_UPLOAD @"/fm/upload"
//申请传输文件
#define FM_UPLOAD_STATE @"/fm/upload/state"
//新上传效验
#define FM_UPLOAD_NEW_VERIFY @"/fm/upload/new/verify"
//新上传
#define FM_UPLOAD_NEW @"/fm/upload/new"
//新上传提交
#define FM_UPLOAD_NEW_COMMIT @"/fm/upload/new/commit"

#endif
