/*--------------------------------------------------------------
 | Author        :  Antigloss @ http://stdcpp.cn
 | File          :  splitor.cpp
 | Last modified :  2012-04-05
 | Create date   :  2012-03-28
 | Abstract      :  functions to implement splitor
 -------------------------------------------------------------*/

// standard headers inherited from C
#include <cctype>    // for isdigit, toupper ...
#include <cstdarg>   // for va_start, va_end ...
#include <cstddef>   // for size_t
#include <cstdlib>   // for exit
#include <cstdio>    // for remove
// ISO C++ standard hearders
#include <algorithm>
#include <fstream>   // for ifstream, ofstream
#include <iostream>  // for cout, cin ...
#include <sstream>   // for stringstream
#include <stdexcept> // for excptions such as logic_error and out_of_range
#include <string>    // for string
#include "../../md5.h"
#include <clientlib/StringUtils.h>

using namespace std;

// self-defined headers
#include "FileSplitter.h"
#include "../exception/open_error.h"              // for open_error
#include "../file_utilities/file_utilities.h"     // for chk_file()
#include <clientlib/SevenCBoxClient.h>


using namespace ant;

//int        issplit = 2;               // 0: merge, 1: split, 2: undetermined
//size_t     frag_size;                 // size for each file fragment
//const char *src, *dst;                // source file, destination file

namespace {
    const string maxsizeb("4294967296");  // max supported size (in byte) for each part when in a 32-bit system
    const string maxsizek("4194304");     // max supported size (in byte) for each part when in a 32-bit system
    const string maxsizem("4096");        // max supported size (in byte) for each part when in a 32-bit system
    const string maxsizeg("4");           // max supported size (in byte) for each part when in a 32-bit system
    const size_t BUF_SIZE = 4096;         // buffer size
    const size_t MAX_NUM  = 4294967295u;  // biggest number size_t can hold when size_t is of 32-bit unsigned integer type
}

// function name : split
// abstract      : split file
// last modified : 2012-07-02 21:30
void CFileSplitter::split(const char * src)
{

    ifstream infile(src, ifstream::binary);
    if ( !infile )
    {   // if file dosen't exist
	string emsg(src);
	emsg += ": no such file or directory or you don't have the authority to access it.";
    	throw open_error(emsg);
    }
	const char * file_name = get_file_name(src);
    bool          eof = false;
    size_t        rd_amt;          // read amount
    char          buf[BUF_SIZE];   // read buffer
    for ( size_t cnt = 1; !eof; ++cnt )
    {
    	//ostringstream oss;

    	//oss << this->destFolder <<dst<< ".INDEX_" << cnt;
		const char* dst_file_path = get_split_file( file_name,cnt );
   // 	if ( chk_file(dst_file_path) )
   //     { // if file already exists
	  // /* string emsg(dst_file_path);
	  //  emsg += ": file already exists.";
	  //  throw logic_error(emsg);*/

			//continue;
   //     }

        ofstream outfile(dst_file_path, ios::binary|ios::out);
        if ( !outfile )
        {
	    string emsg(dst_file_path);
	    emsg += ": cannot create file. Please make sure you have the appropriate authority and the disk is not full.";
	    throw open_error(emsg);
        }

        for ( size_t i = 0; i != frag_size; i += infile.gcount() )
        {
        	// minus 1 in case the result exceeds MAX_NUM
        	if ( (i + (BUF_SIZE - 1)) < frag_size )
        	{
        		rd_amt = BUF_SIZE;
        	}
        	else
        	{
        		rd_amt = frag_size - i;
        	}

        	if ( infile.read(buf, rd_amt) )
        	{
            	outfile.write(buf, infile.gcount());
            }
            else
            {
           		outfile.write(buf, infile.gcount());
            	eof = true;
            	break;
            }
        }
        outfile.flush();
		outfile.close();
        // check if reaching EOF
        if ( !eof )
        {
        	if (infile.peek() == EOF)
        	{
        		eof = true;
        	}
        	else if ( cnt == MAX_NUM )
        	{   // if cnt is going to exceed but not yet encounter EOF
		    string emsg(src);
		    emsg += ": number of parts exceeds max allowed number.";
		    throw out_of_range(emsg);
        	}
        }
    }
	infile.close();
} // end of split
bool CFileSplitter::check_folder()
{
	
	fstream folder(SevenCBoxClient::Config.GetTempFolder().c_str(),ios::in|ios::out);
	if(folder){
		folder.close();
		return true;
	}
	else
	return false;
}
// function name : merge
// abstract      : merge files
// last modified : 2012-07-02 21:30
void CFileSplitter::merge(const char * dst)
{
	if ( chk_file(dst) )
	{ // if file already exists
		string emsg(dst);
		emsg += ": file already exists.";
		throw logic_error(emsg);
	}

	ofstream outfile(dst, ofstream::binary);
	if ( !outfile )
	{
		string emsg(dst);
		emsg += ": cannot create file. Please make sure you have the appropriate authority and the disk is not full.";
		throw open_error(emsg);
	}
	const char * file_name = get_file_name(dst);
	char buf[BUF_SIZE];
	for ( size_t cnt = 1; ; cnt++ )
	{
		/*ostringstream oss;
		oss << src << '.' << cnt;*/
		const char* src_file_path = get_split_file( file_name,cnt );
		ifstream infile(src_file_path, ifstream::binary);
		if ( !infile )
		{
			if ( cnt == 1 )
			{ // fail to open the first file fragment
				outfile.close();
				remove(dst);
				string emsg(src_file_path);
				emsg += ": no such file or you don't have authority to access it.\n"
					"Please make sure the file name is correct.\n"
					"For example, if a name of the file fragments is\n"
					"`xx.xx.1', then only `xx.xx' should be inputted.";
				throw open_error(emsg);
			}
			// files merged completely
			break;
		}

		while ( infile.read(buf, BUF_SIZE) )
		{
			outfile.write(buf, infile.gcount());
		}
		outfile.write(buf, infile.gcount());
		infile.close();
		if ( cnt == MAX_NUM )
		{   // files merged completely
			break;
		}
	}
	if(outfile){
	outfile.flush();
	outfile.close();
	}

} // end of merge


