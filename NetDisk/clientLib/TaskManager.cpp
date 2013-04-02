#include <clientlib/TaskManager.h>
#include <clientlib/CppSQLite3.h>
#include <clientlib/Task.h>
#include <iostream>
#include <sstream>
#include <string>
#include <map>
#include "DbManager.h"
#include <clientlib/SevenCBoxClient.h>
#include "md5.h"
#include <clientlib/SevenCBoxClient.h>
#include "filesplit/split/FileSplitter.h"
#include <clientlib/stringutils.h>
#include <clientlib/Base64Help.h>
#include <clientlib/JsonHttpClient.h>
#include <clientlib/SevenCBoxClientConfig.h>
//#include "clientlib/ExecFileDownLoad.h"
#include "filesplit/exception/open_error.h"
#include <clientlib/TaskMonitor.h>
#ifdef _WIN32
#include <windows.h>
#endif
#include <clientlib/fast_mutex.h>
//#include <clientlib/ExecFileUpload.h>


using namespace ClientConfig;
using namespace std;
tthread::mutex task_manager_mutex;

map<const int,CTask *> * CTaskManager::task_list =NULL;

CTaskManager * CTaskManager::instance = NULL;
bool CTaskManager::Inited = false;
static void CommonTaskViewCallBackFunc(void * task);
void  StartTransfer(void * task);
CTask * _GetCTaskFromQuery(CppSQLite3Query & query);
TaskView_CallBack taskView_NewTaskCallBackFunc = &CommonTaskViewCallBackFunc;
TaskView_CallBack taskView_UpdateTaskCallBackFunc = &CommonTaskViewCallBackFunc;
TaskView_CallBack picView_ThumbTaskCallBackFunc = &CommonTaskViewCallBackFunc;
void CallUpdateTaskView(CTask * task);
void CallInsertToTaskView(CTask * task);

static void CommonTaskViewCallBackFunc(void * task)
{
	return;
}

CTaskManager::CTaskManager( void )
{
	//_Init();
}

CTaskManager::~CTaskManager( void )
{
	if(CDbManager::db)
	{
		CDbManager::db->close();
		CDbManager::db==NULL;
	}
}

//=================私有方法区==============================


//检查任务管理相关表是否存在
void CTaskManager::_CheckTables()
{
	CDbManager::_CheckDB();
	if(!CDbManager::db->tableExists("task_management"))_Create_Task_Management_Table();
}
//创建任务管理表
void CTaskManager::_Create_Task_Management_Table()
{
	CDbManager::_CheckDB();
	CDbManager::db->execDML("CREATE TABLE \"task_management\" (  [task_id] INTEGER NOT NULL ON CONFLICT ROLLBACK PRIMARY KEY ON CONFLICT ROLLBACK AUTOINCREMENT, [task_name] CHAR, [task_file_id] CHAR NOT NULL ON CONFLICT ROLLBACK, [task_file_name] CHAR, [task_file_pid] CHAR NOT NULL ON CONFLICT ROLLBACK, [task_percentage] INT DEFAULT 0, [task_trans_dir] BOOL NOT NULL ON CONFLICT ROLLBACK, [task_local_path] CHAR NOT NULL ON CONFLICT ROLLBACK,[task_priority] INT DEFAULT 0,[task_state] INT DEFAULT 0,[task_pre_sname] CHAR DEFAULT '',[IS_BACKGROUND] INT DEFAULT 0);");
}





void CTaskManager::_AddToTaskList(CppSQLite3Query & query)
{
    
	while(!query.eof())
    {
		CTask * task = _GetCTaskFromQuery(query);
		if(task->GetTaskState()==1&&task->GetTaskPercentage()<100)task->SetPriority(999999);
		_InsertToTaskList(task);
		
		query.nextRow();
	}
}

void CTaskManager::_InsertToTaskList(CTask * task)
{
	//tthread::lock_guard<tthread::mutex> lock(task_manager_mutex);
	task_manager_mutex.lock();
	(*task_list)[task->GetTaskId()]=task;
	//CallUpdateTaskView(task);
	if(!task->IsBackGround())
        CallInsertToTaskView(task);
	task_manager_mutex.unlock();
	
}


