#ifndef _INC_ITASKEXECUTER_H
#define _INC_ITASKEXECUTER_H
#include <clientlib/ClientExport.h>
class EXTERNCLASS ITaskExecuter{
public:
	virtual void ExecuteTask() = 0;
};
#endif