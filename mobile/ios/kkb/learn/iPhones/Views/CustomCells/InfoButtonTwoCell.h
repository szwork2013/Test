//
//  InfoButtonTwoCell.h
//  learn
//
//  Created by zxj on 14-8-16.
//  Copyright (c) 2014年 kaikeba. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "RTLabel.h"
@interface InfoButtonTwoCell : UITableViewCell

@property(strong, nonatomic) IBOutlet UILabel *teacherName;
@property(strong, nonatomic) IBOutlet UILabel *teacherTitle;
@property(strong, nonatomic) IBOutlet UIImageView *teacherHeadImageView;
@property (strong, nonatomic) IBOutlet UILabel *teacherLineLabel;
@property(strong, nonatomic) RTLabel *teacherDetailLabel;

@end
