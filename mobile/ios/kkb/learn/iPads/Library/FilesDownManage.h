//
//  FilesDownManage.h
//  learn
//
//  Created by User on 14-2-27.
//  Copyright (c) 2014年 kaikeba. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "ASIHTTPRequest.h"
#import "ASINetworkQueue.h"
#import "CommonHelper.h"
#import "DownloadDelegate.h"
#import "FileModel.h"

//#import "DownloadCell.h"
#import <AVFoundation/AVAudioPlayer.h>
@interface FilesDownManage : NSObject<ASIHTTPRequestDelegate,ASIProgressDelegate, UIAlertViewDelegate>
{
    NSInteger type;
    NSInteger  maxcount;
    int count;
    
}
@property(nonatomic,retain)UIImage *fileImage;
@property (nonatomic,assign)BOOL downManageFirstLoad;
@property int count;
@property(nonatomic,retain)id<DownloadDelegate> VCdelegate;//获得下载事件的vc，用在比如多选图片后批量下载的情况，这时需配合 allowNextRequest 协议方法使用
@property(nonatomic,retain)id<DownloadDelegate> downloadDelegate;//下载列表delegate

@property(nonatomic,retain)NSString *TargetSubPath;
@property(nonatomic,retain)NSMutableArray *finishedlist;//已下载完成的文件列表（文件对象）

@property(nonatomic,retain)NSMutableArray *downinglist;//正在下载的文件列表(ASIHttpRequest对象)
@property(nonatomic,retain)NSMutableArray *filelist;
@property(nonatomic,retain)NSMutableArray *targetPathArray;

@property(nonatomic,retain)AVAudioPlayer *buttonSound;//按钮声音

@property(nonatomic,retain)AVAudioPlayer *downloadCompleteSound;//下载完成的声音
@property(nonatomic,retain)FileModel *fileInfo;
@property(nonatomic)BOOL isFistLoadSound;//是否第一次加载声音，静音
//-(void)limitMaxLines;
//-(void)limitMaxCount;
//-(void)reload:(FileModel *)fileInfo;




-(void)clearAllRquests;
-(void)clearAllFinished;
-(void)resumeRequest:(ASIHTTPRequest *)request;
-(void)deleteRequest:(ASIHTTPRequest *)request;
-(void)stopRequest:(ASIHTTPRequest *)request;
-(void)saveFinishedFile;
- (void)deleteFileModel:(FileModel*)fileInfo;
-(void)deleteFinishFile:(FileModel *)selectFile;
-(void)downFileUrl:(NSString*)url
          filename:(NSString*)name
        filetarget:(NSString *)path
         fileimage:(NSString *)image
         fileTitle:(NSString *)title
          courseID:(NSString *)courseId
            fileId:(NSString *) fileId
         showAlert:(BOOL)showAlert;
-(void)loadDownloadingFiles;//将本地的未下载完成的临时文件加载到正在下载列表里,但是不接着开始下载
-(void)loadFinishedfiles;//将本地已经下载完成的文件加载到已下载列表里
-(void)playButtonSound;//播放按钮按下时的声音
-(void)playDownloadSound;//播放下载完成时的声音
- (BOOL) isVideoDownloading:(NSString *) courseId userId:(NSString *) userId moduleId:(NSString *) moduleId videoId:(NSString *) videoId;
- (BOOL) isVideoExisted:(NSString *) courseId userId:(NSString *) userId moduleId:(NSString *) moduleId videoId:(NSString *) videoId;
- (NSString *) getVideoPath:(NSString *) courseId userId:(NSString *) userId moduleId:(NSString *) moduleId videoId:(NSString *) videoId;
- (FileModel *) getTargetVideoFileModel:(NSString *) path;
- (NSString *) getTempFile:(NSString *) courseId userId:(NSString *) userId moduleId:(NSString *) moduleId videoId:(NSString *) videoId;
- (ASIHTTPRequest *) getRequestByVideoUrl:(NSString*)videoName;
//-(UIImage *)getImage:(FileModel *)fileinfo;
//-(id)initWithBasepath:(NSString *)basepath;
//+(FilesDownManage *) sharedFilesDownManageWithBasepath:(NSString *)basepath;
+(FilesDownManage *) sharedInstance;
//＊＊＊第一次＊＊＊初始化是使用，设置缓存文件夹和已下载文件夹，构建下载列表和已下载文件列表时使用
+(FilesDownManage *) sharedFilesDownManageWithBasepath:(NSString *)basepath
                                         TargetPathArr:(NSArray *)targetpaths;
//1.点击百度或者土豆的下载，进行一次新的队列请求
//2.是否接着开始下载
-(void)beginRequest:(FileModel *)fileInfo isBeginDown:(BOOL)isBeginDown ;
-(void)startLoad;
-(void)restartAllRquests;
-(void)restartRequest:(ASIHTTPRequest *) request;

-(NSArray *)sortbyTime:(NSArray *)array;
- (int) getNumberOfDownloadingTask:(NSString *) courseId;
- (int) getNumberOfFinishedTask:(NSString *) courseId;
- (int) getNumberOfTask:(NSString *) courseId;

- (NSDictionary *) getDownloadInfoByCourses;

@end

