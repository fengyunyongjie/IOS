#ifndef _INC_SevenCBoxConfig_H
#define _INC_SevenCBoxConfig_H
#include <string>
#include <clientlib/ClientExport.h>
using namespace std;


class EXTERNCLASS SevenCBoxConfig
{
private:
	SevenCBoxConfig();
	~SevenCBoxConfig();
	friend class SevenCBoxClient;
	string SevenCBox_TempForlder;
	string SevenCBox_DbFilePath;
	string SevenCBox_DefaultDownloadFolder;
	string SevenCBox_ServerURL;
	string SevenCBox_LogFile;
	int SevenCBox_NumOfRetry;
	int SevenCBox_MaxUploadSpeed;
	int SevenCBox_MaxDownloadSpeed;
	int SevenCBox_MaxUploadThreads;
	int SevenCBox_MaxDownloadThreads;
public:

	void SetLogFile(const string  logFilePath);
	const string  GetLogFile();

	void SetTempFolder(const string  folderPath);
	const string  GetTempFolder();

	void SetDbFilePath(const string  dbFilePath);
	const string  GetDbFilePath();


	void SetServerUrl(const string  serverUrl);
	const string  GetServerUrl();

	void SetMaxRetry(const int num);
	const int GetMaxRetry();

	void SetMaxUploadSpeed(const int speed);
	const int GetMaxUploadSpeed();

	void SetMaxDownloadSpeed(const int speed);
	const int GetMaxDownloadSpeed();

	void SetMaxUploadThreads(int num);
	const int GetMaxUploadThreads();

	void SetMaxDownloadThreads(int num);
	const int GetMaxDownloadThreads();
};
#endif
