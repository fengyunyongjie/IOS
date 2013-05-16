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
#define CONNECT_TIMEOUT 30
#define RESPONSE_TIMEOUT 10
#define SERVER_URL @"http://7cbox.cn:8080/nds/api"
#define SERVER_URL_NEW @"http://7cbox.cn/nds/api"
//#define SERVER_URL @"http://192.168.1.5:8080/nds/api"	//local host

#pragma mark - 用户管理
//用户注册
#define USER_REGISTER_URI @"/usr/register"
//用户登录
#define USER_LOGIN_URI @"/usr/login"
//用户注销
#define USER_LOGOUT_URI @"/usr/logout"


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
#define FM_DOWNLOAD_THUMB_URI @"/fm/download/thumb"
//预览图下载
#define FM_DOWNLOAD_Look @"/fm/download/preview"

#pragma mark - 共享管理


#pragma mark - 意见管理

#pragma mark - 照片管理
//获取时间分组
#define PHOTO_TIMERLINE @"/photo/timeline"
//获取按年或月查询的概要照片
#define PHOTO_GENERAL @"/photo/general"
//获取按月或日查询的所有照片（分页）
#define PHOTO_DETAIL @"/photo/detail"
//移除
#define PHOTO_Delete @"/fm/rm"

#endif
