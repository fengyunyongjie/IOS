#include "FolderSync.h"
#include <sstream>
#include "DbManager.h"
#include <clientlib/SevenCBoxClient.h>
#include <clientlib/AsynRequest.h>
#include <clientlib/StringUtils.h>
#include <curl/curl.h>
using namespace std;

string JsonToString( const char *value )
{
#ifdef _WIN32
	if(JsonStringUtil::IsChinese(value)&& JsonStringUtil::IsGB2312(value)){
		int size = string(value).length();
		/*int size0 = sizeof(value[0]);*/
		string utf8Value = JsonStringUtil::GB2312ToUTF_8(value,size);
		/*
         int size1 = utf8Value.length();
         int size01 = sizeof(utf8Value.c_str()[0]);
         string gb2312Value = JsonStringUtil::UTF_8ToGB2312(utf8Value.c_str(),size1);
         */
		return utf8Value;
	}
	else
		return string("")+ value;
#else
	return string("")+value;
#endif
}
void Json2Parameter( const Value &value ,string & document_,const string * itemName)
{
    
	switch ( value.type() )
	{
        case nullValue:
            document_ += "null";
            break;
        case intValue:
            document_ += Json::valueToString( value.asInt() );
            break;
        case uintValue:
            document_ += Json::valueToString( value.asUInt() );
            break;
        case realValue:
            document_ += Json::valueToString( value.asDouble() );
            break;
        case stringValue:
            document_ += JsonToString(value.asCString());
            break;
        case booleanValue:
            document_ += Json::valueToString( value.asBool() );
            break;
        case arrayValue:
		{
			int size = value.size();
			for ( int index =0; index < size; ++index )
			{
				if(index>0){
					document_ += "&";
					document_ += *itemName;
					document_ += "=";
				}
                
				Json2Parameter(value[index],document_,itemName);
			}
		}
            
            break;
        case objectValue:
		{
			Value::Members members( value.getMemberNames() );
            
			for ( Value::Members::iterator it = members.begin();
                 it != members.end();
                 ++it )
			{
				const string &name = *it;
                
				if ( it != members.begin() )
					document_ += "&";
				document_ += name;
				document_ += "=";
				Json2Parameter( value[name],document_,&name);
			}
			document_ += "";
		}
            break;
	}
}
void parseStr(CURLcode res,const string & jsonStr,Value & josnResponse)
{
	if(res == CURLE_OK){
        
		SevenCBoxClient::GetLOG()<<"POSTÃ·ΩªÕÍ≥…! return code is:"<<res<<endl;
		Json::Reader jsonReader;
        
		if(jsonStr.empty()){
			josnResponse["code"]=99900;//∑µªÿ÷µŒ™ø’
			josnResponse["error"]="response is NULL!";
		}
		else
		{
			SevenCBoxClient::GetLOG()<<"ø™ ºΩ‚ŒˆœÏ”¶∂‘œÛ£°jsonStr is:"<<jsonStr<<endl;
			jsonReader.parse(jsonStr.c_str(),josnResponse);
			if(!jsonReader.parse(jsonStr.c_str(),josnResponse)){
				josnResponse["code"]=99900;//Ω‚Œˆ∑µªÿ÷µ ß∞‹
				josnResponse["error"]="failed in parse json string:"+jsonStr+" error message is:"+jsonReader.getFormatedErrorMessages();
			}
		}
	}
	else
	{
		josnResponse["code"]=99900+res;//Õ¯¬Á¥ÌŒÛ
		josnResponse["error"]=curl_easy_strerror(res);
	}
}
bool CheckTalbe()
{
	if(CDbManager::_CheckDB())
	{
		return CDbManager::db->tableExists("folder_cache");
	}
	else
		return false;
}
void CreateTable()
{
	if(CDbManager::_CheckDB()){
		ostringstream oss;
		oss<<"CREATE TABLE [folder_cache] (";
		oss<<"[folder_id] INT NOT NULL ON CONFLICT ROLLBACK, ";
		oss<<"[folder_content] VARCHAR, ";
		oss<<"[last_sync] DATETIME NOT NULL ON CONFLICT ROLLBACK DEFAULT (datetime('now')), ";
		oss<<"CONSTRAINT [] PRIMARY KEY ([folder_id] ASC) ON CONFLICT ROLLBACK);"<<endl;
		try{
			CDbManager::db->execDML(oss.str().c_str());
		}catch(...)
		{
			throw "error when create folder_cache table.";
		}
	}
}
void SaveToTable(int folder_id,string & jsonValue)
{
	ostringstream oss;
	
	oss<<"replace into folder_cache (folder_id,folder_content) values("<<folder_id<<",'"<<jsonValue<<"')";
	try{
		CDbManager::db->execDML(oss.str().c_str());
	}catch(...)
	{
#ifdef _DEBUG
		SevenCBoxClient::GetLOG()<<"SQL Error:oss.str()"<<endl;
#endif // _DEBUG
	}
}
void SyncChildFolder(int folder_id)
{
	Value headerFields;
	if(SevenCBoxClient::GetFromUserSession(headerFields)<=0)return;
	CJsonHttpClient client;
	ostringstream oss;
	oss<<folder_id;
	Value jsonRequest;
	jsonRequest["f_id"]= folder_id;
	jsonRequest["cursor"]= 0;
	jsonRequest["offset"]= -1;
	
	string jsonStr;
	Value jsonResponse;
	vector<string> headerlist;
	string postString = "";
	Json2Parameter(jsonRequest,postString,NULL);
	if(headerFields!=NULL && !headerFields.empty())
	{
		Json::Value::Members members( headerFields.getMemberNames() );
		//±È¿˙À˘”–µƒname£¨≤È’“÷µ
		for ( Json::Value::Members::iterator it = members.begin();
             it != members.end();
             ++it ){
            string &name = *it;
            string field("");
            field.append(name).append(":");
#ifdef _WIN32
            const char * nameValue = headerFields[name].asCString();
            if(nameValue&&nameValue!=""&&JsonStringUtil::IsChinese(nameValue) && JsonStringUtil::IsGB2312(nameValue))
                field.append(JsonStringUtil::GB2312ToUTF_8(nameValue,string(nameValue).length()));
            else
                field.append(headerFields[name].asCString());
#else
            field.append(headerFields[name].asCString());
#endif
            
            headerlist.push_back(field.c_str());
		}
        
	}
    
	int res = client.Post(SevenCBoxClient::GetRequestURL(ClientConfig::FM_URI),postString,headerlist,jsonStr);
	
	parseStr((CURLcode)res,jsonStr,jsonResponse);
	if(jsonResponse.isMember("code"))
	{
		int code = jsonResponse["code"].asInt();
		if(code == 0)
		{
			
			SaveToTable(folder_id,jsonStr);
			if(jsonResponse.isMember("files"))
			{
				Value val_array = jsonResponse["files"];
				int iSize = val_array.size();
				for ( int nIndex = 0;nIndex < iSize;++ nIndex )
				{
					
					if ( val_array[nIndex].isMember( "f_id" ) &&  val_array[nIndex].isMember( "f_mime" ))
					{
						int child_f_id = (unsigned long)val_array[nIndex]["f_id"].asInt();
						string f_mime = val_array[nIndex]["f_mime"].asString();
						if(f_mime!="directory")continue;
						
						SyncChildFolder(child_f_id);
						
					}
				}
			}
		}
	}
}
void StartSyncThread(void * ptr)
{
	Value headerFields;
	if(SevenCBoxClient::GetFromUserSession(headerFields)<=0)return;
	CJsonHttpClient client;
	if(!CheckTalbe())CreateTable();
	Value jsonRequest;
	jsonRequest["f_id"]= 1;
	jsonRequest["cursor"]= 0;
	jsonRequest["offset"]= -1;
    
	string jsonStr;
	Value jsonResponse;
	vector<string> headerlist;
	string postString = "";
	Json2Parameter(jsonRequest,postString,NULL);
	if(headerFields!=NULL && !headerFields.empty())
	{
		Json::Value::Members members( headerFields.getMemberNames() );
		//±È¿˙À˘”–µƒname£¨≤È’“÷µ
		for ( Json::Value::Members::iterator it = members.begin();
             it != members.end();
             ++it ){
            string &name = *it;
            string field("");
            field.append(name).append(":");
#ifdef _WIN32
            const char * nameValue = headerFields[name].asCString();
            if(JsonStringUtil::IsChinese(nameValue) && JsonStringUtil::IsGB2312(nameValue))
                field.append(JsonStringUtil::GB2312ToUTF_8(nameValue,string(nameValue).length()));
            else
                field.append(headerFields[name].asCString());
#else
            field.append(headerFields[name].asCString());
#endif
            
            headerlist.push_back(field.c_str());
		}
        
	}
    
	int res = client.Post(SevenCBoxClient::GetRequestURL(ClientConfig::FM_URI),postString,headerlist,jsonStr);
    
    
    parseStr((CURLcode)res,jsonStr,jsonResponse);
    if(jsonResponse.isMember("code"))
    {
        int code = jsonResponse["code"].asInt();
        if(code == 0)
        {
            
            SaveToTable(1,jsonStr);
            if(jsonResponse.isMember("files"))
            {
                Value val_array = jsonResponse["files"];
                int iSize = val_array.size();
                for ( int nIndex = 0;nIndex < iSize;++ nIndex )
                {
                    
                    if ( val_array[nIndex].isMember( "f_id" ) &&  val_array[nIndex].isMember( "f_mime" ))
                    {
                        int child_f_id = (unsigned long)val_array[nIndex]["f_id"].asInt();
                        string f_mime = val_array[nIndex]["f_mime"].asString();
                        if(f_mime!="directory")continue;
                        
                        SyncChildFolder(child_f_id);
                    }
                }
            }
        }
    }
}
void CFolderSync::StartSync()
{
	if(!CheckTalbe())CreateTable();
	tthread::thread t = thread(StartSyncThread,NULL);
	t.join();
	
}

