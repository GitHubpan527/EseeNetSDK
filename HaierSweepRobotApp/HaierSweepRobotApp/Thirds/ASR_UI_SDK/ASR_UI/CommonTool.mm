#include "CommonTool.h"

string GetIosDocumentPath(void)
{
	@autoreleasepool
    {
        NSArray *Paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory,NSUserDomainMask,YES);
        NSString *nsPath = [Paths objectAtIndex:0];
        string strRet =  NsStrToString(nsPath);
        return strRet;
    }
}

string NsStrToString(NSString *nsStr)
{
	string strRet("");
	if (nsStr == nil) {
		return strRet;
	}
	strRet = [nsStr UTF8String];
	return strRet;
}

string GetIosResDataPath(NSString *fileName, NSString *fileType)
{
    NSString *nsSoucePath =[[NSBundle mainBundle] pathForResource:fileName ofType:fileType];
	string strSourcePath = NsStrToString(nsSoucePath);
	if ((fileName == nil) && (fileType == nil)) {
		return strSourcePath;
	}
	string strFileName = NsStrToString(fileName);
	string strFileType = NsStrToString(fileType);
	
	if ((fileName != nil) && (fileType == nil)) {
		 strFileName = string("/") + strFileName;
	}else if ((fileName != nil) && (fileType != nil)) {
		strFileName = string("/") + strFileName + string(".") + strFileType;
	}else if ((fileName == nil) && (fileType != nil)) {
		strFileName = string("/");
	}

	size_t unpos = strSourcePath.rfind(strFileName.c_str());
	strSourcePath = strSourcePath.substr(0,unpos);
	return strSourcePath;
}

string GetIosFullResDataPath(NSString *fileName, NSString *fileType)
{
	NSString *nsSoucePath =[[NSBundle mainBundle] pathForResource:fileName ofType:fileType];
	string strSourcePath = NsStrToString(nsSoucePath);
	return strSourcePath;
}
