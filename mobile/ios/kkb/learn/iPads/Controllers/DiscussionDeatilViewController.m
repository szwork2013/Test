//
//  DiscussionDeatilViewController.m
//  learn
//
//  Created by User on 14-1-9.
//  Copyright (c) 2014年 kaikeba. All rights reserved.
//

#import "DiscussionDeatilViewController.h"
#import "GlobalOperator.h"
#import "AppUtilities.h"
#import "UIImageView+WebCache.h"
#import "DiscussionOperator.h"
#import "DiscussionTopicStructs.h"
#import "MessageDetailViewController.h"

@interface DiscussionDeatilViewController ()

@end

@implementation DiscussionDeatilViewController
@synthesize discussionTopicItem;
@synthesize courseId;
@synthesize announcementTitle,avatarImage,user_name;
@synthesize discussionTableView;
@synthesize currentTopicEntryList,currentTopicEntryReplyList,currentTopicEntryOpenList;
@synthesize headerView;

@synthesize timeTitle;
@synthesize assArr,selectIndex;
@synthesize viewFooter;
@synthesize inputView;
@synthesize bottomLabel;
@synthesize textHeaderstr;
@synthesize dataDictionary;
@synthesize bottomLeftLabel;
@synthesize btnTag;
@synthesize imvBg;
@synthesize webView;
@synthesize fileView,fileLabel;
@synthesize btnLast,btnNext;
- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        op = (DiscussionOperator *)[[GlobalOperator sharedInstance] getOperatorWithModuleType:KAIKEBA_MODULE_DISCUSSION];
        self.currentTopicEntryReplyList = [[NSMutableArray alloc] init];
        self.currentTopicEntryOpenList = [[NSMutableArray alloc] init];
        self.dataDictionary = [[NSMutableDictionary alloc]init];
        
        
    }
    return self;
}

- (void)keyboardwillshow:(NSNotification *)notification
{
    /*
     [UIView beginAnimations:nil context:nil];
     [UIView setAnimationCurve:0.25];
     self.viewFooter.frame = CGRectMake(240, -70, 550, 525);
     
     [UIView commitAnimations];
     */
    
    
    
    NSDictionary *userInfo = [notification userInfo];
    
    
    NSValue *value = [userInfo objectForKey:@"UIKeyboardBoundsUserInfoKey"];//关键的一句，网上关于获取键盘高度的解决办法，多到这句就over了。系统宏定义的UIKeyboardBoundsUserInfoKey等测试都不能获取正确的值。不知道为什么。。。
    
    CGSize keyboardSize = [value CGRectValue].size;
//    NSLog(@"横屏show%f",keyboardSize.height);
    float keyboardHeight = keyboardSize.height;
    
    
    //    // Get the origin of the keyboard when it's displayed.
    //    NSValue* aValue = [userInfo objectForKey:UIKeyboardFrameEndUserInfoKey];
    //
    //    // Get the top of the keyboard as the y coordinate of its origin in self's view's coordinate system. The bottom of the text view's frame should align with the top of the keyboard's final position.
    //    CGRect keyboardRect = [aValue CGRectValue];
    
    // Get the duration of the animation.
    NSValue *animationDurationValue = [userInfo objectForKey:UIKeyboardAnimationDurationUserInfoKey];
    NSTimeInterval animationDuration;
    [animationDurationValue getValue:&animationDuration];
    
    // Animate the resize of the text view's frame in sync with the keyboard's appearance.
    [UIView animateWithDuration:animationDuration animations:^{
        
        
        
        self.view.frame = CGRectMake(self.view.frame.origin.x, 0-keyboardHeight,self.view.frame.size.width, self.view.frame.size.height);
      
        
        //        self.viewFooter.frame = CGRectMake(viewFooter.frame.origin.x, viewFooter.frame.origin.y-20,viewFooter.frame.size.width, 80);
        //        self.imvBg.frame = CGRectMake(imvBg.frame.origin.x, imvBg.frame.origin.y,imvBg.frame.size.width, 80);
        //         self.inputView.frame= CGRectMake(inputView.frame.origin.x, inputView.frame.origin.y, 604, 60);
        
        //        self.viewFooter.frame = CGRectMake(viewFooter.frame.origin.x, 768-80-keyboardHeight,viewFooter.frame.size.width, 80);
        //        self.inputView.frame= CGRectMake(inputView.frame.origin.x, inputView.frame.origin.y, 604, 60);
        
    } completion:^(BOOL finished){
        
        
        
    }];
    
}

