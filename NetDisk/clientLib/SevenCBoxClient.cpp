// 这是主 DLL 文件。

#include <iostream>
#include <curl/curl.h>
#include <clientlib/SevenCBoxClient.h>
#include <clientlib/Base64Help.h>

#include <exception>
#include <clientlib/HttpClientCommon.h>
#include <clientlib/TaskManager.h>
#include <clientlib/Task.h>
#include <vector>
#include <sstream>
#include <clientlib/tinythread.h>
//#include <clientlib/AsynRequest.h>
#include "DbManager.h"
#include "filesplit/split/FileSplitter.h"
using namespace Json;
using namespace std;
using namespace ClientConfig;
using namespace tthread;
class SevenCBoxTaskManager;
//声明导出成员变量
SevenCBoxSession * SevenCBoxClient::oCurrentUserSession;
CTaskManager * SevenCBoxClient::taskManager = NULL;
CAsynRequestManager * SevenCBoxClient::cAsynRequestManager = NULL;
SevenCBoxConfig SevenCBoxClient::Config;
CJsonHttpClient SevenCBoxClient::client;
ofstream SevenCBoxClient::fileLog;

tthread::mutex client_mutex;
struct PostValue{
	const string & uri;
	const Value & jsonValue;
	SCBoxCallBack callback;
	void * ui_ptr;
};

void SevenCBoxClient::InitTaskManager()
{
	SevenCBoxClient::taskManager = CTaskManager::GetInstance();
}

string SevenCBoxClient::GetRequestURL(const string & uri)
{
	string requestUrl = Config.GetServerUrl();

	return requestUrl.append(uri);
}
int SevenCBoxClient::GetResponseCode(Value jsonResponse)
{
	int code = -1;
	Value codeValue = jsonResponse["code"];
	if(codeValue.isInt())
		code = jsonResponse["code"].asInt();
	else if(codeValue.isString() || codeValue.isObject())
		code = atoi(jsonResponse["code"].asCString());
	else
		code = -1;
	return code;

}
ostream & SevenCBoxClient::GetLOG()
{
	return cout;
//#ifdef _DEBUG
//	if(Config.GetLogFile().empty())
//		return cout;
//	else
//	{
//		if(!fileLog)return cout;
//		if(!fileLog.is_open())fileLog.open(Config.GetLogFile().c_str());
//		return fileLog;
//	}
//#else
//	return cout;
//#endif
	
}

int SevenCBoxClient::GetFromUserSession(Value & requestJson)
{
	//tthread::lock_guard<mutex> lock(client_mutex);
	if(oCurrentUserSession!=NULL){

		try
		{
			requestJson["usr_name"] = oCurrentUserSession->GetUserAccountName();
			requestJson["usr_id"] = oCurrentUserSession->GetUserId();
			requestJson["client_tag"] = CLIENT_TAG;
			requestJson["usr_token"] = oCurrentUserSession->GetUserToken();
		}catch(exception)
		{
			return -1;
		}
		return 1;
	}
	else
	{
		return 0;
	}
}



int SevenCBoxClient::PostRequest(const string & remoteURL,const Value & jsonValue,const Value & headerFields,vector<string> & localfiles,Value & jsonResponse,CTask * task)
{

	Json::StyledWriter writer;
	//SevenCBoxClient::GetLOG()<<"SevenCBoxClient::PostRequest To ["<<remoteURL<<"],MultiFormPost request is:\r\n"<<writer.write(jsonValue)<<endl;
	int code = client.MultiFormPost(remoteURL,jsonValue,headerFields,localfiles,jsonResponse,task);
	//SevenCBoxClient::GetLOG()<<"SevenCBoxClient::PostRequest To ["<<remoteURL<<"],MultiFormPost response is:\r\n"<<writer.write(jsonResponse)<<endl;

	return code;
}
//执行接口命令
void SevenCBoxClient::PostRequest(const string & uri,const Value & jsonValue,const Value & headerFields,vector<string> & localfiles,SCBoxCallBack callback,void * ui_ptr)
{
	Value jsonResponse;

	PostRequest(GetRequestURL(uri),jsonValue,headerFields,localfiles,jsonResponse);
	//如果存在回调函数，调用回调函数，交给UI程序处理
	if(callback != NULL){
		//SevenCBoxClient::GetLOG()<<"begin to invoke callback function to "<<uri<<" request."<<endl;
		try{
		callback(jsonResponse,ui_ptr);
		}catch(...){

			//SevenCBoxClient::GetLOG()<<"an exception was thrown,on calling callback function to "<<uri<<" ."<<endl;
		}
		//SevenCBoxClient::GetLOG()<<"invoke callback function to "<<uri<<" finished."<<endl;
	}

}
//执行接口命令
int SevenCBoxClient::PostRequest(const string & uri,const Value & jsonValue,const Value & headerFields,Value & jsonResponse)
{

	Json::StyledWriter writer;
	//SevenCBoxClient::GetLOG()<<"SevenCBoxClient::PostRequest To ["<<uri<<"],request is:\r\n"<<writer.write(jsonValue)<<endl;
	int code = client.Post(GetRequestURL(uri),jsonValue,headerFields,jsonResponse);
	//SevenCBoxClient::GetLOG()<<"SevenCBoxClient::PostRequest To ["<<uri<<"],response is:\r\n"<<writer.write(jsonResponse)<<endl;
	return code;
}

