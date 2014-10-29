
#import "Cell1.h"

@implementation Cell1
@synthesize titleLabel, arrowImageView;

- (id)initWithStyle:(UITableViewCellStyle)style
    reuseIdentifier:(NSString *)reuseIdentifier {
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        // Initialization code
    }
    return self;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

- (void)changeArrowWithUp:(BOOL)up {
    if (up) {
        self.arrowImageView.image = [UIImage imageNamed:@"arrow_01"];
    } else {
        self.arrowImageView.image = [UIImage imageNamed:@"arrow_02"];
    }
}

@end
