#ifndef _INC_CASYNREQUESTMANAGER_H
#define _INC_CASYNREQUESTMANAGER_H
#include <clientlib/AsynRequest.h>
#include <clientlib/ClientExport.h>
#include <json/json.h>
#include <clientlib/HttpClientCommon.h>
EXTERNCLASS typedef struct{
	const string * requestUri;
	const Value * requestParams;
	const Value * requestHeader;
	SCBoxCallBack callbackFunc;
	void * any_pointer;
} RequestStruct;
class EXTERNCLASS CAsynRequestManager
{
public:
	CAsynRequestManager(void);
	~CAsynRequestManager(void);
	void AddToList( const string uri,const Value params,const Value header ,SCBoxCallBack callback/*=NULL*/,void * any_ptr/*=NULL*/ );
private:	
	void StartManager();
	void StopManager();
	
	friend class SevenCBoxClient;

};

#endif