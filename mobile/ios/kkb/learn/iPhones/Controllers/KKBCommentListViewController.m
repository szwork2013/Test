//
//  KKBCommentListViewController.m
//  learn
//
//  Created by zengmiao on 8/24/14.
//  Copyright (c) 2014 kaikeba. All rights reserved.
//

#import "KKBCommentListViewController.h"
#import "KKBHttpClient.h"
#import "CommentCell.h"
#import "KKBUserInfo.h"
static const int ddLogLevel = LOG_LEVEL_WARN;

@interface KKBCommentListViewController () <UITableViewDataSource,
                                            UITableViewDelegate>

@property(nonatomic, strong) NSString *courseId;

@property(nonatomic, strong) UITableView *commentTableView;

@property(nonatomic, strong) NSMutableArray *currentCommentArray;

@end

@implementation KKBCommentListViewController

- (void)dealloc {
}

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
    self.courseId = [self.currentCourse objectForKey:@"id"];
    [self initWithUI];
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
//    [self updateBackground];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Custom Methods
- (void)initWithUI {
    self.commentTableView =
        [[UITableView alloc] initWithFrame:self.view.bounds
                                     style:UITableViewStylePlain];
    _commentTableView.autoresizingMask =
        UIViewAutoresizingFlexibleLeftMargin | UIViewAutoresizingFlexibleWidth |
        UIViewAutoresizingFlexibleRightMargin |
        UIViewAutoresizingFlexibleTopMargin | UIViewAutoresizingFlexibleHeight |
        UIViewAutoresizingFlexibleBottomMargin;

    _commentTableView.delegate = self;
    _commentTableView.dataSource = self;
    [self.view addSubview:_commentTableView];

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

#pragma mark - TextField Delegate Methods
- (BOOL)textFieldShouldReturn:(UITextField *)textField {
    return YES;
}

#pragma mark - TableView Delegate Methods
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
                  [UIImage imageNamed:@"DiscussCard_head-sculpture_dis"]];
    } else {
        [cell.commentUserImageView
            setImage:[UIImage imageNamed:@"DiscussCard_head-sculpture_dis"]];
    }

    if (![[dict objectForKey:@"user_name"] isKindOfClass:[NSNull class]]) {
        cell.commentUserNameLabel.text = [dict objectForKey:@"user_name"];
    }
    DDLogInfo(@"%@", [dict objectForKey:@"created_at"]);

    cell.commentTimeLabel.text =
        [self transforTime:[[dict objectForKey:@"created_at"] stringValue]];

    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    cell.selectedBackgroundView.backgroundColor = [UIColor clearColor];
    [cell.commentContentNewLabel setText:[dict objectForKey:@"content"]];
    cell.commentContentNewLabel.textColor = [UIColor blackColor];
    cell.commentContentNewLabel.height =
        cell.commentContentNewLabel.optimumSize.height;
    cell.height += cell.commentContentNewLabel.optimumSize.height - 14;

    if ([[self.currentCourse objectForKey:@"type"]
            isEqualToString:@"InstructiveCourse"]) {
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
    DDLogInfo(@"localTime is %@", localTime);
    return create_time;
}

#pragma mark - Request
- (void)loadComment:(BOOL)fromCache {
    NSString *jsonForComment =
        [NSString stringWithFormat:@"v1/evaluation/courseid/%@", self.courseId];
    [[KKBHttpClient shareInstance] requestAPIUrlPath:jsonForComment
        method:@"GET"
        param:nil
        fromCache:fromCache
        success:^(id result, AFHTTPRequestOperation *operation) {
            DDLogInfo(@"result is %@", result);
            NSArray *array = result;
            NSMutableArray *tempArray = [NSMutableArray array];
            for (NSDictionary *dict in array) {
                NSString *content = [dict objectForKey:@"content"];
                [tempArray addObject:content];
            }
            _currentCommentArray = result;
            [_commentTableView reloadData];
        }
        failure:^(id result, AFHTTPRequestOperation *operation) {
            DDLogInfo(@"error is %@", result);
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
