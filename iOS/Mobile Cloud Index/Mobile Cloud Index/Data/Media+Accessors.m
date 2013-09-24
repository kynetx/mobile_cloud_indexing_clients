//
//  Media+Accessors.m
//  Mobile Cloud Index
//
//  Created by Lynn Shepherd on 9/2/13.
//  Copyright (c) 2013 Kynetx. All rights reserved.
//

#import "Media+Accessors.h"
#import "NSDictionary+Safe.h"
#import "KXAppDelegate.h"

//@interface Media ()
//
//
//@end

@implementation Media (Accessors)

+ (BOOL)mediaItemExist:(NSString *)itemId inManagedObjectContext:(NSManagedObjectContext *)managedObjectContext
{
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
    NSEntityDescription *entity = [NSEntityDescription entityForName:@"Media" inManagedObjectContext:managedObjectContext];
    [fetchRequest setEntity:entity];
    
    //    NSSortDescriptor *sortDescriptor = [[[NSSortDescriptor alloc] initWithKey:@"TNClientAccounts" ascending:NO] autorelease];
    //    NSArray *sortDescriptorArray = [[NSArray alloc] initWithObjects:sortDescriptor, nil];
    //    [fetchRequest setSortDescriptors:sortDescriptorArray];
    //    [sortDescriptorArray release];
    
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"%K == %@ ",@"guid", itemId];
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

+ (void)addMedia:(NSArray *)mediaArray fromPlayList:(NSNumber *)playList shared:(NSNumber *)shared intoManagedObjectContext:(NSManagedObjectContext *)context
{
    for ( NSDictionary *mediaDictionary in mediaArray )
    {
        [self insertObjectFromDictionary:mediaDictionary forPlayList:playList fromDevice:[NSNumber numberWithBool:NO] shared:nil intoManagedObjectContext:context];
    }
    
    KXAppDelegate *appDelegate = (KXAppDelegate *)[[UIApplication sharedApplication] delegate];
    [appDelegate saveContext];

}

+ (Media *)newMediaInManagedObjectContext:(NSManagedObjectContext *)context
{
    return [NSEntityDescription insertNewObjectForEntityForName:@"Media" inManagedObjectContext:context];
}

