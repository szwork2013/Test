//
//  KKBDownloadStorage.m
//  VideoDownload
//
//  Created by zengmiao on 8/29/14.
//  Copyright (c) 2014 zengmiao. All rights reserved.
//

#import "KKBDownloadStorage.h"
#import "KKBDownloadSaveCount.h"

#ifdef DOWNLOADN_DEBUG
static const int ddLogLevel = LOG_LEVEL_VERBOSE;
#else
static const int ddLogLevel = LOG_LEVEL_OFF;
#endif

//#define DEBUG_SAVE

static NSString *const kkbStoreName = @"KKBVideoDB.sqlite";

@interface KKBDownloadStorage () {
    dispatch_queue_t storageQueue;
}

@property(strong, nonatomic) NSMutableDictionary *countDic;

@end

@implementation KKBDownloadStorage

+ (instancetype)sharedInstacne {

    static KKBDownloadStorage *instacne = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{ instacne = [[self alloc] init]; });

    return instacne;
}

- (instancetype)init {
    self = [super init];
    if (self) {
        [self customInit];
    }
    return self;
}

- (void)customInit {

    storageQueue = dispatch_queue_create("com.kkb.storageQueue", NULL);
    _countDic = [[NSMutableDictionary alloc] init];

    // setup MRCoreDataStack
    [MagicalRecord setLoggingLevel:MagicalRecordLoggingLevelVerbose];
    [MagicalRecord setupCoreDataStackWithAutoMigratingSqliteStoreNamed:kkbStoreName];

    [[NSNotificationCenter defaultCenter]
        addObserverForName:UIApplicationWillTerminateNotification
                    object:nil
                     queue:[NSOperationQueue mainQueue]
                usingBlock:^(NSNotification *note) {
                    [MagicalRecord cleanUp];
                }];
}

+ (void)createTaskWithClass:(KKBDownloadClassModel *)classModel
                      video:(KKBDownloadVideoModel *)videoModel {
    KKBDownloadStorage *storage = [KKBDownloadStorage sharedInstacne];
    [storage createTaskWithClass:classModel video:videoModel];
}

+ (void)deleteTaskWithVideoID:(int)videoID {
    KKBDownloadStorage *storage = [KKBDownloadStorage sharedInstacne];
    [storage deleteTaskWithVideoID:videoID];
}

+ (void)updateTaskWithVideoID:(int)videoID status:(VideoDownloadStatus)status {
    KKBDownloadStorage *storage = [KKBDownloadStorage sharedInstacne];
    [storage updateTaskWithVideoID:videoID status:status];
}

+ (void)updateTaskWithVideoID:(int)videoID
                       status:(VideoDownloadStatus)status
                 downloadPath:(NSString *)downloadPath {
    KKBDownloadStorage *storage = [KKBDownloadStorage sharedInstacne];
    [storage updateTaskWithVideoID:videoID
                            status:status
                      downloadPath:downloadPath];
}

+ (void)updateTaskWithVideoID:(int)videoID
                       status:(VideoDownloadStatus)status
                     progress:(float)progress
                   totalBytes:(long long)totalBtyes
                  readedBytes:(long long)readedBytes {
    KKBDownloadStorage *storage = [KKBDownloadStorage sharedInstacne];
    [storage updateTaskWithVideoID:videoID
                            status:status
                          progress:progress
                        totalBytes:totalBtyes
                       readedBytes:readedBytes];
}

