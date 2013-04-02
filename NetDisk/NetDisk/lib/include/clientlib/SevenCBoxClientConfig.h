/*
 * SevenCBoxCommands.h
 *  Created on: 2012-11-5
 *      Author: zhangdl
 */

#ifndef SEVENCBOXCLIENTCONFIG_H_
#define SEVENCBOXCLIENTCONFIG_H_
#include <string>
#include <json/json.h>

#include <clientlib/PhotoManageConfig.h>
using namespace std;
using namespace Json;


namespace ClientConfig{
#ifdef _WIN32
    const static string  CLIENT_TAG = "1";
#elif _ANDROID
    const static string  CLIENT_TAG = "2";
#elif _IOS
    const static string  CLIENT_TAG = "3";
#else
    const static string  CLIENT_TAG = "3";
#endif
    
    static const bool IS_SYNC_REQUEST = false;
    //连接超时
    const static int CONNECT_TIMEOUT = 10;
    
    //响应超时
    const static int RESPONSE_TIMEOUT = 10;
    
    //默认切割文件大小
    const static long Default_SplitBlock_Size = 1024*1024;
    
    //string SevenCBox_Server_URL = "http://7cbox.net/";
    //生产服务器
    //const static string SevenCBox_Server_URL = "http://7cbox.f3322.org:8080/nds/api";
    //static const string SevenCBox_Server_URL = "http://localhost:8080/RestAPI";
    //const static string SevenCBox_Server_URL ="http://117.34.79.20:8080/ndsrest/api";
    //邹甲乐机器
    //const static string SevenCBox_Server_URL ="http://7cbox.f3322.org:8899/nds/api";
    //string SevenCBox_Server_URL = "http://192.168.1.34:8080/nds/api";
    
    //根目录编号
    const static string FM_Root_Id = "1";
    //Task state defination
    //任务已停止
    const static  int TASK_STATE_STOPPED = 0;
    //任务正在执行
    const static  int TASK_STATE_RUNNING = 1;
    //任务暂停
    const static  int TASK_STATE_PASUSED = 2;
    //任务结束
    const static  int TASK_STATE_FINISHED = 3;
    
    
    //用户注册
    const static string USER_REGISTER_URI = "/usr/register";
    //用户登录
    const static string USER_LOGIN_URI = "/usr/login";
    //用户注销
    const static string USER_LOGOUT_URI = "/usr/logout";
    //获取用户空间
    const static string USER_SPACE_URI = "/usr/space";
    //【说明】：获取群组列表；
    //意见反馈/advice
    const static string ADVICE_URI ="/advice";
    const static string FRIENDSHIPS_GROUPS_URI = "/friendships/groups";
    
    const static string USER_EXIST_URI = "/usr/exist";
    const static string USER_PWD_UPDATE_URI = "/usr/pwd/update";
    const static string USER_PROFILE_UPDATE_URI = "/usr/profile/update";
    const static string USER_PROFILE_URI = "/usr/profile";
    
    //【说明】：获取所有群组及好友列表；
    
    const static string FRIENDSHIPS_GROUPS_DEEP_URI  = "/friendships/group/create";
    //【说明】：创建群组；
    
    
    const static string FRIENDSHIPS_GROUP_CREATE_URI  = "/friendships/group/create";
    //【说明】：修改群组信息；
    
    
    const static string FRIENDSHIPS_GROUP_UPDATE_URI  = "/friendships/group/update";
    //【说明】：删除群组；
    
    const static string FRIENDSHIPS_GROUP_DEL_URI  = "/friendships/group/del";
    //【说明】：获取某一群组下的好友列表；
    
    const static string FRIENDSHIPS_FRIENDS_URI  = "/friendships/friends";
    //【说明】：添加好友；
    
    const static string FRIENDSHIPS_FRIEND_CREATE_URI  = "/friendships/friend/create";
    //【说明】：移动好友到指定群组；
    
    const static string FRIENDSHIPS_FRIEND_MOVE_URI  = "/friendships/friend/move";
    /**修改好友备注*/
    const static string FRIENDSHIPS_FRIEND_REMARK_UPDATE_URI  = "/friendships/friend/remark/update";
    /**删除好友*/
    const static string FRIENDSHIPS_FRIEND_DEL_URI  = "/friendships/friend/del";
    /**获取短消息列表*/
    const static string MSGS_URI  = "/msgs";
    //给指定好友发送短消息 ；
    
    const static string MSG_SEND_URI  = "/msg/send";
    
    //【说明】：删除短消息；
    
    const static string MSG_DEL_URI  = "/msg/del";
    //【说明】：删除所有短消息
    
    const static string MSG_DELALL_URI  = "/msg/delall";
    //【说明】：打开我的网盘根目录，打开网盘中某一个文件夹；
    
    const static string FM_URI  = "/fm";
    //【说明】：在网盘中新建文件夹；
    
    const static string FM_MKDIR_URI  = "/fm/mkdir";
    //【说明】：重命名网盘文件/文件夹；
    
