#ifndef CJsonHttpClient_H
#define CJsonHttpClient_H
#include "clientlib/ClientExport.h"
#include "json/json.h"
#include "clientlib/HttpClientCommon.h"
#include <clientlib/Task.h>
using namespace Json;
using namespace std;

class EXTERNCLASS CJsonHttpClient
{
public:
	CJsonHttpClient(void);
	~CJsonHttpClient(void);
public:
	int Post(const string & strUrl, const string & strPost,vector<string> & headerFields, string & strResponse);
	int Get(const string & strUrl, string & strResponse);
	int Posts(const string & strUrl, const string & strPost, string & strResponse, const char * pCaPath = NULL);
	int Gets(const string & strUrl, string & strResponse, const char * pCaPath = NULL);
public:
	void SetDebug(bool bDebug);
public:
	int Post(const string & strUrl, const Value & jsonValue,const Value & headerFields, Value & jsonResponse);
	void Post(const string & strUrl, const Json::Value & postStrJsonValue,const Value & headerFields, SCBoxCallBack callback,void * ui_ptr);
	void GetRemoteFile(const string & strUrl,const Value & jsonRequest,const Value & headerFields,CTask * task);
	int MultiFormPost(const string & strUrl,const Value & formFilds,const Value & headerFields,vector<string> & files,Value & jsonResponse,CTask * task = NULL);
	int PutFiles(const string & strUrl,const Value & formFilds,const Value & headerFields,vector<string> & files,Value & jsonResponse,My_Progress_Func getProgressValue);
	int Get(const string & strUrl,  Value & jsonResponse);
	int Posts(const string & strUrl, const Value & jsonValue, Value & jsonResponse, const char * pCaPath = NULL);
	int Gets(const string & strUrl, Value & jsonResponse, const char * pCaPath = NULL);
	void GetRemoteThumbFile(const string & strUrl,const Value & jsonRequest,const Value & headerFields,CTask * task);
private:
	bool m_bDebug;

};

#endif
