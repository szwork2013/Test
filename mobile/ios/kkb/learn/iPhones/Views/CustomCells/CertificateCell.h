//
//  CertificateCell.h
//  learn
//
//  Created by zxj on 14-7-23.
//  Copyright (c) 2014年 kaikeba. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface CertificateCell : UITableViewCell
@property(weak, nonatomic) IBOutlet UILabel *courseNameLabel;
@property(weak, nonatomic) IBOutlet UIImageView *courseImageView;
@property(weak, nonatomic) IBOutlet UILabel *certTypeLabel;
@property(weak, nonatomic) IBOutlet UILabel *dateLabel;

@end
