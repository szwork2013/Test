//
//  AllCourseCell.m
//  learn
//
//  Created by User on 14-5-7.
//  Copyright (c) 2014年 kaikeba. All rights reserved.
//

#import "AllCourseCell.h"

@implementation AllCourseCell

- (id)initWithFrame:(CGRect)frame{
    self = [super initWithFrame:frame];
    if (self) {
        
        [self.layer setShouldRasterize:YES];
        [self.layer setRasterizationScale:[[UIScreen mainScreen] scale]];
        
        NSArray *arrayOfViews = [[NSBundle mainBundle] loadNibNamed:@"AllCourseCell" owner:self options: nil];
        if(arrayOfViews.count < 1){return nil;}
        if(![[arrayOfViews objectAtIndex:0] isKindOfClass:[UICollectionViewCell class]]){
            return nil;
        }
        self = [arrayOfViews objectAtIndex:0];
        
    }
    return self;
}

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect
{
    // Drawing code
}
*/

@end
