//
//  KKBDownloadManager.m
//  VideoDownload
//
//  Created by zengmiao on 8/29/14.
//  Copyright (c) 2014 zengmiao. All rights reserved.
//

#import "KKBDownloadManager.h"
#import "AFDownloadRequestOperation.h"
#import "KKBDownloadStorage.h"
#import "KKBDownloadModelFactory.h"
#import <CommonCrypto/CommonDigest.h>
#import "AFNetworkActivityIndicatorManager.h"
#import "KKBDownloadMonitor.h"
#import "KKBVideoSubtitleManager.h"

#ifdef DOWNLOADN_DEBUG
static const int ddLogLevel = LOG_LEVEL_VERBOSE;
#else
static const int ddLogLevel = LOG_LEVEL_OFF;
#endif

#define DownloadManager [KKBDownloadManager sharedInstacne]

static const float maxConcurrentOperationCount = 1;
static NSString *const alertMessage = @"您当前处于非WiFi环境，下载"
    @"可能产生额外的流量费用";

@interface KKBDownloadManager () <KKBDownloadMonitorDelegate>

@property(nonatomic, copy) NSString *downloadPath;

@property(strong, nonatomic) KKBDownloadMonitor *downloadMointor;

+ (instancetype)sharedInstacne;

@end

@implementation KKBDownloadManager

#pragma mark - static download control
+ (void)setUpDownloadManager {
    [KKBDownloadManager sharedInstacne];
}

+ (NSString *)videoDownbloadPath {
    KKBDownloadManager *manager = DownloadManager;
    return manager.downloadPath;
}

+ (instancetype)sharedInstacne {

    static KKBDownloadManager *instacne = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{ instacne = [[self alloc] init]; });
    return instacne;
}

+ (BOOL)countInQueue {
    return DownloadManager.operationQueue.operationCount;
}

+ (void)pauseAllDownloadingTaskInQueue {
    KKBDownloadManager *aDownloadManager = DownloadManager;
    [aDownloadManager internalPauseAllTaskInCurrentQueue];
}

+ (void)startDownloadWithItems:(NSArray *)items {
    NSAssert([items count] > 0, @"error!!startDownloadWithItems = 0");

    KKBDownloadManager *aDownloadManager = DownloadManager;

    if (aDownloadManager.downloadMointor.reachabilityManager.reachable) {

        if (aDownloadManager.downloadMointor.reachabilityManager
                .isReachableViaWiFi) {
            [[self class] interStartDownloadWithItems:items];

        } else {
            // Via 3G
            [UIAlertView alertViewWithTitle:@"提示"
                message:alertMessage
                cancelButtonTitle:@"取消下载"
                otherButtonTitles:@[ @"继续下载" ]
                onDismiss:^(int buttonIndex) {
                    if (buttonIndex == 0) {
                        [[self class] interStartDownloadWithItems:items];
                    }
                }
                onCancel:^{}];
        }

    } else {
        //网络连接失败
        [UIAlertView
            alertViewWithTitle:@"提示"
                       message:@"无网络连接 !请检查网络设置"];
    }
}

+ (void)interStartDownloadWithItems:(NSArray *)items {
    for (KKBDownloadTaskModel *task in items) {
        //判断URL是不是为null （接口有可能未返回URL）
        if (!task.videoModel.videoURL ||
            ![task.videoModel.videoURL isKindOfClass:[NSString class]]) {
            DDLogError(@"task 中 URL错误:%@", task.videoModel.videoTitle);
            break;
        }

        AFDownloadRequestOperation *operation =
            [DownloadManager operationInQueueWithURL:task.videoModel.videoURL];
        if (operation) {
            DDLogError(
                @"interStartDownloadWithItems失败，%@ 已经在当前的queue中",
                [task description]);
        } else {

            // TODO: byzm cache subtitle
            [KKBVideoSubtitleManager
                cachesSubtitleWithClassID:task.classModel.classID
                               andVideoID:task.videoModel.videoID];

            [KKBDownloadStorage createTaskWithClass:task.classModel
                                              video:task.videoModel];
        }
    }
}

+ (void)pauseDownloadWithItems:(NSArray *)items {
    NSAssert([items count] > 0, @"error!pauseDownloadWithItems = 0");

    for (KKBDownloadVideoModel *task in items) {
        [DownloadManager pauseDownloadWithItem:task];
    }
}

