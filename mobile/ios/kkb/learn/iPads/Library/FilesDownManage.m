//
//  FilesDownManage.m
//  learn
//
//  Created by User on 14-2-27.
//  Copyright (c) 2014年 kaikeba. All rights reserved.
//


#import "FilesDownManage.h"
#import "Reachability.h"
#import "AppUtilities.h"

#define MAXLINES  [[[NSUserDefaults standardUserDefaults] valueForKey:@"kMaxRequestCount"]integerValue]

#define TEMPPATH [CommonHelper getTempFolderPathWithBasepath:nil]
#define VIDEOS_PATH [CommonHelper getVideosFolderPathWithBasepath:_basepath]
#define OPENFINISHLISTVIEW

@implementation FilesDownManage
@synthesize downinglist=_downinglist;
@synthesize fileInfo = _fileInfo;
@synthesize downloadDelegate=_downloadDelegate;
@synthesize finishedlist=_finishedList;
@synthesize buttonSound=_buttonSound;
@synthesize downloadCompleteSound=_downloadCompleteSound;
@synthesize isFistLoadSound=_isFirstLoadSound;
@synthesize filelist = _filelist;
@synthesize targetPathArray = _targetPathArray;
@synthesize VCdelegate = _VCdelegate;
@synthesize count;
@synthesize fileImage = _fileImage;
static   FilesDownManage *sharedFilesDownManage = nil;



-(void)playButtonSound
{
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
	NSString *audioAlert = [userDefaults valueForKey:@"kAudioAlertSetting"];
    
	if( NO == [audioAlert boolValue] )
    {
        return;
    }
    NSURL *url=[[[NSBundle mainBundle]resourceURL] URLByAppendingPathComponent:@"btnEffect.wav"];
    NSError *error;
    if(self.buttonSound==nil)
    {
        self.buttonSound=[[AVAudioPlayer alloc] initWithContentsOfURL:url error:&error];
        if(!error)
        {
            NSLog(@"%@",[error description]);
        }
    }
    if([audioAlert isEqualToString:@"YES"]||audioAlert==nil)//播放声音
    {
        if(!self.isFistLoadSound)
        {
            self.buttonSound.volume=1.0f;
        }
    }
    else
    {
        self.buttonSound.volume=0.0f;
    }
    [self.buttonSound play];
}

-(void)playDownloadSound
{
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
	NSString *result = [userDefaults valueForKey:@"kAudioAlertSetting"];
    
	if( NO == [result boolValue] )
    {
        return;
    }
    
    NSURL *url=[[[NSBundle mainBundle]resourceURL] URLByAppendingPathComponent:@"download-complete.wav"];
    NSError *error;
    if(self.downloadCompleteSound==nil)
    {
        self.downloadCompleteSound=[[AVAudioPlayer alloc] initWithContentsOfURL:url error:&error];
        if(!error)
        {
            NSLog(@"%@",[error description]);
        }
    }
    if([result isEqualToString:@"YES"]||result==nil)//播放声音
    {
        if(!self.isFistLoadSound)
        {
            self.downloadCompleteSound.volume=1.0f;
        }
    }
    else
    {
        self.downloadCompleteSound.volume=0.0f;
    }
    [self.downloadCompleteSound play];
}
-(NSArray *)sortbyTime:(NSArray *)array{
    NSArray *sorteArray1 = [array sortedArrayUsingComparator:^(id obj1, id obj2){
        FileModel *file1 = (FileModel *)obj1;
        FileModel *file2 = (FileModel *)obj2;
        NSDate *date1 = [CommonHelper makeDate:file1.time];
        NSDate *date2 = [CommonHelper makeDate:file2.time];
        if ([[date1 earlierDate:date2]isEqualToDate:date2]) {
            return (NSComparisonResult)NSOrderedDescending;
        }
        
        if ([[date1 earlierDate:date2]isEqualToDate:date1]) {
            return (NSComparisonResult)NSOrderedAscending;
        }
        
        return (NSComparisonResult)NSOrderedSame;
    }];
    return sorteArray1;
}

-(NSArray *)sortArrayById:(NSArray *)array{
    NSArray *sorteArray1 = [array sortedArrayUsingComparator:^(id obj1, id obj2){
        FileModel *file1 = (FileModel *)obj1;
        FileModel *file2 = (FileModel *)obj2;

        NSString *fileId1 = file1.fileID;
        NSString *fileId2 = file2.fileID;
        
        if ([fileId1 intValue] <= [fileId2 intValue]) {
            return (NSComparisonResult)NSOrderedDescending;
        } else {
            return (NSComparisonResult)NSOrderedAscending;
        }
    }];
    return sorteArray1;
}

-(NSArray *)sortRequestArrbyTime:(NSArray *)array{
    NSArray *sorteArray1 = [array sortedArrayUsingComparator:^(id obj1, id obj2){
        //
        FileModel* file1 =   [((ASIHTTPRequest *)obj1).userInfo objectForKey:@"File"];
        FileModel *file2 =   [((ASIHTTPRequest *)obj2).userInfo objectForKey:@"File"];
        
        NSDate *date1 = [CommonHelper makeDate:file1.time];
        NSDate *date2 = [CommonHelper makeDate:file2.time];
        if ([[date1 earlierDate:date2]isEqualToDate:date2]) {
            return (NSComparisonResult)NSOrderedDescending;
        }
        
        if ([[date1 earlierDate:date2]isEqualToDate:date1]) {
            return (NSComparisonResult)NSOrderedAscending;
        }
        
        return (NSComparisonResult)NSOrderedSame;
    }];
    return sorteArray1;
}


