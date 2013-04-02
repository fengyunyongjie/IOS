#ifndef _INC_CFOLDERSYNC_H
#define _INC_CFOLDERSYNC_H
#include "clientlib/tinythread.h"
#include <json/json.h>
class CFolderSync
{

public:

	static void StartSync();
	static Json::Value & GetFileList(int folder_id);
};

#endif