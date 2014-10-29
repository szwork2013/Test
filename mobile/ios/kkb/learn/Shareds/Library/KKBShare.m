//
//  KKBShare.m
//  learn
//
//  Created by zxj on 14-8-25.
//  Copyright (c) 2014年 kaikeba. All rights reserved.
//

#import "KKBShare.h"
#import "GlobalDefine.h"
#import "UMSocialQQHandler.h"
#import "UMSocialWechatHandler.h"

@implementation KKBShare {
    NSString *theShareTextForSina;
    NSString *theShareTextForOther;
    NSString *theShareDownloadUrl;
}

+ (KKBShare *)shareInstance {
    static KKBShare *singleton = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{ singleton = [[KKBShare alloc] init]; });
    return singleton;
}

- (void)shareWithImage:(UIImage *)image
               viewCtr:(UIViewController *)viewController
              courseId:(NSString *)courseId
            courseName:(NSString *)courseName
      shareDownloadUrl:(NSString *)shareDownloadUrl
      shareTextForSina:(NSString *)shareTextForSina
     shareTextForOther:(NSString *)shareTextForOther {
    theShareDownloadUrl = shareDownloadUrl;
    theShareTextForSina = shareTextForSina;
    theShareTextForOther = shareTextForOther;

    [UMSocialSnsService
        presentSnsIconSheetView:viewController
                         appKey:UMENG_APPKEY_IPHONE
                      shareText:@""
                     shareImage:image
                shareToSnsNames:
                    [NSArray arrayWithObjects:UMShareToSina, UMShareToTencent,
                                              UMShareToRenren, UMShareToDouban,
                                              UMShareToQzone,
                                              UMShareToWechatSession,
                                              UMShareToWechatTimeline,
                                              UMShareToQQ, nil]
                       delegate:self];
    [UMSocialConfig setFinishToastIsHidden:NO
                                  position:UMSocialiToastPositionCenter];
}

- (void)didSelectSocialPlatform:(NSString *)platformName
                 withSocialData:(UMSocialData *)socialData {
    NSMutableString *suffix =
        [[NSMutableString alloc] initWithString:@"?social_share="];
    if ([platformName isEqualToString:UMShareToDouban]) {
        [suffix appendString:@"douban"];
    } else if ([platformName isEqualToString:UMShareToQQ]) {
        [suffix appendString:@"qq"];
    } else if ([platformName isEqualToString:UMShareToQzone]) {
        [suffix appendString:@"qzone"];
    } else if ([platformName isEqualToString:UMShareToSina]) {
        [suffix appendString:@"weibo"];
    } else if ([platformName isEqualToString:UMShareToTencent]) {
        [suffix appendString:@"t_weibo"];
    } else if ([platformName isEqualToString:UMShareToRenren]) {
        [suffix appendString:@"renren"];
    } else if ([platformName isEqualToString:UMShareToWechatTimeline]) {
        [suffix appendString:@"wechat_quan"];
    } else if ([platformName isEqualToString:UMShareToWechatSession]) {
        [suffix appendString:@"wechat"];
    }

    NSMutableString *downloadUrl =
        [NSMutableString stringWithFormat:@"%@", theShareDownloadUrl];
    [downloadUrl appendString:suffix];

    if ([platformName isEqualToString:UMShareToSina]) {
        socialData.shareText = [NSString
            stringWithFormat:@"%@%@", theShareTextForSina, downloadUrl];
    } else if ([platformName isEqualToString:UMShareToQQ] ||
               [platformName isEqualToString:UMShareToQzone]) {
        [UMSocialQQHandler setQQWithAppId:@"1101760842"
                                   appKey:@"fE56BxnhusHyT3RX"
                                      url:downloadUrl];
        socialData.shareText = theShareTextForOther;
    } else if ([platformName isEqualToString:UMShareToWechatTimeline] ||
               [platformName isEqualToString:UMShareToWechatSession]) {
        [UMSocialWechatHandler setWXAppId:@"wxef4c838d5f6cb77f"
                                      url:downloadUrl];
        socialData.shareText = theShareTextForOther;
    } else {
        socialData.shareText = [NSString
            stringWithFormat:@"%@%@", theShareTextForOther, downloadUrl];
    }
    [socialData.urlResource setResourceType:UMSocialUrlResourceTypeDefault
                                        url:downloadUrl];
}

- (void)didCloseUIViewController:(UMSViewControllerType)fromViewControllerType {
    if (fromViewControllerType == UMSViewControllerShareEdit) {
        [self.delegate shareViewControllerDidDismiss];
    }
}

@end
