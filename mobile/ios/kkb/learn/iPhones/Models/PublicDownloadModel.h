//
//  PublicDownloadModel.h
//  learn
//
//  Created by 翟鹏程 on 14-8-1.
//  Copyright (c) 2014年 kaikeba. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface PublicDownloadModel : NSObject

@property(nonatomic, copy) NSString *itemImage;
@property(nonatomic, copy) NSString *itemTitle;
@property(nonatomic, assign) BOOL isSelected;

@end
