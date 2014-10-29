// DO NOT EDIT. This file is machine-generated and constantly overwritten.
// Make changes to KKBDownloadClass.h instead.

#import <CoreData/CoreData.h>


extern const struct KKBDownloadClassAttributes {
	__unsafe_unretained NSString *classID;
	__unsafe_unretained NSString *classType;
	__unsafe_unretained NSString *name;
} KKBDownloadClassAttributes;

extern const struct KKBDownloadClassRelationships {
	__unsafe_unretained NSString *videos;
} KKBDownloadClassRelationships;

extern const struct KKBDownloadClassFetchedProperties {
} KKBDownloadClassFetchedProperties;

@class KKBDownloadVideo;





@interface KKBDownloadClassID : NSManagedObjectID {}
@end

@interface _KKBDownloadClass : NSManagedObject {}
+ (id)insertInManagedObjectContext:(NSManagedObjectContext*)moc_;
+ (NSString*)entityName;
+ (NSEntityDescription*)entityInManagedObjectContext:(NSManagedObjectContext*)moc_;
- (KKBDownloadClassID*)objectID;





@property (nonatomic, strong) NSNumber* classID;



@property int32_t classIDValue;
- (int32_t)classIDValue;
- (void)setClassIDValue:(int32_t)value_;

//- (BOOL)validateClassID:(id*)value_ error:(NSError**)error_;





@property (nonatomic, strong) NSNumber* classType;



@property int16_t classTypeValue;
- (int16_t)classTypeValue;
- (void)setClassTypeValue:(int16_t)value_;

//- (BOOL)validateClassType:(id*)value_ error:(NSError**)error_;





@property (nonatomic, strong) NSString* name;



//- (BOOL)validateName:(id*)value_ error:(NSError**)error_;





@property (nonatomic, strong) NSSet *videos;

- (NSMutableSet*)videosSet;





@end

@interface _KKBDownloadClass (CoreDataGeneratedAccessors)

- (void)addVideos:(NSSet*)value_;
- (void)removeVideos:(NSSet*)value_;
- (void)addVideosObject:(KKBDownloadVideo*)value_;
- (void)removeVideosObject:(KKBDownloadVideo*)value_;

@end

@interface _KKBDownloadClass (CoreDataGeneratedPrimitiveAccessors)


- (NSNumber*)primitiveClassID;
- (void)setPrimitiveClassID:(NSNumber*)value;

- (int32_t)primitiveClassIDValue;
- (void)setPrimitiveClassIDValue:(int32_t)value_;




- (NSNumber*)primitiveClassType;
- (void)setPrimitiveClassType:(NSNumber*)value;

- (int16_t)primitiveClassTypeValue;
- (void)setPrimitiveClassTypeValue:(int16_t)value_;




- (NSString*)primitiveName;
- (void)setPrimitiveName:(NSString*)value;





- (NSMutableSet*)primitiveVideos;
- (void)setPrimitiveVideos:(NSMutableSet*)value;


@end