void CTaskManager::_LoadAllTasks()
{
	
	const char * select_all_task_sql = "select * from task_management  where (task_state=0 OR task_state=1 OR task_state=-1)";
	CppSQLite3Query query = CDbManager::db->execQuery(select_all_task_sql);
	_AddToTaskList(query);
    
}



void CTaskManager::_Init()
{
	//tthread::lock_guard<tthread::mutex> lock(task_manager_mutex);
	if(CTaskManager::Inited)return;
	//if(!CTaskManager::instance){
    if(!CTaskManager::task_list)
        CTaskManager::task_list = new std::map<const int,CTask *>;
    CDbManager::_CheckDB();
    _CheckTables();
    _LoadAllTasks();
    CTaskManager::Inited = true;
    
    //CTaskManager::instance = this;
	//}
}
void CTaskManager::_UnInit()
{
	if(CTaskManager::Inited)
	{
		CDbManager::CloseDb();
		task_list->clear();
	}
	CTaskManager::Inited=false;
}
void CTaskManager::_FreeAll()
{
	//delete CTaskManager::db;
}

//-------------------任务持久化信息存取方法------------------

CTask * CTaskManager::_GetCTaskFromDB(const int task_id)
{
	//tthread::lock_guard<tthread::mutex> lock(task_manager_mutex);
	ostringstream oss;
	oss<<"select * from task_management where task_id='"<<task_id<<"'";
	CppSQLite3Query query = CDbManager::db->execQuery(oss.str().c_str());
    
	return _GetCTaskFromQuery(query);
}

CTask * _GetCTaskFromQuery(CppSQLite3Query & query)
{
	if(!query.eof()){
		const int task_id = query.getIntField("task_id",-1);
		const string task_name = query.getStringField("task_name");
		const string task_file_id = query.getStringField("task_file_id");
		const string task_file_name = query.getStringField("task_file_name");
		const string task_file_pid = query.getStringField("task_file_pid");
		const int task_percentage = query.getIntField("task_percentage");
		const bool task_trans_dir = query.getIntField("task_trans_dir");
		const string task_local_path = query.getStringField("task_local_path");
		const int task_curent_split_index = query.getIntField("task_priority");
		const int task_state = query.getIntField("task_state");
		const string task_pre_sname = query.getStringField("task_pre_sname");
		const int is_background = query.getIntField("IS_BACKGROUND");
		CTask * task = new CTask(task_id,task_name,task_percentage,task_file_id,task_file_name,task_file_pid,task_local_path,task_trans_dir,task_state,task_curent_split_index,task_pre_sname,is_background);
		//task->SetPreSName(task_pre_sname);
		return task;
	}
	return NULL;
}

void CTaskManager::_UpdateTaskInDB( CTask * task )
{
	//tthread::lock_guard<tthread::mutex> lock(task_manager_mutex);
	if(!task)return;
	ostringstream oss;
	oss<<"update task_management set ";
	oss<<"task_file_id = '"<<task->GetFileId()<<"',";
	oss<<"task_percentage = '"<<task->GetTaskPercentage()<<"',";
	oss<<"task_priority = "<<task->GetPriority()<<",";
	oss<<"task_state = "<<task->GetTaskState()<<", ";
	oss<<"task_pre_sname = '"<<task->GetPreSName()<<"' ";
	oss<<" Where task_id = '"<<task->GetTaskId()<<"'";
	try{
		CDbManager::db->execDML(oss.str().c_str());
		//SevenCBoxClient::GetLOG()<<"save task to db success."<<endl;
	}catch(CppSQLite3Exception){
		//SevenCBoxClient::GetLOG()<<"update task error:"<<e->errorMessage()<<endl;
	}
    
}


void CTaskManager::_DeleteCTaskInDB(const int task_id,bool & ret)
{
    
	ostringstream oss;
	oss<<"delete from task_management ";
	oss<<" Where task_id = '";
	oss<<task_id;
	oss<<"'";
	try{
		ret = (CDbManager::db->execDML(oss.str().c_str())>0);
	}catch(CppSQLite3Exception){
		//SevenCBoxClient::GetLOG()<<"delete task error:"<<e->errorMessage()<<endl;
		ret = false;
	}
    
}