/*----------------------------------------------------------------------
 *                        Auxiliary functions
 *---------------------------------------------------------------------*/
// function name : chk_overflow
// abstract      : check size overflow
// last modified : 2007-04-04 23:10
void CFileSplitter::chk_overflow(const string &stmp,
                  const string::size_type radix_point,
                  const size_t multor)
{
	string::size_type int_part_len; // length of integer part

	if ( multor != 1 && radix_point == stmp.size())
	{   // do not count k, m or g into length
		int_part_len = radix_point - 1;
	}
	else
	{
		int_part_len = radix_point;
	}

	switch (multor)
	{
		case 1:
			chk_overflow2(stmp, maxsizeb, radix_point, int_part_len);
			break;
		case 1024:
			chk_overflow2(stmp, maxsizek, radix_point, int_part_len);
			break;
		case 1024 * 1024:
			chk_overflow2(stmp, maxsizem, radix_point, int_part_len);
			break;
		case 1024 * 1024 * 1024:
			chk_overflow2(stmp, maxsizeg, radix_point, int_part_len);
			break;
		default:  // normally, this never happens
			throw runtime_error("unexpected error occured!\n"
				            "Please report this to Antigloss@163.com.");
	}
} // end of chk_overflow

// function name : chk_overflow2
// abstract      : check size overflow 2
// last modified : 2007-04-04 23:20
void CFileSplitter::chk_overflow2(const string &stmp,
                   const string &maxsize,
                   const string::size_type radix_point,
                   const string::size_type int_part_len)
{
	if ( int_part_len > maxsize.size() )
	{
	    string emsg(stmp);
	    emsg += ": out of range. Support only up to 4GB.";
	    throw out_of_range(emsg);
	}

	if ( int_part_len == maxsize.size() )
	{
		int isgreater;

#if       '1' > '0'   // if digits of the character set are in ascend order
#define   gt  >
#else                 // if digits of the character set are in descend order
#define   gt  <
#endif  // This macro is defined to make our program compatible with different character sets.
        // But if digits of a character set is neither ascend order nor descend order, this program fails.

		if ( (isgreater = stmp.compare(0, int_part_len, maxsize)) gt 0 )
		{
		    string emsg(stmp);
		    emsg += ": out of range. Support only up to 4GB.";
		    throw out_of_range(emsg);
		}

#undef   gt

		if ( isgreater == 0 && radix_point != stmp.size() )
		{
			for ( string::size_type i = radix_point + 1; i != stmp.size(); ++i )
			{
				if ( stmp[i] > '0' && stmp[i] <= '9' )
				{
				    string emsg(stmp);
				    emsg += ": out of range. Support only up to 4GB.";
				    throw out_of_range(emsg);
				}
			}
		}
	}
} // end of chk_overflow2



// function name : validate_size
// abstract      : validate size
// last modified : 2012-04-04 23:00
bool CFileSplitter::validate_size(const string &stmp, size_t &multor)
{
   	if ( stmp.size() == 0 )
	{
		return false;
	}

	string::size_type radix_point = stmp.size();
	for ( string::size_type i = 0; i != stmp.size(); ++i )
	{
		if ( !isdigit(stmp[i]) )
		{
			if ( (i + 1) == stmp.size() )
			{ // if stmp[i] is the last character of stmp
			    char c = toupper(stmp[i]);
			    switch (c)
			    {
                    case 'B':
                        multor = 1;
                        break;
			    	case 'K':
			    		multor = 1024;
			    		break;
			    	case 'M':
			    		multor = 1024 * 1024;
			    		break;
			    	case 'G':
			    		multor = 1024 * 1024 * 1024;
			    		break;
			    	default:
			    		return false;
			    }
			}
			else if ( stmp[i] == '.' && radix_point == stmp.size() && isdigit(stmp[i + 1]) )
			{   // stmp[i] is not the last character of stmp
                // if first occurance of `.' and the character following `.' is a number
				radix_point = i++;
			}
			else
			{
				return false;
			}
		}
	}
	// if k, m or g is the only character in stmp
	if ( multor != 1 && stmp.size() == 1)
	{
		return false;
	}
	chk_overflow(stmp, radix_point, multor);

	return true;
} // end of validate_size

