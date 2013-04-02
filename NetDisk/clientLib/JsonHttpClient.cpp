#include "clientlib/JsonHttpClient.h"

#include <iomanip>
#include "curl/curl.h"
#include <string>
#include<iostream>
#include <vector>
#include <numeric>
#include <sstream>
#include <algorithm>
#include <clientlib/stringutils.h>
#include <clientlib/tinythread.h>
#include <clientlib/SevenCBoxClientConfig.h>
#include <clientlib/SevenCBoxClient.h>
#include <clientlib/Task.h>
#include "filesplit/split/FileSplitter.h"

#include <cstdio>
using namespace std;

string write( const Value &root );
void Json2ParameterString( const Value &value ,string & document_,const string * itemName);
void parseReponceStr(CURLcode res,const string & jsonStr,Value & josnResponse);
string JsonValueToString( const char *value );
bool JsonValueContainsControlCharacter( const char* str );
bool isJsonValueControlCharacter(char ch);
//tthread::mutex httpclient_mutex;


CJsonHttpClient::CJsonHttpClient(void)
{
#ifdef _WIN32
	curl_global_init(CURL_GLOBAL_WIN32);
#else
	curl_global_init(CURL_GLOBAL_ALL);
#endif
	
    
	printf("CJsonHttpClient::CURL_GLOBAL_ALL inited!");
}


CJsonHttpClient::~CJsonHttpClient(void)
{
	curl_global_cleanup();
	printf("CJsonHttpClient exit!");
}
struct curl_slist *  GetHeaderList(const Value & headerFields)
{ struct curl_slist * headerlist = NULL;
    if(!headerFields.empty())
    {
        Json::Value::Members members( headerFields.getMemberNames() );
        //遍历所有的name，查找值
        for ( Json::Value::Members::iterator it = members.begin();
             it != members.end();
             ++it ){
			string &name = *it;
			string field("");
			field.append(name).append(":");
			//--------------获取Headerfield的值---start
			Value nameJsonValue = headerFields[name];
			const char * nameValue;
			if(nameJsonValue.isInt())
			{
				char strBuffer[25];
				//char * strValue;
				int intValue = nameJsonValue.asInt();
				sprintf(strBuffer,"%d",intValue);
				nameValue = strBuffer;
			}
			else if(nameJsonValue.isBool())
			{
				bool boolValue = nameJsonValue.asBool();
				if(boolValue)nameValue="true";
				else
					nameValue="false";
			}
			else if(nameJsonValue.isString())
			{
				const char * temp = nameJsonValue.asCString();
#ifdef _WIN32
				
                if(temp&&JsonStringUtil::IsChinese(temp)&&JsonStringUtil::IsGB2312(temp)){
                    
                    nameValue = JsonStringUtil::GB2312ToUTF_8(temp,string(temp).length()).c_str();
                }
				else
					nameValue = temp;
#else
				nameValue = temp;
#endif
                
			}
			else
			{
				nameValue = "null";
			}
			//--------------获取Headerfield的值---end
            
			//field.append(headerFields[name].asCString());
			field.append(nameValue);
			headerlist = curl_slist_append(headerlist,field.c_str());
        }
    }
    return headerlist;
}
static int OnDebug(CURL *, curl_infotype itype, char * pData, size_t size, void *)
{
	if(itype == CURLINFO_TEXT)
	{
		//printf("[TEXT]%s\n", pData);
	}
	else if(itype == CURLINFO_HEADER_IN)
	{
		printf("[HEADER_IN]%s\n", pData);
	}
	else if(itype == CURLINFO_HEADER_OUT)
	{
		printf("[HEADER_OUT]%s\n", pData);
	}
	else if(itype == CURLINFO_DATA_IN)
	{
		printf("[DATA_IN]%s\n", pData);
	}
	else if(itype == CURLINFO_DATA_OUT)
	{
		printf("[DATA_OUT]%s\n", pData);
	}
	return 0;
}

static size_t OnWriteData(void* buffer, size_t size, size_t nmemb, void* lpVoid)
{
	string* str = dynamic_cast<string*>((string *)lpVoid);
	if( NULL == str || NULL == buffer )
	{
		return -1;
	}
    
	char* pData = (char*)buffer;
	str->append(pData, size * nmemb);
	return nmemb;
}