- (void)keyboardDidHide:(NSNotification *)notification
{
    /*
     [UIView beginAnimations:nil context:nil];
     [UIView setAnimationCurve:0.25];
     
     loginWebViewBg.frame = CGRectMake(240, 140, 550, 405);
     //    registerLoginView.frame = CGRectMake(175, 114, 675, 520);
     registerView.frame = CGRectMake(240, 140, 550, 525);
     
     [UIView commitAnimations];
     */
    NSDictionary *userInfo = [notification userInfo];
    
//    NSValue *value = [userInfo objectForKey:@"UIKeyboardBoundsUserInfoKey"];//关键的一句，网上关于获取键盘高度的解决办法，多到这句就over了。系统宏定义的UIKeyboardBoundsUserInfoKey等测试都不能获取正确的值。不知道为什么。。。
//    
//    CGSize keyboardSize = [value CGRectValue].size;
//    NSLog(@"横屏hide%f",keyboardSize.height);
//    float keyboardHeight = keyboardSize.height;

    
    // Get the origin of the keyboard when it's displayed.
    //    NSValue* aValue = [userInfo objectForKey:UIKeyboardFrameEndUserInfoKey];
    
    // Get the top of the keyboard as the y coordinate of its origin in self's view's coordinate system. The bottom of the text view's frame should align with the top of the keyboard's final position.
    //    CGRect keyboardRect = [aValue CGRectValue];
    
    // Get the duration of the animation.
    NSValue *animationDurationValue = [userInfo objectForKey:UIKeyboardAnimationDurationUserInfoKey];
    NSTimeInterval animationDuration;
    [animationDurationValue getValue:&animationDuration];
    
    
    [UIView beginAnimations:nil context:NULL];
    [UIView setAnimationDuration:animationDuration];
    self.view.frame = CGRectMake(self.view.frame.origin.x, 0,self.view.frame.size.width, self.view.frame.size.height);
    
    //    self.imvBg.frame = CGRectMake(imvBg.frame.origin.x, imvBg.frame.origin.y,imvBg.frame.size.width, 60);
    //    self.inputView.frame= CGRectMake(inputView.frame.origin.x, inputView.frame.origin.y, 604, 40);
    //    self.viewFooter.frame = CGRectMake(viewFooter.frame.origin.x, 688,viewFooter.frame.size.width, 60);
    
    [UIView commitAnimations];
    
    //    [UIView animateWithDuration:0 animations:^{
    //
    //           self.view.frame = CGRectMake(self.view.frame.origin.x, 0,self.view.frame.size.width, self.view.frame.size.height);
    //    } completion:^(BOOL finished){
    //
    //
    //
    //    }];
}
- (IBAction)fileButtonOnClick
{
    if ([self.discussionTopicItem.attachments count] > 0)
    {
        DiscussionTopicAttachmentsItem *attachmentsItem = [self.discussionTopicItem.attachments objectAtIndex:0];
        
        NSURL* url = [[ NSURL alloc ] initWithString :attachmentsItem.url];
        [[UIApplication sharedApplication ] openURL: url ];
    }
    
    //    UIDocumentInteractionController *documentController = [UIDocumentInteractionController
    //     interactionControllerWithURL:[NSURL URLWithString:attachmentsItem.url]];
    ////    documentController.delegate = self;
    //    [documentController retain];
    //    documentController.UTI = attachmentsItem.filename;
    //    [documentController presentOpenInMenuFromRect:CGRectZero
    //                                           inView:self.view
    //                                         animated:YES];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    discussionTableView.showsHorizontalScrollIndicator = NO;
    discussionTableView.showsVerticalScrollIndicator = NO;
    
	// Do any additional setup after loading the view.
    [self setData];
    self.inputView.delegate = self;
    self.textHeaderstr = @"发表讨论：";
    
    UIView *footView = [[UIView alloc]init];
    footView.frame = CGRectMake(0, 0, 768, 80);
    footView.backgroundColor = [UIColor clearColor];
    [self.discussionTableView setTableFooterView:footView];
    
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(hideBoard) name:@"hideKeyBoard" object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardDidHide:) name:UIKeyboardDidHideNotification object:nil];
    
    //#ifdef __IPHONE_5_0
    float version = [[[UIDevice currentDevice] systemVersion] floatValue];
    if (version >= 5.0) {
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardwillshow:) name:UIKeyboardWillChangeFrameNotification object:nil];
        
        
    }else
    {
        [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(keyboardwillshow:) name:UIKeyboardWillShowNotification object:nil];
        
    }
    //#endif
    if (self.assArr.count == 1) {
        btnNext.enabled = NO;
        btnLast.enabled = NO;
    }else{
        if(selectIndex == self.assArr.count - 1)
        {
            btnNext.enabled = NO;
            btnLast.enabled = YES;
            
        }else if(selectIndex == 0)
        {
            btnLast.enabled = NO;
            btnNext.enabled = YES;
            
        }
    }
    UITapGestureRecognizer *floatingLayerTapGestureRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(floatingLayerTapGestureRecognizer:)];
    floatingLayerTapGestureRecognizer.delegate = self;
    [self.view addGestureRecognizer:floatingLayerTapGestureRecognizer];
    
}
- (void)floatingLayerTapGestureRecognizer:(UITapGestureRecognizer *)tap
{
    CGPoint currentPoint = [tap locationInView:self.view];
    //    NSLog(@"%f",currentPoint.y);
    if (currentPoint.y < 710)
    {
        [self hideBoard];
    }
}

