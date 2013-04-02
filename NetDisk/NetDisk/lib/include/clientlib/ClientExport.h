#ifndef export_h
#define export_h
#ifdef Export_DLL
#define EXTERNCLASS __declspec(dllexport)
#elif defined Static_LIB
#define EXTERNCLASS
#else
#define EXTERNCLASS  __declspec(dllimport)
#endif 

#endif