int CJsonHttpClient::Post(const string & strUrl, const string & strPost,vector<string> & headerFields, string & strResponse)
{
	//tthread::lock_guard<mutex> lock(httpclient_mutex);
    printf("%s\n",strPost.c_str());
	int res;
	struct curl_slist *headerlist=NULL;
	if(!headerFields.empty())
	{
        
		//遍历所有的name，查找值
		for(vector<string>::iterator it = headerFields.begin();it != headerFields.end(); ++it){
			string &field = *it;
            
            
			headerlist = curl_slist_append(headerlist,field.c_str());
		}
        
	}
	headerlist = curl_slist_append(headerlist,"ContentEncoding:UTF-8");
	CURL* curl = curl_easy_init();
	//printf("--------------------------------------");
	//printf("CURLOPT_URL");
	//printf(strUrl.c_str());
	//printf("-------------------------------------\r\n");
	if(curl){
		if(m_bDebug)
		{
			curl_easy_setopt(curl, CURLOPT_VERBOSE, 1);
			curl_easy_setopt(curl, CURLOPT_DEBUGFUNCTION, OnDebug);
		}
		curl_easy_setopt(curl, CURLOPT_URL, strUrl.c_str());
		curl_easy_setopt(curl, CURLOPT_POST, 1);
		curl_easy_setopt(curl, CURLOPT_HTTPHEADER, headerlist);
		curl_easy_setopt(curl, CURLOPT_FOLLOWLOCATION, 1);
		curl_easy_setopt(curl, CURLOPT_POSTFIELDS, strPost.c_str());
		curl_easy_setopt(curl, CURLOPT_READFUNCTION, NULL);
		curl_easy_setopt(curl, CURLOPT_WRITEFUNCTION, OnWriteData);
		curl_easy_setopt(curl, CURLOPT_WRITEDATA, (void *)&strResponse);
		curl_easy_setopt(curl, CURLOPT_NOSIGNAL, 1);
		curl_easy_setopt(curl, CURLOPT_CONNECTTIMEOUT, ClientConfig::CONNECT_TIMEOUT);
		res = curl_easy_perform(curl);
		
		curl_easy_cleanup(curl);
	}
	else
		return CURLE_FAILED_INIT;
    
	return res;
}
/************************************************************************/
/* 上传文件                                                              */
/************************************************************************/
struct HttpFile
{
	char *filename;
	FILE *stream;
};

int my_write_func(void *buffer, size_t size, size_t nmemb, FILE *stream)
{
	////tthread::lock_guard<tthread::mutex> lock(httpclient_mutex);
	//struct HttpFile *out=(struct HttpFile *)stream;
	//if (out && !out->stream)
	//{
	//out->stream=fopen(out->filename, "wb");
	//if (!out->stream)
	//{
	//return -1;
	//}
	//}
	//int ret = fwrite(buffer, size, nmemb, out->stream);
	//fclose(out->stream);
	return fwrite(buffer, size, nmemb, stream);
}

size_t my_read_func(void *ptr, size_t size, size_t nmemb, FILE *stream)
{
	//while(!stream)tthread::this_thread::sleep_for(tthread::chrono::seconds(1));
	return fread(ptr, size, nmemb, stream);
}

size_t getcontentlengthfunc(void *ptr, size_t size, size_t nmemb, void *stream) {
    
	return size * nmemb;
    
}

int UploadProgress(void *p,
                   double dltotal, double dlnow,
                   double ultotal, double ulnow)
{
	//tthread::lock_guard<tthread::mutex> lock(httpclient_mutex);
	fprintf(stderr, "UP: %g of %g  DOWN: %g of %g\r\n",
            ulnow, ultotal, dlnow, dltotal);
	return 0;
}

