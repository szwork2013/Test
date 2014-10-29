// DO NOT EDIT. This file is machine-generated and constantly overwritten.
// Make changes to KKBDownloadVideo.h instead.

#import <CoreData/CoreData.h>


extern const struct KKBDownloadVideoAttributes {
	__unsafe_unretained NSString *downloadPath;
	__unsafe_unretained NSString *position;
	__unsafe_unretained NSString *progress;
	__unsafe_unretained NSString *status;
	__unsafe_unretained NSString *tmpPath;
	__unsafe_unretained NSString *totalBytesFile;
	__unsafe_unretained NSString *totalBytesReaded;
	__unsafe_unretained NSString *videoID;
	__unsafe_unretained NSString *videoTitle;
	__unsafe_unretained NSString *videoURL;
} KKBDownloadVideoAttributes;

extern const struct KKBDownloadVideoRelationships {
	__unsafe_unretained NSString *whichClass;
} KKBDownloadVideoRelationships;

extern const struct KKBDownloadVideoFetchedProperties {
} KKBDownloadVideoFetchedProperties;

@class KKBDownloadClass;












@interface KKBDownloadVideoID : NSManagedObjectID {}
@end

@interface _KKBDownloadVideo : NSManagedObject {}
+ (id)insertInManagedObjectContext:(NSManagedObjectContext*)moc_;
+ (NSString*)entityName;
+ (NSEntityDescription*)entityInManagedObjectContext:(NSManagedObjectContext*)moc_;
- (KKBDownloadVideoID*)objectID;





@property (nonatomic, strong) NSString* downloadPath;



//- (BOOL)validateDownloadPath:(id*)value_ error:(NSError**)error_;





@property (nonatomic, strong) NSNumber* position;



@property int32_t positionValue;
- (int32_t)positionValue;
- (void)setPositionValue:(int32_t)value_;

//- (BOOL)validatePosition:(id*)value_ error:(NSError**)error_;





@property (nonatomic, strong) NSNumber* progress;



@property float progressValue;
- (float)progressValue;
- (void)setProgressValue:(float)value_;

//- (BOOL)validateProgress:(id*)value_ error:(NSError**)error_;





@property (nonatomic, strong) NSNumber* status;



@property int16_t statusValue;
- (int16_t)statusValue;
- (void)setStatusValue:(int16_t)value_;

//- (BOOL)validateStatus:(id*)value_ error:(NSError**)error_;





@property (nonatomic, strong) NSString* tmpPath;



//- (BOOL)validateTmpPath:(id*)value_ error:(NSError**)error_;





@property (nonatomic, strong) NSNumber* totalBytesFile;



@property int64_t totalBytesFileValue;
- (int64_t)totalBytesFileValue;
- (void)setTotalBytesFileValue:(int64_t)value_;

//- (BOOL)validateTotalBytesFile:(id*)value_ error:(NSError**)error_;





@property (nonatomic, strong) NSNumber* totalBytesReaded;



@property int64_t totalBytesReadedValue;
- (int64_t)totalBytesReadedValue;
- (void)setTotalBytesReadedValue:(int64_t)value_;

//- (BOOL)validateTotalBytesReaded:(id*)value_ error:(NSError**)error_;





@property (nonatomic, strong) NSNumber* videoID;



@property int32_t videoIDValue;
- (int32_t)videoIDValue;
- (void)setVideoIDValue:(int32_t)value_;

//- (BOOL)validateVideoID:(id*)value_ error:(NSError**)error_;





@property (nonatomic, strong) NSString* videoTitle;



//- (BOOL)validateVideoTitle:(id*)value_ error:(NSError**)error_;





@property (nonatomic, strong) NSString* videoURL;



//- (BOOL)validateVideoURL:(id*)value_ error:(NSError**)error_;





@property (nonatomic, strong) KKBDownloadClass *whichClass;

//- (BOOL)validateWhichClass:(id*)value_ error:(NSError**)error_;





@end

@interface _KKBDownloadVideo (CoreDataGeneratedAccessors)

@end

@interface _KKBDownloadVideo (CoreDataGeneratedPrimitiveAccessors)


- (NSString*)primitiveDownloadPath;
- (void)setPrimitiveDownloadPath:(NSString*)value;




- (NSNumber*)primitivePosition;
- (void)setPrimitivePosition:(NSNumber*)value;

- (int32_t)primitivePositionValue;
- (void)setPrimitivePositionValue:(int32_t)value_;




- (NSNumber*)primitiveProgress;
- (void)setPrimitiveProgress:(NSNumber*)value;

- (float)primitiveProgressValue;
- (void)setPrimitiveProgressValue:(float)value_;




- (NSNumber*)primitiveStatus;
- (void)setPrimitiveStatus:(NSNumber*)value;

- (int16_t)primitiveStatusValue;
- (void)setPrimitiveStatusValue:(int16_t)value_;




- (NSString*)primitiveTmpPath;
- (void)setPrimitiveTmpPath:(NSString*)value;




- (NSNumber*)primitiveTotalBytesFile;
- (void)setPrimitiveTotalBytesFile:(NSNumber*)value;

- (int64_t)primitiveTotalBytesFileValue;
- (void)setPrimitiveTotalBytesFileValue:(int64_t)value_;




- (NSNumber*)primitiveTotalBytesReaded;
- (void)setPrimitiveTotalBytesReaded:(NSNumber*)value;

- (int64_t)primitiveTotalBytesReadedValue;
- (void)setPrimitiveTotalBytesReadedValue:(int64_t)value_;




- (NSNumber*)primitiveVideoID;
- (void)setPrimitiveVideoID:(NSNumber*)value;

- (int32_t)primitiveVideoIDValue;
- (void)setPrimitiveVideoIDValue:(int32_t)value_;




- (NSString*)primitiveVideoTitle;
- (void)setPrimitiveVideoTitle:(NSString*)value;




- (NSString*)primitiveVideoURL;
- (void)setPrimitiveVideoURL:(NSString*)value;





- (KKBDownloadClass*)primitiveWhichClass;
- (void)setPrimitiveWhichClass:(KKBDownloadClass*)value;


@end
