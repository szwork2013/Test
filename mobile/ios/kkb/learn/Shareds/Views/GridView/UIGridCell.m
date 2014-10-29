//
//  UIGridCell.m
//  Mall
//
//  Created by yht on 2/19/13.
//  Copyright (c) 2013 Young Alfred. All rights reserved.
//

#import "UIGridCell.h"

@implementation UIGridCell
@synthesize rowIndex;
@synthesize colIndex;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [self initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
        self.backgroundColor = [UIColor clearColor];
         self.userInteractionEnabled = YES;
        
    }
    return self;
    
}

- (id)initWithFrame:(CGRect)frame
{
    if (self = [super initWithFrame:frame]) {
        self.userInteractionEnabled = YES;        
    }
    return self;
}
@end
