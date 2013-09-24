//
//  KXAppDelegate.m
//  Mobile Cloud Index
//
//  Created by Lynn Shepherd on 8/26/13.
//  Copyright (c) 2013 Kynetx. All rights reserved.
//

#import "KXAppDelegate.h"
#import "KXMasterViewController.h"
#import "KXDetailViewController.h"
#import "KXHTTPUtilities.h"

#import "HTTPServer.h"
#import "DDLog.h"
#import "DDTTYLogger.h"

// Log levels: off, error, warn, info, verbose
static const int ddLogLevel = LOG_LEVEL_VERBOSE;

@implementation KXAppDelegate

@synthesize managedObjectContext = _managedObjectContext;
@synthesize managedObjectModel = _managedObjectModel;
@synthesize persistentStoreCoordinator = _persistentStoreCoordinator;
@synthesize httpServer = _httpServer;
@synthesize masterViewController = _masterViewController;

- (void)startServer
{
    // Start the server (and check for problems)
	
	NSError *error;
	if([_httpServer start:&error])
	{
		DDLogInfo(@"Started HTTP Server on port %hu", [_httpServer listeningPort]);
        NSString* webPath = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) objectAtIndex:0];
        NSString *rootDirectory = [NSString stringWithFormat:@"%@/%@", webPath, ROOT_WEB_DIRECTORY];
        
        [[NSUserDefaults standardUserDefaults] setObject:[NSNumber numberWithInt:[_httpServer listeningPort]] forKey:PORT_NUMBER];
        NSString *ipAddress = [KXHTTPUtilities getIPAddress];
        [[NSUserDefaults standardUserDefaults] setObject:ipAddress forKey:CURRENT_IP_ADDRESS];
        NSLog(@"IPADDRESS=%@", ipAddress);
        [[NSUserDefaults standardUserDefaults] synchronize];
        
        

        [_httpServer setDocumentRoot:rootDirectory];
	}
	else
	{
		DDLogError(@"Error starting HTTP Server: %@", error);
	}
}

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    
    // Configure our logging framework.
	// To keep things simple and fast, we're just going to log to the Xcode console.
	[DDLog addLogger:[DDTTYLogger sharedInstance]];
	
	// Create server using our custom MyHTTPServer class
	self.httpServer = [[HTTPServer alloc] init];
	
	// Tell the server to broadcast its presence via Bonjour.
	// This allows browsers such as Safari to automatically discover our service.
	[_httpServer setType:@"_http._tcp."];
	
	// Normally there's no need to run our server on any specific port.
	// Technologies like Bonjour allow clients to dynamically discover the server's port at runtime.
	// However, for easy testing you may want force a certain port so you can just hit the refresh button.
	// [httpServer setPort:12345];
	
    NSString *firstTime = [[NSUserDefaults standardUserDefaults] objectForKey:FIRST_TIME];
    if ( firstTime == nil )
    {
        // create web server directories
        NSString* webPath = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) objectAtIndex:0];
        NSString *directoryPath = [NSString stringWithFormat:@"%@/%@/%@", webPath, ROOT_WEB_DIRECTORY, PHOTO_DIRECTORY];
        NSError *error = nil;
        [[NSFileManager defaultManager] createDirectoryAtPath:directoryPath
                                  withIntermediateDirectories:YES
                                                   attributes:nil
                                                        error:&error];
        if (error != nil) {
            NSLog(@"error creating directory: %@", error);
        }
        directoryPath = [NSString stringWithFormat:@"%@/%@/%@", webPath, ROOT_WEB_DIRECTORY, VIDEO_DIRECTORY];
        error = nil;
        [[NSFileManager defaultManager] createDirectoryAtPath:directoryPath
                                  withIntermediateDirectories:YES
                                                   attributes:nil
                                                        error:&error];
        if (error != nil) {
            NSLog(@"error creating directory: %@", error);
        }

        directoryPath = [NSString stringWithFormat:@"%@/%@/%@", webPath, ROOT_WEB_DIRECTORY, AUDIO_DIRECTORY];
        error = nil;
        [[NSFileManager defaultManager] createDirectoryAtPath:directoryPath
                                  withIntermediateDirectories:YES
                                                   attributes:nil
                                                        error:&error];
        if (error != nil) {
            NSLog(@"error creating directory: %@", error);
        }
        