-(void)hideBoard
{
    [self.inputView resignFirstResponder];
    
}
-(IBAction)checkAllData
{
    MessageDetailViewController *messageDetailViewController = [[MessageDetailViewController alloc] init];
    messageDetailViewController.discussionTopic = self.discussionTopicItem;
    
    [self presentViewController:messageDetailViewController animated:NO completion:nil];
    
}
-(void)setData
{
    self.announcementTitle.text = discussionTopicItem.title;
    self.user_name.text = discussionTopicItem.user_name;
    //    self.messageTitle.text = [ToolsObject cleanHtml:(NSMutableString *)discussionTopicItem.message];
    
    [webView loadHTMLString:discussionTopicItem.message baseURL:nil];
    [avatarImage sd_setImageWithURL:[NSURL URLWithString:discussionTopicItem.author.avatar_image_url] placeholderImage:[UIImage imageNamed:@"avatar_default.png"]];
    
    timeTitle.text =[AppUtilities convertTimeStyleGo:discussionTopicItem.posted_at];
    
    //    NSString *str = [ToolsObject cleanHtml:(NSMutableString *)discussionTopicItem.message];
    //    CGSize size = [str sizeWithFont:[UIFont fontWithName:@"Helvetica-Bold" size:16] constrainedToSize:CGSizeMake(175.0f, 2000.0f)];
    //    CGRect rect=self.messageTitle.frame;
    //    rect.size.width=size.width + 555;
    //    rect.size.height = size.height + 7;
    //    rect.origin.x = 0;
    //    rect.origin.y = 139;
    //    [self.messageTitle setFrame:rect];
    //    [self.messageTitle setText:str];
    if ([self.discussionTopicItem.attachments count] > 0)
    {
        fileView.hidden = NO;
        DiscussionTopicAttachmentsItem *attachmentsItem = [self.discussionTopicItem.attachments objectAtIndex:0];
        fileLabel.text = attachmentsItem.filename;
        
    }else
    {
        fileView.hidden = YES;
        [self.webView setFrame:CGRectMake(20, 119, 725, 134)];
    }
    
    [op requestALLTopicEntry:self token:[GlobalOperator sharedInstance].user4Request.user.avatar.token courseId:self.courseId topic_id:self.discussionTopicItem._id];
    
}
- (IBAction)nextAss
{
      btnLast.enabled = YES;
    
        self.discussionTopicItem = [self.assArr objectAtIndex:selectIndex + 1];
        [self setData];
        selectIndex = selectIndex + 1;
    
       if(selectIndex == self.assArr.count - 1)
      {
        btnNext.enabled = NO;
        
      }

}
- (IBAction)lastAss
{
     btnNext.enabled = YES;
    
        self.discussionTopicItem = [self.assArr objectAtIndex:selectIndex - 1];
        [self setData];
        selectIndex = selectIndex - 1;
    if(selectIndex == 0)
    {
        btnLast.enabled = NO;
       
        
    }
    
}

- (IBAction)goback
{
    [self.navigationController popViewControllerAnimated:YES];
}


- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return (interfaceOrientation == UIInterfaceOrientationLandscapeLeft ||
            
            interfaceOrientation == UIInterfaceOrientationLandscapeRight );
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    //    NSLog(@"=%d",[self.currentUnitList count]);
    return [self.currentTopicEntryList count];
}

