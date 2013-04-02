/*--------------------------------------------------------------
 | Author        £º Antigloss @ http://stdcpp.cn
 | File          :  splitor.hpp
 | Last modified :  2007-04-05
 | Create date   :  2007-03-28
 | Abstract      £º functions to implement splitor
 -------------------------------------------------------------*/

#ifndef SPLITOR_HPP
#define SPLITOR_HPP

// ISO C++ standard header
#include <string>  // for string

// standard header inherited from C
#include <cstddef> // for size_t
class CFileSplitter{
public:
	//CFileSplitter(char * dstFolder="d:\\temp\\");

// main process function
static void split(const char *src);   // split file
static void merge(const char *dst);   // merge files
static const char * get_split_file(const char * fileName,int index);
static const char * get_file_name(const char * fileFullPath);
static const int get_split_count(const char * fileFullPath);
static const char * get_splite_file(const char * src,int skip,size_t splite_size);
static const  long get_file_size(const char* file);
static const long get_file_size(FILE * fp);
static const long get_file_size(ifstream &file);
static const string get_file_md5(const char * fileFullPath);
// auxiliary functions
static void chk_overflow(const std::string &stmp,
                  const std::string::size_type radix_point,
                  const std::size_t multor);                   // check size overflow
static void chk_overflow2(const std::string &stmp,
                   const std::string &maxsize,
                   const std::string::size_type radix_point,
                   const std::string::size_type int_part_len);      // check size overflow 2
                        // get and validate command line options
//void getsize(const char *s);                                        // get size for each fragment
                                       // print usage
static bool validate_size(const std::string &stmp, std::size_t &multor);   // validate size
static const char * destFolder;
private:
 static bool check_folder();

 // global variables
 static int          issplit;          // 0: merge, 1: split, 2: undetermined
 const static std::size_t  frag_size = 1024*1024;        // size for each file fragment
 
};
#endif  // SPLITOR_HPP