-(void)saveDownloadFile:(FileModel*)fileinfo{
    
    NSLog(@"path === %@",fileinfo.targetPath);
    NSLog(@"path === %@",fileinfo.tempPath);
    NSLog(@"type === %@",fileinfo.usrname);
    NSLog(@"type === %@",[fileinfo.usrname class]);

//    NSDictionary *filedic = [NSDictionary dictionaryWithObjectsAndKeys:
//                             fileinfo.fileName,@"filename",
//                             fileinfo.fileURL,@"fileurl",
//                             fileinfo.fileTitle,@"title",
//                             _basepath,@"basepath",
//                             _TargetSubPath,@"tarpath" ,
//                             fileinfo.fileSize,@"filesize",
//                             fileinfo.fileReceivedSize,@"filerecievesize",
//                             fileinfo.courseId,@"courseID",
//                             fileinfo.usrname,@"userId",
//                             fileinfo.status, @"downloadStatus",
//                             nil];

    
    NSDictionary *filedic = [NSDictionary dictionaryWithObjectsAndKeys:
                             fileinfo.fileName,@"filename",
                             fileinfo.fileURL,@"fileurl",
                             fileinfo.fileTitle,@"title",
                             
                             _TargetSubPath,@"tarpath" ,
                             fileinfo.fileSize,@"filesize",
                             fileinfo.fileReceivedSize,@"filerecievesize",
                             fileinfo.courseId,@"courseID",
                             fileinfo.usrname,@"userId",
                             nil];
    
    NSString *plistPath = [fileinfo.tempPath stringByAppendingPathExtension:@"plist"];
    NSLog(@"===%@",plistPath);
    [filedic writeToFile:plistPath atomically:YES];
    if (![filedic writeToFile:plistPath atomically:YES]) {
        NSLog(@"write plist fail");
    }
}
-(void)beginRequest:(FileModel *)fileInfo isBeginDown:(BOOL)isBeginDown
{
    for(ASIHTTPRequest *tempRequest in self.downinglist)
    {
        if ([tempRequest.url absoluteString] == nil ||
            [[tempRequest.url absoluteString] isEqualToString:@""]) {
            continue;
        }
        NSLog(@"%@",[tempRequest.url absoluteString]);
        if([[[tempRequest.url absoluteString]lastPathComponent] isEqualToString:[fileInfo.fileURL lastPathComponent]])
        {
            if ([tempRequest isExecuting]&&isBeginDown) {
                
                fileInfo.status = Downloading;
                
                return;
            }else if ([tempRequest isExecuting]&&!isBeginDown)
            {
                [tempRequest setUserInfo:[NSDictionary dictionaryWithObject:fileInfo forKey:@"File"]];
                fileInfo.status = Cancelled;
                [tempRequest cancel];
                return;
            }
        }
        
    }
    

    
    [self saveDownloadFile:fileInfo];
    
    //NSLog(@"targetPath %@",fileInfo.targetPath);
    //按照获取的文件名获取临时文件的大小，即已下载的大小
    
    fileInfo.isFirstReceived=YES;
    NSFileManager *fileManager=[NSFileManager defaultManager];
    NSData *fileData=[fileManager contentsAtPath:fileInfo.tempPath];
    NSInteger receivedDataLength=[fileData length];
    fileInfo.fileReceivedSize=[NSString stringWithFormat:@"%ld",(long)receivedDataLength];
    NSLog(@"fileInfo.tempPath == %@",fileInfo.tempPath);
    NSLog(@"start down::已经下载：%@",fileInfo.fileReceivedSize);
    // [self limitMaxLines];
    ASIHTTPRequest *request=[[ASIHTTPRequest alloc] initWithURL:[NSURL URLWithString:fileInfo.fileURL]];
    request.delegate=self;
    [request setDownloadDestinationPath:[fileInfo targetPath]];
    [request setTemporaryFileDownloadPath:fileInfo.tempPath];
    [request setDownloadProgressDelegate:self];
    [request setNumberOfTimesToRetryOnTimeout:2];
    // [request setShouldContinueWhenAppEntersBackground:YES];
    //    [request setDownloadProgressDelegate:downCell.progress];//设置进度条的代理,这里由于下载是在AppDelegate里进行的全局下载，所以没有使用自带的进度条委托，这里自己设置了一个委托，用于更新UI
    [request setAllowResumeForFileDownloads:YES];//支持断点续传
    
    
    [request setUserInfo:[NSDictionary dictionaryWithObject:fileInfo forKey:@"File"]];//设置上下文的文件基本信息
    [request setTimeOutSeconds:30.0f];
    if (isBeginDown) {
        [request startAsynchronous];
    }
    
    //如果文件重复下载或暂停、继续，则把队列中的请求删除，重新添加
    BOOL exit = NO;
    for(ASIHTTPRequest *tempRequest in self.downinglist)
    {
        //  NSLog(@"!!!!---::%@",[tempRequest.url absoluteString]);
        if([[[tempRequest.url absoluteString]lastPathComponent] isEqualToString:[fileInfo.fileURL lastPathComponent] ])
        {
            [self.downinglist replaceObjectAtIndex:[_downinglist indexOfObject:tempRequest] withObject:request ];
            
            exit = YES;
            break;
        }
    }
  
    if (!exit) {
        
        [self.downinglist addObject:request];
        NSLog(@"EXIT!!!!---::%@",[request.url absoluteString]);
    }
//    [self.downloadDelegate updateCellProgress:request];
    
}

