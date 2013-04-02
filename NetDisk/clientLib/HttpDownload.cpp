#include "ClientLib/HttpDownload.h"
#include <stdio.h>
#include <iostream.h>
#include <curl/curl.h>
#include <string>
#include <iostream>
const static int DS_FAILED = 0;
const static int DS_FINISHED = 0;
using namespace std;

CHttpDownload::CHttpDownload(const string & remoteUrl,const string & f_id,const string & localFile,My_Progress_Func getProgressValue)
{
	this->localFile = localFile.c_str();
	this->url = remoteUrl.c_str(); 
	this->param = ("f_id="+f_id).c_str();
	this->progressProcesser = getProgressValue;
}
CHttpDownload::~CHttpDownload()
{

}

//void CHttpDownload::GetProgressValue(const char* localSize, double dt, double dn, double ult, double uln){
//	double showTotal, showNow;
//	showTotal = downloadFileLenth;
//	int localNow = atoi (localSize.c_str());
//	showNow = localNow + dn;
//	showProgressBar(showTotal, showNow);
//}
size_t my_write_func(void *ptr, size_t size, size_t nmemb, FILE *stream)
{
	return fwrite(ptr, size, nmemb, stream);
}

size_t my_read_func(void *ptr, size_t size, size_t nmemb, FILE *stream)
{
	return fread(ptr, size, nmemb, stream);
}

int CHttpDownload::Download(long timeout){
	CURL *curl;
	CURLcode res;
	FILE *outfile;
	
	char *progress_data = "* ";

	curl = curl_easy_init();
	if(curl)
	{
		outfile = fopen(this->localFile, "wb");

		curl_easy_setopt(curl, CURLOPT_URL, url);
		curl_easy_setopt(curl, CURLOPT_WRITEDATA, outfile);
		curl_easy_setopt(curl, CURLOPT_WRITEFUNCTION, my_write_func);
		curl_easy_setopt(curl, CURLOPT_READFUNCTION, my_read_func);
		curl_easy_setopt(curl, CURLOPT_NOPROGRESS, FALSE);
		curl_easy_setopt(curl, CURLOPT_PROGRESSFUNCTION, this->progressProcesser);
		curl_easy_setopt(curl, CURLOPT_PROGRESSDATA, progress_data);
		curl_easy_setopt(curl, CURLOPT_POST, 1);
		curl_easy_setopt(curl, CURLOPT_FOLLOWLOCATION, 1);
		curl_easy_setopt(curl, CURLOPT_POSTFIELDS, param);
		res = curl_easy_perform(curl);

		fclose(outfile);
		/* always cleanup */
		curl_easy_cleanup(curl);
	}
	return 0;

}
