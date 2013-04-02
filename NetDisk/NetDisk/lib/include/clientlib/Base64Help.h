#include <string> 
using namespace std;  

class Base64Help{ 

private: 

	static void _enBase64Help(unsigned char chasc[3],unsigned char chuue[4]); 

	static void _deBase64Help(unsigned char chuue[4],unsigned char chasc[3]); 
public:
	static string enBase64( const char* inbuf, size_t inbufLen ); 

	static string enBase64( const string &inbuf); 

	static int deBase64( string src, char* outbuf ); 

	static string deBase64( string src); 

}; 