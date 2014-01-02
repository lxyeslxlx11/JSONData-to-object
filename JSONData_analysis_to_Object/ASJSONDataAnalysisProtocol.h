//
//  ASJSONDataAnalysisProtocol.h
//  Octopus_iOS_project1
//
//  Created by lx on 14-1-2.
//  Copyright (c) 2014年 rockmobile. All rights reserved.
//

#import <Foundation/Foundation.h>

@protocol ASJSONDataAnalysisProtocol <NSObject>
@required
///获得属性与json中key的对应关系
-(NSString *)getJSONDataKeyFromPropertyName:(NSString *)PropertyName;
///获得实例中数组内的变量类型
-(NSString *)getSelfArrayObjectAttributes:(NSString *)PropertyName;
@end