- (ASIHTTPRequest *) getRequestByVideoUrl:(NSString*)videoName{
    for (ASIHTTPRequest *request in self.downinglist) {
        FileModel *fileInfo = (FileModel*)[request.userInfo objectForKey:@"File"];
        if ([fileInfo.fileURL isEqualToString:videoName]) {
            return request;
        }
    }
    
    return nil;
}
-(void)resumeRequest:(ASIHTTPRequest *)request{
    NSInteger max = MAXLINES;
    FileModel *fileInfo =  [request.userInfo objectForKey:@"File"];
    NSInteger downingcount =0;
    NSInteger indexmax =-1;
    for (FileModel *file in _filelist) {
        if (file.isDownloading) {
            downingcount++;
            if (downingcount==max) {
                indexmax = [_filelist indexOfObject:file];
            }
        }
    }//此时下载中数目是否是最大，并获得最大时的位置Index
    if (downingcount==max) {
        FileModel *file  = [_filelist objectAtIndex:indexmax];
        if (file.isDownloading) {
            file.isDownloading = NO;
            file.willDownloading = YES;
        }
    }//中止一个进程使其进入等待
    
    for (FileModel *file in _filelist) {
        if ([file.fileName isEqualToString:fileInfo.fileName]) {
            file.isDownloading = YES;
            file.willDownloading = NO;
            file.error = NO;
        }
    }//重新开始此下载
//    [self startLoad];
    if([fileInfo.fileReceivedSize longLongValue] < [fileInfo.fileSize longLongValue]){
    [request startAsynchronous];
    }
}
-(void)stopRequest:(ASIHTTPRequest *)request{
    NSInteger max = MAXLINES;
//    if([request isExecuting])
//    {
        [request cancel];
//    }
    FileModel *fileInfo =  [request.userInfo objectForKey:@"File"];
    for (FileModel *file in _filelist) {
        if ([file.fileName isEqualToString:fileInfo.fileName]) {
            file.isDownloading = NO;
            file.willDownloading = NO;
            break;
        }
    }
    NSInteger downingcount =0;
    
    for (FileModel *file in _filelist) {
        if (file.isDownloading) {
            downingcount++;
        }
    }
    if (downingcount<max) {
        for (FileModel *file in _filelist) {
            if (!file.isDownloading&&file.willDownloading){
                file.isDownloading = YES;
                file.willDownloading = NO;
                break;
            }
        }
    }
}
- (void)deleteFileModel:(FileModel*)fileInfo{
    ASIHTTPRequest *req = nil;
    for (ASIHTTPRequest *request in _downinglist) {
        if ([[(FileModel*)[request.userInfo objectForKey:@"File"] fileName] isEqualToString:fileInfo.fileName]) {
            req = request;
            break;
        }
    }
    
    if (req != nil) {
        [req cancel];
        [_downinglist removeObject:req];
    }
    
    NSInteger delindex = -1;
    NSInteger delFinishIndex = -1;
    
    for (FileModel *file in _filelist) {
        if ([file.fileName isEqualToString:fileInfo.fileName]) {
            delindex = [_filelist indexOfObject:file];
            break;
        }
    }
    for (FileModel *file in _finishedList) {
        if ([file.fileName isEqualToString:fileInfo.fileName]) {
            delFinishIndex = [_finishedList indexOfObject:file];
            break;
        }
    }
    
    NSString *path = fileInfo.tempPath;
    if (delindex != -1) {
        [_filelist removeObjectAtIndex:delindex];
    }
    if (delFinishIndex != -1) {
        path = fileInfo.targetPath;
        [_finishedList removeObjectAtIndex:delFinishIndex];
        [self saveFinishedFile];
    }
    
    NSFileManager *fileManager=[NSFileManager defaultManager];
    NSError *error;
    
    NSString *configPath=[NSString stringWithFormat:@"%@.plist",path];
    [fileManager removeItemAtPath:path error:&error];
    [fileManager removeItemAtPath:configPath error:&error];
    self.count = (int)[_filelist count];
}

-(void)deleteRequest:(ASIHTTPRequest *)request{
    //先暂停,再删除
    [self stopRequest:request];
    [request cancel];
    [_downinglist removeObject:request];
    FileModel *fileInfo=(FileModel*)[request.userInfo objectForKey:@"File"];
    [self deleteFileModel:fileInfo];
}
-(void)clearAllFinished{
    [_finishedList removeAllObjects];
}
-(void)clearAllRquests{
    NSFileManager *fileManager=[NSFileManager defaultManager];
    NSError *error;
    for (ASIHTTPRequest *request in _downinglist) {
        if([request isExecuting])
            [request cancel];
        FileModel *fileInfo=(FileModel*)[request.userInfo objectForKey:@"File"];
        NSString *path=fileInfo.tempPath;;
        NSString *configPath=[NSString stringWithFormat:@"%@.plist",path];
        [fileManager removeItemAtPath:path error:&error];
        [fileManager removeItemAtPath:configPath error:&error];
        //  [self deleteImage:fileInfo];
        if(!error)
        {
            NSLog(@"%@",[error description]);
        }
        
    }
    [_downinglist removeAllObjects];
    [_filelist removeAllObjects];
}

- (FileModel *) getTargetVideoFileModel:(NSString *) path{
    return [self getDownloadingFile:path];
}

- (NSString *) getTempFile:(NSString *) courseId userId:(NSString *) userId moduleId:(NSString *) moduleId videoId:(NSString *) videoId{
    NSString * fileName = [NSString stringWithFormat:@"%@_%@_%@_%@.mp4.plist", courseId, userId, moduleId, videoId];
    //NSString *tempfilePath= [TEMPPATH stringByAppendingPathComponent:fileName];
    NSString *tempfilePath = [[AppUtilities appDocDir]stringByAppendingPathComponent:fileName];
    
    return tempfilePath;
}

-(FileModel *)getDownloadingFile:(NSString *)path{
    NSDictionary *dic = [NSDictionary dictionaryWithContentsOfFile:path];
    
    NSString *fileName = [dic objectForKey:@"filename"];
    NSString *courseId = [fileName componentsSeparatedByString:@"_"][0];
    FileModel *file = [[FileModel alloc]init];
    file.fileTitle = [dic objectForKey:@"title"];
    file.fileName = [dic objectForKey:@"filename"];
    file.fileType = [file.fileName pathExtension ];
    file.fileURL = [dic objectForKey:@"fileurl"];
    file.fileSize = [dic objectForKey:@"filesize"];
    file.fileReceivedSize= [dic objectForKey:@"filerecievesize"];
   // NSString*  path1= [CommonHelper getTargetPathWithBasepath:_basepath subpath:_TargetSubPath];
    NSString*  path1= [CommonHelper getTargetPathWithBasepath:nil subpath:_TargetSubPath];
    path1 = [path1 stringByAppendingPathComponent:file.fileName];
    file.targetPath = path1;
    NSString *tempfilePath= [TEMPPATH stringByAppendingPathComponent: file.fileName];
    file.tempPath = tempfilePath;
    file.time = [dic objectForKey:@"time"];
    file.fileimage = [dic objectForKey:@"fileimage"];
    file.isDownloading=NO;
    file.isDownloading = NO;
    file.willDownloading = NO;
    file.courseId = courseId;
    file.usrname = [dic objectForKey:@"userId"];

    file.error = NO;
    
    NSData *fileData=[[NSFileManager defaultManager ] contentsAtPath:file.tempPath];
    NSInteger receivedDataLength=[fileData length];
    file.fileReceivedSize=[NSString stringWithFormat:@"%ld",(long)receivedDataLength];
    return file;
}

