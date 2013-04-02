#include "PostRequestExecuter.h"
#include <clientlib/SevenCBoxClient.h>
#include "filesplit/split/FileSplitter.h"
#include <clientlib/StringUtils.h>
#include <clientlib/Base64Help.h>
#include "md5.h"

void StartPostResquestThread(void * executer);
//tthread::mutex post_request_mutex;

CMultiPostRequestExecuter::~CMultiPostRequestExecuter(void)
{
	pThread->join();
	delete pThread;
}


void CMultiPostRequestExecuter::ExecuteTask()
{
	task->ChangeState(1);
	task->SetStartState(true);
	pThread = new tthread::thread(StartPostResquestThread,this->task);
}

CMultiPostRequestExecuter::CMultiPostRequestExecuter(CTask * v_Task)
{

	task = v_Task;

}



int CheckUploadState(const string & s_name,const string & md5Value,Value &jsonRequestHeader)
{
	
	Value jsonResponse;
	SevenCBoxClient::FmUploadState(s_name,jsonResponse);
	int responseCode = SevenCBoxClient::GetResponseCode(jsonResponse);
	if(responseCode == 0){
		if(jsonResponse["sname"].empty()){

			return 1;
		}
		else
		{
			string sname = jsonResponse["sname"].asString();
			int skip = jsonResponse["skip"].asInt();
			jsonRequestHeader["s_name"] = sname;
			jsonRequestHeader["skip"] = skip;
			jsonRequestHeader["md5"] = md5Value;//GetFileMD5(f_name);
			return 0;
		}
	}
	return 2;
}

//************************************
// Method:    checkResponseCode
// FullName:  checkResponseCode
// Access:    public
// Returns:   bool
// Qualifier: check upload post response code,change task state
// Parameter: int responseCode
// Parameter: int task_id
// Parameter: CTaskManager * taskManager
//************************************
bool CheckFmUploadVerifyResponseCode( int responseCode, CTask * task )
{//tthread::lock_guard<tthread::mutex> lock(post_request_mutex);
	bool continue_thread = false;
	switch(responseCode)
	{
	case 0:
		continue_thread = true;
		break;
	case 1:
	case 2:

	case 3:

	case 4:
		task->SetStartState(false);
		task->ChangeState(-2);
		break;
	case 5:
		task->ChangePercentage(100);
		task->ChangeState(3);
		task->SetTrransfSpeed(0);
		task->SetStartState(false);

		SevenCBoxClient::GetTaskManager()->Save(task);
		break;
	}
	return continue_thread;
}
//************************************
// Method:    PreCheck
// FullName:  PreCheck
// Access:    public
// Returns:   bool
// Qualifier: check the task upload task execution condition,do prepare
// Parameter: int task_id
// Parameter: CTaskManager * manager
// Parameter: Value & jsonRequestHeader
//************************************
bool PreCheck(CTask * task,Value &jsonRequestHeader)
{//tthread::lock_guard<tthread::mutex> lock(post_request_mutex);
	if (task == NULL)
	{
		return false;
	}

	if(SevenCBoxClient::GetFromUserSession(jsonRequestHeader)<=0)
	{
		//taskManager->GetTask(task_id)->Stop();
		task->ChangeState(0);
		task->SetStartState(false);
		/*	taskManager->SetTaskThreadState(task_id,false);
		taskManager->ChangeTaskState(task_id,-1);*/
		//鏇存柊TaskView

		return false;
	}

	//task->ChangeState(1);


	//fcloseall();
	int responseCode = -1;
	const char * local_file_path = task->GetFileLocalPath();
	string task_file_name = task->GetFileName();
#ifdef _WIN32
    const string f_name_utf8 = JsonStringUtil::GB2312ToUTF_8(task_file_name.c_str(),task_file_name.length());
#else
    const string f_name_utf8 = task_file_name;
#endif
	const string f_pid = task->GetFolderId();
	const string f_mime = "";

	//SevenCBoxClient::GetLOG()<<"local_file_path:"<<local_file_path<<endl;
	const long f_size = CFileSplitter::get_file_size(local_file_path);
	if(f_size<=0){
		//SevenCBoxClient::GetLOG()<<"open "<<local_file_path<<" failed,ErrorNO is:"<<errno<<endl;
		//taskManager->SetTaskThreadState(task_id,false);
		return false;
	}
	Value jsonResponse;

	SevenCBoxClient::FmUploadVerify(f_pid,f_name_utf8,f_size,jsonResponse);
	responseCode = SevenCBoxClient::GetResponseCode(jsonResponse);
	if(!CheckFmUploadVerifyResponseCode(responseCode,task))
	{
		return false;
	}


	//if(CheckUploadState(GetFileName(f_name.c_str()),file_md5,jsonRequestHeader)!=0)return;
	jsonRequestHeader["f_pid"] = f_pid;
	jsonRequestHeader["f_name"] = Base64Help::enBase64(f_name_utf8);
	jsonRequestHeader["f_mime"] = f_mime;
	return true;

}
//************************************
// Method:    CheckTaskState
// FullName:  CheckTaskState
// Access:    public
// Returns:   bool
// Qualifier: check task state,do choice
// Parameter: CTaskManager * taskManager
// Parameter: int task_id
//************************************
bool CheckTaskState(CTask * task)
{//tthread::lock_guard<tthread::mutex> lock(post_request_mutex);
	int current_state = task->GetTaskState();
	/*while(current_state==2){
		tthread::this_thread::sleep_for(tthread::chrono::microseconds(1000));
		current_state = task->GetTaskState();
	}
	if(current_state==-2)
	{
		SevenCBoxClient::GetTaskManager()->DeleteFromTaskList(task->GetTaskId());
		return false;
	}
	if(current_state==-1)
	{
		return false;
	}*/
	return current_state==1;
}

