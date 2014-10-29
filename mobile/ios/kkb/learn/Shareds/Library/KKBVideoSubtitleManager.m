//
//  KKBVideoSubtitleManager.m
//  learn
//
//  Created by zengmiao on 9/26/14.
//  Copyright (c) 2014 kaikeba. All rights reserved.
//

#import "KKBVideoSubtitleManager.h"
#import "KKBHttpClient.h"
#import "VKVideoPlayerCaptionSRT.h"

#define VIDEOSUBTITLE_DEBUG

#ifdef VIDEOSUBTITLE_DEBUG
static const int ddLogLevel = LOG_LEVEL_VERBOSE;
#else
static const int ddLogLevel = LOG_LEVEL_OFF;
#endif

@interface KKBVideoSubtitleManager ()
@property(nonatomic, strong, readwrite) NSNumber *classID;
@property(nonatomic, strong, readwrite) NSNumber *videoID;
@end

@implementation KKBVideoSubtitleManager

- (instancetype)initWithClassID:(NSNumber *)classID
                    andDelegate:(id<KKBVideoSuTitleDelegate>)delegate {
    self = [super init];
    if (self) {
        _classID = classID;
        _delegate = delegate;
    }
    return self;
}

- (void)requestSubtitleWithVideoID:(NSNumber *)videoID {
    // TODO: byzm
    //取消上一次的请求

    if (videoID == nil) {
        DDLogWarn(@"request subtitle err ！videoID = nil");
        return;
    }
    if (self.classID == nil) {
        DDLogWarn(@"request subtitle err ！classID = nil");
        return;
    }

    if (!self.videoID) {
        //每次request之前先取消上一次的请求
        NSString *lastPath =
            [NSString stringWithFormat:@"v1/courses/%@/items/%@/subtitles",
                                       self.classID, self.videoID];
        [[KKBHttpClient shareInstance]
            cancelCurrentRequesetInQueueWithRequestURL:lastPath];
    }

    self.videoID = videoID;

    NSString *pathStr =
        [NSString stringWithFormat:@"v1/courses/%@/items/%@/subtitles",
                                   self.classID, self.videoID];
    [[KKBHttpClient shareInstance] requestAPIUrlPath:pathStr
        method:@"GET"
        param:nil
        fromCache:YES
        success:^(NSDictionary *result, AFHTTPRequestOperation *operation) {
            if ([result isKindOfClass:[NSDictionary class]]) {
                NSString *subtitles = result[@"subtitles"];
                [self parseSubtileWithRawString:subtitles];
            } else {
                DDLogWarn(@"error !! subtitle 返回非法的格式");
                [self.delegate
                    subTitleLoadFailedWithManager:
                        self errorCode:subtitlesInvalidResponseFormatError];
            }
        }
        failure:^(id result, AFHTTPRequestOperation *operation) {
            DDLogWarn(@"error:%@", [result description]);
            [self.delegate subTitleLoadFailedWithManager:self
                                               errorCode:subtitlesRequestError];
        }];
}

- (void)parseSubtileWithRawString:(NSString *)str {
    if (!str) {
        DDLogError(@"error !! subtitle str == nil");
        [self.delegate subTitleLoadFailedWithManager:self
                                           errorCode:subtitlesResponseNilError];
    }

    dispatch_queue_t queue =
        dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0);
    dispatch_async(queue, ^{

        VKVideoPlayerCaptionSRT *caption =
            [[VKVideoPlayerCaptionSRT alloc] initWithRawString:str];

        dispatch_async(dispatch_get_main_queue(), ^{
            [self.delegate subTitleDidLoad:caption manager:self];
        });
    });
}

- (void)requestSubtitleWithMainBundleForName:(NSString *)str {
    NSString *filePath =
        [[NSBundle mainBundle] pathForResource:str ofType:@"srt"];
    NSData *testData = [NSData dataWithContentsOfFile:filePath];
    NSString *rawString =
        [[NSString alloc] initWithData:testData encoding:NSUTF8StringEncoding];
    [self parseSubtileWithRawString:rawString];
}

#pragma mark - Helper

+ (void)cachesSubtitleWithClassID:(NSNumber *)classID
                       andVideoID:(NSNumber *)videoID {
    NSString *pathStr = [NSString
        stringWithFormat:@"v1/courses/%@/items/%@/subtitles", classID, videoID];

    [[KKBHttpClient shareInstance] requestAPIUrlPath:pathStr
        method:@"GET"
        param:nil
        fromCache:YES
        success:^(NSDictionary *result, AFHTTPRequestOperation *operation) {
            DDLogWarn(@"caches Success :%@", pathStr);
        }
        failure:^(id result, AFHTTPRequestOperation *operation) {
            DDLogWarn(@"caches %@ error:%@", pathStr, [result description]);
        }];
}

#pragma mark - 从Main Bundle中加载测试数据文件并Json序列化
+ (id)loadTestDataFromFile:(NSString *)param {
    NSURL *url =
        [NSURL fileURLWithPath:[[NSBundle mainBundle] pathForResource:param
                                                               ofType:@"json"]];
    NSData *jsonData = [NSData dataWithContentsOfURL:url];
    NSError *err = nil;
    NSDictionary *jsonObject =
        [NSJSONSerialization JSONObjectWithData:jsonData options:0 error:&err];

    if (err) {
        NSLog(@"💚💚Json序列化Bundle中的:%@ 失败! 原因:%@", param, err);
        return nil;
    }
    return jsonObject;
}

@end
