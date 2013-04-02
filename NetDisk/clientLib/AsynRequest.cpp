#include <clientlib/AsynRequest.h>
#include <json/json.h>
#include <iostream>
#include <clientlib/SevenCBoxClient.h>
#include <clientlib/SevenCBoxClientConfig.h>
using namespace Json;
using namespace ClientConfig;
void StartPostThread(void * ptr);
void StartGetThread(void * ptr);
void StartPutThread(void * ptr);
void StartDeleteThread(void * ptr);
void StartMultiPostThread(void * ptr);

tthread::mutex casyncrequest_mutex_1;

CAsynRequest::CAsynRequest( const string * uri,const Value * params,const Value * header ,SCBoxCallBack callback/*=NULL*/,void * any_ptr/*=NULL*/ )
{
    requestUri = uri;
    requestParams = params;
    callbackFunc = callback;
    any_pointer = any_ptr;
	requestHeader = header;
	pThread= NULL;
	b_IsRunning = false;
}
CAsynRequest::CAsynRequest(CAsynRequest * request)
{
	requestUri = request->requestUri;
	requestParams = request->requestParams;
	callbackFunc = request->callbackFunc;
	any_pointer = request->any_pointer;
	requestHeader = request->requestHeader;
	pThread= request->pThread;
	b_IsRunning = request->b_IsRunning;
}
CAsynRequest::~CAsynRequest(void)
{
	if(pThread){
	pThread->join();
	 delete pThread;
	}
	//if(requestUri)delete requestUri;
	//if(requestParams)delete requestParams;
	//if(requestHeader)delete requestHeader;
}

bool CAsynRequest::IsOver()
{
	return b_IsRunning && !pThread;
}
const string & CAsynRequest::GetUri()
{
    return *requestUri;
}
const Value & CAsynRequest::GetParams()
{
    return *requestParams;
}

const Value & CAsynRequest::GetHeader()
{
	return *requestHeader;
}

SCBoxCallBack CAsynRequest::GetCallBackFunc()
{
    return callbackFunc;
}

void * CAsynRequest::GetAnyPointer()
{
    return any_pointer;
}

void CAsynRequest::ExecutePost()
{
   
   pThread = new thread(StartPostThread,this);
   b_IsRunning = true;
	//CAsynRequestList->push_back(this);

}



//===================Functions Region===========================


void StartPostThread(void * ptr)
{
	
	@autoreleasepool{
		Json::StyledWriter writer;
		Value jsonResponse;
		CAsynRequest * request = (CAsynRequest *)ptr;

		//SevenCBoxClient::GetLOG()<<"===CAsynRequest::PostRequest To ["<<request->GetUri()<<"],request header is:\r\n"<<writer.write(request->GetHeader())<<endl;
		//SevenCBoxClient::GetLOG()<<"===CAsynRequest::request parameter is:"<<writer.write(request->GetParams())<<endl;
		SevenCBoxClient::client.Post(SevenCBoxClient::GetRequestURL(request->GetUri()),request->GetParams(),request->GetHeader(),jsonResponse);
		//SevenCBoxClient::GetLOG()<<"===CAsynRequest::PostRequest To ["<<request->GetUri()<<"],response is:\r\n"<<writer.write(jsonResponse)<<endl;
		if(request->GetCallBackFunc() != NULL)
		{
			//SevenCBoxClient::GetLOG()<<"===CAsynRequest::begin to invoke callback function to "<<request->GetUri()<<" request."<<endl;
			try
			{	
				//casyncrequest_mutex_1.lock();
				request->GetCallBackFunc()(jsonResponse,request->GetAnyPointer());
				//casyncrequest_mutex_1.unlock();
			}
			catch(...)
			{
				//SevenCBoxClient::GetLOG()<<"===CAsynRequest::an exception was thrown,on calling callback function to "<<request->GetUri()<<" ."<<endl;
			}
			//SevenCBoxClient::GetLOG()<<"===CAsynRequest::invoke callback function to "<<request->GetUri()<<" finished."<<endl;
		}
		
	}
	
	//this_thread::sleep_for(tthread::chrono::milliseconds(0));
}