CTask * CTaskManager::_CreateNewTask( const string &stask_name,const string & stask_file_id, const string & stask_file_name,const string & stask_file_pid,const string & stask_local_path,const bool & btask_trans_dir ,bool is_background)
{
    
	const char * select_last_sql = "select * from task_management where rowid=last_insert_rowid()";
    
	string check_exist_sql = "select count(*) from task_management where task_local_path='";
	check_exist_sql.append(stask_local_path);
	check_exist_sql.append("'");
	check_exist_sql.append(" and ");
	check_exist_sql.append(" task_file_pid='");
	check_exist_sql.append(stask_file_pid);
	check_exist_sql.append("'");
    
	string select_by_path_sql = "select * from task_management where task_local_path='";
	select_by_path_sql.append(stask_local_path);
	select_by_path_sql.append("'");
	select_by_path_sql.append(" and ");
	select_by_path_sql.append(" task_file_pid='");
	select_by_path_sql.append(stask_file_pid);
	select_by_path_sql.append("'");
	int background = is_background?1:0;
	std::ostringstream ost;
	ost<<"insert into task_management(task_name,task_state,task_percentage,task_file_id,task_file_name,task_file_pid,task_local_path,task_trans_dir,is_background) values(";
	ost<<"'"<<stask_name<<"',";	//task_name
	ost<<0<<",";	//task_state
	ost<<0<<",";	//task_percentage
	if(btask_trans_dir)
		ost<<"'-1',";	//file_id on upload
	else
		ost<<"'"<<stask_file_id<<"',";	//file_id on download
	ost<<"'"<<stask_file_name<<"',";	//task_file_name
	ost<<"'"<<stask_file_pid<<"',";	//task_file_pid
	ost<<"'"<<stask_local_path<<"',";	//task_file_local_path
	ost<<btask_trans_dir<<",";	//upload or download
	ost<<background;	//upload or download
	ost<<")";
	try{
        CDbManager::_CheckDB();
        //判断记录是否存在
        
        int count = CDbManager::db->execScalar(check_exist_sql.c_str(),0);
        CTask * task=NULL;
        if(count==0){
            
            //插入一条记录
            CDbManager::db->execDML(ost.str().c_str());
            CppSQLite3Query query = CDbManager::db->execQuery(select_last_sql);
            task = _GetCTaskFromQuery(query);
            
            
        }else{
            
            CppSQLite3Query query = CDbManager::db->execQuery(select_by_path_sql.c_str());
            task = _GetCTaskFromQuery(query);
            //if(task->GetTaskState()==3)task->ChangeState(1);
            
        }
        
        if(task){
            if(task->IsUpload())
                task->SetMaxSpeed(SevenCBoxClient::Config.GetMaxUploadSpeed());
            else
                task->SetMaxSpeed(SevenCBoxClient::Config.GetMaxDownloadSpeed());
        }
        return task;
	}catch(CppSQLite3Exception e)
	{
		return NULL;
	}
}


//=================公有方法区==============================

CTask * CTaskManager::CreateNewTask( const string &stask_name,const int & itask_percentage,const string & stask_file_id, const string & stask_file_name,const string & stask_file_pid,const string & stask_local_path,const bool & btask_trans_dir ,bool is_background)
{
	//tthread::lock_guard<tthread::mutex> lock(task_manager_mutex);
	
	CTask * task = _CreateNewTask(stask_name,stask_file_id,stask_file_name,stask_file_pid,stask_local_path,btask_trans_dir,is_background);
	//
	//task_list->insert(pair<const int,CTask *>(task->GetTaskId(),task));
    
	if(task && !task->IsBackGround()){
		int task_id = task->GetTaskId();
		if(task_list->find(task_id)==task_list->end()){
			
			//(*task_list)[task->GetTaskId()]=task;
			_InsertToTaskList(task);
			
            
		}
		else
		{
			//delete task;
			task = task_list->find(task_id)->second;
			task->ChangeState(0);
			task->ChangePercentage(0);
			task->SetStartState(0);
		}
	}
	//_CheckTaskMonitor();
	return task;
    
}
CTask * CTaskManager::CreateNewUploadTask( const string & stask_file_pid,const string & stask_file_local_path,const string & f_mime,SCBoxCallBack callback,void * ui_ptr)
{
	Value jsonResponse;
	CTask * newTask = CreateNewUploadTask(stask_file_pid, stask_file_local_path, f_mime, jsonResponse);
	if(newTask&&callback)
	{
		callback(jsonResponse,ui_ptr);
	}
	return newTask;
}