int CJsonHttpClient::MultiFormPost(const string & strUrl,const Value & formFilds,const Value & headerFields,vector<string> & files,Value & jsonResponse,CTask * task )
{
	//tthread::lock_guard<tthread::mutex> lock(httpclient_mutex);
	CURL *curl;
	//CURLM *multi_handle;
	CURLcode res;
	string jsonStr;
	//int still_running;
	struct curl_httppost *formpost=NULL;
	struct curl_httppost *lastptr=NULL;
	struct curl_slist *headerlist=NULL;
	static const char buf[] = "Expect:";
	//
	int max_speed = task->GetMaxSpeed();
	if(!files.empty())
	{
		int index =0;
		for(vector<string>::iterator it = files.begin();it != files.end(); ++it){
			string localFile = *it;
			/* Fill in the file upload field */
			curl_formadd(&formpost,
                         &lastptr,
                         CURLFORM_COPYNAME, "sendfile"+index,
                         CURLFORM_FILE, localFile.c_str(),
                         CURLFORM_END);
			index++;
		}
		curl_formadd(&formpost,
                     &lastptr,
                     CURLFORM_COPYNAME, "submit",
                     CURLFORM_COPYCONTENTS, "send",
                     CURLFORM_END);
	}
	if(formFilds!=NULL && !formFilds.empty())
	{
		//对象类型，其成员被保存在一个map里面，使用name作为索引进行查找
		Json::Value::Members members( formFilds.getMemberNames() );
		//遍历所有的name，查找值
		for ( Json::Value::Members::iterator it = members.begin();
             it != members.end();
             ++it )
		{
			const string &name = *it;
			curl_formadd(&formpost,&lastptr, CURLFORM_COPYNAME, name.c_str(),CURLFORM_COPYCONTENTS, formFilds[name].asCString(),CURLFORM_END);
		}
	}
    
    
	curl = curl_easy_init();
    
    
    
	//*****************************************************
	if(curl) {
		/* what URL that receives this POST */
		curl_easy_setopt(curl, CURLOPT_URL, strUrl.c_str());
        
		/* only disable 100-continue header if explicitly requested */
		//curl_easy_setopt(curl, CURLOPT_HTTPHEADER, headerlist);
		curl_easy_setopt(curl, CURLOPT_HTTPPOST, formpost);
		curl_easy_setopt(curl, CURLOPT_WRITEFUNCTION, OnWriteData);
		curl_easy_setopt(curl, CURLOPT_WRITEDATA, (void *)&jsonStr);
		curl_easy_setopt(curl, CURLOPT_FOLLOWLOCATION, 1);
		//curl_easy_setopt(curl, CURLOPT_READFUNCTION, NULL);
		curl_easy_setopt(curl, CURLOPT_NOSIGNAL, 1);
		curl_easy_setopt(curl, CURLOPT_COOKIEFILE,"");
		//if(max_speed>0)
		//curl_easy_setopt(curl, CURLOPT_MAX_SEND_SPEED_LARGE,&max_speed);
		//curl_easy_setopt(curl, CURLOPT_PROGRESSFUNCTION, &UploadProgress);
		//curl_easy_setopt(curl, CURLOPT_HEADERFUNCTION, getcontentlengthfunc);
		curl_easy_setopt(curl, CURLOPT_USERAGENT, "7cbox client/1.0");
		curl_easy_setopt(curl, CURLOPT_CONNECTTIMEOUT, ClientConfig::CONNECT_TIMEOUT);
		//curl_easy_setopt(curl, CURLOPT_WRITEFUNCTION, &my_write_func);
		curl_easy_setopt(curl, CURLOPT_READFUNCTION, &my_read_func);
		curl_easy_setopt(curl, CURLOPT_NOPROGRESS, 1L);
		if(task){
			char progress_data[20];
			//itoa(task->GetTaskId(),progress_data,10);
			sprintf(progress_data,"%d",task->GetTaskId());
			curl_easy_setopt(curl, CURLOPT_PROGRESSDATA, progress_data);
		}
        
		curl_easy_setopt(curl, CURLOPT_CONNECTTIMEOUT, ClientConfig::CONNECT_TIMEOUT);
		//curl_easy_setopt(curl, CURLOPT_TIMEOUT,ClientConfig::RESPONSE_TIMEOUT);
		/* Perform the request, res will get the return code */
        
		headerlist = GetHeaderList(headerFields);
		//if(headerlist)curl_easy_setopt(curl, CURLOPT_HTTPHEADER, headerlist);
		//SevenCBoxClient::GetLOG()<<"[headerlist]="<<headerlist<<endl;
		if(headerlist)curl_easy_setopt(curl, CURLOPT_HTTPHEADER, headerlist);
		res = curl_easy_perform(curl);
		/* Check for errors */
		if(res != CURLE_OK){
			//fprintf(stderr, "curl_easy_perform() failed: %s\n",
			//	curl_easy_strerror(res));
			jsonResponse["code"]=99900+res;
			jsonResponse["error"]=curl_easy_strerror(res);
		}
		else{
            
			parseReponceStr(res,jsonStr,jsonResponse);
		}
		//tthread::this_thread::yield();
		/* always cleanup */
		curl_easy_cleanup(curl);
	}
    
	if(formpost!=NULL)curl_formfree(formpost);
	/* free slist */
	if(headerlist!=NULL)curl_slist_free_all (headerlist);
    
    
	return res;
}

