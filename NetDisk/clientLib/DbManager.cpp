#include "DbManager.h"
#include <clientlib/SevenCBoxClient.h>
#include <string>
#include "md5.h"

using namespace std;

CppSQLite3DB * CDbManager::db = NULL;

bool CDbManager::_CheckDB()
{
	if(db)return true;
	return _InitDb();
}
void CDbManager::CloseDb()
{
	if(db)
		db->close();
	db=NULL;
}
bool CDbManager::_InitDb()
{
	if(db)return true;
	try{
		db = new CppSQLite3DB;
	string dbPath = "";
	string dbfile = SevenCBoxClient::GetUserSession()->GetUserAccountName();//"task_manager_db.db3";
	MD5 md5;
	md5.update(dbfile);
	dbfile = md5.toString();
	dbfile.append(".db");
	if(!SevenCBoxClient::Config.GetDbFilePath().empty())
	{
		dbPath.append(SevenCBoxClient::Config.GetDbFilePath());
		dbPath.append(dbfile);
	}
	else
	{
		dbPath = dbfile;
	}
	
		db->open(dbPath.c_str());
		return true;
		//db->open("D:\\WorkSpace\\WorkSpace_For_VS2010\\SevenCBox_WorkSpace\\7CBoxClient\\bin\\c0a0e1439da66958f99947b79d6c4a6e\\c0a0e1439da66958f99947b79d6c4a6e.db");
	}catch(...)
	{
		return false;
	}
}
