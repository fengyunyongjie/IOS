#ifndef HTTPCLIENTCOMM_H
#define HTTPCLIENTCOMM_H

#include <json/json.h>
using namespace Json;

typedef int (*My_Progress_Func)(char *progress_data,
	double t, /* dltotal */
	double d, /* dlnow */
	double ultotal,
	double ulnow
	);
typedef size_t (*My_Write_Func)(void *ptr, size_t size, size_t nmemb, FILE *stream);
typedef size_t (*My_Read_Func)(void *ptr, size_t size, size_t nmemb, FILE *stream);
typedef void (*SCBoxCallBack)(Value &jsonValue,void * ui_ptr);
typedef void (*TaskView_CallBack)(void * task);
typedef void (*TaskCallBack)(void * task,void * pUI);
#endif