// DO NOT EDIT. This file is machine-generated and constantly overwritten.
// Make changes to KKBDownloadClass.m instead.

#import "_KKBDownloadClass.h"

const struct KKBDownloadClassAttributes KKBDownloadClassAttributes = {
	.classID = @"classID",
	.classType = @"classType",
	.name = @"name",
};

const struct KKBDownloadClassRelationships KKBDownloadClassRelationships = {
	.videos = @"videos",
};

const struct KKBDownloadClassFetchedProperties KKBDownloadClassFetchedProperties = {
};

@implementation KKBDownloadClassID
@end

@implementation _KKBDownloadClass

+ (id)insertInManagedObjectContext:(NSManagedObjectContext*)moc_ {
	NSParameterAssert(moc_);
	return [NSEntityDescription insertNewObjectForEntityForName:@"KKBDownloadClass" inManagedObjectContext:moc_];
}

+ (NSString*)entityName {
	return @"KKBDownloadClass";
}

+ (NSEntityDescription*)entityInManagedObjectContext:(NSManagedObjectContext*)moc_ {
	NSParameterAssert(moc_);
	return [NSEntityDescription entityForName:@"KKBDownloadClass" inManagedObjectContext:moc_];
}

- (KKBDownloadClassID*)objectID {
	return (KKBDownloadClassID*)[super objectID];
}

+ (NSSet*)keyPathsForValuesAffectingValueForKey:(NSString*)key {
	NSSet *keyPaths = [super keyPathsForValuesAffectingValueForKey:key];
	
	if ([key isEqualToString:@"classIDValue"]) {
		NSSet *affectingKey = [NSSet setWithObject:@"classID"];
		keyPaths = [keyPaths setByAddingObjectsFromSet:affectingKey];
		return keyPaths;
	}
	if ([key isEqualToString:@"classTypeValue"]) {
		NSSet *affectingKey = [NSSet setWithObject:@"classType"];
		keyPaths = [keyPaths setByAddingObjectsFromSet:affectingKey];
		return keyPaths;
	}

	return keyPaths;
}




@dynamic classID;



- (int32_t)classIDValue {
	NSNumber *result = [self classID];
	return [result intValue];
}

- (void)setClassIDValue:(int32_t)value_ {
	[self setClassID:[NSNumber numberWithInt:value_]];
}

- (int32_t)primitiveClassIDValue {
	NSNumber *result = [self primitiveClassID];
	return [result intValue];
}

- (void)setPrimitiveClassIDValue:(int32_t)value_ {
	[self setPrimitiveClassID:[NSNumber numberWithInt:value_]];
}





@dynamic classType;



- (int16_t)classTypeValue {
	NSNumber *result = [self classType];
	return [result shortValue];
}

- (void)setClassTypeValue:(int16_t)value_ {
	[self setClassType:[NSNumber numberWithShort:value_]];
}

- (int16_t)primitiveClassTypeValue {
	NSNumber *result = [self primitiveClassType];
	return [result shortValue];
}

- (void)setPrimitiveClassTypeValue:(int16_t)value_ {
	[self setPrimitiveClassType:[NSNumber numberWithShort:value_]];
}





@dynamic name;






@dynamic videos;

	
- (NSMutableSet*)videosSet {
	[self willAccessValueForKey:@"videos"];
  
	NSMutableSet *result = (NSMutableSet*)[self mutableSetValueForKey:@"videos"];
  
	[self didAccessValueForKey:@"videos"];
	return result;
}
	






@end
