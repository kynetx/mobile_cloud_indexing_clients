//
//  Devices+Accessors.m
//  Mobile Cloud Index
//
//  Created by Lynn Shepherd on 9/2/13.
//  Copyright (c) 2013 Kynetx. All rights reserved.
//

#import "Devices+Accessors.h"
#import "NSDictionary+Safe.h"

//@interface Device ()
//
//
//@end

@implementation Devices (Accessors)

+ (BOOL)deviceExist:(NSString *)deviceChannel inManagedObjectContext:(NSManagedObjectContext *)managedObjectContext
{
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
    NSEntityDescription *entity = [NSEntityDescription entityForName:@"Devices" inManagedObjectContext:managedObjectContext];
    [fetchRequest setEntity:entity];
    
    //    NSSortDescriptor *sortDescriptor = [[[NSSortDescriptor alloc] initWithKey:@"TNClientAccounts" ascending:NO] autorelease];
    //    NSArray *sortDescriptorArray = [[NSArray alloc] initWithObjects:sortDescriptor, nil];
    //    [fetchRequest setSortDescriptors:sortDescriptorArray];
    //    [sortDescriptorArray release];
    
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"%K == %@ ",@"deviceChannel", deviceChannel];
    //                              @"FullName", [NSNull null],
    //                              @"TNClientAccounts.AccountName", [NSNull null],
    //                              @"TNClientAccounts", theCompany];
    [fetchRequest setPredicate:predicate];
    
    NSError *error;
    NSArray *array = [managedObjectContext executeFetchRequest:fetchRequest error:&error];
    
    if ( [array count] )
    {
        return YES;
    }
    return NO;
}

+ (void)addDevice:(NSArray *)deviceArray intoManagedObjectContext:(NSManagedObjectContext *)context
{
    for ( NSDictionary *deviceDictionary in deviceArray )
    {
        [self insertObjectFromDictionary:deviceDictionary intoManagedObjectContext:context];
    }
}

+ (Devices *)newDeviceInManagedObjectContext:(NSManagedObjectContext *)context
{
    return [NSEntityDescription insertNewObjectForEntityForName:@"Devices" inManagedObjectContext:context];
}

+ (BOOL)insertObjectFromDevice:(Devices *)device intoManagedObjectContext:(NSManagedObjectContext *)context
{
    if ( ![self deviceWithId:device.deviceChannel inManagedObjectContect:context] )
    {
        Devices *newDevice = [NSEntityDescription insertNewObjectForEntityForName:@"Devices" inManagedObjectContext:context];
        
        if ( device == nil )
        {
            newDevice.deviceChannel = nil;
            newDevice.deviceIcon = nil;
            newDevice.deviceName = @"new device";
        }
        else
        {
            newDevice.deviceChannel = device.deviceChannel;
            newDevice.deviceIcon = device.deviceIcon;
            newDevice.deviceName = device.deviceName;
        }

        // Save the context.
        NSError *error = nil;
        if (![context save:&error]) {
            // Replace this implementation with code to handle the error appropriately.
            // abort() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
            NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
            return NO;
        }
        return YES;
    }
    NSLog(@"duplicate record");
    return NO;
}

+ (BOOL)insertObjectFromDictionary:(NSDictionary *)deviceDictionary intoManagedObjectContext:(NSManagedObjectContext *)context
{
    // check for duplicates
    NSDictionary *deviceDict = [NSDictionary dictionaryWithDictionary:deviceDictionary];
    NSString *deviceId = [deviceDict safeObjectForKey:@"mciDeviceChannel"];
    if ( ![self deviceWithId:deviceId inManagedObjectContect:context] )
    {
    
        Devices *newDevice = [NSEntityDescription insertNewObjectForEntityForName:@"Devices" inManagedObjectContext:context];
        
        newDevice.deviceChannel = [deviceDict safeObjectForKey:@"mciDeviceChannel"];
        newDevice.deviceIcon = [deviceDict safeObjectForKey:@"mciDeviceIcon"];
        newDevice.deviceName = [deviceDict safeObjectForKey:@"mciDeviceName"];
        
        // Save the context.
        NSError *error = nil;
        if (![context save:&error]) {
            // Replace this implementation with code to handle the error appropriately.
            // abort() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
            NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
            return NO;
        }
        return YES;
    }
    NSLog(@"duplicate record");
    return NO;
}

+ (Devices *)deviceWithId:(NSString *)deviceChannel inManagedObjectContect:(NSManagedObjectContext *)context
{
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
    NSEntityDescription *entity = [NSEntityDescription entityForName:@"Devices" inManagedObjectContext:context];
    [fetchRequest setEntity:entity];
    
    NSSortDescriptor *sortDescriptor = [[NSSortDescriptor alloc] initWithKey:@"deviceName" ascending:YES];
    NSArray *sortDescriptorArray = [[NSArray alloc] initWithObjects:sortDescriptor, nil];
    [fetchRequest setSortDescriptors:sortDescriptorArray];
    
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"%K == %@",
                              @"deviceChannel", deviceChannel];
    [fetchRequest setPredicate:predicate];
    
    NSError *error = nil;
    NSArray *array = [context executeFetchRequest:fetchRequest error:&error];
    
    if ( error )
    {
        NSLog(@"Error adding new device item -- %@", [error description]);
        return nil;
    }
    return [array lastObject];
}

+ (void)description:(Devices *)device
{
    NSLog(@"mciDeviceChannel:%@\nmciDeviceIcon:%@\nmciDeviceName:%@", device.deviceChannel, device.deviceIcon, device.deviceName);
}

+ (NSString *)getGUID
{
    CFUUIDRef newUniqueId = CFUUIDCreate(kCFAllocatorDefault);
    NSString * uuidString = (__bridge_transfer NSString*)CFUUIDCreateString(kCFAllocatorDefault, newUniqueId);
    CFRelease(newUniqueId);
    
    return uuidString;
}

@end
