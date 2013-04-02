#ifndef FILE_ERROR_HPP
#define FILE_ERROR_HPP

#include <stdexcept>
#include <string>

namespace ant {

class file_error : public std::runtime_error {
public:    
    file_error(const std::string &emsg) : std::runtime_error(emsg) { }
};

} // end of namespace ant

#endif // FILE_ERROR_HPP