//执行接口命令
void SevenCBoxClient::PostRequest(const string & uri,const Value & jsonValue,const Value & headerFields,SCBoxCallBack callback,void * ui_ptr)
{

	//CAsynRequest request(uri,jsonValue,headerFields,callback,ui_ptr);
	
	cAsynRequestManager->AddToList(uri,jsonValue,headerFields,callback,ui_ptr);
}


//执行接口命令
void SevenCBoxClient::PostRequestWithUserSession(const string & uri,const Value & jsonValue,SCBoxCallBack callback,void * ui_ptr)
{
	Value headerFields;
	if(GetFromUserSession(headerFields)>0){
	//CAsynRequest * request = new CAsynRequest(uri,jsonValue,headerFields,callback,ui_ptr);
	cAsynRequestManager->AddToList(uri,jsonValue,headerFields,callback,ui_ptr);
	}
	else
	{
		Value jsonResponse;
		jsonResponse["code"]=99999;
		jsonResponse["error"]="Session is NULL";
		callback(jsonResponse,ui_ptr);
	}

}
int SevenCBoxClient::PostRequestWithUserSession(const string & uri,const Value & jsonValue,Value & jsonResponse)
{
	Value headerFields;
	if(GetFromUserSession(headerFields)>0)
		return PostRequest(uri,jsonValue,headerFields,jsonResponse);
	else
	{
		jsonResponse["code"]=99999;
		jsonResponse["error"]="Session is NULL";
		return 0;
	}
}

int SevenCBoxClient::PostRequestWithoutUserSession(const string & uri,const Value & jsonValue, Value & jsonResponse)
{
	return  PostRequest(uri,jsonValue,NULL,jsonResponse);
}
//执行接口命令
void SevenCBoxClient::PostRequestWithoutUserSession(const string & uri,const Value & jsonValue,SCBoxCallBack callback,void * ui_ptr)
{

	//CAsynRequest request(uri,jsonValue,NULL,callback,ui_ptr);
	cAsynRequestManager->AddToList(uri,jsonValue,NULL,callback,ui_ptr);
}
//*************************************************************************************
//**************************用户管理方法************************************************
//*************************************************************************************
//用户注册
void SevenCBoxClient::UserRegister(const string & usr_name,const string & usr_pwd,const string & client_tag,SCBoxCallBack callback,void * ui_ptr)
{
	//CJsonHttpClient client;
	Value registerRequest;
	Value registerResponse;
	Value header;
	registerRequest["usr_name"] = usr_name;
	registerRequest["usr_pwd"] = Base64Help::enBase64(usr_pwd);
	header["client_tag"] = CLIENT_TAG;
	//int postRet = client.Post(GetRequestURL(USER_REGISTER_URI),registerRequest,header,callback,ui_ptr);
	PostRequest(USER_REGISTER_URI,registerRequest,header,registerResponse);
	if(callback)
	{
		callback(registerResponse,ui_ptr);
	}
	//PostRequestWithoutUserSession(USER_REGISTER_URI,registerRequest,callback,ui_ptr);

}

//void SevenCBoxClient::StartFolderSync()
//{
//	CFolderSync folderSync;
//	folderSync.StartSync();
//}
//用户登录处理
void SevenCBoxClient::UserLogin(const string & user_name,const string & user_pwd,SCBoxCallBack callback,void * ui_ptr)
{
	//CJsonHttpClient client;
	Value loginResponse;
	Value loginRequest;
	Value header;
	loginRequest["usr_name"] =  user_name;
	loginRequest["usr_pwd"] = Base64Help::enBase64(user_pwd);
	header["client_tag"] = CLIENT_TAG;

	//SevenCBoxClient::GetLOG()<<"用户登录函数被调用！"<<endl;

	//string reqestUrl = GetRequestURL(USER_LOGIN_URI);

	int postRet = PostRequest(USER_LOGIN_URI,loginRequest,header,loginResponse);

	int code = loginResponse["code"].asInt();
	if(code == 0)//只有当登录成功时，创建Session对象
	{
		//创建Session对象
		SevenCBoxClient::oCurrentUserSession =  new SevenCBoxSession(loginResponse["usr_id"].asCString(),user_name,loginResponse["usr_token"].asCString());
		
		if(taskManager==NULL)taskManager = CTaskManager::GetInstance();
		//taskManager->StartTaskMonitor();
		if(cAsynRequestManager==NULL)cAsynRequestManager = new CAsynRequestManager;
		if(!IS_SYNC_REQUEST)
		cAsynRequestManager->StartManager();
		
	}


	//调用回调函数，交给UI程序处理
	try
	{
		if(callback)callback(loginResponse,ui_ptr);
	}
	catch (...)
	{
		//SevenCBoxClient::GetLOG()<<"an exception was thrown,on calling callback function for user login "<<endl;
	}


}

