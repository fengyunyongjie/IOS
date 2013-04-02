#ifndef _INC_CPostRequestExecuter_H
#define _INC_CPostRequestExecuter_H
#include <clientlib/JsonHttpClient.h>
#include <json/json.h>
#include <clientlib/TaskManager.h>
#include <clientlib/tinythread.h>
#include <clientlib/ITaskExecuter.h>
class CMultiPostRequestExecuter:public ITaskExecuter
{
public:
	CMultiPostRequestExecuter(CTask * task);
	~CMultiPostRequestExecuter(void);


	virtual void ExecuteTask();

	string  uri;
	Value  jsonRequest;
	Value  headerFields;
	SCBoxCallBack callback;
	CTask * task;
	string splite_file;
	tthread::thread * pThread;
};

#endif