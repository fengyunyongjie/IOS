#include "GetRemoteThumbExecutor.h"
#include <clientlib/Task.h>
#include <fstream>
#include <clientlib/SevenCBoxClient.h>
#include "filesplit/split/FileSplitter.h"

void StartThumbDownLoadThread(void * ptr);
CGetRemoteThumbExecutor::CGetRemoteThumbExecutor(CTask * aTask)
{
	this->task = aTask;
}


CGetRemoteThumbExecutor::~CGetRemoteThumbExecutor(void)
{
	if(pThread)pThread->join();
	delete pThread;
}

void CGetRemoteThumbExecutor::ExecuteTask()
{
	task->ChangeState(1);
	task->SetStartState(true);
	pThread = new tthread::thread(StartThumbDownLoadThread,this->task);
}
bool ThumbHasDownloaded(CTask * task)
{
	const char * filepath = task->GetFileLocalPath();
	ifstream in(filepath);
	bool downloaded = in.is_open();
	if(in)in.close();
	return downloaded;
}
void StartThumbDownLoadThread(void * ptr)
{
@autoreleasepool {
	CTask * task = (CTask *)ptr;
	if (!task)
	{
		return;
	}
	if(task->GetTaskState()!=1)
	{		

		task->SetStartState(false);
		task->DeleteThread();
		//SevenCBoxClient::GetLOG()<<"task state error or task is null :["<<task->GetTaskId()<<"] thread exited! "<<endl;
		//tthread::this_thread::sleep_for(tthread::chrono::milliseconds(1));
		return;
	}

	if(ThumbHasDownloaded(task))
	{
		task->ChangePercentage(100);
		task->ChangeState(3);
		task->SetStartState(false);
		SevenCBoxClient::GetTaskManager()->Save(task);
		task->DeleteThread();
		//SevenCBoxClient::GetLOG()<<"file has been downloaded :["<<task->GetTaskId()<<"] thread exited! "<<endl;
		//tthread::this_thread::sleep_for(tthread::chrono::milliseconds(1));
		return;
	}
	const char * file_path = task->GetFileLocalPath();

	int skip =0;
	Value jsonRequest;
	Value jsonHeaders;
	if( task->GetTaskState()!=1)
	{
		task->SetStartState(false);

		task->DeleteThread();
		//SevenCBoxClient::GetLOG()<<"task state error:["<<task->GetTaskId()<<"] thread exited! "<<endl;
		//tthread::this_thread::sleep_for(tthread::chrono::milliseconds(1));

		return;
	}
	//SevenCBoxClient::GetLOG()<<"start downloading ["<<task->GetTaskId()<<"]! "<<endl;
	if(SevenCBoxClient::GetFromUserSession(jsonHeaders)==1){
		if(task->GetTaskType()==1){
			jsonHeaders["f_id"]=task->GetFileId();
			string file_path = task->GetFileLocalPath();
			string temp_file_path = file_path+".tmp";
			//file_path.append(".tmp");
			string url = SevenCBoxClient::GetRequestURL(ClientConfig::FM_DOWNLOAD_THUMB_URI);
			SevenCBoxClient::client.GetRemoteThumbFile(url,jsonRequest,jsonHeaders,task);
			try{
				long thumb_file_size = CFileSplitter::get_file_size(temp_file_path.c_str());

				if(thumb_file_size==0)
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

				task->SetStartState(false);
				//SevenCBoxClient::GetLOG()<<"file downloaded completed:task ["<<task->GetTaskId()<<"] is stopped! "<<endl;
				task->DeleteThread();
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
			return;
		}
	}
	else
	{
		task->ChangeState(-2);
		task->SetStartState(false);
		//SevenCBoxClient::GetLOG()<<"session error:task ["<<task->GetTaskId()<<"] thread exited! "<<endl;
		task->DeleteThread();
		//this_thread::sleep_for(tthread::chrono::milliseconds(1));

	}
}
}