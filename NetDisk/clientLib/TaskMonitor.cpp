#include "clientlib/TaskMonitor.h"
#include <clientlib/SevenCBoxClient.h>

void StartTaskMonitorThread(void * taskMonitor) ;
CTaskMonitor * CTaskMonitor::taskMonitorInstance = NULL;
tthread::mutex monitor_mutex;
static int retryCount = 10;
//bool task_monitor_exited = true;
static bool task_monitor_started = false;
CTaskMonitor::~CTaskMonitor(void)
{
	if(pThread)
		pThread->join();
	delete pThread;
}

void CTaskMonitor::StartMonitor()
{
	//tthread::lock_guard<mutex> lock(monitor_mutex);
	while(IsStarted())return;
	task_monitor_started = true;
	retryCount = 10;

	pThread = new tthread::thread(StartTaskMonitorThread,this);

}

void CTaskMonitor::StopMonitor()
{
	task_monitor_started = false;
	StopAllRunningTasks();
	//SevenCBoxClient::GetLOG()<<"TaskMonitor Stopped."<<endl;
}

bool CTaskMonitor::IsStarted()
{
	return task_monitor_started;
}

CTaskManager * CTaskMonitor::GetTaskManager()
{
	return taskManager;
}

void CTaskMonitor::StartTask(CTask * task)
{
	task->Start();
}


CTaskMonitor * CTaskMonitor::GetInstance( CTaskManager * taskManager )
{
	if(taskMonitorInstance==NULL){
		taskMonitorInstance = new CTaskMonitor;
		taskMonitorInstance->taskManager = taskManager;
	}
	return taskMonitorInstance;
}

void CTaskMonitor::StopAllRunningTasks()
{
	vector<CTask *> * taskList = taskManager->GetRunningTasks();
	if(taskList)
	{
		while(taskList->begin()!=taskList->end())
		{
			taskList->back()->Stop();
			this_thread::sleep_for(tthread::chrono::milliseconds(10));
			taskList->pop_back();
		}
	}

}

bool task_view_created = false;
//===================Functions==================
void StartTaskMonitorThread(void * taskMonPtr) 
{
	//tthread::lock_guard<mutex> lock(monitor_mutex);
	//SevenCBoxClient::GetLOG()<<"TaskMonitor Started."<<endl;
	CTaskMonitor * taskMonitor = (CTaskMonitor *)taskMonPtr;
	CTaskManager * taskManager = taskMonitor->GetTaskManager();
	if(!task_view_created)	taskManager->CreateTaskView();
	//tthread::this_thread::sleep_for(tthread::chrono::microseconds(1000));
	while(task_monitor_started)
	{
		vector<int> * taskIdList = taskManager->GetNotRuningTaskIdList();
		//monitor_mutex.unlock();

		//while(task_monitor_started&&taskIdList==NULL){

		//	taskIdList = taskManager->GetNotRuningTaskIdList();

		//	this_thread::sleep_for(tthread::chrono::milliseconds(500));
		//}
		if(!taskIdList)
		{
			this_thread::sleep_for(tthread::chrono::milliseconds(500));
			continue;
		}
		if(!task_monitor_started)
		{
			if(taskIdList)delete taskIdList;
			return;
		}
		vector<int>::iterator it = taskIdList->end();
		while(task_monitor_started&&it != taskIdList->end())
		{
			int &task_id = taskIdList->back();

			CTask * task = taskManager->GetTask(task_id);
			if(task->GetPriority()<0)continue;
			if(task->GetPriority()==999999)
			{
				task->Start();
				taskIdList->erase(it);
				break;
			}
			it++;
			
		}
		while(task_monitor_started&&taskIdList->begin() != taskIdList->end())
		{
			int &task_id = taskIdList->back();
			
			CTask * task = taskManager->GetTask(task_id);
			if(task)
			{
				int states = task->GetTaskState();	
				switch(states)
				{
				case 0:
					{
						if(task->GetPriority()<0)break;
						/*if(task->GetPriority()==MAXINT)
						{
							task->Start();
							break;
						}*/
						if(task->IsUpload() )
						{
							if(taskManager->GetCurrentUploadThreads()< 2)
							{
								//taskMonitor->IncreaseUploadThread();
								task->Start();
								break;
							}
						}
						else 
						{
							if (task->GetTaskType()==0&&taskManager->GetCurrentDownloadThreads()< 2) 
							{
								//taskMonitor->IncreaseDownloadThread();
								task->Start();
								break;
							}
							else if (task->GetTaskType()==1&&taskManager->GetCurrentIMDownloadThreads()< 1)
							{
								task->Start();
								break;
							}
						}

					}
					break;
				case 1:
					if(!task->IsRunning())
						task->ChangeState(0);
					break;
				case 2:
					break;

				case 3:
					if(task->IsRunning())
						task->SetStartState(false);
					if(task->GetTaskType()==1)
						taskManager->DeleteFromTaskList(task_id);
					break;

				case -2:
					if(task->GetTaskType()==1)
						taskManager->DeleteFromTaskList(task_id);
					break;
				}
				taskIdList->pop_back();
				//*it = taskIdList->back();
				this_thread::sleep_for(tthread::chrono::milliseconds(10));
			}
		}
		if(!task_monitor_started)
		{
			if(taskIdList)delete taskIdList;
			return;
		}
		delete taskIdList;
	}


}