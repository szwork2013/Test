//
//  collectionItemView.m
//  learn
//
//  Created by zxj on 7/2/14.
//  Copyright (c) 2014 kaikeba. All rights reserved.
//

#import "CollectionItemView.h"
#import "UIView+ViewFrameGeometry.h"

@implementation CollectionItemView

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
        self.labelButton = [UIButton buttonWithType:UIButtonTypeCustom];
        self.labelButton.frame = CGRectMake(16, 8, 0, 0);
        
        self.label.opaque = NO;
        self.label.backgroundColor = [UIColor clearColor];
        self.label.textAlignment = NSTextAlignmentCenter;
        //self.label.backgroundColor = [UIColor redColor];
        
        
        self.label.font = [[self class]defaultFont];
        self.label.textColor = [UIColor colorWithRed:0.6 green:0.6 blue:0.6 alpha:1.0];
        [self addSubview:self.labelButton];
        self.lineImageView = [[UIImageView alloc]initWithImage:[UIImage imageNamed:@"category-filter_line.png"]];
        [self.lineImageView setFrame:CGRectMake(self.right-1, 5, 1, 22)];
        [self addSubview:self.lineImageView];
        self.labelButton.backgroundColor = [UIColor clearColor];
        [self.labelButton setTitleColor:[UIColor grayColor] forState:UIControlStateNormal];
        self.labelButton.titleLabel.textColor = [UIColor grayColor];
        [self.labelButton setTitleColor:[UIColor whiteColor] forState:UIControlStateSelected];
        //self.labelButton.titleLabel.tintColor = [UIColor whiteColor];
        //[self.labelButton setBackgroundImage:[UIImage imageNamed:@"category_pressed.png"] forState:UIControlStateSelected];
        //[self.labelButton setImageEdgeInsets:UIEdgeInsetsMake(-5, -5, -5,-5)];
        //[self.labelButton setImage:[UIImage imageNamed:@"category_pressed.png"] forState:UIControlStateSelected];
//        self.labelButton.backgroundColor = [UIColor yellowColor];
//        self.backgroundColor = [UIColor greenColor];
        self.pressImageView = [[UIImageView alloc]initWithImage:[UIImage imageNamed:@"category_pressed.png"]];
        self.pressImageView.center = self.center;
        self.pressImageView.hidden = YES;
        [self insertSubview:self.pressImageView atIndex:0];
        
        self.hidden = YES;
    }
    return self;
}

+(UIFont *)defaultFont{
    
    return [UIFont boldSystemFontOfSize:13];
}

+(CGSize)sizeForContentString:(NSString *)s{
    //CGSize textSize = [s sizeWithFont:[self defaultFont] constrainedToSize:CGSizeMake(300, 1000) lineBreakMode:NSLineBreakByCharWrapping];
    
    
    NSDictionary* dic = @{NSFontAttributeName:[[self class]defaultFont]};
    
    
    
    CGSize textSize = [s sizeWithAttributes:dic];
    
    return textSize;
}

-(NSString *)text{
    return self.label.text;
}

-(void)setText:(NSString *)text{
    //self.labelButton.titleLabel.text = text;
    self.labelButton.titleLabel.font = [[self class]defaultFont];
    [self.labelButton setTitle:text forState:UIControlStateNormal];
    self.labelButton.titleLabel.textColor = [UIColor grayColor];
    //[self.labelButton.titleLabel setTextColor:[UIColor grayColor]];
    CGRect newLabelFrame = self.labelButton.frame;
    
    CGSize textSize = [[self class]sizeForContentString:text];
    self.size = CGSizeMake((textSize.width+32), (textSize.height+16));
    newLabelFrame.size = textSize;
   
    self.labelButton.frame = newLabelFrame;
    self.pressImageView.width = textSize.width +12;
    self.pressImageView.height = textSize.height +16;
    self.pressImageView.center = self.center;
    
    //    CGAffineTransform transform = CGAffineTransformMakeTranslation(0, 0);
    //
    //    transform = CGAffineTransformScale(transform, 0.8, 0.8);
    //
    //    [self.contentView setTransform:transform];
    //    self.label.top = (self.height-self.label.height)/2;
    //    self.label.left = (self.width-self.label.width)/2;
    //self.labelButton.top = (self.height-self.label.height)/2;
    //self.labelButton.left = (self.width-self.label.width)/2;
    [self.lineImageView setFrame:CGRectMake(self.right-1, 5, 1, 22)];
    [self.labelButton setImageEdgeInsets:UIEdgeInsetsMake(-5, -5, -5,-5)];
    
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
