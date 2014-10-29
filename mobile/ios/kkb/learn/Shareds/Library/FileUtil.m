//
//  FileUtil.m
//  learn
//
//  Created by User on 14-2-17.
//  Copyright (c) 2014年 kaikeba. All rights reserved.
//

#import "FileUtil.h"

@implementation FileUtil

+(NSString*)getDocumentPath{
    return [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) objectAtIndex:0];
}
//FIXME 这里dir没有使用，稍后检查
+(NSString*)getDocumentFilePathWithFile:(NSString*)fileName dir:(NSString*)dir ,...NS_REQUIRES_NIL_TERMINATION{
    NSString* path=[self getDocumentPath];
    id arg;
    va_list argList;
    if(dir)
    {
        va_start(argList,dir);
        while ((arg = va_arg(argList,id)))
        {
            path=[path stringByAppendingPathComponent:((NSString*)arg)];
        }
        va_end(argList);
    }
    [self createFileAtPath:path];
    path=[path stringByAppendingPathComponent:fileName];
    return path;
}
+(BOOL)createDocumentDirAtPath:(NSString*)dir,...NS_REQUIRES_NIL_TERMINATION{
    NSString* path=[self getDocumentPath];
    id arg;
    va_list argList;
    if(dir)
    {
        va_start(argList,dir);
        while ((arg = va_arg(argList,id)))
        {
            path=[path stringByAppendingPathComponent:((NSString*)arg)];
        }
        va_end(argList);
    }
    return [self createFileAtPath:path];
}
+(BOOL) createFileAtPath:(NSString*)path{
    NSFileManager* fm = [NSFileManager defaultManager];
    NSError * error=nil;
    if(![fm fileExistsAtPath:path]){
        [fm createDirectoryAtPath:path withIntermediateDirectories:YES attributes:nil error:&error];
    }
    if(error){
        NSLog(@"createDocumentDirAtPath Error !!!!---%@",[error localizedDescription]);
        return NO;
    }else{
        return YES;
    }
    
}

+ (BOOL)removeFileAtPath:(NSString*)filePath
{
    NSFileManager* fm = [NSFileManager defaultManager];
    if([fm fileExistsAtPath:filePath]){
        return [fm removeItemAtPath:filePath error:NULL];
    } else {
        return NO;
    }
}
@end