int CJsonHttpClient::Get(const string & strUrl, string & strResponse)
{
	int res;
	CURL* curl = curl_easy_init();
	if(NULL == curl)
	{
		return CURLE_FAILED_INIT;
	}
	if(m_bDebug)
	{
		curl_easy_setopt(curl, CURLOPT_VERBOSE, 1);
		curl_easy_setopt(curl, CURLOPT_DEBUGFUNCTION, OnDebug);
	}
	curl_easy_setopt(curl, CURLOPT_URL, strUrl.c_str());
	curl_easy_setopt(curl, CURLOPT_FOLLOWLOCATION, 1);
	curl_easy_setopt(curl, CURLOPT_READFUNCTION, NULL);
	curl_easy_setopt(curl, CURLOPT_WRITEFUNCTION, OnWriteData);
	curl_easy_setopt(curl, CURLOPT_WRITEDATA, (void *)&strResponse);
	/**
     * 当多个线程都使用超时处理的时候，同时主线程中有sleep或是wait等操作。
     * 如果不设置这个选项，libcurl将会发信号打断这个wait从而导致程序退出。
     */
	curl_easy_setopt(curl, CURLOPT_NOSIGNAL, 1);
	curl_easy_setopt(curl, CURLOPT_CONNECTTIMEOUT, ClientConfig::CONNECT_TIMEOUT);
	curl_easy_setopt(curl, CURLOPT_TIMEOUT,ClientConfig::RESPONSE_TIMEOUT);
	res = curl_easy_perform(curl);
	curl_easy_cleanup(curl);
	return res;
}

int DownloadProgress(char *progress_data,double t, /* dltotal */double d, /* dlnow */double ultotal,double ulnow)
{
    
	float percent = 0;
	if(t==0)
	{
		//SevenCBoxClient::GetTaskManager()->task_manager_mutex->unlock();
		//download_Taskmanager->ChangeTaskPercent(download_task_id,0);
		percent = 0;
		//printf("%s %g / %g 已下载：(0 %%)\n", progress_data, d, t);
	}
	else
	{
		if(d>0){
            
			//int task_id = atoi(progress_data);
			//CTask * task = SevenCBoxClient::GetTaskManager()->GetTask(task_id);
			//if(task){
			//string temp_file = task->GetFileLocalPath();
			//temp_file.append(".tmp");
			//long tmp_file_size = CFileSplitter::get_file_size(temp_file.c_str());
			//long f_size = task->GetTaskFileSize();
			//percent = (float)tmp_file_size*100.0/f_size;
			//task->ChangePercentage((int)percent);
            
			//long dur = task->GetDuration();
			//if(dur>0)
			//task->SetTrransfSpeed(d/(dur*1024));
			//}
			//task->ChangePercentage(percent);
		}
		//SevenCBoxClient::GetTaskManager()->task_manager_mutex->unlock();
		//download_Taskmanager->ChangeTaskPercent(download_task_id,d*100.0/t);
        
		//printf("%s %g / %g 已下载：(%g %%)\n", progress_data, d, t, d*100.0/t);
	}
    
	return 0;
}

