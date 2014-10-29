//
//  DownloadManagerViewController.m
//  learn
//
//  Created by xgj on 14-6-21.
//  Copyright (c) 2014年 kaikeba. All rights reserved.
//

#import "DownloadManagerViewController.h"
#import "MobClick.h"
#import "RATreeView.h"
#import "RADataObject.h"
#import "FilesDownManage.h"
#import "KKBHttpClient.h"
#import "KKBUserInfo.h"
#import "KKBDownloadRecord.h"
#import "KKBDownloadCourse.h"
#import "CommonHelper.h"
//#import "SidebarViewController.h"
#import "FileUtil.h"
#import "GlobalOperator.h"
#import "PlayerFrameView.h"
#import "KKBMoviePlayerController.h"
#import "KKBNoDownloadTaskView.h"
#import "AppUtilities.h"
#import "AFNetworkReachabilityManager.h"
#import "LocalStorage.h"

#define NAVIGATION_BAR_HEIGHT 44
#define STATUS_BAR_HEIGHT 20
#define BOTTOM_BUTTON_HEIGHT 48

#define UITableViewCellIndent 36

#define UITableViewSectionTitleLabelMargin 14

#define UITableViewCellTitleLabelMargin 20
#define UITableViewCellProgressViewMargin 132
#define UITableViewCellProgressLabelMargin 216
#define UITableViewCellIndicatorMargin 276
@interface DownloadManagerViewController ()

@end

@implementation DownloadManagerViewController

- (id)initWithNibName:(NSString *)nibNameOrNil
               bundle:(NSBundle *)nibBundleOrNil {
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        [FilesDownManage sharedInstance].downloadDelegate = self;
        loadTime = 0;
    }
    return self;
}

#pragma mark - Action

- (IBAction)showRightSideBar:(id)sender {
    /*
    if ([[SidebarViewController share]
    respondsToSelector:@selector(showSideBarControllerWithDirection:)]) {
        if([[SidebarViewController share] getSideBarShowing] == YES){
            [[SidebarViewController share]
    showSideBarControllerWithDirection:SideBarShowDirectionNone];
        } else {
            [[SidebarViewController share]
    showSideBarControllerWithDirection:SideBarShowDirectionRight];
        }
    }
     */
}

- (IBAction)editOrDone:(id)sender {
    UIButton *button = (UIButton *)sender;

    if (isEditActivated) {
        [button setBackgroundImage:[UIImage imageNamed:@"download_edit"]
                          forState:UIControlStateNormal];

        isAllItemsSelected = true;
        [self selectAllItems];
    } else {
        [button setBackgroundImage:[UIImage imageNamed:@"download_done"]
                          forState:UIControlStateNormal];
    }

    [selectAllItemsButton setHidden:isEditActivated];
    [removeItemsButton setHidden:isEditActivated];

    [resumeAllButton setHidden:!isEditActivated];
    [pauseAllButton setHidden:!isEditActivated];
    [line setHidden:!isEditActivated];

    [self showSelectButton:!isEditActivated];

    isEditActivated = !isEditActivated;
}

- (void)showSelectButton:(BOOL)hidden {

    for (KKBDownloadCourse *aCourse in self.downloadCourses) {
        UITableViewCell *section = [self.tableView cellForItem:aCourse];

        UIView *title = [section viewWithTag:1004];

        [self indent:hidden view:title];
        [[section viewWithTag:1006] setHidden:!hidden];

        for (KKBDownloadRecord *aRecord in aCourse.downloadRecords) {
            UITableViewCell *cell = [self.tableView cellForItem:aRecord];

            UIView *title = [cell viewWithTag:1000];
            UIView *progressLabel = [cell viewWithTag:1001];
            UIView *progressView = [cell viewWithTag:1002];
            UIView *status = [cell viewWithTag:1003];

            [self indent:hidden view:title];
            [self indent:hidden view:progressLabel];
            [self indent:hidden view:progressView];
            [self indent:hidden view:status];

            [[cell viewWithTag:1004] setHidden:!hidden];
        }
    }
}

- (void)selectAllItems {
    selectedItemsCount = 0;
    for (KKBDownloadCourse *aCourse in self.downloadCourses) {
        UITableViewCell *section = [self.tableView cellForItem:aCourse];

        UIButton *sectionButton = (UIButton *)[section viewWithTag:1006];

        if (isAllItemsSelected) {
            [sectionButton
                setBackgroundImage:[UIImage imageNamed:@"download_default"]
                          forState:UIControlStateNormal];
        } else {
            [sectionButton
                setBackgroundImage:[UIImage imageNamed:@"download_selected"]
                          forState:UIControlStateNormal];
        }

        aCourse.isSelected = !isAllItemsSelected;

        for (KKBDownloadRecord *aRecord in aCourse.downloadRecords) {
            UITableViewCell *cell = [self.tableView cellForItem:aRecord];

            UIButton *cellButton = (UIButton *)[cell viewWithTag:1004];
            [cellButton.titleLabel setHidden:YES];

            aRecord.isSelected = !isAllItemsSelected;

            if (isAllItemsSelected) {
                [cellButton
                    setBackgroundImage:[UIImage imageNamed:@"download_default"]
                              forState:UIControlStateNormal];
            } else {
                [cellButton
                    setBackgroundImage:[UIImage imageNamed:@"download_selected"]
                              forState:UIControlStateNormal];
            }

            if (!isAllItemsSelected) {
                selectedItemsCount++;
            }
        }
    }

    if (isAllItemsSelected) {
        [selectAllItemsButton setImage:[UIImage imageNamed:@"download_default"]
                              forState:UIControlStateNormal];
    } else {
        [selectAllItemsButton setImage:[UIImage imageNamed:@"download_selected"]
                              forState:UIControlStateNormal];
    }

    [self refreshTable];
    isAllItemsSelected = !isAllItemsSelected;
    [self setRemoveItemsButtonText];
}

- (void)indent:(BOOL)needed view:(UIView *)view {
    int x = view.frame.origin.x +
            (needed ? UITableViewCellIndent : -UITableViewCellIndent);
    int y = view.frame.origin.y;
    int width = view.frame.size.width;
    int height = view.frame.size.height;
    view.frame = CGRectMake(x, y, width, height);
}

- (void)indent2:(BOOL)needed view:(UIView *)view {
    int x = view.frame.origin.x + (needed ? UITableViewCellIndent : 0);
    int y = view.frame.origin.y;
    int width = view.frame.size.width;
    int height = view.frame.size.height;
    view.frame = CGRectMake(x, y, width, height);
}

#pragma mark - Custom Method

