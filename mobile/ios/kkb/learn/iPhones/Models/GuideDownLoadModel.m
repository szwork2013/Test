//
//  GuideDownLoadModel.m
//  learn
//
//  Created by zxj on 14-8-9.
//  Copyright (c) 2014年 kaikeba. All rights reserved.
//

#import "GuideDownLoadModel.h"
#import "GuideDownLoadSubModel.h"
@implementation GuideDownLoadModel

- (void)initWithDictionary:(NSDictionary *)dictionary {
    self.name = [dictionary objectForKey:@"name"];
    NSArray *subArray = [dictionary objectForKey:@"items"];
    for (NSDictionary *dic in subArray) {
        GuideDownLoadSubModel *model = [[GuideDownLoadSubModel alloc] init];
        model.title = [dic objectForKey:@"title"];
        model.type = [dic objectForKey:@"type"];
        model.html_url = [dic objectForKey:@"html_url"];
        model.url = [dic objectForKey:@"url"];
        model.itemImage = @"download_default";

        model.isSelected = NO;
        [self.itemArray addObject:model];
    }
}

@end
