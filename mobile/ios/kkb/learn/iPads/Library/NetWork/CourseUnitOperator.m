//
//  CourseUnitOperator.m
//  learn
//
//  Created by User on 13-5-22.
//  Copyright (c) 2013年 kaikeba. All rights reserved.
//

#import "CourseUnitOperator.h"
#import "JSONKit.h"


@implementation CourseUnitOperator

@synthesize courseBriefIntroduction;
@synthesize introductionOfLecturer;
@synthesize courseUnit;
@synthesize page;



- (id)init
{
    if (self = [super init])
    {
        self.moduleType = KAIKEBA_MODULE_COURSEUNIT;
        self.courseUnit = [[CourseUnitStructs alloc] init];
    }
    
    return self;
}


//网络Url--------------------------------


//网络请求 -------------------------------

//获取指定的Page，用在课程框架、课程单元点击某些页面时Modules
- (void)requestPage:(id)delegate token:(NSString *)token courseId:(NSString *)courseId pageURL:(NSString *)pageURL
{
    NSString *jsonUrl = [NSString stringWithFormat:@"%@courses/%@/pages/%@", API_HOST, courseId, pageURL];
    
    [self getJSONFromUrl:delegate command:HTTP_CMD_COURSEUNIT_PAGE jsonUrl:jsonUrl token:token];
}
//获取课程视频信息
- (void)requestCourseVideo:(id)delegate token:(NSString *)token courseId:(NSString *)courseId
{
    
//    http://superclass.kaikeba.com/ocw/srv/api.php?num=999&courseid=34&moduleid=71&itemid=10333&token=
//     NSString *jsonUrl = [NSString stringWithFormat:@"%@course/%@/video", @"http://api.kaikeba.com/api/v2/", courseId];
    
     NSString *jsonUrl = [NSString stringWithFormat:@"http://superclass.kaikeba.com/ocw/srv/api.php?num=666&courseid=%@",courseId];
    
     [self getJSONFromUrl:delegate command:HTTP_CMD_COURSEUNIT_VIDEO jsonUrl:jsonUrl token:token];
}
//网络解析 -------------------------------
//课程简介Page
- (void)parseCourseBriefIntroduction:(NSString *)jsonDatas
{
    NSDictionary *dic = [jsonDatas objectFromJSONString];
    self.courseBriefIntroduction = [dic objectForKey:@"body"];
}

//讲师简介Page
- (void)parseIntroductionOfLecturer:(NSString *)jsonDatas
{
    NSDictionary *dic = [jsonDatas objectFromJSONString];
    self.introductionOfLecturer = [dic objectForKey:@"body"];
}

//指定课程的单元Modules
- (void)parseModules:(NSString *)jsonDatas
{
    NSArray *array = [jsonDatas objectFromJSONString];
    [self.courseUnit.modulesArray removeAllObjects];
    for(NSDictionary *dic in array)
    {
        UnitItem *item = [[UnitItem alloc] init];
        
        item.item_id = [[dic objectForKey:@"id"] stringValue];
        item.name = [dic objectForKey:@"name"];
        item.position = [dic objectForKey:@"position"];
        item.prerequisite_module_ids = [dic objectForKey:@"prerequisite_module_ids"];
        item.require_sequential_progress = [dic objectForKey:@"require_sequential_progress"];
        item.unlock_at = [dic objectForKey:@"unlock_at"];
        item.workflow_state = [dic objectForKey:@"workflow_state"];
        item.ableDownload = @"0";
        
        [self.courseUnit.modulesArray addObject:item];
    }
}

- (void)parsePage:(NSString *)jsonDatas
{
    NSDictionary *dic = [jsonDatas objectFromJSONString];
    
    self.page = [dic objectForKey:@"body"];
}
//解析视频
- (void)parseCourseVideo:(NSString *)jsonDatas
{
    NSRange range = [jsonDatas rangeOfString:@"["];//匹配得到的下标
    //    NSLog(@"rang:%@",NSStringFromRange(range));
    NSString* string = [jsonDatas substringFromIndex:range.location];//截取范围类的字符串
    //    NSLog(@"截取的值为：%@",string);
    
    
    NSArray *array = [string objectFromJSONString];
    [self.courseUnit.modulesItemDic removeAllObjects];
    if(array.count > 0){
        //    NSLog(@"video == %@",[array objectAtIndex:0]);
        for(NSDictionary *dic in array)
        {
            //        NSLog(@"moduleID== %@",[dic objectForKey:@"moduleID"]);
            for(int i = 0; i < self.courseUnit.modulesArray.count; i++){
                
                UnitItem *item = [self.courseUnit.modulesArray objectAtIndex:i];
                //            NSLog(@"item._id----%@",item._id);
                if([[dic objectForKey:@"moduleID"] intValue] == [item.item_id intValue]){
                    //                NSLog(@"item.able ----%@",item.ableDownload);
                    item.ableDownload = @"1";//可下载
                    
                }
            }
            NSArray *videoListArr = [dic objectForKey:@"videoList"];
            NSMutableArray *arr = [[NSMutableArray alloc]init];
            for(NSDictionary *dicList in videoListArr)
            {
                UnitDownladItem *item = [[UnitDownladItem alloc] init];
                item.itemID = [dicList objectForKey:@"itemID"];
                item.videoTitle = [dicList objectForKey:@"itemTitle"];
                item.videoUrl = [dicList objectForKey:@"videoURL"];
                item.hasDownloaded = @"nodownload";
                [arr addObject:item];
            }
            NSString *key = [dic objectForKey:@"moduleID"];
            [self.courseUnit.modulesItemDic setObject:arr forKey:key];
        }
    }
}


//网络代理回调 -------------------------------
- (void)requestFinished:(id)subDelegate cmd:(NSString *)cmd jsonDatas:(NSString *)jsonDatas url:(NSString *)url
{
    if ([cmd compare:HTTP_CMD_COURSE_MODULES] == NSOrderedSame)
    {
        [self parseModules:jsonDatas];
    }
    else if ([cmd compare:HTTP_CMD_COURSEUNIT_PAGE] == NSOrderedSame)
    {
        [self parsePage:jsonDatas];
    }
    else if ([cmd compare:HTTP_CMD_HOMEPAGE_COURSEBRIEFINTRODUCTION] == NSOrderedSame)
    {
        [self parseCourseBriefIntroduction:jsonDatas];
    }
    else if ([cmd compare:HTTP_CMD_HOMEPAGE_INTRODUCTIONOFLECTURER] == NSOrderedSame)
    {
        [self parseIntroductionOfLecturer:jsonDatas];
    } else if ([cmd compare:HTTP_CMD_COURSEUNIT_VIDEO] == NSOrderedSame)
    {
        [self parseCourseVideo:jsonDatas];
    }
    
    [super requestFinished:subDelegate cmd:cmd jsonDatas:jsonDatas url:url];
}
@end