+ (void)resumeDownloadWithItems:(NSArray *)items
                allowAlertVia3G:(BOOL)alertVia3G {
    NSAssert([items count] > 0, @"error!resumeDownloadWithItems = 0");

    KKBDownloadManager *aDownloadManager = DownloadManager;
    if (aDownloadManager.downloadMointor.reachabilityManager.reachable) {

        if (aDownloadManager.downloadMointor.reachabilityManager
                .isReachableViaWiFi ||
            !alertVia3G) {
            [[self class] interResumeDownloadWithItems:items];
        } else {
            // Via 3G

            [UIAlertView alertViewWithTitle:@"提示"
                message:alertMessage
                cancelButtonTitle:@"取消下载"
                otherButtonTitles:@[ @"继续下载" ]
                onDismiss:^(int buttonIndex) {
                    if (buttonIndex == 0) {
                        [[self class] interResumeDownloadWithItems:items];
                    }
                }
                onCancel:^{}];
        }

    } else {
        //网络连接失败
        [UIAlertView
            alertViewWithTitle:@"提示"
                       message:@"无网络连接 !请检查网络设置"];
    }
}

+ (void)resumeDownloadWithItems:(NSArray *)items {
    [[self class] resumeDownloadWithItems:items allowAlertVia3G:YES];
}

+ (void)interResumeDownloadWithItems:(NSArray *)items {
    KKBDownloadManager *aDownloadManager = DownloadManager;
    for (KKBDownloadVideoModel *task in items) {
        if (task.status != videoDownloadFinish) {
            [aDownloadManager resumeDownloadWithItem:task];
        }
    }
}
/**
 *  删除下载任务
 *
 *  @param items 为KKBDownloadVideoModel集合
 */
+ (void)deleteDownloadWithItems:(NSArray *)items {
    NSAssert([items count] > 0, @"error!cancelDownloadWithItems = 0");
    for (KKBDownloadVideoModel *task in items) {
        [DownloadManager deleteDownloadWithItem:task];
    }
}

#pragma mark -
- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (instancetype)init {
    self = [super init];
    if (self) {
        [[AFNetworkActivityIndicatorManager sharedManager] setEnabled:YES];

        self.responseSerializer = [AFHTTPResponseSerializer serializer];

        self.downloadMointor =
            [[KKBDownloadMonitor alloc] initWithDelegate:self];
        [self.operationQueue
            setMaxConcurrentOperationCount:maxConcurrentOperationCount];

        [KKBDownloadStorage sharedInstacne];

        [self addNotificationObserver];
    }
    return self;
}

#pragma mark - internal Mehtod
- (void)internalPauseAllTaskInCurrentQueue
    __deprecated_msg("iOS8中如果网络失败队列任务会先失败然后才检测到网络失败") {
    NSArray *allTaskModels = [self allAddedVideoTaskInCurrentQueue];
    if ([allTaskModels count] == 0) {
        DDLogWarn(
            @"!!!internalPauseAllTaskInCurrentQueue 没有从数据库中查询到model");
        return;
    }
    [KKBDownloadManager pauseDownloadWithItems:allTaskModels];
}

- (void)internalPauseAllTaskInDB {
    //考虑到app可能会异常退出这个时候数据库没有更新退出的状态
    NSPredicate *predicate = [NSPredicate
        predicateWithFormat:@"status = %d OR status = %d OR status = %d ",
                            videoDownloading, videoDownloadInQueue,
                            videoDownloadError];

    NSArray *videoTasks = [KKBDownloadVideo MR_findAllWithPredicate:predicate];

    NSMutableArray *allTasks =
        [[NSMutableArray alloc] initWithCapacity:[videoTasks count]];
    for (KKBDownloadVideo *video in videoTasks) {
        KKBDownloadVideoModel *videoModel =
            [KKBDownloadModelFactory convertToBridgeVideoModel:video];
        [allTasks addObject:videoModel];
    }
    if ([allTasks count]) {
        [[self class] pauseDownloadWithItems:allTasks];
    }
}

- (void)internalResumeAllTaskInDBAlertVia3G:(BOOL)alertVia3G;
{
    //考虑到app可能会异常退出这个时候数据库没有更新退出的状态
    NSPredicate *predicate = [NSPredicate
        predicateWithFormat:
            @"status = %d OR status = %d OR status = %d OR status = %d ",
            videoPause, videoDownloading, videoDownloadInQueue,
            videoDownloadError];

    NSArray *videoTasks = [KKBDownloadVideo MR_findAllWithPredicate:predicate];

    NSMutableArray *allTasks =
        [[NSMutableArray alloc] initWithCapacity:[videoTasks count]];
    for (KKBDownloadVideo *video in videoTasks) {
        KKBDownloadVideoModel *videoModel =
            [KKBDownloadModelFactory convertToBridgeVideoModel:video];
        [allTasks addObject:videoModel];
    }
    if ([allTasks count]) {
        [[self class] resumeDownloadWithItems:allTasks
                              allowAlertVia3G:alertVia3G];
    }
}

