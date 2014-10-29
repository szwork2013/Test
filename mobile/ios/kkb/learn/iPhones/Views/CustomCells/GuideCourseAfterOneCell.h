//
//  GuideCourseAfterOneCell.h
//  learn
//
//  Created by zxj on 14-8-14.
//  Copyright (c) 2014年 kaikeba. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface GuideCourseAfterOneCell : UITableViewCell

@property(strong, nonatomic) IBOutlet UILabel *courseName;
@property(strong, nonatomic) IBOutlet UIImageView *statusImageView;
@property(assign, nonatomic) BOOL isFold;

@end
