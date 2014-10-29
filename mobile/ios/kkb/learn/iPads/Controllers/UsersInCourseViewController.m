//
//  UsersInCourseViewController.m
//  learn
//
//  Created by User on 13-7-12.
//  Copyright (c) 2013年 kaikeba. All rights reserved.
//

#import "UsersInCourseViewController.h"
#import "AppUtilities.h"
#import "GlobalOperator.h"
#import "GlobalDefine.h"
#import "UIImageView+WebCache.h"
#import "UsersInCourseOperator.h"
#import "UsersInCourseStructs.h"

@interface UsersInCourseViewController () {
}

@end

// static BOOL const _kNRGridViewSampleCrazyScrollEnabled = NO; // For the lulz.

@implementation UsersInCourseViewController {
    BOOL _firstSectionReloaded; // For reloading sections/cells demo
}

@synthesize teachersAndTas;
@synthesize students;
@synthesize courseId;
@synthesize courseName;

#pragma mark - View lifecycle

- (id)init {
    if (self = [super init]) {
        op = (UsersInCourseOperator *)[[GlobalOperator sharedInstance]
            getOperatorWithModuleType:KAIKEBA_MODULE_USERSINCOURSE];
        self.teachersAndTas = [NSMutableArray array];
        self.students = [NSMutableArray array];
    }

    return self;
}

- (void)loadView {
    [super loadView];

    _gridView = [[NRGridView alloc] init];
    //    if(IS_IOS_7){
    //         _gridView.frame=CGRectMake(0, 20, 768, 748);
    //    }else
    //    {
    _gridView.frame = CGRectMake(0, 0, 871, 748);
    //    }
    _gridView.backgroundColor = [UIColor colorWithRed:224.0 / 255.0
                                                green:224.0 / 255.0
                                                 blue:224.0 / 255.0
                                                alpha:1.0];
    _gridView.delegate = self;
    _gridView.dataSource = self;
    _gridView.showsHorizontalScrollIndicator = NO;
    _gridView.showsVerticalScrollIndicator = NO;
    [_gridView setCellSize:CGSizeMake(430, 120)];
    [self.view addSubview:_gridView];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.

    [op requestTeachersInCourse:self
                          token:DEVELOPER_TOKEN
                       courseId:self.courseId];
    [op requestTasInCourse:self token:DEVELOPER_TOKEN courseId:self.courseId];
    [op requestStudentsInCourse:self
                          token:DEVELOPER_TOKEN
                       courseId:self.courseId];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - NRGridView Data Source

- (NSInteger)numberOfSectionsInGridView:(NRGridView *)gridView {
    return 2;
}
- (CGFloat)gridView:(NRGridView *)gridView
    heightForHeaderInSection:(NSInteger)section {
    return 60;
}
- (NSInteger)gridView:(NRGridView *)gridView
    numberOfItemsInSection:(NSInteger)section {
    return section == 0 ? [self.teachersAndTas count] : [self.students count];
}
- (UIView *)gridView:(NRGridView *)gridView
    viewForHeaderInSection:(NSInteger)section {
    UIView *mySectionView =
        [[UIView alloc] initWithFrame:CGRectMake(0, 0, 871, 60)];
    //    mySectionView.backgroundColor = [UIColor
    //    colorWithPatternImage:[UIImage
    //    imageNamed:@"course_intro_nav_bg_withshadow"]];

    UIImageView *imvView =
        [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, 871, 60)];
    imvView.image = [UIImage imageNamed:@"course_intro_nav_bg_withshadow"];
    [mySectionView addSubview:imvView];

    UILabel *titleLable =
        [[UILabel alloc] initWithFrame:CGRectMake(335, 10, 200, 40)];
    [titleLable setTextAlignment:NSTextAlignmentCenter];
    titleLable.textColor = [UIColor colorWithRed:61.0 / 255.0
                                           green:69.0 / 255.0
                                            blue:76.0 / 255.0
                                           alpha:1.0];
    titleLable.font = [UIFont fontWithName:@"Helvetica" size:18.0];
    titleLable.backgroundColor = [UIColor clearColor];
    if (section == 0) {
        titleLable.text = @"老师和助教";
    } else {
        titleLable.text = @"学生";
    }
    [imvView addSubview:titleLable];
    return mySectionView;
}
//- (NSString *)gridView:(NRGridView *)gridView
//titleForHeaderInSection:(NSInteger)section
//{
//    return section == 0 ? @"老师和助教" : @"学生";
//}