#pragma mark -
- (void)updateTaskWithVideoID:(int)videoID status:(VideoDownloadStatus)status {

    // add count to Dic
    NSString *key = [NSString stringWithFormat:@"%d", videoID];

    if (status == videoDownloadInQueue) {
        if (!self.countDic[key]) {
            KKBDownloadSaveCount *countObject =
                [[KKBDownloadSaveCount alloc] init];
            self.countDic[key] = countObject;
        } else {
            DDLogError(@"添加失败countDic已存在!!videoID:%d", videoID);
        }

    } else if (status == videoDownloadFinish || status == videoDownloadError ||
               status == videoDownloadCancel) {
        if (self.countDic[key]) {
            [self.countDic removeObjectForKey:key];
        } else {
            DDLogError(@"删除失败countDic不存在!!videoID:%d", videoID);
        }
    }

#ifdef DEBUG_SAVE
    [MagicalRecord saveWithBlock:^(NSManagedObjectContext *localContext) {
        // check VideoItem
        KKBDownloadVideo *existDownloadVideo =
            [KKBDownloadVideo MR_findFirstByAttribute:@"videoID"
                                            withValue:@(videoID)
                                            inContext:localContext];
        if (existDownloadVideo) {
            // check class
            if (existDownloadVideo.whichClass) {
                existDownloadVideo.status = @(status);
                existDownloadVideo.videoID = @(videoID);
            } else {
                DDLogError(@"updateTaskError-" @"要"
                           @"更新的的KKBDownloadVideo不"
                           @"存在WhichClass属性-%d",
                           videoID);
            }

        } else {
            DDLogError(@"updateTaskError-要更新的KKBDownloadVideo不存在-%d",
                       videoID);
        }
    }];
#else
    dispatch_async(storageQueue, ^{
        [MagicalRecord
            saveWithBlockAndWait:^(NSManagedObjectContext *localContext) {
                // check VideoItem
                KKBDownloadVideo *existDownloadVideo =
                    [KKBDownloadVideo MR_findFirstByAttribute:@"videoID"
                                                    withValue:@(videoID)
                                                    inContext:localContext];
                if (existDownloadVideo) {
                    // check class
                    if (existDownloadVideo.whichClass) {
                        existDownloadVideo.status = @(status);
                        existDownloadVideo.videoID = @(videoID);
                        if (status == videoDownloadFinish) {
                            existDownloadVideo.progress = @(1);
                        }
                    } else {
                        DDLogError(@"updateTaskError-" @"要"
                                   @"更新的的KKBDownloadVideo不"
                                   @"存在WhichClass属性-%d",
                                   videoID);
                    }

                } else {
                    DDLogError(
                        @"updateTaskError-要更新的KKBDownloadVideo不存在-%d",
                        videoID);
                }
            }];
    });

#endif
}

- (void)updateTaskWithVideoID:(int)videoID
                       status:(VideoDownloadStatus)status
                     progress:(float)progress
                   totalBytes:(long long)totalBtyes
                  readedBytes:(long long)readedBytes {

    NSString *key = [NSString stringWithFormat:@"%d", videoID];
    KKBDownloadSaveCount *count = self.countDic[key];
    if ([count allowSaveToDB] || progress == 1.0) {
#ifdef DEBUG_SAVE
        [MagicalRecord saveWithBlock:^(NSManagedObjectContext *localContext) {
            // check VideoItem
            KKBDownloadVideo *existDownloadVideo =
                [KKBDownloadVideo MR_findFirstByAttribute:@"videoID"
                                                withValue:@(videoID)
                                                inContext:localContext];
            if (existDownloadVideo) {
                // check class
                if (existDownloadVideo.whichClass) {
                    existDownloadVideo.status = @(status);
                    existDownloadVideo.videoID = @(videoID);
                    existDownloadVideo.progress = @(progress);
                    existDownloadVideo.totalBytesFile = @(totalBtyes);
                    existDownloadVideo.totalBytesReaded = @(readedBytes);
                } else {
                    DDLogError(@"updateTaskError-" @"要"
                               @"更新的的KKBDownloadVideo不"
                               @"存在WhichClass属性-%d",
                               videoID);
                }

            } else {
                DDLogError(@"updateTaskError-要更新的KKBDownloadVideo不存在-%d",
                           videoID);
            }
        }];

#else
        dispatch_async(storageQueue, ^{

            [MagicalRecord saveWithBlockAndWait:^(NSManagedObjectContext *
                                                      localContext) {
                // check VideoItem
                KKBDownloadVideo *existDownloadVideo =
                    [KKBDownloadVideo MR_findFirstByAttribute:@"videoID"
                                                    withValue:@(videoID)
                                                    inContext:localContext];
                if (existDownloadVideo) {
                    // check class
                    if (existDownloadVideo.whichClass) {
                        existDownloadVideo.status = @(status);
                        existDownloadVideo.videoID = @(videoID);
                        existDownloadVideo.progress = @(progress);
                        existDownloadVideo.totalBytesFile = @(totalBtyes);
                        existDownloadVideo.totalBytesReaded = @(readedBytes);
                    } else {
                        DDLogError(@"updateTaskError-" @"要"
                                   @"更新的的KKBDownloadVideo不"
                                   @"存在WhichClass属性-%d",
                                   videoID);
                    }

                } else {
                    DDLogError(
                        @"updateTaskError-要更新的KKBDownloadVideo不存在-%d",
                        videoID);
                }
            }];
        });

#endif
    }
}