-(FileModel *) getDownloadedFileFrom:(NSString *) filePath{
    NSDictionary *dic = [NSDictionary dictionaryWithContentsOfFile:filePath];
    
    NSString *fileName = [dic objectForKey:@"filename"];
    NSString *courseId = [fileName componentsSeparatedByString:@"_"][0];
    
    FileModel *file = [[FileModel alloc]init];
    
    file.fileTitle = [dic objectForKey:@"title"];
    file.fileName = [dic objectForKey:@"filename"];
    file.fileType = [file.fileName pathExtension ];
    file.fileURL = [dic objectForKey:@"fileurl"];
    file.fileSize = [dic objectForKey:@"filesize"];

    file.time = [dic objectForKey:@"time"];
    file.fileimage = [dic objectForKey:@"fileimage"];
    file.isDownloading=NO;
    file.willDownloading = NO;
    file.courseId = courseId;
    file.usrname = [dic objectForKey:@"userId"];
    file.error = NO;
    file.status = Finished;

    return file;
}

-(void)loadDownloadingFiles
{
    
    NSFileManager *fileManager=[NSFileManager defaultManager];
    NSError *error;
    NSArray *filesInTempDir =[fileManager contentsOfDirectoryAtPath:TEMPPATH error:&error];
    if (!error) {
        NSLog(@"%@",[error description]);
    }
    NSMutableArray *files = [[NSMutableArray alloc]init];
    for(NSString *file in filesInTempDir)
    {
        NSString *fileType = [file pathExtension];
        if([fileType isEqualToString:@"plist"])
            [files addObject:[self getDownloadingFile:[TEMPPATH stringByAppendingPathComponent:file]]];
    }
    
    NSArray* arr =  [self sortbyTime:(NSArray *)files];
//    NSArray* arr =  [self sortArrayById:(NSArray *)files];
    
    if (_filelist == nil) {
        _filelist = [[NSMutableArray alloc] init];
    }
    
    [_filelist addObjectsFromArray:arr];
}

-(void)loadFinishedfiles
{
    if (self.filelist == nil) {
        self.filelist = [[NSMutableArray alloc] init];
    }
    
    NSString *document = [NSHomeDirectory() stringByAppendingPathComponent:@"Documents"];
    //NSString *plistPath = [[document stringByAppendingPathComponent:self.basepath]stringByAppendingPathComponent:@"finishPlist.plist"];
    NSString *plistPath = [document stringByAppendingPathComponent:@"finishPlist.plist"];
    if ([[NSFileManager defaultManager] fileExistsAtPath:plistPath]) {
        NSMutableArray *finishedItems = [[NSMutableArray alloc]initWithContentsOfFile:plistPath];
      
        for (NSDictionary *dic in finishedItems) {
            FileModel *file = [[FileModel alloc]init];
            file.fileName = [dic objectForKey:@"filename"];
            file.fileType = [file.fileName pathExtension ];
            file.fileSize = [dic objectForKey:@"filesize"];
            file.targetPath = [dic objectForKey:@"fileurl"];
            file.time = [dic objectForKey:@"time"];
            file.fileReceivedSize = [dic objectForKey:@"filerecievesize"];
            file.fileTitle = [dic objectForKey:@"title"];
            file.usrname = [dic objectForKey:@"userId"];
            file.courseId = [dic objectForKey:@"courseID"];
            file.status = Finished;
            
            [self.filelist addObject:file];
        }
    }
}

-(void)saveFinishedFile{
    if (self.filelist == nil) {
        return;
    }
    NSMutableArray *finishedinfo = [[NSMutableArray alloc]init];
    
    for (FileModel *fileinfo in self.filelist) {
        if (fileinfo.status == Finished) {
            NSDictionary *filedic = [NSDictionary dictionaryWithObjectsAndKeys:
                                     fileinfo.fileName,@"filename",
                                     fileinfo.targetPath,@"fileurl",
                                     fileinfo.courseId,@"courseID",
                                     fileinfo.fileTitle,@"title",
                                    
                                     _TargetSubPath,@"tarpath" ,
                                     fileinfo.fileSize,@"filesize",
                                     fileinfo.fileReceivedSize,@"filerecievesize",
                                     
                                     fileinfo.time, @"time",
                                     fileinfo.usrname,@"userId",
                                     nil];
            [finishedinfo addObject:filedic];
        }
        
    }
    NSString *document = [NSHomeDirectory() stringByAppendingPathComponent:@"Documents"];
    //NSString *plistPath = [[document stringByAppendingPathComponent:self.basepath]stringByAppendingPathComponent:@"finishPlist.plist"];
    NSString *plistPath = [document stringByAppendingPathComponent:@"finishPlist.plist"];

    NSLog(@"%@",plistPath);
    [finishedinfo writeToFile:plistPath atomically:YES];
    if (![finishedinfo writeToFile:plistPath atomically:YES]) {
        NSLog(@"write plist fail");
    }
    //[self loadFinishedfiles];
}

- (BOOL) isVideoExisted:(NSString *) courseId userId:(NSString *) userId moduleId:(NSString *) moduleId videoId:(NSString *) videoId{
    NSString *videoPath = [self getVideoPath:courseId userId:userId moduleId:moduleId videoId:videoId];
    NSFileManager *fileManager = [NSFileManager defaultManager];
    
    BOOL isExisted = [fileManager fileExistsAtPath:videoPath isDirectory:NO];
    
    return isExisted;
}

- (BOOL) isVideoDownloading:(NSString *) courseId userId:(NSString *) userId moduleId:(NSString *) moduleId videoId:(NSString *) videoId
{
    NSString * fileName = [NSString stringWithFormat:@"%@_%@_%@_%@.mp4", courseId, userId, moduleId, videoId];
    NSString *tempfilePath= [TEMPPATH stringByAppendingPathComponent:fileName]  ;
    tempfilePath =[tempfilePath stringByAppendingString:@".plist"];
    NSFileManager *fileManager = [NSFileManager defaultManager];
    
    BOOL isExisted = [fileManager fileExistsAtPath:tempfilePath isDirectory:NO];
    
    return isExisted;
}

