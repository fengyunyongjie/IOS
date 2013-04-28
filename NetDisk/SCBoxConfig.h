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
#define CONNECT_TIMEOUT 10
#define RESPONSE_TIMEOUT 10
#define SERVER_URL @"http://7cbox.cn:8080/nds/api"
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
//文件下载
#define FM_DOWNLOAD_URI @"/fm/download"
#define FM_DOWNLOAD_NEW_URI @"/fm/download/new"

//缩略图下载
#define FM_DOWNLOAD_THUMB_URI @"/fm/download/thumb"


#pragma mark - 共享管理


#pragma mark - 意见管理
#endif