- (void)updateTaskWithVideoID:(int)videoID
                       status:(VideoDownloadStatus)status
                 downloadPath:(NSString *)downloadPath {

#ifdef DEBUG_SAVE
    [MagicalRecord saveWithBlock:^(NSManagedObjectContext *localContext) {
        // check VideoItem
        KKBDownloadVideo *existDownloadVideo =
            [KKBDownloadVideo MR_findFirstByAttribute:@"videoID"
                                            withValue:@(videoID)
                                            inContext:localContext];
        if (existDownloadVideo) {
            // check class
            if (existDownloadVideo.whichClass) {
                existDownloadVideo.status = @(status);
                existDownloadVideo.videoID = @(videoID);
                existDownloadVideo.downloadPath = downloadPath;
            } else {
                DDLogError(@"updateTaskError-" @"要"
                           @"更新的的KKBDownloadVideo不"
                           @"存在WhichClass属性-%d",
                           videoID);
            }

        } else {
            DDLogError(@"updateTaskError-要更新的KKBDownloadVideo不存在-%d",
                       videoID);
        }
    }];
#else
    dispatch_async(storageQueue, ^{
        [MagicalRecord
            saveWithBlockAndWait:^(NSManagedObjectContext *localContext) {
                // check VideoItem
                KKBDownloadVideo *existDownloadVideo =
                    [KKBDownloadVideo MR_findFirstByAttribute:@"videoID"
                                                    withValue:@(videoID)
                                                    inContext:localContext];
                if (existDownloadVideo) {
                    // check class
                    if (existDownloadVideo.whichClass) {
                        existDownloadVideo.status = @(status);
                        existDownloadVideo.videoID = @(videoID);
                        existDownloadVideo.downloadPath = downloadPath;
                    } else {
                        DDLogError(@"updateTaskError-" @"要"
                                   @"更新的的KKBDownloadVideo不"
                                   @"存在WhichClass属性-%d",
                                   videoID);
                    }

                } else {
                    DDLogError(
                        @"updateTaskError-要更新的KKBDownloadVideo不存在-%d",
                        videoID);
                }
            }];
    });

#endif
}

- (void)deleteTaskWithVideoID:(int)videoID {
    dispatch_async(storageQueue, ^{
        [MagicalRecord saveWithBlockAndWait:^(NSManagedObjectContext *
                                                  localContext) {
            // check VideoItem
            KKBDownloadVideo *existDownloadVideo =
                [KKBDownloadVideo MR_findFirstByAttribute:@"videoID"
                                                withValue:@(videoID)
                                                inContext:localContext];
            if (existDownloadVideo) {
                // check class
                KKBDownloadClass *existDownloadClass =
                    existDownloadVideo.whichClass;
                BOOL willDelete =
                    [existDownloadClass.videos count] == 1 ? YES : NO;

                // delete video item
                [existDownloadVideo MR_deleteEntityInContext:localContext];

                if (willDelete) {
                    // delete class
                    [existDownloadClass MR_deleteEntityInContext:localContext];
                }

            } else {
                DDLogError(@"deleteTaskError-要删除的KKBDownloadVideo不存在-"
                           @"videoID:%d",
                           videoID);
            }
        }];
    });
}

