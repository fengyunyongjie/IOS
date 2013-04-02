#include "GetRemoteFileExecutor.h"
#include <clientlib/SevenCBoxClient.h>
#include "filesplit/split/FileSplitter.h"
#include <cstdio>
#include <sstream>   // for stringstream
#include <clientlib/StringUtils.h>
int download_task_id;
int UpdateDownloadProgressValue(char *progress_data,double t, /* dltotal */	double d, /* dlnow */	double ultotal,	double ulnow);
void StartDownLoadThread(void * ptr);
void GetRemoteFileCallBack(Value &jsonResponse,void * executer);
//tthread::mutex download_task_mutex;
//tthread::condition_variable getremotefile_cond;

CGetRemoteFileExecutor::~CGetRemoteFileExecutor(void)
{
	if(pThread){
	pThread->join();
	delete pThread;
	}
}

CGetRemoteFileExecutor::CGetRemoteFileExecutor(CTask * v_task)
{
	task = v_task;
}

void CGetRemoteFileExecutor::ExecuteTask()
{	
	task->ChangeState(1);
	task->SetStartState(true);
	pThread = new tthread::thread(StartDownLoadThread,this->task);
	//delete params;

}



bool FileHasDownloaded(CTask * task)
{
#ifdef _WIN32
	const char * filepath = task->GetFileLocalPath();
	string filePathStr = JsonStringUtil::UTF_8ToGB2312(filepath,string(filepath).length());
	bool downloaded = false;
	WIN32_FIND_DATA fileInfo; 
	HANDLE hFind;
	hFind = FindFirstFile(JsonStringUtil::s2ws(filePathStr).c_str(), &fileInfo);
	downloaded =(hFind != INVALID_HANDLE_VALUE);
	FindClose(hFind);
	return downloaded;
#else
	const char * filepath = task->GetFileLocalPath();
	ifstream in(filepath);
	bool downloaded = in.is_open();
	if(in)in.close();
	return downloaded;
#endif
}
void StartDownLoadThread(void * ptr)
{
@autoreleasepool {
	//tthread::lock_guard<tthread::mutex> lock(download_task_mutex);

	CTask * task = (CTask *)ptr;
	if(!task||task->GetTaskState()!=1)
	{		
		task->SetStartState(false);
		//this_thread::yield();
		return;
	}
	CTaskManager * taskManager = SevenCBoxClient::GetTaskManager();
	if(FileHasDownloaded(task))
	{
		task->ChangePercentage(100);
		task->ChangeState(3);
		task->SetStartState(false);
		taskManager->Save(task);
		task->DeleteThread();
		//this_thread::yield();
		return;
	}
	const char * file_path = task->GetFileLocalPath();
	//CJsonHttpClient client;
	int skip =0;
	Value jsonRequest;
	Value jsonHeaders;
	//SevenCBoxClient::GetLOG()<<"start downloading ["<<task->GetFileName()<<"]! "<<endl;
	if(SevenCBoxClient::GetFromUserSession(jsonHeaders)==1){
		if(!task)
		{
			//this_thread::yield();
			task->DeleteThread();
			return;
		}
		if( task->GetTaskState()==-2)
		{
			//SevenCBoxClient::GetLOG()<<"["<<task->GetFileName()<<"] downloading task will been deleted! "<<endl;
			task->DeleteThread();
			//this_thread::yield();
			return;
		}
		if(task->GetTaskState()==-1)
		{
			task->DeleteThread();
			//this_thread::yield();
			return;
		}
		
		jsonHeaders["f_id"]=task->GetFileId();
		//jsonRequest["f_skip"] = skip;
		
			//skip = CFileSplitter::get_file_size(file_path);
			//SevenCBoxClient::GetLOG()<<"Get file ["<<task->GetFileName()<<"] from server! "<<endl;
			SevenCBoxClient::client.GetRemoteFile(SevenCBoxClient::GetRequestURL(ClientConfig::FM_DOWNLOAD_NEW_URI),jsonRequest,jsonHeaders,task);
			if(!task||task->GetTaskState()!=1)return;
			SevenCBoxClient::FmGetFileInfo(task->GetFileId(),GetRemoteFileCallBack,task);
		
	}
}
}


