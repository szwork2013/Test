//
//  AnnouncementTopicEntryViewController.m
//  learn
//
//  Created by User on 13-7-18.
//  Copyright (c) 2013年 kaikeba. All rights reserved.
//

#import <QuartzCore/QuartzCore.h>
#import "AnnouncementTopicEntryViewController.h"
#import "GlobalOperator.h"
#import "AppUtilities.h"
#import "UIImageView+WebCache.h"
#import "AnnouncementOperator.h"
#import "DiscussionTopicStructs.h"
#import "Cell1.h"
#import "Cell2.h"

@interface AnnouncementTopicEntryViewController () {
}

@property(assign) BOOL isOpen;
@property(nonatomic, retain) NSIndexPath *selectIndex;

@end

@implementation AnnouncementTopicEntryViewController

@synthesize currentTopicEntryList;
@synthesize currentTopicEntryReplyList;
@synthesize isOpen;
@synthesize selectIndex;
@synthesize discussionTopicItem;
@synthesize courseId;

#pragma mark - View lifecycle

- (id)init {
    if (self = [super init]) {
        op = (AnnouncementOperator *)[[GlobalOperator sharedInstance]
            getOperatorWithModuleType:KAIKEBA_MODULE_ANNOUNCEMENT];
        self.isOpen = NO;
        self.currentTopicEntryReplyList = [[NSMutableArray alloc] init];
    }

    return self;
}

- (void)loadView {
    [super loadView];

    UILabel *headerLabel =
        [[UILabel alloc] initWithFrame:CGRectMake(80, 0, 768 - 160, 44)];
    headerLabel.text = @"讨论";
    headerLabel.textAlignment = NSTextAlignmentCenter;
    headerLabel.font = [UIFont boldSystemFontOfSize:22];
    headerLabel.backgroundColor = [UIColor clearColor];
    headerLabel.textColor = [UIColor blackColor];
    //    headerLabel.shadowColor = [UIColor whiteColor];
    //    headerLabel.shadowOffset = CGSizeMake(1, 0);
    self.navigationItem.titleView = headerLabel;

    UIImage *img = [UIImage imageNamed:@"title_bar"];
    if (IS_IOS_7) {
        self.navigationController.navigationBar.frame =
            CGRectMake(0, 20, 768, 44);
    } else {
        self.navigationController.navigationBar.frame =
            CGRectMake(0, 0, 768, 44);
    }
    [self.navigationController.navigationBar
        setBackgroundImage:img
             forBarMetrics:UIBarMetricsDefault];

    //返回按钮
    UIButton *btn = [UIButton buttonWithType:UIButtonTypeCustom];
    btn.frame = CGRectMake(0, 0, 58, 30);
    [btn setBackgroundColor:[UIColor clearColor]];
    [btn setImage:[UIImage imageNamed:@"button_back_pad"]
         forState:UIControlStateNormal];
    [btn addTarget:self
                  action:@selector(back)
        forControlEvents:UIControlEventTouchUpInside];

    UIBarButtonItem *backButton =
        [[UIBarButtonItem alloc] initWithCustomView:btn];
    self.navigationItem.leftBarButtonItem = backButton;

    topicEntryTableView =
        [[UITableView alloc] initWithFrame:CGRectMake(0, 0, 768, 704)
                                     style:UITableViewStylePlain];
    topicEntryTableView.delegate = self;
    topicEntryTableView.dataSource = self;
    topicEntryTableView.showsVerticalScrollIndicator = NO;
    topicEntryTableView.backgroundColor = [UIColor whiteColor];
    topicEntryTableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    //    topicEntryTableView.layer.borderColor = [UIColor
    //    lightGrayColor].CGColor;
    //    topicEntryTableView.layer.borderWidth = 1.0;
    //    topicEntryTableView.layer.cornerRadius = 0;
    ////    topicEntryTableView.layer.shadowPath = [[UIBezierPath
    ///bezierPathWithRect:topicEntryTableView.bounds] CGPath];
    //    topicEntryTableView.layer.shadowColor = [UIColor blackColor].CGColor;
    //    topicEntryTableView.layer.shadowOffset = CGSizeMake(0, 0);
    //    topicEntryTableView.layer.shadowOpacity = 0.5;
    //    topicEntryTableView.layer.shadowRadius = 3.0;
    //    topicEntryTableView.layer.masksToBounds = NO;

    [self.view addSubview:topicEntryTableView];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.

    [op requestALLTopicEntry:self
                       token:[GlobalOperator sharedInstance]
                                 .user4Request.user.avatar.token
                    courseId:self.courseId
                    topic_id:self.discussionTopicItem._id];
}

