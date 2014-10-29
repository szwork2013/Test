//
//  KKBDownloadDeleteBtn.h
//  VideoDownload
//
//  Created by zengmiao on 9/9/14.
//  Copyright (c) 2014 zengmiao. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface KKBDownloadDeleteBtn : UIButton

@property (nonatomic, assign) NSUInteger selectedDeleteCount;//已经选择了数量 用于删除按钮

@property (nonatomic, assign) NSUInteger selectedDownloadCount;//已选择数量 用于选择加入下载按钮

/**
 *  计算用
 */
@property (nonatomic, assign) NSUInteger counter;
@property (nonatomic, assign) NSUInteger maxCount;
- (BOOL)allowSelected; //是否允许继续选择

@end
