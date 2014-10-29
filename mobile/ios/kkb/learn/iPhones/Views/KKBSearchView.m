
#import "KKBSearchView.h"
#import "KKBHttpClient.h"
#import <QuartzCore/QuartzCore.h>
#import "KKBEmptyContentView.h"
#import "CourseItemCell.h"
#import "KKBCourseItemCellModel.h"
#import "AppDelegate.h"
#import "KKBHttpClient.h"
#import "AppUtilities.h"
#import "KKBSearchFailedView.h"
#import "KKBSearchingView.h"

static const CGFloat SearchBarFadeInAnimationDuration = 0.2f;

static const CGFloat SearchResultTableHeaderViewHeight = 44.0f;
static const CGFloat SearchResultTableHeaderViewHeight2 = 20.0f;
static const CGFloat SearchHistoryTableFooterViewHeight = 52.0f;

static const CGFloat SearchTextFieldOriginXOnSearchingStatus = 40.0f;
static const CGFloat SearchTextFieldWidthOnSearchingStatus = 232.0f;

static const CGFloat SearchTextFieldOriginXOnStandbyStatus = 8.0f;
static const CGFloat SearchTextFieldWidthOnStandbyStatus = 304.0f;

static const CGFloat TableViewOriginY = 68.0f;
static const CGFloat SearchBarViewHeight = 48.0f;

static const CGFloat ClearAllHistoryButtonWidth = 128.0f;
static const CGFloat ClearAllHistoryButtonHeight = 32.0f;

static const CGFloat ClearAllHistoryButtonOriginY = 20.0f;

static const CGFloat TableViewDefaultHeight = 44.0f;

static const CGFloat CancelButtonWidth = 48.0f;
static const CGFloat CancelButtonOriginY = 2.0f;

static const CGFloat RecordButtonWidth = 40.0f;
static const CGFloat RecordButtonOriginY = 4.0f;

static const CGFloat SearchFailedViewOriginY = 68.0f;
static const CGFloat SearchingViewOriginY = SearchFailedViewOriginY;

@interface KKBSearchView () {

    NSArray *searchList;

    NSArray *searchResultsOriginArray;
    NSMutableArray *searchResultsArray;
    NSDictionary *allCoursesDataArray; //全部课程数据
    NSMutableArray *coursesRecommendedArray;

    UIView *footerView;

    BOOL searchOnlineMode;
    BOOL loadDataSuccessOnce;
    BOOL keyboardSearchButtonDidPress;
    NSNumber *courseIdSelected;

    KKBSearchFailedView *searchFailedView;
    KKBSearchingView *searchingView;
    KKBEmptyContentView *emptyContentView;

    NSOperationQueue *searchOperationQueue;
}

@end

@implementation KKBSearchView

- (id)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
    }
    return self;
}

#pragma mark - IBAction Methods
- (IBAction)recordButtonDidPress:(id)sender {

    [_searchTextField resignFirstResponder];
    [self.delegate recordAudioButtonDidPress];
}

- (IBAction)cancelButtonDidPress:(id)sender {

    [self restoreSearchTextFieldWidthAndCoordinate];
    [self modifySearchBarTextAlignment];
    [self dismissRecordButton];
    [self dismissCancelButton];
    [self dismissKeyboard];

    [self.searchHistoryTableView reloadData];
    [self collapeTableView];

    [self.delegate cancelButtonDidPress];
}