- (void)back {
    [self.navigationController popViewControllerAnimated:YES];
}

- (void)makeTopicEntryBlankView {
    topicEntryBlankView =
        [[UIView alloc] initWithFrame:CGRectMake(0, 0, 768, 748)];
    [self.view addSubview:topicEntryBlankView];

    UILabel *promptLabel = [[UILabel alloc] init];
    promptLabel.frame = CGRectMake(0, 280, 768, 60);
    promptLabel.backgroundColor = [UIColor clearColor];
    promptLabel.textAlignment = NSTextAlignmentCenter;
    promptLabel.textColor = [UIColor grayColor];
    promptLabel.font = [UIFont boldSystemFontOfSize:22];
    promptLabel.text = @"暂时还没有讨论哦！";
    [topicEntryBlankView addSubview:promptLabel];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return [self.currentTopicEntryList count];
}

- (CGFloat)tableView:(UITableView *)tableView
    heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.row == 0) {
        TopicEntryItem *item =
            [self.currentTopicEntryList objectAtIndex:indexPath.section];
        // CGSize userContentSize = [item.message sizeWithFont:[UIFont
        // systemFontOfSize:14] constrainedToSize:CGSizeMake(600, MAXFLOAT)
        // lineBreakMode:NSLineBreakByWordWrapping];//用户留言内容的size
        CGRect rect1 = [item.message
            boundingRectWithSize:CGSizeMake(600, MAXFLOAT)
                         options:NSStringDrawingUsesLineFragmentOrigin
                      attributes:@{
                          NSFontAttributeName : [UIFont systemFontOfSize:14]
                      } context:nil];
        CGSize userContentSize = rect1.size;
        return userContentSize.height + 79;
    } else {
        NSArray *array = [self.currentTopicEntryReplyList
            objectAtIndex:self.selectIndex.section];

        TopicEntryReplyItem *replyItem =
            [array objectAtIndex:indexPath.row - 1];

        // CGSize userReplySize = [replyItem.message sizeWithFont:[UIFont
        // systemFontOfSize:14] constrainedToSize:CGSizeMake(600, MAXFLOAT)
        // lineBreakMode:NSLineBreakByWordWrapping];//用户留言回复内容的size
        CGRect rect1 = [replyItem.message
            boundingRectWithSize:CGSizeMake(600, MAXFLOAT)
                         options:NSStringDrawingUsesLineFragmentOrigin
                      attributes:@{
                          NSFontAttributeName : [UIFont systemFontOfSize:14]
                      } context:nil];
        CGSize userReplySize = rect1.size;

        return 61 + userReplySize.height;
    }
}

- (NSInteger)tableView:(UITableView *)tableView
    numberOfRowsInSection:(NSInteger)section {
    if (self.isOpen) {
        if (self.selectIndex.section == section) {
            return [[self.currentTopicEntryReplyList
                       objectAtIndex:section] count] +
                   1;
        }
    }

    return 1;
}

