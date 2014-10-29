//
//  KKBCommentListView.m
//  learn
//
//  Created by pczhai on 14-9-15.
//  Copyright (c) 2014年 kaikeba. All rights reserved.
//

#import "KKBCommentListView.h"
#import "RTLabel.h"
#import "CommentCell.h"

@implementation KKBCommentListView {
    UITableView *commentTableView;
    NSArray *commentArray;
    NSString *currentCourseType;
    UITapGestureRecognizer *tapGesture;

    UIView *commentCoverView;

    CGFloat tableViewHeight;
}

- (id)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
        [self uiConfig];
    }
    return self;
}

- (id)initWithCoder:(NSCoder *)aDecoder {
    self = [super initWithCoder:aDecoder];
    if (self) {
        [self uiConfig];
    }
    return self;
}

- (void)uiConfig {
}

- (id)initWithFrame:(CGRect)frame
       CommentArray:(NSArray *)array
         CourseType:(NSString *)courseType {
    self = [super initWithFrame:frame];
    self.backgroundColor = [UIColor clearColor];
    if (self) {
        commentCoverView = [[UIView alloc] initWithFrame:frame];
        commentCoverView.backgroundColor = [UIColor blackColor];
        commentCoverView.alpha = 0.5;
        [self addSubview:commentCoverView];

        commentTableView = [[UITableView alloc]
            initWithFrame:CGRectMake(0, G_SCREEN_HEIGHT / 3, G_SCREEN_WIDTH,
                                     G_SCREEN_HEIGHT / 3 * 2)
                    style:UITableViewStylePlain];
        commentTableView.delegate = self;
        commentTableView.dataSource = self;
        commentTableView.showsVerticalScrollIndicator = NO;
        commentTableView.bounces = NO;
        [self addSubview:commentTableView];
        commentArray = [[NSArray alloc] init];
        commentArray = array;
        currentCourseType = courseType;

        tapGesture = [[UITapGestureRecognizer alloc]
            initWithTarget:self
                    action:@selector(tapAction:)];
        tapGesture.delegate = self;
        [commentCoverView addGestureRecognizer:tapGesture];
        self.hidden = YES;
    }
    return self;
}

- (void)tapAction:(UITapGestureRecognizer *)tapGesture {
    [self dismissCommentTableView];
}

- (void)dismissCommentTableView {
    NSLog(@"CoverViewClick");
    [_delegate commentListViewCoverViewClick];
    [UIView animateWithDuration:0.2
        animations:^{
            commentTableView.frame =
                CGRectMake(0, G_SCREEN_HEIGHT, G_SCREEN_WIDTH, tableViewHeight);
        }
        completion:^(BOOL finished) { self.hidden = YES; }];
}

- (void)showCommentView {
    self.hidden = NO;
    [UIView animateWithDuration:0.2
                     animations:^{
                         commentTableView.frame =
                             CGRectMake(0, G_SCREEN_HEIGHT - tableViewHeight,
                                        G_SCREEN_WIDTH, tableViewHeight);
                     }];
}

#pragma mark - UITableViewDelegate
- (NSInteger)tableView:(UITableView *)tableView
    numberOfRowsInSection:(NSInteger)section {
    return commentArray.count;
}

- (CGFloat)tableView:(UITableView *)tableView
    heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    NSDictionary *dic = nil;
    if (commentArray != nil || commentArray != 0) {
        dic = [commentArray objectAtIndex:indexPath.row];
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
    NSDictionary *dict = [commentArray objectAtIndex:indexPath.row];
    if (![[dict objectForKey:@"user_image_url"] isKindOfClass:[NSNull class]]) {
        [cell.commentUserImageView
            sd_setImageWithURL:
                [NSURL URLWithString:[dict objectForKey:@"user_image_url"]]
              placeholderImage:
                  [UIImage imageNamed:@"DiscussCard_head-sculpture_dis"]];
    } else {
        [cell.commentUserImageView
            setImage:[UIImage imageNamed:@"DiscussCard_head-sculpture_dis"]];
    }

    if (![[dict objectForKey:@"user_name"] isKindOfClass:[NSNull class]]) {
        cell.commentUserNameLabel.text = [dict objectForKey:@"user_name"];
    }

    cell.commentTimeLabel.text =
        [self transforTime:[[dict objectForKey:@"created_at"] stringValue]];

    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    cell.selectedBackgroundView.backgroundColor = [UIColor clearColor];
    [cell.commentContentNewLabel setText:[dict objectForKey:@"content"]];
    cell.commentContentNewLabel.textColor = [UIColor blackColor];
    cell.commentContentNewLabel.height =
        cell.commentContentNewLabel.optimumSize.height;
    cell.height += cell.commentContentNewLabel.optimumSize.height - 14;

    if ([currentCourseType isEqualToString:@"InstructiveCourse"]) {
        cell.starRatingView.fullImage = @"star_yellow_full";
        cell.starRatingView.halfImage = @"star_yellow_half";
    }

    float starNum = [[dict objectForKey:@"rating"] floatValue];
    cell.commentScoreLabel.text =
        [NSString stringWithFormat:@"(%0.f分)", starNum];
    starNum = starNum / 2;
    cell.starRatingView.rating = starNum;

    return cell;
}

- (void)layoutSubviews {
    if (commentArray.count * 89 > G_SCREEN_HEIGHT / 3 * 2) {
        tableViewHeight = G_SCREEN_HEIGHT / 3 * 2;
    } else {
        tableViewHeight = commentArray.count * 89;
    }
    commentTableView.frame =
        CGRectMake(0, G_SCREEN_HEIGHT, G_SCREEN_WIDTH, tableViewHeight);
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
    return create_time;
}

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect
{
    // Drawing code
}
*/

@end