- (IBAction)keyboardSearchButtonDidPress {

    keyboardSearchButtonDidPress = YES;

    if (searchOperationQueue.operationCount > 0) {
        // disable search UI and show loading
        // [self showView:searchingView];
        self.userInteractionEnabled = NO;
        return;
    } else {
        // enable search UI
        self.userInteractionEnabled = YES;
    }

    NSString *keyword = [_searchTextField.text
        stringByTrimmingCharactersInSet:
            [NSCharacterSet whitespaceAndNewlineCharacterSet]];
    if (keyword == nil || keyword.length == 0) {
        return;
    }

    [_searchTextField resignFirstResponder];

    BOOL connected = [AppUtilities isExistenceNetwork];
    if (connected) {
        // 在线搜索
        [self showView:searchingView];

        NSMutableArray *tempCourseIdsArray = [[NSMutableArray alloc] init];
        for (NSDictionary *aDict in searchResultsOriginArray) {

            NSUInteger courseIdInt = [[aDict objectForKey:@"id"] integerValue];
            NSNumber *aCourseId = [NSNumber numberWithInteger:courseIdInt];
            [tempCourseIdsArray addObject:aCourseId];
        }

        [KKBCourseManager getCoursesWithIDs:(NSArray *)tempCourseIdsArray
                                forceReload:YES
                          completionHandler:^(id model, NSError *error) {

                              if (model != nil &&
                                  ((NSArray *)model).count > 0 &&
                                  error == nil) {

                                  [searchResultsArray removeAllObjects];
                                  [self.searchResultTableView reloadData];

                                  for (NSDictionary *aDictionary in(
                                           NSArray *)model) {

                                      [self parseDictionary:aDictionary];
                                  }

                                  [self.searchResultTableView reloadData];
                                  [self showView:self.searchResultTableView];
                                  footerView.hidden = YES;
                                  loadDataSuccessOnce = YES;
                              } else if (model != nil &&
                                         ((NSArray *)model).count == 0 &&
                                         error == nil) {
                                  // 如果返回的结果中无数据，提示用户［未搜索到相关课程］
                                  [self showView:emptyContentView];
                              } else {
                                  // 如果返回的结果失败，则提示［数据加载失败］
                                  [self showView:searchFailedView];
                                  loadDataSuccessOnce = NO;
                              }
                          }];

        [self insertSearchRecordToDb];
    } else {

        [searchResultsArray removeAllObjects];
        [self.searchResultTableView reloadData];

        [self showView:self.searchResultTableView];
        footerView.hidden = YES;

        // 本地搜索
        [allCoursesDataArray
            enumerateKeysAndObjectsUsingBlock:^(id key, id dictionary,
                                                BOOL *stop) {

                if ([[dictionary objectForKey:@"name"]
                        rangeOfString:_searchTextField.text
                              options:NSCaseInsensitiveSearch].location !=
                    NSNotFound) {

                    [self parseDictionary:dictionary];
                }
            }];

        [self.searchResultTableView reloadData];
        [self insertSearchRecordToDb];
    }
}

- (void)searchHistoryTableViewCellDidSelectWhenOnlineMode {

    NSString *apiPath = @"v1/courses/search";
    NSMutableDictionary *dictionary = [[NSMutableDictionary alloc] init];
    [dictionary setObject:_searchTextField.text forKey:@"keyword"];
    [[KKBHttpClient shareInstance] requestAPIUrlPath:apiPath
        method:@"POST"
        param:dictionary
        fromCache:NO
        success:^(id result, AFHTTPRequestOperation *operation) {
            // success

            searchResultsOriginArray = (NSArray *)result;
            [self keyboardSearchButtonDidPress];
        }
        failure:^(id result, AFHTTPRequestOperation *operation) {// failure
                }];
}

- (void)oneCourseFromLocalStorageDidSelect {

    [_searchTextField resignFirstResponder];

    [self showView:self.searchResultTableView];
    footerView.hidden = YES;

    // 本地搜索
    [searchResultsArray removeAllObjects];
    [self.searchResultTableView reloadData];

    [allCoursesDataArray
        enumerateKeysAndObjectsUsingBlock:^(id key, id dictionary, BOOL *stop) {

            if ([[dictionary objectForKey:@"name"]
                    rangeOfString:_searchTextField.text
                          options:NSCaseInsensitiveSearch].location !=
                NSNotFound) {

                [self parseDictionary:dictionary];
            }
        }];

    [self.searchResultTableView reloadData];
    [self insertSearchRecordToDb];
}

- (void)oneCourseItemFromRemoteServerDidSelect {

    [_searchTextField resignFirstResponder];

    [self showView:self.searchResultTableView];
    footerView.hidden = YES;

    // 远程搜索

    [KKBCourseManager getCourseWithID:courseIdSelected
                          forceReload:YES
                    completionHandler:^(id model, NSError *error) {

                        if (error == nil) {

                            [searchResultsArray removeAllObjects];
                            [self.searchResultTableView reloadData];

                            [self parseDictionary:(NSDictionary *)model];
                            [self.searchResultTableView reloadData];
                        }
                    }];

    [self insertSearchRecordToDb];
}

#pragma mark - Custom Methods
- (void)modifySearchTextFieldWidthAndCoordinate {

    [UIView animateWithDuration:SearchBarFadeInAnimationDuration
                     animations:^{

                         CGFloat x = SearchTextFieldOriginXOnSearchingStatus;
                         CGFloat y = _searchTextField.frame.origin.y;
                         CGFloat width = SearchTextFieldWidthOnSearchingStatus;
                         CGFloat height = _searchTextField.frame.size.height;

                         [_searchTextField
                             setFrame:CGRectMake(x, y, width, height)];
                     }];
}