//用户注销
void SevenCBoxClient::UserLogout(SCBoxCallBack callback,void * ui_ptr){
	if(oCurrentUserSession!= NULL)
	{
		Value logoutJson;
		logoutJson["usr_id"] = oCurrentUserSession->GetUserId();
		logoutJson["client_tag"] = oCurrentUserSession->GetClientTag();
		logoutJson["usr_token"] = oCurrentUserSession->GetUserToken();
		Value jsonResponse;
		PostRequest(USER_LOGOUT_URI,NULL,logoutJson,jsonResponse);
		if(callback)
		{
			callback(jsonResponse,ui_ptr);
		}
		
		
		if(cAsynRequestManager)
			cAsynRequestManager->StopManager();
		if(taskManager)
			taskManager->StopTaskMonitor();
		delete oCurrentUserSession;
		oCurrentUserSession = NULL;
	}
	else
	{
		if(callback)
		{
			Value jsonResponse;
			jsonResponse["code"]=0;

			callback(jsonResponse,ui_ptr);
		}
	}
	//SevenCBoxClient::GetLOG()<<"User Logout"<<endl;

}
//请求服务器判断用户是否存在
void SevenCBoxClient::IsUsrExist(const string & usr_name,const string & client_tag,SCBoxCallBack callback,void * ui_ptr)
{
	
	Value usrExistRequest;
	Value usrExistResponse;

	usrExistRequest["usr_name"] =  usr_name;
	usrExistRequest["client_tag"] = client_tag;
	PostRequestWithoutUserSession(USER_EXIST_URI,usrExistRequest,callback,ui_ptr);
}
//修改用户密码
void SevenCBoxClient::UpdateUsrPwd(const string & usr_pwd_old,const string & usr_pwd_new,SCBoxCallBack callback,void * ui_ptr)
{
	//CJsonHttpClient client;
	Value jsonRequest;


	jsonRequest["usr_pwd_old"] = Base64Help::enBase64(usr_pwd_old);
	jsonRequest["usr_pwd_new"] = Base64Help::enBase64(usr_pwd_new);
	//jsonRequest["usr_name"] = oCurrentUserSession->GetUserName();

	PostRequestWithUserSession(USER_PWD_UPDATE_URI,jsonRequest,callback,ui_ptr);
}
void SevenCBoxClient::GetUserProfile( SCBoxCallBack callback/*=NULL*/,void * ui_ptr/*=NULL*/ )
{
	Value jsonRequest;
	PostRequestWithUserSession(USER_PROFILE_URI,jsonRequest,callback,ui_ptr);
}

//修改用户个人信息
void SevenCBoxClient::UpdateUsrProfile(const string & usr_nickname,const string & usr_gender,const string & usr_birthday,const string & usr_intro,SCBoxCallBack callback,void * ui_ptr)
{

	Value jsonRequest;
	jsonRequest["usr_nickname"] = usr_nickname;
	jsonRequest["usr_gender"] = usr_gender;
	jsonRequest["usr_birthday"] = usr_birthday;
	jsonRequest["usr_intro"] = usr_intro;
	PostRequestWithUserSession(USER_PROFILE_UPDATE_URI,jsonRequest,callback,ui_ptr);
}
//获取用户空间
void SevenCBoxClient::GetUsrSpace(SCBoxCallBack callback,void * ui_ptr)
{

	PostRequestWithUserSession(USER_SPACE_URI,NULL,callback,ui_ptr);
}

//***********************************************************************************
//***************好友及群组管理*******************************************************
//***********************************************************************************
//获取群组列表
void SevenCBoxClient::GetFriendshipsGroups(int cursor,int offset,SCBoxCallBack callback,void * ui_ptr)
{
	Value jsonRequest;

	jsonRequest["cursor"]=cursor;
	jsonRequest["offset"]=offset;
	PostRequestWithUserSession(FRIENDSHIPS_GROUPS_URI,jsonRequest,callback,ui_ptr);
}
//获取群组及好友列表
void SevenCBoxClient::GetFriendshipsGroupsDeep(int cursor,int offset,SCBoxCallBack callback,void * ui_ptr)
{
	Value jsonRequest;
	jsonRequest["cursor"]=cursor;
	jsonRequest["offset"]=offset;
	PostRequestWithUserSession(FRIENDSHIPS_GROUPS_URI,jsonRequest,callback,ui_ptr);
}
//获取当前会话
SevenCBoxSession * SevenCBoxClient::GetUserSession()
{
	return oCurrentUserSession;
}


void SevenCBoxClient::CreateFriendshipsGroup(const string & group_name,SCBoxCallBack callback,void * ui_ptr)
{
	Value jsonRequest;

	jsonRequest["group_name"]= group_name;

	PostRequestWithUserSession(FRIENDSHIPS_GROUP_CREATE_URI,jsonRequest,callback,ui_ptr);
}
void SevenCBoxClient::UpdateFriendshipsGroup(const string & group_id,const string & group_name,SCBoxCallBack callback,void * ui_ptr)
{
	Value jsonRequest;


	jsonRequest["group_id"]= group_id;
	jsonRequest["group_name"]= group_name;


	PostRequestWithUserSession(FRIENDSHIPS_GROUP_CREATE_URI,jsonRequest,callback,ui_ptr);
}
void SevenCBoxClient::DelFriendshipsGroup(bool isdeep,const string & group_id,SCBoxCallBack callback,void * ui_ptr)
{
	Value jsonRequest;
	jsonRequest["group_id"]= group_id;
	jsonRequest["isdeep"]= isdeep;
	PostRequestWithUserSession(FRIENDSHIPS_GROUP_DEL_URI,jsonRequest,callback,ui_ptr);
}

