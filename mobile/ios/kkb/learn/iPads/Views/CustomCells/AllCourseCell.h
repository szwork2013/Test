//
//  AllCourseCell.h
//  learn
//
//  Created by User on 14-5-7.
//  Copyright (c) 2014年 kaikeba. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface AllCourseCell : UICollectionViewCell

@property (strong, nonatomic) IBOutlet UILabel *courseNameLabel;
@property (strong, nonatomic) IBOutlet UIImageView *coverImv;
@property (strong, nonatomic) IBOutlet UILabel *stateLabel;

@property (strong, nonatomic) IBOutlet UILabel *schoolNameLabel;

@property (strong, nonatomic) IBOutlet UILabel *detailLabel;

@end
