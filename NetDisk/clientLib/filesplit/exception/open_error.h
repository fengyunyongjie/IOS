#ifndef OPEN_ERROR_HPP
#define OPEN_ERROR_HPP

#include "file_error.h"

namespace ant {

class open_error : public file_error {
public:
    open_error(const std::string &emsg =
	          "Cannot open file or directory. "
		  "Please make sure the file/directory is existed "
		  "and you have the appropriate authority to access it.")
       	       : file_error(emsg) { }
};

} // end of namespace ant

#endif // OPEN_ERROR_HPP