const char * CFileSplitter::get_split_file( const char * fileName,int index )
{
	char * tempFile = (char *)malloc(255);
	char str[30];
	
	strcpy(tempFile,SevenCBoxClient::Config.GetTempFolder().c_str());
	MD5 md5;
	md5.update(fileName);
#ifdef _WIN32
	strcat(tempFile,"\\split_file_");
#else
	strcat(tempFile,"split_file_");
#endif
	
	strcat(tempFile,md5.toString().c_str());
	strcat(tempFile,".");
	sprintf(str,"%d",index);
	strcat(tempFile,str);
	return tempFile;

}

const char * CFileSplitter::get_file_name( const char * fileFullPath )
{
	int len;
	const char *current=NULL;
	len=strlen(fileFullPath);
	for (;len>0;len--) //从最后一个元素开始找.直到找到第一个'/'
#ifdef _WIN32
		if(fileFullPath[len]=='\\')
#else
		if(fileFullPath[len]=='/')
#endif
		{
			current=&fileFullPath[len+1];
			break;
		}
		return current;

}

const long CFileSplitter::get_file_size(FILE * fp)
{

	if(fp == NULL)return 0;
	long pos = ftell(fp);
	fseek(fp, 0, SEEK_END);
	long size =  ftell(fp);
	fseek(fp,pos,SEEK_SET);
	return size;

}
const long CFileSplitter::get_file_size(ifstream &file)
{

	if(!file.is_open())return 0;
	if(file)
		ios::pos_type currentPos = file.tellg();
	file.seekg(0,ios::end);
	long size = file.tellg();
	file.seekg(ios::beg);
	return size;
}
const long CFileSplitter::get_file_size(const char* file)
{
	/*ifstream infile;
	infile.open(file,ios::binary);
	long file_size = get_file_size(infile);
	if(infile && infile.is_open())infile.close();
	return file_size;*/
	
	FILE *fp = fopen(file,"rb");
	long size = 0;
	if(fp){

	size = get_file_size(fp);
	fclose(fp);
	}
	else
	size = 0;

	return size;
}

const int CFileSplitter::get_split_count( const char * fileFullPath )
{
	ifstream file(fileFullPath,ios::in|ios::binary);
	long fileSize = get_file_size(file);
	int splitCount = fileSize/frag_size;
	int totalSplited = splitCount*frag_size;
	if(fileSize>totalSplited)splitCount+=1;
	file.close();
	return splitCount;
}

const char * CFileSplitter::get_splite_file( const char * src,int skip,size_t splite_size )
{
	bool          eof = false;
	size_t        rd_amt;  // read amount
	int buffer_size = 1;
	if(splite_size>1)
		buffer_size = splite_size/2;

	char * buf =(char *) malloc(buffer_size);   // read buffer
	std::ifstream infile(src, ios::binary|ios::in);
	if ( !infile )
	{   // if file dosen't exist
		//string emsg(src);
		//emsg += ": no such file or directory or you don't have the authority to access it.";
		//throw open_error(emsg);
		return NULL;
	}

	const char * dst_file_path = get_split_file(src,skip);
	ofstream outfile;
	outfile.open(dst_file_path, ios::binary|ios::out);

	if ( !outfile )
	{
		/*string emsg(dst_file_path);
		emsg += ": cannot create file. Please make sure you have the appropriate authority and the disk is not full.";
		throw open_error(emsg);*/
		dst_file_path = NULL;
	}
	infile.seekg(0);
	infile.seekg(skip);
	if(infile.eof()){
		infile.close();
		return NULL;
	}
	try{
	for ( size_t i = 0; i != splite_size; i += infile.gcount() )
	{
		// minus 1 in case the result exceeds MAX_NUM
		if ( (i + (buffer_size - 1)) < splite_size )
		{
			rd_amt = buffer_size;
		}
		else
		{
			rd_amt = splite_size - i;
		}

		if ( infile.read(buf, rd_amt) )
		{
			outfile.write(buf, infile.gcount());
		}
		else
		{
			outfile.write(buf, infile.gcount());
			eof = true;
			break;
		}
	}
	free(buf);
	if(outfile)
		outfile.close();
	if(infile)
		infile.close();
	return dst_file_path;
	}catch(...)
	{
		if(outfile)
		outfile.close();
		if(infile)
		infile.close();
		return NULL;
	}
}

const string CFileSplitter::get_file_md5( const char * fileFullPath )
{
	MD5 md5;
	md5.reset();
	ifstream in(fileFullPath,ios::binary);
	if(in){
	md5.update(in);
	return md5.toString();
	}
	return "";
}


