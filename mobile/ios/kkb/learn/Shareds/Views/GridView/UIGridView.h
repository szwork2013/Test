//
//  UIGridView.h
//  foodling2
//
//  Created by Tanin Na Nakorn on 3/6/12.
//  Copyright 2012 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "UIGridViewDelegate.h"

////////////////////////////////////////////////////////////
@class UIGridViewRow;
@protocol UIGridViewRowDelegate <NSObject>
@optional
- (void)touchCell:(UIGridCell*)cell;
@end

@interface UIGridViewRow : UITableViewCell {
    id<UIGridViewRowDelegate> hGridRowDelegate;
}
@property(nonatomic,assign)id<UIGridViewRowDelegate> hGridRowDelegate;
@end

////////////////////////////////////////////////////////////
@interface UIGridView : UITableView<UITableViewDelegate, UITableViewDataSource, UIGridViewRowDelegate> {
}

@property (nonatomic, assign)  id<UIGridViewDelegate> uiGridViewDelegate;

@end