//        if([[UIDevice currentDevice].model rangeOfString:@"iPhone"].length > 0 )
//        {
        [[NSUserDefaults standardUserDefaults] setObject:DEVICE_TOKEN_IPHONE forKey:DEVICE_TOKEN_KEY];
        
        [[NSUserDefaults standardUserDefaults] setObject:DEVELOPMENT_SESSION_TOKEN forKey:OWNER_SESSION_TOKEN_KEY];
//        [[NSUserDefaults standardUserDefaults] setObject:CUSTOMER_SESSION_TOKEN forKey:OWNER_SESSION_TOKEN_KEY];
        
        
//        }
//        else
//        {
//            [[NSUserDefaults standardUserDefaults] setObject:DEVICE_TOKEN_IPAD forKey:DEVICE_TOKEN_KEY];
//        }
        [[NSUserDefaults standardUserDefaults] setObject:[NSNumber numberWithBool:NO] forKey:LOCAL_MEDIA_SAVED_TO_SERVER];
        [[NSUserDefaults standardUserDefaults] setObject:[NSNumber numberWithBool:NO] forKey:LOCAL_MEDIA_SAVED_TO_DB];
        [[NSUserDefaults standardUserDefaults] setObject:[NSNumber numberWithBool:AUTO_PLAY] forKey:AUTO_PLAY_KEY];
        [[NSUserDefaults standardUserDefaults] synchronize];
    }
    
	// Serve files from our embedded Web folder
    NSMutableString* webPath = [[NSMutableString alloc] initWithString:[NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) objectAtIndex:0]];
    [webPath appendFormat:@"/%@", ROOT_WEB_DIRECTORY];

	DDLogInfo(@"Setting document root: %@", webPath);
	NSLog(@"Setting document root: %@", webPath);
    
	[_httpServer setDocumentRoot:webPath];
    
    [self startServer];

    self.window = [[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
    // Override point for customization after application launch.
    if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPhone) {
        self.masterViewController = [[KXMasterViewController alloc] initWithNibName:@"KXMasterViewController_iPhone" bundle:nil];
        self.navigationController = [[UINavigationController alloc] initWithRootViewController:_masterViewController];
        self.window.rootViewController = self.navigationController;
        _masterViewController.managedObjectContext = self.managedObjectContext;
    } else {
        self.masterViewController = [[KXMasterViewController alloc] initWithNibName:@"KXMasterViewController_iPad" bundle:nil];
        UINavigationController *masterNavigationController = [[UINavigationController alloc] initWithRootViewController:_masterViewController];
        
//        KXDetailViewController *detailViewController = [[KXDetailViewController alloc] initWithNibName:@"KXDetailViewController_iPad" bundle:nil];
//        UINavigationController *detailNavigationController = [[UINavigationController alloc] initWithRootViewController:detailViewController];
    	
//    	_masterViewController.detailViewController = detailViewController;
        
//        self.splitViewController = [[UISplitViewController alloc] init];
//        self.splitViewController.delegate = detailViewController;
//        self.splitViewController.viewControllers = @[masterNavigationController, detailNavigationController];
        
//        self.window.rootViewController = self.splitViewController;
        self.window.rootViewController = masterNavigationController;
        _masterViewController.managedObjectContext = self.managedObjectContext;
    }
    [self.window makeKeyAndVisible];
    return YES;
}

- (void)applicationWillResignActive:(UIApplication *)application
{
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
    
    [_httpServer stop];
}

- (void)applicationDidEnterBackground:(UIApplication *)application
{
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later. 
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
}

- (void)applicationWillEnterForeground:(UIApplication *)application
{
    // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
    [self startServer];
    if ( ![[KXHTTPUtilities getIPAddress] isEqualToString:[[NSUserDefaults standardUserDefaults] objectForKey:CURRENT_IP_ADDRESS]] )
    {
        [_masterViewController clearAndReloadData];
    }
    else
    {
        [_masterViewController startServerLoad];
    }
}

- (void)applicationDidBecomeActive:(UIApplication *)application
{
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
}

- (void)applicationWillTerminate:(UIApplication *)application
{
    // Saves changes in the application's managed object context before the application terminates.
    [self saveContext];
}

- (void)saveContext
{
    NSError *error = nil;
    NSManagedObjectContext *managedObjectContext = self.managedObjectContext;
    if (managedObjectContext != nil) {
        if ([managedObjectContext hasChanges] && ![managedObjectContext save:&error]) {
             // Replace this implementation with code to handle the error appropriately.
             // abort() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development. 
            NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
//            abort();
        } 
    }
}