void SevenCBoxClient::GetFriendshipsFriends(const string & group_id,int cursor,int offset,SCBoxCallBack callback,void * ui_ptr)
{
	Value jsonRequest;
	jsonRequest["group_id"]= group_id;
	jsonRequest["cursor"]= cursor;
	jsonRequest["offset"]= offset;
	PostRequestWithUserSession(FRIENDSHIPS_FRIENDS_URI,jsonRequest,callback,ui_ptr);
}

void SevenCBoxClient::CreateFriendshipsFriend(const string & friend_name,const string & group_id,const string & friend_remark,SCBoxCallBack callback,void * ui_ptr)
{
	Value jsonRequest;
	jsonRequest["friend_name"]= friend_name;
	jsonRequest["group_id"]= group_id;
	jsonRequest["friend_remark"]= friend_remark;

	PostRequestWithUserSession(FRIENDSHIPS_FRIEND_CREATE_URI,jsonRequest,callback,ui_ptr);
}
//移动好友
void SevenCBoxClient::MoveFriendshipsFriend(const string & group_id,const string & friend_id,SCBoxCallBack callback,void * ui_ptr)
{
	Value jsonRequest;
	jsonRequest["group_id"]= group_id;
	jsonRequest["friend_id"]= friend_id;

	PostRequestWithUserSession(FRIENDSHIPS_FRIEND_MOVE_URI,jsonRequest,callback,ui_ptr);
}

void SevenCBoxClient::UpdateFriendshipsFriendRemark(const string & friend_remark,const string & friend_id,SCBoxCallBack callback,void * ui_ptr)
{
	Value jsonRequest;
	jsonRequest["friend_remark"]= friend_remark;
	jsonRequest["friend_id"]= friend_id;

	PostRequestWithUserSession(FRIENDSHIPS_FRIEND_REMARK_UPDATE_URI,jsonRequest,callback,ui_ptr);
}


void SevenCBoxClient::DelFriendshipsFriend(const string &friend_id,SCBoxCallBack callback,void * ui_ptr)
{
	Value jsonRequest;
	jsonRequest["friend_id"]= friend_id;

	PostRequestWithUserSession(FRIENDSHIPS_FRIEND_DEL_URI,jsonRequest,callback,ui_ptr);
}



//*************************************************************************************
//************************消息处理方法**************************************************
//*************************************************************************************
void SevenCBoxClient::GetMsgsList( const int msg_type,const int cursor,const int offset,SCBoxCallBack callback/*=NULL*/,void * ui_ptr )
{
	Value jsonRequest;
	jsonRequest["msg_type"]= msg_type;
	PostRequestWithUserSession(MSGS_URI,jsonRequest,callback,ui_ptr);
}

void SevenCBoxClient::MsgSend( const string & friend_id,const string & msg_content,SCBoxCallBack callback/*=NULL*/,void * ui_ptr )
{
	Value jsonRequest;
	jsonRequest["friend_id"]= friend_id;
	jsonRequest["msg_content"]= msg_content;
	PostRequestWithUserSession(MSG_SEND_URI,jsonRequest,callback,ui_ptr);
}
void FillJsonReqeust(Value &jsonValue,vector<string> &values)
{
	for( vector<string>::iterator it = values.begin();it != values.end(); ++it){
		string &value = *it;
		jsonValue.append(value);
	}
}
void FillJsonReqeust(Value &jsonValue,vector<int> &values)
{
	for( vector<int>::iterator it = values.begin();it != values.end(); ++it){
		jsonValue.append(*it);
	}
}

void SevenCBoxClient::MsgDel( vector<string> &msg_ids, SCBoxCallBack callback/*=NULL*/,void * ui_ptr )
{
	Value jsonRequest;

	FillJsonReqeust(jsonRequest["msg_ids"],msg_ids);
	//SevenCBoxClient::GetLOG()<<"MsgDel jsonRequest;"<<jsonRequest<<endl;
	cin.get();
	PostRequestWithUserSession(MSG_DEL_URI,jsonRequest,callback,ui_ptr);
}

void SevenCBoxClient::MsgDelAll( const int msg_type,SCBoxCallBack callback/*=NULL*/,void * ui_ptr )
{
	Value jsonRequest;
	jsonRequest["msg_type"]= msg_type;

	PostRequestWithUserSession(MSG_DELALL_URI,jsonRequest,callback,ui_ptr);
}



