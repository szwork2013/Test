//
//  KKBDownloadClassModel.m
//  VideoDownload
//
//  Created by zengmiao on 8/29/14.
//  Copyright (c) 2014 zengmiao. All rights reserved.
//

#import "KKBDownloadClassModel.h"

@implementation KKBDownloadClassModel

- (NSString *)description {
  return [NSString
      stringWithFormat:@"KKBDownloadClassModel&&&classID:%@&&&Title:%@",
                       self.classID, self.name];
}
@end