- (void)restoreSearchTextFieldWidthAndCoordinate {

    [UIView animateWithDuration:SearchBarFadeInAnimationDuration
                     animations:^{

                         CGFloat x = SearchTextFieldOriginXOnStandbyStatus;
                         CGFloat y = _searchTextField.frame.origin.y;
                         CGFloat width = SearchTextFieldWidthOnStandbyStatus;
                         CGFloat height = _searchTextField.frame.size.height;

                         [_searchTextField
                             setFrame:CGRectMake(x, y, width, height)];
                     }];
}

- (void)revealRecordButton {

    [UIView
        animateWithDuration:SearchBarFadeInAnimationDuration
                 animations:^{

                     CGFloat x = 0;
                     CGFloat y = RecordButtonOriginY;
                     CGFloat width = _recordButton.frame.size.width;
                     CGFloat height = _recordButton.frame.size.height;

                     [_recordButton setFrame:CGRectMake(x, y, width, height)];
                 }];
}

- (void)revealCancelButton {

    [UIView
        animateWithDuration:SearchBarFadeInAnimationDuration
                 animations:^{

                     CGFloat x = G_SCREEN_WIDTH - CancelButtonWidth;
                     CGFloat y = CancelButtonOriginY;
                     CGFloat width = _cancelButton.frame.size.width;
                     CGFloat height = _cancelButton.frame.size.height;

                     [_cancelButton setFrame:CGRectMake(x, y, width, height)];
                 }];
}

- (void)dismissRecordButton {

    [UIView
        animateWithDuration:SearchBarFadeInAnimationDuration
                 animations:^{

                     CGFloat x = -RecordButtonWidth;
                     CGFloat y = RecordButtonOriginY;
                     CGFloat width = _recordButton.frame.size.width;
                     CGFloat height = _recordButton.frame.size.height;

                     [_recordButton setFrame:CGRectMake(x, y, width, height)];
                 }];
}

- (void)dismissCancelButton {

    [UIView
        animateWithDuration:SearchBarFadeInAnimationDuration
                 animations:^{

                     CGFloat x = G_SCREEN_WIDTH;
                     CGFloat y = CancelButtonOriginY;
                     CGFloat width = _cancelButton.frame.size.width;
                     CGFloat height = _cancelButton.frame.size.height;

                     [_cancelButton setFrame:CGRectMake(x, y, width, height)];
                 }];
}

- (void)dismissKeyboard {
    [_searchTextField resignFirstResponder];
}

- (void)modifySearchBarTextAlignment {
    [_searchTextField setTextAlignment:NSTextAlignmentCenter];
}

- (void)addMarginForSearchBarTextField {

    UIImageView *spaceView =
        [[UIImageView alloc] initWithFrame:CGRectMake(0, 4, 24, 24)];
    [spaceView
        setImage:[UIImage imageNamed:@"kkb_iphone_find_courses_search_white"]];
    [_searchTextField setLeftView:spaceView];
    [_searchTextField setLeftViewMode:UITextFieldViewModeAlways];
}

- (void)searchBarTextFieldAddSelector {
    [_searchTextField addTarget:self
                         action:@selector(textFieldValueDidChange:)
               forControlEvents:UIControlEventEditingChanged];
}

- (CGRect)tableViewFrame {
    CGRect frame =
        CGRectMake(0, TableViewOriginY, G_SCREEN_WIDTH,
                   G_SCREEN_HEIGHT - gStatusBarHeight - TableViewOriginY);
    return frame;
}

- (void)initTextFieldClearButton {
    UIButton *clearButton = [_searchTextField valueForKey:@"_clearButton"];
    [clearButton
        setImage:[UIImage imageNamed:@"kkb_iphone_find_courses_search_close"]
        forState:UIControlStateNormal];
}

- (void)initOperationQueue {

    searchOperationQueue = [[NSOperationQueue alloc] init];
    searchOperationQueue.maxConcurrentOperationCount = 1;
}

- (void)observerOpertionQueueCountValueChange {

    [searchOperationQueue addObserver:self
                           forKeyPath:@"operationCount"
                              options:NSKeyValueObservingOptionNew
                              context:nil];
}

