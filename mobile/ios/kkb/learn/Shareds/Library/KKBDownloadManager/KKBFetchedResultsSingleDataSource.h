//
//  KKBFetchedResultsSingleDataSource.h
//  VideoDownload
//
//  Created by zengmiao on 9/10/14.
//  Copyright (c) 2014 zengmiao. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef void (^TableViewCellConfigureBlock)(id cell, id item);

@interface KKBFetchedResultsSingleDataSource : NSObject <UITableViewDataSource>

@property(strong, nonatomic) NSArray *items;

- (id)initWithClassID:(NSNumber *)classID
                 items:(NSArray *)items
              tableView:(UITableView *)tableView
        cellIdentifier:(NSString *)aCellIdentifier
    configureCellBlock:(TableViewCellConfigureBlock)aConfigureCellBlock;

- (void)removeDelegate;

- (void)addDelegate;

@end