//*************************************************************************************
//****************网盘文件管理处理方法***************************************************
//*************************************************************************************
void SevenCBoxClient::FMOpenFolder(const string &f_id,const int cursor,const int offset,SCBoxCallBack callback,void * ui_ptr)
{
	if(f_id=="")
	{
		if(callback){
		Value jsonResponse;
		jsonResponse["code"]=1;
		jsonResponse["error"]="invalid f_id!";
		callback(jsonResponse,ui_ptr);
		}
		return;
	}
	Value jsonRequest;
	jsonRequest["f_id"]= f_id;
	jsonRequest["cursor"]= cursor;
	jsonRequest["offset"]= offset;
	PostRequestWithUserSession(FM_URI,jsonRequest,callback,ui_ptr);
	/*int folder_id = atoi(f_id.c_str());
	Value jsonResponse = CFolderSync::GetFileList(folder_id);
	if(callback)
	{
		callback(jsonResponse,ui_ptr);
	}*/
}
//创建目录
void SevenCBoxClient::FmMKdir(const string & f_name,const string & f_pid,SCBoxCallBack callback,void * ui_ptr)
{
	Value jsonRequest;
	jsonRequest["f_name"]= f_name;
	jsonRequest["f_pid"]= f_pid;
	PostRequestWithUserSession(FM_MKDIR_URI,jsonRequest,callback,ui_ptr);
}
//修改文件或者目录名
void SevenCBoxClient::FmReName(const string & f_id,	const string & f_name,SCBoxCallBack callback,void * ui_ptr)
{
	Value jsonRequest;
	jsonRequest["f_id"]= f_id;
	jsonRequest["f_name"]= f_name;
	PostRequestWithUserSession(FM_RENAME_URI,jsonRequest,callback,ui_ptr);
}
//粘贴文件或者目录
void SevenCBoxClient::FmCopyToFolder(const bool iscut,const string &f_pid,vector<string> &f_ids,SCBoxCallBack callback,void * ui_ptr)
{
	Value jsonRequest;
	jsonRequest["iscut"]= iscut;
	jsonRequest["f_pid"]=f_pid;
	FillJsonReqeust(jsonRequest["f_ids[]"],f_ids);
	if(iscut)
	PostRequestWithUserSession(FM_CUTPASTE_URI,jsonRequest,callback,ui_ptr);
	else
	PostRequestWithUserSession(FM_COPYPASTE_URI,jsonRequest,callback,ui_ptr);
}
//删除文件或者目录
void SevenCBoxClient::FmRm(vector<string> &f_ids,SCBoxCallBack callback,void * ui_ptr)
{
	Value jsonRequest;
	FillJsonReqeust(jsonRequest["f_ids[]"],f_ids);
	PostRequestWithUserSession(FM_RM_URI,jsonRequest,callback,ui_ptr);
}
void SevenCBoxClient::FmSearch(const string &f_pid, const string &f_queryparams, const int cursor, const int offset,SCBoxCallBack callback,void * ui_ptr)
{
	Value jsonRequest;
	jsonRequest["f_pid"]= f_pid;
	jsonRequest["f_queryparam"]= f_queryparams;
	jsonRequest["cursor"]= cursor;
	jsonRequest["offset"]= offset;

	PostRequestWithUserSession(FM_SEARCH_URI,jsonRequest,callback,ui_ptr);
}

//申请上传、获取上传状态
void SevenCBoxClient::FmUploadState( const string & s_name,Value & jsonResponse )
{
	Value jsonRequest;
	jsonRequest["s_name"]= s_name;
	PostRequestWithUserSession(FM_UPLOAD_STATE_URI,jsonRequest,jsonResponse);
}
//校验远程文件与本地文件是否相等
void SevenCBoxClient::FmUploadVerify( const string & f_pid,const string & f_name,const int f_size,Value & jsonResponse )
{
	Value jsonRequest;
	jsonRequest["f_pid"]= f_pid;
	jsonRequest["f_name"]= f_name;
	jsonRequest["f_size"]= f_size;
	PostRequestWithUserSession(FM_UPLOAD_VERIFY_URI,jsonRequest,jsonResponse);
}


//上传文件
void SevenCBoxClient::FmUpload(const string & f_pid,const string & f_name,const string & f_mime,SCBoxCallBack callback,void * ui_ptr)
{

	taskManager->CreateNewUploadTask(f_pid,f_name,f_mime,callback,ui_ptr);

}

void  SevenCBoxClient::FmUploadFiles(const string & f_pid,vector<string> f_name_list,const string & f_mime,SCBoxCallBack callback,void * ui_ptr)
{
	//vector<CTask *> *task_list = new vector<CTask *>;
	Value jsonResponse;
	Value jsonAllResponse;
	string error="";
	for( vector<string>::iterator it = f_name_list.begin();
		it != f_name_list.end();
		++it )
	{
        @synchronized(ui_ptr) {
		const string f_name = *it;
		try{
			long fileSize = CFileSplitter::get_file_size(f_name.c_str());
			if(fileSize==0)continue;
			taskManager->CreateNewUploadTask(f_pid,f_name,f_mime,jsonResponse);
			if(jsonResponse["code"].asInt()==1)
			{
				error += jsonResponse["error"].asString();
			}
		}catch(...)
		{
			error += "error on create upload task.";
		}
		}
	}

	if(callback){
		if(error.length()>0)
		{
			jsonAllResponse["code"]=1;
			jsonAllResponse["error"] = error;
		}
		else
		{
			jsonAllResponse["code"]=0;
		}
		callback(jsonAllResponse,ui_ptr);
	}
	//return task_list;
}
/************************************************************************/
/* 下载文件                                                              */
/************************************************************************/
//CTask *  SevenCBoxClient::FmDownloadFile(const string & f_id,const string & savefile,SCBoxCallBack callback,void * ui_ptr)
//{
//
//	CTask * task = taskManager->CreateNewDownloadTask(f_id,savefile,callback,ui_ptr);
//	return task;
//
//}
void  SevenCBoxClient::FmDownloadFile(const string & f_id,const string & savefile,bool open_after_downloaded,SCBoxCallBack callback,void * ui_ptr,bool is_background)
{

	taskManager->CreateNewDownloadTask(f_id,savefile,open_after_downloaded,callback,ui_ptr,false);

}