- (void)observeValueForKeyPath:(NSString *)keyPath
                      ofObject:(id)object
                        change:(NSDictionary *)change
                       context:(void *)context {

    if (object == searchOperationQueue) {
        NSLog(@"operationCount %d", searchOperationQueue.operationCount);
        if (searchOperationQueue.operationCount == 0 &&
            keyboardSearchButtonDidPress) {
            dispatch_async(dispatch_get_main_queue(), ^{
                [self keyboardSearchButtonDidPress];
                keyboardSearchButtonDidPress = NO;
            });
        }
    }
}
- (void)setSearchTextFieldCursorColor {
    [self.searchTextField setTintColor:[UIColor whiteColor]];
}

- (void)addSearchFailedView {

    searchFailedView = [[KKBSearchFailedView alloc] init];

    CGRect originFrame = searchFailedView.frame;
    originFrame.origin.y = SearchFailedViewOriginY;

    [searchFailedView setFrame:originFrame];
    [searchFailedView setHidden:YES];

    [searchFailedView addTapAction:@selector(keyboardSearchButtonDidPress)
                            target:self];

    [self addSubview:searchFailedView];
}

- (void)addSearchingView {
    searchingView = [[KKBSearchingView alloc] init];

    CGRect originFrame = searchingView.frame;
    originFrame.origin.y = SearchingViewOriginY;
    [searchingView setFrame:originFrame];
    [searchingView setHidden:YES];
    [self addSubview:searchingView];
}

- (id)initWithSearchList:(NSArray *)list andDelegate:(id)aDelegate {

    CGRect frame = CGRectMake(0, 0, G_SCREEN_WIDTH, SearchBarViewHeight);

    self = [[[NSBundle mainBundle] loadNibNamed:@"KKBSearchView"
                                          owner:self
                                        options:nil] lastObject];
    [self setFrame:frame];
    if (self) {
        // Initialization code
        _delegate = aDelegate;
        searchList = list;

        loadDataSuccessOnce = NO;
        keyboardSearchButtonDidPress = NO;

        coursesRecommendedArray = [[NSMutableArray alloc] init];
        searchResultsArray = [[NSMutableArray alloc] init];

        [self initTextFieldClearButton];

        [self initOperationQueue];
        [self observerOpertionQueueCountValueChange];

        [self setSearchTextFieldCursorColor];

        [self addMarginForSearchBarTextField];
        [self modifySearchTextFieldCorner];

        [self searchBarTextFieldAddSelector];

        [self initFooterView];
        [self loadAllCourses];

        [self initSearchHistoryTableView];
        [self initCoursesRecommendedTableView];
        [self initSearchResultTableView];

        [self addSearchFailedView];
        [self addSearchingView];
        [self addEmptyContentView];
    }
    return self;
}

- (void)initSearchHistoryTableView {
    [self.searchHistoryTableView setFrame:[self tableViewFrame]];
    self.searchHistoryTableView.showsVerticalScrollIndicator = NO;
}

- (void)initCoursesRecommendedTableView {

    _coursesRecommendedTableView =
        [[UITableView alloc] initWithFrame:[self tableViewFrame]
                                     style:UITableViewStyleGrouped];

    _coursesRecommendedTableView.delegate = self;
    _coursesRecommendedTableView.dataSource = self;

    [_coursesRecommendedTableView setBackgroundColor:[UIColor whiteColor]];

    [_coursesRecommendedTableView setHidden:YES];
    _coursesRecommendedTableView.showsVerticalScrollIndicator = NO;

    [self addSubview:_coursesRecommendedTableView];
}

- (void)initSearchResultTableView {

    _searchResultTableView =
        [[UITableView alloc] initWithFrame:[self tableViewFrame]
                                     style:UITableViewStyleGrouped];

    [_searchResultTableView registerNib:[CourseItemCell cellNib]
                 forCellReuseIdentifier:COURSEITEMCELL_RESUEDID];

    _searchResultTableView.delegate = self;
    _searchResultTableView.dataSource = self;

    [_searchResultTableView setBackgroundColor:UIColorFromRGB(0xf0f0f0)];
    [_searchResultTableView
        setSeparatorStyle:UITableViewCellSeparatorStyleNone];

    [_searchResultTableView setHidden:YES];
    _searchResultTableView.showsVerticalScrollIndicator = NO;

    [self addSubview:_searchResultTableView];
}

