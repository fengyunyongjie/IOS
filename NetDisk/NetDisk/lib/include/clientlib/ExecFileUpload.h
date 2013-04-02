#ifndef INC_CExecFileUpload_H
#define INC_CExecFileUpload_H
#include <clientlib/ClientExport.h>
#include <clientlib/HttpClientCommon.h>
#include <clientlib/TaskManager.h>
#include "clientlib/tinythread.h"
#include <clientlib/ITaskExecuter.h>
class EXTERNCLASS CExecFileUpload:public ITaskExecuter
{
public:
CExecFileUpload(CTask * task);
~CExecFileUpload(void);
void ExecuteTask();
CTask * task;
private:
tthread::thread * pThread;
};
#endif
