#ifndef _INC_CASYNREQUEST_H
#define _INC_CASYNREQUEST_H
#include <json/json.h>
#include <clientlib/ClientExport.h>
#include <clientlib/tinythread.h>
#include <string>
#include <clientlib/HttpClientCommon.h>
using namespace Json;
using namespace tthread;
using namespace std;
//异步请求类
class EXTERNCLASS CAsynRequest
{
public:

	//************************************
	// Method:    CAsynRequest
	// FullName:  CAsynRequest::CAsynRequest
	// Access:    public 
	// Returns:   
	// Qualifier:
	// Parameter: Value & header	头信息
	// Parameter: Value & params	字段信息
	// Parameter: SCBoxCallBack callback	回调函数
	// Parameter: void * any_ptr	任意指针，会缘分不动的传给回调函数
	//************************************
	
	CAsynRequest(const string * uri,const Value * params,const Value * header ,SCBoxCallBack callback=NULL,void * any_ptr=NULL);
	CAsynRequest(CAsynRequest * request);
	~CAsynRequest(void);
	
	const Value & GetParams();
	const Value & GetHeader();
	const string & GetUri();
	bool IsOver();

	SCBoxCallBack GetCallBackFunc();
	void * GetAnyPointer();
	My_Progress_Func GetProgressFunc();
	void ExecutePost();


private:
	
	friend class SevenCBoxClient;
	thread * pThread;
	bool b_IsRunning;
	const string * requestUri;
	const Value * requestParams;
	const Value * requestHeader;
	SCBoxCallBack callbackFunc;
	void * any_pointer;
};

#endif