- (NSString *) getVideoPath:(NSString *) courseId userId:(NSString *) userId moduleId:(NSString *) moduleId videoId:(NSString *) videoId{
    NSArray* paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString* documentsDirectory = [paths objectAtIndex:0];
    NSString *videosDir = [documentsDirectory stringByAppendingPathComponent:@"DownLoad/mp4"];
    NSString *videoPath = [videosDir stringByAppendingPathComponent:[NSString stringWithFormat:@"%@_%@_%@_%@.mp4", courseId, userId, moduleId, videoId]];

    return videoPath;
}

-(void)deleteFinishFile:(FileModel *)selectFile{
    [_finishedList removeObject:selectFile];
    
}

#pragma mark -- 入口 --
-(void)downFileUrl:(NSString*)url
          filename:(NSString*)name
        filetarget:(NSString *)path
         fileimage:(NSString *)image
         fileTitle:(NSString *)title
          courseID:(NSString *)courseId
          fileId:(NSString *) fileId
         showAlert:(BOOL)showAlert

{
    
    //因为是重新下载，则说明肯定该文件已经被下载完，或者有临时文件正在留着，所以检查一下这两个地方，存在则删除掉
    self.TargetSubPath = path;
//    NSString *fileSize = nil;
    if (_fileInfo!=nil) {
//        fileSize = _fileInfo.fileSize;
        _fileInfo = nil;
    }
    _fileInfo = [[FileModel alloc]init];
    _fileInfo.fileName = name;
    _fileInfo.fileURL = url;
    _fileInfo.usrname = image;//这里暂时用image属性存储user_id
    _fileInfo.fileTitle = title;
    _fileInfo.courseId = courseId;
    _fileInfo.fileID = fileId;
    
//    if (fileSize) {
//        _fileInfo.fileSize = fileSize;
//    }
    
    NSDate *myDate = [NSDate date];
    _fileInfo.time = [CommonHelper dateToString:myDate];
    _fileInfo.fileType=[name pathExtension];
    //path= [CommonHelper getTargetPathWithBasepath:_basepath subpath:path];
    path= [CommonHelper getTargetPathWithBasepath:nil subpath:path];
    path = [path stringByAppendingPathComponent:name];
    _fileInfo.targetPath = path ;
    _fileInfo.isDownloading=YES;
    _fileInfo.willDownloading = YES;
    _fileInfo.error = NO;
    _fileInfo.isFirstReceived = YES;
    NSString *tempfilePath= [TEMPPATH stringByAppendingPathComponent: _fileInfo.fileName]  ;
    _fileInfo.tempPath = tempfilePath;
    _fileInfo.status = Downloading;
    
    if([CommonHelper isExistFile: _fileInfo.targetPath]) {//已经下载过一次该音乐
        if (showAlert) {
            UIAlertView *alert=[[UIAlertView alloc] initWithTitle:@"温馨提示" message:@"该文件已下载，是否重新下载？" delegate:self cancelButtonTitle:@"取消" otherButtonTitles:@"确定", nil];
            [alert show];
            return;
        }
    }
    //    //存在于临时文件夹里
    tempfilePath =[tempfilePath stringByAppendingString:@".plist"];
    if([CommonHelper isExistFile:tempfilePath]) {
        if (showAlert) {
            UIAlertView *alert=[[UIAlertView alloc] initWithTitle:@"温馨提示" message:@"该文件已经在下载列表中了，是否重新下载？" delegate:self cancelButtonTitle:@"取消" otherButtonTitles:@"确定", nil];
            [alert show];
            return;
        }
    }
    
    // [self saveImage:_fileInfo :image];
    //若不存在文件和临时文件，则是新的下载
    
    if (_filelist == nil) {
        _filelist = [[NSMutableArray alloc] init];
    }
    
    [self.filelist addObject:_fileInfo];
    [self beginRequest:_fileInfo isBeginDown:YES ];
    
    [self updateNumbers];
//    [self startLoad];
    if(self.VCdelegate!=nil && [self.VCdelegate respondsToSelector:@selector(allowNextRequest)]) {
        [self.VCdelegate allowNextRequest];
    } else {
        if (showAlert) {
            UIAlertView *alert=[[UIAlertView alloc] initWithTitle:@"温馨提示" message:@"该文件成功添加到下载队列" delegate:self cancelButtonTitle:@"确定" otherButtonTitles:nil, nil];
            [alert show];
        }
    }
    return;
}

- (void)updateNumbers
{
    NSMutableDictionary * numbersForCourse = [[NSMutableDictionary alloc] init];
    for (FileModel* file in self.filelist) {
        int finishedTaskNumber = [self getNumberOfFinishedTask:file.courseId];
        int downloadingTaskNumber = [self getNumberOfDownloadingTask:file.courseId];
        NSMutableDictionary *numbers = [[NSMutableDictionary alloc] init];
        
        [numbers setValue:[NSString stringWithFormat:@"%d", finishedTaskNumber] forKey:@"finished"];
        [numbers setValue:[NSString stringWithFormat:@"%d", downloadingTaskNumber] forKey:@"downloading"];
        
        [numbersForCourse setObject:numbers forKey:file.courseId];
    }
//    if ([self.downloadDelegate performSelector:@selector(updateNumbersOfDownloading:)]) {
//        [self.downloadDelegate updateNumbersOfDownloading:numbersForCourse];
//    }
    [self.downloadDelegate updateNumbersOfDownloading:numbersForCourse];
}