+ (BOOL)insertObjectFromMedia:(Media *)media forPlayList:(NSNumber *)playList fromDevice:(NSNumber *)fromDevice shared:(NSNumber *)shared intoManagedObjectContext:(NSManagedObjectContext *)context
{
    BOOL duplicate = NO;
    
    if ( playList )
    {
        duplicate = [self duplicateInPlaylist:media.guid inManagedObjectContect:context];
    }
    else
    {
        duplicate = [self duplicateInOffDeviceMedia:media.guid inManagedObjectContect:context];
    }
    
    if ( !duplicate )
    {
        Media *newMedia = [NSEntityDescription insertNewObjectForEntityForName:@"Media" inManagedObjectContext:context];
        
        if ( media == nil )
        {
            newMedia.dateAdded = [NSDate date];
            newMedia.addedToServer = [NSNumber numberWithBool:NO];
            newMedia.coverArtPath = nil;
            newMedia.guid = [self getGUID];
            newMedia.itemDescription = nil;
            newMedia.path = nil;
            
            if ( [shared boolValue] )
            {
                newMedia.shared = shared;
            }
            else
            {
                newMedia.shared = [NSNumber numberWithBool:NO];
            }

            newMedia.shared = [NSNumber numberWithBool:NO];
            newMedia.title = @"new media item";
            newMedia.type = nil;
            
            if ( [playList boolValue] )
            {
                newMedia.playQueue = playList;
            }
            else
            {
                newMedia.playQueue = [NSNumber numberWithBool:NO];
            }
            
            if ( [fromDevice boolValue] )
            {
                newMedia.fromDevice = fromDevice;
            }
            else
            {
                newMedia.fromDevice = [NSNumber numberWithBool:NO];
            }
        }
        else
        {
            newMedia.addedToServer = media.addedToServer;
            newMedia.coverArtPath = media.coverArtPath;
            newMedia.guid = media.guid;
            newMedia.itemDescription = media.description;
            newMedia.path = media.path;

            if ( shared == nil )
            {
                newMedia.shared = media.shared;
            }
            else if ( [shared boolValue] )
            {
                newMedia.shared = shared;
            }
            else
            {
                newMedia.shared = [NSNumber numberWithBool:NO];
            }

            newMedia.shared = media.shared;
            newMedia.title = media.title;
            newMedia.type = media.type;

            if ( playList == nil )
            {
                newMedia.playQueue = media.playQueue;
            }
            else if ( [fromDevice boolValue] )
            {
                newMedia.playQueue = playList;
            }
            else
            {
                newMedia.playQueue = [NSNumber numberWithBool:NO];
            }

            newMedia.playQueue = media.playQueue;
            
            if ( fromDevice == nil )
            {
                newMedia.fromDevice = media.fromDevice;
            }
            else if ( [fromDevice boolValue] )
            {
                newMedia.fromDevice = fromDevice;
            }
            else
            {
                newMedia.fromDevice = [NSNumber numberWithBool:NO];
            }
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

+ (BOOL)insertObjectFromDictionary:(NSDictionary *)mediaDictionary forPlayList:(NSNumber *)playList  fromDevice:(NSNumber *)fromDevice shared:(NSNumber *)shared intoManagedObjectContext:(NSManagedObjectContext *)context
{
    // check for duplicates

    BOOL duplicate = NO;
    
    if ( playList )
    {
        duplicate = [self duplicateInPlaylist:[mediaDictionary safeObjectForKey:@"mediaGUID"] inManagedObjectContect:context];
    }
    else
    {
        duplicate = [self duplicateInOffDeviceMedia:[mediaDictionary safeObjectForKey:@"mediaGUID"] inManagedObjectContect:context];
    }
    
    if ( !duplicate )
    {    
        Media *newMedia = [NSEntityDescription insertNewObjectForEntityForName:@"Media" inManagedObjectContext:context];
        
        newMedia.addedToServer = [NSNumber numberWithBool:YES];
        newMedia.coverArtPath = [mediaDictionary safeObjectForKey:@"mediaCoverArt"];
        newMedia.guid = [mediaDictionary safeObjectForKey:@"mediaGUID"];
        newMedia.itemDescription = [mediaDictionary safeObjectForKey:@"mediaDescription"];
        newMedia.path = [mediaDictionary safeObjectForKey:@"mediaURL"];
        newMedia.shared = [mediaDictionary safeObjectForKey:@"mediaShared"];
        newMedia.title = [mediaDictionary safeObjectForKey:@"mediaTitle"];
        newMedia.type = [mediaDictionary safeObjectForKey:@"mediaType"];
        newMedia.playQueue = playList;
        
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

+ (BOOL)duplicateInPlaylist:(NSString *)guid inManagedObjectContect:(NSManagedObjectContext *)context
{
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
    NSEntityDescription *entity = [NSEntityDescription entityForName:@"Media" inManagedObjectContext:context];
    [fetchRequest setEntity:entity];
    
    NSSortDescriptor *sortDescriptor = [[NSSortDescriptor alloc] initWithKey:@"title" ascending:YES];
    NSArray *sortDescriptorArray = [[NSArray alloc] initWithObjects:sortDescriptor, nil];
    [fetchRequest setSortDescriptors:sortDescriptorArray];
    
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"%K == %@ && %K == %@",
                              @"guid", guid, @"playQueue", [NSNumber numberWithBool:YES]];
    [fetchRequest setPredicate:predicate];
    
    NSError *error = nil;
    NSArray *array = [context executeFetchRequest:fetchRequest error:&error];
    
    if ( error )
    {
        NSLog(@"Error adding new media item -- %@", [error description]);
        return NO;
    }
    
    if ( [array count] > 0 )
    {
        return YES;
    }
    else
    {
        return NO;
    }
}

+ (BOOL)duplicateInOffDeviceMedia:(NSString *)guid inManagedObjectContect:(NSManagedObjectContext *)context
{
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
    NSEntityDescription *entity = [NSEntityDescription entityForName:@"Media" inManagedObjectContext:context];
    [fetchRequest setEntity:entity];
    
    NSSortDescriptor *sortDescriptor = [[NSSortDescriptor alloc] initWithKey:@"title" ascending:YES];
    NSArray *sortDescriptorArray = [[NSArray alloc] initWithObjects:sortDescriptor, nil];
    [fetchRequest setSortDescriptors:sortDescriptorArray];
    
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"%K == %@ && %K == %@ && %K == %@",
                              @"guid", guid, @"playQueue", [NSNumber numberWithBool:NO], @"fromDevice", [NSNumber numberWithBool:NO]];
    [fetchRequest setPredicate:predicate];
    
    NSError *error = nil;
    NSArray *array = [context executeFetchRequest:fetchRequest error:&error];
    
    if ( error )
    {
        NSLog(@"Error adding new media item -- %@", [error description]);
        return NO;
    }
    
    if ( [array count] > 0 )
    {
        return YES;
    }
    else
    {
        return NO;
    }
}

+ (Media *)mediaWithURL:(NSString *)url inManagedObjectContext:(NSManagedObjectContext *)context
{
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
    NSEntityDescription *entity = [NSEntityDescription entityForName:@"Media" inManagedObjectContext:context];
    [fetchRequest setEntity:entity];
    
    NSSortDescriptor *sortDescriptor = [[NSSortDescriptor alloc] initWithKey:@"title" ascending:YES];
    NSArray *sortDescriptorArray = [[NSArray alloc] initWithObjects:sortDescriptor, nil];
    [fetchRequest setSortDescriptors:sortDescriptorArray];
    
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"%K == %@", @"path", url];
    [fetchRequest setPredicate:predicate];
    
    NSError *error = nil;
    NSArray *array = [context executeFetchRequest:fetchRequest error:&error];
    
    if ( error )
    {
        NSLog(@"Error adding new media item -- %@", [error description]);
        return nil;
    }
    return [array lastObject];
}

+ (Media *)mediaWithId:(NSString *)guid inManagedObjectContect:(NSManagedObjectContext *)context
{
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
    NSEntityDescription *entity = [NSEntityDescription entityForName:@"Media" inManagedObjectContext:context];
    [fetchRequest setEntity:entity];
    
    NSSortDescriptor *sortDescriptor = [[NSSortDescriptor alloc] initWithKey:@"title" ascending:YES];
    NSArray *sortDescriptorArray = [[NSArray alloc] initWithObjects:sortDescriptor, nil];
    [fetchRequest setSortDescriptors:sortDescriptorArray];
    
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"%K == %@",
                              @"guid", guid];
    [fetchRequest setPredicate:predicate];
    
    NSError *error = nil;
    NSArray *array = [context executeFetchRequest:fetchRequest error:&error];
    
    if ( error )
    {
        NSLog(@"Error adding new media item -- %@", [error description]);
        return nil;
    }
    return [array lastObject];
}


+ (NSArray *)mediaObjectsWithType:(NSString *)typeString inManagedObjectContext:(NSManagedObjectContext *)context
{
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
    NSEntityDescription *entity = [NSEntityDescription entityForName:@"Media" inManagedObjectContext:context];
    [fetchRequest setEntity:entity];
    
    NSSortDescriptor *sortDescriptor = [[NSSortDescriptor alloc] initWithKey:@"title" ascending:YES];
    NSArray *sortDescriptorArray = [[NSArray alloc] initWithObjects:sortDescriptor, nil];
    [fetchRequest setSortDescriptors:sortDescriptorArray];
    
    if ( typeString )
    {
        NSPredicate *predicate = [NSPredicate predicateWithFormat:@"%K == %@", @"type", typeString];
        [fetchRequest setPredicate:predicate];
    }
    
    NSError *error = nil;
    NSArray *array = [context executeFetchRequest:fetchRequest error:&error];
    
    if ( error )
    {
        NSLog(@"Error retrieving media item -- %@", [error description]);
        return nil;
    }
    return array;
}

+ (NSArray *)mediaPlayList:(NSManagedObjectContext *)context
{
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
    NSEntityDescription *entity = [NSEntityDescription entityForName:@"Media" inManagedObjectContext:context];
    [fetchRequest setEntity:entity];
    
    NSSortDescriptor *sortDescriptor = [[NSSortDescriptor alloc] initWithKey:@"dateAdded" ascending:YES];
    NSArray *sortDescriptorArray = [[NSArray alloc] initWithObjects:sortDescriptor, nil];
    [fetchRequest setSortDescriptors:sortDescriptorArray];
    
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"%K == %@",
                              @"playQueue", [NSNumber numberWithBool:YES]];
    [fetchRequest setPredicate:predicate];
    
    NSError *error = nil;
    NSArray *array = [context executeFetchRequest:fetchRequest error:&error];
    
    if ( error )
    {
        NSLog(@"Error removing playlist media item -- %@", [error description]);
        return nil;
    }
    return array;
}

