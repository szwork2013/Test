//
//  KKBJSONSerialBaseModel.h
//  learn
//  所有需要使用ORM的Model继承次BaseModel

//  Created by zengmiao on 10/13/14.
//  Copyright (c) 2014 kaikeba. All rights reserved.
//

#import "MTLModel.h"
#import "Mantle.h"

@interface KKBJSONSerialBaseModel : MTLModel <MTLJSONSerializing>

@end
