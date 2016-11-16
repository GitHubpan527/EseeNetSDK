

#import "NSString+Hashing.h"
#import <CommonCrypto/CommonDigest.h>



@implementation NSString (NSString_Hashing)

- (NSString *)MD5Hash
{
	const char *cStr = [self UTF8String];
	unsigned char result[16];
	CC_MD5(cStr, strlen(cStr), result);
	return [NSString stringWithFormat:
			@"%02X%02X%02X%02X%02X%02X%02X%02X%02X%02X%02X%02X%02X%02X%02X%02X",
			result[0], result[1], result[2], result[3], 
			result[4], result[5], result[6], result[7],
			result[8], result[9], result[10], result[11],
			result[12], result[13], result[14], result[15]].lowercaseString;
}

+ (NSString*)getMD5WithData:(NSData *)data{
    
    const char* original_str = (const char *)[data bytes];
    
    unsigned char digist[CC_MD5_DIGEST_LENGTH]; //CC_MD5_DIGEST_LENGTH = 16
    
    CC_MD5(original_str, strlen(original_str), digist);
    
    NSMutableString* outPutStr = [NSMutableString stringWithCapacity:10];
    
    for(int  i =0; i<CC_MD5_DIGEST_LENGTH;i++){
        
        [outPutStr appendFormat:@"%02x",digist[i]];//小写x表示输出的是小写MD5，大写X表示输出的是大写MD5
        
    }
    
    //也可以定义一个字节数组来接收计算得到的MD5值
    
        Byte byte[16];
    
        CC_MD5(original_str, strlen(original_str), byte);
    
          outPutStr = [NSMutableString stringWithCapacity:10];
    
        for(int  i = 0; i<CC_MD5_DIGEST_LENGTH;i++){
    
            [outPutStr appendFormat:@"%02x",byte[i]];
    
        }
    
    //    [temp release];

    return [outPutStr lowercaseString];
}
@end
