#include "clientlib/Task.h"
#include "filesplit/split/FileSplitter.h"
#include <ctime>
#include <clientlib/tinythread.h>
#include <clientlib/fast_mutex.h>
#include <clientlib/SevenCBoxClient.h>
//#include <clientlib/ExecFileUpload.h>
//#include <clientlib/ExecFileDownLoad.h>
#include "GetRemoteFileExecutor.h"
#include "PostRequestExecuter.h"
#include "GetRemoteThumbExecutor.h"

extern long GetDownLoadFileSizeById( string file_id ) ;



CTask::~CTask(void)
{
	if(task_executer)
	{
		delete task_executer;
		task_executer = NULL;
	}
	delete task_recursive_mutex;
}
const int CTask::GetTaskId()
{
	////tthread::lock_guard<tthread::fast_mutex> lock(task_mutex);
	return task_id;
}
const char * CTask::GetTaskName()
{
	////tthread::lock_guard<tthread::fast_mutex> lock(task_mutex);
	return this->task_name.c_str();
}

const char * CTask::GetFileId()
{
	////tthread::lock_guard<tthread::fast_mutex> lock(task_mutex);
	return this->task_file_id.c_str();
}

const char * CTask::GetFileName()
{
	////tthread::lock_guard<tthread::fast_mutex> lock(task_mutex);
	return this->task_file_name.c_str();
}

int CTask::GetMaxSpeed()
{
	return task_max_speed;
}

int CTask::GetTaskPercentage()
{
	////tthread::lock_guard<tthread::fast_mutex> lock(task_mutex);
	return task_percentage;
}

int CTask::GetTaskType()
{
	////tthread::lock_guard<tthread::fast_mutex> lock(task_mutex);
	return task_type;
}


const char * CTask::GetFolderId()
{
	////tthread::lock_guard<tthread::fast_mutex> lock(task_mutex);
	return this->task_file_pid.c_str();
}

const char * CTask::GetFileLocalPath()
{
	////tthread::lock_guard<tthread::fast_mutex> lock(task_mutex);
	return this->task_local_path.c_str();
}
bool CTask::IsUpload()
{
	////tthread::lock_guard<tthread::fast_mutex> lock(task_mutex);
	return task_is_upload;
}

const int CTask::GetTaskState()
{
	//tthread::lock_guard<tthread::fast_mutex> lock(task_mutex);
	return this->task_state;
}
int CTask::GetPriority()
{
	////tthread::lock_guard<tthread::fast_mutex> lock(task_mutex);
	return task_priority;
}


const char * CTask::GetPreSName()
{
	////tthread::lock_guard<tthread::fast_mutex> lock(task_mutex);
	return task_pre_sname.c_str();
}



float CTask::GetTrransfSpeed()
{
	////tthread::lock_guard<tthread::fast_mutex> lock(task_mutex);
	return task_transf_speed;
}

long CTask::GetTaskFileSize()
{
	////tthread::lock_guard<tthread::fast_mutex> lock(task_mutex);
	if(task_is_upload==false && task_file_size==-1)task_file_size= GetDownLoadFileSizeById(task_file_id);
	return task_file_size;
}

string CTask::GetFileMD5()
{
	////tthread::lock_guard<tthread::fast_mutex> lock(task_mutex);
	if(task_file_md5.empty())
	{
		task_file_md5 = CFileSplitter::get_file_md5(task_local_path.c_str());
	}
	return task_file_md5;
}



time_t CTask::GetStartTime()
{
	////tthread::lock_guard<tthread::fast_mutex> lock(task_mutex);
	return start_time;
}


long CTask::GetDuration()
{
	////tthread::lock_guard<tthread::fast_mutex> lock(task_mutex);
	return (long)(time(NULL)-start_time);
}

bool CTask::IsRunning()
{
	//tthread::lock_guard<tthread::fast_mutex> lock(task_mutex);
	return started&&task_executer;
}
bool CTask::IsStarted()
{
	//tthread::lock_guard<tthread::fast_mutex> lock(task_mutex);
	return started;
}
long CTask::GetSkipOnStart()
{
	return skip_on_start;
}

bool CTask::IsBackGround()
{
	//tthread::lock_guard<tthread::fast_mutex> lock(task_mutex);
	return task_is_bkground>0;
}

