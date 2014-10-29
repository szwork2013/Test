//
//  SelfViewController.h
//  learn
//
//  Created by zxj on 14-7-22.
//  Copyright (c) 2014年 kaikeba. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "MajorViews.h"
#import "KKBBaseViewController.h"

@interface MicroMajorViewController
    : KKBBaseViewController <MiniMajorDelegate> {
    UIScrollView *baseScrollView;
    MajorViews *tempMV;
    NSMutableArray *majorViewArray;
    NSArray *microSpecialitiesArray;
    NSDictionary *majorDic;
}
@end