void StartPostResquestThread(void * cTaskPtr)
{
@autoreleasepool {
	try{
		//tthread::lock_guard<tthread::mutex> lock(post_request_mutex);
		//CMultiPostRequestExecuter * pExecuter = (CMultiPostRequestExecuter *)executer;
		CTask * task = (CTask *)cTaskPtr;
		if(!task||task->GetTaskState()!=1)return;
		Value jsonRequestHeader;
		long start_time = clock();
		long file_size = task->GetTaskFileSize();
		CTaskManager * taskManager = SevenCBoxClient::GetTaskManager();
		//int task_id = uploader->task_id;
		//CTask * task = taskManager->GetTask(task_id);
		//task->ChangeState(1);
		//task->SetStartState(true);
		/*taskManager->ChangeTaskState(task_id,1);
		taskManager->SetTaskThreadState(task_id,true);*/
		if(!PreCheck(task,jsonRequestHeader))
		{
			task->SetStartState(false);
			task->DeleteThread();
			return;
		}
		string s_name = task->GetPreSName();
		string file_md5 =  task->GetFileMD5();//GetFileMD5(local_file_path);
		const char * local_file_path = task->GetFileLocalPath();
		string task_file_name = task->GetFileName();


		if(!CheckTaskState(task)){
			task->DeleteThread();
			return;
		}
		//long skipOnStart=task->GetSkipOnStart();
		//bool checkstate  = (CheckUploadState(s_name,file_md5,jsonRequestHeader)==0);
		//int index =0;

		if(CheckUploadState(s_name,file_md5,jsonRequestHeader)==0)
		{
			if(!task||task->GetTaskState()!=1)return;
			vector<string> uploadFiles;
			int skiped = jsonRequestHeader["skip"].asInt();
			const string loacal_file_name = CFileSplitter::get_splite_file(local_file_path,skiped,1024*100);//spliter.get_file_name(local_file_path);
			if(loacal_file_name.empty())
			{
				task->ChangeState(0);
				task->SetStartState(false);
				task->DeleteThread();
				return;
			}
			uploadFiles.push_back(loacal_file_name);
			task->SetSkipOnStart(skiped);
			task->SetPreSName(jsonRequestHeader["s_name"].asString());

			vector<string> localFiles;
			localFiles.push_back(loacal_file_name);
			Value jsonResponse;
			Value jsonRequest;
			//SevenCBoxClient::GetLOG()<<"[CMultiPostRequestExecuter]准备上传一个文件碎片,文件名："<<loacal_file_name<<endl;
			//SevenCBoxClient::GetLOG()<<"[CMultiPostRequestExecuter]文件碎片上传，请求参数jsonRequestHeader="<<jsonRequestHeader<<endl;
			SevenCBoxClient::client.MultiFormPost(SevenCBoxClient::GetRequestURL(ClientConfig::FM_UPLOAD_URI),jsonRequest,jsonRequestHeader,localFiles,jsonResponse,task);
			//SevenCBoxClient::GetLOG()<<"[CMultiPostRequestExecuter]文件碎片上传完成，返回值jsonResponse="<<jsonResponse<<endl;
			if(!task||task->GetTaskState()!=1)return;
			ifstream in(loacal_file_name.c_str());
			if(in){
				in.close();
				remove(loacal_file_name.c_str());
			}
			long end_time = clock();
			long dur = (end_time-start_time)/1000;
			if(dur>0){
				int speed = 100/(dur);
				task->SetTrransfSpeed(speed);
			}

			float percent = skiped*100.0/file_size;
			task->ChangePercentage(percent);

			taskManager->Save(task);
			if(jsonResponse.isMember("code")&&jsonResponse["code"].asInt()==0&&jsonResponse.isMember("fid"))
			{
				if(!task||task->GetTaskState()!=1)return;
				task->ChangeState(3);
				task->SetStartState(false);
				task->SetTrransfSpeed(0);
				task->ChangePercentage(100);
				string fileId = jsonResponse["fid"].asString();
				task->SetFileId(fileId);
				taskManager->Save(task);
				task->DeleteThread();
				return;
			}
			else
			{
				if(!task||task->GetTaskState()!=1)
				{
					if(task)task->DeleteThread();
						return;
				}
				CMultiPostRequestExecuter next(task);
				next.ExecuteTask();
				return;
			}


		}
	}catch(...)
	{
		return;
	}
}
}

const char * GetFileName( const char * m_strFilePath )
{
	int len;
	const char *current=NULL;
	len=strlen(m_strFilePath);
	for (;len>0;len--) 
#ifdef _WIN32
		if(m_strFilePath[len]=='\\')
#else
		if(m_strFilePath[len]=='/')
#endif
		{
			current=&m_strFilePath[len+1];
			break;
		}
		return current;
}
const long GetFileSize(const char * f_name)
{
	FILE * file;
	file = fopen(f_name,"rb");

	if(file==NULL){
		return -1;
	}

	fseek(file,0,SEEK_END);
	const long size =  ftell(file);
	fclose(file);
	return size;
}
string GetFileMD5( const string & f_name )
{
	MD5 md5;
	md5.reset();
	ifstream in(f_name.c_str(),ios::binary);
	if(in){
	md5.update(in);
	return md5.toString();
	}
	return "";
}

bool CheckFmUploadResponceCode( CTask * task, int responceCode )
{
	bool conitue_for_upload = false;
	switch(responceCode){
	case 0:
		conitue_for_upload= true;
		break;
	case 1:
	case 2:
	case 3:
	case 4:
		task->ChangeState(0);
		break;
	default:
		task->ChangeState(0);
		break;
	}
	return conitue_for_upload;
}
