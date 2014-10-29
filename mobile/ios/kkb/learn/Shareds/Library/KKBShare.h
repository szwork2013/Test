//
//  KKBShare.h
//  learn
//
//  Created by zxj on 14-8-25.
//  Copyright (c) 2014年 kaikeba. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "UMSocial.h"

@protocol KKBShareDelegate <NSObject>

@required
- (void)shareViewControllerDidDismiss;

@end

@interface KKBShare : NSObject <UMSocialUIDelegate>

@property(nonatomic, weak) id<KKBShareDelegate> delegate;

+ (KKBShare *)shareInstance;
- (void)shareWithImage:(UIImage *)image
               viewCtr:(UIViewController *)viewController
              courseId:(NSString *)courseId
            courseName:(NSString *)courseName
      shareDownloadUrl:(NSString *)shareDownloadUrl
      shareTextForSina:(NSString *)shareTextForSina
     shareTextForOther:(NSString *)shareTextForOther;

@end
