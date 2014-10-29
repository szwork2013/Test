//
//  MyCorseCell.m
//  learn
//
//  Created by kaikeba on 13-4-15.
//  Copyright (c) 2013年 kaikeba. All rights reserved.
//

#import "MyCourseCell.h"

@implementation MyCourseCell


- (id)initWithFrame:(CGRect)frame{
    self = [super initWithFrame:frame];
    if (self) {
        
        [self.layer setShouldRasterize:YES];
        [self.layer setRasterizationScale:[[UIScreen mainScreen] scale]];

        NSArray *arrayOfViews = [[NSBundle mainBundle] loadNibNamed:@"MyCoursesCell" owner:self options: nil];
        if(arrayOfViews.count < 1){return nil;}
        if(![[arrayOfViews objectAtIndex:0] isKindOfClass:[UICollectionViewCell class]]){
            return nil;
        }
        self = [arrayOfViews objectAtIndex:0];
        
    }
    return self;
}


@end
