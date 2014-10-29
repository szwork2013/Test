//
//  UIGridViewView.m
//  foodling2
//
//  Created by Tanin Na Nakorn on 3/6/12.
//  Copyright 2012 __MyCompanyName__. All rights reserved.
//

#import "UIGridView.h"
#import "UIGridCell.h"



////////////////////////////////////////////////////////////
@implementation UIGridViewRow
@synthesize hGridRowDelegate;
- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    if (self = [super initWithStyle:UITableViewCellStyleDefault reuseIdentifier:reuseIdentifier]) {
		self.selectionStyle = UITableViewCellSelectionStyleNone;
		self.userInteractionEnabled = YES;
        self.backgroundColor = [UIColor clearColor];
	}
    return self;
}

- (void)dealloc {
    [super dealloc];
}

- (void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event
{
    UITouch *touch = [touches anyObject];
    for (UIView *v in self.contentView.subviews) {
        if (v == touch.view && [v isKindOfClass:[UIGridCell class]]) {
            if (hGridRowDelegate && [hGridRowDelegate respondsToSelector:@selector(touchCell:)]) {
                [hGridRowDelegate touchCell:(UIGridCell*)v];
            }
            break;
        }
    }
}

@end

////////////////////////////////////////////////////////////
@implementation UIGridView
@synthesize uiGridViewDelegate;

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        self.delegate = self;
        self.dataSource = self;
        self.separatorStyle = UITableViewCellSeparatorStyleNone;
    }
    return self;
}


- (void)dealloc {
	self.delegate = nil;
	self.dataSource = nil;
	self.uiGridViewDelegate = nil;
    [super dealloc];
}

-(CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    return 60;
}
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return [uiGridViewDelegate numberOfSectionsInUIGridView:self];
}
-(UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
    return [uiGridViewDelegate gridView:self viewForHeaderInSection:section];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    NSInteger count = [uiGridViewDelegate numberOfCellsOfGridView:self];
    NSInteger cols = [uiGridViewDelegate numberOfColumnsOfGridView:self];
    
    return  (count+cols-1) / cols;
}


- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return [uiGridViewDelegate gridView:self heightForRowAt:(int)indexPath.row];
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSString *CellIdentifier = [uiGridViewDelegate identifierOfGridView:self];
    UIGridViewRow *row = (UIGridViewRow *)[tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (row == nil) {
        row = [[[UIGridViewRow alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier] autorelease];
        row.hGridRowDelegate = self;
    }
	
	NSInteger numCols = [uiGridViewDelegate numberOfColumnsOfGridView:self];
    NSInteger count = [uiGridViewDelegate numberOfCellsOfGridView:self];
	
	CGFloat x = 0.0;
	CGFloat height = [uiGridViewDelegate gridView:self heightForRowAt:(int)indexPath.row];
	
	for (int i=0;i<numCols;i++) {
		UIGridCell *cell = [uiGridViewDelegate gridView:self cell:(UIGridCell*)[row viewWithTag:0xaa01+i] cellForRowAt:(int)indexPath.row AndColumnAt:i];
        [row.contentView addSubview:cell];
        
		cell.rowIndex = (int)indexPath.row;
		cell.colIndex = i;
        cell.tag = 0xaa01 + i;
		
		CGFloat thisWidth = [uiGridViewDelegate gridView:self widthForColumnAt:i];
		cell.frame = CGRectMake(x, 0, thisWidth, height);
		x += thisWidth;
        
        if (indexPath.row*numCols+i < count) {
            cell.hidden = NO;
        }else {
            cell.hidden = YES;
        }
	}
	
	row.frame = CGRectMake(row.frame.origin.x,
							row.frame.origin.y,
							x,
							height);
	
    return row;
}

- (void)touchCell:(UIGridCell*)gridCell
{
    if (uiGridViewDelegate && [uiGridViewDelegate respondsToSelector:@selector(gridView: didSelectRowAt: AndColumnAt:)])
    {
        [uiGridViewDelegate gridView:self didSelectRowAt:gridCell.rowIndex AndColumnAt:gridCell.colIndex];
    }
}

@end
