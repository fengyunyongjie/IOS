#include "clientlib/ExecFileDownLoad.h"
#include <clientlib/task.h>
#include <clientlib/TaskManager.h>
#include <clientlib/SevenCBoxClient.h>
#include <clientlib/JsonHttpClient.h>
#include <iostream>
#include <sstream>
#include <string>
#include <fstream>
#include "GetRemoteFileExecutor.h"

using namespace ClientConfig;
using namespace std;

//tthread::mutex cexe_file_download_mutex;
static const long GetFileSize(const char * f_name);

void StartDownlodThread(void * executor);

CExecFileDownLoad::CExecFileDownLoad(CTask * ctask)
{
	
	task = ctask;
	
}

void CExecFileDownLoad::ExecuteTask()
{
	if(!task)
	{
		this_thread::yield();	
		return;
	}
	if(task && task->GetFileId()==NULL || task->GetFileId()=="" )
	{
		task->ChangeState(0);
		task->SetStartState(false);
		this_thread::yield();
		return;
	}
	else{
		task->ChangeState(1);
		task->SetStartState(true);
		pThread = new tthread::thread(StartDownlodThread,task);
	}
}
void StartDownlodThread(void * taskPtr)
{	
	//tthread::lock_guard<tthread::mutex> lock(cexe_file_download_mutex);
@autoreleasepool {	
	CTask * task = (CTask *)taskPtr;
	if(!task||task->GetTaskState()!=1)
	{
		task->SetStartState(false);
		this_thread::yield();
		return;
	}

	try{
			CGetRemoteFileExecutor getRemoteFileExecutor(task);
			getRemoteFileExecutor.ExecuteTask();

	}catch(...)
	{
		SevenCBoxClient::GetLOG()<<"An exeception durring downloading ["<<task->GetFileName()<<"]!Thread Stoped!"<<endl;
		
		task->ChangeState(0);	//出现已成下载停止
		task->SetStartState(false);
		SevenCBoxClient::GetTaskManager()->Save(task);
		//this_thread::yield();
		return;
	}
}
}


CExecFileDownLoad::~CExecFileDownLoad( void )
{
	if(pThread){
	pThread->join();
	delete pThread;
	}
}

