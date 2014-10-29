//
//  AnnouncementViewController.m
//  learn
//
//  Created by User on 13-7-11.
//  Copyright (c) 2013年 kaikeba. All rights reserved.
//

#import "AnnouncementViewController.h"
#import "AppUtilities.h"
#import "GlobalOperator.h"
#import "GlobalDefine.h"
#import "DiscussionTopicStructs.h"
#import "AnnouncementOperator.h"
#import "UIImageView+WebCache.h"
#import "AnnouncementDetailViewController.h"
#import "AppDelegate.h"

@interface AnnouncementViewController ()

@end

@implementation AnnouncementViewController

@synthesize announcementsArray;
@synthesize courseId;

@synthesize announcementTableView;

#pragma mark - View lifecycle

- (id)initWithNibName:(NSString *)nibNameOrNil
               bundle:(NSBundle *)nibBundleOrNil {
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        op = (AnnouncementOperator *)[[GlobalOperator sharedInstance]
            getOperatorWithModuleType:KAIKEBA_MODULE_ANNOUNCEMENT];
    }
    return self;
}
/*
- (id)init
{
    if (self = [super init])
    {
        op = (AnnouncementOperator *)[[GlobalOperator sharedInstance]
getOperatorWithModuleType:KAIKEBA_MODULE_ANNOUNCEMENT];
    }

    return self;
}
*/
/*
- (void)loadView
{
    [super loadView];

    self.view.frame =  CGRectMake(0, 0, 768, 748);
//    self.view.backgroundColor = [UIColor colorWithPatternImage:[UIImage
imageNamed:@"courseunit_bg.png"]];
//    if(IS_IOS_7){
//    titleView = [[UIView alloc] initWithFrame:CGRectMake(0, 20, 768, 44)];
//    }else
//    {
    titleView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 768, 60)];
//    }
    headerLabel = [[UILabel alloc] init];
//    if(IS_IOS_7){
//     headerLabel.frame = CGRectMake(-150, 0, 768, 44);
//    }else
//    {
//      headerLabel.frame = CGRectMake(0, 0, 768, 44);
//    }
//    headerLabel.text = @"通告";
//    headerLabel.textAlignment = NSTextAlignmentCenter;
//    headerLabel.font = [UIFont boldSystemFontOfSize:22];
//    headerLabel.backgroundColor = [UIColor clearColor];
//    headerLabel.textColor = [UIColor blackColor];
//    [titleView addSubview:headerLabel];
//      [headerLabel release];
    //    headerLabel.shadowColor = [UIColor whiteColor];
    //    headerLabel.shadowOffset = CGSizeMake(1, 0);
    self.navigationItem.titleView = titleView;
//    self.navigationItem.title =  @"通告";
    [titleView release];

    UIImage *img = [UIImage imageNamed:@"title_bar.png"];
//      if(IS_IOS_7){
//    self.navigationController.navigationBar.frame = CGRectMake(0, 20, 768,
44);
//      }else
//      {
           self.navigationController.navigationBar.frame = CGRectMake(0, 0, 768,
60);
//      }
    [self.navigationController.navigationBar setBackgroundImage:img
forBarMetrics:UIBarMetricsDefault];



    //748-44
    announcementTableView = [[UITableView alloc] initWithFrame:CGRectMake(5, 0,
758, 704) style:UITableViewStylePlain];
    announcementTableView.delegate = self;
    announcementTableView.dataSource = self;
    announcementTableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    //    announcementTableView.backgroundColor = [UIColor
colorWithPatternImage:[UIImage imageNamed:@"courseunit_bg.png"]];
    announcementTableView.backgroundColor = [UIColor clearColor];
    [self.view addSubview:announcementTableView];
    [announcementTableView release];
    AppDelegate* delegant= (AppDelegate*)[[UIApplication
sharedApplication]delegate];
    if(delegant.isFromActivity == YES){
       [ToolsObject showLoading:@"加载通告中..." andView:announcementTableView];
    }

}
 */
