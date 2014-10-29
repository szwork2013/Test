//
//  UIGridCell.h
//  Mall
//
//  Created by yht on 2/19/13.
//  Copyright (c) 2013 Young Alfred. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface UIGridCell : UIView
{
    int rowIndex;
    int colIndex;
}
@property(nonatomic)int rowIndex;
@property(nonatomic)int colIndex;
@end
