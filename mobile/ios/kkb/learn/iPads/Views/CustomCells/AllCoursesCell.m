//
//  AllCorseCell.m
//  learn
//
//  Created by kaikeba on 13-4-23.
//  Copyright (c) 2013年 kaikeba. All rights reserved.
//

#import <QuartzCore/QuartzCore.h>
#import "AllCoursesCell.h"
#import "GlobalDefine.h"

#define isRetinaPad ([UIScreen instancesRespondToSelector:@selector(currentMode)] ? CGSizeEqualToSize(CGSizeMake(2048, 1536), [[UIScreen mainScreen] currentMode].size) : NO)
@implementation AllCoursesCell


- (id)initWithFrame:(CGRect)frame  
{
    if (self = [super initWithFrame:frame])
    {
    
        [self.layer setShouldRasterize:YES];
        [self.layer setRasterizationScale:[[UIScreen mainScreen] scale]];
        self.backgroundColor = [UIColor clearColor];
        
        self.layer.masksToBounds = NO;
        self.layer.cornerRadius = 8; // if you like rounded corners
        self.layer.shadowOffset = CGSizeMake(0, 1);
        self.layer.shadowRadius = 1;
        self.layer.shadowOpacity = 0.1;
        
        UIImageView *coverImage = [[UIImageView alloc] initWithFrame:CGRectMake(10, 10, 243, 157)];
        [coverImage setClipsToBounds:YES];
        coverImage.contentMode = UIViewContentModeScaleAspectFill;
        coverImage.tag = 101;
        [self addSubview:coverImage];
        
        /*
        //开始日期的背景图
        UIImageView *startDateBg = [[UIImageView alloc] initWithFrame:CGRectMake(5, 9, 254, 295)];
        startDateBg.image = [UIImage imageNamed:@"cover_course_red.png"];
        startDateBg.tag = 102;
        [self addSubview:startDateBg];
        [startDateBg release];
        
        UIImageView *instructorAvatar = [[UIImageView alloc] initWithFrame:CGRectMake(22, 250, 45, 45)];
        instructorAvatar.tag = 103;
        [self addSubview:instructorAvatar];
        [instructorAvatar release];
    
        //开始日期
        UILabel *startDate = [[UILabel alloc] initWithFrame:CGRectMake(173, 28, 100, 40)];
        startDate.backgroundColor = [UIColor clearColor];
        startDate.textColor = [UIColor whiteColor];
        startDate.numberOfLines = 0;
        startDate.font = [UIFont boldSystemFontOfSize:15];
        startDate.textAlignment = NSTextAlignmentCenter;
        startDate.tag = 104;
        startDate.layer.transform = CATransform3DRotate(startDate.layer.transform, 3.1415 * 0.25, 0, 0, 1);
        [self addSubview:startDate];
        [startDate release];
        */
        UIView *bgView = [[UIView alloc] init];
        if(isRetinaPad){
          bgView.frame =  CGRectMake(10, 167, 243, 160);
        }else if(isRetinaForMINI)
        {
            bgView.frame =  CGRectMake(10, 167, 243, 160);
        }
        else
        {
             bgView.frame =CGRectMake(11, 167, 241, 160);
        }
        bgView.backgroundColor = [UIColor whiteColor];
        bgView.userInteractionEnabled = NO;
        [self addSubview:bgView];

        UILabel *startDate = [[UILabel alloc] initWithFrame:CGRectMake(10, 89, 150, 21)];
        startDate.backgroundColor = [UIColor clearColor];
        startDate.textColor = [UIColor colorWithRed:61.0/255 green:69.0/255 blue:76.0/255 alpha:1.0];
        startDate.numberOfLines = 1;
        startDate.font = [UIFont systemFontOfSize:12];
        startDate.textAlignment = NSTextAlignmentLeft;
        startDate.tag = 104;
        [bgView addSubview:startDate];

        UILabel *schoolName = [[UILabel alloc] initWithFrame:CGRectMake(10, 72, 150, 21)];
        schoolName.backgroundColor = [UIColor clearColor];
        schoolName.textColor = [UIColor colorWithRed:61.0/255 green:69.0/255 blue:76.0/255 alpha:1.0];
        schoolName.font = [UIFont systemFontOfSize:12];
        schoolName.textAlignment = NSTextAlignmentLeft;
        schoolName.lineBreakMode = NSLineBreakByTruncatingTail;
        schoolName.tag = 105;
        [bgView addSubview:schoolName];

        UILabel *courseName = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, 0, 0)];
        courseName.backgroundColor = [UIColor clearColor];
     
         [courseName setNumberOfLines:0];
        courseName.textColor = [UIColor colorWithRed:61.0/255 green:69.0/255 blue:76.0/255 alpha:1.0];
        courseName.font = [UIFont systemFontOfSize:21];
        courseName.lineBreakMode = NSLineBreakByTruncatingTail;
        courseName.tag = 106;
        [bgView addSubview:courseName];

        UILabel *abstract = [[UILabel alloc] initWithFrame:CGRectMake(9, 111, 224,44 )];
        abstract.backgroundColor = [UIColor clearColor];
        abstract.textColor = [UIColor colorWithRed:170.0/255 green:174.0/255 blue:178.0/255 alpha:1.0];
         abstract.numberOfLines = 2;
        abstract.font = [UIFont systemFontOfSize:14];
        abstract.tag = 107;
        [bgView addSubview:abstract];
    }
    
    return self;
}

@end
