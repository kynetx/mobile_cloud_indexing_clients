//
//  Devices+Accessors.h
//  Mobile Cloud Index
//
//  Created by Lynn Shepherd on 9/2/13.
//  Copyright (c) 2013 Kynetx. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Devices.h"


@interface Devices (Accessors)

+ (BOOL)deviceExist:(NSString *)deviceChannel inManagedObjectContext:(NSManagedObjectContext *)managedObjectContext;
+ (void)addDevice:(NSArray *)deviceArray intoManagedObjectContext:(NSManagedObjectContext *)context;
+ (Devices *)newDeviceInManagedObjectContext:(NSManagedObjectContext *)context;
+ (BOOL)insertObjectFromDevice:(Devices *)device intoManagedObjectContext:(NSManagedObjectContext *)context;
+ (BOOL)insertObjectFromDictionary:(NSDictionary *)deviceDictionary intoManagedObjectContext:(NSManagedObjectContext *)context;
+ (Devices *)deviceWithId:(NSString *)deviceChannel inManagedObjectContect:(NSManagedObjectContext *)context;

@end