- (void)createTaskWithClass:(KKBDownloadClassModel *)classModel
                      video:(KKBDownloadVideoModel *)videoModel {

    dispatch_async(storageQueue, ^{
        [MagicalRecord saveWithBlockAndWait:^(NSManagedObjectContext *
                                                  localContext) {
            // check class
            KKBDownloadClass *existDownloadClass =
                [KKBDownloadClass MR_findFirstByAttribute:@"classID"
                                                withValue:classModel.classID
                                                inContext:localContext];

            if (!existDownloadClass) {
                // create new class
                DDLogInfo(
                    @"创建KKBDownloadClass￥￥￥classID:%@ name:%@ ***",
                    classModel.classID, classModel.name);
                KKBDownloadClass *newDownloadClass =
                    [KKBDownloadClass MR_createEntityInContext:localContext];
                newDownloadClass.classID = classModel.classID;
                newDownloadClass.name = classModel.name;
                newDownloadClass.classType = @(classModel.classType);

                existDownloadClass = newDownloadClass;

            } else {
                DDLogInfo(
                    @"已存在KKBDownloadClass￥￥￥classID:%@ name:%@ ***",
                    classModel.classID, classModel.name);
            }

            // check VideoItem
            KKBDownloadVideo *existDownloadVideo =
                [KKBDownloadVideo MR_findFirstByAttribute:@"videoID"
                                                withValue:videoModel.videoID
                                                inContext:localContext];
            if (!existDownloadVideo) {
                // success
                KKBDownloadVideo *newDownloadVideo =
                    [KKBDownloadVideo MR_createEntityInContext:localContext];
                newDownloadVideo.videoID = videoModel.videoID;
                newDownloadVideo.position = videoModel.position;
                newDownloadVideo.downloadPath = videoModel.downloadPath;
                newDownloadVideo.tmpPath = videoModel.tmpPath;
                newDownloadVideo.videoURL = videoModel.videoURL;
                newDownloadVideo.videoTitle = videoModel.videoTitle;
                newDownloadVideo.status = @(videoModel.status);
                newDownloadVideo.whichClass = existDownloadClass;

            } else {
                // error
                DDLogInfo(
                    @"提示！已存在KKBDownloadVideo￥￥￥classID:%@ "
                    @"name:%@ " @"*** videoID:%@***videURL:%@",
                    classModel.classID, classModel.name, videoModel.videoID,
                    videoModel.videoURL);
            }
        }];

        [[NSNotificationCenter defaultCenter]
            postNotificationName:DOWNLOADVIDEO_CREATE_SUCCESS_NOTIFICATION
                          object:videoModel];
    });

    /*
    [MagicalRecord saveWithBlock:^(NSManagedObjectContext *localContext) {
        // check class
        KKBDownloadClass *existDownloadClass =
        [KKBDownloadClass MR_findFirstByAttribute:@"classID"
                                        withValue:classModel.classID
                                        inContext:localContext];

        if (!existDownloadClass) {
            // create new class
            DDLogInfo(@"创建KKBDownloadClass￥￥￥classID:%@ name:%@ ***",
                      classModel.classID, classModel.name);
            KKBDownloadClass *newDownloadClass =
            [KKBDownloadClass MR_createEntityInContext:localContext];
            newDownloadClass.classID = classModel.classID;
            newDownloadClass.name = classModel.name;
            newDownloadClass.classType = @(classModel.classType);

            existDownloadClass = newDownloadClass;

        } else {
            DDLogInfo(@"已存在KKBDownloadClass￥￥￥classID:%@ name:%@ ***",
                      classModel.classID, classModel.name);
        }

        // check VideoItem
        KKBDownloadVideo *existDownloadVideo =
        [KKBDownloadVideo MR_findFirstByAttribute:@"videoID"
                                        withValue:videoModel.videoID
                                        inContext:localContext];
        if (!existDownloadVideo) {
            // success
            KKBDownloadVideo *newDownloadVideo =
            [KKBDownloadVideo MR_createEntityInContext:localContext];
            newDownloadVideo.videoID = videoModel.videoID;
            newDownloadVideo.downloadPath = videoModel.downloadPath;
            newDownloadVideo.tmpPath = videoModel.tmpPath;
            newDownloadVideo.videoURL = videoModel.videoURL;
            newDownloadVideo.videoTitle = videoModel.videoTitle;
            newDownloadVideo.status = @(videoModel.status);
            newDownloadVideo.whichClass = existDownloadClass;

        } else {
            // error
            DDLogInfo(
                      @"提示！已存在KKBDownloadVideo￥￥￥classID:%@ name:%@ "
                      @"*** videoID:%@***videURL:%@",
                      classModel.classID, classModel.name, videoModel.videoID,
                      videoModel.videoURL);
        }
    } completion:^(BOOL success, NSError *error) {
        if (!error) {
            [[NSNotificationCenter defaultCenter]
             postNotificationName:DOWNLOADVIDEO_CREATE_SUCCESS_NOTIFICATION
             object:videoModel];

        } else {
            DDLogError(@"创建KKBDownloadVideo失败!￥￥￥classID:%@ name:%@ "
                       @"*** videoID:%@***videURL:%@ error:%@",
                       classModel.classID, classModel.name, videoModel.videoID,
                       videoModel.videoURL, [error description]);
        }
    }];
     */
}

+ (BOOL)shouldResumeTask {
    NSPredicate *predicate =
        [NSPredicate predicateWithFormat:@"status != %d", videoDownloadFinish];
    NSArray *arr = [KKBDownloadVideo MR_findAllWithPredicate:predicate];

    return [arr count] > 0 ? YES : NO;
}
@end
