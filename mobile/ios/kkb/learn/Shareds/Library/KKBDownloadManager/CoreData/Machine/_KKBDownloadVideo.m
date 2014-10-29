// DO NOT EDIT. This file is machine-generated and constantly overwritten.
// Make changes to KKBDownloadVideo.m instead.

#import "_KKBDownloadVideo.h"

const struct KKBDownloadVideoAttributes KKBDownloadVideoAttributes = {
	.downloadPath = @"downloadPath",
	.position = @"position",
	.progress = @"progress",
	.status = @"status",
	.tmpPath = @"tmpPath",
	.totalBytesFile = @"totalBytesFile",
	.totalBytesReaded = @"totalBytesReaded",
	.videoID = @"videoID",
	.videoTitle = @"videoTitle",
	.videoURL = @"videoURL",
};

const struct KKBDownloadVideoRelationships KKBDownloadVideoRelationships = {
	.whichClass = @"whichClass",
};

const struct KKBDownloadVideoFetchedProperties KKBDownloadVideoFetchedProperties = {
};

@implementation KKBDownloadVideoID
@end

@implementation _KKBDownloadVideo

+ (id)insertInManagedObjectContext:(NSManagedObjectContext*)moc_ {
	NSParameterAssert(moc_);
	return [NSEntityDescription insertNewObjectForEntityForName:@"KKBDownloadVideo" inManagedObjectContext:moc_];
}

+ (NSString*)entityName {
	return @"KKBDownloadVideo";
}

+ (NSEntityDescription*)entityInManagedObjectContext:(NSManagedObjectContext*)moc_ {
	NSParameterAssert(moc_);
	return [NSEntityDescription entityForName:@"KKBDownloadVideo" inManagedObjectContext:moc_];
}

- (KKBDownloadVideoID*)objectID {
	return (KKBDownloadVideoID*)[super objectID];
}

+ (NSSet*)keyPathsForValuesAffectingValueForKey:(NSString*)key {
	NSSet *keyPaths = [super keyPathsForValuesAffectingValueForKey:key];
	
	if ([key isEqualToString:@"positionValue"]) {
		NSSet *affectingKey = [NSSet setWithObject:@"position"];
		keyPaths = [keyPaths setByAddingObjectsFromSet:affectingKey];
		return keyPaths;
	}
	if ([key isEqualToString:@"progressValue"]) {
		NSSet *affectingKey = [NSSet setWithObject:@"progress"];
		keyPaths = [keyPaths setByAddingObjectsFromSet:affectingKey];
		return keyPaths;
	}
	if ([key isEqualToString:@"statusValue"]) {
		NSSet *affectingKey = [NSSet setWithObject:@"status"];
		keyPaths = [keyPaths setByAddingObjectsFromSet:affectingKey];
		return keyPaths;
	}
	if ([key isEqualToString:@"totalBytesFileValue"]) {
		NSSet *affectingKey = [NSSet setWithObject:@"totalBytesFile"];
		keyPaths = [keyPaths setByAddingObjectsFromSet:affectingKey];
		return keyPaths;
	}
	if ([key isEqualToString:@"totalBytesReadedValue"]) {
		NSSet *affectingKey = [NSSet setWithObject:@"totalBytesReaded"];
		keyPaths = [keyPaths setByAddingObjectsFromSet:affectingKey];
		return keyPaths;
	}
	if ([key isEqualToString:@"videoIDValue"]) {
		NSSet *affectingKey = [NSSet setWithObject:@"videoID"];
		keyPaths = [keyPaths setByAddingObjectsFromSet:affectingKey];
		return keyPaths;
	}

	return keyPaths;
}




@dynamic downloadPath;






@dynamic position;



- (int32_t)positionValue {
	NSNumber *result = [self position];
	return [result intValue];
}

- (void)setPositionValue:(int32_t)value_ {
	[self setPosition:[NSNumber numberWithInt:value_]];
}

- (int32_t)primitivePositionValue {
	NSNumber *result = [self primitivePosition];
	return [result intValue];
}

- (void)setPrimitivePositionValue:(int32_t)value_ {
	[self setPrimitivePosition:[NSNumber numberWithInt:value_]];
}





@dynamic progress;



- (float)progressValue {
	NSNumber *result = [self progress];
	return [result floatValue];
}

- (void)setProgressValue:(float)value_ {
	[self setProgress:[NSNumber numberWithFloat:value_]];
}

- (float)primitiveProgressValue {
	NSNumber *result = [self primitiveProgress];
	return [result floatValue];
}

- (void)setPrimitiveProgressValue:(float)value_ {
	[self setPrimitiveProgress:[NSNumber numberWithFloat:value_]];
}





@dynamic status;



- (int16_t)statusValue {
	NSNumber *result = [self status];
	return [result shortValue];
}

- (void)setStatusValue:(int16_t)value_ {
	[self setStatus:[NSNumber numberWithShort:value_]];
}

- (int16_t)primitiveStatusValue {
	NSNumber *result = [self primitiveStatus];
	return [result shortValue];
}

- (void)setPrimitiveStatusValue:(int16_t)value_ {
	[self setPrimitiveStatus:[NSNumber numberWithShort:value_]];
}





@dynamic tmpPath;






@dynamic totalBytesFile;



- (int64_t)totalBytesFileValue {
	NSNumber *result = [self totalBytesFile];
	return [result longLongValue];
}

- (void)setTotalBytesFileValue:(int64_t)value_ {
	[self setTotalBytesFile:[NSNumber numberWithLongLong:value_]];
}

- (int64_t)primitiveTotalBytesFileValue {
	NSNumber *result = [self primitiveTotalBytesFile];
	return [result longLongValue];
}

- (void)setPrimitiveTotalBytesFileValue:(int64_t)value_ {
	[self setPrimitiveTotalBytesFile:[NSNumber numberWithLongLong:value_]];
}





@dynamic totalBytesReaded;



- (int64_t)totalBytesReadedValue {
	NSNumber *result = [self totalBytesReaded];
	return [result longLongValue];
}

- (void)setTotalBytesReadedValue:(int64_t)value_ {
	[self setTotalBytesReaded:[NSNumber numberWithLongLong:value_]];
}

- (int64_t)primitiveTotalBytesReadedValue {
	NSNumber *result = [self primitiveTotalBytesReaded];
	return [result longLongValue];
}

- (void)setPrimitiveTotalBytesReadedValue:(int64_t)value_ {
	[self setPrimitiveTotalBytesReaded:[NSNumber numberWithLongLong:value_]];
}





@dynamic videoID;



- (int32_t)videoIDValue {
	NSNumber *result = [self videoID];
	return [result intValue];
}

- (void)setVideoIDValue:(int32_t)value_ {
	[self setVideoID:[NSNumber numberWithInt:value_]];
}

- (int32_t)primitiveVideoIDValue {
	NSNumber *result = [self primitiveVideoID];
	return [result intValue];
}

- (void)setPrimitiveVideoIDValue:(int32_t)value_ {
	[self setPrimitiveVideoID:[NSNumber numberWithInt:value_]];
}





@dynamic videoTitle;






@dynamic videoURL;






@dynamic whichClass;

	






@end
