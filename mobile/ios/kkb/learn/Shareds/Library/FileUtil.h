//
//  FileUtil.h
//  learn
//
//  Created by User on 14-2-17.
//  Copyright (c) 2014年 kaikeba. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface FileUtil : NSObject
+(NSString*)getDocumentPath;
+(NSString*)getDocumentFilePathWithFile:(NSString*)fileName dir:(NSString*)dir ,...NS_REQUIRES_NIL_TERMINATION;
+ (BOOL)removeFileAtPath:(NSString*)filePath;
@end
