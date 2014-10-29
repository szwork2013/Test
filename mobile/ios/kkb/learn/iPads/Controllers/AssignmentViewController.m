//
//  AssignmentViewController.m
//  learn
//
//  Created by User on 13-12-26.
//  Copyright (c) 2013年 kaikeba. All rights reserved.
//

#import "AssignmentViewController.h"
#import "AppUtilities.h"
#import "GlobalOperator.h"
#import "GlobalDefine.h"
#import "AssignmentOperator.h"
#import "AssignmentInCourseStructs.h"
#import "AppDelegate.h"
#import "AssignmentDetailViewController.h"

@interface AssignmentViewController ()

@end

@implementation AssignmentViewController
@synthesize courseId, arrAssignmentBefore, arrAssignmentFuture,
    assignmentTableView;

- (id)initWithNibName:(NSString *)nibNameOrNil
               bundle:(NSBundle *)nibBundleOrNil {
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
        op = (AssignmentOperator *)[[GlobalOperator sharedInstance]
            getOperatorWithModuleType:KAIKEBA_MODULE_ASSIGNMENT];
        self.arrAssignmentBefore = [NSMutableArray array];
        self.arrAssignmentFuture = [NSMutableArray array];
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.

    [op requestAssignments:self
                     token:[GlobalOperator sharedInstance]
                               .user4Request.user.avatar.token
                  courseId:self.courseId];

    assignmentTableView.delegate = self;
    assignmentTableView.dataSource = self;
    assignmentTableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    assignmentTableView.backgroundColor = [UIColor clearColor];
    assignmentTableView.showsVerticalScrollIndicator = NO;
    //        discussionTableView.contentSize =
    //        CGSizeMake(discussionTableView.frame.size.width,1000);

    UIView *footView = [[UIView alloc] init];
    footView.frame = CGRectMake(0, 0, 768, 100);
    footView.backgroundColor = [UIColor clearColor];
    [assignmentTableView setTableFooterView:footView];
    AppDelegate *delegant =
        (AppDelegate *)[[UIApplication sharedApplication] delegate];
    if (delegant.isFromActivityMes == YES) {
        [AppUtilities showLoading:@"加载作业中..." andView:self.view];
    }
}
//- (void)makeAnnouncementBlankView
//{
//    announcementBlankView = [[UIView alloc] initWithFrame:CGRectMake(0, 0,
//    768, 748)];
//    [self.view addSubview:announcementBlankView];
//    [announcementBlankView release];
//
//    UILabel *promptLabel = [[UILabel alloc] init];
//    promptLabel.frame = CGRectMake(0, 280, 768, 60);
//    promptLabel.backgroundColor = [UIColor clearColor];
//    promptLabel.textAlignment = NSTextAlignmentCenter;
//    promptLabel.textColor = [UIColor grayColor];
//    promptLabel.font = [UIFont boldSystemFontOfSize:22];
//    promptLabel.text = @"暂时还没有作业哦！去其它地方逛逛吧~~";
//    [announcementBlankView addSubview:promptLabel];
//    [promptLabel release];
//}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
- (void)requestSuccess:(NSString *)cmd {
    if ([cmd compare:HTTP_CMD_COURSE_ASSIGNMENT] == NSOrderedSame) {
        //        self.discussionsArray =
        //        op.discussionTopic.discussionsItemArray;

        for (
            AssignmentItem *item in op.assignmentStructs.assignmentsItemArray) {
            id atValue = item.due_at;
            id unlockValue = item.unlock_at;
            id lockValue = item.lock_at;
            if (atValue != [NSNull null] &&
                [AppUtilities isLaterCurrentSystemDate:item.due_at]) {
                [self.arrAssignmentFuture addObject:item];
            } else if (unlockValue != [NSNull null] &&
                       [AppUtilities isLaterCurrentSystemDate:item.unlock_at]) {
                [self.arrAssignmentFuture addObject:item];
            } else if (lockValue != [NSNull null] &&
                       [AppUtilities isLaterCurrentSystemDate:item.lock_at]) {
                [self.arrAssignmentFuture addObject:item];
            } else {
                [self.arrAssignmentBefore addObject:item];
            }
        }
        //        NSLog(@"arrAssignmentFuture = %@",arrAssignmentFuture);
        //        NSLog(@"arrAssignmentBefore = %@",arrAssignmentBefore);

        AppDelegate *delegant =
            (AppDelegate *)[[UIApplication sharedApplication] delegate];
        if (delegant.isFromActivityMes == YES) {
            NSLog(@"delegant.annStr=====%@", delegant.annStr);
            AssignmentDetailViewController *announcementDetailViewController =
                [[AssignmentDetailViewController alloc] init];
            for (NSInteger i = 0; i < self.arrAssignmentFuture.count; i++) {
                AssignmentItem *item =
                    [self.arrAssignmentFuture objectAtIndex:i];
                if ([delegant.annStr intValue] == [item._id intValue]) {
                    announcementDetailViewController.assignmentItem = item;
                    announcementDetailViewController.selectIndex = i;
                    announcementDetailViewController.assArr =
                        self.arrAssignmentFuture;
                    break;
                }
            }
            for (NSInteger i = 0; i < self.arrAssignmentBefore.count; i++) {
                AssignmentItem *item =
                    [self.arrAssignmentBefore objectAtIndex:i];
                if ([delegant.annStr intValue] == [item._id intValue]) {
                    announcementDetailViewController.assignmentItem = item;
                    announcementDetailViewController.selectIndex = i;
                    announcementDetailViewController.assArr =
                        self.arrAssignmentBefore;
                    break;
                }
            }

            [AppUtilities closeLoading:self.view];
            [self.navigationController
                pushViewController:announcementDetailViewController
                          animated:NO];
        }

        [assignmentTableView reloadData];
    }
}