CTask * CTaskManager::CreateNewUploadTask( const string & stask_file_pid,const string & stask_file_local_path,const string & f_mime,Value & jsonResponse)
{
	const string stask_file_name = CFileSplitter::get_file_name(stask_file_local_path.c_str());
	const string stask_name = "upload "+stask_file_name;
	const int itask_percentage = 0;
	const string stask_file_id = "";
    
	CTask * newTask = NULL;
	try{
		newTask = CreateNewTask( stask_name,itask_percentage,stask_file_id, stask_file_name,stask_file_pid,stask_file_local_path,true,false);
		if(newTask!=NULL){
			jsonResponse["code"]=0;
		}
		else
		{
			jsonResponse["code"]=1;
			jsonResponse["error"]="task is existed!";
		}
	}catch(...)
	{
		jsonResponse["code"]=1;
		jsonResponse["error"]="can not create new task!";
	}
    
	return newTask;
    
}

//void StartTask( void * taskPtr )
//{
//	CTask * task = (CTask *)taskPtr;
//	if(!task->IsRunning()){
//		task->Start();
//	}
//}



CTask * CTaskManager::GetTask(int task_id)
{
	try{
        return (*task_list)[task_id];
	}catch(...)
	{
		return NULL;
	}
}

CTask * CTaskManager::CreateImmediatelyDownloadTask( const string & f_id, const string & savefile, SCBoxCallBack callBack,void * ui_ptr)
{
	CTask * task = NULL;
	
	int task_id = -atoi(f_id.c_str());
	if(task_list->find(task_id)!=task_list->end())
        task = (*task_list)[task_id];
	else
	{
		task = new CTask(task_id,"back download "+savefile,0,f_id,f_id,"-1",savefile,false,0,0,"",1,1);
		//tthread::lock_guard<tthread::mutex> lock(task_manager_mutex);
		/*task_manager_mutex.lock();
         (*task_list)[task_id]=task;
         task_manager_mutex.unlock();*/
		_InsertToTaskList(task);
		//if(task)task->Start();
		if(task && callBack){
			//task->SetCallBack(ui_ptr);
			Value jsonValue;
			jsonValue["task_id"]= task->GetTaskId();
			callBack(jsonValue,ui_ptr);
		}
		//if(!task->IsBackGround())CallInsertToTaskView(task);
	}
	//if(task)
	//SevenCBoxClient::GetLOG()<<time(0)<<"[CreateImmediatelyDownloadTask],taskid="<<task->GetTaskId()<<"  filename="<<task->GetFileLocalPath()<<endl;
	return task;
	
}

CTask * CTaskManager::CreateNewDownloadTask( const string & f_id, const string & savefile,bool open_after_downloaded, SCBoxCallBack callBack,void * ui_ptr,bool is_background)
{
	const string stask_name = "DownLoad for "+f_id;
	const int itask_percentage = 0;
	const string stask_file_id = f_id;
	const string stask_file_name = CFileSplitter::get_file_name(savefile.c_str());
	Value jsonResponse;
	const string stask_file_local_path = savefile;
	try{
		CTask * newTask = CreateNewTask( stask_name,itask_percentage,stask_file_id, stask_file_name,"",stask_file_local_path,false ,is_background);
		if(newTask && callBack)
		{
			newTask->SetOpenAfterDownloaded(open_after_downloaded);
			jsonResponse["code"]=0;
			callBack(jsonResponse,ui_ptr);
		}
		return newTask;
	}catch(...)
	{
		//SevenCBoxClient::GetLOG()<<"can't create new task for "<<f_id<<" download."<<endl;
		if(callBack)
		{
			jsonResponse["code"]=1;
			jsonResponse["error"]= "can't create new task for "+f_id+" download.";
			callBack(jsonResponse,ui_ptr);
			return NULL;
		}
	}
	return NULL;
}