- (void)addEmptyContentView {
    emptyContentView = [[KKBEmptyContentView alloc]
        initWithFrame:CGRectMake(0, TableViewOriginY, G_SCREEN_WIDTH,
                                 _searchResultTableView.frame.size.height +
                                     gStatusBarHeight)
            imagePath:@"icon_box"
                 text:@"未搜索到相关课程"];

    [self addSubview:emptyContentView];
}

- (void)modifySearchTextFieldCorner {
    [_searchTextField.layer setCornerRadius:3.0f];
    [_searchTextField.layer setMasksToBounds:YES];
}

- (void)revealSearchHistoryTableView {

    BOOL isSearchHistoryEmpty = (searchList.count == 0);

    [self.searchHistoryTableView setHidden:isSearchHistoryEmpty];
    if (!isSearchHistoryEmpty) {
        [self showView:self.searchHistoryTableView];
    } else {
        [self showNothing];
    }

    [footerView setHidden:NO];

    [self getSearchRecords];
    [self.searchHistoryTableView reloadData];

    [self expandTableView];
}

- (void)expandTableView {

    [UIView
        animateWithDuration:SearchBarFadeInAnimationDuration
                 animations:^{

                     CGRect frame =
                         CGRectMake(0, 0, G_SCREEN_WIDTH, G_SCREEN_HEIGHT);
                     [self setFrame:frame];

                     CGRect tableViewFrame =
                         CGRectMake(0, TableViewOriginY, G_SCREEN_WIDTH,
                                    G_SCREEN_HEIGHT - TableViewOriginY);

                     [self.searchHistoryTableView setFrame:tableViewFrame];
                     [self.coursesRecommendedTableView setFrame:tableViewFrame];
                     [self.searchResultTableView setFrame:tableViewFrame];
                 }];
}

- (void)collapeTableView {

    [self.searchTextField setText:nil];

    [self showNothing];

    CGRect frame = CGRectMake(0, 0, G_SCREEN_WIDTH, SearchBarViewHeight);
    [self setFrame:frame];
}

- (void)parseDictionary:(NSDictionary *)aCourseDict {

    NSString *name = [aCourseDict objectForKey:@"name"];
    NSString *imageUrl = [aCourseDict objectForKey:@"cover_image"];
    NSUInteger weeks = [[aCourseDict objectForKey:@"weeks"] intValue];
    NSUInteger viewCount = [[aCourseDict objectForKey:@"view_count"] intValue];
    NSString *type = [aCourseDict objectForKey:@"type"];
    NSUInteger rating = [[aCourseDict objectForKey:@"rating"] intValue];
    NSString *ratingText = [self getRatingStar:rating];
    CGFloat covertRating = rating / 2.0;
    if (covertRating > 5) {
        covertRating = 5;
    }

    NSUInteger updatedTo =
        [[aCourseDict objectForKey:@"updated_amount"] intValue];
    NSString *other =
        [NSString stringWithFormat:@"更新至第%d节视频", updatedTo];
    NSString *courseId = [aCourseDict objectForKey:@"id"];

    NSString *courseIntro = [aCourseDict objectForKey:@"intro"];
    NSString *courseLevel = [aCourseDict objectForKey:@"level"];
    NSString *keyWord = [aCourseDict objectForKey:@"slogan"];
    NSString *coverImage = [aCourseDict objectForKey:@"cover_image"];
    NSString *videoUrl = [aCourseDict objectForKey:@"promotional_video_url"];

    int courseType = ([type isEqualToString:OpenCourse] ? 0 : 1);
    KCourseItem *aCourseItem = [[KCourseItem alloc] init:imageUrl
                                                    name:name
                                                duration:weeks
                                       learnTimeEachWeek:3
                                                    vote:ratingText
                                           learnerNumber:viewCount
                                                    type:courseType
                                                courseId:courseId
                                                   other:other
                                             courseIntro:courseIntro
                                             courseLevel:courseLevel
                                                 keyWord:keyWord
                                              coverImage:coverImage
                                                videoUrl:videoUrl];
    aCourseItem.rating = covertRating;
    [searchResultsArray addObject:aCourseItem];
}

- (NSString *)getRatingStar:(int)ratingCount {
    if (ratingCount == 0) {
        return nil;
    } else {
        NSMutableString *rateString = [[NSMutableString alloc] init];

        float count = ceilf(ratingCount / 2.0f);
        for (int i = 0; i < count; i++) {
            [rateString appendString:@"★"];
        }

        return rateString;
    }
}

