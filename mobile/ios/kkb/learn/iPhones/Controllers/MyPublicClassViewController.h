//
//  MyPublicClass.h
//  learn
//
//  Created by zxj on 14-7-29.
//  Copyright (c) 2014年 kaikeba. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "KKBBaseViewController.h"

@interface MyPublicClassViewController : KKBBaseViewController<UITableViewDataSource,UITableViewDelegate>{
    NSMutableArray *myPublicArray;
}
@property (strong, nonatomic) IBOutlet UITableView *tableView;

@end