-(UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
    TopicEntryItem *item = [self.currentTopicEntryList objectAtIndex:section];
    
    TopicEntryParticipantsItem *participantsItem = nil;
    
    for (TopicEntryParticipantsItem *_participantsItem in op.discussionTopic.allTopicEntry.participants)
    {
        if ([_participantsItem._id isEqual:item.user_id])
        {
            participantsItem = _participantsItem;
            break;
        }
    }
    
    
    
    
    UIView * mySectionView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 871, 115)];
    mySectionView.backgroundColor = [UIColor clearColor];
    
    //    UIImageView *imvshaow = [[[UIImageView alloc] initWithFrame:CGRectMake(0, 0, 768, 10)] autorelease];
    //    imvshaow.image = [UIImage imageNamed:@"bg_nav_.png"];
    //    [mySectionView addSubview:imvshaow];
    
    
    UIView *rightView =  [[UIView alloc] initWithFrame:CGRectMake(70, 0, 791, 115)];
    rightView.backgroundColor = [UIColor whiteColor];
    [mySectionView addSubview:rightView];
    
    UIImageView *imvAva = [[UIImageView alloc] initWithFrame:CGRectMake(10, 0, 60, 60)];
    [imvAva sd_setImageWithURL:[NSURL URLWithString:participantsItem.avatar_image_url] placeholderImage:[UIImage imageNamed:@"default_avatar.png"]];
    [mySectionView addSubview:imvAva];
    
    UILabel * nameLabel = [[UILabel alloc] initWithFrame:CGRectMake(15, 12, 150, 30)];
    nameLabel.backgroundColor = [UIColor clearColor];
    nameLabel.font = [UIFont fontWithName:@"Helvetica" size:18];
    nameLabel.textColor = [UIColor colorWithRed:40.0/255 green:120.0/255 blue:200.0/255 alpha:1];
    
    nameLabel.text = participantsItem.display_name;
    [rightView addSubview:nameLabel];
    
    UILabel * messageLabel = [[UILabel alloc] initWithFrame:CGRectMake(15, 32, 753, 60)];
    messageLabel.backgroundColor = [UIColor clearColor];
    messageLabel.font = [UIFont fontWithName:@"Helvetica" size:14];
    messageLabel.textColor = [UIColor colorWithRed:61.0/255 green:69.0/255 blue:76.0/255 alpha:1];
    messageLabel.numberOfLines = 2;
    messageLabel.text =[AppUtilities cleanHtml:(NSMutableString *)item.message];
    [rightView addSubview:messageLabel];
    
    UILabel * timeLabel = [[UILabel alloc] initWithFrame:CGRectMake(15, 80, 350, 30)];
    timeLabel.backgroundColor = [UIColor clearColor];
    timeLabel.font = [UIFont fontWithName:@"Helvetica" size:14];
    timeLabel.textColor = [UIColor colorWithRed:170.0/255 green:174.0/255 blue:178.0/255 alpha:1];
    timeLabel.text = [AppUtilities convertTimeStyleToDayInAnnouncement:item.created_at];
    [rightView addSubview:timeLabel];
    
    
//    NSString *buttonTitle = [NSString stringWithFormat:@"回复%@",nameLabel.text];
    UIButton *replyButton =  [UIButton buttonWithType:UIButtonTypeCustom];
    replyButton.tag = section;
    replyButton.frame = CGRectMake(713, 65, 80, 60);
    [replyButton setTitle:@"回复" forState:UIControlStateNormal];
    [replyButton setTitleColor:[UIColor colorWithRed:61.0/255 green:69.0/255 blue:76.0/255 alpha:1.0] forState:UIControlStateNormal];
    replyButton.titleLabel.font = [UIFont systemFontOfSize:14];
    [replyButton addTarget:self action:@selector(replyPeople:) forControlEvents:UIControlEventTouchUpInside];
    [rightView addSubview:replyButton];
    
    return mySectionView;
}
- (UIView *)tableView:(UITableView *)tableView viewForFooterInSection:(NSInteger)section
{
    UIView *view=[[UIView alloc] initWithFrame:CGRectMake(0, 0,871, 5)];
    view.backgroundColor = [UIColor clearColor];
    return view ;
}