int ProgressFunc(char *progress_data,
	double t, /* dltotal */
	double d, /* dlnow */
	double ultotal,
	double ulnow)
{
	return 0;
}

long GetDownLoadFileSizeById( string file_id ) 
{
	Value jsonResponse;
	SevenCBoxClient::FmGetFileInfo(file_id,jsonResponse);
	if(jsonResponse.isMember("code")&&jsonResponse["code"].asInt()==0)
	{
		Value fileInfos = jsonResponse["files"];
		int nIndex = 0;
		Value fileInfo = fileInfos[nIndex];
		long f_size = fileInfo["f_size"].asInt();
		return f_size;
	}
	return -1;
}

CTask::CTask( const int & itask_id, const string &stask_name,const int & itask_percentage,const string & stask_file_id, const string & stask_file_name,const string & stask_file_pid,const string & stask_local_path,const bool & btask_trans_dir,const int task_init_state,const int priority,string pre_sname,int is_bkground,int itask_type)
{   task_type = itask_type;
	task_transfered_size = 0;
	task_id = itask_id;
	task_name = stask_name;
	task_percentage = itask_percentage;
	task_file_id = stask_file_id;
	task_file_name = stask_file_name;
	task_file_pid = stask_file_pid;
	task_local_path = stask_local_path;
	task_is_upload = btask_trans_dir;
	task_state = task_init_state;
	task_priority = priority;
	start_time = time(NULL);
	started = false;
	task_transf_speed = 0;
	if(task_is_upload)
	task_file_size = CFileSplitter::get_file_size(stask_local_path.c_str());
	else
		task_file_size=GetDownLoadFileSizeById(task_file_id);
	skip_on_start = 0;
	task_pre_sname = pre_sname;
	task_is_bkground = is_bkground;
	task_callback = NULL;
	task_max_speed = INT_MAX;
	task_tobedelete = false;
	task_execute_after_downloaded = false;
	task_retry = 3;
	task_recursive_mutex = new tthread::recursive_mutex;
}
CTask::CTask()
{   
	task_recursive_mutex = new tthread::recursive_mutex;
	task_type = 0;
	task_transfered_size = 0;
	task_id = -1;
	task_name = "";
	task_percentage = 0;
	task_file_id = -1;
	task_file_name = "";
	task_file_pid = -1;
	task_local_path = "";
	task_is_upload = false;
	task_state = -1;
	task_priority = 0;
	start_time = time(NULL);
	started = false;
	task_transf_speed = 0;
	task_file_size = 0;
	skip_on_start = 0;
	task_pre_sname = "";
	task_is_bkground = false;
	task_callback = NULL;
	task_tobedelete = false;
	task_execute_after_downloaded = false;
	task_retry = 3;
}

CTask::CTask( CTask * task )
{

	task_type = task->task_type;
	task_transfered_size =task->task_transfered_size;
	task_id = task->task_id;
	task_name = task->task_name;
	task_percentage = task->task_percentage;
	task_file_id = task->task_file_id;
	task_file_name = task->task_file_name;
	task_file_pid = task->task_file_pid;
	task_local_path = task->task_local_path;
	task_is_upload = task->task_is_upload;
	task_state = task->task_state;
	task_priority = task->task_priority;
	start_time = task->start_time;
	started = task->started;
	task_transf_speed = task->task_transf_speed;
	task_file_size = task->task_file_size;
	skip_on_start = task->skip_on_start;
	task_pre_sname = task->task_pre_sname;
	task_is_bkground = task->task_is_bkground;
	task_callback = task->task_callback;
	task_max_speed = task->task_max_speed;
	task_tobedelete = task->task_tobedelete;
	task_retry = 3;
	task_execute_after_downloaded =task-> task_execute_after_downloaded;
	task_recursive_mutex = new tthread::recursive_mutex;
}

void CTask::SetFileId(string & file_id)
{
	//task_recursive_mutex->lock();
	this->task_file_id = file_id;
	//task_recursive_mutex->unlock();
	//UpdateView();
}
void CTask::SetTrransfSpeed( float speed )
{
	//task_recursive_mutex->lock();
	task_transf_speed = speed;
	//task_recursive_mutex->unlock();
	//UpdateView();
}

