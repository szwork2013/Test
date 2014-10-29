#import "KKBDownloadClass.h"

@interface KKBDownloadClass ()

// Private interface goes here.

@end

@implementation KKBDownloadClass

// Custom logic goes here.

// bridge Property
- (VideoDownloadClassType)customClassType {
  NSInteger tempType = [self.classType integerValue];
  if (tempType) {
    return videoOpenCourse;
  }
  return videoGuideCourse;
}


@end