- (UITableViewCell *)tableView:(UITableView *)tableView
         cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    if (self.isOpen && self.selectIndex.section == indexPath.section &&
        indexPath.row != 0) {
        static NSString *CellIdentifier = @"Cell2_Announcement";
        Cell2 *cell = (Cell2 *)
            [tableView dequeueReusableCellWithIdentifier:CellIdentifier];

        if (!cell) {
            cell = [[[NSBundle mainBundle] loadNibNamed:CellIdentifier
                                                  owner:self
                                                options:nil] objectAtIndex:0];

            UIImageView *cell2Bg = [[UIImageView alloc] init];
            cell2Bg.frame = CGRectMake(0, 0, 768, 80);
            cell2Bg.tag = 100;
            [cell.contentView addSubview:cell2Bg];
            [cell.contentView sendSubviewToBack:cell2Bg];

            UIImageView *avatar =
                [[UIImageView alloc] initWithFrame:CGRectMake(38, 20, 40, 40)];
            avatar.tag = 101;
            [cell.contentView addSubview:avatar];

            UILabel *userName =
                [[UILabel alloc] initWithFrame:CGRectMake(98, 20, 300, 21)];
            userName.tag = 102;
            [userName setTextAlignment:NSTextAlignmentLeft];
            userName.font = [UIFont boldSystemFontOfSize:16];
            userName.textColor = [UIColor grayColor];
            userName.backgroundColor = [UIColor clearColor];
            [cell.contentView addSubview:userName];

            UILabel *postedAt =
                [[UILabel alloc] initWithFrame:CGRectMake(600, 30, 140, 21)];
            postedAt.tag = 103;
            [postedAt setTextAlignment:NSTextAlignmentLeft];
            postedAt.font = [UIFont systemFontOfSize:12];
            postedAt.textColor = [UIColor grayColor];
            postedAt.backgroundColor = [UIColor clearColor];
            [cell.contentView addSubview:postedAt];

            UILabel *content =
                [[UILabel alloc] initWithFrame:CGRectMake(98, 51, 600, 21)];
            content.tag = 104;
            content.backgroundColor = [UIColor clearColor];
            [content setTextAlignment:NSTextAlignmentLeft];
            content.font = [UIFont systemFontOfSize:14];
            content.textColor = [UIColor grayColor];
            content.numberOfLines = 0;
            [cell.contentView addSubview:content];
        }

        NSArray *array = [self.currentTopicEntryReplyList
            objectAtIndex:self.selectIndex.section];

        TopicEntryReplyItem *replyItem =
            [array objectAtIndex:indexPath.row - 1];

        TopicEntryParticipantsItem *participantsItem = nil;

        for (TopicEntryParticipantsItem *_participantsItem in op.discussionTopic
                 .allTopicEntry.participants) {
            if ([_participantsItem._id isEqual:replyItem.user_id]) {
                participantsItem = _participantsItem;

                break;
            }
        }

        // CGSize userReplySize = [replyItem.message sizeWithFont:[UIFont
        // systemFontOfSize:14] constrainedToSize:CGSizeMake(600, MAXFLOAT)
        // lineBreakMode:NSLineBreakByWordWrapping];//用户留言内容的size
        CGRect rect1 = [replyItem.message
            boundingRectWithSize:CGSizeMake(600, MAXFLOAT)
                         options:NSStringDrawingUsesLineFragmentOrigin
                      attributes:@{
                          NSFontAttributeName : [UIFont systemFontOfSize:14]
                      } context:nil];
        CGSize userReplySize = rect1.size;

        UIImage *resizeableImage = [UIImage imageNamed:@"reply2reply_bg"];
        resizeableImage = [resizeableImage
            resizableImageWithCapInsets:UIEdgeInsetsMake(10, 60, 10, 40)];

        UIImageView *cell2Bg = (UIImageView *)[cell viewWithTag:100];
        cell2Bg.frame = CGRectMake(0, 0, 768, userReplySize.height + 61);
        cell2Bg.image = resizeableImage;

        UIImageView *avatar = (UIImageView *)[cell viewWithTag:101];
        [avatar sd_setImageWithURL:
                    [NSURL URLWithString:[NSString
                                             stringWithFormat:
                                                 @"%@", participantsItem
                                                            .avatar_image_url]]
                  placeholderImage:[UIImage imageNamed:@"default_avatar"]];

        UILabel *userName = (UILabel *)[cell viewWithTag:102];
        userName.text = participantsItem.display_name;

        UILabel *createdAt = (UILabel *)[cell viewWithTag:103];
        createdAt.text = [AppUtilities
            convertTimeStyleToDayInAnnouncement:replyItem.created_at];

        UILabel *content = (UILabel *)[cell viewWithTag:104];
        content.frame = CGRectMake(98, 51, 600, userReplySize.height);
        content.text = replyItem.message;

        cell.selectionStyle = UITableViewCellSelectionStyleNone;

        return cell;
    } else {
        static NSString *CellIdentifier = @"Cell1_Announcement";
        Cell1 *cell = (Cell1 *)
            [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
        if (!cell) {
            cell = [[[NSBundle mainBundle] loadNibNamed:CellIdentifier
                                                  owner:self
                                                options:nil] objectAtIndex:0];

            UILabel *topline =
                [[UILabel alloc] initWithFrame:CGRectMake(0, 0, 768, 1)];
            topline.backgroundColor = [UIColor lightGrayColor];
            [cell.contentView addSubview:topline];

            //            UIImage *img = [UIImage imageNamed:@"reply_bg.png"];
            UIImageView *cell1Bg = [[UIImageView alloc] init];
            cell1Bg.frame = CGRectMake(0, 0, 768, 100);
            cell1Bg.tag = 100;
            cell1Bg.backgroundColor = [UIColor whiteColor];
            [cell.contentView addSubview:cell1Bg];
            [cell.contentView sendSubviewToBack:cell1Bg];

            //头像
            UIImageView *avatar =
                [[UIImageView alloc] initWithFrame:CGRectMake(18, 20, 60, 60)];
            avatar.tag = 101;
            [cell.contentView addSubview:avatar];

            //用户名
            UILabel *userName =
                [[UILabel alloc] initWithFrame:CGRectMake(98, 20, 300, 21)];
            userName.tag = 102;
            [userName setTextAlignment:NSTextAlignmentLeft];
            userName.font = [UIFont boldSystemFontOfSize:16];
            userName.textColor = [UIColor grayColor];
            userName.backgroundColor = [UIColor clearColor];
            [cell.contentView addSubview:userName];

            //发表时间
            UILabel *createdAt =
                [[UILabel alloc] initWithFrame:CGRectMake(600, 30, 140, 21)];
            createdAt.tag = 103;
            [createdAt setTextAlignment:NSTextAlignmentLeft];
            createdAt.font = [UIFont systemFontOfSize:12];
            createdAt.textColor = [UIColor grayColor];
            createdAt.backgroundColor = [UIColor clearColor];
            [cell.contentView addSubview:createdAt];

            //消息内容
            UILabel *content =
                [[UILabel alloc] initWithFrame:CGRectMake(98, 51, 600, 21)];
            content.tag = 104;
            content.backgroundColor = [UIColor clearColor];
            [content setTextAlignment:NSTextAlignmentLeft];
            content.font = [UIFont systemFontOfSize:14];
            content.textColor = [UIColor grayColor];
            content.numberOfLines = 0;
            [cell.contentView addSubview:content];

            UILabel *line =
                [[UILabel alloc] initWithFrame:CGRectMake(0, 99, 768, 1)];
            line.tag = 105;
            line.backgroundColor = [UIColor lightGrayColor];
            [cell.contentView addSubview:line];
        }

        TopicEntryItem *item =
            [self.currentTopicEntryList objectAtIndex:indexPath.section];

        TopicEntryParticipantsItem *participantsItem = nil;

        for (TopicEntryParticipantsItem *_participantsItem in op.discussionTopic
                 .allTopicEntry.participants) {
            if ([_participantsItem._id isEqual:item.user_id]) {
                participantsItem = _participantsItem;
                break;
            }
        }

        // CGSize userContentSize = [item.message sizeWithFont:[UIFont
        // systemFontOfSize:14] constrainedToSize:CGSizeMake(600, MAXFLOAT)
        // lineBreakMode:NSLineBreakByWordWrapping];//用户留言内容的size
        CGRect rect1 = [item.message
            boundingRectWithSize:CGSizeMake(600, MAXFLOAT)
                         options:NSStringDrawingUsesLineFragmentOrigin
                      attributes:@{
                          NSFontAttributeName : [UIFont systemFontOfSize:14]
                      } context:nil];
        CGSize userContentSize = rect1.size;

        UIImageView *cell1Bg = (UIImageView *)[cell viewWithTag:100];
        cell1Bg.frame = CGRectMake(0, 0, 768, userContentSize.height + 79);

        UIImageView *line = (UIImageView *)[cell viewWithTag:105];
        line.frame = CGRectMake(0, userContentSize.height + 79, 768, 1);

        UIImageView *avatar = (UIImageView *)[cell viewWithTag:101];
        [avatar sd_setImageWithURL:[NSURL URLWithString:participantsItem
                                                            .avatar_image_url]
                  placeholderImage:[UIImage imageNamed:@"default_avatar"]];

        UILabel *userName = (UILabel *)[cell viewWithTag:102];
        userName.text = participantsItem.display_name;

        UILabel *createdAt = (UILabel *)[cell viewWithTag:103];
        createdAt.text =
            [AppUtilities convertTimeStyleToDayInAnnouncement:item.created_at];

        UILabel *content = (UILabel *)[cell viewWithTag:104];
        content.frame = CGRectMake(98, 51, 600, userContentSize.height);
        content.text = item.message;

        [cell changeArrowWithUp:([self.selectIndex isEqual:indexPath] ? YES
                                                                      : NO)];

        cell.selectionStyle = UITableViewCellSelectionStyleNone;

        return cell;
    }
}

