//
//  GlobalOperator.h
//  learn
//
//  Created by User on 13-5-21.
//  Copyright (c) 2013年 kaikeba. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "GlobalDefine.h"
#import "UserItem.h"

@interface GlobalOperator : NSObject
{
    
}

@property (nonatomic, retain) User4Request *user4Request;
@property (nonatomic, copy) NSString *userId;
@property (nonatomic, assign) BOOL isLogin;
@property (nonatomic, assign) BOOL isLandscape;

+ (GlobalOperator *)sharedInstance;//单例模式

//根据单个KAIKEBA_MODULE_TYPE类型来获得某一个操作实例
- (id)getOperatorWithModuleType:(KAIKEBA_MODULE_TYPE)type;


@end
