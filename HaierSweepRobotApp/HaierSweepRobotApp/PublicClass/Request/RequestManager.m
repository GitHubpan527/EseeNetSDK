//
//  RequestManager.m
//  HaierSweepRobotApp
//
//  Created by Ljp on 16/7/5.
//  Copyright © 2016年 LC-World. All rights reserved.
//

#import "RequestManager.h"

#import "LoginUserModel.h"
#import "LoginUserDefaults.h"

static RequestManager *requestManager = nil;

@implementation RequestManager

//单例
+ (RequestManager *)shareRequestManager
{
    @synchronized(self) {
        if (!requestManager) {
            requestManager = [[RequestManager alloc] init];
        }
        return requestManager;
    }
}

//数据请求
- (void)requestDataType:(RequestType)requestType urlStr:(NSString *)urlStr parameters:(NSDictionary *)parameters successBlock:(SuccessBlock)successBlock FailBlock:(FailBlock)failBlock
{
    AFHTTPSessionManager *sessionManager = [[AFHTTPSessionManager alloc] init];
    sessionManager.requestSerializer = [AFHTTPRequestSerializer serializer];
    sessionManager.responseSerializer = [AFHTTPResponseSerializer serializer];
    [sessionManager.requestSerializer setValue:[[self getauth] JSONString] forHTTPHeaderField:@"auth"];
    NSString *url = [NSString stringWithFormat:@"%@%@",OFFICALIP,urlStr];

    //网络监测、请求
    Reachability *r = [Reachability reachabilityWithHostName:@"www.baidu.com"];
    if ([r currentReachabilityStatus] != NotReachable) {
        //[sessionManager.requestSerializer setValue:@"application/json; charset=utf-8" forHTTPHeaderField:@"Content-Type"];
        //sessionManager.responseSerializer.acceptableContentTypes = [NSSet setWithObject:@"text/html"];
        
        if (requestType == RequestTypePOST) {
            [sessionManager POST:url parameters:parameters progress:^(NSProgress * _Nonnull uploadProgress) {
                // 这里可以获取到目前的数据请求的进度
            } success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
                NSDictionary *getDic = [NSJSONSerialization JSONObjectWithData:responseObject options:NSJSONReadingMutableContainers | NSJSONReadingMutableLeaves error:nil];
                NSLog(@"success--url:%@ dic:%@",url,getDic);
                if (successBlock) {
                    successBlock(getDic);
                }
            } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
                if (failBlock) {
                    failBlock(error);
                }
            }];
        } else {
            [sessionManager GET:url parameters:parameters progress:^(NSProgress * _Nonnull downloadProgress) {
                // 这里可以获取到目前的数据请求的进度
            } success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
                NSDictionary *getDic = [NSJSONSerialization JSONObjectWithData:responseObject options:NSJSONReadingMutableContainers | NSJSONReadingMutableLeaves error:nil];
                NSLog(@"success:%@",getDic);
                if (successBlock) {
                    successBlock(getDic);
                }
            } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
                if (failBlock) {
                    failBlock(error);
                }
            }];
        }
    }
    else {
        if (failBlock) {
            failBlock(@"没有网络");
        }
    }
}

//上传图片
- (void)uploadImagesWithDic:(NSDictionary *)infoDic shortURL:(NSString *)urlStr imagesArray:(NSArray *)imagesArray imageName:(NSString *)name successBlock:(SuccessBlock)successBlock FailBlock:(FailBlock)failBlock
{
    AFHTTPSessionManager *sessionManager = [[AFHTTPSessionManager alloc] init];
    sessionManager.requestSerializer = [AFHTTPRequestSerializer serializer];
    sessionManager.responseSerializer = [AFHTTPResponseSerializer serializer];
    [sessionManager.requestSerializer setValue:[[self getauth] JSONString] forHTTPHeaderField:@"auth"];
    NSString *url = [NSString stringWithFormat:@"%@%@",OFFICALIP,urlStr];
    
    //网络监测、请求
    Reachability *r = [Reachability reachabilityWithHostName:@"www.baidu.com"];
    if ([r currentReachabilityStatus] != NotReachable) {
        [sessionManager POST:url parameters:infoDic constructingBodyWithBlock:^(id<AFMultipartFormData>  _Nonnull formData) {
            for (int i = 0; i < imagesArray.count; i++) {
                UIImage *image = imagesArray[i];
                [formData appendPartWithFileData:[self compactImage:image] name:name fileName:[NSString stringWithFormat:@"image%@.jpg",[self timeStamp]] mimeType:@"Multipart/form-data"];
            }
        } progress:^(NSProgress * _Nonnull uploadProgress) {
            NSLog(@"上传进度");
        } success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
            NSDictionary *getDic = [NSJSONSerialization JSONObjectWithData:responseObject options:NSJSONReadingMutableContainers | NSJSONReadingMutableLeaves error:nil];
            NSLog(@"success:%@",getDic);
            if (successBlock) {
                successBlock(getDic);
            }
        } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
            if (failBlock) {
                failBlock(error);
            }
        }];
    }
    else {
        if (failBlock) {
            failBlock(@"没有网络");
        }
    }
}

/*图片压缩*/
static float scale = 1.0;
- (NSData *)compactImage:(UIImage *)image
{
    NSData * resultData= nil;
    NSData * data = UIImageJPEGRepresentation(image, scale);
    resultData = data;
    while (resultData.length > 1024 * 100 && scale > 0.1) {
        scale -= 0.05;
        UIImage * newImage = [UIImage imageWithData:data];
        NSData * newData = UIImageJPEGRepresentation(newImage, scale);
        resultData = newData;
    }
    
    return resultData;
}

//时间戳
- (NSString *)timeStamp
{
    NSString *timeSp = [NSString stringWithFormat:@"%ld", (long)[[NSDate date] timeIntervalSince1970]];
    NSLog(@"timeSp:%@",timeSp); //时间戳的值
    return timeSp;
}

//auth请求头
-(NSDictionary *)getauth
{
    LoginUserModel *userModel = [LoginUserDefaults getLoginUserModelForKey:[LoginUserDefaults getLoginUserModelKey]];
    if (!userModel) {
        userModel.token = @"";
    }
    NSDictionary *dic = @{@"imei":[[[UIDevice currentDevice].identifierForVendor UUIDString]stringByReplacingOccurrencesOfString:@"-" withString:@""],
                          @"devicelmodel": @"iphone",
                          @"os": [UIDevice currentDevice].systemName,
                          @"os_version": [UIDevice currentDevice].systemVersion,
                          @"app_version": [[NSBundle mainBundle]infoDictionary][@"CFBundleShortVersionString"],
                          @"timestamp": [self timeStamp],
                          @"token": userModel ? userModel.token : @"",
                          @"sign": [NSString lc_md5String:[NSString stringWithFormat:@"%@%@",[self timeStamp],userModel.token]]};
    return dic;
}

@end