- (void)loadAllCourses {

    [KKBCourseManager getAllCoursesForceReload:NO
                             completionHandler:^(id model, NSError *error) {
                                 if (error == nil) {
                                     // success
                                     allCoursesDataArray =
                                         (NSDictionary *)model;
                                 } else {
                                     // failure
                                     NSLog(@"%@", error);
                                 }
                             }];
}

#pragma mark - Custom Methods 2
- (void)getSearchRecords {
    searchList = [[LocalStorage shareInstance] getSearchRecords];
}

- (void)clearSearchTableRecords {
    [[LocalStorage shareInstance] clearSearchTableRecords];
}

- (void)insertSearchRecordToDb {
    NSString *keyword = [_searchTextField.text
        stringByTrimmingCharactersInSet:
            [NSCharacterSet whitespaceAndNewlineCharacterSet]];

    if (keyword != nil && keyword.length > 0) {
        [[LocalStorage shareInstance] insertSearchRecord:keyword];
    }
}

- (void)clearHistoryButtonDidPress:(id)sender {

    searchList = nil;

    [self clearSearchTableRecords];

    [self.searchHistoryTableView reloadData];
    [self showNothing];
}

- (void)initFooterView {
    footerView = [[UIView alloc]
        initWithFrame:CGRectMake(0, 0, G_SCREEN_WIDTH,
                                 SearchHistoryTableFooterViewHeight)];

    int width = ClearAllHistoryButtonWidth;
    int height = ClearAllHistoryButtonHeight;
    int x = (G_SCREEN_WIDTH - width) / 2;
    int y = ClearAllHistoryButtonOriginY;

    UIButton *clearHistoryButton = [[UIButton alloc] init];

    [clearHistoryButton.layer setCornerRadius:2.0f];
    [clearHistoryButton.layer setMasksToBounds:YES];

    [clearHistoryButton setFrame:CGRectMake(x, y, width, height)];
    [clearHistoryButton.titleLabel setFont:[UIFont systemFontOfSize:14.0f]];
    [clearHistoryButton setTitle:@"清空搜索记录" forState:UIControlStateNormal];
    [clearHistoryButton setTitleColor:UIColorFromRGB(0x646466)
                             forState:UIControlStateNormal];
    [clearHistoryButton setBackgroundColor:UIColorFromRGB(0xf0f0f0)];
    [clearHistoryButton addTarget:self
                           action:@selector(clearHistoryButtonDidPress:)
                 forControlEvents:UIControlEventTouchUpInside];

    UITapGestureRecognizer *gesture = [[UITapGestureRecognizer alloc]
        initWithTarget:self
                action:@selector(clearHistoryButtonDidPress:)];

    [footerView addGestureRecognizer:gesture];
    [footerView addSubview:clearHistoryButton];
}

- (void)showView:(UIView *)view {

    [self showNothing];
    [view setHidden:NO];
}

- (void)showNothing {

    [self.searchHistoryTableView setHidden:YES];
    [self.coursesRecommendedTableView setHidden:YES];
    [self.searchResultTableView setHidden:YES];

    [searchFailedView setHidden:YES];
    [searchingView setHidden:YES];
    [emptyContentView setHidden:YES];
}

#pragma mark - UITextField Delegate Methods
- (void)textFieldDidBeginEditing:(UITextField *)textField {
    [textField setTextAlignment:NSTextAlignmentLeft];

    [self modifySearchTextFieldWidthAndCoordinate];
    [self revealRecordButton];
    [self revealCancelButton];
    [self revealSearchHistoryTableView];
}