//开始任务监控线程
void CTaskManager::StartTaskMonitor( void )
{
	if(!Inited)
		_Init();
	if(((CTaskMonitor *)taskMonitor)->IsStarted())return;
	((CTaskMonitor *)taskMonitor)->StartMonitor();
    
}
//结束任务监控线程
void CTaskManager::StopTaskMonitor( void )
{
	if(taskMonitor &&((CTaskMonitor *)taskMonitor)->IsStarted())
		((CTaskMonitor *)taskMonitor)->StopMonitor();
	_UnInit();
	
}
void CTaskManager::DeleteFromTaskList(const int task_id)
{
	//tthread::lock_guard<tthread::mutex> lock(task_manager_mutex);
	if(task_list->find(task_id)!=task_list->end()){
		
		CTask * task = (*task_list)[task_id];
		//task_manager_mutex.lock();
		task_list->erase(task_id);
		//task_manager_mutex.unlock();
		if(task)
		{
			delete task;
			task = NULL;
		}
	}
}
//==================task control method============================
void CTaskManager::Start( const int task_id )
{
	//tthread::lock_guard<tthread::mutex> lock(task_manager_mutex);
	if(task_list->find(task_id)!=task_list->end()){
		CTask * task = (*task_list)[task_id];
		if(!task)return;
		if(!task->IsRunning()){
			//task->Start();
			//task_manager_mutex.lock();
			task->task_recursive_mutex->lock();
			task->SetStartState(false);
			task->ChangeState(1);
			task->SetPriority(999999);
			task->task_recursive_mutex->unlock();
			//task_manager_mutex.unlock();
			//_CheckTaskMonitor();
			_UpdateTaskInDB( task );
            
		}
	}
}

void CTaskManager::Stop( const int task_id )
{
	
	if(task_list->find(task_id)!=task_list->end()){
		//task_manager_mutex.lock();
		CTask * task = (*task_list)[task_id];
		task->task_recursive_mutex->lock();
		task->SetStartState(false);
		task->SetPriority(-1);
		task->ChangeState(0);
		if(task->GetTaskType()==0)
			_UpdateTaskInDB( task );
		task->task_recursive_mutex->unlock();
		//task_manager_mutex.unlock();
		//CallUpdateTaskView((*task_list)[task_id]);
		//_CheckTaskMonitor();
	}
    
}

void CTaskManager::Delete( const int task_id )
{
    
	try{
        
		ostringstream oss;
		oss<<"delete from task_management ";
		oss<<" Where task_id = '";
		oss<<task_id;
		oss<<"'";
		(CDbManager::db->execDML(oss.str().c_str())>0);
	}catch(CppSQLite3Exception){
		//SevenCBoxClient::GetLOG()<<"delete task error:"<<e->errorMessage()<<endl;
	}
	
	if(task_list->find(task_id)!=task_list->end()){
		CTask * task = (*task_list)[task_id];
        //int taskState = task->GetTaskState();
		if(task){
			//task_manager_mutex.lock();
			task->task_recursive_mutex->lock();
			task->ChangeState(-2);
			task->SetToBeDelete();
			task->task_recursive_mutex->unlock();
			//task_manager_mutex.unlock();
			
			//CallUpdateTaskView(task);
			//_CheckTaskMonitor();
			
		}
		
        //得先停止线程，再删除
        //task_list->erase(task_id);
	}
    
}

//==================Get Single Instance of CTaskManager==============
CTaskManager * CTaskManager::task_manager_instnce = NULL;
CTaskManager * CTaskManager::GetInstance()
{
	if(CTaskManager::task_manager_instnce == NULL){
		task_manager_instnce = new CTaskManager;
		//task_manager_instnce->_Init();
		task_manager_instnce->taskMonitor = CTaskMonitor::GetInstance(task_manager_instnce);
	}
    
	return task_manager_instnce;
}

void CTaskManager::Save( CTask * task )
{
	tthread::lock_guard<tthread::mutex> lock(task_manager_mutex);
	//if(task_list->find(task->GetTaskId())!=task_list->end())
	if(task->GetTaskType()==0)
        _UpdateTaskInDB( task );
    
	//task_manager_mutex->unlock();
}

void CTaskManager::SetThumbTaskCallBack( TaskView_CallBack callBack )
{
	picView_ThumbTaskCallBackFunc = callBack;
}

void CTaskManager::SetTaskViewNewTaskCallBack( TaskView_CallBack callBack )
{
	taskView_NewTaskCallBackFunc = callBack;
}

void CTaskManager::SetTaskViewUpdateTaskCallBack( TaskView_CallBack callBack )
{
	taskView_UpdateTaskCallBackFunc = callBack;
}

