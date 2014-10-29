//
//  MyGuideClaassCellTableViewCell.h
//  learn
//
//  Created by zxj on 14-8-6.
//  Copyright (c) 2014年 kaikeba. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface MyGuideClassCell : UITableViewCell

@property(strong, nonatomic) IBOutlet UIImageView *courseImageView;
@property(weak, nonatomic) IBOutlet UILabel *courseNameLabel;
@property(weak, nonatomic) IBOutlet UILabel *textLabel1;
@property(weak, nonatomic) IBOutlet UILabel *textLabel2;

@end
