//
//  KKBDownloadDeleteBtn.m
//  VideoDownload
//
//  Created by zengmiao on 9/9/14.
//  Copyright (c) 2014 zengmiao. All rights reserved.
//

#import "KKBDownloadDeleteBtn.h"

@implementation KKBDownloadDeleteBtn

- (id)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
    }
    return self;
}

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect
{
    // Drawing code
}
*/

- (void)awakeFromNib {
    [super awakeFromNib];
}

- (void)setSelectedDeleteCount:(NSUInteger)selectedCount {
    _selectedDeleteCount = selectedCount;

    UIColor *color = [UIColor kkb_colorwithHexString:@"646466" alpha:1];
    if (_selectedDeleteCount) {
        color = [UIColor kkb_colorwithHexString:@"008eec" alpha:1];
        NSString *countStr = [NSString
            stringWithFormat:@"删除(已选%d个)", _selectedDeleteCount];
        [self setTitle:countStr forState:UIControlStateNormal];
        [self setTitle:countStr forState:UIControlStateHighlighted];

    } else {
        [self setTitle:@"删除" forState:UIControlStateNormal];
        [self setTitle:@"删除" forState:UIControlStateHighlighted];
    }
    
    [self setTitleColor:color forState:UIControlStateNormal];
    [self setTitleColor:color forState:UIControlStateHighlighted];
}

- (void)setSelectedDownloadCount:(NSUInteger)selectedDownloadCount {
    _selectedDownloadCount = selectedDownloadCount;

    UIColor *color = [UIColor kkb_colorwithHexString:@"646466" alpha:1];
    if (_selectedDownloadCount) {
        color = [UIColor kkb_colorwithHexString:@"008eec" alpha:1];
        NSString *countStr = [NSString
            stringWithFormat:@"下载(已选%d个)", _selectedDownloadCount];
        [self setTitle:countStr forState:UIControlStateNormal];
        [self setTitle:countStr forState:UIControlStateHighlighted];

    } else {
        [self setTitle:@"下载" forState:UIControlStateNormal];
        [self setTitle:@"下载" forState:UIControlStateHighlighted];
    }

    [self setTitleColor:color forState:UIControlStateNormal];
    [self setTitleColor:color forState:UIControlStateHighlighted];
}

- (void)setCounter:(NSUInteger)counter {
    _counter = counter;
    if ((_counter == _maxCount) && (counter != 0)) {
        [self setTitle:@"取消全选" forState:UIControlStateNormal];
        [self setTitle:@"取消全选" forState:UIControlStateHighlighted];
    } else {
        [self setTitle:@"全选" forState:UIControlStateNormal];
        [self setTitle:@"全选" forState:UIControlStateHighlighted];
    }
}

- (BOOL)allowSelected {
    return _counter != _maxCount;
}

@end