-(void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if(buttonIndex==1)//确定按钮
    {
        
        NSFileManager *fileManager=[NSFileManager defaultManager];
        NSError *error;
        NSInteger delindex =-1;
        if([CommonHelper isExistFile:_fileInfo.targetPath])//已经下载过一次该音乐
        {
            if ([fileManager removeItemAtPath:_fileInfo.targetPath error:&error]!=YES) {
                
                NSLog(@"删除文件出错:%@",[error localizedDescription]);
            }
            
            
        }else{
            for(ASIHTTPRequest *request in self.downinglist)
            {
                FileModel *fileModel=[request.userInfo objectForKey:@"File"];
                if([fileModel.fileName isEqualToString:_fileInfo.fileName])
                {
                    //[self.downinglist removeObject:request];
                    if ([request isExecuting]) {
                        [request cancel];
                    }
                    delindex = [_downinglist indexOfObject:request];
                    //  [self deleteImage:fileModel];
                    break;
                }
            }
            
//            @try {
//                [_downinglist removeObjectAtIndex:delindex];
//            }
//            @catch (NSException *exception) {
//                NSLog(@"[_downinglist removeObjectAtIndex:delindex] exception: %@", exception.reason);
//            }
//            @finally {
//                
//            }
            
            
            for (FileModel *file in _filelist) {
                if ([file.fileName isEqualToString:_fileInfo.fileName]) {
                    delindex = [_filelist indexOfObject:file];
                    break;
                }
            }
//            [_filelist removeObjectAtIndex:delindex];
            //存在于临时文件夹里
            NSString * tempfilePath =[_fileInfo.tempPath stringByAppendingString:@".plist"];
            if([CommonHelper isExistFile:tempfilePath])
            {
                if ([fileManager removeItemAtPath:tempfilePath error:&error]!=YES) {
                    NSLog(@"删除临时文件出错:%@",[error localizedDescription]);
                }
                
            }
            if([CommonHelper isExistFile:_fileInfo.tempPath])
            {
                if ([fileManager removeItemAtPath:_fileInfo.tempPath error:&error]!=YES) {
                    NSLog(@"删除临时文件出错:%@",[error localizedDescription]);
                }
            }
            
        }
        //    [self saveImage:_fileInfo :_fileImage];
        
        self.fileInfo.fileReceivedSize=[CommonHelper getFileSizeString:@"0"];
        [_filelist addObject:_fileInfo];
        // [self beginRequest:self.fileInfo isBeginDown:YES ];
//        [self startLoad];
        //        UIAlertView *alert=[[UIAlertView alloc] initWithTitle:@"温馨提示" message:@"该文件已经添加到您的下载列表中了！" delegate:self cancelButtonTitle:@"确定" otherButtonTitles:nil, nil];
        //        [alert show];
        //        [alert release];
        
    }
    if(self.VCdelegate!=nil && [self.VCdelegate respondsToSelector:@selector(allowNextRequest)])
    {
        [self.VCdelegate allowNextRequest];
    }
}

- (NSDictionary *) getDownloadInfoByCourses{
    
    NSMutableDictionary *coursesDictionary = [[NSMutableDictionary alloc] init];
    for (FileModel *aFile in self.filelist) {
        
        NSArray *fields = [aFile.fileName componentsSeparatedByString:@"_"];
        NSString *lastField = fields[fields.count - 1];
        NSArray *fields2 = [lastField componentsSeparatedByString:@"."];
        NSString *videoId = fields2[0];
        
        NSMutableArray *videoIds = [NSMutableArray arrayWithArray:[coursesDictionary objectForKey:aFile.courseId]];
        
        BOOL isCourseAlreadyContainedInDictionary = (videoIds != nil && [coursesDictionary objectForKey:aFile.courseId] != nil);
        if (isCourseAlreadyContainedInDictionary) {
            //如果course已存在，则将videoId添加至数组中
            [videoIds addObject:videoId];
            [coursesDictionary setObject:videoIds forKey:aFile.courseId];
        } else {
            //如果course不存在，创建数组存videoId，并将该数组作为值保存
            NSMutableArray *items = [[NSMutableArray alloc] initWithObjects:videoId, nil];
            [coursesDictionary setObject:items forKey:aFile.courseId];
        }
    }
    
    return coursesDictionary;
}

- (BOOL) containsText:(NSString *) text inArray:(NSArray *) array{
    for (NSString *aString in array) {
        if ([aString isEqualToString:text]) {
            return YES;
        }
    }
    
    return NO;
}


-(void)startLoad{
    NSInteger num = 0;
    NSInteger max = MAXLINES;
    for (FileModel *file in _filelist) {
        if (!file.error) {
            if (file.isDownloading==YES) {
                file.willDownloading = NO;
                
                if (num>max) {
                    file.isDownloading = NO;
                    file.willDownloading = YES;
                }else
                    num++;
            }
        }
    }
    if (num<max) {
        for (FileModel *file in _filelist) {
            if (!file.error) {
                if (!file.isDownloading&&file.willDownloading) {
                    num++;
                    if (num>max) {
                        break;
                    }
                    file.isDownloading = YES;
                    file.willDownloading = NO;
                }
            }
        }
        
    }
    for (FileModel *file in _filelist) {
        if (!file.error) {
            if (file.isDownloading==YES) {
                [self beginRequest:file isBeginDown:YES];
            }else
                [self beginRequest:file isBeginDown:NO];
        }
    }
    self.count = (int)[_filelist count];
}

#pragma mark Custom Method


- (int) getNumberOfDownloadingTask:(NSString *) courseId{
    
    NSUInteger downloadingTaskcount = self.filelist.count;
    int counter = 0;
    for (int i = 0; i < downloadingTaskcount; i++) {
        FileModel *aFile = self.filelist[i];
        
        BOOL found = [aFile.courseId intValue] == [courseId intValue];
        BOOL inProgress = (aFile.status == Wait || aFile.status == Ready || aFile.status == Cancelled || aFile.status == Downloading);
        if (found && inProgress) {
            counter++;
        }
    }
    
    return counter;
}

- (int) getNumberOfFinishedTask:(NSString *) courseId{
    
    NSUInteger downloadingTaskcount = self.filelist.count;
    int counter = 0;
    for (int i = 0; i < downloadingTaskcount; i++) {
        FileModel *aFile = self.filelist[i];
        
        BOOL found = [aFile.courseId intValue] == [courseId intValue];
        BOOL isFinished = (aFile.status == Finished);
        if (found && isFinished) {
            counter++;
        }
    }
    
    return counter;
}

- (int) getNumberOfTask:(NSString *) courseId{
    return ([self getNumberOfDownloadingTask:courseId]) + ([self getNumberOfFinishedTask:courseId]);
}

