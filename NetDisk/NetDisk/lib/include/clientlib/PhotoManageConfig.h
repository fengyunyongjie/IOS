#ifndef _INC_PhotoManageConfig_h_
#define _INC_PhotoManageConfig_h_
#include <string>
#include <json/json.h>
using namespace std;
using namespace Json;
namespace ClientConfig{
	//获取时间分组
	const static string PHOTO_TIMELINE_URI = "/photo/timeline";
	//获取按年或月查询的概要照片/photo/general
	const static string PHOTO_GENERAL_URI = "/photo/general";
	//获取按日查询的照片/photo/detail
	const static string  PHOTO_DETAIL_URI= "/photo/detail";
	//获取最新标签/photo/tag/recent
	const static string  PHOTO_TAG_RECENT_URI= "/photo/tag/recent";
	//获取指定文件相关标签/photo/tag/file_tags
	const static string PHOTO_TAG_FILE_TAGS_URI = "/photo/tag/file_tags";
	//根据标签集查询文件列表/photo/tag/tag_files
	const static string PHOTO_TAG_TAG_FILES_URI = "/photo/tag/tag_files";
	//给指定文件集标注指定的标签集/photo/tag/file_add
	const static string  PHOTO_TAG_FILE_ADD_URI = "/photo/tag/file_add";
	//给指定文件集删除指定文件标签集/photo/tag/file_del
	const static string PHOTO_TAG_FILE_DEL_URI = "/photo/tag/file_del";
	//创建标签/photo/tag/create
	const static string PHOTO_TAG_CREATE_URI = "/photo/tag/create";
	//删除标签/photo/tag/del
	const static string PHOTO_TAG_DEL_URI = "/photo/tag/del";
};
#endif