- (void)viewWillAppear:(BOOL)animated {
    //    if(IS_IOS_7){
    //        headerLabel.frame = CGRectMake(-150, 0, 768, 44);
    //        [titleView addSubview:headerLabel];
    //        self.navigationItem.titleView = titleView;
    //    }
}
- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.

    [op requestAnnouncements:self
                       token:[GlobalOperator sharedInstance]
                                 .user4Request.user.avatar.token
                    courseId:self.courseId];

    announcementTableView.delegate = self;
    announcementTableView.dataSource = self;
    announcementTableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    announcementTableView.backgroundColor = [UIColor clearColor];
    AppDelegate *delegant =
        (AppDelegate *)[[UIApplication sharedApplication] delegate];
    if (delegant.isFromActivityAnn == YES) {
        [AppUtilities showLoading:@"加载通告中..." andView:self.view];
    }
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)makeAnnouncementBlankView {
    announcementBlankView =
        [[UIView alloc] initWithFrame:CGRectMake(0, 0, 871, 748)];
    [self.view addSubview:announcementBlankView];

    UILabel *promptLabel = [[UILabel alloc] init];
    promptLabel.frame = CGRectMake(50, 280, 768, 60);
    promptLabel.backgroundColor = [UIColor clearColor];
    promptLabel.textAlignment = NSTextAlignmentCenter;
    promptLabel.textColor = [UIColor grayColor];
    promptLabel.font = [UIFont boldSystemFontOfSize:22];
    promptLabel.text = @"暂时还没有通告哦！去其它地方逛逛吧~~";
    [announcementBlankView addSubview:promptLabel];
}

#pragma mark - UITableViewDelegate

- (NSInteger)tableView:(UITableView *)tableView
    numberOfRowsInSection:(NSInteger)section {
    return [self.announcementsArray count];
}

- (CGFloat)tableView:(UITableView *)tableView
    heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 110;
}

