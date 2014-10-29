//
//  DiscussionViewController.m
//  learn
//
//  Created by User on 13-12-24.
//  Copyright (c) 2013年 kaikeba. All rights reserved.
//

#import "DiscussionViewController.h"
#import "AppUtilities.h"
#import "GlobalOperator.h"
#import "GlobalDefine.h"
#import "DiscussionTopicStructs.h"
#import "DiscussionOperator.h"
#import "AppDelegate.h"
#import "DiscussionDeatilViewController.h"

@interface DiscussionViewController ()

@end

@implementation DiscussionViewController
@synthesize courseId,discussionsArray,discussionTableView;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
         op = (DiscussionOperator *)[[GlobalOperator sharedInstance] getOperatorWithModuleType:KAIKEBA_MODULE_DISCUSSION];
    }
    return self;
}

- (void)viewDidLoad
{
        [super viewDidLoad];
        // Do any additional setup after loading the view.
        
        [op requestDiscussions:self token:[GlobalOperator sharedInstance].user4Request.user.avatar.token courseId:self.courseId];
        
        discussionTableView.delegate = self;
        discussionTableView.dataSource = self;
        discussionTableView.separatorStyle = UITableViewCellSeparatorStyleNone;
        discussionTableView.backgroundColor = [UIColor clearColor];
        discussionTableView.showsVerticalScrollIndicator=NO;
//        discussionTableView.contentSize = CGSizeMake(discussionTableView.frame.size.width,1000);
    
        UIView *footView = [[UIView alloc]init];
        footView.frame = CGRectMake(0, 0, 768, 100);
        footView.backgroundColor = [UIColor clearColor];
        [discussionTableView setTableFooterView:footView];
        AppDelegate* delegant= (AppDelegate*)[[UIApplication sharedApplication]delegate];
        if(delegant.isFromActivityDis == YES){
            [AppUtilities showLoading:@"加载讨论中..." andView:self.view];
        }
    

}
- (void)makeAnnouncementBlankView
{
    announcementBlankView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 871, 748)];
    [self.view addSubview:announcementBlankView];
    
    UILabel *promptLabel = [[UILabel alloc] init];
    promptLabel.frame = CGRectMake(50, 280, 871, 60);
    promptLabel.backgroundColor = [UIColor clearColor];
    promptLabel.textAlignment = NSTextAlignmentCenter;
    promptLabel.textColor = [UIColor grayColor];
    promptLabel.font = [UIFont boldSystemFontOfSize:22];
    promptLabel.text = @"暂时还没有讨论哦！去其它地方逛逛吧~~";
    [announcementBlankView addSubview:promptLabel];
}

#pragma mark - UITableViewDelegate

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [self.discussionsArray count];
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 125;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if ([self.discussionsArray count] > 0)
    {
        static NSString *CellAnnouncementIdentifier = @"CellAnnouncementIdentifier";
        UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellAnnouncementIdentifier];
        
        if (cell == nil)
        {
            cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellAnnouncementIdentifier];
            cell.selectionStyle = UITableViewCellSelectionStyleNone;
            //            UIImageView *selectedBackgroundView = [[UIImageView alloc] init];
            //            selectedBackgroundView .backgroundColor = [UIColor colorWithPatternImage:[UIImage imageNamed:@"annoucement_bg_selected.png"]];
            //            cell.selectedBackgroundView = selectedBackgroundView;
            //            [selectedBackgroundView release];
            cell.backgroundColor = [UIColor clearColor];
            
            UIImageView *bgImageView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 10, 851, 115)];
            bgImageView.backgroundColor = [UIColor whiteColor];
            [cell.contentView addSubview:bgImageView];
            
            
            
//            UILabel *announcementTitle = [[UILabel alloc] initWithFrame:CGRectMake(15, 20, 250, 30)];
            UILabel *announcementTitle = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, 0, 0)];
            [announcementTitle setNumberOfLines:0];
            announcementTitle.tag = 102;
            announcementTitle.backgroundColor = [UIColor clearColor];
            [announcementTitle setTextAlignment:NSTextAlignmentLeft];
            announcementTitle.numberOfLines = 1;
            announcementTitle.font = [UIFont systemFontOfSize:16];
            announcementTitle.textColor = [UIColor colorWithRed:61.0/255 green:69.0/255 blue:76.0/255 alpha:1];
            [bgImageView addSubview:announcementTitle];
            
            UILabel *posted_at = [[UILabel alloc] initWithFrame:CGRectMake(700, 20, 160, 21)];
            posted_at.tag = 104;
            [posted_at setTextAlignment:NSTextAlignmentLeft];
            posted_at.font = [UIFont systemFontOfSize:14];
            posted_at.textColor = [UIColor colorWithRed:170.0/255 green:174.0/255 blue:178.0/255 alpha:1];
            posted_at.backgroundColor = [UIColor clearColor];
            [bgImageView addSubview:posted_at];
            
            UILabel *message = [[UILabel alloc] initWithFrame:CGRectMake(15, 65, 700, 21)];
            message.tag = 106;
            [message setTextAlignment:NSTextAlignmentLeft];
            message.font = [UIFont systemFontOfSize:14];
            message.textColor = [UIColor colorWithRed:170.0/255 green:174.0/255 blue:178.0/255 alpha:1];
            message.backgroundColor = [UIColor clearColor];
            [bgImageView addSubview:message];
            
            