- (void) removePlistFile{
    NSFileManager *manager = [NSFileManager defaultManager];
    
    NSString *document = [NSHomeDirectory() stringByAppendingPathComponent:@"Documents"];
    //NSString *plistPath = [[document stringByAppendingPathComponent:self.basepath]stringByAppendingPathComponent:@"finishPlist.plist"];
    NSString *plistPath = [document stringByAppendingPathComponent:@"finishPlist.plist"];
    NSError *error = nil;
    BOOL removed = [manager removeItemAtPath:plistPath error:&error];
    if (!removed) {
        NSLog(@"plist not removed success, reason:%@", error);
    } else{
        NSLog(@"plist removed");
    }
    
}
//
//- (DownloadStatus) getCourseStatusVia:(NSString *) courseId itemId:(NSString *) itemId{
//    return Downloading;
//}

//- (void) postNotificationTo:(NSString *) itemId withProgress:(float) progress progressText:(NSString *) progressText {
//    NSDictionary *dict = [[NSDictionary alloc] initWithObjectsAndKeys:
//            [NSNumber numberWithFloat:progress], @"Progress",
//                                    progressText, @"ProgressText", nil];
//    NSString *notifName = [NSString stringWithFormat:@"DownloadProgressDidChange_%@", itemId];
//    
//    [[NSNotificationCenter defaultCenter] postNotificationName:notifName object:self userInfo:dict];
//}
////
////// KKBDownloadRecord
//- (void) addObserver:(NSString *) itemId{
//    NSString *notifName = [NSString stringWithFormat:@"DownloadProgressDidChange_%@", itemId];
//    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(handleNotification:) name:notifName object:nil];
//}
//
//- (void) postNotificationTo:(NSString *) courseId withProgresses:(NSArray *) progressesInfo {
////    NSDictionary *dict = [[NSDictionary alloc] initWithObjectsAndKeys:
////                                [NSNumber numberWithFloat:progress], @"Progress",
////                                                        progressText, @"ProgressText", nil];
//    
////    NSDictionary *dict = [[NSDictionary alloc] init]
//    NSString *notifName = [NSString stringWithFormat:@"DownloadProgressDidChange_%@", courseId];
//    
//    [[NSNotificationCenter defaultCenter] postNotificationName:notifName object:self userInfo:dict];
//}


#pragma mark -- init methods --
-(id)initWithBasepath:(NSString *)basepath
        TargetPathArr:(NSArray *)targetpaths{
    //self.basepath = basepath;
    _targetPathArray = [[NSMutableArray alloc]initWithArray:targetpaths];
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    NSString * Max= [userDefaults valueForKey:@"kMaxRequestCount"];
    if (Max==nil) {
        [userDefaults setObject:@"2" forKey:@"kMaxRequestCount"];
        Max =@"2";
    }
    [userDefaults synchronize];
    maxcount = [Max integerValue];
    _filelist = [[NSMutableArray alloc]init];
    _downinglist=[[NSMutableArray alloc] init];
    _finishedList = [[NSMutableArray alloc] init];
    self.isFistLoadSound=YES;
    return  [self init];
}

- (id)init
{
	self = [super init];
	if (self != nil) {
        self.count = 0;
        
            [self loadFinishedfiles];
            [self loadDownloadingFiles];
            self.downManageFirstLoad = YES;
        
            [[NSNotificationCenter defaultCenter] addObserver:self
                                                     selector:@selector(pause:)
                                                         name:@"PauseDownload"
                                                       object:nil];
            
        
        
    }
	return self;
}
-(void)cleanLastInfo{
    for (ASIHTTPRequest *request in _downinglist) {
        if([request isExecuting])
            [request cancel];
    }
    [self saveFinishedFile];
    [_downinglist removeAllObjects];
    [_finishedList removeAllObjects];
    [_filelist removeAllObjects];
    
}
+(FilesDownManage *) sharedFilesDownManageWithBasepath:(NSString *)basepath
                                         TargetPathArr:(NSArray *)targetpaths{
//    @synchronized(self){
//        if (sharedFilesDownManage == nil) {
//            sharedFilesDownManage = [[self alloc] initWithBasepath:basepath TargetPathArr:targetpaths];
//        }
//    }
//    if (![sharedFilesDownManage.basepath isEqualToString:basepath]) {
//        
//        [sharedFilesDownManage cleanLastInfo];
//        sharedFilesDownManage.basepath = basepath;
//        [sharedFilesDownManage loadTempfiles];
//        [sharedFilesDownManage loadFinishedfiles];
//    }
//    sharedFilesDownManage.basepath = basepath;
//    sharedFilesDownManage.targetPathArray =[NSMutableArray arrayWithArray:targetpaths];
//    return  sharedFilesDownManage;
    return [FilesDownManage sharedInstance];
}

+ (FilesDownManage *) sharedInstance
{
    @synchronized(self){
        if (sharedFilesDownManage == nil) {
            sharedFilesDownManage = [[self alloc] init];
            sharedFilesDownManage.filelist = [[NSMutableArray alloc] init];
            sharedFilesDownManage.downinglist = [[NSMutableArray alloc] init];
            
            [sharedFilesDownManage loadDownloadingFiles];
            [sharedFilesDownManage loadFinishedfiles];
        }
    }
    return  sharedFilesDownManage;
}
+(id) allocWithZone:(NSZone *)zone{
    @synchronized(self){
        if (sharedFilesDownManage == nil) {
            sharedFilesDownManage = [super allocWithZone:zone];
            return  sharedFilesDownManage;
        }
    }
    return nil;
}
#pragma mark -- ASIHttpRequest回调委托 --

//出错了，如果是等待超时，则继续下载
-(void)requestFailed:(ASIHTTPRequest *)request
{
    NSError *error=[request error];
    NSLog(@"ASIHttpRequest出错了!%@",error);
    if (error.code==4) {
        return;
    }
    if ([request isExecuting]) {
        [request cancel];
    }
    FileModel *fileInfo =  [request.userInfo objectForKey:@"File"];
    fileInfo.isDownloading = NO;
    fileInfo.willDownloading = NO;
    fileInfo.error = YES;
    for (FileModel *file in _filelist) {
        if ([file.fileName isEqualToString:fileInfo.fileName]) {
            file.isDownloading = NO;
            file.willDownloading = NO;
            file.error = YES;
        }
    }
    
    [self updateNumbers];
    
    fileInfo.status = Failed;
//    [self.downloadDelegate updateCellProgress:request];
}

