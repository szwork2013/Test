//
//  MyCorseCell.h
//  learn
//
//  Created by kaikeba on 13-4-15.
//  Copyright (c) 2013年 kaikeba. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface MyCourseCell : UICollectionViewCell

@property (strong, nonatomic) IBOutlet UILabel *courseNameLabel;
@property (strong, nonatomic) IBOutlet UIImageView *coverImv;
@property (strong, nonatomic) IBOutlet UILabel *stateLabel;
@property (strong, nonatomic) IBOutlet UILabel *typeLabel;
@property (strong, nonatomic) IBOutlet UILabel *schoolNameLabel;
@property (strong, nonatomic) IBOutlet UILabel *startTimeLabel;
@property (strong, nonatomic) IBOutlet UILabel *endTimeLabel;
@property (strong, nonatomic) IBOutlet UILabel *percentLabel;
@property (strong, nonatomic) IBOutlet UIView *percentView;

@property (strong, nonatomic) IBOutlet UILabel *symbl;

@end