#ifndef INC_CExecFileDownLoad_H
#define INC_CExecFileDownLoad_H
#include <clientlib/ClientExport.h>
#include <clientlib/HttpClientCommon.h>
#include <clientlib/JsonHttpClient.h>
#include <clientlib/TaskManager.h>
#include "clientlib/tinythread.h"
#include <clientlib/ITaskExecuter.h>

class EXTERNCLASS CExecFileDownLoad:public ITaskExecuter
{
public:
	CExecFileDownLoad(CTask * task);
	~CExecFileDownLoad(void);
	void ExecuteTask();
private:
	tthread::thread * pThread;
	CTask * task;
};
#endif 