void CJsonHttpClient::GetRemoteFile(const string & strUrl,const Value & jsonRequest,const Value & headerFields,CTask * task)
{
	//tthread::lock_guard<tthread::mutex> lock(httpclient_mutex);
	string postString = "";
	struct curl_slist *headerlist=NULL;
	string urlStr = strUrl;
	int max_speed = task->GetMaxSpeed()*1024;
	if(jsonRequest!=NULL)
		Json2ParameterString(jsonRequest,postString,NULL);
	CURL *curl;
    
	FILE *outfile = NULL;
	urlStr += "?"+postString;
	char progress_data[20];
	int task_id = task->GetTaskId();
    
	const char * temp_ext = ".tmp";
	string file_path;
	sprintf(progress_data,"%d",task_id);
	//itoa(task_id,progress_data,10);
	const char * localFilePath = task->GetFileLocalPath();
	file_path.append(localFilePath);
	file_path.append(temp_ext);
    
#ifdef _WIN32
	outfile = fopen(file_path.c_str(), "ab+");
#else
	outfile = fopen(file_path.c_str(), "a+");
#endif
	if(outfile)
	{
		fclose(outfile);
	}
	curl = curl_easy_init();
	//multi_handle = curl_multi_init();
	if(curl /*&& multi_handle*/)
	{
		curl_easy_setopt(curl, CURLOPT_URL, urlStr.c_str());
        
		curl_easy_setopt(curl, CURLOPT_WRITEFUNCTION, &my_write_func);
		//curl_easy_setopt(curl, CURLOPT_READFUNCTION, &my_read_func);
		curl_easy_setopt(curl, CURLOPT_NOPROGRESS, false);
		curl_easy_setopt(curl, CURLOPT_PROGRESSFUNCTION, DownloadProgress);
		curl_easy_setopt(curl, CURLOPT_PROGRESSDATA, progress_data);
		curl_easy_setopt(curl, CURLOPT_HTTPGET, 1);
		curl_easy_setopt(curl, CURLOPT_FOLLOWLOCATION, 1);
		curl_easy_setopt(curl, CURLOPT_USERAGENT, "7cbox client/1.0");
		curl_easy_setopt(curl, CURLOPT_CONNECTTIMEOUT, ClientConfig::CONNECT_TIMEOUT);
		//curl_easy_setopt(curl, CURLOPT_TIMEOUT,ClientConfig::RESPONSE_TIMEOUT);
		//if(max_speed>0)
		//curl_easy_setopt(curl, CURLOPT_MAX_RECV_SPEED_LARGE,&max_speed);
		headerlist = GetHeaderList(headerFields);
		if(headerlist)curl_easy_setopt(curl, CURLOPT_HTTPHEADER, headerlist);
		int res = CURLE_OK;
		int retry = 0;
		long f_size = task->GetTaskFileSize();
		long pre_time = time(0);
		while(retry<3 && task&& task->GetTaskPercentage()<100 && task->GetTaskState()==1){
			long current_size = CFileSplitter::get_file_size(file_path.c_str());
			ostringstream oss;
			int rang_size = f_size-current_size;
			if(rang_size>1024)
				rang_size = 1024;
            
			oss<<current_size<<"-"<<(current_size+rang_size);
			curl_easy_setopt(curl, CURLOPT_RANGE, oss.str().c_str());
			long begin_time = clock();
#ifdef _WIN32
			outfile = fopen(file_path.c_str(), "ab+");
#else
			outfile = fopen(file_path.c_str(), "a+");
#endif
			if(!outfile&&task){
				task->ChangeState(-2);
				task->SetStartState(false);
				if(SevenCBoxClient::GetTaskManager())
                    SevenCBoxClient::GetTaskManager()->Save(task);
				return;
			}
			else
			{
				curl_easy_setopt(curl, CURLOPT_WRITEDATA, outfile);
			}
            
			res=curl_easy_perform(curl);
            
            
			if(outfile){
				fflush (outfile);
				fclose(outfile);
			}
            
			//if(task->GetTaskType()==1)cond.wait(httpclient_mutex);
			if(res!=CURLE_OK)retry++;
			else{
				retry =0;
			}
			if(CFileSplitter::get_file_size(file_path.c_str())>=current_size){
				long end_time = clock();
				long now_time = time(0);
				long dur = end_time-begin_time;
				if(dur==0)dur=1;
				float speed = rang_size*1000/(1024*dur);
				current_size = CFileSplitter::get_file_size(file_path.c_str());
				float percent = (float)current_size*100.0/f_size;
				if(task)
                    task->ChangePercentage((int)percent);
				if(now_time-pre_time>1){
                    pre_time = now_time;
                    if(task)
                        task->SetTrransfSpeed(speed);
				}
			}
			//tthread::this_thread::yield();
		}
		curl_easy_cleanup(curl);
        
        
		if(outfile){
			fflush (outfile);
			fclose(outfile);
		}
		/* always cleanup */
		if(headerlist!=NULL)curl_slist_free_all (headerlist);
		
	}
}