void SevenCBoxClient::FmDownloadThumbFile( const string & f_id,const string & savefile,SCBoxCallBack callback/*=NULL*/,void * ui_ptr/*=NULL*/ )
{
	taskManager->CreateImmediatelyDownloadTask(f_id,savefile,callback,ui_ptr);

}

//获取文件信息
void SevenCBoxClient::FmGetFileInfo( const string & f_id ,SCBoxCallBack callback/*=NULL*/,void * ui_ptr )
{
	Value jsonRequest;

	jsonRequest["f_id"]= f_id;

	PostRequestWithUserSession(FM_GETFILEINFO_URI,jsonRequest,callback,ui_ptr);
}
//获取文件信息
void SevenCBoxClient::FmGetFileInfo( const string & f_id ,Value & jsonValue)
{
	Value jsonRequest;

	jsonRequest["f_id"]= f_id;

	PostRequestWithUserSession(FM_GETFILEINFO_URI,jsonRequest,jsonValue);
}
//获取一个目录下的所有图片目录
void SevenCBoxClient::FmGetPicDirs( const string & f_id,const int cursor,const int offset,SCBoxCallBack callback/*=NULL*/,void * ui_ptr )
{
	Value jsonRequest;
	jsonRequest["f_id"]= f_id;
	jsonRequest["cursor"]= cursor;
	jsonRequest["offset"]= offset;

	PostRequestWithUserSession(FM_PIC_DIR_URI,jsonRequest,callback,ui_ptr);
}
//获取最近上传的文件列表
void SevenCBoxClient::FmGetRecentUpload(const string & date,const int cursor,const int offset,SCBoxCallBack callback,void * ui_ptr)
{
	Value jsonRequest;
	 //istringstream ss();
	 //ss.imbue(std::locale("zh-cn"));

	jsonRequest["date"]= date;
	jsonRequest["cursor"]= cursor;
	jsonRequest["offset"]= offset;

	PostRequestWithUserSession(FM_RECENT_UPLOAD_URI,jsonRequest,callback,ui_ptr);
}


//***********************************************************************
//********回收站管理方法**************************************************
//***********************************************************************

void SevenCBoxClient::FmTrashOpen( const int cursor,const int offset,SCBoxCallBack callback/*=NULL*/,void * ui_ptr )
{
	Value jsonRequest;
	jsonRequest["cursor"]= cursor;
	jsonRequest["offset"]= offset;
	PostRequestWithUserSession(FM_TRASH_URI,jsonRequest,callback,ui_ptr);
}

void SevenCBoxClient::FmTrashDel( vector<string> &f_ids,SCBoxCallBack callback/*=NULL*/,void * ui_ptr )
{
	Value jsonRequest;
	FillJsonReqeust(jsonRequest["f_ids[]"],f_ids);
	PostRequestWithUserSession(FM_TRASH_DEL_URI,jsonRequest,callback,ui_ptr);
}

void SevenCBoxClient::FmTrashDelAll( SCBoxCallBack callback/*=NULL*/,void * ui_ptr )
{
	PostRequestWithUserSession(FM_TRASH_DELALL_URI,NULL,callback,ui_ptr);
}

void SevenCBoxClient::FmTrashResume( vector<string> &f_ids,SCBoxCallBack callback/*=NULL*/,void * ui_ptr )
{
	Value jsonRequest;

	FillJsonReqeust(jsonRequest["f_ids[]"],f_ids);

	PostRequestWithUserSession(FM_TRASH_RESUME_URI,jsonRequest,callback,ui_ptr);
}

void SevenCBoxClient::FmTrashResumeAll( SCBoxCallBack callback/*=NULL*/,void * ui_ptr )
{
	PostRequestWithUserSession(FM_TRASH_RESUMEALL_URI,NULL,callback,ui_ptr);
}
//*****************************************************************************
//************************打开共享文件夹****************************************
//*****************************************************************************

void SevenCBoxClient::OpenShareFolder( const string & f_id,const int cursor,const int offset,SCBoxCallBack callback/*=NULL*/,void * ui_ptr )
{
	Value jsonRequest;
	jsonRequest["f_id"]= f_id;
	jsonRequest["cursor"]= cursor;
	jsonRequest["offset"]= offset;

	PostRequestWithUserSession(SHARE_URI,jsonRequest,callback,ui_ptr);
}

void SevenCBoxClient::ShareCreate( const string & f_id,vector<string> &member_accounts,SCBoxCallBack callback/*=NULL*/,void * ui_ptr )
{
	Value jsonRequest;
	jsonRequest["f_id"]= f_id;

	FillJsonReqeust(jsonRequest["member_accounts[]"],member_accounts);
	PostRequestWithUserSession(SHARE_CREATE_URI,jsonRequest,callback,ui_ptr);
}