//            UILabel *discussion_subentry_count = [[UILabel alloc] initWithFrame:CGRectMake(275, 24, 41, 19)];
            UILabel *discussion_subentry_count = [[UILabel alloc] init];
            discussion_subentry_count.tag = 105;
            discussion_subentry_count.textAlignment = NSTextAlignmentCenter;
            discussion_subentry_count.font = [UIFont boldSystemFontOfSize:14];
            discussion_subentry_count.textColor = [UIColor whiteColor];
            discussion_subentry_count.backgroundColor = [UIColor colorWithPatternImage:[UIImage imageNamed:@"amount_bg.png"]];
            [bgImageView addSubview:discussion_subentry_count];
            
            //            UILabel *message = [[UILabel alloc] initWithFrame:CGRectMake(120, 79, 560, 21)];
            //            message.tag = 106;
            //            message.backgroundColor = [UIColor clearColor];
            //            [message setTextAlignment:NSTextAlignmentLeft];
            //            message.font = [UIFont systemFontOfSize:18];
            //            message.textColor = [UIColor blackColor];
            //            [bgImageView addSubview:message];
            //            [message release];
        }
        
        DiscussionTopicItem *item = [self.discussionsArray objectAtIndex:indexPath.row];
        
        
        UILabel *announcementTitle = (UILabel *)[cell viewWithTag:102];
        CGSize size = CGSizeMake(620,2000);
//        CGSize labelsize = [item.title sizeWithFont:announcementTitle.font
//                                  constrainedToSize:size
//                                      lineBreakMode:NSLineBreakByWordWrapping];
        CGRect rect1 = [item.title boundingRectWithSize:size options:NSStringDrawingUsesLineFragmentOrigin attributes:@{NSFontAttributeName:[UIFont systemFontOfSize:16]} context:nil];
        CGSize labelsize = rect1.size;
        if(labelsize.width > 500){
            labelsize.width  = 500;
            announcementTitle.frame = CGRectMake(15, 20, labelsize.width, 30 );
        }else{
            announcementTitle.frame = CGRectMake(15, 20, labelsize.width, 30 );
        }
        announcementTitle.text = item.title;
        
      
        
        UILabel *posted_at = (UILabel *)[cell viewWithTag:104];
        posted_at.text = [AppUtilities convertTimeStyleTo:item.posted_at];
        
        UILabel *discussion_subentry_count = (UILabel *)[cell viewWithTag:105];
        if (item.discussion_subentry_count.intValue > 0)
        {
            discussion_subentry_count.frame = CGRectMake(15+labelsize.width+5, 24, 41, 19 );
            discussion_subentry_count.hidden = NO;
            discussion_subentry_count.text = [NSString stringWithFormat:@"%@", item.discussion_subentry_count];
        }
        else
        {
            discussion_subentry_count.hidden = YES;
        }
        UILabel *message = (UILabel *)[cell viewWithTag:106];
        message.text = [AppUtilities cleanHtml:(NSMutableString *)item.message];
        
        return cell;
    }
    
    return [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"null"];
}
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    DiscussionDeatilViewController *discussionDeatilViewController = [[DiscussionDeatilViewController alloc] init];
    discussionDeatilViewController.courseId = self.courseId;
    discussionDeatilViewController.discussionTopicItem = [self.discussionsArray objectAtIndex:indexPath.row];
    discussionDeatilViewController.assArr = self.discussionsArray;
    discussionDeatilViewController.selectIndex = indexPath.row;
    [self.navigationController pushViewController:discussionDeatilViewController animated:YES];
    
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
}


- (void)requestSuccess:(NSString *)cmd
{
    if ([cmd compare:HTTP_CMD_COURSE_DISCUSSION] == NSOrderedSame)
    {
        self.discussionsArray = op.discussionTopic.discussionsItemArray;
        
        if ([self.discussionsArray count] > 0)
        {
            if (announcementBlankView)
            {
                [announcementBlankView removeFromSuperview];
            }
        }
        else
        {
            if (!announcementBlankView)
            {
                [self makeAnnouncementBlankView];
            }
        }
        
        
        
        AppDelegate* delegant= (AppDelegate*)[[UIApplication sharedApplication]delegate];
        if(delegant.isFromActivityDis == YES){
            
            [AppUtilities closeLoading:self.view];

            DiscussionDeatilViewController *announcementDetailViewController = [[DiscussionDeatilViewController alloc] init];
            announcementDetailViewController.courseId = self.courseId;
            for (NSInteger i = 0; i<self.discussionsArray.count; i++) {
                DiscussionTopicItem *item = [self.discussionsArray objectAtIndex:i];
                if([delegant.annStr intValue] == [item._id intValue])
                {
                    announcementDetailViewController.discussionTopicItem = item;
                    announcementDetailViewController.selectIndex = i;
                    announcementDetailViewController.assArr = self.discussionsArray;
                    
                    [self.navigationController pushViewController:announcementDetailViewController animated:NO];
//                    [announcementDetailViewController release];
                    
                    break;
                }
                
            }
            if(announcementDetailViewController.discussionTopicItem == nil){
                [AppUtilities showHUD:@"暂无讨论" andView:self.view];
            }
            
        }
        
        [discussionTableView reloadData];
        
    }
}

- (void)requestFailure:(NSString *)cmd errMsg:(NSString *)errMsg
{
    if ([cmd compare:HTTP_CMD_COURSE_DISCUSSION] == NSOrderedSame)
    {
        [AppUtilities closeLoading:discussionTableView];
    }
    
    [AppUtilities showHUD:errMsg andView:self.view];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return (interfaceOrientation == UIInterfaceOrientationLandscapeLeft ||
            
            interfaceOrientation == UIInterfaceOrientationLandscapeRight );
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
@end
