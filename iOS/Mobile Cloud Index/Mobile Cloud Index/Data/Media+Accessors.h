//
//  Media+Accessors.h
//  Mobile Cloud Index
//
//  Created by Lynn Shepherd on 9/2/13.
//  Copyright (c) 2013 Kynetx. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Media.h"

@interface Media (Accessors)

+ (BOOL)mediaItemExist:(NSString *)itemId inManagedObjectContext:(NSManagedObjectContext *)managedObjectContext;
+ (void)addMedia:(NSArray *)mediaArray fromPlayList:(NSNumber *)playList shared:(NSNumber *)shared intoManagedObjectContext:(NSManagedObjectContext *)context;
+ (BOOL)insertObjectFromMedia:(Media *)media forPlayList:(NSNumber *)playList fromDevice:(NSNumber *)fromDevice shared:(NSNumber *)shared intoManagedObjectContext:(NSManagedObjectContext *)context;
+ (BOOL)insertObjectFromDictionary:(NSDictionary *)mediaDictionary forPlayList:(NSNumber *)playList  fromDevice:(NSNumber *)fromDevice shared:(NSNumber *)shared intoManagedObjectContext:(NSManagedObjectContext *)context;
+ (Media *)newMediaInManagedObjectContext:(NSManagedObjectContext *)context;
+ (NSArray *)mediaObjectsWithType:(NSString *)typeString inManagedObjectContext:(NSManagedObjectContext *)context;
+ (NSArray *)mediaPlayList:(NSManagedObjectContext *)context;
+ (NSArray *)mediaOnDevice:(BOOL)onDevice inManagedObjectContext:(NSManagedObjectContext *)context;
+ (BOOL)duplicateInPlaylist:(NSString *)guid inManagedObjectContect:(NSManagedObjectContext *)context;
+ (BOOL)duplicateInOffDeviceMedia:(NSString *)guid inManagedObjectContect:(NSManagedObjectContext *)context;
+ (Media *)mediaWithURL:(NSString *)url inManagedObjectContext:(NSManagedObjectContext *)context;

@end