void CJsonHttpClient::GetRemoteThumbFile(const string & strUrl,const Value & jsonRequest,const Value & headerFields,CTask * task)
{
	//SevenCBoxClient::GetLOG()<<"start GetRemoteThumbFile for "<<task->GetTaskId()<<"."<<endl;
	string postString = "";
	struct curl_slist *headerlist=NULL;
	string urlStr = strUrl;
	//int max_speed = task->GetMaxSpeed();
	if(jsonRequest!=NULL)
		Json2ParameterString(jsonRequest,postString,NULL);
	CURL *curl;
    
	FILE *outfile = NULL;
	//urlStr += "?"+postString;
	char progress_data[20];
	int task_id = task->GetTaskId();
    
	const char * temp_ext = ".tmp";
	string file_path;
	//itoa(task_id,progress_data,10);
	sprintf(progress_data,"%d",task_id);
	const char * localFilePath = task->GetFileLocalPath();
	file_path.append(localFilePath);
	file_path.append(temp_ext);
    
    
#ifdef _WIN32
	outfile = fopen(file_path.c_str(), "ab+");
#else
	outfile = fopen(file_path.c_str(), "a+");
#endif
	if(outfile)
	{
		fclose(outfile);
	}
	curl = curl_easy_init();
	//multi_handle = curl_multi_init();
	if( curl /*&& multi_handle*/)
	{
		curl_easy_setopt(curl, CURLOPT_URL, urlStr.c_str());
        
		curl_easy_setopt(curl, CURLOPT_WRITEFUNCTION, &my_write_func);
		//curl_easy_setopt(curl, CURLOPT_READFUNCTION, &my_read_func);
		curl_easy_setopt(curl, CURLOPT_NOPROGRESS, false);
		curl_easy_setopt(curl, CURLOPT_PROGRESSFUNCTION, DownloadProgress);
		curl_easy_setopt(curl, CURLOPT_PROGRESSDATA, progress_data);
		curl_easy_setopt(curl, CURLOPT_HTTPGET, 1);
		curl_easy_setopt(curl, CURLOPT_FOLLOWLOCATION, 1);
		curl_easy_setopt(curl, CURLOPT_USERAGENT, "7cbox client/1.0");
		curl_easy_setopt(curl, CURLOPT_CONNECTTIMEOUT, ClientConfig::CONNECT_TIMEOUT);
		headerlist = GetHeaderList(headerFields);
		if(headerlist)curl_easy_setopt(curl, CURLOPT_HTTPHEADER, headerlist);
#ifdef _WIN32
		outfile = fopen(file_path.c_str(), "ab+");
#else
		outfile = fopen(file_path.c_str(), "a+");
#endif
		if(!outfile){
			task->ChangeState(-2);
			task->SetStartState(false);
			SevenCBoxClient::GetTaskManager()->Save(task);
			return;
		}
		else
		{
			curl_easy_setopt(curl, CURLOPT_WRITEDATA, outfile);
		}
		
		int res = CURLE_OK;
		//SevenCBoxClient::GetLOG()<<"GetRemoteThumbFile:begin to curl_easy_perform  for "<<task->GetTaskId()<<"."<<endl;
		res=curl_easy_perform(curl);
		//SevenCBoxClient::GetLOG()<<"GetRemoteThumbFile:end of curl_easy_perform  for "<<task->GetTaskId()<<"."<<endl;
		int retry = SevenCBoxClient::Config.GetMaxRetry();
		if(retry==0)retry=3;
		while(res!=CURLE_OK && retry>0&& task->GetTaskState()==1)
		{
			//SevenCBoxClient::GetLOG()<<"GetRemoteThumbFile:retry("<<retry<<") curl_easy_perform  for "<<task->GetTaskId()<<"."<<endl;
			res=curl_easy_perform(curl);
			retry--;
			//SevenCBoxClient::GetLOG()<<"GetRemoteThumbFile:end of curl_easy_perform retry("<<retry<<") for "<<task->GetTaskId()<<"."<<endl;
		}
        
		curl_easy_cleanup(curl);
        
	}
	else
	{
		//SevenCBoxClient::GetLOG()<<"can not open local file for "<<task->GetTaskId()<<"."<<endl;
	}
	if(outfile){
		fflush (outfile);
		fclose(outfile);
	}
	/* always cleanup */
	if(headerlist!=NULL)curl_slist_free_all (headerlist);
}

int CJsonHttpClient::Posts(const string & strUrl, const string & strPost, string & strResponse, const char * pCaPath)
{
	int res;
	CURL* curl = curl_easy_init();
	if(NULL == curl)
	{
		return CURLE_FAILED_INIT;
	}
	if(m_bDebug)
	{
		curl_easy_setopt(curl, CURLOPT_VERBOSE, 1);
		curl_easy_setopt(curl, CURLOPT_DEBUGFUNCTION, OnDebug);
	}
	curl_easy_setopt(curl, CURLOPT_URL, strUrl.c_str());
	curl_easy_setopt(curl, CURLOPT_FOLLOWLOCATION, 1);
	curl_easy_setopt(curl, CURLOPT_POST, 1);
	curl_easy_setopt(curl, CURLOPT_POSTFIELDS, strPost.c_str());
	curl_easy_setopt(curl, CURLOPT_READFUNCTION, NULL);
	curl_easy_setopt(curl, CURLOPT_WRITEFUNCTION, OnWriteData);
	curl_easy_setopt(curl, CURLOPT_WRITEDATA, (void *)&strResponse);
	curl_easy_setopt(curl, CURLOPT_NOSIGNAL, 1);
	curl_easy_setopt(curl, CURLOPT_COOKIEFILE, "curlposttest.cookie");
	if(NULL == pCaPath)
	{
		curl_easy_setopt(curl, CURLOPT_SSL_VERIFYPEER, false);
		curl_easy_setopt(curl, CURLOPT_SSL_VERIFYHOST, false);
	}
	else
	{
		//缺省情况就是PEM，所以无需设置，另外支持DER
		//curl_easy_setopt(curl,CURLOPT_SSLCERTTYPE,"PEM");
		curl_easy_setopt(curl, CURLOPT_SSL_VERIFYPEER, true);
		curl_easy_setopt(curl, CURLOPT_CAINFO, pCaPath);
	}
	curl_easy_setopt(curl, CURLOPT_CONNECTTIMEOUT, ClientConfig::CONNECT_TIMEOUT);
	curl_easy_setopt(curl, CURLOPT_TIMEOUT,ClientConfig::RESPONSE_TIMEOUT);
	res = curl_easy_perform(curl);
	curl_easy_cleanup(curl);
	return res;
}

