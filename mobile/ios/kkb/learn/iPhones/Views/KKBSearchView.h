
#import <UIKit/UIKit.h>
#import "LocalStorage.h"
#import "KCourseItem.h"

@protocol KKBSearchDelegate <NSObject>

- (void)recordAudioButtonDidPress;
- (void)cancelButtonDidPress;

@required
- (void)searchResultTableViewCellDidSelect:(KCourseItem *)aCourseItem;

@end

@interface KKBSearchView : UIView <UITableViewDataSource, UITableViewDelegate,
                                   UITextFieldDelegate, UIScrollViewDelegate>

@property(nonatomic, strong) IBOutlet UITableView *searchHistoryTableView;
@property(nonatomic, strong) IBOutlet UITableView *coursesRecommendedTableView;
@property(nonatomic, strong) IBOutlet UITableView *searchResultTableView;

@property(nonatomic, strong) IBOutlet UITextField *searchTextField;
@property(nonatomic, strong) IBOutlet UIButton *recordButton;
@property(nonatomic, strong) IBOutlet UIButton *cancelButton;

@property(nonatomic, assign) __unsafe_unretained id<KKBSearchDelegate> delegate;

- (id)initWithSearchList:(NSArray *)list andDelegate:(id)aDelegate;

- (IBAction)recordButtonDidPress:(id)sender;
- (IBAction)cancelButtonDidPress:(id)sender;
- (IBAction)keyboardSearchButtonDidPress;

@end
