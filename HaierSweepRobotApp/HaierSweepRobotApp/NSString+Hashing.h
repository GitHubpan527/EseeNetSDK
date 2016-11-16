
#pragma mark - MD5 base64加密算法
#import <Foundation/Foundation.h>
@interface NSString (NSString_Hashing)

- (NSString *)MD5Hash;
/******************************************************************************
 函数名称 : + (NSString *)base64StringFromText:(NSString *)text
 函数描述 : 将文本转换为base64格式字符串
 输入参数 : (NSString *)text    文本
 输出参数 : N/A
 返回参数 : (NSString *)    base64格式字符串
 备注信息 :
 ******************************************************************************/
+ (NSString *)base64StringFromText:(NSString *)text;

/******************************************************************************
 函数名称 : + (NSString *)textFromBase64String:(NSString *)base64
 函数描述 : 将base64格式字符串转换为文本
 输入参数 : (NSString *)base64  base64格式字符串
 输出参数 : N/A
 返回参数 : (NSString *)    文本
 备注信息 :
 ******************************************************************************/
+ (NSString *)textFromBase64String:(NSString *)base64;

+(NSString*)getMD5WithData:(NSData*)data;


//计算字符串的MD5值，

+(NSString*)getmd5WithString:(NSString*)string;


//计算大文件的MD5值

+(NSString*)getFileMD5WithPath:(NSString*)path;
@end
