#include <clientlib/AsynRequestManager.h>
#include <clientlib/AsynRequest.h>
#include <clientlib/SevenCBoxClientConfig.h>
#include <list>
#include <clientlib/SevenCBoxClient.h>

void ExecutRequestTaskThread(void * ptr);
void StartRequestThreadCheck(void * ptr);
static bool started;
list<CAsynRequest *> * CAsynRequestList=new list<CAsynRequest *>;
//list<CAsynRequest *> * CAsynRunningRequestList=new list<CAsynRequest *>;
tthread::thread * CAsynRequestManager_Thread = NULL;
//tthread::thread * CAsynRequestManager_CheckThread = NULL;
tthread::mutex casyncrequest_mutex;
tthread::mutex manager_states_mutex;


CAsynRequestManager::CAsynRequestManager(void)
{
	CAsynRequestManager_Thread=NULL;
}


CAsynRequestManager::~CAsynRequestManager(void)
{
	StopManager();
	this_thread::sleep_for(tthread::chrono::seconds(1));
}


void CAsynRequestManager::StartManager()
{
	if(ClientConfig::IS_SYNC_REQUEST)return;
	if(started)return;
	started = true;
	CAsynRequestManager_Thread= new tthread::thread(ExecutRequestTaskThread,(void *) NULL);
	//CAsynRequestManager_CheckThread = new tthread::thread(StartRequestThreadCheck,(void *) NULL);
}



void CAsynRequestManager::AddToList( const string uri,const Value params,const Value header ,SCBoxCallBack callback/*=NULL*/,void * any_ptr/*=NULL*/  )
{
	//StartManager();
	if(ClientConfig::IS_SYNC_REQUEST)
	{
		CAsynRequest request(new string(uri),new Value(params),new Value(header),callback,any_ptr);
		request.ExecutePost();
		
	}
	else
	{
		//if(CAsynRequestList->size()>10)
		//return;
		/*RequestStruct * requestStruct = new RequestStruct;
		requestStruct->requestUri = new string(uri) ;
		requestStruct->requestParams = new Value(params);
		requestStruct->requestHeader = new Value(header);
		requestStruct->callbackFunc = callback;
		requestStruct->any_pointer = any_ptr;*/
		casyncrequest_mutex.lock();
		CAsynRequest * request = new CAsynRequest(new string(uri),new Value(params),new Value(header),callback,any_ptr);
		CAsynRequestList->push_back(request);
		casyncrequest_mutex.unlock();
	}
	
	
	
	//tthread::thread *t = new tthread::thread(ExecutAddRequestThread,(void *) requestStruct);
	//t->join();
	//delete t;
	
	
}

void CAsynRequestManager::StopManager()
{
	started=false;
}

void TryStopManager()
{
	tthread::lock_guard<mutex> lock(manager_states_mutex);
	if(CAsynRequestList->size()==0){
		started=false;
	//SevenCBoxClient::GetLOG()<<"CAsynRequestManager Stoped."<<endl;
	
	}
}

//void StartRequestThreadCheck(void * ptr)
//{
//	while(started)
//	{
//		if(CAsynRunningRequestList->size()>0){
//			CAsynRequest * request = CAsynRunningRequestList->front();
//			if(request->IsOver()){
//			CAsynRunningRequestList->pop_front();
//			if(request)
//			{
//				delete request;
//				request = NULL;
//			}
//			
//			}
//			this_thread::sleep_for(tthread::chrono::microseconds(0));
//		}
//		else
//		{
//			this_thread::sleep_for(tthread::chrono::microseconds(500));
//		}
//	}
//}

 void ExecutRequestTaskThread(void * ptr)
{

	//SevenCBoxClient::GetLOG()<<"CAsynRequestManager started."<<endl;
	while(started)
	{
		if(!started)
		{	
			break;
		}
		while(CAsynRequestList->size()>0){
            
			CAsynRequestList->front()->ExecutePost();
			this_thread::sleep_for(tthread::chrono::milliseconds(0));
			casyncrequest_mutex.lock();
			CAsynRequestList->pop_front();
			casyncrequest_mutex.unlock();
			
			if(!started)
			{	
				break;
			}
		}

		if(!started)
		{	
			break;
		}

		this_thread::sleep_for(tthread::chrono::milliseconds(10));
	}
}