- (NRGridViewCell *)gridView:(NRGridView *)gridView
      cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *GridViewCellIdentifier = @"GridViewCellIdentifier";

    NRGridViewCell *cell =
        [gridView dequeueReusableCellWithIdentifier:GridViewCellIdentifier];

    if (cell == nil) {
        cell = [[NRGridViewCell alloc]
            initWithReuseIdentifier:GridViewCellIdentifier];

        UIImageView *selectedBackgroundView = [[UIImageView alloc] init];
        selectedBackgroundView.backgroundColor = [UIColor clearColor];
        cell.selectionBackgroundView = selectedBackgroundView;

        UIImageView *bgImageView =
            [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, 430, 116)];
        bgImageView.image = [UIImage imageNamed:@"people_bg"];
        [cell addSubview:bgImageView];

        UIImageView *avatarImage =
            [[UIImageView alloc] initWithFrame:CGRectMake(5, 4, 105, 106)];
        avatarImage.tag = 101;
        [bgImageView addSubview:avatarImage];

        UILabel *name =
            [[UILabel alloc] initWithFrame:CGRectMake(120, 20, 200, 21)];
        name.tag = 102;
        name.backgroundColor = [UIColor clearColor];
        [name setTextAlignment:NSTextAlignmentLeft];
        name.numberOfLines = 0;
        name.font = [UIFont boldSystemFontOfSize:16];
        name.textColor = [UIColor colorWithRed:61.0 / 255.0
                                         green:69.0 / 255.0
                                          blue:76.0 / 255.0
                                         alpha:1.0];
        [bgImageView addSubview:name];

        UILabel *short_name =
            [[UILabel alloc] initWithFrame:CGRectMake(120, 45, 200, 21)];
        short_name.tag = 103;
        [short_name setTextAlignment:NSTextAlignmentLeft];
        short_name.font = [UIFont systemFontOfSize:14];
        short_name.textColor = [UIColor colorWithRed:170.0 / 255.0
                                               green:174.0 / 255.0
                                                blue:178.0 / 255.0
                                               alpha:1.0];
        short_name.backgroundColor = [UIColor clearColor];
        [bgImageView addSubview:short_name];

        UILabel *email =
            [[UILabel alloc] initWithFrame:CGRectMake(120, 80, 240, 21)];
        email.tag = 104;
        email.textAlignment = NSTextAlignmentLeft;
        email.font = [UIFont systemFontOfSize:14];
        email.textColor = [UIColor colorWithRed:170.0 / 255.0
                                          green:174.0 / 255.0
                                           blue:178.0 / 255.0
                                          alpha:1.0];
        email.backgroundColor = [UIColor clearColor];
        [bgImageView addSubview:email];
    }

    User *item;

    if (indexPath.section == 0) {
        item = [self.teachersAndTas objectAtIndex:indexPath.row];
    } else {
        item = [self.students objectAtIndex:indexPath.row];
    }

    UIImageView *avatarImage = (UIImageView *)[cell viewWithTag:101];
    [avatarImage sd_setImageWithURL:[NSURL URLWithString:item.avatar_url]
                   placeholderImage:[UIImage imageNamed:@"avatar_default"]];

    UILabel *name = (UILabel *)[cell viewWithTag:102];
    name.text = item.name;

    UILabel *short_name = (UILabel *)[cell viewWithTag:103];
    short_name.text = item.email;

    UILabel *email = (UILabel *)[cell viewWithTag:104];
    email.text = self.courseName;

    return cell;
}

#pragma mark - NRGridView Delegate

- (void)gridView:(NRGridView *)gridView
    didSelectCellAtIndexPath:(NSIndexPath *)indexPath {

    [gridView deselectCellAtIndexPath:indexPath animated:YES];
}

//- (void)gridView:(NRGridView *)gridView
//didLongPressCellAtIndexPath:(NSIndexPath *)indexPath
//{
//    UIMenuController* menuController = [UIMenuController
//    sharedMenuController];
//    NRGridViewCell* cell = [gridView cellAtIndexPath:indexPath];
//
//    [self becomeFirstResponder];
//    [menuController setMenuItems:[NSArray arrayWithObject:[[[UIMenuItem alloc]
//    initWithTitle:@"Hooorayyyy!"
//                                                                                      action:@selector(handleHooray:)] autorelease]]];
//    [menuController setTargetRect:[cell frame]
//                           inView:[self view]];
//
//    [menuController setMenuVisible:YES animated:YES];
//
//}
//
//#pragma mark - UIMenuController Actions
//
//- (void)handleHooray:(id)sender
//{
//    [_gridView unhighlightPressuredCellAnimated:YES];
//}
//
//- (BOOL)canPerformAction:(SEL)action withSender:(id)sender
//{
//    return (action == @selector(handleHooray:));
//}

#pragma mark 网络代理回调

- (void)requestSuccess:(NSString *)cmd {
    if ([cmd compare:HTTP_CMD_COURSE_TEACHERSINCOURSE] == NSOrderedSame) {
        [self.teachersAndTas removeAllObjects];
        [self.teachersAndTas addObjectsFromArray:op.usersInCourse.teachers];
        //        [op requestTasInCourse:self token:[GlobalOperator
        //        sharedInstance].user4Request.user.avatar.token
        //        courseId:self.courseId];
    } else if ([cmd compare:HTTP_CMD_COURSE_TASINCOURSE] == NSOrderedSame) {
        [self.teachersAndTas addObjectsFromArray:op.usersInCourse.tas];

        [_gridView reloadData];
    } else if ([cmd compare:HTTP_CMD_COURSE_STUDENTSINCOURSE] ==
               NSOrderedSame) {
        [self.students removeAllObjects];

        [self.students addObjectsFromArray:op.usersInCourse.students];
        [_gridView reloadData];
    }
}

- (void)requestFailure:(NSString *)cmd errMsg:(NSString *)errMsg {
    [AppUtilities showHUD:errMsg andView:self.view];
}
- (BOOL)shouldAutorotateToInterfaceOrientation:
            (UIInterfaceOrientation)interfaceOrientation {
    return (interfaceOrientation == UIInterfaceOrientationLandscapeLeft ||
            interfaceOrientation == UIInterfaceOrientationLandscapeRight);
}

@end
