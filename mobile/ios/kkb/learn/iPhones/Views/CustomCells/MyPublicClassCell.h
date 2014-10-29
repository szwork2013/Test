//
//  MyPublicClassCell.h
//  learn
//
//  Created by zxj on 14-8-4.
//  Copyright (c) 2014年 kaikeba. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface MyPublicClassCell : UITableViewCell

@property(strong, nonatomic) IBOutlet UIImageView *courseImageView;
@property(strong, nonatomic) IBOutlet UILabel *courseName;
@property(strong, nonatomic) IBOutlet UILabel *UpdateLabel;
@property(strong, nonatomic) IBOutlet UILabel *watchLabel;

@end