#pragma mark - notification
- (void)addNotificationObserver {

    [[NSNotificationCenter defaultCenter]
        addObserverForName:DOWNLOADVIDEO_CREATE_SUCCESS_NOTIFICATION
                    object:nil
                     queue:[NSOperationQueue currentQueue]
                usingBlock:^(NSNotification *note) {
                    KKBDownloadVideoModel *videoModel = note.object;
                    NSLog(@"thread:%@", [NSThread currentThread]);
                    NSLog(@"queue:%@", [NSOperationQueue currentQueue]);

                    //开始下载
                    DDLogInfo(@"receive notification %@",
                              [videoModel description]);
                    [self startDownloadWithItem:videoModel];
                }];
}

#pragma mark - download control
- (void)startDownloadWithItem:(KKBDownloadVideoModel *)item {
    NSParameterAssert(item.videoURL != nil);

    int videoID = [item.videoID integerValue];

    AFDownloadRequestOperation *operation = [self
        startDownloadWithURL:item.videoURL
        targetPath:self.downloadPath
        success:^(AFHTTPRequestOperation *operation, id responseObject) {

            DDLogDebug(@"%@下载成功,本地地址:%@", [item description],
                       responseObject);
            // update success
            if ([responseObject isKindOfClass:[NSString class]]) {
                [KKBDownloadStorage updateTaskWithVideoID:videoID
                                                   status:videoDownloadFinish
                                             downloadPath:responseObject];
            }
        }
        failure:^(AFHTTPRequestOperation *operation, NSError *error) {

            // update error status
            // code detail
            // https://developer.apple.com/library/mac/documentation/Cocoa/Reference/Foundation/Miscellaneous/Foundation_Constants/Reference/reference.html
            if (error.code != NSFileWriteFileExistsError &&
                error.code != NSURLErrorCancelled &&
                error.code != NSURLErrorNetworkConnectionLost) {
                // 999取消下载 516已经存在file -1005网络断开
                [KKBDownloadStorage updateTaskWithVideoID:videoID
                                                   status:videoDownloadError];
                DDLogError(@"%@下载失败%@", [item description],
                           [error description]);

            } else {
                DDLogWarn(@"文件已存在");
            }
        }];

    [operation setProgressiveDownloadProgressBlock:
                   ^(AFDownloadRequestOperation *operation, NSInteger bytesRead,
                     long long totalBytesRead, long long totalBytesExpected,
                     long long totalBytesReadForFile,
                     long long totalBytesExpectedToReadForFile) {

                       float progress = totalBytesReadForFile /
                                        (float)totalBytesExpectedToReadForFile;
                       // update progress
                       [KKBDownloadStorage
                           updateTaskWithVideoID:videoID
                                          status:videoDownloading
                                        progress:progress
                                      totalBytes:totalBytesExpectedToReadForFile
                                     readedBytes:totalBytesReadForFile];
                   }];

    // update Status
    [KKBDownloadStorage updateTaskWithVideoID:videoID
                                       status:videoDownloadInQueue];
    DDLogDebug(@"%@***startDownload", [item description]);
}

- (void)pauseDownloadWithItem:(KKBDownloadVideoModel *)item {
    AFDownloadRequestOperation *download =
        [self operationInQueueWithURL:item.videoURL];

    if (download) {
        if ([download isExecuting]) {

        } else {
            DDLogWarn(@"仅同时下载一个任务%@当前没在下载状态",
                      [item description]);
        }

        [download cancel];
    } else {
        DDLogWarn(@"%@没有在当前的队列中", [item description]);
    }
    
    // 一旦暂停不管task是否正在执行都更新数据库状态 save to db
    [KKBDownloadStorage updateTaskWithVideoID:[item.videoID integerValue]
                                       status:videoPause];
    DDLogDebug(@"%@***pauseDownload", [item description]);
}

- (void)resumeDownloadWithItem:(KKBDownloadVideoModel *)item {
    AFDownloadRequestOperation *download =
        [self operationInQueueWithURL:item.videoURL];
    if (download) {
        DDLogWarn(@"!!!继续下载的任务还在当前的队列中%@", [item description]);

    } else {
        //将task重新添加到queue中
        [self startDownloadWithItem:item];
    }

    DDLogDebug(@"%@***resumeDownload", [item description]);
}

