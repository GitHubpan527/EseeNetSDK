//
//  YFonc.h
//  YFonc
//
//  Created by apple on 16/7/15.
//  Copyright © 2016年 yuanHongQiang. All rights reserved.
//
#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

#ifndef RGBA
#define RGBA(r,g,b,a) [UIColor colorWithRed:r/255.0f green:g/255.0f blue:b/255.0f alpha:a]
#endif
@interface YFonc : NSObject

#pragma mark - 数值类
+(CGSize)gtTextCGSize:(NSString* __nullable)string withTextMaxWidth:(CGFloat)textMaxWidth withFont:(UIFont* __nullable)font;//获取文本的最佳尺寸,布局时经常用到
+(CGSize)gtAttributeTextCGSize:(NSAttributedString* __nullable)string withTextMaxWidth:(CGFloat)textMaxWidth withFont:(UIFont* __nullable)font;//获取多属性文本的尺寸
+(CGSize)gtImageThumbnailSize:(UIImage* __nullable)image maxWidth:(CGFloat)width maxHeight:(CGFloat)heigh;//获取图片缩略图的尺寸
+(NSInteger)gtVersionCompareWithOld:(NSString* __nullable)oldVer withNew:(NSString* __nullable)newVer;//比较两个版本号,更大返回1,相等或者无法比较返回0,更旧返回-1
+(CGFloat)gtItemBestSpaceWithMinSpace:(CGFloat)space withItemWidth:(CGFloat)itw withViewWidth:(CGFloat)width;//获取最佳间距,用于表格格子的平均间距
+(BOOL)gtIsLandscape;//获取当前屏幕是否是横屏

#pragma mark - 文本类
+(NSString* __nullable)gtFileSizeToString:(CGFloat)size;//文件大小单位的转换

#pragma mark - 富文本类
+(NSAttributedString* __nullable)gtTextWithString:(NSString* __nullable)str withColor:(UIColor* __nullable)color withFont:(UIFont* __nullable)font withAlignment:(NSTextAlignment)alig;//获取一个带颜色,大小,对齐的基本富文本

#pragma mark - 颜色类
+(UIColor* __nullable)gtColorWithHexString:(NSString* __nullable)color;//十六进制颜色转换

#pragma mark - 图片类
+(UIImage* __nullable)gtQRImageWithString:(NSString* __nullable)str withColor:(UIColor* __nullable)color withWidth:(CGFloat)width;//得到二维码
+(UIImage* __nullable)gtImageFromColor:(UIColor* __nullable)color;//从颜色转图片
+(UIImage* __nullable)gtSegImageFromImageLeft:(UIImage* __nullable)imageL imageRight:(UIImage* __nullable)imageR size:(CGSize)size;//得到左右比例正确的图片拼接
+(UIImage* __nullable)gtRoundedCornerImageWithCornerRadius:(CGFloat)cornerRadius withImage:(UIImage* __nullable)theImage;//得到圆角图片
+(UIImage* __nullable)gtImageFromLayer:(CALayer* __nullable)layer;//从layer得到图片,可以用作屏幕截图
@end
