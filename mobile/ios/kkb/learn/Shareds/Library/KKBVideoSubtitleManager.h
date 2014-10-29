//
//  KKBVideoSubtitleManager.h
//  learn
//
//  Created by zengmiao on 9/26/14.
//  Copyright (c) 2014 kaikeba. All rights reserved.
//

#import <Foundation/Foundation.h>
@class VKVideoPlayerCaptionSRT;
@class KKBVideoSubtitleManager;

typedef NS_ENUM(NSInteger, SubtitlesError) {
    subtitlesRequestError = 2000,
    subtitlesInvalidResponseFormatError,
    subtitlesResponseNilError
};

@protocol KKBVideoSuTitleDelegate <NSObject>

- (void)subTitleDidLoad:(VKVideoPlayerCaptionSRT *)caption
                manager:(KKBVideoSubtitleManager *)manager;

- (void)subTitleLoadFailedWithManager:(KKBVideoSubtitleManager *)manager
                            errorCode:(SubtitlesError)errCode;

@end

@interface KKBVideoSubtitleManager : NSObject

@property(nonatomic, weak) id<KKBVideoSuTitleDelegate> delegate;
@property(nonatomic, strong, readonly) NSNumber *classID;
@property(nonatomic, strong, readonly) NSNumber *videoID;

- (instancetype)initWithClassID:(NSNumber *)classID
                    andDelegate:(id<KKBVideoSuTitleDelegate>)delegate;

- (void)requestSubtitleWithVideoID:(NSNumber *)videoID;

- (void)requestSubtitleWithMainBundleForName:(NSString *)str;


+ (void)cachesSubtitleWithClassID:(NSNumber *)classID
                       andVideoID:(NSNumber *)videoID;

@end