- (NSString *)getVideosDirPath {
    NSArray *allPathes = NSSearchPathForDirectoriesInDomains(
        NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documentDir = [allPathes objectAtIndex:0];
    NSString *videosDirPath =
        [documentDir stringByAppendingPathComponent:@"DownLoad/mp4"];

    return videosDirPath;
}

- (NSString *)getTempDirPath {
    NSArray *allPathes = NSSearchPathForDirectoriesInDomains(
        NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documentDir = [allPathes objectAtIndex:0];
    NSString *tempDirPath =
        [documentDir stringByAppendingPathComponent:@"Temp"];

    return tempDirPath;
}

- (NSArray *)allFilesInTempDir {
    NSFileManager *fileManager = [NSFileManager defaultManager];
    NSString *tempDir = [self getTempDirPath];
    NSArray *files = [fileManager contentsOfDirectoryAtPath:tempDir error:nil];

    return files;
}

- (NSArray *)allFilesInVideosDir {
    NSFileManager *fileManager = [NSFileManager defaultManager];
    NSString *videosDir = [self getVideosDirPath];
    NSArray *files =
        [fileManager contentsOfDirectoryAtPath:videosDir error:nil];

    return files;
}

- (NSString *)getCourseIdFromFile:(NSString *)fileName {
    NSArray *fields = [fileName componentsSeparatedByString:@"_"];
    NSString *courseId = [fields objectAtIndex:0];
    return courseId;
}

- (NSString *)getVideoIdFromFile:(NSString *)fileName {
    NSArray *fields = [fileName componentsSeparatedByString:@"_"];
    NSString *videoId = [fields objectAtIndex:3];
    videoId = [[videoId componentsSeparatedByString:@"."] objectAtIndex:0];
    return videoId;
}

- (NSString *)getModuleIdFromFile:(NSString *)fileName {
    NSArray *fields = [fileName componentsSeparatedByString:@"_"];
    NSString *moduleId = [fields objectAtIndex:2];
    return moduleId;
}

//- (NSArray *) getDownloadingCoursesIds{
//    FilesDownManage *manager = [FilesDownManage sharedFilesDownManage];
//    NSMutableArray *downloadingCourseIds = [[NSMutableArray alloc] init];
//    for (FileModel *aFile in manager.filelist) {
//        BOOL isDownloading = (aFile.status == READY || aFile.status ==
//        Downloading || aFile.status == Cancelled);
//        if (isDownloading) {
//            NSString *courseId = aFile.courseId;
//            if (![downloadingCourseIds containsObject:courseId]) {
//                [downloadingCourseIds addObject:courseId];
//            }
//        }
//    }
//
//    return [NSArray arrayWithArray:downloadingCourseIds];
//}
//
//- (NSArray *) getDownloadedCoursesIds{
//    NSArray *downloadedFiles = [self allFilesInVideosDir];
//    NSMutableArray *downloadedCourseIds = [[NSMutableArray alloc] init];
//    for (NSString *aFile in downloadedFiles) {
//        NSString *courseId = [self getCourseIdFromFile:aFile];
//        if (![downloadedCourseIds containsObject:courseId]) {
//            [downloadedCourseIds addObject:courseId];
//        }
//    }
//
//    return [NSArray arrayWithArray:downloadedCourseIds];
//}
//
//- (NSArray *) getDownloadingCoursesNames{
//    NSMutableArray *downloadingCoursesNames = [[NSMutableArray alloc] init];
//    for (NSDictionary *aCourseDictionary in _allCourseIdsAndNames) {
//        NSArray *downloadingCoursesIds = [self getDownloadingCoursesIds];
//        for (NSString *aCourseId in downloadingCoursesIds) {
//            if ([[aCourseDictionary objectForKey:@"courseId"] intValue] ==
//            [aCourseId intValue]) {
//                [downloadingCoursesNames addObject:[aCourseDictionary
//                objectForKey:@"courseName"]];
//            }
//        }
//    }
//
//    return [NSArray arrayWithArray:downloadingCoursesNames];
//}
//
//- (NSArray *) getDownloadedCoursesNames{
//    NSMutableArray *downloadedCoursesNames = [[NSMutableArray alloc] init];
//    for (NSDictionary *aCourseDictionary in _allCourseIdsAndNames) {
//        NSArray *downloadedCoursesIds = [self getDownloadedCoursesIds];
//        for (NSString *aCourseId in downloadedCoursesIds) {
//            if ([[aCourseDictionary objectForKey:@"courseId"] intValue] ==
//            [aCourseId intValue]) {
//                [downloadedCoursesNames addObject:[aCourseDictionary
//                objectForKey:@"courseName"]];
//            }
//        }
//    }
//
//    return [NSArray arrayWithArray:downloadedCoursesNames];
//}
//
//- (NSString *) getCourseNameById:(int) courseId inArray:(NSArray *) array{
//    for (NSDictionary *aCourseDictionary in array) {
//        BOOL found = ([[aCourseDictionary objectForKey:@"courseId"] intValue]
//        == courseId);
//        if (found) {
//            return [aCourseDictionary objectForKey:@"courseName"];
//        }
//    }
//
//    return nil;
//}

- (NSString *)getDownloadedVideoPathById:(NSString *)courseId {
    for (NSString *path in [self allFilesInVideosDir]) {
        if ([path hasPrefix:courseId]) {
            return
                [[self getVideosDirPath] stringByAppendingPathComponent:path];
        }
    }

    return nil;
}

- (NSString *)getDownloadedModuleIdBy:(NSString *)filePath {

    NSString *moduleId =
        [[filePath componentsSeparatedByString:@"_"] objectAtIndex:2];

    return moduleId;
}

- (ASIHTTPRequest *)getRequestByFileName:(NSString *)fileName {
    FilesDownManage *videoDownloader = [FilesDownManage sharedInstance];
    for (ASIHTTPRequest *request in videoDownloader.downinglist) {
        FileModel *fileInfo =
            (FileModel *)[request.userInfo objectForKey:@"File"];
        if ([fileInfo.fileName isEqualToString:fileName]) {
            return request;
        }
    }

    return nil;
}

#pragma mark TreeView Delegate methods
- (CGFloat)treeView:(RATreeView *)treeView heightForRowForItem:(id)item {
    NSInteger treeDepthLevel = [treeView levelForCellForItem:item];
    if (treeDepthLevel == 0) {
        return 60;
    } else if (treeDepthLevel == 1) {
        return 50;
    }
    return 0;
}

/*
- (CGFloat)treeView:(RATreeView *)treeView heightForRowForItem:(id)item
treeNodeInfo:(RATreeNodeInfo *)treeNodeInfo
{
    if (treeNodeInfo.treeDepthLevel == 0) {
        return 60;
    } else if (treeNodeInfo.treeDepthLevel == 1) {
        return 50;
    }
    return 0;
}
*/

- (NSInteger)treeView:(RATreeView *)treeView
    indentationLevelForRowForItem:(id)item {

    NSInteger treeDepthLevel = [treeView levelForCellForItem:item];
    return 1 * treeDepthLevel;
}

/*
- (NSInteger)treeView:(RATreeView *)treeView
indentationLevelForRowForItem:(id)item treeNodeInfo:(RATreeNodeInfo
*)treeNodeInfo
{
    return 1 * treeNodeInfo.treeDepthLevel;
}
*/

- (BOOL)treeView:(RATreeView *)treeView shouldExpandRowForItem:(id)item {
    return shouldExpanded;
}

/*
- (BOOL)treeView:(RATreeView *)treeView shouldExpandItem:(id)item
treeNodeInfo:(RATreeNodeInfo *)treeNodeInfo
{
    return shouldExpanded;
}
*/

- (BOOL)treeView:(RATreeView *)treeView
    shouldItemBeExpandedAfterDataReload:(id)item
                         treeDepthLevel:(NSInteger)treeDepthLevel {
    return !(treeDepthLevel == 0);
}

- (void)treeView:(RATreeView *)treeView
    willDisplayCell:(UITableViewCell *)cell
            forItem:(id)item {

    NSInteger treeDepthLevel = [treeView levelForCellForItem:item];
    if (treeDepthLevel == 0) {
        cell.backgroundColor = UIColorFromRGB(0x242424);
    } else if (treeDepthLevel == 1) {
        cell.backgroundColor = UIColorFromRGB(0x1A1A1A);
    }
}

/*
- (void)treeView:(RATreeView *)treeView willDisplayCell:(UITableViewCell *)cell
forItem:(id)item treeNodeInfo:(RATreeNodeInfo *)treeNodeInfo
{
    if (treeNodeInfo.treeDepthLevel == 0) {
        cell.backgroundColor = UIColorFromRGB(0x242424);
    } else if (treeNodeInfo.treeDepthLevel == 1) {
        cell.backgroundColor = UIColorFromRGB(0x1A1A1A);
    }
}
*/

- (void)treeView:(RATreeView *)treeView didSelectRowForItem:(id)item {
    NSInteger treeDepthLevel = [treeView levelForCellForItem:item];
    BOOL expanded = [treeView isCellForItemExpanded:item];

    [treeView deselectRowForItem:item animated:YES];

    if (treeDepthLevel == 0) {
        /****************** section ********************/
        UITableViewCell *cell = [treeView cellForItem:item];
        UIImageView *sectionIndicator = (UIImageView *)[cell viewWithTag:1005];
        if (expanded) {
            [sectionIndicator setImage:[UIImage imageNamed:@"download_down"]];
        } else {
            [sectionIndicator setImage:[UIImage imageNamed:@"download_up"]];
        }
    } else if (treeDepthLevel == 1) {
        KKBDownloadRecord *aRecord = (KKBDownloadRecord *)item;
        if (aRecord.status == FINISHED) {
            NSString *videoUrl = [NSString
                stringWithFormat:@"file://%@/%@", [self getVideosDirPath],
                                 aRecord.fileName];
            [playerFrameView setPromoVideoStr:videoUrl];
            [playerFrameView playMovieAtURL];
            playerFrameView.hiddenMode = YES;
            [[playerFrameView getMoviePlayer] setFullscreen:YES];
        }
    }
}

/*
- (void)treeView:(RATreeView *)treeView didSelectRowForItem:(id)item
treeNodeInfo:(RATreeNodeInfo *)treeNodeInfo{

    [treeView deselectRowForItem:item animated:YES];

    if (treeNodeInfo.treeDepthLevel == 0) {
        UITableViewCell *cell = [treeView cellForItem:item];
        UIImageView *sectionIndicator = (UIImageView *)[cell viewWithTag:1005];
        if (treeNodeInfo.isExpanded) {
            [sectionIndicator setImage:[UIImage imageNamed:@"download_down"]];
        } else {
            [sectionIndicator setImage:[UIImage imageNamed:@"download_up"]];
        }
    } else if (treeNodeInfo.treeDepthLevel == 1){
        KKBDownloadRecord *aRecord = (KKBDownloadRecord *) item;
        if (aRecord.status == FINISHED) {
            NSString *videoUrl = [NSString stringWithFormat:@"file://%@/%@",
[self getVideosDirPath], aRecord.fileName];
            [playerFrameView setPromoVideoStr:videoUrl];
            [playerFrameView playMovieAtURL];
            playerFrameView.hiddenMode = YES;
            [[playerFrameView getMoviePlayer] setFullscreen:YES];

        }
    }
}
*/

/*
- (BOOL)treeView:(RATreeView *)treeView canEditRowForItem:(id)item
treeNodeInfo:(RATreeNodeInfo *)treeNodeInfo{
    return NO;
}
*/

#pragma mark TreeView Data Source
- (UITableViewCell *)treeView:(RATreeView *)treeView cellForItem:(id)item {
    NSInteger treeDepthLevel = [treeView levelForCellForItem:item];
    BOOL expanded = [treeView isCellForItemExpanded:item];

    if (treeDepthLevel == 0) {

        static NSString *cellIdentifier = @"DownloadManagerSection";
        UITableViewCell *cell =
            [treeView dequeueReusableCellWithIdentifier:cellIdentifier];
        if (cell == nil) {
            NSArray *arr =
                [[NSBundle mainBundle] loadNibNamed:@"DownloadManagerSection"
                                              owner:self
                                            options:nil];
            cell = [arr objectAtIndex:0];
        }

        /****************** section ********************/
        KKBDownloadCourse *aCourse = ((KKBDownloadCourse *)item);

        UIButton *selectButton = (UIButton *)[cell viewWithTag:1006];
        UILabel *sectionTextLabel = (UILabel *)[cell viewWithTag:1004];
        UIImageView *sectionIndicator = (UIImageView *)[cell viewWithTag:1005];

        selectButton.titleLabel.text =
            [NSString stringWithFormat:@"%@", aCourse.courseId];

        if (aCourse.isSelected) {
            [selectButton
                setBackgroundImage:[UIImage imageNamed:@"download_selected"]
                          forState:UIControlStateNormal];
        } else {
            [selectButton
                setBackgroundImage:[UIImage imageNamed:@"download_default"]
                          forState:UIControlStateNormal];
        }

        [selectButton setHidden:!isEditActivated];

        [self indent2:isEditActivated view:sectionTextLabel];

        [selectButton addTarget:self
                         action:@selector(sectionSelected:)
               forControlEvents:UIControlEventTouchUpInside];

        [sectionTextLabel setTextColor:UIColorFromRGB(0xF1F1F1)];
        [sectionTextLabel setFont:[UIFont systemFontOfSize:16]];
        if (expanded) {
            [sectionIndicator setImage:[UIImage imageNamed:@"download_up"]];
        } else {
            [sectionIndicator setImage:[UIImage imageNamed:@"download_down"]];
        }

        sectionTextLabel.text = aCourse.title;

        return cell;
    } else if (treeDepthLevel == 1) {

        static NSString *cellIdentifier = @"DownloadManagerCell";
        UITableViewCell *cell =
            [treeView dequeueReusableCellWithIdentifier:cellIdentifier];
        if (cell == nil) {
            NSArray *arr =
                [[NSBundle mainBundle] loadNibNamed:@"DownloadManagerCell"
                                              owner:self
                                            options:nil];
            cell = [arr objectAtIndex:0];
        }

        /****************** cell ********************/
        KKBDownloadRecord *aRecord = ((KKBDownloadRecord *)item);

        UIButton *selectButton = (UIButton *)[cell viewWithTag:1004];
        UILabel *cellTextLabel = (UILabel *)[cell viewWithTag:1000];
        UIProgressView *cellProgressView =
            (UIProgressView *)[cell viewWithTag:1001];
        UILabel *cellProgressLabel = (UILabel *)[cell viewWithTag:1002];
        UIButton *cellIndicator = (UIButton *)[cell viewWithTag:1003];

        if (aRecord.isSelected) {
            [selectButton
                setBackgroundImage:[UIImage imageNamed:@"download_selected"]
                          forState:UIControlStateNormal];
        } else {
            [selectButton
                setBackgroundImage:[UIImage imageNamed:@"download_default"]
                          forState:UIControlStateNormal];
        }

        selectButton.titleLabel.text =
            [NSString stringWithFormat:@"%@", aRecord.fileName];

        [selectButton setHidden:!isEditActivated];
        [selectButton.titleLabel setHidden:YES];
        [selectButton addTarget:self
                         action:@selector(cellSelected:)
               forControlEvents:UIControlEventTouchUpInside];

        [self indent2:isEditActivated view:cellTextLabel];
        [self indent2:isEditActivated view:cellProgressView];
        [self indent2:isEditActivated view:cellProgressLabel];
        [self indent2:isEditActivated view:cellIndicator];

        [cellIndicator addTarget:self
                          action:@selector(downloadVideo:event:)
                forControlEvents:UIControlEventTouchUpInside];

        [cellTextLabel setTextColor:UIColorFromRGB(0x9F9F9F)];
        [cellTextLabel setLineBreakMode:NSLineBreakByTruncatingTail];
        [cellTextLabel setFont:[UIFont systemFontOfSize:12]];

        [cellProgressLabel setTextColor:UIColorFromRGB(0x9F9F9F)];
        [cellProgressView setProgress:aRecord.progress];
        cellProgressLabel.text = aRecord.progressText;

        // download status
        switch (aRecord.status) {
        case READY:
            [cellIndicator setBackgroundImage:[UIImage imageNamed:@"download"]
                                     forState:UIControlStateNormal];
            break;

        case DOWNLOADING:
            [cellIndicator
                setBackgroundImage:[UIImage imageNamed:@"download_stop"]
                          forState:UIControlStateNormal];
            break;

        case PAUSED:
            [cellIndicator setBackgroundImage:[UIImage imageNamed:@"download"]
                                     forState:UIControlStateNormal];
            break;

        case FINISHED:
            [cellIndicator setBackgroundImage:[UIImage imageNamed:@"down_done"]
                                     forState:UIControlStateNormal];
            break;

        case FAILED:
            [cellIndicator setBackgroundImage:[UIImage imageNamed:@"download"]
                                     forState:UIControlStateNormal];
            break;

        default:
            break;
        }

        cellIndicator.titleLabel.text = aRecord.fileName;
        [cellIndicator.titleLabel setHidden:YES];
        cellTextLabel.text = aRecord.title;

        return cell;
    }

    return nil;
}

/*
- (UITableViewCell *)treeView:(RATreeView *)treeView cellForItem:(id)item
treeNodeInfo:(RATreeNodeInfo *)treeNodeInfo
{

    if (treeNodeInfo.treeDepthLevel == 0) {

        static NSString* cellIdentifier = @"DownloadManagerSection";
        UITableViewCell* cell = [treeView
dequeueReusableCellWithIdentifier:cellIdentifier];
        if (cell == nil) {
            NSArray* arr = [[NSBundle mainBundle]
loadNibNamed:@"DownloadManagerSection" owner:self options:nil];
            cell=  [arr objectAtIndex:0];
        }

        KKBDownloadCourse *aCourse = ((KKBDownloadCourse *)item);

        UIButton *selectButton = (UIButton *)[cell viewWithTag:1006];
        UILabel *sectionTextLabel = (UILabel *)[cell viewWithTag:1004];
        UIImageView *sectionIndicator = (UIImageView *)[cell viewWithTag:1005];

        selectButton.titleLabel.text = [NSString stringWithFormat:@"%@",
aCourse.courseId];

        if (aCourse.isSelected) {
            [selectButton setBackgroundImage:[UIImage
imageNamed:@"download_selected"] forState:UIControlStateNormal];
        } else {
            [selectButton setBackgroundImage:[UIImage
imageNamed:@"download_default"] forState:UIControlStateNormal];
        }

        [selectButton setHidden:!isEditActivated];

        [self indent2:isEditActivated view:sectionTextLabel];

        [selectButton addTarget:self action:@selector(sectionSelected:)
forControlEvents:UIControlEventTouchUpInside];

        [sectionTextLabel setTextColor:UIColorFromRGB(0xF1F1F1)];
        [sectionTextLabel setFont: [UIFont systemFontOfSize:16]];
        if (treeNodeInfo.isExpanded) {
            [sectionIndicator setImage:[UIImage imageNamed:@"download_up"]];
        } else {
            [sectionIndicator setImage:[UIImage imageNamed:@"download_down"]];
        }

        sectionTextLabel.text = aCourse.title;

        return cell;
    } else if (treeNodeInfo.treeDepthLevel == 1) {

        static NSString* cellIdentifier = @"DownloadManagerCell";
        UITableViewCell* cell = [treeView
dequeueReusableCellWithIdentifier:cellIdentifier];
        if (cell == nil) {
            NSArray* arr = [[NSBundle mainBundle]
loadNibNamed:@"DownloadManagerCell" owner:self options:nil];
            cell=  [arr objectAtIndex:0];
        }


 KKBDownloadRecord *aRecord = ((KKBDownloadRecord *)item);

        UIButton *selectButton = (UIButton *)[cell viewWithTag:1004];
        UILabel *cellTextLabel = (UILabel *)[cell viewWithTag:1000];
        UIProgressView *cellProgressView = (UIProgressView *)[cell
viewWithTag:1001];
        UILabel *cellProgressLabel = (UILabel *)[cell viewWithTag:1002];
        UIButton *cellIndicator = (UIButton *)[cell viewWithTag:1003];


        if (aRecord.isSelected) {
            [selectButton setBackgroundImage:[UIImage
imageNamed:@"download_selected"] forState:UIControlStateNormal];
        } else {
            [selectButton setBackgroundImage:[UIImage
imageNamed:@"download_default"] forState:UIControlStateNormal];
        }

        selectButton.titleLabel.text = [NSString stringWithFormat:@"%@",
aRecord.fileName];

        [selectButton setHidden:!isEditActivated];
        [selectButton.titleLabel setHidden:YES];
        [selectButton addTarget:self action:@selector(cellSelected:)
forControlEvents:UIControlEventTouchUpInside];

        [self indent2:isEditActivated view:cellTextLabel];
        [self indent2:isEditActivated view:cellProgressView];
        [self indent2:isEditActivated view:cellProgressLabel];
        [self indent2:isEditActivated view:cellIndicator];

        [cellIndicator addTarget:self action:@selector(downloadVideo:event:)
forControlEvents:UIControlEventTouchUpInside];

        [cellTextLabel setTextColor:UIColorFromRGB(0x9F9F9F)];
        [cellTextLabel setLineBreakMode:NSLineBreakByTruncatingTail];
        [cellTextLabel setFont: [UIFont systemFontOfSize:12]];

        [cellProgressLabel setTextColor:UIColorFromRGB(0x9F9F9F)];
        [cellProgressView setProgress:aRecord.progress];
        cellProgressLabel.text = aRecord.progressText;

        // download status
        switch (aRecord.status) {
            case READY:
                [cellIndicator setBackgroundImage:[UIImage
imageNamed:@"download"] forState:UIControlStateNormal];
                break;

            case DOWNLOADING:
                [cellIndicator setBackgroundImage:[UIImage
imageNamed:@"download_stop"] forState:UIControlStateNormal];
                break;

            case PAUSED:
                [cellIndicator setBackgroundImage:[UIImage
imageNamed:@"download"] forState:UIControlStateNormal];
                break;

            case FINISHED:
                [cellIndicator setBackgroundImage:[UIImage
imageNamed:@"down_done"] forState:UIControlStateNormal];
                break;

            case FAILED:
                [cellIndicator setBackgroundImage:[UIImage
imageNamed:@"download"] forState:UIControlStateNormal];
                break;

            default:
                break;
        }

        cellIndicator.titleLabel.text = aRecord.fileName;
        [cellIndicator.titleLabel setHidden:YES];
        cellTextLabel.text = aRecord.title;

        return cell;
    }

    return nil;
}
*/

- (NSInteger)treeView:(RATreeView *)treeView numberOfChildrenOfItem:(id)item {
    if (item == nil) {
        return [self.downloadCourses count];
    }

    KKBDownloadRecord *aRecord = (KKBDownloadRecord *)item;
    if ([aRecord isMemberOfClass:[KKBDownloadRecord class]]) {
        return 0;
    }

    KKBDownloadCourse *aCourse = (KKBDownloadCourse *)item;
    if ([aCourse isMemberOfClass:[KKBDownloadCourse class]]) {
        return aCourse.downloadRecords.count;
    }

    return 0;
}

- (id)treeView:(RATreeView *)treeView child:(NSInteger)index ofItem:(id)item {
    if (item == nil) {
        return [self.downloadCourses objectAtIndex:index];
    }

    KKBDownloadCourse *aCourse = (KKBDownloadCourse *)item;
    return [aCourse.downloadRecords objectAtIndex:index];
}

#pragma mark - DownloadDelegate
- (void)updateNumbersOfDownloading:(NSDictionary *)numbersByCourse {
}

#pragma mark - UINavigationController Delegate Methods
- (BOOL)hidesBottomBarWhenPushed {
    return YES;
}

#pragma mark - Custom mehtod

- (void)movieFinished:(NSNotification *)notification {
    if (playerFrameView) {
        [playerFrameView setHidden:YES];
    }
}

- (void)exitFullScreen:(NSNotification *)notification {
    if (playerFrameView) {
        [playerFrameView setHidden:YES];
    }
}

- (void)setAllCourseIdsAndNames:(NSArray *)courses {
    _allCourseIdsAndNames = courses;

    //    [self getDownloadedCoursesNames];
    //    [self getDownloadingCoursesNames];
}

- (void)requestAllCoursesIdsAndNames {
    NSMutableArray *allCoursesIdsAndNames = [[NSMutableArray alloc] init];

    NSDictionary *downloadInfoDictionary =
        [[FilesDownManage sharedInstance] getDownloadInfoByCourses];

    for (NSString *aCourseId in [downloadInfoDictionary allKeys]) {
        NSString *courseName =
            [[LocalStorage shareInstance] getCourseNameBy:aCourseId];

        NSDictionary *aCourse = [NSDictionary
            dictionaryWithObjectsAndKeys:aCourseId, @"courseId", courseName,
                                         @"courseName", nil];
        [allCoursesIdsAndNames addObject:aCourse];
    }

    [self
        setAllCourseIdsAndNames:[NSArray arrayWithArray:allCoursesIdsAndNames]];
}

- (NSArray *)getDownloadCourse {
    NSString *cacheFileName = CACHE_HOMEPAGE_MYCOURSE;
    // unarchiver
    NSString *myCoursePath = [FileUtil
        getDocumentFilePathWithFile:cacheFileName
                                dir:ARCHIVER_DIR, CACHE_HOMEPAGE_MYCOURSE, nil];

    NSArray *myCoursesDataArray =
        [NSKeyedUnarchiver unarchiveObjectWithFile:myCoursePath];

    return myCoursesDataArray;
}

- (void)downloadVideo:(id)sender event:(id)event {
    UIButton *downloadBtn = (UIButton *)sender;

    NSString *recordId = downloadBtn.titleLabel.text;
    KKBDownloadRecord *aRecord = [self getDownloadRecordById:recordId];

    switch (aRecord.status) {
    case READY:

        break;

    case DOWNLOADING:
        [downloadBtn setBackgroundImage:[UIImage imageNamed:@"download_stop"]
                               forState:UIControlStateNormal];
        [self pause:YES forFile:recordId];
        aRecord.status = PAUSED;
        [self enablePauseAndResumeAllButton:YES];
        int k = 0;
        for (ASIHTTPRequest *requ in
             [FilesDownManage sharedInstance].downinglist) {
            FileModel *aFile = [requ.userInfo objectForKey:@"File"];
            if (aFile.status == Cancelled) {
                k++;
            }
        }
        if (k == [FilesDownManage sharedInstance].downinglist.count) {
            [self enablePauseAllButton:NO];
        }

        break;

    case PAUSED:
        [downloadBtn setBackgroundImage:[UIImage imageNamed:@"download"]
                               forState:UIControlStateNormal];
        [self pause:NO forFile:recordId];
        aRecord.status = DOWNLOADING;
        [self enablePauseAndResumeAllButton:YES];

        //如果 downingList中的所有对象下载状态为DOWNLOADING
        //则将全部下载按钮disable
        int j = 0;
        for (ASIHTTPRequest *requ in
             [FilesDownManage sharedInstance].downinglist) {
            FileModel *aFile = [requ.userInfo objectForKey:@"File"];
            if (aFile.status == Downloading) {
                j++;
            }
        }
        if (j == [FilesDownManage sharedInstance].downinglist.count) {
            [self enablePauseAllButton:YES];
        }

        break;

    case FINISHED:

        break;

    case FAILED:

        break;

    default:
        break;
    }

    // [self checkIfAllRecordsPaused];
    [self refreshTable];
}

- (void)checkIfAllRecordsPaused {
    FilesDownManage *filesManager = [FilesDownManage sharedInstance];

    BOOL areAllRecordsPaused = YES;

    for (FileModel *aFile in filesManager.filelist) {
        if (aFile.status == Downloading) {
            areAllRecordsPaused = NO;
            break;
        }
    }

    if (areAllRecordsPaused) {
        [self enablePauseAllButton:NO];
    } else {
        [self enablePauseAllButton:YES];
    }
}

- (void)pause:(BOOL)pause forFile:(NSString *)fileName {
    ASIHTTPRequest *request = [self getRequestByFileName:fileName];
    FileModel *aFile = [request.userInfo objectForKey:@"File"];

    [[NSNotificationCenter defaultCenter] postNotificationName:@"PauseDownload"
                                                        object:nil
                                                      userInfo:@{
                                                          @"fileModel" : aFile,
                                                          @"pause" : @(pause)
                                                      }];
}

- (KKBDownloadRecord *)getDownloadRecordById:(NSString *)recordId {
    for (KKBDownloadCourse *aCourse in self.downloadCourses) {
        for (KKBDownloadRecord *aRecord in aCourse.downloadRecords) {
            BOOL found = [aRecord.fileName isEqualToString:recordId];
            if (found) {
                return aRecord;
            }
        }
    }

    return nil;
}

- (void)initTableView {

    // frame
    RATreeView *treeView =
        [[RATreeView alloc] initWithFrame:[self treeViewFrame]];

    treeView.delegate = self;
    treeView.dataSource = self;
    treeView.separatorStyle = RATreeViewCellSeparatorStyleNone;

    [treeView reloadData];
    [treeView setBackgroundColor:UIColorFromRGB(0x1a1a1a)];
    [treeView setSeparatorColor:UIColorFromRGB(0x000000)];

    self.tableView = treeView;
    BOOL noContents =
        (self.downloadCourses == nil || self.downloadCourses.count == 0);
    [self.tableView setHidden:noContents];
    [self.view addSubview:treeView];
}

- (void)initDownloadingData {
    FilesDownManage *filesManager = [FilesDownManage sharedInstance];

    if (_downloadCourses != nil) {
        /******************************* DOWDLOADING...
         * *********************************/
        NSMutableArray *downloadingArray = filesManager.downinglist;
        NSUInteger count = downloadingArray.count;
        for (int i = 0; i < count; i++) {
            ASIHTTPRequest *aRequest = [downloadingArray objectAtIndex:i];
            FileModel *fileInfo = [aRequest.userInfo objectForKey:@"File"];

            //            NSString *courseId = fileInfo.courseId;
            // NSString *courseName = [self getCourseNameById:[fileInfo.courseId
            // intValue] inArray:_allCourseIdsAndNames];
            // KKBDownloadCourse *aCourse = [[KKBDownloadCourse alloc]
            // initWith:courseId title:courseName];
            BOOL found =
                ([fileInfo.courseId intValue] == [fileInfo.courseId intValue]);
            if (found) {
                NSString *courseId = fileInfo.courseId;
                NSString *name = fileInfo.fileTitle;
                NSString *progressText = [self getProgressTextBy:fileInfo];
                float progress = [self getProgressBy:fileInfo];
                DownloadStatus status = [self getDownloadStatusBy:fileInfo];
                KKBDownloadRecord *aRecord =
                    [[KKBDownloadRecord alloc] initWith:courseId
                                               fileName:fileInfo.fileName
                                                  title:name
                                               progress:progress
                                           progressText:progressText
                                         downloadStatus:status
                                                    url:fileInfo.fileURL];

                if ([self containsCourseInTableView:courseId]) {
                    BOOL isRecordContained =
                        [self isRecord:aRecord.title inCourse:courseId];
                    if (!isRecordContained) {
                        [[self getCourseById:courseId] addRecord:aRecord];
                    }
                } else {
                    //                    if (courseName) {
                    //                        BOOL isRecordContained = [self
                    //                        isRecord:aRecord.title
                    //                        inCourse:courseId];
                    //                        if (!isRecordContained) {
                    //                            [aCourse addRecord:aRecord];
                    //                            [self.downloadCourses
                    //                            addObject:aCourse];
                    //                        }
                    //                    }
                }
            }

            NSLog(@"initDownloadingggggggData");
        }
    }

    //    if ([self getDownloadingCoursesIds].count > 0) {
    //        [self enablePauseAllButton:YES];
    //        [self setTableViewHidden:NO];
    //        [self setButtonsHidden:NO];
    //    } else {
    //        [self enablePauseAndResumeAllButton:NO];
    //    }
}

- (NSMutableArray *)getDownloadingArray {
    FilesDownManage *filesManager = [FilesDownManage sharedInstance];
    NSMutableArray *downloadings = [[NSMutableArray alloc] init];
    for (FileModel *aFile in filesManager.filelist) {
        BOOL isDownloading =
            (aFile.status == Wait || aFile.status == READY ||
             aFile.status == Downloading || aFile.status == Cancelled);
        if (isDownloading) {
            [downloadings addObject:aFile];
        }
    }

    return downloadings;
}

- (void)initDownloadedData {
    //    NSFileManager *fileManager = [NSFileManager defaultManager];
    /******************************* DOWDLOADED
     * *********************************/
    //    for (NSString *aCourseId in [self getDownloadedCoursesIds]) {
    //        NSArray *allTargetVideos = [self
    //        getAllDownloadedVideosPathBy:aCourseId];
    //        for (NSString *aVideoPath in allTargetVideos) {
    //            NSString * videoPath = [[self getVideosDirPath]
    //            stringByAppendingPathComponent:aVideoPath];
    //            NSDictionary *fileProperty = [fileManager
    //            attributesOfItemAtPath:videoPath error:nil];
    //
    //            NSString *fileSize = [NSString stringWithFormat:@"%@",
    //            [fileProperty objectForKey:@"NSFileSize"]];
    //
    //            fileSize = [CommonHelper getFileSizeString:fileSize];
    //
    //            NSString *courseName = [[LocalStorage shareInstance]
    //            getCourseNameBy:aCourseId];
    //            KKBDownloadCourse *aCourse = [[KKBDownloadCourse alloc]
    //            initWith:aCourseId title:courseName];
    //
    //            NSString *videoId = [self getVideoIdFromFile:videoPath];
    //            NSString *videoName = [[LocalStorage shareInstance]
    //            getVideoNameBy:aCourseId andVideoId:videoId];
    //            NSString *videoUrl = nil;
    //
    //            float progress = 100.0f;
    //            NSString *progressText = [NSString stringWithFormat:@"%@/%@",
    //            fileSize, fileSize] ;
    //            DownloadStatus status = FINISHED;
    //            KKBDownloadRecord *aRecord = [[KKBDownloadRecord alloc]
    //                                          initWith:aCourseId
    //                                          fileName:aVideoPath
    //                                          title:videoName
    //                                          progress:progress
    //                                          progressText:progressText
    //                                          downloadStatus:status
    //                                          url:videoUrl];
    //
    //            if ([self containsCourseInTableView:aCourseId]) {
    //                BOOL isRecordContained = [self isRecord:aRecord.title
    //                inCourse:aCourseId];
    //                if (!isRecordContained) {
    //                    [[self getCourseById:aCourseId] addRecord:aRecord];
    //                }
    //            } else {
    //                if (courseName) {
    //                    if (videoName) {
    //                        [aCourse addRecord:aRecord];
    //                    }
    //                    [self.downloadCourses addObject:aCourse];
    //                }
    //            }
    //
    //            NSLog(@"initDownloadedData");
    //        }
    //}

    //    if ([self getDownloadedCoursesIds].count > 0) {
    //        // has content
    //        [self setTableViewHidden:NO];// show
    //        [self setButtonsHidden:NO];// show
    //
    //        [self.tableView reloadData];
    //    }
}

- (NSArray *)getAllDownloadedVideosPathBy:(NSString *)aCourseId {
    NSMutableArray *allTargetVideos = [[NSMutableArray alloc] init];
    NSArray *allDownloadedVideos = [self allFilesInVideosDir];
    for (NSString *aVideoPath in allDownloadedVideos) {
        if ([aVideoPath hasPrefix:aCourseId]) {
            [allTargetVideos addObject:aVideoPath];
        }
    }

    return [NSArray arrayWithArray:allTargetVideos];
}
- (BOOL)containsCourseInTableView:(NSString *)courseId {
    for (KKBDownloadCourse *aCourse in self.downloadCourses) {
        if ([aCourse.courseId intValue] == [courseId intValue]) {
            return YES;
        }
    }

    return NO;
}

- (BOOL)isRecord:(NSString *)recordId
        inCourse:(NSString *)courseId { //// herere prob

    KKBDownloadCourse *downloadCourse = [self getCourseById:courseId];
    for (KKBDownloadRecord *aRecord in downloadCourse.downloadRecords) {
        if ([aRecord.title isEqualToString:recordId]) {
            return YES;
        }
    }

    return NO;
}

//- (BOOL) containsDownloadRecordInCourse:(NSString *) courseId
// downloadRecord:(NSString *) videoName{
//    KKBDownloadCourse *downloadCourse = [self getCourseById:courseId];
//    for (KKBDownloadRecord *aRecord in downloadCourse.downloadRecords) {
//        if ([aRecord.title isEqualToString:videoName] || videoName == nil ||
//        aRecord.title == nil) {
//            return YES;
//        }
//    }
//
//    return NO;
//}

- (KKBDownloadCourse *)getCourseById:(NSString *)courseId {
    for (KKBDownloadCourse *aCourse in self.downloadCourses) {
        if ([aCourse.courseId intValue] == [courseId intValue]) {
            return aCourse;
        }
    }

    return nil;
}

- (float)getProgressBy:(FileModel *)aFile {
    float x = [aFile.fileReceivedSize floatValue];
    float total = [aFile.fileSize floatValue];

    if (total == 0) {
        return 0;
    }

    return x / total;
}

- (NSString *)getProgressTextBy:(FileModel *)aFile {
    if ([aFile.fileReceivedSize integerValue] == 0 &&
        [aFile.fileSize integerValue] > 0) {
        return [NSString
            stringWithFormat:@"%@/%@",
                             [CommonHelper getFileSizeString:[aFile fileSize]],
                             [CommonHelper getFileSizeString:[aFile fileSize]]];
    } else {
        return [NSString
            stringWithFormat:@"%@/%@",
                             [CommonHelper
                                 getFileSizeString:[aFile fileReceivedSize]],
                             [CommonHelper getFileSizeString:[aFile fileSize]]];
    }
}

- (DownloadStatus)getDownloadStatusBy:(FileModel *)aFile {
    //    if ([aFile.fileSize longLongValue] == 0) {
    //        return READY;
    //    } else if (aFile.isDownloading && [aFile.fileSize longLongValue] != 0)
    //    {
    //        return DOWNLOADING;
    //    } else if (!aFile.isDownloading &&([aFile.fileSize longLongValue] >
    //    [aFile.fileReceivedSize longLongValue])){
    //        return PAUSED;
    //    } else if ([[aFile fileReceivedSize] longLongValue] >= [aFile.fileSize
    //    longLongValue]){
    //        return FINISHED;
    //    }

    //    return FAILED;

    if (aFile.status == Wait || aFile.status == Ready) {
        return READY;
    } else if (aFile.status == Downloading) {
        return DOWNLOADING;
    } else if (aFile.status == Cancelled) {
        return PAUSED;
    } else if (aFile.status == Finished) {
        return FINISHED;
    }

    return UNKNOWN;
}

- (void)requestDownloadingData {
    [self initDownloadingData];
}

- (NSArray *)getCourseModules {
    return nil;
}

- (KKBDownloadRecord *)getDownloadRecordBy:(FileModel *)aFile {
    for (KKBDownloadCourse *aCourse in self.downloadCourses) {
        for (KKBDownloadRecord *aRecord in aCourse.downloadRecords) {

            BOOL found = [aRecord.fileName isEqualToString:aFile.fileName];
            if (found) {
                aRecord.progress = [self getProgressBy:aFile];
                aRecord.progressText = [self getProgressTextBy:aFile];

                UITableViewCell *cell = [self.tableView cellForItem:aRecord];
                UIProgressView *progressView =
                    (UIProgressView *)[cell viewWithTag:1001];
                UILabel *progressLabel = (UILabel *)[cell viewWithTag:1002];

                [progressView setProgress:aRecord.progress];
                [progressLabel setText:aRecord.progressText];

                return aRecord;
            }
        }
    }

    return nil;
}

- (CGRect)treeViewFrame {
    int x = 0;
    int y = NAVIGATION_BAR_HEIGHT;
    int width = self.view.frame.size.width;
    int height = self.view.bounds.size.height - y - STATUS_BAR_HEIGHT -
                 BOTTOM_BUTTON_HEIGHT;
    CGRect frame = CGRectMake(x, y, width, height);
    return frame;
}

- (void)handleNotification {
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(updateProgress:)
                                                 name:@"CellDownloadProgress"
                                               object:nil];
}

- (void)updateProgress:(NSNotification *)notification {
    //    ASIHTTPRequest *request = [notification.userInfo
    //    objectForKey:@"request"];
    //    FileModel *fileInfo = [request.userInfo objectForKey:@"File"];

    //    KKBDownloadRecord *aRecord = [self getDownloadRecordBy:fileInfo];

    //    BOOL finished = [fileInfo.fileReceivedSize integerValue] >=
    //    [fileInfo.fileSize integerValue] && fileInfo.status == Downloading;
    //    if (finished) {
    //        aRecord.status = FINISHED;
    //        [self refreshTable];
    //    }

    BOOL noDownloadingTask =
        ([FilesDownManage sharedInstance].downinglist == nil ||
         [FilesDownManage sharedInstance].downinglist.count == 0);
    if (noDownloadingTask) {
        [self enablePauseAndResumeAllButton:NO];
    }
}

- (CGRect)pauseAllButtonFrame {
    int width = self.view.frame.size.width / 2;
    int height = BOTTOM_BUTTON_HEIGHT;
    int x = 0;
    int y = self.view.bounds.size.height - height - STATUS_BAR_HEIGHT;

    CGRect frame = CGRectMake(x, y, width, height);
    return frame;
}

- (CGRect)startAllButtonFrame {
    int width = self.view.frame.size.width / 2;
    int height = BOTTOM_BUTTON_HEIGHT;
    int x = width;
    int y = self.view.bounds.size.height - height - STATUS_BAR_HEIGHT;

    CGRect frame = CGRectMake(x, y, width, height);
    return frame;
}

- (void)addFourButtons {

    pauseAllButton =
        [[UIButton alloc] initWithFrame:[self pauseAllButtonFrame]];
    [pauseAllButton setTitle:@"全部暂停" forState:UIControlStateNormal];
    [pauseAllButton setTitleColor:UIColorFromRGB(0x333333)
                         forState:UIControlStateDisabled];
    [pauseAllButton setBackgroundColor:UIColorFromRGB(0x404040)];
    [pauseAllButton setBackgroundImage:[UIImage imageNamed:@"button_pressed"]
                              forState:UIControlStateHighlighted];
    [pauseAllButton addTarget:self
                       action:@selector(pauseAll:)
             forControlEvents:UIControlEventTouchUpInside];

    resumeAllButton =
        [[UIButton alloc] initWithFrame:[self startAllButtonFrame]];
    [resumeAllButton setTitle:@"全部开始" forState:UIControlStateNormal];
    [resumeAllButton setTitleColor:UIColorFromRGB(0x333333)
                          forState:UIControlStateDisabled];
    [resumeAllButton setBackgroundColor:UIColorFromRGB(0x404040)];
    [resumeAllButton setBackgroundImage:[UIImage imageNamed:@"button_pressed"]
                               forState:UIControlStateHighlighted];
    [resumeAllButton addTarget:self
                        action:@selector(startAll:)
              forControlEvents:UIControlEventTouchUpInside];
    [resumeAllButton setEnabled:NO];

    selectAllItemsButton =
        [[UIButton alloc] initWithFrame:[self pauseAllButtonFrame]];
    [selectAllItemsButton setTitle:@"全选" forState:UIControlStateNormal];
    [selectAllItemsButton setBackgroundColor:UIColorFromRGB(0x333333)];
    [selectAllItemsButton
        setBackgroundImage:[UIImage imageNamed:@"button_pressed"]
                  forState:UIControlStateHighlighted];
    [selectAllItemsButton setImage:[UIImage imageNamed:@"download_default"]
                          forState:UIControlStateNormal];
    [selectAllItemsButton addTarget:self
                             action:@selector(selectAllItems:)
                   forControlEvents:UIControlEventTouchUpInside];

    removeItemsButton =
        [[UIButton alloc] initWithFrame:[self startAllButtonFrame]];
    [removeItemsButton setTitle:@"删除(已选0个)" forState:UIControlStateNormal];
    [removeItemsButton addTarget:self
                          action:@selector(removeItems:)
                forControlEvents:UIControlEventTouchUpInside];
    [removeItemsButton setBackgroundColor:UIColorFromRGB(0xe55e5e)];
    [removeItemsButton
        setBackgroundImage:[UIImage imageNamed:@"button_pressed2"]
                  forState:UIControlStateHighlighted];

    [self.view addSubview:selectAllItemsButton];
    [self.view addSubview:removeItemsButton];

    [self.view addSubview:pauseAllButton];
    [self.view addSubview:resumeAllButton];

    BOOL hasDownloadingTask = [self hasDownloadingTask];
    BOOL areAllRecordsStarted = [self areAllRecordsStarted];
    [self enablePauseAllButton:hasDownloadingTask && areAllRecordsStarted];

    // add | between two buttons
    line = [[KKBVerticalLine alloc] initWithFrame:[self pipeFrame]];
    [self.view addSubview:line];
    [line setHidden:YES];

    BOOL hasNoContents =
        (self.downloadCourses == nil || self.downloadCourses.count == 0);
    [self setButtonsHidden:hasNoContents];
}

//- (BOOL) hasDownloadingTask{
//    return ([FilesDownManage sharedFilesDownManage].downinglist.count > 0);
//}

- (void)enablePauseAllButton:(BOOL)enable {
    [pauseAllButton setEnabled:enable];
    [resumeAllButton setEnabled:!enable];
}

- (void)enablePauseAndResumeAllButton:(BOOL)enable {
    [pauseAllButton setEnabled:enable];
    [resumeAllButton setEnabled:enable];
}

- (void)setButtonsHidden:(BOOL)hidden {
    [selectAllItemsButton setHidden:hidden];
    [removeItemsButton setHidden:hidden];
    [pauseAllButton setHidden:hidden];
    [resumeAllButton setHidden:hidden];

    [_btnEditOrDone setHidden:hidden];
    [line setHidden:hidden];
}

- (void)setTableViewHidden:(BOOL)hidden {
    [self.tableView setHidden:hidden];

    if (hidden) {
        ;
    }
}

- (CGRect)pipeFrame {

    int x = self.view.frame.size.width / 2;
    int y = self.view.frame.size.height - STATUS_BAR_HEIGHT - 10 - 28;
    int width = 2;
    int height = 28;

    return CGRectMake(x - 1, y, width, height);
}

- (void)startAll:(UIButton *)button {
    [self resumeAllNew];
}

- (void)pauseAll:(UIButton *)button {
    [self pauseAllNew];
}

- (void)resumeAll {
    FilesDownManage *videoDownloader = [FilesDownManage sharedInstance];

    NSUInteger count = videoDownloader.downinglist.count;
    for (int i = 0; i < count; i++) {
        __autoreleasing ASIHTTPRequest *aRequest =
            videoDownloader.downinglist[i];
        FileModel *aFile = [aRequest.userInfo objectForKey:@"File"];

        KKBDownloadRecord *aRecord = [self getDownloadRecordBy:aFile];

        [self pause:NO forFile:aFile.fileName];
        aRecord.status = DOWNLOADING;
    }

    [self enablePauseAllButton:YES];
    [self refreshTable];
}
- (void)resumeAllNew {
    NSUInteger count = [FilesDownManage sharedInstance].downinglist.count;
    for (int i = 0; i < count; i++) {
        ASIHTTPRequest *aRequest =
            [FilesDownManage sharedInstance].downinglist[i];
        if (aRequest != nil && [aRequest isCancelled]) {
            FileModel *aFile = [aRequest.userInfo objectForKey:@"File"];
            [[FilesDownManage sharedInstance] beginRequest:aFile
                                               isBeginDown:YES];
            KKBDownloadRecord *aRecord = [self getDownloadRecordBy:aFile];
            aFile.status = Downloading;
            aRecord.status = DOWNLOADING;
        }
    }
    [self enablePauseAllButton:YES];
    [self refreshTable];
}

- (void)pauseAll {
    FilesDownManage *videoDownloader = [FilesDownManage sharedInstance];

    for (ASIHTTPRequest *aRequest in videoDownloader.downinglist) {
        if (aRequest != nil && ![aRequest isCancelled]) {
            FileModel *fileInfo = [aRequest.userInfo objectForKey:@"File"];
            [self pause:YES forFile:fileInfo.fileName];

            // fileInfo.status = Cancelled;
            KKBDownloadRecord *aRecord = [self getDownloadRecordBy:fileInfo];
            aRecord.status = PAUSED;
            BOOL notStarted = ([fileInfo.fileReceivedSize integerValue] == 0 &&
                               [fileInfo.fileSize integerValue] == 0);
            aRecord.progress = (notStarted ? 0 : aRecord.progress);
        }
    }

    [self refreshTable];
}

- (void)pauseAllNew {
    FilesDownManage *videoDownloader = [FilesDownManage sharedInstance];

    for (ASIHTTPRequest *aRequest in videoDownloader.downinglist) {
        if (aRequest != nil && ![aRequest isCancelled]) {
            FileModel *aFile = [aRequest.userInfo objectForKey:@"File"];
            [aRequest cancel];
            aFile.status = Cancelled;
            KKBDownloadRecord *aRecord = [self getDownloadRecordBy:aFile];
            aRecord.status = PAUSED;
            BOOL notStarted = ([aFile.fileReceivedSize integerValue] == 0 &&
                               [aFile.fileSize integerValue] == 0);
            aRecord.progress = (notStarted ? 0 : aRecord.progress);
        }
    }

    [self enablePauseAllButton:NO];
    [self refreshTable];
}
- (void)selectAllItems:(UIButton *)button {
    [self selectAllItems];
}

- (void)removeItems:(UIButton *)button {

    NSMutableArray *downloadRecordsWillBeRemoved =
        [[NSMutableArray alloc] init];

    for (KKBDownloadCourse *aCourse in self.downloadCourses) {
        for (KKBDownloadRecord *aRecord in aCourse.downloadRecords) {

            // 如果该选择框被选中，则将相对应的下载条目加入到downloadRecordsWillBeRemoved队列中
            if (aRecord.isSelected) {
                [downloadRecordsWillBeRemoved addObject:aRecord];
            }
        }
    }

    for (KKBDownloadRecord *aRecord in downloadRecordsWillBeRemoved) {
        // 重要备注:不能在for循环中，删除、增加条目
        [self removeRequest:aRecord];
        [self removeVideoFileVia:aRecord];
        [self removeRecord:aRecord];

        [self refreshTable];

        selectedItemsCount--;
        [self setRemoveItemsButtonText];
    }

    if (self.downloadCourses.count == 0) {
        [self setButtonsHidden:YES];
        [self setTableViewHidden:YES];
    }
}

- (void)removeRequest:(KKBDownloadRecord *)aRecord {
    FilesDownManage *videoDownloader = [FilesDownManage sharedInstance];
    for (ASIHTTPRequest *request in videoDownloader.downinglist) {
        FileModel *fileInfo =
            (FileModel *)[request.userInfo objectForKey:@"File"];

        BOOL found = [fileInfo.fileName isEqualToString:aRecord.fileName];
        if (aRecord.isSelected && found) {
            [request cancel];
        }
    }
}

- (void)removeRecord:(KKBDownloadRecord *)aRecord {
    KKBDownloadCourse *aCourse = [self getCourseById:aRecord.courseId];

    [aCourse.downloadRecords removeObject:aRecord];

    // 如果在删除下载的视频后，该课程下已无视频下载记录的话，将此课程也从表中移除
    if (aCourse.downloadRecords.count == 0) {
        [self.downloadCourses removeObject:aCourse];
    }
}

- (void)removeVideoFileVia:(KKBDownloadRecord *)aRecord {
    NSFileManager *fileManager = [NSFileManager defaultManager];
    NSError *err = nil;

    NSString *videoPathInVideosDir = [[self getVideosDirPath]
        stringByAppendingPathComponent:aRecord.fileName];
    NSString *videoPathWithExtMp4ExtInTempDir =
        [[self getTempDirPath] stringByAppendingPathComponent:aRecord.fileName];
    NSString *videoPathWithExtPlistInTempDir =
        [videoPathWithExtMp4ExtInTempDir stringByAppendingString:@".plist"];

    BOOL removeSuccess1 =
        [fileManager removeItemAtPath:videoPathInVideosDir error:&err];
    if (!removeSuccess1) {
        NSLog(@"Remove recorde %@ failed from [videos] dir, Reason: %@",
              aRecord, err);
    }

    BOOL removeSuccess2 =
        [fileManager removeItemAtPath:videoPathWithExtMp4ExtInTempDir
                                error:&err];
    if (!removeSuccess2) {
        NSLog(@"Remove recorde %@ failed from [Temp] dir with suffix [.mp4], "
              @"Reason: %@",
              aRecord, err);
    }

    BOOL removeSuccess3 =
        [fileManager removeItemAtPath:videoPathWithExtPlistInTempDir
                                error:&err];
    if (!removeSuccess3) {
        NSLog(@"Remove recorde %@ failed from [Temp] dir with suffix [.plist], "
              @"Reason: %@",
              aRecord, err);
    }
}

- (void)refreshTable {
    [self.tableView reloadData];
}

- (void)sectionSelected:(UIButton *)button {
    NSString *courseId = button.titleLabel.text;
    KKBDownloadCourse *aCourse = [self getCourseById:courseId];

    if (aCourse.isSelected) {
        [button setBackgroundImage:[UIImage imageNamed:@"download_default"]
                          forState:UIControlStateNormal];
        [self selectAllDownloadRecord:NO inCourse:courseId];
    } else {
        [button setBackgroundImage:[UIImage imageNamed:@"download_selected"]
                          forState:UIControlStateNormal];
        [self selectAllDownloadRecord:YES inCourse:courseId];
    }

    aCourse.isSelected = !aCourse.isSelected;

    [self checkIfAllRecordsSelectedInTable];
}

- (void)cellSelected:(UIButton *)button {
    NSString *recordId = button.titleLabel.text;
    KKBDownloadRecord *aRecord = [self getDownloadRecordById:recordId];

    if (aRecord.isSelected) {
        [button setBackgroundImage:[UIImage imageNamed:@"download_default"]
                          forState:UIControlStateNormal];
        selectedItemsCount--;
    } else {
        [button setBackgroundImage:[UIImage imageNamed:@"download_selected"]
                          forState:UIControlStateNormal];
        selectedItemsCount++;
    }

    KKBDownloadCourse *course =
        [self getCourseFromTableViewData:aRecord.courseId];

    aRecord.isSelected = !aRecord.isSelected;

    if (!aRecord.isSelected) {
        course.isSelected = NO;
    } else {
        BOOL areAllSelected =
            [self areAllRecordsSelectedForCourse:aRecord.courseId];
        if (areAllSelected) {
            course.isSelected = YES;
        }
    }

    [self checkIfAllRecordsSelectedInTable];

    [self refreshTable];
    [self setRemoveItemsButtonText];
}

- (void)checkIfAllRecordsSelectedInTable {
    BOOL areAllRecordsSelected = [self areAllRecordsSelectedForTable];
    if (areAllRecordsSelected) {
        isAllItemsSelected = YES;
        [selectAllItemsButton setImage:[UIImage imageNamed:@"download_selected"]
                              forState:UIControlStateNormal];
    } else {
        isAllItemsSelected = NO;
        [selectAllItemsButton setImage:[UIImage imageNamed:@"download_default"]
                              forState:UIControlStateNormal];
    }
}

- (KKBDownloadCourse *)getCourseFromTableViewData:(NSString *)cousseId {
    for (KKBDownloadCourse *aCourse in self.downloadCourses) {
        if ([aCourse.courseId intValue] == [cousseId intValue]) {
            return aCourse;
        }
    }

    return nil;
}

- (BOOL)areAllRecordsSelectedForCourse:(NSString *)courseId {
    BOOL areAllSelected = YES;

    KKBDownloadCourse *targetCourse =
        [self getCourseFromTableViewData:courseId];

    for (KKBDownloadRecord *aRecord in targetCourse.downloadRecords) {
        if (aRecord.isSelected) {
            areAllSelected = (areAllSelected && YES);
        } else {
            areAllSelected = (areAllSelected && NO);
        }
    }

    return areAllSelected;
}

- (BOOL)areAllRecordsDeselectedForCourse:(NSString *)courseId {
    BOOL areAllRecordsDeselected = YES;

    KKBDownloadCourse *targetCourse =
        [self getCourseFromTableViewData:courseId];

    for (KKBDownloadRecord *aRecord in targetCourse.downloadRecords) {
        if (aRecord.isSelected) {
            areAllRecordsDeselected = (areAllRecordsDeselected && NO);
        } else {
            areAllRecordsDeselected = (areAllRecordsDeselected && YES);
        }
    }

    return areAllRecordsDeselected;
}

- (BOOL)areAllRecordsSelectedForTable {
    BOOL areAllSelected = YES;

    for (KKBDownloadCourse *aCourse in self.downloadCourses) {
        if (aCourse.isSelected) {
            areAllSelected = (areAllSelected && YES);
        } else {
            areAllSelected = (areAllSelected && NO);
        }
    }

    return areAllSelected;
}

- (BOOL)areAllRecordsDeselectedForTable {
    BOOL areAllDeselected = YES;

    for (KKBDownloadCourse *aCourse in self.downloadCourses) {
        if (aCourse.isSelected) {
            areAllDeselected = (areAllDeselected && NO);
        } else {
            areAllDeselected = (areAllDeselected && YES);
        }
    }

    return areAllDeselected;
}

- (void)selectAllDownloadRecord:(BOOL)select inCourse:(NSString *)courseId {
    for (KKBDownloadCourse *aCourse in self.downloadCourses) {
        if ([aCourse.courseId intValue] == [courseId intValue]) {

            for (KKBDownloadRecord *aRecord in aCourse.downloadRecords) {
                UITableViewCell *cell = [self.tableView cellForItem:aRecord];
                UIButton *cellSelectButton =
                    (UIButton *)[cell viewWithTag:1004];

                if (select) {
                    // 如果此cell已经被选中，则selectedItemsCount计数器不再+1
                    if (!aRecord.isSelected) {
                        selectedItemsCount++;
                    }
                    [cellSelectButton
                        setBackgroundImage:[UIImage
                                               imageNamed:@"download_selected"]
                                  forState:UIControlStateNormal];
                } else {
                    // 如果此cell已经未被选中，则selectedItemsCount计数器不再-1
                    if (aRecord.isSelected) {
                        selectedItemsCount--;
                    }
                    [cellSelectButton
                        setBackgroundImage:[UIImage
                                               imageNamed:@"download_default"]
                                  forState:UIControlStateNormal];
                }
                aRecord.isSelected = select;
            }
        }
    }

    [self refreshTable];
    [self setRemoveItemsButtonText];
}

- (void)setRemoveItemsButtonText {
    if (selectedItemsCount < 0) {
        selectedItemsCount = 0;
    }

    [removeItemsButton
        setTitle:[NSString stringWithFormat:@"删除(已选%d个)",
                                            selectedItemsCount]
        forState:UIControlStateNormal];
}

- (CGRect)noTaskViewFrame {
    int x = 0;
    int y = NAVIGATION_BAR_HEIGHT;
    int width = self.view.frame.size.width;
    int height =
        self.view.frame.size.height - NAVIGATION_BAR_HEIGHT - STATUS_BAR_HEIGHT;

    return CGRectMake(x, y, width, height);
}

- (void)addNoTaskView {
    KKBNoDownloadTaskView *noTaskView = [KKBNoDownloadTaskView sharedInstance];
    [noTaskView updateFrame:[self noTaskViewFrame]];
    [self.view addSubview:noTaskView];
}

- (void)addPlayerFrameView {
    playerFrameView = [[PlayerFrameView alloc] init];

    int x = 0;
    int y = NAVIGATION_BAR_HEIGHT;
    int width = 1;
    int height = 1;
    CGRect frame = CGRectMake(x, y, width, height);

    playerFrameView.frame = frame;
    [playerFrameView setHidden:YES];
    [self.view addSubview:playerFrameView];
}

- (void)prepareData {
    _downloadCourses = [[NSMutableArray alloc] init];
}

- (void)networkStatusDidChange {
    [[AFNetworkReachabilityManager sharedManager]
        setReachabilityStatusChangeBlock:^(AFNetworkReachabilityStatus status) {
            switch (status) {
            case AFNetworkReachabilityStatusReachableViaWWAN:
                [self resumeAll];
            case AFNetworkReachabilityStatusReachableViaWiFi:
                [self resumeAll];
                break;
            case AFNetworkReachabilityStatusNotReachable:
                [self pauseAll];
            default:
                break;
            }
        }];
}

- (void)checkIfHasDownloadingTask {
    [NSTimer scheduledTimerWithTimeInterval:0.5f
                                     target:self
                                   selector:@selector(checkDownloadingTask:)
                                   userInfo:nil
                                    repeats:YES];
}

- (void)checkDownloadingTask:(NSTimer *)timer {

    BOOL hasDownloadTask = [self hasDownloadingTask];

    if (!hasDownloadTask) {
        [timer invalidate];
        [self enablePauseAndResumeAllButton:NO];
    }
    [self checkIfHasFinishedViaProgress];
}

- (BOOL)hasDownloadingTask {
    BOOL hasDownloadTask = NO;

    FilesDownManage *manager = [FilesDownManage sharedInstance];
    hasDownloadTask =
        (manager.downinglist != nil && manager.downinglist.count > 0);

    return hasDownloadTask;
}

- (BOOL)areAllRecordsPaused {
    BOOL areAllRecordsPaused = YES;
    for (KKBDownloadCourse *aCourse in self.downloadCourses) {
        for (KKBDownloadRecord *aRecord in aCourse.downloadRecords) {
            if (aRecord.status == PAUSED) {
                areAllRecordsPaused = (areAllRecordsPaused && YES);
            } else if (aRecord.status == Downloading) {
                areAllRecordsPaused = (areAllRecordsPaused && NO);
            }
        }
    }

    return areAllRecordsPaused;
}

- (BOOL)areAllRecordsStarted {
    BOOL areAllRecordsStarted = YES;
    for (KKBDownloadCourse *aCourse in self.downloadCourses) {
        for (KKBDownloadRecord *aRecord in aCourse.downloadRecords) {
            if (aRecord.status == PAUSED) {
                areAllRecordsStarted = (areAllRecordsStarted && NO);
            } else if (aRecord.status == Downloading) {
                areAllRecordsStarted = (areAllRecordsStarted && YES);
            }
        }
    }

    return areAllRecordsStarted;
}

//- (BOOL) hasDownloadingTask{
//    BOOL hasDownloadTask = NO;
//    for (KKBDownloadCourse *aCourse in self.downloadCourses) {
//        for (KKBDownloadRecord *aRecord in aCourse.downloadRecords) {
//            if (aRecord.status == Downloading) {
//                hasDownloadTask = YES;
//                break;
//            }
//        }
//    }
//
//    return hasDownloadTask;
//}

//- (void) checkDownloadingTask:(NSTimer *) timer{
//    FilesDownManage *manager = [FilesDownManage sharedFilesDownManage];
//    BOOL hasDownloadTask = NO;
//    for (FileModel *aFile in manager.filelist) {
//        hasDownloadTask = (aFile.status == Ready || aFile.status ==
//        Downloading || aFile.status == Cancelled);
//        if (hasDownloadTask) {
//            break;
//        }
//    }
//
//    [self checkIfHasFinishedViaProgress];
//
//    if (!hasDownloadTask) {
//        [timer invalidate];
//        [self enablePauseAndResumeAllButton:NO];
//    }
//}

- (void)checkIfHasFinishedViaProgress {
    for (KKBDownloadCourse *aCourse in self.downloadCourses) {
        for (KKBDownloadRecord *aRecord in aCourse.downloadRecords) {
            ASIHTTPRequest *request =
                [self getRequestByFileName:aRecord.fileName];
            FileModel *fileInfo = [request.userInfo objectForKey:@"File"];

            BOOL finished = [fileInfo.fileReceivedSize integerValue] >=
                                [fileInfo.fileSize integerValue] &&
                            [fileInfo.fileSize integerValue] > 0 &&
                            fileInfo.status == Downloading;
            if (finished) {
                aRecord.status = FINISHED;
                [self refreshTable];
            }
        }
    }
}

#pragma mark - viewDidLoad
- (void)viewDidLoad {
    [super viewDidLoad];

    [FilesDownManage
        sharedFilesDownManageWithBasepath:@"DownLoad"
                            TargetPathArr:[NSArray
                                              arrayWithObject:@"DownLoad/mp4"]];

    [self prepareData];
    [self addPlayerFrameView];
    [self addNoTaskView];
    [self networkStatusDidChange];
    //[self requestAllCoursesIdsAndNames];
    [self handleNotification];
    //    [self initDownloadingData];
    //    [self initDownloadedData];
    [self initDownloadData];

    [self initTableView];
    [self addFourButtons];
    //[self checkIfHasDownloadingTask];
    [self.navigationController.navigationBar setHidden:NO];
}

- (void)initDownloadData {

    //    NSMutableArray *allCoursesIdsAndNames = [[NSMutableArray alloc] init];
    //
    //    NSDictionary *downloadInfoDictionary = [[FilesDownManage
    //    sharedInstance] getDownloadInfoByCourses];
    //
    //    for (NSString *aCourseId in [downloadInfoDictionary allKeys]) {
    //        NSString *courseName = [[LocalStorage shareInstance]
    //        getCourseNameBy:aCourseId];
    //
    //        NSDictionary *aCourse = [NSDictionary
    //        dictionaryWithObjectsAndKeys:aCourseId, @"courseId", courseName,
    //        @"courseName", nil];
    //        [allCoursesIdsAndNames addObject:aCourse];
    //        KKBDownloadCourse *course  = [[KKBDownloadCourse
    //        alloc]initWith:aCourseId title:courseName];
    //       FileModel *model = [FilesDownManage sharedInstance].filelist
    //       objectAtIndex:
    //    }

    NSMutableArray *totalArray = [FilesDownManage sharedInstance].filelist;
    int hadAdd = 0;
    for (int i = 0; i < totalArray.count; i++) {
        hadAdd = 0;

        FileModel *filemodel = [totalArray objectAtIndex:i];
        NSString *courseId = filemodel.courseId;
        NSString *name = filemodel.fileTitle;
        NSString *progressText = [self getProgressTextBy:filemodel];
        float progress = [self getProgressBy:filemodel];
        DownloadStatus status = [self getDownloadStatusBy:filemodel];

        KKBDownloadRecord *aRecord =
            [[KKBDownloadRecord alloc] initWith:courseId
                                       fileName:filemodel.fileName
                                          title:name
                                       progress:progress
                                   progressText:progressText
                                 downloadStatus:status
                                            url:filemodel.fileURL];
        NSString *courseName =
            [[LocalStorage shareInstance] getCourseNameBy:courseId];

        if (aRecord.status != FINISHED || filemodel.status != Finished) {
            if (aRecord.status != DOWNLOADING) {
                aRecord.status = PAUSED;
            }
            if ([FilesDownManage sharedInstance].downManageFirstLoad == YES) {
                ASIHTTPRequest *request = [[ASIHTTPRequest alloc]
                    initWithURL:[NSURL URLWithString:filemodel.fileURL]];
                request.delegate = [FilesDownManage class];
                [request setDownloadDestinationPath:[filemodel targetPath]];
                [request setTemporaryFileDownloadPath:filemodel.tempPath];
                [request setDownloadProgressDelegate:[FilesDownManage class]];
                [request setNumberOfTimesToRetryOnTimeout:2];
                [request setAllowResumeForFileDownloads:YES]; //支持断点续传

                [request
                    setUserInfo:
                        [NSDictionary
                            dictionaryWithObject:filemodel
                                          forKey:
                                              @"File"]]; //设置上下文的文件基本信息
                [request setTimeOutSeconds:30.0f];

                [[FilesDownManage sharedInstance].downinglist
                    addObject:request];
            }
        }
        if (self.downloadCourses != nil || self.downloadCourses.count != 0) {
            for (KKBDownloadCourse *courseSaved in self.downloadCourses) {
                if ([courseId intValue] == [courseSaved.courseId intValue]) {
                    [courseSaved addRecord:aRecord];
                    hadAdd = 1;
                }
            }
        }
        if (hadAdd == 0) {
            KKBDownloadCourse *course =
                [[KKBDownloadCourse alloc] initWith:courseId title:courseName];
            [course addRecord:aRecord];
            [self.downloadCourses addObject:course];
        }
    }

    int pauseNum = 0;
    int loadingNum = 0;
    for (ASIHTTPRequest *aRequest in
         [FilesDownManage sharedInstance].downinglist) {
        FileModel *model = [aRequest.userInfo objectForKey:@"File"];

        if (model.status == Cancelled) {
            pauseNum = 1;
        } else if (model.status == Downloading) {
            loadingNum = 1;
        }
    }
    if (pauseNum == 1 && loadingNum == 1) {
        [self enablePauseAndResumeAllButton:YES];
    }
    [self refreshTable];
    [FilesDownManage sharedInstance].downManageFirstLoad = NO;
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];

    //    if([[[[UIDevice currentDevice] systemVersion]
    //    componentsSeparatedByString:@"."][0] intValue] >= 7) {
    //        CGRect statusBarViewRect = [[UIApplication sharedApplication]
    //        statusBarFrame];
    //        float heightPadding = statusBarViewRect.size.height +
    //        NAVGATION_BAR_HEIGHT;
    //        self.tableView.contentInset = UIEdgeInsetsMake(0, 0.0, 0.0, 0.0);
    //        self.tableView.contentOffset = CGPointMake(0.0, -heightPadding);
    //    }

    [MobClick beginLogPageView:@"download_manager"];
}
- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    [MobClick endLogPageView:@"download_manager"];
    //[[FilesDownManage sharedInstance].downinglist removeAllObjects];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self
                                                    name:@"CellDownloadProgress"
                                                  object:nil];

    [[NSNotificationCenter defaultCenter]
        removeObserver:self
                  name:MPMoviePlayerPlaybackDidFinishNotification
                object:[playerFrameView getMoviePlayer]];

    [[NSNotificationCenter defaultCenter]
        removeObserver:self
                  name:MPMoviePlayerDidEnterFullscreenNotification
                object:[playerFrameView getMoviePlayer]];

    _allCourseIdsAndNames = nil;
    playerFrameView = nil;

    pauseAllButton = nil;
    resumeAllButton = nil;
    selectAllItemsButton = nil;
    removeItemsButton = nil;
    line = nil;

    NSLog(@"DownloadManagerViewController is deallocated");
}

- (void)finishedDownload:(ASIHTTPRequest *)request {
    FileModel *aFile = (FileModel *)[request.userInfo objectForKey:@"File"];
    for (KKBDownloadCourse *aCourse in self.downloadCourses) {
        for (KKBDownloadRecord *aRecord in aCourse.downloadRecords) {

            BOOL found = [aRecord.fileName isEqualToString:aFile.fileName];
            if (found) {
                aFile.status = Finished;
                aRecord.status = FINISHED;
                [self refreshTable];
            }
        }
    }
}

@end