+ (NSArray *)mediaOnDevice:(BOOL)onDevice inManagedObjectContext:(NSManagedObjectContext *)context
{
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
    NSEntityDescription *entity = [NSEntityDescription entityForName:@"Media" inManagedObjectContext:context];
    [fetchRequest setEntity:entity];
    
    NSSortDescriptor *sortDescriptor = [[NSSortDescriptor alloc] initWithKey:@"title" ascending:YES];
    NSArray *sortDescriptorArray = [[NSArray alloc] initWithObjects:sortDescriptor, nil];
    [fetchRequest setSortDescriptors:sortDescriptorArray];
    
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"%K == %@",
                              @"fromDevice", [NSNumber numberWithBool:onDevice]];
    [fetchRequest setPredicate:predicate];
    
    NSError *error = nil;
    NSArray *array = [context executeFetchRequest:fetchRequest error:&error];
    
    if ( error )
    {
        NSLog(@"Error removing off-device media item -- %@", [error description]);
        return nil;
    }
    return array;
}

+ (void)description:(Media *)media
{
    NSLog(@"addedToServer:%@\ncoverArtPath:%@\nguid:%@\ndescription:%@\nurl:%@\nshared:%@\ntitle:%@\ntype:%@\nplayQueue:%@", media.addedToServer, media.coverArtPath, media.guid, media.description, media.path, media.shared, media.title, media.type, media.playQueue);
}

+ (NSString *)getGUID
{
    CFUUIDRef newUniqueId = CFUUIDCreate(kCFAllocatorDefault);
    NSString * uuidString = (__bridge_transfer NSString*)CFUUIDCreateString(kCFAllocatorDefault, newUniqueId);
    CFRelease(newUniqueId);
    
    return uuidString;
}

@end
