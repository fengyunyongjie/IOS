#ifndef CPPStringUtils_H
#define CPPStringUtils_H
#include <string>
using namespace std;
class CPPStringUtils
{
public:
	CPPStringUtils(void);
	~CPPStringUtils(void);

static string ws2s(const wstring& ws);
static wstring s2ws(const string& s);
};
#endif