//
//  KXAppDelegate.h
//  Mobile Cloud Index
//
//  Created by Lynn Shepherd on 8/26/13.
//  Copyright (c) 2013 Kynetx. All rights reserved.
//

#import <UIKit/UIKit.h>

#define ROOT_WEB_DIRECTORY @"mci_media"
#define PHOTO_DIRECTORY @"mci_photo"
#define VIDEO_DIRECTORY @"mci_video"
#define AUDIO_DIRECTORY @"mci_audio"
#define DEVICE_TOKEN_KEY @"device_token"
#define DEVICE_TOKEN_IPHONE @"18A2DD70-09EF-11E3-92CF-9596E71C24E1"
#define DEVICE_TOKEN_IPAD @"D2740FA4-16A5-11E3-B8E7-82514DB4A5F6"
#define OWNER_SESSION_TOKEN_KEY @"owner_session_token"

//#ifdef CONFIGURATION_Debug
#define DEVELOPMENT_SESSION_TOKEN @"A2E3CC48-09EE-11E3-A275-7C5C1257AE36"
//#endif

//#ifdef CONFIGURATION_Release
#define CUSTOMER_SESSION_TOKEN @"1FCEA696-230E-11E3-A7AA-D6A7E71C24E1"
//#endif

#define CURRENT_DEVICE_KEY @"current_device"
#define AUTO_PLAY_KEY @"auto_play"
#define CURRENT_IP_ADDRESS @"current_ip_address"
#define LOCAL_MEDIA_SAVED_TO_SERVER @"local_media_saved_to_server"
#define LOCAL_MEDIA_SAVED_TO_DB @"local_media_saved_to_db"
#define FIRST_TIME @"first_time"
#define PORT_NUMBER @"port_number"

static const int AUTO_PLAY = 0;
static const int DEMO_MODE = 1;

@class HTTPServer, KXMasterViewController;

@interface KXAppDelegate : UIResponder <UIApplicationDelegate>
{
}

@property (strong, nonatomic) UIWindow *window;

@property (readonly, strong, nonatomic) NSManagedObjectContext *managedObjectContext;
@property (readonly, strong, nonatomic) NSManagedObjectModel *managedObjectModel;
@property (readonly, strong, nonatomic) NSPersistentStoreCoordinator *persistentStoreCoordinator;
@property (strong, nonatomic) HTTPServer *httpServer;
@property (strong, nonatomic) KXMasterViewController *masterViewController;

- (void)saveContext;
- (NSURL *)applicationDocumentsDirectory;
- (NSManagedObjectContext *)threadManagedObjectContext;

@property (strong, nonatomic) UINavigationController *navigationController;

@property (strong, nonatomic) UISplitViewController *splitViewController;

@end