#pragma mark - TableView delegate

- (void)tableView:(UITableView *)tableView
    didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.row == 0) {
        if ([indexPath isEqual:self.selectIndex]) {
            self.isOpen = NO;
            [self didSelectCellRowFirstDo:NO nextDo:NO];
            self.selectIndex = nil;
        } else {
            if (!self.selectIndex) {
                self.selectIndex = indexPath;
                [self didSelectCellRowFirstDo:YES nextDo:NO];
            } else {
                [self didSelectCellRowFirstDo:NO nextDo:YES];
            }
        }
    } else {
    }

    [tableView deselectRowAtIndexPath:indexPath animated:YES];
}

- (void)didSelectCellRowFirstDo:(BOOL)firstDoInsert nextDo:(BOOL)nextDoInsert {
    self.isOpen = firstDoInsert;

    Cell1 *cell =
        (Cell1 *)[topicEntryTableView cellForRowAtIndexPath:self.selectIndex];
    [cell changeArrowWithUp:firstDoInsert];

    [topicEntryTableView beginUpdates];

    int section = (int)self.selectIndex.section;
    int contentCount =
        (int)[[self.currentTopicEntryReplyList objectAtIndex:section] count];

    NSMutableArray *rowToInsert = [[NSMutableArray alloc] init];
    for (NSUInteger i = 1; i < contentCount + 1; i++) {
        NSIndexPath *indexPathToInsert =
            [NSIndexPath indexPathForRow:i inSection:section];
        [rowToInsert addObject:indexPathToInsert];
    }

    if (firstDoInsert) {
        [topicEntryTableView
            insertRowsAtIndexPaths:rowToInsert
                  withRowAnimation:UITableViewRowAnimationFade];
    } else {
        [topicEntryTableView
            deleteRowsAtIndexPaths:rowToInsert
                  withRowAnimation:UITableViewRowAnimationFade];
    }

    [topicEntryTableView endUpdates];

    if (nextDoInsert) {
        self.isOpen = YES;
        self.selectIndex = [topicEntryTableView indexPathForSelectedRow];
        [self didSelectCellRowFirstDo:YES nextDo:NO];
    }

    if (self.isOpen) {
        [topicEntryTableView scrollToNearestSelectedRowAtScrollPosition:
                                 UITableViewScrollPositionTop animated:YES];
    }
}