TaskView_CallBack CTaskManager::GetTaskViewNewTaskCallBack()
{
	return taskView_NewTaskCallBackFunc;
}

TaskView_CallBack CTaskManager::GetTaskViewUpdateTaskCallBack()
{
	return taskView_UpdateTaskCallBackFunc;
}

TaskView_CallBack GetThumbTaskCallBack()
{
	return picView_ThumbTaskCallBackFunc;
}
void CTaskManager::CreateTaskView()
{
	//tthread::lock_guard<tthread::mutex> lock(task_manager_mutex);
	map<const int,CTask *>::iterator it = task_list->begin();
	while(it != task_list->end())
	{
		CTask * task = it->second;
		//CTask * v_task = new CTask(task);
		
		if(!task->IsBackGround()&&taskView_NewTaskCallBackFunc){
			taskView_NewTaskCallBackFunc(task);
			//this_thread::sleep_for(tthread::chrono::microseconds(100));
		}
		it++;
	}
	//task_manager_mutex->unlock();
    
}


void CTaskManager::CallUpdatePicThum(CTask * task)
{
	if(picView_ThumbTaskCallBackFunc && task->GetTaskType()==1){
        
		picView_ThumbTaskCallBackFunc(task);
	}
}
void CTaskManager::CallInsertToTaskView(CTask * task)
{
    
	
	if(taskView_NewTaskCallBackFunc && !task->IsBackGround()){
        
		taskView_NewTaskCallBackFunc(task);
	}
    
}
void CTaskManager::CallUpdateTaskView(CTask * task)
{
    
	if(taskView_UpdateTaskCallBackFunc && !task->IsBackGround()){
        
        taskView_UpdateTaskCallBackFunc(task);
	}
}
int CTaskManager::GetCurrentIMDownloadThreads()
{
	//SevenCBoxClient::GetLOG()<<time(0)<<"[GetCurrentIMDownloadThreads]:begin"<<endl;
	int cur_download = 0;
	//task_manager_mutex.lock();
	map<const int,CTask *>::iterator it = task_list->begin();
	while(it != task_list->end())
	{
		CTask * task = it->second;
		if(!task){
			
			continue;
		}
		if(task->IsStarted()&& task->GetTaskType()==1 && !task->IsUpload())
			cur_download++;
		it++;
	}
	//SevenCBoxClient::GetLOG()<<time(0)<<"[GetCurrentIMDownloadThreads]:end"<<endl;
	//task_manager_mutex.unlock();
	return cur_download;
}
int CTaskManager::GetCurrentDownloadThreads()
{
	//SevenCBoxClient::GetLOG()<<time(0)<<"[GetCurrentDownloadThreads]:begin"<<endl;
	int cur_download = 0;
	//task_manager_mutex.lock();
	map<const int,CTask *>::iterator it = task_list->begin();
	while(it != task_list->end())
	{
		CTask * task = it->second;
		if(!task){
			
			continue;
		}
		if(task->IsRunning()&& task->GetTaskType()==0 && !task->IsUpload())cur_download++;
		it++;
	}
	//task_manager_mutex.unlock();
	//SevenCBoxClient::GetLOG()<<time(0)<<"[GetCurrentDownloadThreads]:end"<<endl;
	return cur_download;
}

int CTaskManager::GetCurrentUploadThreads()
{
	//SevenCBoxClient::GetLOG()<<time(0)<<"[GetCurrentUploadThreads]:begin"<<endl;
	int cur_upload = 0;
	//task_manager_mutex.lock();
	map<const int,CTask *>::iterator it = task_list->begin();
	while(it != task_list->end())
	{
		CTask * task = it->second;
		if(!task){
			
			continue;
		}
		if(task->IsRunning() && task->IsUpload())cur_upload++;
		it++;
	}
	//task_manager_mutex.unlock();
	//SevenCBoxClient::GetLOG()<<time(0)<<"[GetCurrentUploadThreads]:end"<<endl;
	return cur_upload;
}