- (void)deleteDownloadWithItem:(KKBDownloadVideoModel *)item {
    AFDownloadRequestOperation *download =
        [self operationInQueueWithURL:item.videoURL];

    if (download) {
        DDLogDebug(@"delete download start:%d",
                   [self.operationQueue.operations count]);

        if ([download isPaused]) {
            [download resume];
        }

        [download cancel];

        DDLogDebug(@"delete download end:%d",
                   [self.operationQueue.operations count]);

    } else {
        DDLogWarn(@"要删除的%@没在当前的队列中", [item description]);
    }

    //删除数据库状态
    [KKBDownloadStorage deleteTaskWithVideoID:[item.videoID intValue]];
    //删除tmp文件或者视屏文件
    [self deleteFileWithItem:item];

    DDLogDebug(@"%@***delete download", [item description]);
}

#pragma mark -
- (AFDownloadRequestOperation *)
    startDownloadWithURL:(NSString *)URLString
              targetPath:(NSString *)targetPath
                 success:(void (^)(AFHTTPRequestOperation *operation,
                                   id responseObject))success
                 failure:(void (^)(AFHTTPRequestOperation *operation,
                                   NSError *error))failure {
    NSParameterAssert(targetPath != nil && URLString != nil);

    NSURL *url = [NSURL URLWithString:URLString];
    NSURLRequest *request = [NSURLRequest requestWithURL:url];

    AFDownloadRequestOperation *operation =
        [[AFDownloadRequestOperation alloc] initWithRequest:request
                                                 targetPath:targetPath
                                               shouldResume:YES];

    operation.responseSerializer = self.responseSerializer;
    operation.shouldUseCredentialStorage = self.shouldUseCredentialStorage;
    operation.credential = self.credential;
    operation.securityPolicy = self.securityPolicy;

    [operation setCompletionBlockWithSuccess:success failure:failure];
    operation.completionQueue = self.completionQueue;
    operation.completionGroup = self.completionGroup;

    [self.operationQueue addOperation:operation];

    return operation;
}

#pragma mark -
- (AFDownloadRequestOperation *)currentExcutingOperation {
    for (AFDownloadRequestOperation *operation in self.operationQueue
             .operations) {
        if ([operation isExecuting]) {
            return operation;
        }
    }
    return nil;
}

- (NSArray *)allAddedVideoTaskInCurrentQueue {
    NSMutableArray *downloadURLs = [[NSMutableArray alloc]
        initWithCapacity:[self.operationQueue operationCount]];

    for (AFDownloadRequestOperation *downloadOperation in self.operationQueue
             .operations) {
        NSString *downloadURLStr =
            [downloadOperation.request.URL absoluteString];
        [downloadURLs addObject:downloadURLStr];
    }

    NSPredicate *predicate =
        [NSPredicate predicateWithFormat:@"videoURL IN %@", downloadURLs];

    NSArray *filterArrs = [KKBDownloadVideo MR_findAllWithPredicate:predicate];
    NSMutableArray *tempArr =
        [[NSMutableArray alloc] initWithCapacity:[filterArrs count]];
    if ([filterArrs count] == 0) {
        DDLogWarn(@"！" @"！"
                  @"！allAddedVideoTaskInCurrentQueue当前queue中没有查"
                  @"询的Ta" @"sk");
    } else {
        for (KKBDownloadVideo *video in filterArrs) {
            [tempArr addObject:[KKBDownloadModelFactory
                                   convertToBridgeVideoModel:video]];
        }
    }
    return tempArr;
}

- (AFDownloadRequestOperation *)operationInQueueWithURL:(NSString *)urlStr {
    AFDownloadRequestOperation *operation = nil;
    NSLog(@"operation currentCount:%d", [self.operationQueue.operations count]);
    for (AFDownloadRequestOperation *downloadOperation in self.operationQueue
             .operations) {
        NSString *downloadURLStr =
            [downloadOperation.request.URL absoluteString];
        if ([urlStr isEqualToString:downloadURLStr]) {
            operation = downloadOperation;
            break;
        }
    }
    return operation;
}

