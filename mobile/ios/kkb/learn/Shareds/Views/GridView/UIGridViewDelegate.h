//
//  UIGridViewDelegate.h
//  foodling2
//
//  Created by Tanin Na Nakorn on 3/6/12.
//  Copyright 2012 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>

@class UIGridView;
@class UIGridCell;
@protocol UIGridViewDelegate <NSObject>

@optional
- (void) gridView:(UIGridView *)grid didSelectRowAt:(int)rowIndex AndColumnAt:(int)columnIndex;


@required
- (CGFloat) gridView:(UIGridView *)grid widthForColumnAt:(int)columnIndex;
- (CGFloat) gridView:(UIGridView *)grid heightForRowAt:(int)rowIndex;
- (NSInteger)numberOfCellsOfGridView:(UIGridView *)grid;
- (NSInteger)numberOfColumnsOfGridView:(UIGridView *) grid;
- (NSString*)identifierOfGridView:(UIGridView*)grid;
- (UIGridCell *) gridView:(UIGridView *)grid cell:(UIGridCell*)cell cellForRowAt:(int)rowIndex AndColumnAt:(int)columnIndex;
-(UIView *)gridView:(UIGridView *)grid viewForHeaderInSection:(NSInteger)section;
- (NSInteger)numberOfSectionsInUIGridView:(UIGridView *) grid;
@end