#pragma mark 网络代理回调

- (void)requestSuccess:(NSString *)cmd {
    if ([cmd compare:HTTP_CMD_COURSE_ANNOUNCEMENTS_ALLTOPICENTRY] ==
        NSOrderedSame) {
        self.currentTopicEntryList = op.discussionTopic.allTopicEntry.views;

        if ([self.currentTopicEntryList count] > 0) {
            if (topicEntryBlankView) {
                [topicEntryBlankView removeFromSuperview];
            }

            for (TopicEntryItem *item in op.discussionTopic.allTopicEntry
                     .views) {
                if (item.replys) {
                    [self.currentTopicEntryReplyList addObject:item.replys];
                }
            }
        } else {
            if (!topicEntryBlankView) {
                [self makeTopicEntryBlankView];
            }
        }

        [topicEntryTableView reloadData];
    }
}

- (void)requestFailure:(NSString *)cmd errMsg:(NSString *)errMsg {
    if ([cmd compare:HTTP_CMD_COURSE_ANNOUNCEMENTS_ALLTOPICENTRY] ==
        NSOrderedSame) {
    }

    [AppUtilities showHUD:errMsg andView:self.view];
}
- (BOOL)shouldAutorotateToInterfaceOrientation:
            (UIInterfaceOrientation)interfaceOrientation {
    return (interfaceOrientation == UIInterfaceOrientationLandscapeLeft ||
            interfaceOrientation == UIInterfaceOrientationLandscapeRight);
}

@end
