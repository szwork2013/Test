//
//  KKBSuccessView.h
//  learn
//
//  Created by zxj on 14-9-24.
//  Copyright (c) 2014年 kaikeba. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface KKBSuccessView : UIView{
    UIView *baseView;
    UIImageView*backGroundView;
    UIView *roundCornorView;
}
@property (strong,nonatomic)UILabel *successMessage;
@end
