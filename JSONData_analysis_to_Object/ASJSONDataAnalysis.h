//
//  ASJSONDataAnalysis.h
//  Octopus_iOS_project1
//
//  Created by lx on 14-1-2.
//  Copyright (c) 2014年 Talon. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface ASJSONDataAnalysis : NSObject

///分析JSON字典生成对象实例
-(id)returnTheObject:(NSString *)ObjectName FromJSONDic:(NSDictionary *)JSONDic;

-(id)analysisJSONDic:(NSDictionary *)JSONDic ToObject:(NSString *)ObjectName;

@end