- (void)textFieldValueDidChange:(UITextField *)textField {

    NSString *searchText = textField.text;

    if (searchText.length == 0) {
        [self revealSearchHistoryTableView];
        return;
    }

    BOOL connected = [AppUtilities isExistenceNetwork];
    [self showNothing];
    [footerView setHidden:YES];

    [coursesRecommendedArray removeAllObjects];
    if (connected) {
        // 远程检索
        [self.coursesRecommendedTableView setHidden:NO];
        [searchingView setHidden:loadDataSuccessOnce];

        NSString *apiPath = @"v1/courses/search";
        NSMutableDictionary *dictionary = [[NSMutableDictionary alloc] init];
        [dictionary setObject:searchText forKey:@"keyword"];

        [searchOperationQueue addOperationWithBlock:^{

            dispatch_semaphore_t sema = dispatch_semaphore_create(0);

            [[KKBHttpClient shareInstance] requestAPIUrlPath:apiPath
                method:@"POST"
                param:dictionary
                fromCache:NO
                success:^(id result, AFHTTPRequestOperation *operation) {
                    // success

                    searchOnlineMode = YES;
                    searchResultsOriginArray = (NSArray *)result;
                    NSLog(@"searchResultsOriginArray.count %d",
                          searchResultsOriginArray.count);

                    for (NSDictionary *dict in(NSArray *)result) {
                        [coursesRecommendedArray
                            addObject:[dict objectForKey:@"name"]];
                    }

                    loadDataSuccessOnce = YES;

                    [self.coursesRecommendedTableView reloadData];
                    [self showView:self.coursesRecommendedTableView];

                    dispatch_semaphore_signal(sema);
                }
                failure:^(id result, AFHTTPRequestOperation *operation) {
                    // failure

                    [self showView:searchFailedView];

                    loadDataSuccessOnce = NO;

                    dispatch_semaphore_signal(sema);
                }];

            dispatch_semaphore_wait(sema, DISPATCH_TIME_FOREVER);
        }];

    } else {
        searchOnlineMode = NO;

        // 本地检索
        [coursesRecommendedArray removeAllObjects];
        [allCoursesDataArray
            enumerateKeysAndObjectsUsingBlock:^(id key, id dictionary,
                                                BOOL *stop) {

                if ([[dictionary objectForKey:@"name"]
                        rangeOfString:searchText
                              options:NSCaseInsensitiveSearch].location !=
                    NSNotFound) {

                    NSString *name = [dictionary objectForKey:@"name"];
                    [coursesRecommendedArray addObject:name];
                }
            }];

        [self.coursesRecommendedTableView reloadData];
        [self showView:self.coursesRecommendedTableView];
    }
}

#pragma mark - UIScrollView Delegate Methods
- (void)scrollViewDidScroll:(UIScrollView *)scrollView {

    [_searchTextField resignFirstResponder];
}

//- (void)layoutSubviews {
//    self.alpha = 0.0f;
//    [UIView animateWithDuration:0.30
//        animations:^{ self.alpha = 1.0f; }
//        completion:^(BOOL finished) {}];
//    [super layoutSubviews];
//}
/*git
 // Only override drawRect: if you perform custom drawing.
 // An empty implementation adversely affects performance during animation.
 - (void)drawRect:(CGRect)rect
 {
 // Drawing code
 }
 */

#pragma mark - TableView DataSource
- (NSInteger)tableView:(UITableView *)tableView
    numberOfRowsInSection:(NSInteger)section {
    if ([tableView isEqual:self.searchHistoryTableView]) {
        return searchList.count;
    } else if ([tableView isEqual:self.coursesRecommendedTableView]) {
        return coursesRecommendedArray.count;
    } else {
        return searchResultsArray.count;
    }
}

- (NSString *)tableView:(UITableView *)tableView
    titleForHeaderInSection:(NSInteger)section {

    if ([tableView isEqual:self.searchHistoryTableView]) {

        if (searchList != nil && searchList.count > 0) {
            return @"最近搜索";
        } else {
            return nil;
        }

    } else if ([tableView isEqual:self.coursesRecommendedTableView]) {

        return nil;
    } else {

        BOOL isContentEmpty = ([searchResultsArray count] == 0);
        NSString *xCourseFoundString =
            [NSString stringWithFormat:@"找到%d门相关课程",
                                       searchResultsArray.count];

        return (isContentEmpty ? nil : xCourseFoundString);
    }
}