- (void)requestFailure:(NSString *)cmd errMsg:(NSString *)errMsg {
    if ([cmd compare:HTTP_CMD_COURSE_ASSIGNMENT] == NSOrderedSame) {
        [AppUtilities closeLoading:assignmentTableView];
    }

    [AppUtilities showHUD:errMsg andView:self.view];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:
            (UIInterfaceOrientation)interfaceOrientation {
    return (interfaceOrientation == UIInterfaceOrientationLandscapeLeft ||
            interfaceOrientation == UIInterfaceOrientationLandscapeRight);
}

#pragma mark - Table view data source

- (UIView *)tableView:(UITableView *)tableView
    viewForHeaderInSection:(NSInteger)section {
    UIView *mySectionView =
        [[UIView alloc] initWithFrame:CGRectMake(0, 0, 851, 81)];
    mySectionView.backgroundColor = [UIColor colorWithRed:224.0 / 255.0
                                                    green:224.0 / 255.0
                                                     blue:224.0 / 255.0
                                                    alpha:1.0];

    //    UIImageView *imvShowView = [[[UIImageView
    //    alloc]initWithFrame:CGRectMake(0, 0, 768, 10)] autorelease];
    //    imvShowView.image = [UIImage imageNamed:@"bg_nav_shadow.png"];
    //    [mySectionView addSubview:imvShowView];

    UIView *imvView = [[UIView alloc] initWithFrame:CGRectMake(0, 10, 871, 71)];
    imvView.backgroundColor = [UIColor whiteColor];
    [mySectionView addSubview:imvView];

    UILabel *titleLable =
        [[UILabel alloc] initWithFrame:CGRectMake(15, 15, 200, 40)];
    [titleLable setTextAlignment:NSTextAlignmentLeft];
    titleLable.font = [UIFont fontWithName:@"Helvetica" size:21.0];
    titleLable.backgroundColor = [UIColor clearColor];
    if (section == 0) {
        titleLable.textColor = [UIColor colorWithRed:254.0 / 255.0
                                               green:93.0 / 255.0
                                                blue:93.0 / 255.0
                                               alpha:1.0];
        titleLable.text = @"即将到来的作业";
    } else if (section == 1) {
        titleLable.textColor = [UIColor colorWithRed:61.0 / 255.0
                                               green:69.0 / 255.0
                                                blue:76.0 / 255.0
                                               alpha:1.0];
        titleLable.text = @"以前的作业";
    }
    [imvView addSubview:titleLable];
    return mySectionView;
}
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {

    return 2;
}
- (CGFloat)tableView:(UITableView *)tableView
    heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 65;
}

