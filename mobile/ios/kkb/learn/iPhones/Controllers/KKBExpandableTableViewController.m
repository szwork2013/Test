//
//  KKBExpandableTableViewController.m
//  learn
//
//  Created by zengmiao on 9/15/14.
//  Copyright (c) 2014 kaikeba. All rights reserved.
//

#import "KKBExpandableTableViewController.h"

@interface KKBExpandableTableViewController ()

@end

@implementation KKBExpandableTableViewController

- (id)initWithNibName:(NSString *)nibNameOrNil
               bundle:(NSBundle *)nibBundleOrNil {
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.

    _expandableSections = [NSMutableIndexSet indexSet];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Property
- (SLExpandableTableView *)tableView {
    if (!_tableView) {
        _tableView =
            [[SLExpandableTableView alloc] initWithFrame:self.view.bounds
                                                   style:UITableViewStylePlain];
        _tableView.delegate = self;
        _tableView.autoresizingMask =
            UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    }
    return _tableView;
}

#pragma mark - UITableViewDelegate

- (CGFloat)tableView:(UITableView *)tableView
    heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.row == 0) {
        // section
        return gDownloadSectionCell + 1;
    } else {
        // row
        return gDownloadStatusCell + 1;
    }
}

- (CGFloat)tableView:(UITableView *)tableView
    estimatedHeightForRowAtIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.row == 0) {
        // section
        return gDownloadSectionCell + 1;
    } else {
        // row
        return gDownloadStatusCell + 1;
    }
}

- (void)tableView:(UITableView *)tableView
    didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:NO];
}

#pragma mark - SLExpandableTableViewDelegate

- (void)tableView:(SLExpandableTableView *)tableView
    downloadDataForExpandableSection:(NSInteger)section {
    [self.expandableSections addIndex:section];
    [tableView expandSection:section animated:YES];
}

- (void)tableView:(SLExpandableTableView *)tableView
    didCollapseSection:(NSUInteger)section
              animated:(BOOL)animated {
    [self.expandableSections removeIndex:section];
}
/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little
preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
