//
//  TeacherIntroCell.h
//  learn
//
//  Created by zxj on 14-8-11.
//  Copyright (c) 2014年 kaikeba. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface TeacherIntroCell : UITableViewCell

@property(strong, nonatomic) IBOutlet UIImageView *teacherImageVIew;
@property(strong, nonatomic) IBOutlet UILabel *teacherName;
@property(strong, nonatomic) IBOutlet UILabel *teacherIntro;
@property (strong, nonatomic) IBOutlet UIImageView *backgroundImageView;

@end