void CTask::SetPreSName(const string & pre_sname )
{
	//task_recursive_mutex->lock();
	task_pre_sname = pre_sname;
	//task_recursive_mutex->unlock();
	//UpdateView();
}

void CTask::SetSkipOnStart( long skip )
{
	//task_recursive_mutex->lock();
	skip_on_start = skip;
	//task_recursive_mutex->unlock();
	//UpdateView();
}

void CTask::ChangeState(const int state)
{
	//task_recursive_mutex->lock();
	task_state = state;
	//task_recursive_mutex->unlock();
	UpdateView();
}
void CTask::SetPriority(int index)
{
	//task_recursive_mutex->lock();
	task_priority = index;
	//task_recursive_mutex->unlock();
	//UpdateView();
}
void CTask::ChangePercentage(int percent)
{
	//task_recursive_mutex->lock();
	
	if(percent<0||percent>100)return;
	task_percentage = percent;
	//task_recursive_mutex->unlock();
	UpdateView();
}


void CTask::SetStartState( bool v_started )
{

	//task_recursive_mutex->lock();
	if(v_started)this->start_time = time(NULL);
	else
	{
		//DeleteThread();
		this->stop_time = time(NULL);
	}
	this->started = v_started;
	//task_recursive_mutex->unlock();
	//UpdateView();
}

void CTask::Start()
{
	if(started)return;
	started = true;
	if(task_is_upload)
	{
		task_executer = new CMultiPostRequestExecuter(this);
	}
	else{
		
		
		if(this->task_type==1)
			task_executer = new CGetRemoteThumbExecutor(this);
		else
			task_executer = new CGetRemoteFileExecutor(this);
		
	}
	
	task_executer->ExecuteTask();
	tthread::this_thread::sleep_for(tthread::chrono::milliseconds(1));
	//task_recursive_mutex->unlock();
	//task_mutex.unlock();
}

void CTask::UpdateView()
{
	if(task_type==0)
	SevenCBoxClient::GetTaskManager()->CallUpdateTaskView(this);
	else
	if(task_type==1 && task_state==3)
	SevenCBoxClient::GetTaskManager()->CallUpdatePicThum(this);
}

void CTask::AddTransferedSize( long size )
{
	//task_recursive_mutex->lock();
	task_transfered_size += size;
	int percent = (task_transfered_size+skip_on_start)/GetTaskFileSize();
	percent *= 100;
	task_percentage = percent;
	long time_passed = GetDuration();
	if(time_passed>0){
		task_transf_speed = task_transfered_size/(time_passed*1024);
	}
	//task_recursive_mutex->unlock();
	UpdateView();
}

void CTask::SetTaskType( int itask_type )
{
	//task_recursive_mutex->lock();
	task_type = itask_type;
	//task_recursive_mutex->unlock();
}

void CTask::SetMaxSpeed(int speed)
{
	//task_recursive_mutex->lock();
	task_max_speed =speed;
	//task_recursive_mutex->unlock();
}



void CTask::SetToBeDelete()
{
	//task_recursive_mutex->lock();
	task_tobedelete = true;
	task_state=-2;
	//task_recursive_mutex->unlock();
}

bool CTask::IsToBeDelete()
{
	return task_tobedelete|task_state==-2;
}

void CTask::SetCallBack( TaskCallBack * callBack )
{
	//task_recursive_mutex->lock();
	task_callback = callBack;
	//task_recursive_mutex->unlock();
}

TaskCallBack * CTask::GetCallBack()
{
	return task_callback;
}



void CTask::Complete()
{
	if(task_callback)
	{

	}
}
void CTask::SetOpenAfterDownloaded(bool open_after_downloaded)
{
	task_execute_after_downloaded = open_after_downloaded;
}
bool CTask::OpenAfterDownloaded()
{
	return task_execute_after_downloaded;
}

void CTask::Stop()
{
	task_recursive_mutex->lock();
		task_state = 0;
		started = false;
		task_priority = -1;
		UpdateView();
	task_recursive_mutex->unlock();
		
}

void CTask::DeleteThread()
{
	//task_recursive_mutex->lock();
	if(this->task_executer){
		delete task_executer;
		task_executer = NULL;
	}
	//task_recursive_mutex->unlock();
}

int CTask::GetRetry()
{
	return task_retry;
}

void CTask::SetRetry( int retry )
{
	task_retry = retry;
}