void SevenCBoxClient::ShareMkdir( const string & f_name,const string & f_pid,SCBoxCallBack callback/*=NULL*/,void * ui_ptr )
{
	Value jsonRequest;
	jsonRequest["f_name"]= f_name;
	jsonRequest["f_pid"]= f_pid;

	PostRequestWithUserSession(SHARE_MKDIR_URI,jsonRequest,callback,ui_ptr);
}

void SevenCBoxClient::SharePaste( const bool iscut,const string & f_pid,vector<string> &f_ids,SCBoxCallBack callback/*=NULL*/,void * ui_ptr )
{
	Value jsonRequest;
	jsonRequest["iscut"]= iscut;
	jsonRequest["f_pid"]= f_pid;

	FillJsonReqeust(jsonRequest["f_ids[]"],f_ids);
	if(iscut)
	PostRequestWithUserSession(SHARE_CUTPARSTE_URI,jsonRequest,callback,ui_ptr);
	else
	PostRequestWithUserSession(SHARE_COPYPARSTE_URI,jsonRequest,callback,ui_ptr);
}

void SevenCBoxClient::ShareRm( vector<string> &f_ids,SCBoxCallBack callback/*=NULL*/,void * ui_ptr )
{
	Value jsonRequest;
	FillJsonReqeust(jsonRequest["f_ids[]"],f_ids);
	PostRequestWithUserSession(SHARE_RM_URI,jsonRequest,callback,ui_ptr);
}

void SevenCBoxClient::ShareSearch( const string & f_pid,const string & query_param,const int cursor,const int offset,SCBoxCallBack callback/*=NULL*/,void * ui_ptr )
{
	Value jsonRequest;
	jsonRequest["f_pid"]= f_pid;
	jsonRequest["query_param"]= query_param;
	jsonRequest["cursor"]= cursor;
	jsonRequest["offset"]= offset;
	PostRequestWithUserSession(SHARE_SEARCH_URI,jsonRequest,callback,ui_ptr);
}

void SevenCBoxClient::ShareCancel( const string & f_id,SCBoxCallBack callback/*=NULL*/,void * ui_ptr )
{
	Value jsonRequest;
	jsonRequest["f_id"]= f_id;
	PostRequestWithUserSession(SHARE_CANCEL_URI,jsonRequest,callback,ui_ptr);
}

void SevenCBoxClient::ShareMembers( const string & f_id,const int cursor,const int offset,SCBoxCallBack callback/*=NULL*/,void * ui_ptr )
{
	Value jsonRequest;
	jsonRequest["f_id"]= f_id;
	jsonRequest["cursor"]= cursor;
	jsonRequest["offset"]= offset;
	PostRequestWithUserSession(SHARE_MEMBERS_URI,jsonRequest,callback,ui_ptr);
}

void SevenCBoxClient::ShareMemberRm( const string & f_id,const string & member_account,SCBoxCallBack callback/*=NULL*/,void * ui_ptr )
{
	Value jsonRequest;
	jsonRequest["f_id"]= f_id;
	jsonRequest["member_account"]= member_account;
	PostRequestWithUserSession(SHARE_MEMBER_RM_URI,jsonRequest,callback,ui_ptr);
}

void SevenCBoxClient::ShareMemberAdd( const string & f_id,const string & member_account,SCBoxCallBack callback/*=NULL*/,void * ui_ptr )
{
	Value jsonRequest;
	jsonRequest["f_id"]= f_id;
	jsonRequest["member_account"]= member_account;
	PostRequestWithUserSession(SHARE_MEMBER_ADD_URI,jsonRequest,callback,ui_ptr);
}

void SevenCBoxClient::ShareMemberExit( const string & f_id,SCBoxCallBack callback/*=NULL*/,void * ui_ptr )
{
	Value jsonRequest;
	jsonRequest["f_id"]= f_id;

	PostRequestWithUserSession(SHARE_MEMBER_EXIT_URI,jsonRequest,callback,ui_ptr);
}

//***************************************************************
//*********************共享回收站管理****************************
//***************************************************************
void SevenCBoxClient::ShareTrashDel(vector<string> &f_ids,SCBoxCallBack callback/*=NULL*/,void * ui_ptr )
{
	Value jsonRequest;
	FillJsonReqeust(jsonRequest["f_ids[]"],f_ids);

	PostRequestWithUserSession(SHARE_TRASH_DEL_URI,jsonRequest,callback,ui_ptr);
}

void SevenCBoxClient::OpenShareTrash( const string & f_id,const int cursor,const int offset,SCBoxCallBack callback/*=NULL*/,void * ui_ptr )
{
	Value jsonRequest;
	jsonRequest["f_id"]= f_id;
	jsonRequest["cursor"]= cursor;
	jsonRequest["offset"]= offset;
	PostRequestWithUserSession(SHARE_TRASH_URI,jsonRequest,callback,ui_ptr);
}

void SevenCBoxClient::ShareTrashDelAll( SCBoxCallBack callback/*=NULL*/,void * ui_ptr )
{
	PostRequestWithUserSession(SHARE_TRASH_DELALL_URI,NULL,callback,ui_ptr);
}
//=========================================================


