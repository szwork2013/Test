//
//  CourseArrangeView.m
//  learn
//
//  Created by zxj on 14-6-1.
//  Copyright (c) 2014年 kaikeba. All rights reserved.
//

#import "CourseArrangeView.h"
#import "CourseUnitOperator.h"
#import "HomePageOperator.h"
#import "GlobalOperator.h"
#import "PlayerFrameView.h"
#import "ToolsObject.h"
#import "SuspensionHintView.h"
#import "PageDetailViewController.h"
#define listRect CGRectMake(0.f, 175.f, 320.f, self.frame.size.height - 175.f)
@interface CourseArrangeView()
{
    
}
@end
@implementation CourseArrangeView
{
    NSUInteger selectedSection;
    NSUInteger selectedRow;
    // add
    BOOL isTouched;
    BOOL isTheFirstTimeToTouch;
}
@synthesize couseArrangeDelegate;
@synthesize courseState;
@synthesize playerFrameView;
@synthesize courseArrangeList;
@synthesize courseUnits;
@synthesize currentSecondLevelUnitList;
@synthesize openedInSectionArr;
@synthesize selectIndex;
@synthesize homePageOperator;
@synthesize courseUnitOperator;
@synthesize courseId;
@synthesize courseImage;
@synthesize courseName;
// add
@synthesize videoUrlArray,videoArrCount,modulesItemDic,videoTitleArray;

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
        [[SuspensionHintView appearance] setPopupColor:[UIColor whiteColor]];
        self.courseUnits = [[NSMutableArray alloc] init];
        self.currentSecondLevelUnitList = [[NSMutableArray alloc] init];
        self.openedInSectionArr = [[NSMutableArray alloc] init];
        // add
        self.videoUrlArray = [[NSMutableArray alloc] init];
        self.videoTitleArray = [[NSMutableArray alloc] init];
        videoArrCount = 1;
        isTouched = NO;
        isTheFirstTimeToTouch = YES;
        self.modulesItemDic = [[NSMutableDictionary alloc] init];
//        NSLog(@"courseUnits %@",self.courseUnits);
//        NSLog(@"modulesItemDic %@",self.modulesItemDic);
        
        self.homePageOperator = (HomePageOperator *)[[GlobalOperator sharedInstance] getOperatorWithModuleType:KAIKEBA_MODULE_HOMEPAGE];
        self.courseUnitOperator = (CourseUnitOperator *)[[GlobalOperator sharedInstance] getOperatorWithModuleType:KAIKEBA_MODULE_COURSEUNIT];

        [self initWithStart:(KKBCourseState)[ToolsObject getIsFirstIn]];
        
    }
    return self;
}


