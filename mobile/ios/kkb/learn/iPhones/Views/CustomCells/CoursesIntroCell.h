//
//  CoursesIntroCell.h
//  learn
//
//  Created by zxj on 14-8-11.
//  Copyright (c) 2014年 kaikeba. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface CoursesIntroCell : UITableViewCell
@property (strong, nonatomic) IBOutlet UIImageView *backgroundImageView;

@property(strong, nonatomic) IBOutlet UILabel *courseName;
@property(strong, nonatomic) IBOutlet UILabel *courseLabel;

@end
