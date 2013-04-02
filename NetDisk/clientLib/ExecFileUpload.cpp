#include <clientlib/ExecFileUpload.h>
#include <clientlib/StringUtils.h>
#include <clientlib/SevenCBoxClient.h>
#ifdef _WIN32
#include <windows.h>
//#include <atlstr.h>
#endif
#include "filesplit/split/FileSplitter.h"
#include "clientlib/Base64Help.h"
#include "md5.h"
#include <cstdio>
#include "clientlib/tinythread.h"
#include "PostRequestExecuter.h"
using namespace ClientConfig;


const char * GetFileName( const char * m_strFilePath );
string GetFileMD5( const string & f_name );
const long GetFileSize(const char * f_name);
bool PreCheck(int task_id,CTaskManager * manager,Value &jsonRequestHeader);
int CheckUploadState(const string & s_name,const string & md5Value,Value &jsonRequestHeader);
bool CheckFmUploadVerifyResponseCode( int responseCode, int task_id, CTaskManager * taskManager ) ;
void StartUploadThread(void * executor);
void PostRequestCallBack(Value &jsonValue,void * executer);
//tthread::mutex cexe_file_upload_mutex;


CExecFileUpload::CExecFileUpload(CTask * ctask)
{
	task = ctask;
}




CExecFileUpload::~CExecFileUpload(void)
{
	pThread->join();
	delete pThread;
}




void CExecFileUpload::ExecuteTask()
{
	task->ChangeState(1);
	task->SetStartState(true);
    
	pThread = new tthread::thread(StartUploadThread,this->task);
	
}




//************************************
// Method:    StartUploadThread
// FullName:  StartUploadThread
// Access:    public
// Returns:   void
// Qualifier: Function for Upload Thread
// Parameter: void * executor
//************************************
void StartUploadThread(void * taskPtr)
{	//tthread::lock_guard<tthread::mutex> lock(cexe_file_upload_mutex);
    @autoreleasepool {
        CTask * task = (CTask *)taskPtr;
        
		if(!task||task->GetTaskState()!=1)
		{
			task->SetStartState(false);
			return;
		}
		try{
            CMultiPostRequestExecuter postExecuter(task);
            postExecuter.ExecuteTask();
            //this_thread::yield();
		}catch(...)
		{
			SevenCBoxClient::GetLOG()<<"An Exeception occurred durring Uploading ["<<task->GetFileName()<<"]! Thread Stoped!"<<endl;
            
			task->ChangeState(0);	//出现已成下载停止
			task->SetStartState(false);
			SevenCBoxClient::GetTaskManager()->Save(task);
			this_thread::yield();
			return;
		}
    }
}