-(void)requestStarted:(ASIHTTPRequest *)request
{
    NSLog(@"开始了!");
//    FileModel *fileInfo=[request.userInfo objectForKey:@"File"];
//     fileInfo.status =Downloading;
    
    
}

-(void)request:(ASIHTTPRequest *)request didReceiveResponseHeaders:(NSDictionary *)responseHeaders
{
    NSLog(@"收到回复了！");
    
    FileModel *fileInfo=[request.userInfo objectForKey:@"File"];
    
    NSString *len = [responseHeaders objectForKey:@"Content-Length"];//
    // NSLog(@"%@,%@,%@",fileInfo.fileSize,fileInfo.fileReceivedSize,len);
    //这个信息头，首次收到的为总大小，那么后来续传时收到的大小为肯定小于或等于首次的值，则忽略
    if ([fileInfo.fileSize longLongValue]> [len longLongValue])
    {
        return;
    }
    if (fileInfo.fileSize ==0) {
        long long fileSizeTotal = [fileInfo.fileReceivedSize longLongValue]+request.contentLength;
        fileInfo.fileSize = [NSString stringWithFormat:@"%lld", fileSizeTotal];
    }
    
    
    [self saveDownloadFile:fileInfo];
    
}

-(void)request:(ASIHTTPRequest *)request didReceiveBytes:(long long)bytes
{
    FileModel *fileInfo=[request.userInfo objectForKey:@"File"];
    
    if (fileInfo.isFirstReceived) {
        fileInfo.isFirstReceived=NO;
        fileInfo.fileReceivedSize =[NSString stringWithFormat:@"%lld",bytes];
    }
    else if(!fileInfo.isFirstReceived)
    {
        
        fileInfo.fileReceivedSize=[NSString stringWithFormat:@"%lld",[fileInfo.fileReceivedSize longLongValue]+bytes];
    }
    
    [[NSNotificationCenter defaultCenter] postNotificationName:@"CellDownloadProgress"
                                                        object:nil
                                                      userInfo:@{@"request": request}];
    
    if([self.downloadDelegate respondsToSelector:@selector(updateCellProgress:)])
    {
        [self.downloadDelegate updateCellProgress:request];
    }
    
}

//将正在下载的文件请求ASIHttpRequest从队列里移除，并将其配置文件删除掉,然后向已下载列表里添加该文件对象
-(void)requestFinished:(ASIHTTPRequest *)request
{
    [self playDownloadSound];
    FileModel *fileInfo = (FileModel *)[request.userInfo objectForKey:@"File"];
    
    [_finishedList addObject:fileInfo];
    NSString *configPath=[fileInfo.tempPath stringByAppendingString:@".plist"];
    NSFileManager *fileManager=[NSFileManager defaultManager];
    NSError *error;
    if([fileManager fileExistsAtPath:configPath])//如果存在临时文件的配置文件
    {
        [fileManager removeItemAtPath:configPath error:&error];
        if(!error)
        {
            NSLog(@"%@",[error description]);
        }
    }
    
    fileInfo.status = Finished;
    
//    [_filelist removeObject:fileInfo];
    [_downinglist removeObject:request];
    
    
    
    [self updateNumbers];
    
    
    [self saveFinishedFile];
//    [self startLoad];
    
    if([self.downloadDelegate respondsToSelector:@selector(finishedDownload:)])
    {
        [self.downloadDelegate finishedDownload:request];
    }
}
//-(BOOL) respondsToSelector:(SEL)aSelector {
//    printf("SELECTOR: %s\n", [NSStringFromSelector(aSelector) UTF8String]);
//    return [super respondsToSelector:aSelector];
//}

-(void)restartAllRquests{
    
    for (ASIHTTPRequest *request in _downinglist) {
        if([request isExecuting])
            [request cancel];
    }
    
    [self startLoad];
}

-(void)restartRequest:(ASIHTTPRequest *) request{
//    
//    if([request isCancelled]){
//        [request start];
//        
//        [request startAsynchronous];
//    }
//    
//    [self startLoad];
}

- (void)pause:(NSNotification*)notification{
    /*
     [[NSNotificationCenter defaultCenter] postNotificationName:@"PauseDownload"
     object:nil
     userInfo:@{@"fileModel": _model,
     @"pause": @(_playButton.selected)}];
     */
    FileModel *model = [notification.userInfo objectForKey:@"fileModel"];
    BOOL pause = [[notification.userInfo objectForKey:@"pause"] boolValue];
    
    __block BOOL foundReq = NO;
    [_downinglist enumerateObjectsUsingBlock:^(ASIHTTPRequest *req, NSUInteger idx, BOOL *stop) {
        FileModel *fileInfo=(FileModel *)[req.userInfo objectForKey:@"File"];
        if ([fileInfo.fileName isEqualToString:model.fileName]) {
            if (pause) {
                model.status = Cancelled;
                [req cancel];
            } else {
                [self beginRequest:fileInfo isBeginDown:YES];
                model.status = Downloading;
            }
            foundReq = YES;
            *stop = YES;
        }
    }];
    
    [_filelist enumerateObjectsUsingBlock:^(FileModel *fileInfo, NSUInteger idx, BOOL *stop) {
        if ([fileInfo.fileName isEqualToString:model.fileName]) {
            if (pause) {
                model.status = Cancelled;
            } else {
                [self beginRequest:fileInfo isBeginDown:YES];
                model.status = Downloading;
            }
            foundReq = YES;
            *stop = YES;
        }
    }];
    
    if ( !foundReq && !pause) {
        [self downFileUrl:model.fileURL
                 filename:model.fileName
               filetarget:@"mp4"
                fileimage:nil
                fileTitle:model.fileTitle
                 courseID:model.courseId
                   fileId:model.fileID
                showAlert:NO];
    }
}
@end