int CTaskManager::GetCurrentRunningTaskThreads()
{
	//SevenCBoxClient::GetLOG()<<time(0)<<"[GetCurrentRunningTaskThreads]:begin"<<endl;
	//task_manager_mutex.lock();
	int cur_totals_threads = 0;
	map<const int,CTask *>::iterator it = task_list->begin();
	while(it != task_list->end())
	{
		CTask * task = it->second;
		if(!task){
			//task_list->erase(it->first);
			continue;
		}
		if(task&&task->IsStarted())cur_totals_threads++;
		it++;
	}
	//task_manager_mutex.unlock();
	//SevenCBoxClient::GetLOG()<<time(0)<<"[GetCurrentRunningTaskThreads]:end"<<endl;
	return cur_totals_threads;
}

vector<CTask *> * CTaskManager::GetDownloadingTasks()
{
	//SevenCBoxClient::GetLOG()<<time(0)<<"[GetUploadingTasks]:begin"<<endl;
	vector<CTask *> * downloading_task_list = new vector<CTask *>;
	//task_manager_mutex.lock();
	map<const int,CTask *>::iterator it = task_list->begin();
	while(it != task_list->end())
	{
		CTask * task = it->second;
		if(task->GetTaskType()==0&&!task->IsUpload()&&(task->GetTaskState()==1||task->GetTaskState()==0))downloading_task_list->push_back(task);
		it++;
	}
	//task_manager_mutex.unlock();
	//SevenCBoxClient::GetLOG()<<time(0)<<"[GetUploadingTasks]:end"<<endl;
	return downloading_task_list;
}

vector<CTask *> * CTaskManager::GetUploadingTasks()
{
	//SevenCBoxClient::GetLOG()<<time(0)<<"[GetUploadingTasks]:begin"<<endl;
	vector<CTask *> * uploading_task_list = new vector<CTask *>;
	map<const int,CTask *>::iterator it = task_list->begin();
	while(it != task_list->end())
	{
		CTask * task = it->second;
		if(!task){
			//task_list->erase(it->first);
			continue;
		}
		if(task->IsUpload()&&(task->GetTaskState()==1||task->GetTaskState()==0))uploading_task_list->push_back(task);
		it++;
	}
	//SevenCBoxClient::GetLOG()<<time(0)<<"[GetUploadingTasks]:end"<<endl;
	return uploading_task_list;
}

vector<CTask *> * CTaskManager::GetRunningTasks()
{
	//SevenCBoxClient::GetLOG()<<time(0)<<"[GetRunningTasks]:begin"<<endl;
	//task_manager_mutex.lock();
	vector<CTask *> * running_task_list = new vector<CTask *>;
	map<const int,CTask *>::iterator it = task_list->begin();
	while(it != task_list->end())
	{
		CTask * task = it->second;
		if(!task){
			//task_list->erase(it->first);
			continue;
		}
		if(task->IsRunning())running_task_list->push_back(task);
		it++;
	}
	//task_manager_mutex.unlock();
	//SevenCBoxClient::GetLOG()<<time(0)<<"[GetRunningTasks]:end"<<endl;
	return running_task_list;
}

vector<CTask *> * CTaskManager::GetCompletedTasks()
{
	//SevenCBoxClient::GetLOG()<<time(0)<<"[GetCompletedTasks]:begin"<<endl;
	//task_manager_mutex.lock();
	vector<CTask *> * completed_task_list = new vector<CTask *>;
	string select_completed_sql = "select * from task_management where task_state=3";
	try{
        CppSQLite3Query query = CDbManager::db->execQuery(select_completed_sql.c_str());
        if(!query.eof()){
            const int task_id = query.getIntField("task_id",-1);
            const string task_name = query.getStringField("task_name");
            const string task_file_id = query.getStringField("task_file_id");
            const string task_file_name = query.getStringField("task_file_name");
            const string task_file_pid = query.getStringField("task_file_pid");
            const int task_percentage = query.getIntField("task_percentage");
            const bool task_trans_dir = query.getIntField("task_trans_dir");
            const string task_local_path = query.getStringField("task_local_path");
            //const int task_curent_split_index = query.getIntField("task_priority");
            const int task_state = query.getIntField("task_state");
            const string task_pre_sname = query.getStringField("task_pre_sname");
            const int is_background = query.getIntField("IS_BACKGROUND");
            CTask * task = new CTask(task_id,task_name,task_percentage,task_file_id,task_file_name,task_file_pid,task_local_path,task_trans_dir,task_state,0,task_pre_sname,is_background);
            completed_task_list->push_back(task);
        }
	}catch(...){}
	//task_manager_mutex.unlock();
	//SevenCBoxClient::GetLOG()<<time(0)<<"[GetCompletedTasks]:end"<<endl;
	return completed_task_list;
}

