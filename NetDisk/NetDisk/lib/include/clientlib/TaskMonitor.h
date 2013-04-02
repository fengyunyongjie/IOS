#ifndef _INC_CTaskMonitor_H
#define _INC_CTaskMonitor_H
#include <clientlib/TaskManager.h>
class CTaskMonitor
{
public:
	void StartMonitor();
	void StopMonitor();
	bool IsStarted();
	void StartTask(CTask * task);
	static CTaskMonitor * GetInstance(CTaskManager * v_taskManager);
	CTaskManager * GetTaskManager();

private:
	static CTaskMonitor * taskMonitorInstance;
	~CTaskMonitor(void);

	
	CTaskManager * taskManager;
	tthread::thread * pThread;
    void StopAllRunningTasks();
};
#endif
