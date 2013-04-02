#ifndef _INC_CDBMANAGER_H
#define _INC_CDBMANAGER_H
#include <clientlib/CppSQLite3.h>
class CDbManager
{
public:
	static CppSQLite3DB * db;
	static bool _CheckDB();
	static bool _InitDb();
	static void CloseDb();
};

#endif