CTaskManager * SevenCBoxClient::GetTaskManager()
{
	return SevenCBoxClient::taskManager;
}
//==========================照片管理方法区==================================
void SevenCBoxClient::PhotoTimeline( SCBoxCallBack callback/*=NULL*/,void * ui_ptr/*=NULL*/ )
{
	Value jsonRequest;
	PostRequestWithUserSession(PHOTO_TIMELINE_URI,jsonRequest,callback,ui_ptr);
}

void SevenCBoxClient::PhotoGeneral( const string & date,long maxNum,SCBoxCallBack callback/*=NULL*/,void * ui_ptr/*=NULL*/ )
{
	Value jsonRequest;
	//ostringstream oss;
	//oss<<maxNum;
	jsonRequest["date"]= date;
	if(maxNum==0)maxNum=5;
	jsonRequest["maxNum"]= (int)maxNum;

	PostRequestWithUserSession(PHOTO_GENERAL_URI,jsonRequest,callback,ui_ptr);
}

void SevenCBoxClient::PhotoDetail( const string & day,int cursor,int offset,SCBoxCallBack callback/*=NULL*/,void * ui_ptr/*=NULL*/ )
{
	Value jsonRequest;
	jsonRequest["day"]= day;
	jsonRequest["cursor"]= cursor;
	jsonRequest["offset"]= offset;
	PostRequestWithUserSession(PHOTO_DETAIL_URI,jsonRequest,callback,ui_ptr);
}

void SevenCBoxClient::PhotoTagRecent( SCBoxCallBack callback/*=NULL*/,void * ui_ptr/*=NULL*/ )
{
	Value jsonRequest;
	PostRequestWithUserSession(PHOTO_TAG_RECENT_URI,jsonRequest,callback,ui_ptr);
}

void SevenCBoxClient::PhotoTagFileTags( const string & fid,SCBoxCallBack callback/*=NULL*/,void * ui_ptr/*=NULL*/ )
{
	Value jsonRequest;
	jsonRequest["fid"]= fid;
	PostRequestWithUserSession(PHOTO_TAG_FILE_TAGS_URI,jsonRequest,callback,ui_ptr);
}

void SevenCBoxClient::PhotoTagTagFiles( vector<string> & t_ids,int cursor,int offset,SCBoxCallBack callback/*=NULL*/,void * ui_ptr/*=NULL*/ )
{
	Value jsonRequest;
	FillJsonReqeust(jsonRequest["t_id[]"],t_ids);
	jsonRequest["cursor"]=cursor;
	jsonRequest["offset"]=offset;
	PostRequestWithUserSession(PHOTO_TAG_TAG_FILES_URI,jsonRequest,callback,ui_ptr);
}

void SevenCBoxClient::PhotoTagFileAdd( vector<string> & f_ids,vector<string> &t_ids,SCBoxCallBack callback/*=NULL*/,void * ui_ptr/*=NULL*/ )
{
	Value jsonRequest;
	FillJsonReqeust(jsonRequest["f_id[]"],f_ids);
	FillJsonReqeust(jsonRequest["t_id[]"],t_ids);

	PostRequestWithUserSession(PHOTO_TAG_FILE_ADD_URI,jsonRequest,callback,ui_ptr);
}

void SevenCBoxClient::PhotoTagFileDel( vector<string> &f_ids,vector<string> &t_ids,SCBoxCallBack callback/*=NULL*/,void * ui_ptr/*=NULL*/ )
{
	Value jsonRequest;
	FillJsonReqeust(jsonRequest["f_id[]"],f_ids);
	FillJsonReqeust(jsonRequest["t_id[]"],t_ids);

	PostRequestWithUserSession(PHOTO_TAG_FILE_DEL_URI,jsonRequest,callback,ui_ptr);
}

void SevenCBoxClient::PhotoTagCreate( const string & tag_name,SCBoxCallBack callback/*=NULL*/,void * ui_ptr/*=NULL*/ )
{
	Value jsonRequest;
	jsonRequest["tag_name"]=tag_name;

	PostRequestWithUserSession(PHOTO_TAG_CREATE_URI,jsonRequest,callback,ui_ptr);
}

void SevenCBoxClient::PhotoTagDel( const string & tag_id,SCBoxCallBack callback/*=NULL*/,void * ui_ptr/*=NULL*/ )
{
	Value jsonRequest;

	jsonRequest["tag_id[]"]=tag_id;
	PostRequestWithUserSession(PHOTO_TAG_DEL_URI,jsonRequest,callback,ui_ptr);
}
void SevenCBoxClient::SetThumbTaskCallBack( TaskView_CallBack callBack )
{
	taskManager->SetThumbTaskCallBack(callBack);
}
void SevenCBoxClient::SetTaskViewNewTaskCallBack( TaskView_CallBack callBack )
{
	taskManager->SetTaskViewNewTaskCallBack(callBack);
}

void SevenCBoxClient::SetTaskViewUpdateTaskCallBack( TaskView_CallBack callBack )
{
	taskManager->SetTaskViewUpdateTaskCallBack(callBack);
}

void SevenCBoxClient::StartTaskMonitor()
{
	taskManager->StartTaskMonitor();
}

void SevenCBoxClient::StopTaskMonitor()
{
	if(taskManager)
	taskManager->StopTaskMonitor();
}




//========================================================
//=================Function===============================
//========================================================