- (CGFloat)tableView:(UITableView *)tableView
    heightForHeaderInSection:(NSInteger)section {
    return 81;
}
- (NSInteger)tableView:(UITableView *)tableView
    numberOfRowsInSection:(NSInteger)section {
    if (section == 0) {
        return self.arrAssignmentFuture.count;
    } else if (section == 1) {
        return self.arrAssignmentBefore.count;
    }
    return 0;
}
- (UITableViewCell *)tableView:(UITableView *)tableView
         cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    NSString *cellIdentifier = @"CellIdentifier";
    UITableViewCell *cell =
        [tableView dequeueReusableCellWithIdentifier:cellIdentifier];

    if (cell == nil) {
        NSArray *arr = [[NSBundle mainBundle] loadNibNamed:@"AssignmentCell"
                                                     owner:self
                                                   options:nil];
        cell = [arr objectAtIndex:0];
    }
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    cell.backgroundColor = [UIColor clearColor];
    cell.contentView.backgroundColor =
        [UIColor colorWithPatternImage:[UIImage imageNamed:@"item_bg_ass"]];

    UILabel *titleLable = (UILabel *)[cell viewWithTag:401];
    UILabel *timeLable = (UILabel *)[cell viewWithTag:402];
    UILabel *pointsLable = (UILabel *)[cell viewWithTag:403];

    AssignmentItem *item = nil;

    //    if(self.arrAssignmentFuture.count == 0)
    //    {
    //        NSString *CellIdentifier2 = [NSString
    //        stringWithFormat:@"Cell%d%d", [indexPath section], [indexPath
    //        row]];
    //        UITableViewCell* cell2 = [[[UITableViewCell alloc]
    //        initWithStyle:UITableViewCellStyleDefault
    //        reuseIdentifier:CellIdentifier2] autorelease];
    //        cell2.frame = CGRectMake(0, 0, 748, 15);
    //        cell2.backgroundColor = [UIColor clearColor];
    //
    //        return cell2;
    //    }

    if (indexPath.section == 0 && self.arrAssignmentFuture.count > 0) {
        item = [self.arrAssignmentFuture objectAtIndex:indexPath.row];

    } else if (indexPath.section == 1 && self.arrAssignmentBefore.count > 0) {

        item = [self.arrAssignmentBefore objectAtIndex:indexPath.row];
    }

    if (item != nil) {
        titleLable.text = item.name;
        id atValue = item.due_at;
        id unlockValue = item.unlock_at;
        id lockValue = item.lock_at;

        //        NSLog(@"assignmentItem.due_at== %@",item.due_at);
        //        NSLog(@"assignmentItem.unlock_at== %@",item.unlock_at);
        //        NSLog(@"assignmentItem.lock_at== %@",item.lock_at);

        if (atValue != [NSNull null] &&
            [AppUtilities isLaterCurrentSystemDate:item.due_at]) {
            timeLable.text = [AppUtilities convertTimeStyleTo:item.due_at];
        } else if (unlockValue != [NSNull null] &&
                   [AppUtilities isLaterCurrentSystemDate:item.unlock_at]) {
            timeLable.text = [AppUtilities convertTimeStyleTo:item.unlock_at];
        } else if (lockValue != [NSNull null] &&
                   [AppUtilities isLaterCurrentSystemDate:item.lock_at]) {
            timeLable.text = [AppUtilities convertTimeStyleTo:item.lock_at];
        } else {
            timeLable.text = @"";
        }

        pointsLable.text = [NSString stringWithFormat:@"满分%@分", item.points];
    }
    return cell;
}
- (void)tableView:(UITableView *)tableView
    didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    AssignmentItem *item = nil;

    if (indexPath.section == 0) {
        item = [self.arrAssignmentFuture objectAtIndex:indexPath.row];
        AssignmentDetailViewController *controller =
            [[AssignmentDetailViewController alloc]
                initWithNibName:@"AssignmentDetailViewController"
                         bundle:nil];
        controller.assignmentItem = item;
        controller.assArr = self.arrAssignmentFuture;
        controller.selectIndex = indexPath.row;

        [self.navigationController pushViewController:controller animated:YES];
    } else if (indexPath.section == 1) {
        item = [self.arrAssignmentBefore objectAtIndex:indexPath.row];
        AssignmentDetailViewController *controller =
            [[AssignmentDetailViewController alloc]
                initWithNibName:@"AssignmentDetailViewController"
                         bundle:nil];
        controller.assignmentItem = item;
        controller.assArr = self.arrAssignmentBefore;
        controller.selectIndex = indexPath.row;

        [self.navigationController pushViewController:controller animated:YES];
    }

    [tableView deselectRowAtIndexPath:indexPath animated:YES];
}

@end
