#ifndef CTaskManager_H
#define CTaskManager_H
#include "clientlib/Task.h"

#include <clientlib/ClientExport.h>
#include <clientlib/HttpClientCommon.h>
#include <clientlib/CppSQLite3.h>
#include <clientlib/tinythread.h>
#include <map>


using namespace std;
//static const char * db_file = "task_manager_db.db3";
class  CTaskManager;

struct Task_Thread_Pair{
	CTaskManager * manager;
	CTask * task;
};

class EXTERNCLASS CTaskManager
{
private:
	static CTaskManager * task_manager_instnce;
	void * taskMonitor;
	static map<const int,CTask *> * task_list;
	static CTaskManager * instance;
	
	static bool Inited;

	
	void _CheckTables();
	void _Create_Task_Management_Table();
	void _Init();
	void _UnInit();
	void _FreeAll();
	void _LoadAllTasks();
	void _AddToTaskList(CppSQLite3Query & query);
	void _InsertToTaskList(CTask * task);
	CTask * _GetCTaskFromDB(const int task_id);
	void _UpdateTaskInDB( CTask * task );
	void _DeleteCTaskInDB(const int task_id,bool & ret);
	

	//void Start( CTask * task );
	CTask * _CreateNewTask( const string &stask_name,const string & stask_file_id, const string & stask_file_name,const string & stask_file_pid,const string & stask_local_path,const bool & btask_trans_dir ,bool is_background=false);
	CTaskManager(void);
	~CTaskManager(void);
	//void _CheckTaskMonitor();
	friend class CTaskMonitor;
	friend class SevenCBoxConfig;
public:
	static CTaskManager * GetInstance();
	
	//
	CTask * CreateNewTask(const string &stask_name,const int & itask_percentage,const string & stask_file_id, const string & stask_file_name,const string & stask_file_pid,const string & stask_local_path,const bool & btask_trans_dir,bool is_background=false);
	CTask * CreateNewUploadTask( const string & stask_file_pid,const string & stask_file_local_path,const string & f_mime,SCBoxCallBack callback=NULL,void * ui_ptr=NULL);
	CTask * CreateNewUploadTask( const string & stask_file_pid,const string & stask_file_local_path,const string & f_mime,Value & jsonResponse);
	CTask * CreateImmediatelyDownloadTask( const string & f_id, const string & savefile, SCBoxCallBack callBack,void * ui_ptr);
	void StartTaskMonitor(void);
	void StopTaskMonitor( void );
	void Start(const int task_id);
	
	void Pause(const int task_id);
	void Stop(const int task_id);
	void Abort(const int task_id);
	void Resume(const int task_id);
	void Delete(const int task_id);
	//void Update( CTask * task );
	void Save(CTask * task);
	CTask * CreateNewDownloadTask( const string & f_id, const string & savefile,bool open_after_downloaded=false, SCBoxCallBack callBack=NULL,void * ui_ptr=NULL,bool is_background=false);
	void DeleteFromTaskList(const int task_id);
	/*void ChangeTaskState(const int task_id,int state);
	void ChangeTaskPercent(const int task_id,int percent);
	void SetTaskSName(const int task_id,string & sname);
	void SetTaskFileId(const int task_id,string & file_id);
	void SetTaskTransfSpeed(const int task_id,float speed);
	void SetTaskThreadState(const int task_id,bool started);
	void SetTaskSkipOnStart(const int task_id,long skip);
	long GetTaskSkipOnStart(const int task_id);*/
	CTask * GetTask(int task_id);

	void SetTaskViewNewTaskCallBack( TaskView_CallBack callBack );
	void SetTaskViewUpdateTaskCallBack(TaskView_CallBack callBack);
	TaskView_CallBack GetTaskViewNewTaskCallBack();
	TaskView_CallBack GetTaskViewUpdateTaskCallBack();
	void CreateTaskView();
	void CallUpdateTaskView(CTask * task);
	void CallInsertToTaskView(CTask * task);

	vector<CTask *> * GetDownloadingTasks();
	vector<CTask *> * GetUploadingTasks();
	//vector<CTask *> * GetUploadedTasks();
	//vector<CTask *> * GetDownloadedTasks();
	vector<CTask *> * GetCompletedTasks();
	//vector<CTask *> * GetDeletedTasks();
	vector<CTask *> * GetRunningTasks();
	vector<CTask *> * GetAllTasks();
	vector<int> * GetTaskIdList();
	vector<int> * GetNotRuningTaskIdList();
	
	int GetCurrentDownloadThreads();
	int GetCurrentUploadThreads();
	int GetCurrentRunningTaskThreads();
	int GetCurrentIMDownloadThreads();
	void SetThumbTaskCallBack( TaskView_CallBack callBack );
	void CallUpdatePicThum(CTask * task);
	//全部取消
	//单个暂停
	//单个开始
	//单个取消

};

#endif