    const static string FM_RENAME_URI  = "/fm/rename";
    
    //复制到指定网盘文件夹
    const static string FM_COPYPASTE_URI  = "/fm/copypaste";
    //剪切粘贴
    const static string FM_CUTPASTE_URI  = "/fm/cutpaste";
    //移除网盘中的文件文件夹
    const static string FM_RM_URI  = "/fm/rm";
    //【说明】：搜索网盘文件/文件夹；
    
    const static string FM_SEARCH_URI  = "/fm/search";
    
    //上传状态
    const static string FM_UPLOAD_STATE_URI = "/fm/upload/state";
    //【说明】：上传文件；
    
    const static string FM_UPLOAD_URI  = "/fm/upload";
    //【说明】：上传文件校验；
    
    const static string FM_UPLOAD_VERIFY_URI  = "/fm/upload/verify";

    //【说明】：下载指定文件；    
    const static string FM_DOWNLOAD_URI  = "/fm/download";
      
    //【说明】：下载；客户端指定要下载的流片段，下载文件流；
    const static string FM_DOWNLOAD_NEW_URI  = "/fm/download/new";
    
    //【说明】：下载缩略图；
    const static string FM_DOWNLOAD_THUMB_URI  = "/fm/download/thumb";
    
    //【说明】：预览图下载
    const static string FM_DOWNLOAD_PREVIEW_URI ="/fm/download/preview";
    
    //获取文件信息,通过文件或文件夹id获取文件或文件夹对象
    const static string FM_GETFILEINFO_URI  = "/fm/getFileInfo";
    //打开我的网盘根目录只获取包含图片的文件夹，其他文件夹不显示，打开包含图片的文件夹，只显示图片，其他文件不显示
    const static string FM_PIC_DIR_URI  = "/fm/pic_dir";
    //获取一段日期以内的上传完成记录，若所传时间距离现在超过三个月，则仍返回三个月内的记录
    const static string FM_RECENT_UPLOAD_URI  = "/fm/recent_upload";
    
    
    //【说明】：打开网盘回收站；
    
    const static string FM_TRASH_URI  = "/fm/trash";
    //【说明】：彻底删除网盘回收站中的文件/文件夹；
    
    const static string FM_TRASH_DEL_URI  = "/fm/trash/del";
    //【说明】：清空网盘回收站
    
    const static string FM_TRASH_DELALL_URI  = "/fm/trash/delall";
    //【说明】：恢复网盘回收站中的文件/文件夹；
    
    const static string FM_TRASH_RESUME_URI  = "/fm/trash/resume";
    //【说明】：恢复所有网盘回收站中的文件/文件夹；
    
    const static string FM_TRASH_RESUMEALL_URI  = "/fm/trash/resumeall";
    
    //【说明】：打开共享根目录，打开某一共享文件夹；
    
    const static string SHARE_URI  = "/share";
    //【说明】：将网盘中某一文件夹设置成共享文件夹；
    
    const static string SHARE_CREATE_URI  = "/share/create";
    //【说明】：在共享文件夹中创建子文件夹；
    
    const static string SHARE_MKDIR_URI  = "/share/mkdir";
    //【说明】：复制/剪切 文件 到指定共享文件夹；
    const static string SHARE_COPYPARSTE_URI  = "/share/copypaste";
    const static string SHARE_CUTPARSTE_URI  = "/share/cutpaste";
    //【说明】：在“共享区”进行文件/文件夹的删除操作：
    //删除文件夹：不论文件夹是谁创建的，都回共享者网盘回收站；
    //删除文件：如果是共享者上传文件则回共享者网盘回收站；如果是不是共享者上传的则回文件创建者的共享回收站；
    
    const static string SHARE_RM_URI  = "/share/rm";
    //【说明】：搜索共享文件/文件夹；
    
    const static string SHARE_SEARCH_URI  = "/share/search";
    //【说明】：取消文件夹共享；
    
    const static string SHARE_CANCEL_URI  = "/share/cancel";
    //【说明】：创建文件夹；
    
    const static string SHARE_MEMBERS_URI  = "/share/members";
    //【说明】：踢除共享成员；
    
    const static string SHARE_MEMBER_RM_URI  = "/share/member/rm";
    //【说明】：添加共享成员；
    
    const static string SHARE_MEMBER_ADD_URI  = "/share/member/add";
    //【说明】：成员退出共享；
    
    const static string SHARE_MEMBER_EXIT_URI  = "/share/member/exit";
    //【说明】：打开共享回收站；
    
    const static string SHARE_TRASH_URI  = "/share/trash";
    //【说明】：彻底删除共享回收站中的文件；
    
    const static string SHARE_TRASH_DEL_URI  = "/share/trash/del";
    
    //【说明】：删除共享回收站中所有文件；
    
    const static string SHARE_TRASH_DELALL_URI  = "/share/trash/delall";
    
}
#endif /*SevenCBoxClientConfig_h_*/