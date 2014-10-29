//
//  CertificatViewController.h
//  learn
//
//  Created by xgj on 14-7-14.
//  Copyright (c) 2014年 kaikeba. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface CertificatViewController : UIViewController<UIScrollViewDelegate>{
    IBOutlet UIImageView *imageView;
    
}

@property (nonatomic, strong) NSString *imageUrl;
@property (nonatomic, retain) IBOutlet UIScrollView *scrollView;

@end