-(void)replyPeople:(UIButton *)sender
{
    TopicEntryItem *item = [self.currentTopicEntryList objectAtIndex:sender.tag];
    btnTag = sender.tag;
    
    TopicEntryParticipantsItem *participantsItem = nil;
    
    for (TopicEntryParticipantsItem *_participantsItem in op.discussionTopic.allTopicEntry.participants)
    {
        if ([_participantsItem._id isEqual:item.user_id])
        {
            participantsItem = _participantsItem;
            break;
        }
    }
    NSLog(@"participantsItem.display_name === %@",participantsItem.display_name);
    [inputView becomeFirstResponder];
    bottomLeftLabel.text = [NSString stringWithFormat:@"回复%@：",participantsItem.display_name];
    
    
}


-(CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    return 115;
}
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if([[currentTopicEntryOpenList objectAtIndex:indexPath.section] intValue] == 0)
    {
        if (indexPath.row == 2)
        {
            return 40;
        }else
        {
            return 73;
        }
        
    }else
    {
        return 73;
    }
    
    return 0;
}
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    //    NSLog(@"=====%d",[[self.currentSecondLevelUnitList objectAtIndex:section] count]);
    //    NSLog(@"%@",openedInSectionArr);
    //    if([[self.openedInSectionArr objectAtIndex:section] intValue] == 1)
    //    {
    //
    //        [openedInSectionArr replaceObjectAtIndex:section withObject:@"0"];
    //        return 0;
    //    }
    
    if ([[currentTopicEntryOpenList objectAtIndex:section] intValue] == 0) {
        return 4;
    }else
    {
        //        NSLog(@"%@",currentTopicEntryReplyList);
        NSArray *array = [self.currentTopicEntryReplyList objectAtIndex:section];
        
        return [array count];
        
    }
    
    return 0;
    
}
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSString *CellIdentifier = [NSString stringWithFormat:@"Cell%ld%ld", (long)[indexPath section], (long)[indexPath row]];
    //    NSString *CellIdentifier = [NSString stringWithFormat:@"CellAnnoucementDetail"];
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil)
    {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
        cell.backgroundColor = [UIColor clearColor];
        cell.contentView.backgroundColor = [UIColor clearColor];
        
        
        if([[currentTopicEntryOpenList objectAtIndex:indexPath.section] isEqualToString:@"0"]){
            //            NSLog(@"%d",indexPath.section);
            
            
            
            
            if(indexPath.row == 2)
            {
                
                UIImageView *bgView = [[UIImageView alloc] initWithFrame:CGRectMake(70, 0, 791, 40)];
                bgView.image = [UIImage imageNamed:@"unit_item_bg.png"];
                bgView.userInteractionEnabled = YES;
                [cell addSubview:bgView];
                
                UIImageView * arrView = [[UIImageView alloc] init];
                arrView.frame = CGRectMake(15, 5, 30, 30);
                arrView.image = [UIImage imageNamed:@"icon_morereplys"];
                [bgView addSubview:arrView];
                
                UILabel * itemslabel = [[UILabel alloc] initWithFrame:CGRectMake(270, 12, 150, 21)];
                itemslabel.backgroundColor = [UIColor clearColor];
                itemslabel.font = [UIFont fontWithName:@"Helvetica" size:14];
                itemslabel.textColor = [UIColor colorWithRed:170.0/255 green:174.0/255 blue:178.0/255 alpha:1];
                itemslabel.text = [NSString stringWithFormat:@"共%ld条回复",(unsigned long)[(NSMutableArray *)[currentTopicEntryReplyList objectAtIndex:indexPath.section] count]];
                [bgView addSubview:itemslabel];
                
                UIButton *openButton =  [UIButton buttonWithType:UIButtonTypeCustom];
                
                
                //[NSString stringWithFormat:@"Cell%d%d", [indexPath section], [indexPath row]
                
                openButton.tag = indexPath.section;
                //[self.dic setObject:indexPath forKey:[NSString stringWithFormat:@"%d",openButton.tag]];
                openButton.frame = CGRectMake(430, 12, 80, 20);
                [openButton setTitle:@"全部展开" forState:UIControlStateNormal];
                [openButton setTitleColor:[UIColor colorWithRed:61.0/255 green:69.0/255 blue:76.0/255 alpha:1.0] forState:UIControlStateNormal];
                openButton.titleLabel.font = [UIFont systemFontOfSize:14];
                [openButton addTarget:self action:@selector(changeOpen:) forControlEvents:UIControlEventTouchUpInside];
                [cell addSubview:openButton];
                
                // [(NSMutableArray *)[currentTopicEntryReplyList objectAtIndex:indexPath.section] count] -3
                
            }else
            {
                
                UIImageView *bgView = [[UIImageView alloc] initWithFrame:CGRectMake(70, 0, 791, 73)];
                bgView.image = [UIImage imageNamed:@"unit_item_bg.png"];
                [cell addSubview:bgView];
                
                UIImageView * arrView = [[UIImageView alloc] init];
                arrView.frame = CGRectMake(15, 18, 30, 30);
                arrView.tag = 101;
                [bgView addSubview:arrView];
                
                
                UILabel * nameLabel = [[UILabel alloc] initWithFrame:CGRectMake(55, 15, 150, 21)];
                nameLabel.tag = 102;
                nameLabel.backgroundColor = [UIColor clearColor];
                nameLabel.font = [UIFont fontWithName:@"Helvetica" size:14];
                nameLabel.textColor = [UIColor colorWithRed:40.0/255 green:120.0/255 blue:200.0/255 alpha:1];
                [bgView addSubview:nameLabel];
                
                UILabel * messageLabel = [[UILabel alloc] initWithFrame:CGRectMake(55, 30, 683, 40)];
                messageLabel.tag = 103;
                messageLabel.backgroundColor = [UIColor clearColor];
                messageLabel.font = [UIFont fontWithName:@"Helvetica" size:14];
                messageLabel.textColor = [UIColor colorWithRed:61.0/255 green:69.0/255 blue:76.0/255 alpha:1];
                messageLabel.numberOfLines = 2;
                //                messageLabel.text = [ToolsObject cleanHtml:(NSMutableString *)replyItem.message];
                [bgView addSubview:messageLabel];
                
                UILabel * timeLabel = [[UILabel alloc] initWithFrame:CGRectMake(570, 15, 150, 21)];
                timeLabel.tag = 104;
                timeLabel.backgroundColor = [UIColor clearColor];
                timeLabel.font = [UIFont fontWithName:@"Helvetica" size:14];
                timeLabel.textColor = [UIColor colorWithRed:170.0/255 green:174.0/255 blue:178.0/255 alpha:1];
                [bgView addSubview:timeLabel];
                
                
            }
            
            
            
        }else
        {
            
            UIImageView *bgView = [[UIImageView alloc] initWithFrame:CGRectMake(70, 0, 791, 73)];
            bgView.image = [UIImage imageNamed:@"unit_item_bg.png"];
            [cell addSubview:bgView];
            
            UIImageView * arrView = [[UIImageView alloc] init];
            arrView.frame = CGRectMake(15, 18, 30, 30);
            arrView.tag = 201;
            //            [arrView sd_setImageWithURL:[NSURL URLWithString:participantsItem.avatar_image_url] placeholderImage:[UIImage imageNamed:@"default_avatar.png"]];
            [bgView addSubview:arrView];
            
            
            UILabel * nameLabel = [[UILabel alloc] initWithFrame:CGRectMake(55, 15, 150, 21)];
            nameLabel.tag = 202;
            nameLabel.backgroundColor = [UIColor clearColor];
            nameLabel.font = [UIFont fontWithName:@"Helvetica" size:14];
            nameLabel.textColor = [UIColor colorWithRed:40.0/255 green:120.0/255 blue:200.0/255 alpha:1];
            
            //            nameLabel.text = participantsItem.display_name;
            [bgView addSubview:nameLabel];
            
            UILabel * messageLabel = [[UILabel alloc] initWithFrame:CGRectMake(55, 30, 683, 40)];
            messageLabel.backgroundColor = [UIColor clearColor];
            messageLabel.tag = 203;
            messageLabel.font = [UIFont fontWithName:@"Helvetica" size:14];
            messageLabel.textColor = [UIColor colorWithRed:61.0/255 green:69.0/255 blue:76.0/255 alpha:1];
            messageLabel.numberOfLines = 2;
            //            messageLabel.text = [ToolsObject cleanHtml:(NSMutableString *)replyItem.message];
            //            messageLabel.text = replyItem.message;
            [bgView addSubview:messageLabel];
            
            UILabel * timeLabel = [[UILabel alloc] initWithFrame:CGRectMake(673, 15, 150, 21)];
            
            timeLabel.tag = 204;
            timeLabel.backgroundColor = [UIColor clearColor];
            timeLabel.font = [UIFont fontWithName:@"Helvetica" size:14];
            timeLabel.textColor = [UIColor colorWithRed:170.0/255 green:174.0/255 blue:178.0/255 alpha:1];
            //            timeLabel.text = [ToolsObject convertTimeStyleToDayInAnnouncement:replyItem.created_at];
            [bgView addSubview:timeLabel];
            
            
            
        }
        
        
    }
    if([[currentTopicEntryOpenList objectAtIndex:indexPath.section] isEqualToString:@"0"])
    {
        NSArray *array = [self.currentTopicEntryReplyList objectAtIndex:indexPath.section];
        NSMutableArray* arr = [NSMutableArray arrayWithObjects:[array objectAtIndex:array.count-1],[array objectAtIndex:array.count-2],@"null",[array objectAtIndex:0], nil];
        
        if(indexPath.row != 2){
            TopicEntryReplyItem *replyItem = [arr objectAtIndex:indexPath.row];
            
            TopicEntryParticipantsItem *participantsItem = nil;
            
            for (TopicEntryParticipantsItem *_participantsItem in op.discussionTopic.allTopicEntry.participants)
            {
                if ([_participantsItem._id isEqual:replyItem.user_id])
                {
                    participantsItem = _participantsItem;
                    
                    break;
                }
            }
            
            UIImageView * imgView= (UIImageView *)[cell viewWithTag:101];
            [imgView sd_setImageWithURL:[NSURL URLWithString:participantsItem.avatar_image_url] placeholderImage:[UIImage imageNamed:@"default_avatar.png"]];
            UILabel *lbName = (UILabel *)[cell viewWithTag:102];
            lbName.text = participantsItem.display_name;
            
            UILabel *lbMessage = (UILabel *)[cell viewWithTag:103];
            lbMessage.text  = replyItem.message;
            
            UILabel *lbTime = (UILabel *)[cell viewWithTag:104];
            lbTime.text = [AppUtilities convertTimeStyleToDayInAnnouncement:replyItem.created_at];
        }
        
    }else if([[currentTopicEntryOpenList objectAtIndex:indexPath.section] isEqualToString:@"1"])
    {
        NSArray *array = [self.currentTopicEntryReplyList objectAtIndex:indexPath.section];
        //        NSLog(@"array ==== %@",array);
        //        NSLog(@"%d",indexPath.row);
        TopicEntryReplyItem *replyItem = [array objectAtIndex:array.count-indexPath.row-1];
        
        TopicEntryParticipantsItem *participantsItem = nil;
        
        for (TopicEntryParticipantsItem *_participantsItem in op.discussionTopic.allTopicEntry.participants)
        {
            if ([_participantsItem._id isEqual:replyItem.user_id])
            {
                participantsItem = _participantsItem;
                
                break;
            }
        }
        UIImageView * imgView= (UIImageView *)[cell viewWithTag:201];
        [imgView sd_setImageWithURL:[NSURL URLWithString:participantsItem.avatar_image_url] placeholderImage:[UIImage imageNamed:@"default_avatar.png"]];
        UILabel *lbName = (UILabel *)[cell viewWithTag:202];
        lbName.text = participantsItem.display_name;
        
        UILabel *lbMessage = (UILabel *)[cell viewWithTag:203];
        lbMessage.text  = replyItem.message;
        
        UILabel *lbTime = (UILabel *)[cell viewWithTag:204];
        lbTime.text = [AppUtilities convertTimeStyleToDayInAnnouncement:replyItem.created_at];
        
        
    }
    
    return cell;
}

