//
//  DownloadDelegate.h
//  learn
//
//  Created by User on 14-2-27.
//  Copyright (c) 2014年 kaikeba. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "ASIHTTPRequest.h"

@protocol DownloadDelegate <NSObject>

@optional
-(void)startDownload:(ASIHTTPRequest *)request;
-(void)updateCellProgress:(ASIHTTPRequest *)request;
-(void)finishedDownload:(ASIHTTPRequest *)request;
-(void)allowNextRequest;//处理一个窗口内连续下载多个文件且重复下载的情况

@required
- (void)updateNumbersOfDownloading:(NSDictionary *)numbersByCourse;

@end

