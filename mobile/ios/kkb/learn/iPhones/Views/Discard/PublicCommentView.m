//
//  PublicCommentView.m
//  learn
//
//  Created by 翟鹏程 on 14-7-31.
//  Copyright (c) 2014年 kaikeba. All rights reserved.
//

#import "PublicCommentView.h"
#import "Cell2.h"
#import "KKBHttpClient.h"
#import "KKBUserInfo.h"
#import "CommentCell.h"
#import "UIImageView+WebCache.h"

@implementation PublicCommentView {
    UITextField *_commentTF;

    UITableView *_commentTableView;
}

- (void)dealloc
{
    
}

- (id)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
        [self initWithUI];
    }
    return self;
}

- (id)initWithCoder:(NSCoder *)aDecoder {
    self = [super initWithCoder:aDecoder];
    if (self) {
    }
    return self;
}

- (void)initWithUI {

    // comment Box 输入框8.26版先不加
    //    UIView *commentBox = [[UIView alloc] initWithFrame:CGRectMake(0, 170,
    //    320, 30)];
    //    commentBox.backgroundColor = [UIColor whiteColor];
    //
    //    [self addSubview:commentBox];
    //    _commentTF = [[UITextField alloc] initWithFrame:CGRectMake(0, 170,
    //    320, 30)];
    //    _commentTF.borderStyle = UITextBorderStyleRoundedRect;
    //    _commentTF.placeholder = @"输入想说的话...";
    //    _commentTF.delegate = self;
    //    [self addSubview:_commentTF];
    // comment tableView

    _commentTableView =
        [[UITableView alloc] initWithFrame:self.bounds
                                     style:UITableViewStylePlain];
    _commentTableView.autoresizingMask =
        UIViewAutoresizingFlexibleLeftMargin | UIViewAutoresizingFlexibleWidth |
        UIViewAutoresizingFlexibleRightMargin |
        UIViewAutoresizingFlexibleTopMargin | UIViewAutoresizingFlexibleHeight |
        UIViewAutoresizingFlexibleBottomMargin;

    _commentTableView.delegate = self;
    _commentTableView.dataSource = self;
    [self addSubview:_commentTableView];

    [self loadComment:YES];
    [self loadComment:NO];
}

#pragma mark - Property
- (void)setCurrentCommentArray:(NSMutableArray *)currentCommentArray {
    if (_currentCommentArray != currentCommentArray) {
        _currentCommentArray = currentCommentArray;
        [self.commentTableView reloadData];
    }
}

- (void)setCourseId:(NSString *)courseId {
    if (_courseId != courseId) {
        _courseId = courseId;

        //加载网络数据
        [self loadComment:YES];
        [self loadComment:NO];
    }
}

#pragma mark - TextFieldDelegate
- (BOOL)textFieldShouldReturn:(UITextField *)textField {
    [_commentTF resignFirstResponder];
    return YES;
}

#pragma mark - TableViewD

- (NSInteger)tableView:(UITableView *)tableView
    numberOfRowsInSection:(NSInteger)section {
    return [_currentCommentArray count];
}

- (CGFloat)tableView:(UITableView *)tableView
    heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    NSDictionary *dic = nil;
    if (_currentCommentArray != nil || _currentCommentArray != 0) {
        dic = [_currentCommentArray objectAtIndex:indexPath.row];
    }
    if (dic != nil) {
        NSString *text = [dic objectForKey:@"content"];
        return [self getCommentCellHeight:text];
    } else
        return 89;
}

