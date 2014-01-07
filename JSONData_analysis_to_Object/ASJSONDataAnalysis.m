//
//  ASJSONDataAnalysis.m
//  Octopus_iOS_project1
//
//  Created by lx on 14-1-2.
//  Copyright (c) 2014年 Talon. All rights reserved.
//

#import "ASJSONDataAnalysis.h"
#import <objc/message.h>
#import "ASJSONDataAnalysisProtocol.h"

#define FORMAT_STRING @"yyyy-MM-dd HH:mm:ss"

@implementation ASJSONDataAnalysis
-(id)returnTheObject:(NSString *)ObjectName FromJSONDic:(NSDictionary *)JSONDic
{
    id returnData=nil;
    @try {
        @autoreleasepool {
            returnData=[self analysisJSONDic:JSONDic ToObject:ObjectName];
        }
    }
    @catch (NSException *exception) {
        NSLog(@"ASJSONDataAnalysis Error");
    }
    @finally {
        return returnData;
    }
}

-(id)analysisJSONDic:(NSDictionary *)JSONDic ToObject:(NSString *)ObjectName
{
    //符合协议
    NSArray *originClassArray=[NSArray arrayWithObjects:@"NSString",@"NSNumber",@"NSURL",@"NSDate",@"NSArray",nil];
    
    NSArray *objectPorpertyArray=[self getPerpotyArrayFromClass:ObjectName];
    if (!objectPorpertyArray)
    {
        //没有获得属性类型数组
        NSLog(@"can not found the object name");
        return nil;
    }
    
    Class GoalObjectClass=NSClassFromString(ObjectName);//用来检测是否符合协议
    if (![GoalObjectClass conformsToProtocol:@protocol(ASJSONDataAnalysisProtocol)])
    {
        //不符合协议
        NSLog(@"className=%@ not conform the property",ObjectName);
        return nil;
    }
    id <ASJSONDataAnalysisProtocol> goalClassObject=[[GoalObjectClass alloc] init];
    
    for (NSDictionary *porpertyDic in objectPorpertyArray)
    {
        
        NSString *propertyName=[porpertyDic objectForKey:@"perportyName"];
        NSString *propertyAttribute=[porpertyDic objectForKey:@"perportyAttribute"];
        NSString *jsonKeyName=[goalClassObject getJSONDataKeyFromPropertyName:propertyName];
        if (!jsonKeyName) {
            //没有得到JSON的KeyName
            continue;
        }
        int indexInArray=[self containString:propertyAttribute InArray:originClassArray];
        id setValue;
        if (indexInArray>=0)
        {

            //原生类型
            switch (indexInArray)
            {
                case 0:
                {
                    //NSString
                    if ([self containString:jsonKeyName InArray:[JSONDic allKeys]]>=0) {
                        setValue=[JSONDic objectForKey:jsonKeyName];
                    }
                    else
                    {
                        //JSON字典中无此数据
                        setValue=@"";
                    }

                }
                    break;
                case 1:
                {
                    //NSNumber
                    if ([self containString:jsonKeyName InArray:[JSONDic allKeys]]>=0) {
                        setValue=[JSONDic objectForKey:jsonKeyName];
                    }
                    else
                    {
                        //JSON字典中无此数据
                        setValue=[NSNumber numberWithInt:0];
                    }

                }
                    break;
                case 2:
                {
                    //NSURL
                    if ([self containString:jsonKeyName InArray:[JSONDic allKeys]]>=0) {
                        setValue=[NSURL URLWithString:[JSONDic objectForKey:jsonKeyName]];
                    }
                    else
                    {
                        //JSON字典中无此数据
                        setValue=[NSURL URLWithString:@""];
                    }

                }
                    break;
                case 3:
                {
                    //NSDate
                    if ([self containString:jsonKeyName InArray:[JSONDic allKeys]]>=0) {
                        setValue=[self getTheDateFromJSONDateStr:[JSONDic objectForKey:jsonKeyName]];
                    }
                    else
                    {
                        //JSON字典中无此数据
                        setValue=nil;
                    }

                }
                    break;
                case 4:
                {
                    //NSArray
                    if ([self containString:jsonKeyName InArray:[JSONDic allKeys]]>=0) {
                        NSString *arrayPropertyAttribute=[goalClassObject getSelfArrayObjectAttributes:propertyName];
                        setValue=[self analysisJSONArray:[JSONDic objectForKey:jsonKeyName] ToObjectName:arrayPropertyAttribute];
                    }
                    else
                    {
                        //JSON字典中无此数据
                        setValue=nil;
                    }


                }
                    break;
                    
                default:
                    break;
            }
        }
        else
        {
            //自定义类型
            if ([self containString:jsonKeyName InArray:[JSONDic allKeys]]>=0) {
                setValue=[self analysisJSONDic:[JSONDic objectForKey:propertyName] ToObject:propertyAttribute];
            }
            else
            {
                //JSON字典中无此数据
                setValue=nil;
            }

        }
        if (setValue) {
            [(id) goalClassObject setValue:setValue forKey:propertyName];
        }
        else
        {
            //没有解析到数据不操作
            NSLog(@"className=%@,propertyName=%@ not get the value",ObjectName,propertyName);
            continue;
        }
    }
    return goalClassObject;
}
-(NSArray *)getPerpotyArrayFromClass:(NSString *)ClassName
{
    NSString *className = ClassName;
    const char *char_className = [className UTF8String];
    
    id goalClass = objc_getClass(char_className);
    if (!goalClass)
    {
        //没有找到目标类型
        return nil;
    }
    Class goalClassObject=NSClassFromString(className);
    if (!goalClassObject)
    {
        //没有生成类实例
        return nil;
    }
    NSMutableArray *classPropertyArray=[[NSMutableArray alloc] init];
    unsigned int outCount, i;
    objc_property_t *properties = class_copyPropertyList(goalClassObject, &outCount);
    for (i = 0; i < outCount; i++)
    {
        objc_property_t property = properties[i];
        NSString *propName = [NSString stringWithUTF8String:property_getName(property)];
        NSString *attributes = [NSString stringWithUTF8String:property_getAttributes(property)];
        if ([[attributes substringWithRange:NSMakeRange(0, 3)] isEqualToString:@"T@\""])
        {
            NSArray *getArray=[attributes componentsSeparatedByString:@"\""];
            NSString *propertyClassName=[getArray objectAtIndex:1];
            [classPropertyArray addObject:[NSDictionary dictionaryWithObjectsAndKeys:propName,@"perportyName",propertyClassName,@"perportyAttribute", nil]];
        }
        else
        {
            //not recognition property
            continue;
        }
    }
    if ([classPropertyArray count]>0)
    {
        return [classPropertyArray copy];
    }
    else
    {
        return nil;
    }
}
-(int)containString:(NSString *)String InArray:(NSArray *)Array
{
    if (!Array)
    {
        //Array is nil
        return -1;
    }
    int count =[Array count];
    if (count<1)
    {
        //Array no object
        return -1;
    }
    for (int i=0; i<count; i++)
    {
        if ([[Array objectAtIndex:i] isEqualToString:String])
        {
            return i;
        }
    }
    //not found
    return -1;
}
-(NSArray *)analysisJSONArray:(NSArray *)JSONArray ToObjectName:(NSString *)ObjectName
{
    NSMutableArray *getResultArray=[[NSMutableArray alloc] init];
    for (NSDictionary *dic in JSONArray)
    {
        //获得数组内变量类型
        id returnObject=[self analysisJSONDic:dic ToObject:ObjectName];
        if (returnObject)
        {
            [getResultArray addObject:returnObject];
        }
    }
    if (getResultArray>0)
    {
        return getResultArray;
    }
    return nil;
    
}
-(NSDate *)getTheDateFromJSONDateStr:(NSString *)JSONDateStr
{
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat:FORMAT_STRING];
    NSDate *getDate=[dateFormatter dateFromString:[JSONDateStr description]];
    return getDate;
    
}

@end
