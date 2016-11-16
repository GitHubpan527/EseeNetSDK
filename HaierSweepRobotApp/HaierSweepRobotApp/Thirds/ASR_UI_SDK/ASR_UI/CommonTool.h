#ifndef __common_tool_header__
#define __common_tool_header__

#include <string>
using std::string;

string GetIosDocumentPath(void);

string NsStrToString(NSString *nsStr);

//获取不带有文件名的文件路径
string GetIosResDataPath(NSString*fileName,NSString*fileType);

//获取带有文件名的全路径
string GetIosFullResDataPath(NSString *fileName, NSString *fileType);

#endif

