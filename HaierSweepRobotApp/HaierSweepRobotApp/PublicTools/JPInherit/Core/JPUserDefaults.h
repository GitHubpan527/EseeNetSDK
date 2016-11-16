//
//  JPUserDefaults.h
//  JPInherit
//
//  Created by Ljp on 16/8/25.
//  Copyright © 2016年 LC-World. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface JPUserDefaults : NSUserDefaults

+ (void)jp_setObject:(id)object forKey:(NSString *)key;
+ (id)jp_objectForKey:(NSString *)key;

@end