- (void)initWithStart:(KKBCourseState)state
{
    /*start first course arrange view init*/
    self.courseState = state;
    switch (state) {
        case KKBCourseStart:
            [self initCourseList:self.bounds];
        case KKBCourseStarted:

            // 添加视频播放的View
            self.playerFrameView = [[PlayerFrameView alloc] initWithFrame:CGRectMake(0.f, 0.f, 320.f, 175.f)];
            if (courseArrangeList == nil) {
                [self initCourseList:listRect];
            }
            else
            {
                [courseArrangeList setFrame:listRect];
            }
            
            [self addSubview:self.playerFrameView];
            [self addSubview:courseArrangeList];
            break;
        default:
            break;
    }
}
- (void)initbackImage
{
    // add delegate
    self.playerFrameView.playerFrameDelegate = self;
    self.playerFrameView.imageURL = self.courseImage;
    [self.playerFrameView initImage];
}
- (void)initCourseList:(CGRect)rect
{
    courseArrangeList = [[UITableView alloc] initWithFrame:rect];
    courseArrangeList.delegate = self;
    courseArrangeList.dataSource = self;
}
/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect
{
    // Drawing code
}
*/
-(UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
    
    UIView * mySectionView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 320, 60)];
    mySectionView.backgroundColor = [UIColor colorWithPatternImage:[UIImage imageNamed:@"unit_Ititlebar_nav"]];
    UIButton * myButton = [UIButton buttonWithType:UIButtonTypeCustom];
    myButton.frame = CGRectMake(0, 0, 871, 40);
    myButton.tag = 100 + section;
    [myButton addTarget:self action:@selector(tapHeader:) forControlEvents:UIControlEventTouchUpInside];
    [mySectionView addSubview:myButton];
    
    
    NSString *name = ((UnitItem *)[self.courseUnits objectAtIndex:section]).name;
    
    UILabel * myLabel = [[UILabel alloc] initWithFrame:CGRectMake(12, 15, 320, 30)];
    myLabel.backgroundColor = [UIColor clearColor];
    myLabel.font = [UIFont fontWithName:@"Helvetica" size:13];
    myLabel.text = name;
    [myButton addSubview:myLabel];
    
    return mySectionView;
}
-(void)tapHeader:(UIButton *)sender
{
    // add
    if (isTheFirstTimeToTouch == YES) {
        for (int i = 0; i < openedInSectionArr.count; i++) {
            [openedInSectionArr replaceObjectAtIndex:i withObject:@"1"];
        }
    } else {
        if ([[openedInSectionArr objectAtIndex:sender.tag - 100] intValue] == 0) {
            [openedInSectionArr replaceObjectAtIndex:sender.tag - 100 withObject:@"1"];
            //        NSLog(@"%d打开",sender.tag);
        }
        else
        {
            [openedInSectionArr replaceObjectAtIndex:sender.tag - 100 withObject:@"0"];
            //        NSLog(@"%d关闭",sender.tag);
        }
    }
    isTheFirstTimeToTouch = NO;
    // change
//    if ([[openedInSectionArr objectAtIndex:sender.tag - 100] intValue] == 0) {
//        [openedInSectionArr replaceObjectAtIndex:sender.tag - 100 withObject:@"1"];
//        //        NSLog(@"%d打开",sender.tag);
//    }
//    else
//    {
//        [openedInSectionArr replaceObjectAtIndex:sender.tag - 100 withObject:@"0"];
//        //        NSLog(@"%d关闭",sender.tag);
//    }
    // add
    NSLog(@"modulesItemDic is %@",self.modulesItemDic);
    if (videoArrCount == 1) {
        for( int i = 0; i <[self.courseUnitOperator.courseUnit.modulesItemDic allKeys].count;i++){
            NSLog(@"modulesArray is %@",self.courseUnitOperator.courseUnit.modulesArray);
            NSMutableArray *arr = [[self.courseUnitOperator.courseUnit.modulesItemDic allValues] objectAtIndex:i];
            // add
//            NSLog(@"arr is %@",arr);
            for(UnitDownladItem *downItem in arr)
            {
                [videoUrlArray addObject:downItem.videoUrl];
                // add
                [videoTitleArray addObject:downItem.videoTitle];
                // end
            }
            NSLog(@"----------------");
        }
        NSLog(@"111111videoUrlArray is %@ count %lu",videoUrlArray,(unsigned long)videoUrlArray.count);
        // add
        self.playerFrameView.videoUrlArray = self.videoUrlArray;
        self.playerFrameView.videoTitleArray = self.videoTitleArray;
    }
    videoArrCount = 100;
    // end
    
    [courseArrangeList reloadData];
}
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
   return [self.courseUnits count];
}
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if ([[self.openedInSectionArr objectAtIndex:section] intValue] == 1 &&
        [self.currentSecondLevelUnitList count] > section) {
        return [[self.currentSecondLevelUnitList objectAtIndex:section] count];
    }
    
    return 0;
}
- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    return 60.f;
}
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    
    return 50;
    
}
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSString *CellIdentifier = [NSString stringWithFormat:@"Cell%ld%ld", (long)[indexPath section], (long)[indexPath row]];
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    
    
    if (cell == nil)
    {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
        cell.backgroundColor = [UIColor colorWithRed:240.0/255.0 green:240.0/255.0 blue:240.0/255.0 alpha:1.0];
        
        UIImageView* unitCellIcon = [[UIImageView alloc] init];
        unitCellIcon.frame = CGRectMake(14, 15, 24, 24);
        unitCellIcon.tag = 60;
        [cell addSubview:unitCellIcon];
        
        UILabel *title = [[UILabel alloc] initWithFrame:CGRectMake(60, 9, 240, 34)];
        title.tag = 61;
        title.numberOfLines = 2;
        title.backgroundColor = [UIColor clearColor];
        title.textColor = [UIColor colorWithRed:128.0/255 green:128.0/255 blue:128.0/255 alpha:1];
        title.font = [UIFont fontWithName:@"Helvetica" size:13];
        [cell.contentView addSubview:title];
    }
    
    
    UIImageView *unitCellIcon = (UIImageView*)[cell viewWithTag:60];
    UILabel *nameLabel = (UILabel *)[cell viewWithTag:61];
    NSArray *array = [NSArray arrayWithArray:[self.currentSecondLevelUnitList objectAtIndex:indexPath.section]];
    
    
    if ([array count] != 0 && indexPath.row < [array count]) {
        NSString *type = [((NSDictionary *)[array objectAtIndex:indexPath.row]) objectForKey:@"type"];
        
        if ([type isEqual:@"Page"])//页面
        {
            unitCellIcon.image = [UIImage imageNamed:@"unit_icon_page_active_dark.png"];
        }
        else if ([type isEqual:@"Discussion"])//讨论
        {
            unitCellIcon.image = [UIImage imageNamed:@"unit_icon_dis_active_dark.png"];
        }
        else if ([type isEqual:@"Assignment"])//作业
        {
            unitCellIcon.image = [UIImage imageNamed:@"unit_icon_assignment_active_dark.png"];
        }
        else if ([type isEqual:@"Quiz"])//测验
        {
            unitCellIcon.image = [UIImage imageNamed:@"unit_icon_quiz_active_dark.png"];
        }
        else if ([type isEqual:@"File"])//文件
        {
            unitCellIcon.image = [UIImage imageNamed:@"unit_icon_download_active_dark.png"];
        } else if ([type isEqual:@"ExternalTool"])//wailian
        {
            unitCellIcon.image = [UIImage imageNamed:@"unit_icon_video_active_dark"];
        }
        
        
        nameLabel.text = [((NSDictionary *)[array objectAtIndex:indexPath.row]) objectForKey:@"title"];
        nameLabel.textColor = [UIColor colorWithRed:61.0/255 green:69.0/255 blue:76.0/255 alpha:1];
    }
    if (isTouched == YES) {
        if (indexPath.section == selectedSection && indexPath.row == selectedRow) {
            [tableView selectRowAtIndexPath:[NSIndexPath indexPathForRow:selectedRow inSection:selectedSection] animated:YES scrollPosition:UITableViewScrollPositionBottom];
        }
    }
    return cell;
}
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    if([ToolsObject isExistenceNetwork]){
        
        NSArray *array = [self.currentSecondLevelUnitList objectAtIndex:indexPath.section];
        if ([((NSDictionary *)[array objectAtIndex:indexPath.row]) objectForKey:@"url"]){
            //截取字符串
            NSString *regex = @"/";
            NSPredicate *predicate = [NSPredicate predicateWithFormat:@"SELF CONTAINS %@", regex];
            
            NSMutableString *url = [[NSMutableString alloc] init];
            
            [url setString: [((NSDictionary *)[array objectAtIndex:indexPath.row]) objectForKey:@"url"]];
            
            while ([predicate evaluateWithObject:url])
            {
                NSRange range = [url rangeOfString:regex];
                [url setString:[url substringFromIndex:range.location + 1]];
            }
            if([self isPureInt:url] == YES){
                [ToolsObject showHUD:@"下个版本即将支持，敬请期待" andView:self];
                
            }else{
                
                NSArray *array = [self.currentSecondLevelUnitList objectAtIndex:indexPath.section];
                [couseArrangeDelegate loadingWebView:array url:url indexPath:indexPath];
            }
            
        } else if ([[((NSDictionary *)[array objectAtIndex:indexPath.row]) objectForKey:@"type"] isEqualToString:@"ExternalTool"])
        {
            if([self.courseUnitOperator.courseUnit.modulesItemDic allKeys].count > 0){//supclass课程
                
                //            NSLog(@"array ==== %@",array);
                //        NSLog(@"%d",indexPath.row);
                // add
                NSLog(@"dict-1-1-1-1-1-1- %@",[self.courseUnitOperator.courseUnit.modulesItemDic allKeys]);
                
                NSString *detailItemId = [((NSDictionary *)[array objectAtIndex:indexPath.row]) objectForKey:@"id"];
                // add
                NSLog(@"detailItemId is %@",detailItemId);
                
                for( int i = 0; i <[self.courseUnitOperator.courseUnit.modulesItemDic allKeys].count;i++){
                    
                    
                    NSMutableArray *arr = [[self.courseUnitOperator.courseUnit.modulesItemDic allValues] objectAtIndex:i];
                    // add
                    NSLog(@"arr is %@",arr);
                    for(UnitDownladItem *downItem in arr)
                    {
                        if([downItem.itemID intValue] == [detailItemId intValue]){
                            
                            
//                            NSArray *array = [self.currentSecondLevelUnitList objectAtIndex:indexPath.section];
                            
//                            PageDetailViewController *pageController = [[[PageDetailViewController alloc]initWithNibName:@"PageDetailViewController" bundle:nil]autorelease];
//                            
//                            [self.navigationController pushViewController:pageController animated:YES];
//                            pageController.lbtitle.text =[((NSDictionary *)[array objectAtIndex:indexPath.row]) objectForKey:@"title"];
//                            pageController.videoUrl = downItem.videoUrl;
//                            pageController.strCourseID = self.courseId;
//                            pageController.imageUrl = self.courseImage;
//                            self.courseState = [ToolsObject getIsFirstIn];
//                            switch (self.courseState) {
//                                case KKBCourseStart:
//                                {
//                                    SuspensionHintView *popup = [SuspensionHintView popupWithText:@"您还没有加入学习此课程哦\n快去学习吧"];
//                                    
//                                    [popup showInView:self.courseArrangeList
//                                        centerAtPoint:self.courseArrangeList.center
//                                             duration:kLPPopupDefaultWaitDuration
//                                           completion:nil];
//                                }
//                                    break;
//                                case KKBCourseStarted:
//                                {
//                                    self.playerFrameView.promoVideoStr = downItem.videoUrl;
//                                    self.playerFrameView.strCourseID = self.courseId;
//                                    self.playerFrameView.imageURL = self.courseImage;
//                                    
//                                    [self.playerFrameView playMovieAtURL];
//                                }
//                                    
//                                    break;
//                                default:
//                                    break;
//                            }
//                            
//                            break;
                            // add
                            NSString *lastVideoUrl = [self.videoUrlArray lastObject];
                            NSLog(@"videoUrl is %@%@%@",downItem.videoUrl,lastVideoUrl,videoUrlArray);
                            if ([downItem.videoUrl isEqualToString:lastVideoUrl]) {
                                self.playerFrameView.isTheLastMovie = YES;
                            } else {
                                self.playerFrameView.isTheLastMovie = NO;
                                self.playerFrameView.currentVideoUrl = downItem.videoUrl;
                            }
                            // end
                            
                            self.playerFrameView.promoVideoStr = downItem.videoUrl;
                            // add
                            self.playerFrameView.promoVideoStr = self.playerFrameView.currentVideoUrl;
                            self.playerFrameView.strCourseID = self.courseId;
                            self.playerFrameView.imageURL = self.courseImage;
                            
                            [self.playerFrameView playMovieAtURL];
                        }
                    }
                    
                }
                
                
            }else{
                
                [ToolsObject showHUD:@"下个版本即将支持，敬请期待" andView:self];
            }
        }else{
            
            [ToolsObject showHUD:@"下个版本即将支持，敬请期待" andView:self];
        }
        
    }else
    {
        [ToolsObject showHUD:@"无网络连接，请检查你的网络" andView:self];
    }
    
    [tableView selectRowAtIndexPath:indexPath animated:YES scrollPosition:UITableViewScrollPositionNone];
    selectedSection = indexPath.section;
    selectedRow = indexPath.row;
    // add
    isTouched = YES;
}

// add
- (void)sendVideoTitle:(NSString *)videoTitle{
    for (int i = 0; i < self.currentSecondLevelUnitList.count; i++) {
        NSArray *array = [NSArray arrayWithArray:[self.currentSecondLevelUnitList objectAtIndex:i]];
        for (int j = 0; j < array.count; j++) {
            NSString *title = [((NSDictionary *)[array objectAtIndex:j]) objectForKey:@"title"];
            if ([title isEqualToString:videoTitle]) {
                NSIndexPath *indexPath = [NSIndexPath indexPathForRow:j inSection:i];
                selectedSection = indexPath.section;
                selectedRow = indexPath.row;
                [self.courseArrangeList selectRowAtIndexPath:indexPath animated:YES scrollPosition:UITableViewScrollPositionNone];
            }
        }
    }
}

//判断是否位数字，暂时
- (BOOL)isPureInt:(NSString *)string{
    NSScanner* scan = [NSScanner scannerWithString:string];
    int val;
    return [scan scanInt:&val] && [scan isAtEnd];
}

@end
