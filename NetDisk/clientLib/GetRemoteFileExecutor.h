#ifndef _INC_CGETREMOTEFILEEXECUTOR_H
#define _INC_CGETREMOTEFILEEXECUTOR_H
#include <clientlib/JsonHttpClient.h>
#include <json/json.h>
#include <clientlib/TaskManager.h>
#include <clientlib/ITaskExecuter.h>
class CGetRemoteFileExecutor:public ITaskExecuter
{
private:
	tthread::thread * pThread;
public:
	CGetRemoteFileExecutor(CTask * task);
	~CGetRemoteFileExecutor(void);
	

	virtual void ExecuteTask();

	//CTaskManager * taskManager;
	CTask * task;
	Value  jsonReqeust;
	Value  header;
};
#endif
