#import "KKBDownloadVideo.h"

@interface KKBDownloadVideo ()

// Private interface goes here.

@end

@implementation KKBDownloadVideo

// Custom logic goes here.

- (VideoDownloadStatus)customDownloadStatus {
    VideoDownloadStatus status = videoUnknown;
    switch (self.statusValue) {
    case 0:
        status = videoUnknown;
        break;
    case 1:
        status = videoDownloading;
        break;
    case 2:
        status = videoPause;
        break;
    case 3:
        status = videoDownloadFinish;
        break;
    case 4:
        status = videoDownloadInQueue;
        break;
    case 5:
        status = videoDownloadError;
        break;
    case 6:
        status = videoDownloadCancel;
        break;
    default:
        status = videoUnknown;
        break;
    }
    return status;
}

- (NSString *)descriptionStatus {
    NSString *descriptionStatus = @"未知状态";
    switch ([self customDownloadStatus]) {
    case videoUnknown:
        descriptionStatus = @"未知状态";
        break;
    case videoDownloading:
        descriptionStatus = @"下载状态";
        break;
    case videoPause:
        descriptionStatus = @"暂停状态";
        break;
    case videoDownloadFinish:
        descriptionStatus = @"已下载";
        break;
    case videoDownloadInQueue:
        descriptionStatus = @"等待状态";
        break;
    case videoDownloadError:
        descriptionStatus = @"下载错误";
        break;
    case videoDownloadCancel:
        descriptionStatus = @"取消状态";
        break;
    default:
        descriptionStatus = @"未知状态";
        break;
    }
    return descriptionStatus;
}

//是否允许暂停
- (BOOL)allowPause {
    VideoDownloadStatus stauts = [self customDownloadStatus];
    if (stauts == videoDownloadInQueue || stauts == videoDownloading) {
        return YES;
    }
    return NO;
}

- (BOOL)allowResume {
    VideoDownloadStatus stauts = [self customDownloadStatus];
    if (stauts != videoDownloadFinish) {
        return YES;
    }
    return NO;
}

//开机时检测是否可以放入队列下载
- (BOOL)allowBeginStart {
    VideoDownloadStatus stauts = [self customDownloadStatus];
    if (stauts == videoPause || stauts == videoDownloading ||
        stauts == videoDownloadInQueue || stauts == videoDownloadError) {
        return YES;
    }
    return NO;
}

- (NSString *)tempDownloadPath {

    return nil;
}

- (NSNumber *)sortedKey {
    return self.whichClass.classID;
}
@end