- (UITableViewCell *)tableView:(UITableView *)tableView
         cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    if ([self.announcementsArray count] > 0) {
        static NSString *CellAnnouncementIdentifier =
            @"CellAnnouncementIdentifier";
        UITableViewCell *cell = [tableView
            dequeueReusableCellWithIdentifier:CellAnnouncementIdentifier];

        if (cell == nil) {
            cell = [[UITableViewCell alloc]
                  initWithStyle:UITableViewCellStyleDefault
                reuseIdentifier:CellAnnouncementIdentifier];
            cell.selectionStyle = UITableViewCellSelectionStyleNone;
            //            UIImageView *selectedBackgroundView = [[UIImageView
            //            alloc] init];
            //            selectedBackgroundView .backgroundColor = [UIColor
            //            colorWithPatternImage:[UIImage
            //            imageNamed:@"annoucement_bg_selected.png"]];
            //            cell.selectedBackgroundView = selectedBackgroundView;
            //            [selectedBackgroundView release];
            cell.backgroundColor = [UIColor clearColor];
            cell.contentView.backgroundColor = [UIColor clearColor];
            //            cell.layer.masksToBounds = NO;
            //            cell.layer.cornerRadius = 8; // if you like rounded
            //            corners
            //            cell.layer.shadowOffset = CGSizeMake(0, 1);
            //            cell.layer.shadowRadius = 1;
            //            cell.layer.shadowOpacity = 0.1;

            UIImageView *bgImageView =
                [[UIImageView alloc] initWithFrame:CGRectMake(0, 10, 851, 105)];
            bgImageView.backgroundColor = [UIColor whiteColor];
            [cell.contentView addSubview:bgImageView];

            UIImageView *avatarImage =
                [[UIImageView alloc] initWithFrame:CGRectMake(15, 8, 75, 75)];
            avatarImage.tag = 101;
            [bgImageView addSubview:avatarImage];

            //            UIImageView *downloadImage = [[UIImageView alloc]
            //            initWithFrame:CGRectMake(210, 15, 25, 25)];
            UIImageView *downloadImage = [[UIImageView alloc] init];
            downloadImage.tag = 107;
            downloadImage.image = [UIImage imageNamed:@"icon_download"];
            [bgImageView addSubview:downloadImage];

            //            UILabel *announcementTitle = [[UILabel alloc]
            //            initWithFrame:CGRectMake(105, 8, 100, 40)];
            UILabel *announcementTitle =
                [[UILabel alloc] initWithFrame:CGRectMake(0, 0, 0, 0)];
            [announcementTitle setNumberOfLines:0];
            announcementTitle.tag = 102;
            announcementTitle.backgroundColor = [UIColor clearColor];
            [announcementTitle setTextAlignment:NSTextAlignmentLeft];
            announcementTitle.numberOfLines = 1;
            announcementTitle.font = [UIFont systemFontOfSize:16];
            announcementTitle.textColor = [UIColor colorWithRed:61.0 / 255
                                                          green:69.0 / 255
                                                           blue:76.0 / 255
                                                          alpha:1];
            [bgImageView addSubview:announcementTitle];

            UILabel *user_name =
                [[UILabel alloc] initWithFrame:CGRectMake(105, 45, 300, 21)];
            user_name.tag = 103;
            [user_name setTextAlignment:NSTextAlignmentLeft];
            user_name.font = [UIFont systemFontOfSize:14];
            user_name.textColor = [UIColor colorWithRed:61.0 / 255
                                                  green:69.0 / 255
                                                   blue:76.0 / 255
                                                  alpha:1];
            user_name.backgroundColor = [UIColor clearColor];
            [bgImageView addSubview:user_name];

            UILabel *posted_at =
                [[UILabel alloc] initWithFrame:CGRectMake(700, 15, 160, 21)];
            posted_at.tag = 104;
            [posted_at setTextAlignment:NSTextAlignmentLeft];
            posted_at.font = [UIFont systemFontOfSize:14];
            posted_at.textColor = [UIColor colorWithRed:170.0 / 255
                                                  green:174.0 / 255
                                                   blue:178.0 / 255
                                                  alpha:1];
            posted_at.backgroundColor = [UIColor clearColor];
            [bgImageView addSubview:posted_at];

            UILabel *message =
                [[UILabel alloc] initWithFrame:CGRectMake(105, 67, 620, 21)];
            message.tag = 106;
            [message setTextAlignment:NSTextAlignmentLeft];
            message.font = [UIFont systemFontOfSize:14];
            message.textColor = [UIColor colorWithRed:170.0 / 255
                                                green:174.0 / 255
                                                 blue:178.0 / 255
                                                alpha:1];
            message.backgroundColor = [UIColor clearColor];
            [bgImageView addSubview:message];

            //            UILabel *discussion_subentry_count = [[UILabel alloc]
            //            initWithFrame:CGRectMake(245, 18, 41, 19)];
            UILabel *discussion_subentry_count = [[UILabel alloc] init];
            discussion_subentry_count.tag = 105;
            discussion_subentry_count.textAlignment = NSTextAlignmentCenter;
            discussion_subentry_count.font = [UIFont boldSystemFontOfSize:14];
            discussion_subentry_count.textColor = [UIColor whiteColor];
            discussion_subentry_count.backgroundColor = [UIColor
                colorWithPatternImage:[UIImage imageNamed:@"amount_bg"]];
            [bgImageView addSubview:discussion_subentry_count];

            //            UILabel *message = [[UILabel alloc]
            //            initWithFrame:CGRectMake(120, 79, 560, 21)];
            //            message.tag = 106;
            //            message.backgroundColor = [UIColor clearColor];
            //            [message setTextAlignment:NSTextAlignmentLeft];
            //            message.font = [UIFont systemFontOfSize:18];
            //            message.textColor = [UIColor blackColor];
            //            [bgImageView addSubview:message];
            //            [message release];
        }

        DiscussionTopicItem *item =
            [self.announcementsArray objectAtIndex:indexPath.row];

        UIImageView *avatarImage = (UIImageView *)[cell viewWithTag:101];
        [avatarImage
            sd_setImageWithURL:[NSURL
                                   URLWithString:item.author.avatar_image_url]
              placeholderImage:[UIImage imageNamed:@"avatar_default"]];

        UILabel *announcementTitle = (UILabel *)[cell viewWithTag:102];

        CGSize size = CGSizeMake(320, 2000);
        //        CGSize labelsize = [item.title
        //        sizeWithFont:announcementTitle.font
        //                                  constrainedToSize:size
        //                                      lineBreakMode:NSLineBreakByWordWrapping];
        CGRect rect1 = [item.title
            boundingRectWithSize:size
                         options:NSStringDrawingUsesLineFragmentOrigin
                      attributes:@{
                          NSFontAttributeName : [UIFont systemFontOfSize:16]
                      } context:nil];
        CGSize labelsize = rect1.size;
        if (labelsize.width > 300) {
            labelsize.width = 300;
            announcementTitle.frame =
                CGRectMake(105, 16, 300, labelsize.height);
        } else {
            announcementTitle.frame =
                CGRectMake(105, 16, labelsize.width, labelsize.height);
        }
        announcementTitle.text = item.title;

        UILabel *user_name = (UILabel *)[cell viewWithTag:103];
        user_name.text = item.user_name;

        UILabel *posted_at = (UILabel *)[cell viewWithTag:104];
        posted_at.text = [AppUtilities convertTimeStyleTo:item.posted_at];

        UIImageView *downImage = (UIImageView *)[cell viewWithTag:107];
        if (item.attachments.count == 0) {
            downImage.hidden = YES;
        } else {
            downImage.frame = CGRectMake(105 + labelsize.width + 5, 12, 25, 25);
        }

        UILabel *discussion_subentry_count = (UILabel *)[cell viewWithTag:105];
        if (item.discussion_subentry_count.intValue > 0) {
            if (item.attachments.count == 0) {
                discussion_subentry_count.frame =
                    CGRectMake(105 + labelsize.width + 5, 16, 41, 19);
            } else {
                discussion_subentry_count.frame =
                    CGRectMake(105 + labelsize.width + 10 + 25, 16, 41, 19);
            }
            discussion_subentry_count.hidden = NO;
            discussion_subentry_count.text = [NSString
                stringWithFormat:@"%@", item.discussion_subentry_count];
        } else {
            discussion_subentry_count.hidden = YES;
        }

        UILabel *message = (UILabel *)[cell viewWithTag:106];
        message.text = [AppUtilities cleanHtml:(NSMutableString *)item.message];

        return cell;
    }

    return [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault
                                  reuseIdentifier:@"null"];
}