void GetRemoteFileCallBack(Value &jsonResponse,void * ptr)
{

	CTaskManager * taskManager = SevenCBoxClient::GetTaskManager();
	CTask * task = (CTask *)ptr;
	if(!task||task->GetTaskState()!=1)
	{
		if(task)task->DeleteThread();
			return;
	}
	string file_path = task->GetFileLocalPath();
	string temp_file_path = file_path+".tmp";
	int ret =jsonResponse["code"].asInt();
	if(ret==0)
	{
		Value fileInfos = jsonResponse["files"];
		int nIndex = 0;
		Value fileInfo = fileInfos[nIndex];
		long f_size = fileInfo["f_size"].asInt();

		long saved_size = CFileSplitter::get_file_size(temp_file_path.c_str());
		if(f_size > saved_size )
		{
			//SevenCBoxClient::GetLOG()<<"Get file ["<<currentTask->GetFileName()<<"] from server!continue "<<endl;
			Value jsonRequest;
			Value jsonHeaders;
			if(SevenCBoxClient::GetFromUserSession(jsonHeaders)==1){
				jsonHeaders["f_id"]=task->GetFileId();
				//SevenCBoxClient::GetLOG()<<"Get file ["<<task->GetFileName()<<"] from server! "<<endl;
				//CGetRemoteFileExecutor getRemoteFileExecutor(jsonRequest,jsonHeaders,task);
				//getRemoteFileExecutor.ExecutTask();
				SevenCBoxClient::client.GetRemoteFile(SevenCBoxClient::GetRequestURL(ClientConfig::FM_DOWNLOAD_URI),jsonRequest,jsonHeaders,task);
				SevenCBoxClient::FmGetFileInfo(task->GetFileId(),GetRemoteFileCallBack,task);
				//client.GetRemoteFile(SevenCBoxClient::GetRequestURL(ClientConfig::FM_DOWNLOAD_URI),jsonRequest,jsonHeaders,file_path,UpdateDownloadProgressValue);
				//SevenCBoxClient::FmGetFileInfo(currentTask->GetFileId(),jsonResponse);
			}


		}
		else
		{
			if(!task||task->GetTaskState()!=1)return;


			try{
				//long thumb_file_size = CFileSplitter::get_file_size(temp_file_path.c_str());
				//如果文件大小为0.则删
				if(saved_size==0)
				{
					std::remove(temp_file_path.c_str());
					task->ChangePercentage(0);
					task->ChangeState(-2);
				}
				else
				{
					std::rename(temp_file_path.c_str(),file_path.c_str());
					task->ChangePercentage(100);
					task->ChangeState(3);
				}
				//SevenCBoxClient::GetLOG()<<"file downloaded completed:task ["<<task->GetTaskId()<<"] is stopped! "<<endl;
				taskManager->Save(task);
				task->DeleteThread();
				task->SetStartState(false);
				//this_thread::sleep_for(tthread::chrono::milliseconds(1));
			}catch(...)
			{
				task->ChangePercentage(0);
				task->ChangeState(-2);
				task->SetStartState(false);
				//SevenCBoxClient::GetLOG()<<"remove or rename file failed :task ["<<task->GetTaskId()<<"] is stopped! "<<endl;
				task->DeleteThread();
				//this_thread::sleep_for(tthread::chrono::milliseconds(1));
				return;
			}
			
//			//SevenCBoxClient::GetLOG()<<"CGetRemoteFileExecutor::Download Completed!"<<endl;
//			
//			//SevenCBoxClient::GetLOG()<<"CGetRemoteFileExecutor::Change State for Task("<<task->GetTaskId()<<")"<<endl;
//			task->ChangeState(3);
//			//SevenCBoxClient::GetLOG()<<"CGetRemoteFileExecutor::Change percentage for Task("<<task->GetTaskId()<<")"<<endl;
//			task->ChangePercentage(100);
//			
//			//SevenCBoxClient::GetLOG()<<"CGetRemoteFileExecutor::Begin to rename file name!"<<endl;
////#ifdef _WIN32
////			std::ostringstream cmd_oss;
////			cmd_oss<<"rename "<<temp_file_path.c_str()<<" "<<file_path.c_str();
////			std::system(cmd_oss.str().c_str());
////#else
//			std::rename(temp_file_path.c_str(),file_path.c_str());
////#endif
//			//SevenCBoxClient::GetLOG()<<"CGetRemoteFileExecutor::File Name renamed!"<<endl;
//			//SevenCBoxClient::GetLOG()<<"CGetRemoteFileExecutor::Save Task!"<<endl;
//			task->SetStartState(false);
//			taskManager->Save(task);
//			//SevenCBoxClient::GetLOG()<<"Task saved,download ["<<task->GetFileName()<<"] OK!"<<endl;
//			task->DeleteThread();
//			//SevenCBoxClient::GetLOG()<<"download ["<<task->GetFileName()<<"] Thread deleted!"<<endl;
//			//this_thread::yield();
		}
		//更新TaskView

	}
	else
	{

		//SevenCBoxClient::GetLOG()<<"Error in download ["<<task->GetFileName()<<"]! Stoped!"<<endl;
		if(task)
		{
			task->ChangeState(0);	//下载停止
			task->SetStartState(false);
			taskManager->Save(task);
			task->DeleteThread();
			//this_thread::yield();
		}
	}

}