- (UITableViewCell *)tableView:(UITableView *)tableView
         cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *cellIde = @"CommentCell";
    CommentCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIde];
    if (cell == nil) {
        cell = [[[NSBundle mainBundle] loadNibNamed:@"CommentCell"
                                              owner:self
                                            options:nil] lastObject];
    }
    NSDictionary *dict = [_currentCommentArray objectAtIndex:indexPath.row];
    if (![[dict objectForKey:@"user_image_url"] isKindOfClass:[NSNull class]]) {
        [cell.commentUserImageView
            sd_setImageWithURL:
                [NSURL URLWithString:[dict objectForKey:@"user_image_url"]]
              placeholderImage:
                  [UIImage imageNamed:@"DiscussCard_head-sculpture_dis.png"]];
    } else {
        [cell.commentUserImageView
            setImage:[UIImage
                         imageNamed:@"DiscussCard_head-sculpture_dis.png"]];
    }

    if (![[dict objectForKey:@"user_name"] isKindOfClass:[NSNull class]]) {
        cell.commentUserNameLabel.text = [dict objectForKey:@"user_name"];
    }
    NSLog(@"%@", [dict objectForKey:@"created_at"]);

    cell.commentTimeLabel.text =
        [self transforTime:[[dict objectForKey:@"created_at"] stringValue]];

    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    cell.selectedBackgroundView.backgroundColor = [UIColor clearColor];
    [cell.commentContentNewLabel setText:[dict objectForKey:@"content"]];
    cell.commentContentNewLabel.textColor = [UIColor blackColor];
    cell.commentContentNewLabel.height =
        cell.commentContentNewLabel.optimumSize.height;
    cell.height += cell.commentContentNewLabel.optimumSize.height - 14;
    
    NSString *courseId = [dict objectForKey:@"course_id"];
    NSDictionary *dic = [[KKBUserInfo shareInstance]getCourseInfoByCourseId:courseId];
    if ([[dic objectForKey:@"type"]isEqualToString:@"InstructiveCourse"]) {
        cell.starRatingView.fullImage = @"star_yellow_full.png";
        cell.starRatingView.halfImage = @"star_yellow_half.png";
    }

    float starNum = [[dict objectForKey:@"rating"] floatValue];
    cell.commentScoreLabel.text =
        [NSString stringWithFormat:@"(%0.f分)", starNum];
    starNum = starNum / 2;
    cell.starRatingView.rating = starNum;
    


    return cell;
}

- (NSString *)transforTime:(NSString *)timeSeconds {
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    //[formatter setDateFormat:@"MM月dd日 HH:mm:ss"];
    [formatter setDateFormat:@"MM月dd日"];
    NSTimeInterval timesec = [timeSeconds doubleValue] / 1000;
    NSDate *createDate = [NSDate dateWithTimeIntervalSince1970:timesec];
    NSString *create_time = [formatter stringFromDate:createDate];

    // 时区
    NSTimeZone *timeZone = [NSTimeZone systemTimeZone];
    NSInteger integer = [timeZone secondsFromGMTForDate:createDate];
    NSDate *localDate = [createDate dateByAddingTimeInterval:integer];
    NSString *localTime = [formatter stringFromDate:localDate];
    NSLog(@"localTime is %@", localTime);
    return create_time;
}

#pragma mark - TableView delegate

//- (void)tableView:(UITableView *)tableView
// didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
//    NSLog(@"did select !!!!");
//}

#pragma mark - Request
- (void)loadComment:(BOOL)fromCache {
    NSString *jsonForComment =
        [NSString stringWithFormat:@"v1/evaluation/courseid/%@", self.courseId];
    [[KKBHttpClient shareInstance] requestAPIUrlPath:jsonForComment
        method:@"GET"
        param:nil
        fromCache:fromCache
        success:^(id result, AFHTTPRequestOperation *operation) {
            NSLog(@"result is %@", result);
            NSArray *array = result;
            NSMutableArray *tempArray = [NSMutableArray array];
            for (NSDictionary *dict in array) {
                NSString *content = [dict objectForKey:@"content"];
                [tempArray addObject:content];
            }
            _currentCommentArray = result;
            [_commentTableView reloadData];
            if ([self.delegate respondsToSelector:@selector(commentCount:)]) {
                [_delegate commentCount:[_currentCommentArray count]];
            }
        }
        failure:^(id result, AFHTTPRequestOperation *operation) {
            NSLog(@"error is %@", result);
        }];
}

- (float)getCommentCellHeight:(NSString *)text {
    float height = 89;
    RTLabel *label = [[RTLabel alloc] initWithFrame:CGRectZero];
    label.font = [UIFont systemFontOfSize:14];
    label.width = 290;
    [label setText:text];
    height += label.optimumSize.height - 14;
    return height;
}

@end