#pragma mark - Property
- (NSString *)downloadPath {
    if (!_downloadPath) {
        NSArray *paths = NSSearchPathForDirectoriesInDomains(
            NSCachesDirectory, NSUserDomainMask, YES);

        NSString *downloadPath = [paths objectAtIndex:0];
        _downloadPath = [downloadPath
            stringByAppendingPathComponent:DOWNLOAD_DIRECTORY_NAME];

        NSFileManager *fileManager = [NSFileManager defaultManager];
        if (![fileManager fileExistsAtPath:_downloadPath]) {
            NSError *eror = nil;
            [fileManager createDirectoryAtPath:_downloadPath
                   withIntermediateDirectories:NO
                                    attributes:nil
                                         error:&eror];
            if (eror) {
                DDLogError(@"create downloadPath err! %@", [eror description]);
            }
        }
    }
    return _downloadPath;
}

#pragma mark - KKBDownloadMonitorDelegate
- (void)pauseAllTaskInDB:(KKBDownloadMonitor *)monitor {
    [self internalPauseAllTaskInDB];
}

- (void)resumeAllTaskInDB:(KKBDownloadMonitor *)monitor
          allowAlertVia3G:(BOOL)alertVia3G {
    [self internalResumeAllTaskInDBAlertVia3G:alertVia3G];
}

- (BOOL)shouldResumeTask {
    //检测数据库中是否有可下载的任务
    return [KKBDownloadStorage shouldResumeTask];
}
/*
- (void)checkAndSetOperationActiveCount {
    NSInteger excutingCount = 0;
    NSInteger pauseCount = 0;

    for (AFDownloadRequestOperation *operation in self.operationQueue
             .operations) {
        if (operation.isExecuting) {
            excutingCount++;
        }
        if (operation.isPaused) {
            pauseCount++;
        }
    }

    NSLog(@"excutingCount:%d  pauseCount:%d", excutingCount, pauseCount);
}
 */

#pragma mark - delete Method
- (NSString *)tempDownloadPathForURL:(NSURL *)url {
    NSString *fileName = [url lastPathComponent];
    NSString *downloadPath =
        [NSString pathWithComponents:@[ self.downloadPath, fileName ]];

    NSString *md5URLString = [[self class] md5StringForString:downloadPath];
    NSString *tempPath = [[[self class] cacheFolder]
        stringByAppendingPathComponent:md5URLString];
    NSLog(@"tmpPath:%@", tempPath);
    return tempPath;
}

- (BOOL)deleteFileWithItem:(KKBDownloadVideoModel *)item {
    static NSFileManager *fileManager;
    if (!fileManager) {
        fileManager = [NSFileManager defaultManager];
    }

    // tempPath
    BOOL success = NO;
    NSString *tempPath =
        [self tempDownloadPathForURL:[NSURL URLWithString:item.videoURL]];
    if ([fileManager fileExistsAtPath:tempPath]) {
        NSError *err = nil;
        [fileManager removeItemAtPath:tempPath error:&err];
        if (!err) {
            success = YES;
        } else {
            success = NO;
            DDLogError(@"!删除tmp文件失败%@", [err description]);
        }
    }

    // downloaded file
    BOOL downloadedDeleteSuccess = NO;
    if (item.downloadPath) {
        if ([fileManager fileExistsAtPath:item.downloadPath]) {
            NSError *err = nil;
            [fileManager removeItemAtPath:item.downloadPath error:&err];
            if (err) {
                DDLogWarn(@"删除downloaded文件失败!%@", [err description]);
                downloadedDeleteSuccess = NO;
            } else {
                downloadedDeleteSuccess = YES;
            }
        }
    }

    return success && downloadedDeleteSuccess;
}

#pragma mark - helper
+ (NSString *)cacheFolder {
    NSFileManager *filemgr = [NSFileManager new];
    static NSString *cacheFolder;

    if (!cacheFolder) {
        NSString *cacheDir = NSTemporaryDirectory();
        cacheFolder = [cacheDir stringByAppendingPathComponent:
                                    kAFNetworkingIncompleteDownloadFolderName];
    }

    // ensure all cache directories are there
    NSError *error = nil;
    if (![filemgr createDirectoryAtPath:cacheFolder
            withIntermediateDirectories:YES
                             attributes:nil
                                  error:&error]) {
        NSLog(@"Failed to create cache directory at %@", cacheFolder);
        cacheFolder = nil;
    }
    return cacheFolder;
}

// calculates the MD5 hash of a key
+ (NSString *)md5StringForString:(NSString *)string {
    const char *str = [string UTF8String];
    unsigned char r[CC_MD5_DIGEST_LENGTH];
    CC_MD5(str, (uint32_t)strlen(str), r);
    return [NSString
        stringWithFormat:
            @"%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x",
            r[0], r[1], r[2], r[3], r[4], r[5], r[6], r[7], r[8], r[9], r[10],
            r[11], r[12], r[13], r[14], r[15]];
}

@end