-(void)changeOpen:(UIButton *)sender
{
    
    
    [currentTopicEntryOpenList replaceObjectAtIndex:sender.tag withObject:@"1"];
    [self.discussionTableView reloadSections:[NSIndexSet indexSetWithIndex:sender.tag] withRowAnimation:UITableViewRowAnimationTop];
}


#pragma mark 网络代理回调

- (void)requestSuccess:(NSString *)cmd
{
    if ([cmd compare:HTTP_CMD_COURSE_DISSCUSSION_ALLTOPICENTRY] == NSOrderedSame)
    {
        
        //        [self.currentTopicEntryList removeAllObjects];
        [self.currentTopicEntryReplyList removeAllObjects];
        [self.currentTopicEntryOpenList removeAllObjects];
        
        self.currentTopicEntryList = op.discussionTopic.allTopicEntry.views;
        
        if ([self.currentTopicEntryList count] > 0)
        {
            //            [headerView removeFromSuperview];
            [discussionTableView setTableHeaderView:headerView];
            discussionTableView.hidden = NO;
            
            for (TopicEntryItem *item in op.discussionTopic.allTopicEntry.views)
            {
                if (item.replys)
                {
                    //                    NSLog(@"%@",item.replys);
                    [self.currentTopicEntryReplyList addObject:item.replys];
                    if(item.replys.count >3)
                    {
                        [self.currentTopicEntryOpenList addObject:@"0"];
                        
                    }else
                    {
                        [self.currentTopicEntryOpenList addObject:@"1"];
                        
                    }
                }
            }
            
        }
        [discussionTableView reloadData];
//        [self performSelector:@selector(reset) withObject:nil afterDelay:0.5];
        
    }else if ([cmd compare:HTTP_CMD_COURSE_REPLYANNOUNCEMENTS] == NSOrderedSame)
    {
        NSLog(@"111");
        //        [discussionTableView reloadData];
         [self performSelector:@selector(requestALL) withObject:nil afterDelay:1.0];
        
        
    }else if ([cmd compare:HTTP_CMD_COURSE_REPLYPEOPLE] == NSOrderedSame)
    {
        NSLog(@"222");
        [self performSelector:@selector(requestALL) withObject:nil afterDelay:1.0];
        
    }
}
-(void)reset
{
    [discussionTableView reloadData];
    for(NSInteger i = 0;i <self.currentTopicEntryList.count; i++){
        [self.discussionTableView reloadSections:[NSIndexSet indexSetWithIndex:i] withRowAnimation:UITableViewRowAnimationTop];
    }
}
-(void)requestALL
{
    [op requestALLTopicEntry:self token:[GlobalOperator sharedInstance].user4Request.user.avatar.token courseId:self.courseId topic_id:self.discussionTopicItem._id];
}
- (void)requestFailure:(NSString *)cmd errMsg:(NSString *)errMsg
{
    if ([cmd compare:HTTP_CMD_COURSE_ANNOUNCEMENTS_ALLTOPICENTRY] == NSOrderedSame)
    {
        
    }
    
    [AppUtilities showHUD:errMsg andView:self.view];
}
#pragma mark -
#pragma mark TextField Delegate Methods
- (void)textViewDidBeginEditing:(UITextView *)textView
{
    
}
- (void)textViewDidEndEditing:(UITextView *)textView
{
    self.bottomLeftLabel.text = @"回复该讨论：";
}
//-(IBAction)replyAnnouncement
//{
//    self.textHeaderstr = @"发表讨论：";
//    [self.inputView becomeFirstResponder];
//}