Value & CFolderSync::GetFileList( int  folder_id )
{
	if(!CheckTalbe())
	{	Value jsonValue;
		jsonValue["code"]=1;
		return jsonValue;
	}
	ostringstream oss;
	oss<<"select count(*) from folder_cache where folder_id="<<folder_id<<endl;
	try{
		int count = CDbManager::db->execScalar(oss.str().c_str());
		if(count==0)
		{
			Value jsonValue;
			jsonValue["code"]=1;
			return jsonValue;
		}
        ostringstream oss1;
        oss1<<"select folder_content from folder_cache where folder_id="<<folder_id<<endl;
        
        CppSQLite3Query query = CDbManager::db->execQuery(oss1.str().c_str());
        if(query.eof())
        {
            Value jsonValue;
            jsonValue["code"]=1;
            return jsonValue;
        }
        else
        {
            Json::Reader jsonReader;
            Value jsonValue;
            const char * content = query.getStringField("folder_content");
            //int size = string(content).length();
		//string new_content = JsonStringUtil::UTF_8ToGB2312(content,size);
		bool parsed = jsonReader.parse(content,jsonValue);
		if(parsed) return jsonValue;
		else
		{
			jsonValue["code"]=1;
			return jsonValue;
		}
	}
	}catch(...)
	{
#ifdef _DEBUG
		SevenCBoxClient::GetLOG()<<"SQL Error:oss.str()"<<endl;
#endif // _DEBUG
	}
}
