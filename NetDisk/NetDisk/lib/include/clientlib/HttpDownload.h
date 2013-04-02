#ifndef CHTTPDOWNLOAD_H
#define CHTTPDOWNLOAD_H
#include "clientlib/ClientExport.h"
#include <string>
using namespace std;
typedef int (*My_Progress_Func)(char *progress_data,
	double t, /* dltotal */
	double d, /* dlnow */
	double ultotal,
	double ulnow);

class EXTERNCLASS CHttpDownload
{

public:
	CHttpDownload(const string & remoteUrl,const string & f_id,const string & localFile,My_Progress_Func getProgressValue=NULL);
	~CHttpDownload();
	int Download(long timeout=30);
	void SetProgressProcess(My_Progress_Func getProgressValue);

private:
	//全局变量	
	const char * localFile;
	const char * url;
	const char * param;
	My_Progress_Func progressProcesser;
};

#endif
