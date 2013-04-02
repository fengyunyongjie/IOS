#pragma once
#include <clientlib/ITaskExecuter.h>
#include <clientlib/tinythread.h>
#include <clientlib/Task.h>
class CGetRemoteThumbExecutor:public ITaskExecuter
{
public:
	CGetRemoteThumbExecutor(CTask * aTask);
	~CGetRemoteThumbExecutor(void);

	virtual void ExecuteTask();
private:
	tthread::thread * pThread;
	CTask * task;
};

