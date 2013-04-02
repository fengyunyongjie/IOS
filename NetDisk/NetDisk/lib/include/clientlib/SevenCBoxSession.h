#ifndef SEVENCBOXSESSION_H_
#define SEVENCBOXSESSION_H_
#include <string>
#include "clientlib/ClientExport.h"
using namespace std;
class EXTERNCLASS SevenCBoxSession {
friend class SevenCBoxClient;
private:
	string sUserId;
	string sUserName;
	string sUserToken;
private:
	SevenCBoxSession(string userId,string userName,string userToken)
	{
		sUserId = userId;
		sUserName = userName;
		sUserToken = userToken;
	}
	SevenCBoxSession(){
          sUserId = "";
            sUserName = "";
            sUserToken = "";
	};
public:
	virtual ~SevenCBoxSession();
	string GetUserId();
	string GetUserAccountName();
	string GetClientTag();
	string GetUserToken();
};

#endif
