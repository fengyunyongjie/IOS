#include "clientlib/SevenCBoxConfig.h"
#include "clientlib/SevenCBoxClient.h"
#include <LIMITS.H>
void SevenCBoxConfig::SetTempFolder( const string  folderPath )
{
	SevenCBox_TempForlder = folderPath;
}

const string  SevenCBoxConfig::GetTempFolder()
{
	return SevenCBox_TempForlder;
}

void SevenCBoxConfig::SetDbFilePath( const string  dbFilePath )
{
	SevenCBox_DbFilePath = dbFilePath;
	if(!SevenCBoxClient::GetTaskManager()->Inited)SevenCBoxClient::GetTaskManager()->_Init();
}

const string  SevenCBoxConfig::GetDbFilePath()
{
	return SevenCBox_DbFilePath;
}

//void SevenCBoxConfig::SetDefaultDownloadFolder( const string & downloadFolder )
//{
//	SevenCBox_DefaultDownloadFolder = downloadFolder;
//}
//
//const string & SevenCBoxConfig::GetDefaultDownloadFolder()
//{
//	return SevenCBox_DefaultDownloadFolder;
//}

void SevenCBoxConfig::SetServerUrl( const string  serverUrl )
{
	SevenCBox_ServerURL = serverUrl;
}

const string  SevenCBoxConfig::GetServerUrl()
{
	return SevenCBox_ServerURL;
}

SevenCBoxConfig::SevenCBoxConfig()
{
	SevenCBox_TempForlder="";
	SevenCBox_DbFilePath = "";
	//SevenCBoxConfig::SevenCBox_DefaultDownloadFolder = "";
	//SevenCBox_ServerURL = "http://7cbox.f3322.org:8080/nds/api";
	SevenCBox_ServerURL = "http://7cbox.cn:8080/nds/api";//正式库
	//SevenCBox_ServerURL = "http://192.168.1.5:8080/nds/api";	//local host
	//SevenCBoxConfig::SevenCBox_ServerURL = "http://7cbox.f3322.org:8899/nds/api";
	SevenCBox_LogFile = "";
	SevenCBox_MaxDownloadSpeed = INT_MAX;
	SevenCBox_MaxUploadSpeed = INT_MAX;
	SevenCBox_MaxDownloadThreads = 3;
	SevenCBox_MaxUploadThreads = 3;

//#ifdef _WIN32
//	_setmaxstdio(2048);
//#endif
}

SevenCBoxConfig::~SevenCBoxConfig()
{

}

void SevenCBoxConfig::SetLogFile( const string  logFilePath )
{
	SevenCBox_LogFile = logFilePath;
}

const string  SevenCBoxConfig::GetLogFile()
{
	return SevenCBox_LogFile;
}

void SevenCBoxConfig::SetMaxUploadSpeed( const int speed )
{
	SevenCBox_MaxUploadSpeed = speed;
}

void SevenCBoxConfig::SetMaxDownloadSpeed( const int speed )
{
	SevenCBox_MaxDownloadSpeed = speed;
}

void SevenCBoxConfig::SetMaxRetry( const int num )
{
	SevenCBox_NumOfRetry = num;
}

const int SevenCBoxConfig::GetMaxRetry()
{
	return SevenCBox_NumOfRetry;
}

const int SevenCBoxConfig::GetMaxUploadSpeed()
{
	return SevenCBox_MaxUploadSpeed;
}

const int SevenCBoxConfig::GetMaxDownloadSpeed()
{
	return SevenCBox_MaxDownloadSpeed;
}

void SevenCBoxConfig::SetMaxUploadThreads( int num )
{
	SevenCBox_MaxUploadThreads = num;
}

const int SevenCBoxConfig::GetMaxUploadThreads()
{
	return SevenCBox_MaxUploadThreads;
}

void SevenCBoxConfig::SetMaxDownloadThreads( int num )
{
	SevenCBox_MaxDownloadThreads = num;
}