- (UITableViewCell *)tableView:(UITableView *)tableView
         cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    if ([tableView isEqual:self.searchHistoryTableView]) {
        static NSString *CellIdentifier = @"Cell";

        UITableViewCell *cell =
            [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
        if (cell == nil) {
            cell = [[UITableViewCell alloc]
                  initWithStyle:UITableViewCellStyleDefault
                reuseIdentifier:CellIdentifier];
        }

        // assign cell properties
        if (searchList != nil && searchList.count > 0) {
            cell.textLabel.text = [searchList objectAtIndex:indexPath.row];
        }

        return cell;

    } else if ([tableView isEqual:self.coursesRecommendedTableView]) {

        static NSString *CellIdentifier = @"Cell2";

        UITableViewCell *cell =
            [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
        if (cell == nil) {
            cell = [[UITableViewCell alloc]
                  initWithStyle:UITableViewCellStyleDefault
                reuseIdentifier:CellIdentifier];
        }

        if (coursesRecommendedArray != nil &&
            coursesRecommendedArray.count > 0) {
            cell.textLabel.text =
                [coursesRecommendedArray objectAtIndex:indexPath.row];
        }

        return cell;

    } else {

        CourseItemCell *cell =
            [tableView dequeueReusableCellWithIdentifier:COURSEITEMCELL_RESUEDID
                                            forIndexPath:indexPath];
        cell.selectionStyle = UITableViewCellSelectionStyleDefault;
        cell.selectedBackgroundView =
            [[UIView alloc] initWithFrame:cell.bounds];

        KCourseItem *aCourseItem = searchResultsArray[indexPath.row];

        KKBCourseItemCellModel *model = [[KKBCourseItemCellModel alloc] init];
        model.headImageURL = aCourseItem.imageUrl;
        model.cellTitle = aCourseItem.name;
        model.rating = aCourseItem.rating;
        model.itemType =
            !aCourseItem.type ? CourseItemOpenType : CourseItemGuideType;
        model.isOnLine = YES;
        model.enrollments = @(aCourseItem.learnerNumber);

        cell.model = model;

        return cell;
    }
}

- (CGFloat)tableView:(UITableView *)tableView
    heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    if ([tableView isEqual:self.searchResultTableView]) {
        return COURSEITEMCELL_HEIGHT;
    } else {
        return TableViewDefaultHeight;
    }
}

- (CGFloat)tableView:(UITableView *)tableView
    heightForFooterInSection:(NSInteger)section {
    if ([tableView isEqual:self.searchHistoryTableView]) {
        return SearchHistoryTableFooterViewHeight;
    } else {
        return 0.0f;
    }
}

- (CGFloat)tableView:(UITableView *)tableView
    heightForHeaderInSection:(NSInteger)section {
    if ([tableView isEqual:self.searchResultTableView]) {
        return SearchResultTableHeaderViewHeight;
    } else if ([tableView isEqual:self.searchHistoryTableView]) {
        return SearchResultTableHeaderViewHeight2;
    }

    return 0.0f;
}

- (void)tableView:(UITableView *)tableView
    didSelectRowAtIndexPath:(NSIndexPath *)indexPath {

    if ([AppUtilities isExistenceNetwork]) {
        // 在线搜索
        if ([tableView isEqual:self.searchHistoryTableView]) {

            NSString *selectedItem = [searchList objectAtIndex:indexPath.row];
            _searchTextField.text = selectedItem;
            [self searchHistoryTableViewCellDidSelectWhenOnlineMode];

        } else if ([tableView isEqual:_coursesRecommendedTableView]) {

            NSDictionary *oneDict = (NSDictionary *)
                [searchResultsOriginArray objectAtIndex:indexPath.row];

            NSString *courseName = [oneDict objectForKey:@"name"];
            _searchTextField.text = courseName;

            courseIdSelected = [oneDict objectForKey:@"id"];
            [self oneCourseItemFromRemoteServerDidSelect];
        } else {

            BOOL hasContent =
                (searchResultsArray != nil && searchResultsArray.count > 0);
            if (hasContent) {
                KCourseItem *aCourseItem =
                    [searchResultsArray objectAtIndex:indexPath.row];
                [self.delegate searchResultTableViewCellDidSelect:aCourseItem];
            }
        }

    } else {
        // 本地搜索

        if ([tableView isEqual:self.searchHistoryTableView]) {
            NSString *selectedItem = [searchList objectAtIndex:indexPath.row];

            _searchTextField.text = selectedItem;
            [self keyboardSearchButtonDidPress];

        } else if ([tableView isEqual:_coursesRecommendedTableView]) {

            NSString *selectedItem =
                [coursesRecommendedArray objectAtIndex:indexPath.row];
            _searchTextField.text = selectedItem;

            [self keyboardSearchButtonDidPress];
        } else {

            KCourseItem *aCourseItem =
                [searchResultsArray objectAtIndex:indexPath.row];
            [self.delegate searchResultTableViewCellDidSelect:aCourseItem];
        }
    }
}

- (UIView *)tableView:(UITableView *)tableView
    viewForFooterInSection:(NSInteger)section {
    if ([tableView isEqual:self.searchHistoryTableView]) {
        if (searchList != nil && searchList.count > 0) {
            return footerView;
        } else {
            return nil;
        }
    } else {
        return nil;
    }
}

@end
