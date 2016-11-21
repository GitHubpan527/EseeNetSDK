//
//  RequestManager.h
//  HaierSweepRobotApp
//
//  Created by Ljp on 16/7/5.
//  Copyright © 2016年 LC-World. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef void(^SuccessBlock)(id successObject);
typedef void(^FailBlock)(id failObject);

typedef NS_ENUM(NSInteger, RequestType) {
    RequestTypePOST,
    RequestTypeGET
};

@interface RequestManager : NSObject

//单例
+ (RequestManager *)shareRequestManager;

//数据请求
- (void)requestDataType:(RequestType)type urlStr:(NSString *)urlStr parameters:(NSDictionary *)parameters successBlock:(SuccessBlock)successBlock FailBlock:(FailBlock)failBlock;

//上传图片
- (void)uploadImagesWithDic:(NSDictionary *)infoDic shortURL:(NSString *)urlStr imagesArray:(NSArray *)imagesArray imageName:(NSString *)name successBlock:(SuccessBlock)successBlock FailBlock:(FailBlock)failBlock;

@end