-(BOOL)textView:(UITextView *)textView shouldChangeTextInRange:(NSRange)range replacementText:(NSString *)text
{
    if ([text isEqualToString:@"\n"]) {
        
        [self sendMsg];
        return NO;
    }
    return YES;
    
    
}

- (IBAction)sendMsg{
    
    NSString *messageStr = self.inputView.text;
    if([self.bottomLeftLabel.text isEqualToString:@"回复该讨论："]){
        
        if (messageStr != nil && ![@"" isEqualToString:messageStr])
        {
            [self.dataDictionary removeAllObjects];
            [self.dataDictionary setValue:messageStr forKey:@"message"];
            [op postDiscussionReply:self token:[GlobalOperator sharedInstance].user4Request.user.avatar.token courseId:self.courseId topic_id:self.discussionTopicItem._id entries:self.dataDictionary];
        }
    }else
    {
        if (messageStr != nil && ![@"" isEqualToString:messageStr])
        {
            [self.dataDictionary removeAllObjects];
            [self.dataDictionary setValue:messageStr forKey:@"message"];
            TopicEntryItem *item = [self.currentTopicEntryList objectAtIndex:btnTag];
            
            [op postDiscussionPeopleReply:self token:[GlobalOperator sharedInstance].user4Request.user.avatar.token courseId:self.courseId topic_id:self.discussionTopicItem._id entry_id:item._id replies:dataDictionary];
        }
    }
    self.bottomLeftLabel.text = @"回复该讨论：";
    self.inputView.text = @"";
    //    [self.currentTopicEntryList addObject:<#(id)#>]
    
    
    [self.inputView resignFirstResponder];
    
    
    
}

@end
