//
//  RatingView.m
//  StarRatingView
//
//  Created by
//  Copyright (c) 2014年 zengmiao. All rights reserved.
//

#import "KKBStarRatingView.h"

@interface KKBStarRatingView ()

@property (nonatomic, strong) NSMutableArray *starButtons;

@end


@implementation KKBStarRatingView

- (id)initWithOrigin:(CGPoint)origin
           starCount:(int)count
           starWidth:(CGFloat)starWidth
          starHeight:(CGFloat)starHeight
             spacing:(CGFloat)spacing
         rateEnabled:(BOOL)rateEnabled {
    
    CGRect rect = (CGRect){
        .origin.x = origin.x,
        .origin.y = origin.y,
        .size.width =  starWidth * count + spacing * (count - 1),
        .size.height = starHeight
    };
    
    self = [super initWithFrame:rect];
    if (self) {
        _starButtons = [[NSMutableArray alloc] initWithCapacity:count];
        for (int i = 0; i < count; i++) {
            UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
            
            CGRect btnframe = (CGRect){
                .origin.x = i * (starWidth + spacing),
                .origin.y = 0,
                .size.width =  starWidth,
                .size.height = starHeight
            };
            
            [button setFrame:btnframe];
            [button setTitleColor:[UIColor redColor] forState:UIControlStateNormal];
            button.tag = i;
            [self addSubview:button];
            [_starButtons addObject:button];
        }
        
        self.rateEnabled = rateEnabled;
    }
    return self;
}


- (void)setRateEnabled:(BOOL)rateEnabled
{
  _rateEnabled = rateEnabled;
  for (int i = 0; i < _starButtons.count; i++) {
    UIButton *button = [_starButtons objectAtIndex:i];
    [button setUserInteractionEnabled:_rateEnabled];
    if (_rateEnabled) {
      [button  addTarget:self
                  action:@selector(rate:)
        forControlEvents:UIControlEventTouchUpInside];
    }
  }
}

- (void)rate:(id)sender
{
  UIButton *button = (UIButton *)sender;
  [self setRating:button.tag + 1];
}

- (void)setRating:(CGFloat)rating
{
  _rating = rating;

  UIImage *starFull, *starHalf, *starEmpty;

  if (self.fullImage) {
    starFull = [UIImage imageNamed:self.fullImage];
  } else {
    starFull = [UIImage imageNamed:@"star_blue_full"];
  }

  if (self.halfImage) {
    starHalf = [UIImage imageNamed:self.halfImage];
  } else {
    starHalf = [UIImage imageNamed:@"star_blue_half"];
  }

  if (self.emptyImage) {
    starEmpty = [UIImage imageNamed:self.emptyImage];
  } else {
    starEmpty = [UIImage imageNamed:@"star_gray_bg"];
  }

  int fullStars = floor(rating);
  int i;
  for (i = 0; i < fullStars; i++) {
    UIButton *button = [_starButtons objectAtIndex:i];
    [button setImage:starFull forState:UIControlStateNormal];
  }

  if (rating - fullStars >= 0.5) {
    UIButton *button = [_starButtons objectAtIndex:fullStars];
    [button setImage:starHalf forState:UIControlStateNormal];
    i++;
  }

  for (; i < [self.starButtons count]; i++) {
    UIButton *button = [_starButtons objectAtIndex:i];
    [button setImage:starEmpty forState:UIControlStateNormal];
  }
}

@end