// this is the selector that is called when the threaded moc saves a change
- (void)contextDidSave:(NSNotification*)notification {
    NSManagedObjectContext *moc = self.managedObjectContext;
    void (^mergeChanges) (void) = ^ {
        [moc mergeChangesFromContextDidSaveNotification:notification];
    };
    
    if ([NSThread isMainThread])
    {
        mergeChanges();
    }
    else
    {
        dispatch_sync(dispatch_get_main_queue(), mergeChanges);
    }
}

#pragma mark - Core Data stack

// Returns the managed object context for the application.
// If the context doesn't already exist, it is created and bound to the persistent store coordinator for the application.

- (NSManagedObjectContext *)threadManagedObjectContext {
    
    // this is for managed object contexts that are created as needed in the background and when they are done, we need to merge this managed object context back into the main managed object context. Any saves that happen for this context must be done with saveContextWithContext
    
    NSPersistentStoreCoordinator *coordinator = [self persistentStoreCoordinator];
    NSManagedObjectContext *localManagedObjectContext = nil;
    if (coordinator != nil) {
        localManagedObjectContext = [[NSManagedObjectContext alloc] init];
        [localManagedObjectContext setPersistentStoreCoordinator:coordinator];
        
        NSNotificationCenter *center = [NSNotificationCenter defaultCenter];
        [center addObserver:self
                   selector:@selector(contextDidSave:) name:NSManagedObjectContextDidSaveNotification
                     object:localManagedObjectContext];
    }
    
    return localManagedObjectContext;
}


- (NSManagedObjectContext *)managedObjectContext
{
    if (_managedObjectContext != nil) {
        return _managedObjectContext;
    }
    
    NSPersistentStoreCoordinator *coordinator = [self persistentStoreCoordinator];
    if (coordinator != nil) {
        _managedObjectContext = [[NSManagedObjectContext alloc] init];
        [_managedObjectContext setPersistentStoreCoordinator:coordinator];
    }
    return _managedObjectContext;
}

// Returns the managed object model for the application.
// If the model doesn't already exist, it is created from the application's model.
- (NSManagedObjectModel *)managedObjectModel
{
    if (_managedObjectModel != nil) {
        return _managedObjectModel;
    }
    NSURL *modelURL = [[NSBundle mainBundle] URLForResource:@"Mobile_Cloud_Index" withExtension:@"momd"];
    _managedObjectModel = [[NSManagedObjectModel alloc] initWithContentsOfURL:modelURL];
    return _managedObjectModel;
}

// Returns the persistent store coordinator for the application.
// If the coordinator doesn't already exist, it is created and the application's store added to it.
- (NSPersistentStoreCoordinator *)persistentStoreCoordinator
{
    if (_persistentStoreCoordinator != nil) {
        return _persistentStoreCoordinator;
    }
    
    NSURL *storeURL = [[self applicationDocumentsDirectory] URLByAppendingPathComponent:@"Mobile_Cloud_Index.sqlite"];
    
    NSError *error = nil;
    _persistentStoreCoordinator = [[NSPersistentStoreCoordinator alloc] initWithManagedObjectModel:[self managedObjectModel]];
    if (![_persistentStoreCoordinator addPersistentStoreWithType:NSSQLiteStoreType configuration:nil URL:storeURL options:nil error:&error]) {
        /*
         Replace this implementation with code to handle the error appropriately.
         
         abort() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development. 
         
         Typical reasons for an error here include:
         * The persistent store is not accessible;
         * The schema for the persistent store is incompatible with current managed object model.
         Check the error message to determine what the actual problem was.
         
         
         If the persistent store is not accessible, there is typically something wrong with the file path. Often, a file URL is pointing into the application's resources directory instead of a writeable directory.
         
         If you encounter schema incompatibility errors during development, you can reduce their frequency by:
         * Simply deleting the existing store:
         [[NSFileManager defaultManager] removeItemAtURL:storeURL error:nil]
         
         * Performing automatic lightweight migration by passing the following dictionary as the options parameter:
         @{NSMigratePersistentStoresAutomaticallyOption:@YES, NSInferMappingModelAutomaticallyOption:@YES}
         
         Lightweight migration will only work for a limited set of schema changes; consult "Core Data Model Versioning and Data Migration Programming Guide" for details.
         
         */
        NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
//        abort();
    }    
    
    return _persistentStoreCoordinator;
}

#pragma mark - Application's Documents directory

// Returns the URL to the application's Documents directory.
- (NSURL *)applicationDocumentsDirectory
{
    return [[[NSFileManager defaultManager] URLsForDirectory:NSDocumentDirectory inDomains:NSUserDomainMask] lastObject];
}

@end
