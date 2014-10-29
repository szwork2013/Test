#import "_KKBDownloadVideo.h"

#import "KKBDownloadHeader.h"

@interface KKBDownloadVideo : _KKBDownloadVideo {}
// Custom logic goes here.

- (VideoDownloadStatus)customDownloadStatus;
- (NSString *)descriptionStatus;


- (NSString *)tempDownloadPath;

//是否允许暂停
- (BOOL)allowPause;
- (BOOL)allowResume;


//开机时检测是否可以放入队列下载
- (BOOL)allowBeginStart;

- (NSNumber *)sortedKey;

@end
