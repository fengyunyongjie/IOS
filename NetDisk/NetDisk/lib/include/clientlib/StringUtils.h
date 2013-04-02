#ifndef JsonStringUtil_H
#define JsonStringUtil_H
#ifdef _WIN32
#include <string>
#include <windows.h>
#include <string.h>
using namespace std;
class  JsonStringUtil
{
public:
	JsonStringUtil(void);
	~JsonStringUtil(void);
	static string ws2s(const wstring& ws);
	static wstring s2ws(const string& s);

	static string UnicodeToUtf8(const wchar_t* buf);
	static wstring Utf8ToUnicode(const char* buf);
	static string UnicodeToAnsi(const wchar_t* buf);
	static wstring AnsiToUnicode(const char* buf);
	static string GB2312ToUTF_8(const char *pText,int pLen);
	static string UTF_8ToGB2312(const char *pText,int pLen);
	static bool IsChinese( const char *pzInfo );
	static bool IsUTF8( const char * pzInfo );
	static bool IsGB2312( const char *pzInfo );

};
#endif
#endif