vector<CTask *> * CTaskManager::GetAllTasks()
{
	
	vector<CTask *> * all_task_list = new vector<CTask *>;
	//task_manager_mutex.lock();
	map<const int,CTask *>::iterator it = task_list->begin();
	while(it != task_list->end())
	{
		CTask * task = it->second;
		if(!task){
			
			continue;
		}
		all_task_list->push_back(task);
		it++;
	}
	string select_completed_sql = "select * from task_management";
	try{
        CppSQLite3Query query = CDbManager::db->execQuery(select_completed_sql.c_str());
        if(!query.eof()){
            const int task_id = query.getIntField("task_id",-1);
            const string task_name = query.getStringField("task_name");
            const string task_file_id = query.getStringField("task_file_id");
            const string task_file_name = query.getStringField("task_file_name");
            const string task_file_pid = query.getStringField("task_file_pid");
            const int task_percentage = query.getIntField("task_percentage");
            const bool task_trans_dir = query.getIntField("task_trans_dir");
            const string task_local_path = query.getStringField("task_local_path");
            //const int task_curent_split_index = query.getIntField("task_priority");
            const int task_state = query.getIntField("task_state");
            const string task_pre_sname = query.getStringField("task_pre_sname");
            const int is_background = query.getIntField("IS_BACKGROUND");
            CTask * task = new CTask(task_id,task_name,task_percentage,task_file_id,task_file_name,task_file_pid,task_local_path,task_trans_dir,task_state,0,task_pre_sname,is_background);
            if(task_list->find(task->GetTaskId())==task_list->end())all_task_list->push_back(task);
        }
	}catch(...)
	{
        
	}
	//task_manager_mutex.unlock();
	return all_task_list;
}

vector<int> * CTaskManager::GetTaskIdList()
{
	vector<int> * taskIdList = new vector<int>;
	//task_manager_mutex.lock();
	map<const int,CTask *>::iterator it = task_list->begin();
	while(it != task_list->end())
	{
		int task_id = it->first;
		taskIdList->push_back(task_id);
		it++;
	}
	//task_manager_mutex.unlock();
	return taskIdList;
}

vector<int> * CTaskManager::GetNotRuningTaskIdList()
{
	//SevenCBoxClient::GetLOG()<<time(0)<<"[GetNotRuningTaskIdList]:begin"<<endl;
	//task_manager_mutex.lock();//------------lock start
	vector<int> * taskIdList = new vector<int>;
	if(task_list->size()==0){
		delete taskIdList;
		return NULL;
	}
	//SevenCBoxClient::GetLOG()<<"[GetNotRuningTaskIdList]:"<<"current task list"<<endl;
	//task_manager_mutex.lock();
	map<const int,CTask *>::iterator it = task_list->begin();
	while(it != task_list->end())
	{
		CTask * task = it->second;
		//SevenCBoxClient::GetLOG()<<"[GetNotRuningTaskIdList]:"<<"task id="<<task->GetTaskId()<<" task type="<<task->GetTaskType()<<" task state="<<task->GetTaskState()<<endl;
		if(!task){
			//SevenCBoxClient::GetLOG()<<time(0)<<"[GetNotRuningTaskIdList]:find a null task with id="<<it->first<<endl;
			continue;
		}
		//SevenCBoxClient::GetLOG()<<"[GetNotRuningTaskIdList]:"<<"task id="<<task->GetTaskId()<<" task type="<<task->GetTaskType()<<" task state="<<task->GetTaskState()<<"isupload="<<task->IsUpload()<<" isRunning="<<task->IsRunning()<<endl;
		if(!task->IsRunning()){
			int task_id = it->first;
			taskIdList->push_back(task_id);
		}
		it++;
	}
	//task_manager_mutex.unlock();
	if(taskIdList->size()==0){
		delete taskIdList;
		return NULL;
	}
	//task_manager_mutex.unlock();//----------lock end
	//SevenCBoxClient::GetLOG()<<time(0)<<"[GetNotRuningTaskIdList]:end"<<endl;
	return taskIdList;
}