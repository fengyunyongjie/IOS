#ifndef SevenCBoxClient_h
#define SevenCBoxClient_h
#include <json/json.h>
#include "clientlib/ClientExport.h"
#include "clientlib/SevenCBoxSession.h"
#include "clientlib/SevenCBoxClientConfig.h"
#include "clientlib/Task.h"
#include "clientlib/HttpClientCommon.h"
#include "clientlib/TaskManager.h"
#include <ctime>
#include <iostream>
#include <fstream>
#include <clientlib/SevenCBoxConfig.h>
#include <clientlib/JsonHttpClient.h>
#include "clientlib/AsynRequestManager.h"
using namespace std;
class EXTERNCLASS SevenCBoxClient {
private:
	static SevenCBoxSession * oCurrentUserSession;
	static CTaskManager * taskManager;
	static ofstream fileLog;
	static CAsynRequestManager * cAsynRequestManager;

public:
	static class SevenCBoxConfig Config;
	static class CJsonHttpClient client;
	static ostream & GetLOG();
	static void InitTaskManager();
	static void SetTaskViewNewTaskCallBack(TaskView_CallBack callBack);
	static void SetTaskViewUpdateTaskCallBack(TaskView_CallBack callBack);
	static void StartTaskMonitor();
	static void StopTaskMonitor();
	static int GetFromUserSession(Value & requestJson);
	static SevenCBoxSession * GetUserSession();
	static int PostRequest(const string & uri,const Value & jsonValue,const Value & headerFields,Value & jsonResponse);
	static void PostRequest(const string & uri,const Value & jsonValue,const Value & headerFields,SCBoxCallBack callback=NULL,void * ui_ptr=NULL);
	static void PostRequestWithUserSession(const string & uri,const Value & jsonValue,SCBoxCallBack callback=NULL,void * ui_ptr=NULL);
	static int PostRequestWithUserSession(const string & uri,const Value & jsonValue, Value & jsonResponse);
	static void PostRequestWithoutUserSession(const string & uri,const Value & jsonValue,SCBoxCallBack callback=NULL,void * ui_ptr=NULL);
	static int PostRequestWithoutUserSession(const string & uri,const Value & jsonValue, Value & jsonResponse);
	static void PostRequest(const string & uri,const Value & jsonValue,const Value & headerFields,vector<string> & localfiles,SCBoxCallBack callback=NULL,void * ui_ptr=NULL);
	static int PostRequest(const string & remoteURL,const Value & jsonValue,const Value & headerFields,vector<string> & localfiles, Value & jsonResponse,CTask * task = NULL);
	static void UserLogin(const string & user_name,const string & user_pwd,SCBoxCallBack callback=NULL,void * ui_ptr=NULL);
	static void UserLogout(SCBoxCallBack callback=NULL,void * ui_ptr=NULL);
	static void UserRegister(const string & usr_name,const string & usr_pwd,const string & client_tag,SCBoxCallBack callback=NULL,void * ui_ptr=NULL);
	static void IsUsrExist(const string & usr_name,const string & client_tag,SCBoxCallBack callback=NULL,void * ui_ptr=NULL);
	static void UpdateUsrPwd(const string & usr_pwd_old,const string & usr_pwd_new,SCBoxCallBack callback=NULL,void * ui_ptr=NULL);
	static void UpdateUsrProfile(const string & usr_nickname,const string & usr_gender,const string & usr_birthday,const string & usr_intro,SCBoxCallBack callback=NULL,void * ui_ptr=NULL);
	static void GetUserProfile(SCBoxCallBack callback=NULL,void * ui_ptr=NULL);
	static void GetUsrSpace(SCBoxCallBack callback=NULL,void * ui_ptr=NULL);
	static void GetFriendshipsGroups(const int cursor,const int offset,SCBoxCallBack callback=NULL,void * ui_ptr=NULL);
	static void GetFriendshipsGroupsDeep(const int cursor,const int offset,SCBoxCallBack callback=NULL,void * ui_ptr=NULL);
	static void CreateFriendshipsGroup(const string & group_name,SCBoxCallBack callback=NULL,void * ui_ptr=NULL);
	static void UpdateFriendshipsGroup(const string & group_id,const string & group_name,SCBoxCallBack callback=NULL,void * ui_ptr=NULL);
	static void DelFriendshipsGroup(bool isdeep,const string & group_id,SCBoxCallBack callback=NULL,void * ui_ptr=NULL);
	static void GetFriendshipsFriends(const string & group_id,const int cursor,const int offset,SCBoxCallBack callback=NULL,void * ui_ptr=NULL);
	static void CreateFriendshipsFriend(const string & friend_name,const string & group_id,const string & friend_remark,SCBoxCallBack callback=NULL,void * ui_ptr=NULL);
	static void MoveFriendshipsFriend(const string & group_id,const string & friend_id,SCBoxCallBack callback=NULL,void * ui_ptr=NULL);
	static void UpdateFriendshipsFriendRemark(const string & friend_remark,const string & friend_id,SCBoxCallBack callback=NULL,void * ui_ptr=NULL);
	static void DelFriendshipsFriend(const string &friend_id,SCBoxCallBack callback=NULL,void * ui_ptr=NULL);
	static void FMOpenFolder(const string &f_id,const int cursor,const int offset,SCBoxCallBack callback=NULL,void * ui_ptr=NULL);
	static void FmMKdir(const string & f_name,const string & f_pid,SCBoxCallBack callback=NULL,void * ui_ptr=NULL);
	static void FmReName(const string & f_id,	const string & f_name,SCBoxCallBack callback=NULL,void * ui_ptr=NULL);
	static void FmCopyToFolder(const bool iscut,const string &f_pid,vector<string> & f_ids,SCBoxCallBack callback=NULL,void * ui_ptr=NULL);
	static void FmRm(vector<string> & f_ids,SCBoxCallBack callback=NULL,void * ui_ptr=NULL);
	static void FmSearch(const string  &f_pid,	const string &f_queryparams,const int cursor,const int offset,SCBoxCallBack callback=NULL,void * ui_ptr=NULL);
	static void FmUploadState(const string & s_name,Value & jsonResponse);
	static void FmUpload(const string & f_pid,const string & f_name,const string & f_mime,SCBoxCallBack callback=NULL,void * ui_ptr=NULL);
	static void FmUploadFiles(const string & f_pid,vector<string>  f_name_list,const string & f_mime,SCBoxCallBack callback,void * ui_ptr);
	static void FmUploadVerify(const string & f_pid,const string & f_name,const int f_size,Value & jsonResponse);
	static void FmDownloadFile(const string & f_id,const string & localfile,bool open_atfer_downloaded=false,SCBoxCallBack callback=NULL,void * ui_ptr=NULL,bool is_background=false);
	static void FmDownloadThumbFile(const string & f_id,const string & localfile,SCBoxCallBack callback=NULL,void * ui_ptr=NULL);
	static void FmGetFileInfo(const string & f_id ,SCBoxCallBack callback=NULL,void * ui_ptr=NULL);
	static void FmGetFileInfo(const string & f_id ,Value & jsonValue);
	static void FmGetPicDirs(const string & f_id,const int cursor,const int offset,SCBoxCallBack callback=NULL,void * ui_ptr=NULL);
	static void FmGetRecentUpload(const string & date,const int cursor,const int offset,SCBoxCallBack callback=NULL,void * ui_ptr=NULL);
	static	void FmTrashOpen(const int cursor,const int	offset,SCBoxCallBack callback=NULL,void * ui_ptr=NULL);
	static	void FmTrashDel(vector<string> & f_ids,SCBoxCallBack callback=NULL,void * ui_ptr=NULL);
	static	void FmTrashDelAll(SCBoxCallBack callback=NULL,void * ui_ptr=NULL);
	static	void FmTrashResume(vector<string> & f_ids,SCBoxCallBack callback=NULL,void * ui_ptr=NULL);
	static	void FmTrashResumeAll(SCBoxCallBack callback=NULL,void * ui_ptr=NULL);
	static	void OpenShareFolder(const string & f_id,const int cursor,const int offset,SCBoxCallBack callback=NULL,void * ui_ptr=NULL);
	static	void ShareCreate(const string & f_id,vector<string> & member_account,SCBoxCallBack callback=NULL,void * ui_ptr=NULL);
	static	void ShareMkdir(const string & f_name,const string & f_pid,SCBoxCallBack callback=NULL,void * ui_ptr=NULL);
	static	void SharePaste(const bool iscut,const string & f_pid,vector<string> & f_ids,SCBoxCallBack callback=NULL,void * ui_ptr=NULL);
	static	void ShareRm(vector<string> & f_ids,SCBoxCallBack callback=NULL,void * ui_ptr=NULL);
	static	void ShareSearch(const string & f_pid,const string & query_params,const int cursor,const int offset,SCBoxCallBack callback=NULL,void * ui_ptr=NULL);
	static	void ShareCancel(const string & f_id,SCBoxCallBack callback=NULL,void * ui_ptr=NULL);
	static	void ShareMembers(const string & f_id,const int cursor,const int offset,SCBoxCallBack callback=NULL,void * ui_ptr=NULL);
	static	void ShareMemberRm(const string & f_id,const string & member_account,SCBoxCallBack callback=NULL,void * ui_ptr=NULL);
	static	void ShareMemberAdd(const string & f_id,const string & member_account,SCBoxCallBack callback=NULL,void * ui_ptr=NULL);
	static	void ShareMemberExit(const string & f_id,SCBoxCallBack callback=NULL,void * ui_ptr=NULL);
	static	void OpenShareTrash(const string & f_id,const int cursor,const int offset,SCBoxCallBack callback=NULL,void * ui_ptr=NULL);
	static	void ShareTrashDel(vector<string> & f_ids,SCBoxCallBack callback=NULL,void * ui_ptr=NULL);
	static	void ShareTrashDelAll(SCBoxCallBack callback=NULL,void * ui_ptr=NULL);
	static	void GetMsgsList(const int msg_type,const int cursor,const int	offset,SCBoxCallBack callback=NULL,void * ui_ptr=NULL);
	static	void MsgSend(const string & friend_id,const string & msg_content,SCBoxCallBack callback=NULL,void * ui_ptr=NULL);
	static	void MsgDel(vector<string> & msg_ids,	SCBoxCallBack callback=NULL,void * ui_ptr=NULL);
	static	void MsgDelAll(const int msg_type,SCBoxCallBack callback=NULL,void * ui_ptr=NULL);
	static	int GetResponseCode(Value jsonResponse);
	static string GetRequestURL(const string & uri);
	static CTaskManager * GetTaskManager();
	static	void PhotoTimeline(SCBoxCallBack callback=NULL,void * ui_ptr=NULL);
	static	void  PhotoGeneral(const string & date,long maxNum,SCBoxCallBack callback=NULL,void * ui_ptr=NULL);
	static	void PhotoDetail( const string & day,int cursor,int offset,SCBoxCallBack callback=NULL,void * ui_ptr=NULL);
	static	void PhotoTagRecent(SCBoxCallBack callback=NULL,void * ui_ptr=NULL);
	static	void PhotoTagFileTags(const string & fid,SCBoxCallBack callback=NULL,void * ui_ptr=NULL);
	static	void PhotoTagTagFiles(vector<string> & t_ids,int cursor,int offset,SCBoxCallBack callback=NULL,void * ui_ptr=NULL);
	static	void PhotoTagFileAdd(vector<string> & f_ids,vector<string> &t_ids,SCBoxCallBack callback=NULL,void * ui_ptr=NULL);
	static void PhotoTagFileDel(vector<string> &f_ids,vector<string> &t_ids,SCBoxCallBack callback=NULL,void * ui_ptr=NULL);
	static void  PhotoTagCreate(const string & tag_name,SCBoxCallBack callback=NULL,void * ui_ptr=NULL);
	static void  PhotoTagDel(const string & tag_id,SCBoxCallBack callback=NULL,void * ui_ptr=NULL);
	static void SetThumbTaskCallBack( TaskView_CallBack callBack );
	//static void StartFolderSync();
};
#endif