int CJsonHttpClient::Gets(const string & strUrl, string & strResponse, const char * pCaPath)
{
	int res;
	CURL* curl = curl_easy_init();
	if(NULL == curl)
	{
		return CURLE_FAILED_INIT;
	}
	if(m_bDebug)
	{
		curl_easy_setopt(curl, CURLOPT_VERBOSE, 1);
		curl_easy_setopt(curl, CURLOPT_DEBUGFUNCTION, OnDebug);
	}
	curl_easy_setopt(curl, CURLOPT_URL, strUrl.c_str());
	curl_easy_setopt(curl, CURLOPT_FOLLOWLOCATION, 1);
	curl_easy_setopt(curl, CURLOPT_READFUNCTION, NULL);
	curl_easy_setopt(curl, CURLOPT_WRITEFUNCTION, OnWriteData);
	curl_easy_setopt(curl, CURLOPT_WRITEDATA, (void *)&strResponse);
	curl_easy_setopt(curl, CURLOPT_NOSIGNAL, 1);
	if(NULL == pCaPath)
	{
		curl_easy_setopt(curl, CURLOPT_SSL_VERIFYPEER, false);
		curl_easy_setopt(curl, CURLOPT_SSL_VERIFYHOST, false);
	}
	else
	{
		curl_easy_setopt(curl, CURLOPT_SSL_VERIFYPEER, true);
		curl_easy_setopt(curl, CURLOPT_CAINFO, pCaPath);
	}
	curl_easy_setopt(curl, CURLOPT_CONNECTTIMEOUT, 3);
	curl_easy_setopt(curl, CURLOPT_TIMEOUT, 3);
	res = curl_easy_perform(curl);
	curl_easy_cleanup(curl);
    
	return res;
}

///////////////////////////////////////////////////////////////////////////////////////////////

void CJsonHttpClient::SetDebug(bool bDebug)
{
	m_bDebug = bDebug;
}

struct  Poster{
    CJsonHttpClient * client;
    string url ;
    Value request;
    Value header;
    SCBoxCallBack ui_callback;
    void * any_ptr;
};
void PostExecutor(void * ptr)
{
	Poster * poster = (Poster *)ptr;
	Value jsonResponse;
	poster->client->Post(poster->url,poster->request,poster->header,jsonResponse);
	if(poster->ui_callback){
		poster->ui_callback(jsonResponse,poster->any_ptr);
	}
}
void CJsonHttpClient::Post(const string & strUrl, const Json::Value & postStrJsonValue,const Value & headerFields, SCBoxCallBack callback,void * ui_ptr)
{
 	Poster poster;
	poster.url= strUrl;
	poster.request = postStrJsonValue;
	poster.header = headerFields;
	poster.ui_callback = callback;
	poster.any_ptr = ui_ptr;
	poster.client = this;
	tthread::thread t(PostExecutor,&poster);
	t.join();
}

int CJsonHttpClient::Post(const string & strUrl, const Json::Value & postStrJsonValue,const Value & headerFields, Json::Value & jsonResponse)
{
	string jsonStr;
	Json::StyledWriter writer;
	vector<string> headerlist;
	//SevenCBoxClient::GetLOG()<<"开始发送POST请求."<<endl;
	string postString = "";
	if(postStrJsonValue!=NULL){
		Json2ParameterString(postStrJsonValue,postString,NULL);
	}else
	{
		//SevenCBoxClient::GetLOG()<<"post json value is null!"<<endl;
	}
	if(headerFields!=NULL && !headerFields.empty())
	{
		Json::Value::Members members( headerFields.getMemberNames() );
		//遍历所有的name，查找值
		for ( Json::Value::Members::iterator it = members.begin();
             it != members.end();
             ++it ){
            string &name = *it;
            string field("");
            field.append(name).append(":");
#ifdef _WIN32
            const char * nameValue = headerFields[name].asCString();
            
            if(nameValue && nameValue!=""&&JsonStringUtil::IsChinese(nameValue) && JsonStringUtil::IsGB2312(nameValue))
                field.append(JsonStringUtil::GB2312ToUTF_8(nameValue,string(nameValue).length()));
            else
                field.append(headerFields[name].asCString());
#else
            field.append(headerFields[name].asCString());
#endif
            
            headerlist.push_back(field.c_str());
		}
        
	}
	//SevenCBoxClient::GetLOG()<<"CJsonHttpClient::Post:post string is:"<<postString<<endl;
	int res = Post(strUrl,postString,headerlist,jsonStr);
	if(res != CURLE_OK){
		//fprintf(stderr, "curl_easy_perform() failed: %s\n",
		//	curl_easy_strerror((CURLcode)res));
		jsonResponse["code"]=99900+res;
		jsonResponse["error"]=curl_easy_strerror((CURLcode)res);
	}
	else{
        
		parseReponceStr((CURLcode)res,jsonStr,jsonResponse);
	}
    
	return res;
}