- (void)tableView:(UITableView *)tableView
    didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    AnnouncementDetailViewController *announcementDetailViewController =
        [[AnnouncementDetailViewController alloc] init];
    announcementDetailViewController.courseId = self.courseId;
    announcementDetailViewController.discussionTopicItem =
        [self.announcementsArray objectAtIndex:indexPath.row];
    announcementDetailViewController.assArr = self.announcementsArray;
    announcementDetailViewController.selectIndex = indexPath.row;
    [self.navigationController
        pushViewController:announcementDetailViewController
                  animated:YES];

    [tableView deselectRowAtIndexPath:indexPath animated:YES];
}

#pragma mark 网络代理回调

- (void)requestSuccess:(NSString *)cmd {
    if ([cmd compare:HTTP_CMD_COURSE_ANNOUNCEMENTS] == NSOrderedSame) {
        self.announcementsArray = op.discussionTopic.announcementsItemArray;

        if ([self.announcementsArray count] > 0) {
            if (announcementBlankView) {
                [announcementBlankView removeFromSuperview];
            }
        } else {
            if (!announcementBlankView) {
                [self makeAnnouncementBlankView];
            }
        }

        AppDelegate *delegant =
            (AppDelegate *)[[UIApplication sharedApplication] delegate];
        if (delegant.isFromActivityAnn == YES) {
            AnnouncementDetailViewController *announcementDetailViewController =
                [[AnnouncementDetailViewController alloc] init];
            announcementDetailViewController.courseId = self.courseId;
            for (NSInteger i = 0; i < self.announcementsArray.count; i++) {
                DiscussionTopicItem *item =
                    [self.announcementsArray objectAtIndex:i];
                if ([delegant.annStr intValue] == [item._id intValue]) {
                    announcementDetailViewController.discussionTopicItem = item;
                    announcementDetailViewController.selectIndex = i;
                    break;
                }
            }

            //            for(DiscussionTopicItem *item in
            //            self.announcementsArray)
            //            {
            //                if([delegant.annStr intValue] == [item._id
            //                intValue])
            //                {
            //                    announcementDetailViewController.discussionTopicItem
            //                    = item;
            //                }
            //            }
            announcementDetailViewController.assArr = self.announcementsArray;

            [AppUtilities closeLoading:self.view];
            [self.navigationController
                pushViewController:announcementDetailViewController
                          animated:NO];
        }

        [announcementTableView reloadData];
    }
}

- (void)requestFailure:(NSString *)cmd errMsg:(NSString *)errMsg {
    if ([cmd compare:HTTP_CMD_COURSE_ANNOUNCEMENTS] == NSOrderedSame) {
        [AppUtilities closeLoading:announcementTableView];
    }

    [AppUtilities showHUD:errMsg andView:self.view];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:
            (UIInterfaceOrientation)interfaceOrientation {
    return (interfaceOrientation == UIInterfaceOrientationLandscapeLeft ||
            interfaceOrientation == UIInterfaceOrientationLandscapeRight);
}

@end
