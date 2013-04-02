/*--------------------------------------------------------------
 | Author        £º Antigloss @ http://stdcpp.cn
 | File          :  file_utility.hpp
 | Last modified :  2007-04-05
 | Create date   :  2007-03-28
 | Abstract      £º file utilities
 -------------------------------------------------------------*/

#ifndef FILE_UTILITY_HPP
#define FILE_UTILITY_HPP

// function name : chk_file
// abstract      : check file existence
// last modified : 2007-04-05 19:00
inline bool chk_file(const char *file)
{
	ifstream infile(file);
	if ( !infile )
	{
		return false; // file not exist
	}
	
	return true;      // file exists
} // end of chk_file

#endif  // FILE_UTILITY_HPP
