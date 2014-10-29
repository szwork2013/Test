//
//  GuideDownLoadSubModel.h
//  learn
//
//  Created by zxj on 14-8-9.
//  Copyright (c) 2014年 kaikeba. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface GuideDownLoadSubModel : NSObject

@property(nonatomic, copy) NSString *title;
@property(nonatomic, copy) NSString *type;
@property(nonatomic, copy) NSString *html_url;

@property(nonatomic, copy) NSString *url;
@property(nonatomic, copy) NSString *itemImage;

@property(nonatomic, assign) BOOL isSelected;
@end
