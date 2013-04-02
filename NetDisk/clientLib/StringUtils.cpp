#ifdef _WIN32
#include <clientlib/stringutils.h>
#include <iostream>
#include <vector>
#include <Windows.h>
string JsonStringUtil::ws2s(const wstring& ws)
{

    string curLocale = setlocale(LC_ALL, NULL);
	setlocale(LC_ALL, "chs");
	const wchar_t* _Source = ws.c_str();
	size_t _Dsize = 2 * ws.size() + 1;
	char *_Dest = new char[_Dsize];
	memset(_Dest,0,_Dsize);
	wcstombs(_Dest,_Source,_Dsize);
	string result = _Dest;
	delete []_Dest;
	setlocale(LC_ALL, curLocale.c_str());
	return result;
}

wstring JsonStringUtil::s2ws(const string& s)
{
	std::string curLocale = setlocale(LC_ALL, NULL); // curLocale = "C";
	setlocale(LC_ALL, "chs");
	const char* _Source = s.c_str();
	size_t _Dsize = s.size() + 1;
	wchar_t *_Dest = new wchar_t[_Dsize];
	wmemset(_Dest, 0, _Dsize);
	mbstowcs(_Dest,_Source,_Dsize);
	std::wstring result = _Dest;
	delete []_Dest;
	setlocale(LC_ALL, curLocale.c_str());
	return result;

}

void Gb2312ToUnicode(WCHAR* pOut,const char *gbBuffer)
{
	::MultiByteToWideChar(CP_ACP,MB_PRECOMPOSED,gbBuffer,2,pOut,1);
}
// Unicode 转换成UTF-8
void UnicodeToUTF_8(char* pOut,WCHAR* pText)
{
	// 注意 WCHAR高低字的顺序,低字节在前，高字节在后
	char* pchar = (char*)pText;

	pOut[0] = (0xE0|((pchar[1]&0xF0)>>4));
	pOut[1] = (0x80|((pchar[1]&0x0F)<<2))+((pchar[0]&0xC0)>>6);
	pOut[2] = (0x80|(pchar[0]&0x3F));

}
void UTF_8ToUnicode(WCHAR* pOut,const char *pText)
{
	char* uchar = (char *)pOut;

	uchar[1] = ((pText[0]&0x0F)<<4)+((pText[1]>>2)&0x0F);
	uchar[0] = ((pText[1]&0x03)<<6)+(pText[2]&0x3F);

}

// 把Unicode 转换成 GB2312
void UnicodeToGB2312(char* pOut,unsigned short uData)
{
	WideCharToMultiByte(CP_ACP,NULL,LPCWSTR(uData),1,pOut,sizeof(WCHAR),NULL,NULL);
}

int IsGB( char *pText )
{
	unsigned char *sqChar = (unsigned char *)pText;
	if (sqChar[0] >= 0xa1)
	{
		if (sqChar[0] == 0xa3)
		{
			return 1;//全角字符
		}
		else
		{
			return 2;//汉字
		}
	}
	else
	{
		return 0;//英文、数字、英文标点
	}
}

string JsonStringUtil::GB2312ToUTF_8(const char *pText,int pLen)
{
	if(pLen==0)return string(pText);
	string pOut;
	char buf[1024];
	char* rst = new char[pLen+(pLen>>2)+2];

	memset(buf,0,1024);
	memset(rst,0,pLen+(pLen>>2)+2);

	int i = 0;
	int j = 0;
	while(i < pLen)
	{
		//如果是英文直接复制就可以
		if( *(pText + i) >= 0)
		{
			rst[j++] = pText[i++];
		}
		else
		{
			WCHAR pbuffer;
			Gb2312ToUnicode(&pbuffer,pText+i);
			UnicodeToUTF_8(buf,&pbuffer);

			unsigned short int tmp = 0;
			tmp = rst[j] = buf[0];
			tmp = rst[j+1] = buf[1];
			tmp = rst[j+2] = buf[2];


			j+= 3;
			i+= 2;
		}
	}
	strcpy_s(&rst[j],1,"\0");
	//返回结果
	pOut = rst;

	return pOut;
}

