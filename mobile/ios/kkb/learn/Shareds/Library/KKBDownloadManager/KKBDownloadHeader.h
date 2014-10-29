//
//  KKBDownloadHeader.h
//  VideoDownload
//
//  Created by zengmiao on 8/29/14.
//  Copyright (c) 2014 zengmiao. All rights reserved.
//

#ifndef VideoDownload_KKBDownloadHeader_h
#define VideoDownload_KKBDownloadHeader_h

#pragma mark - enum
typedef NS_ENUM(NSInteger, VideoDownloadStatus) {
  videoUnknown = 0,     //未知状态
  videoDownloading,     //正在下载
  videoPause,           //暂停中
  videoDownloadFinish,  //完成状态
  videoDownloadInQueue, //等待状态
  videoDownloadError,   //下载失败
  videoDownloadCancel   //取消状态
};

typedef NS_ENUM(NSInteger, VideoDownloadClassType) {
  videoGuideCourse = 0, //导学课
  videoOpenCourse,      //公开课
};

#pragma mark - notification

#define DOWNLOADVIDEO_CREATE_SUCCESS_NOTIFICATION                              \
  @"downloadVideoCreateSuccessNotification"

#import "KKBDownloadClassModel.h"
#import "KKBDownloadVideoModel.h"
#import "KKBDownloadTaskModel.h"

#import "KKBDownloadClass.h"
#import "KKBDownloadVideo.h"

#endif