int CJsonHttpClient::Get(const string & strUrl,  Json::Value & jsonResponse)
{
	string jsonStr;
	int res = Get(strUrl,jsonStr);
	parseReponceStr((CURLcode)res,jsonStr,jsonResponse);
	return res;
    
}

int CJsonHttpClient::Posts(const string & strUrl, const Json::Value & jsonValue, Json::Value & jsonResponse, const char * pCaPath)
{
	string jsonStr;
	string postsStr="";
	Json2ParameterString(jsonValue,postsStr,NULL);
	int res = Posts(strUrl,postsStr,jsonStr,pCaPath);
	parseReponceStr((CURLcode)res,jsonStr,jsonResponse);
	return res;
}

int CJsonHttpClient::Gets(const string & strUrl, Json::Value & jsonResponse, const char * pCaPath)
{
	string jsonStr;
	int res = Gets(strUrl,jsonStr,pCaPath);
	parseReponceStr((CURLcode)res,jsonStr,jsonResponse);
	return res;
}

//===================函数区域==========================
//把json对象转换成parameter字符串
bool isJsonValueControlCharacter(char ch)
{
	return ch > 0 && ch <= 0x1F;
}

bool JsonValueContainsControlCharacter( const char* str )
{
	while ( *str )
	{
		if ( isJsonValueControlCharacter( *(str++) ) )
			return true;
	}
	return false;
}
string JsonValueToString( const char *value )
{
#ifdef _WIN32
	if(JsonStringUtil::IsChinese(value)&& JsonStringUtil::IsGB2312(value)){
		int size = string(value).length();
		/*int size0 = sizeof(value[0]);*/
		string utf8Value = JsonStringUtil::GB2312ToUTF_8(value,size);
		/*
         int size1 = utf8Value.length();
         int size01 = sizeof(utf8Value.c_str()[0]);
         string gb2312Value = JsonStringUtil::UTF_8ToGB2312(utf8Value.c_str(),size1);
         */
		return utf8Value;
	}
	else
		return string("")+ value;
#else
	return string("")+value;
#endif
}

void parseReponceStr(CURLcode res,const string & jsonStr,Value & josnResponse)
{
	if(res == CURLE_OK){
        
		//SevenCBoxClient::GetLOG()<<"POST提交完成! return code is:"<<res<<endl;
		Json::Reader jsonReader;
        
		if(jsonStr.empty()){
			josnResponse["code"]=99900;//返回值为空
			josnResponse["error"]="response is NULL!";
		}
		else
		{
			//SevenCBoxClient::GetLOG()<<"开始解析响应对象！jsonStr is:"<<jsonStr<<endl;
			jsonReader.parse(jsonStr.c_str(),josnResponse);
			if(!jsonReader.parse(jsonStr.c_str(),josnResponse)){
				josnResponse["code"]=99900;//解析返回值失败
				josnResponse["error"]="failed in parse json string:"+jsonStr+" error message is:"+jsonReader.getFormatedErrorMessages();
			}
		}
	}
	else
	{
		josnResponse["code"]=99900+res;//网络错误
		josnResponse["error"]=curl_easy_strerror(res);
	}
}

void Json2ParameterString( const Value &value ,string & document_,const string * itemName)
{
    
	switch ( value.type() )
	{
        case nullValue:
            document_ += "null";
            break;
        case intValue:
            document_ += Json::valueToString( value.asInt() );
            break;
        case uintValue:
            document_ += Json::valueToString( value.asUInt() );
            break;
        case realValue:
            document_ += Json::valueToString( value.asDouble() );
            break;
        case stringValue:
            document_ += JsonValueToString(value.asCString());
            break;
        case booleanValue:
            document_ += Json::valueToString( value.asBool() );
            break;
        case arrayValue:
		{
			int size = value.size();
			for ( int index =0; index < size; ++index )
			{
				if(index>0){
					document_ += "&";
					document_ += *itemName;
					document_ += "=";
				}
                
				Json2ParameterString(value[index],document_,itemName);
			}
		}
            
            break;
        case objectValue:
		{
			Value::Members members( value.getMemberNames() );
            
			for ( Value::Members::iterator it = members.begin();
                 it != members.end();
                 ++it )
			{
				const string &name = *it;
                
				if ( it != members.begin() )
					document_ += "&";
				document_ += name;
				document_ += "=";
				Json2ParameterString( value[name],document_,&name);
			}
			document_ += "";
		}
            break;
	}
}
string write( const Value &root )
{
	string document_ = "?";
	Json2ParameterString( root,document_ ,NULL);
	return document_;
}