//UTF-8 转为 GB2312
string JsonStringUtil::UTF_8ToGB2312(const char *pData,int size)
{
	/*if(pLen==0)return string(pText);
	string pOut;
	char * newBuf = new char[pLen];
	char Ctemp[4];
	memset(Ctemp,0,4);

	int i =0;
	int j = 0;

	while(i < pLen)
	{
		if(pText[i] > 0)
		{
			newBuf[j++] = pText[i++];
		}
		else
		{
			WCHAR Wtemp;
			UTF_8ToUnicode(&Wtemp,pText+i);
			UnicodeToGB2312(Ctemp,Wtemp);
			newBuf[j] = Ctemp[0];
			newBuf[j+1] = Ctemp[1];
			i+= 3;
			j+= 2;
		}
	}
	strcpy_s(&newBuf[j],1,"\0");

	pOut = newBuf;

	return pOut;*/
	size_t n = MultiByteToWideChar(CP_UTF8, 0, pData, (int)size, NULL, 0);
	WCHAR   *   pChar   =   new   WCHAR[n+1];

	n = MultiByteToWideChar(CP_UTF8, 0, pData, (int)size, pChar, n);
	pChar[n]=0;

	n = WideCharToMultiByte(936, 0, pChar, -1, 0, 0, 0, 0);
	char *p = new char[n+1];

	n = WideCharToMultiByte(936, 0, pChar, -1, p, (int)n, 0, 0);
	string result(p);

	delete []pChar;
	delete []p;
	return result;
}
bool JsonStringUtil::IsUTF8( const char * pzInfo )
{
	int nWSize = MultiByteToWideChar( CP_UTF8,MB_ERR_INVALID_CHARS,pzInfo,-1,NULL,0 );
	int error = GetLastError();
	if (error == ERROR_NO_UNICODE_TRANSLATION)
	{
		return false;
	}
	//判断是否是gb2312,只要把CP_UTF8用936代替即可.
	return true;
}
bool JsonStringUtil::IsGB2312( const char *pzInfo )
{
	int nWSize = MultiByteToWideChar( 936,MB_ERR_INVALID_CHARS,pzInfo,-1,NULL,0 );
	int error = GetLastError();
	if (error == ERROR_NO_UNICODE_TRANSLATION)
	{
		return false;
	}
	//判断是否是CP_UTF8,只要把936用CP_UTF8代替即可.
	return true;
}
bool JsonStringUtil::IsChinese( const char *pzInfo )
{
	if(!pzInfo)return false;
	int i;
	char *pText = (char*)pzInfo;
	while (*pText != '\0')
	{
		i = IsGB(pText);
		switch(i)
		{
		case 0:
			pText++;
			break;
		case 1:
			pText++;
			pText++;
			break;
		case 2:
			pText++;
			pText++;
			return TRUE;
			break;
		}
	}
	return false;
}

wstring JsonStringUtil::AnsiToUnicode(const char* buf)
{
	int len = ::MultiByteToWideChar(CP_ACP, 0, buf, -1, NULL, 0);
	if (len == 0) return L"";

	std::vector<wchar_t> unicode(len);
	::MultiByteToWideChar(CP_ACP, 0, buf, -1, &unicode[0], len);

	return &unicode[0];
}

string JsonStringUtil::UnicodeToAnsi(const wchar_t* buf)
{
	int len = ::WideCharToMultiByte(CP_ACP, 0, buf, -1, NULL, 0, NULL, NULL);
	if (len == 0) return "";

	std::vector<char> utf8(len);
	::WideCharToMultiByte(CP_ACP, 0, buf, -1, &utf8[0], len, NULL, NULL);

	return &utf8[0];
}

wstring JsonStringUtil::Utf8ToUnicode(const char* buf)
{
	int len = ::MultiByteToWideChar(CP_UTF8, 0, buf, -1, NULL, 0);
	if (len == 0) return L"";

	std::vector<wchar_t> unicode(len);
	::MultiByteToWideChar(CP_UTF8, 0, buf, -1, &unicode[0], len);

	return &unicode[0];
}

string JsonStringUtil::UnicodeToUtf8(const wchar_t* buf)
{
	int len = ::WideCharToMultiByte(CP_UTF8, 0, buf, -1, NULL, 0, NULL, NULL);
	if (len == 0) return "";

	std::vector<char> utf8(len);
	::WideCharToMultiByte(CP_UTF8, 0, buf, -1, &utf8[0], len, NULL, NULL);

	return &utf8[0];
}

#endif
