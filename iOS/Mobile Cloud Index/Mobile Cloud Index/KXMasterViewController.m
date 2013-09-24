//
//  KXMasterViewController.m
//  Mobile Cloud Index
//
//  Created by Lynn Shepherd on 8/26/13.
//  Copyright (c) 2013 Kynetx. All rights reserved.
//

#import "KXAppDelegate.h"
#import "KXMasterViewController.h"
#import "KXMediaListViewController.h"
#import "KXMediaDeviceListViewController.h"
#import "KXMediaMusicListViewController.h"
#import "KXMediaPhotoListViewController.h"
#import "KXMediaPlayListViewController.h"
#import "KXMediaSharedListViewController.h"
#import "KXMediaVideoListViewController.h"
#import "KXDetailViewController.h"
#import "KXHTTPUtilities.h"
#import "Media+Accessors.h"
#import "Reachability.h"
#import "Devices+Accessors.h"
#import "NSDictionary+Safe.h"
#import "UIAlertView+BlockExtensions.h"
#import "KXContentQLViewController.h"

static const NSUInteger NUM_LOCAL_ITEMS_TO_LOAD = 10;

@interface KXMasterViewController ()
{
    BOOL bWifi;
    BOOL bWWan;
    BOOL bConnection;
}

@property (nonatomic, assign) NSUInteger mediaType;
@property (strong, nonatomic) NSMutableArray *photoItems;
@property (strong, nonatomic) NSMutableArray *videoItems;
@property (strong, nonatomic) KXAppDelegate *appDelegate;
@property (strong, nonatomic) KXCommunicationController *communicationsController;
@property (strong, nonatomic) UITableView *tableView;
@property (strong, nonatomic) NSArray *deviceListArray;
@property (nonatomic, strong) UIPopoverController *devicePickerPopover;
@property (strong, nonatomic) IBOutlet UITableView *pickerContainerView;
@property (assign, nonatomic) BOOL loadingLocalMedia;
@property (assign, nonatomic) BOOL playingMedia;
@property (strong, nonatomic) IBOutlet UIView *loadingView;
@property (strong, nonatomic) IBOutlet UIView *spinnerContainerView;
@property (strong, nonatomic) ALAssetsLibrary *assetLibrary;

- (void)configureCell:(UITableViewCell *)cell atIndexPath:(NSIndexPath *)indexPath;
- (void)playMedia;

@end

@implementation KXMasterViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPad) {
//            self.clearsSelectionOnViewWillAppear = NO;
        }
    }
    return self;
}
							
- (void)viewDidLoad
{
    [super viewDidLoad];
    
    [self.navigationController.view addSubview:_loadingView];
    
    self.assetLibrary = [[ALAssetsLibrary alloc] init];

    self.loadingLocalMedia = NO;
    self.playingMedia = NO;
    
    [[NSNotificationCenter defaultCenter] postNotificationName:ALAssetsLibraryChangedNotification object:self];
    
//    self.title = @"Mobile Clou";
    [[UIApplication sharedApplication] setStatusBarHidden:YES];
    
    if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPad)
    {
        self.navigationItem.title = @"Mobile Cloud Index";
    }
    else
    {
        UILabel *titleLabel = [[UILabel alloc] initWithFrame:CGRectMake(0.0, 0.0, 200.0, 20.0)];
        titleLabel.backgroundColor = [UIColor clearColor];
        titleLabel.font = [UIFont systemFontOfSize:16];
        titleLabel.text = @"Mobile Cloud Index";
        titleLabel.textColor = [UIColor blackColor];
        titleLabel.textAlignment = NSTextAlignmentCenter;
        self.navigationItem.titleView = titleLabel;
    }
    
    self.appDelegate = (KXAppDelegate*)[[UIApplication sharedApplication] delegate];
    self.managedObjectContext = _appDelegate.managedObjectContext;
    
    self.communicationsController = [[KXCommunicationController alloc] initWithManagedObjectContext:_managedObjectContext];
    self.communicationsController.delegate = self;
    
    self.view.backgroundColor = [UIColor colorWithRed:0.062 green:0.13 blue:0.24 alpha:1.0];

    self.navigationController.navigationBar.tintColor = [UIColor colorWithRed:0.062 green:0.13 blue:0.24 alpha:1.0];
    self.navigationController.navigationBar.titleTextAttributes = [NSDictionary dictionaryWithObject:[UIColor whiteColor] forKey:UITextAttributeTextColor];
    UIBarButtonItem *chooseDeviceBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"Device" style:UIBarButtonItemStyleBordered target:self action:@selector(selectDevice)];
    self.navigationItem.leftBarButtonItem = chooseDeviceBarButtonItem;
    
    UIBarButtonItem *cameraBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"Camera" style:UIBarButtonItemStyleBordered target:self action:@selector(loadCamera)];
    self.navigationItem.rightBarButtonItem = cameraBarButtonItem;
    
    self.deviceListArray = nil;
    
    if ( DEMO_MODE )
    {
        self.tableView.hidden = YES;
    }
    
    
    if ( [[NSUserDefaults standardUserDefaults] objectForKey:FIRST_TIME] == nil )
    {
        self.deviceListArray = [_communicationsController listDevicesFromServer];
        [Devices addDevice:_deviceListArray intoManagedObjectContext:_managedObjectContext];
        
        self.tableView.hidden = NO;
        
        [self selectDevice];
//        [self getPhotoVideoAssets];
    }
    
    
	// Do any additional setup after loading the view, typically from a nib.
//    self.navigationItem.leftBarButtonItem = self.editButtonItem;

//    UIBarButtonItem *addButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemAdd target:self action:@selector(insertNewObject:)];
//    self.navigationItem.rightBarButtonItem = addButton;
    
//    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^
//    {
//    });
    
    if ( [[NSUserDefaults standardUserDefaults] objectForKey:CURRENT_DEVICE_KEY] )
    {
        dispatch_async(dispatch_get_main_queue(), ^{
            [self clearAndReloadData];
            //        });
            //        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^
            //        {
            if ( [[NSUserDefaults standardUserDefaults] objectForKey:FIRST_TIME] )
            {
                [self getPhotoVideoAssets];
            }

        });
//        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^
    }
    

//    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^
//    {
//    });

    // here if they want to check for wifi
//    Reachability *reachability = [Reachability reachabilityWithHostName:@"www.google.com"];
//    NetworkStatus netStatus = [reachability currentReachabilityStatus];
//    bWifi = NO;
//    bWWan = NO;
//    bConnection = NO;
//    
//    switch (netStatus) {
//        case NotReachable:
//            bConnection = NO;
//            break;
//            
//        case ReachableViaWWAN:
//            bWWan = YES;
//            bConnection = YES;
//            break;
//            
//        case ReachableViaWiFi:
//            bWifi = YES;
//            bConnection = YES;
//            break;
//            
//        default:
//            break;
//    }
    
    //////////////
//    if ( !bConnection )
//    {
//        UIAlertView *wifiDownloadAlert = [[UIAlertView alloc] initWithTitle:@"No Internet Connection" message:@"No Internet connection is available. Please check to make your wireless is turned on and try again when you have an active connection." delegate:nil cancelButtonTitle:@"Continue" otherButtonTitles:nil];
//        
//        [wifiDownloadAlert show];
//    }
//    else if ( bWifi )
//    {
//        if (bBusyDownloading == NO && appDelegate.bUpdateAtStartup && appDelegate.bFromAfterHomeScreen == NO )
//        {
//            [self startDownload];
//        }
//    }
//    else if ( bWWan && !appDelegate.bWifiDownloadOnly )
//    {
//        if (bBusyDownloading == NO && appDelegate.bUpdateAtStartup && appDelegate.bFromAfterHomeScreen == NO )
//        {
//            [self startDownload];
//        }
//    }
//    else
//    {
//        UIAlertView *wifiDownloadAlert = [[UIAlertView alloc] initWithTitle:@"No Internet Connection" message:@"No WiFi Internet connection is available. Please check to make your wireless is turned on and try again when you have an active connection. You could also turn off 'WiFi Only' download in Telenotes Settings." delegate:nil cancelButtonTitle:@"Continue" otherButtonTitles:nil];
//        
//        [wifiDownloadAlert show];
//        [wifiDownloadAlert release];
//    }

}

- (void)viewDidAppear:(BOOL)animated
{
    [[NSUserDefaults standardUserDefaults] setObject:@"not the first run" forKey:FIRST_TIME];
    [[NSUserDefaults standardUserDefaults] synchronize];

    [super viewDidAppear:animated];
}

- (void)selectDevice
{
    self.deviceListArray = [_communicationsController listDevicesFromServer];
    [Devices addDevice:[_communicationsController listDevicesFromServer] intoManagedObjectContext:_managedObjectContext];

    //ADDING PICKER for iPad
    
    if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPhone)
    {
        KXMediaDeviceListViewController *deviceVC = [[KXMediaDeviceListViewController alloc] initWithManagedObjectContext:_managedObjectContext withSize:self.view.frame.size andDelegate:self];
//        KXMediaDeviceListViewController *deviceVC = [[KXMediaDeviceListViewController alloc] initWithManagedObjectContext:_managedObjectContext withSize:CGSizeMake(320.0, [_deviceListArray count] * 44.0) andDelegate:self];
        deviceVC.view.backgroundColor = [UIColor colorWithRed:0.062 green:0.13 blue:0.24 alpha:1.0];
        [self.navigationController pushViewController:deviceVC animated:YES];
    }
    else
    {
        KXMediaDeviceListViewController *deviceVC = [[KXMediaDeviceListViewController alloc] initWithManagedObjectContext:_managedObjectContext withSize:CGSizeMake(320.0, [_deviceListArray count] * 44.0) andDelegate:self];
        self.devicePickerPopover = [[UIPopoverController alloc] initWithContentViewController:deviceVC];
        [self.devicePickerPopover presentPopoverFromBarButtonItem:self.navigationItem.leftBarButtonItem permittedArrowDirections:UIPopoverArrowDirectionUp animated:YES];
    }
}

- (void)clearAndReloadData
{
    
    // check for device
    NSString *deviceId = [[NSUserDefaults standardUserDefaults] objectForKey:CURRENT_DEVICE_KEY];
    // if no device, get device
    
    if ( deviceId == nil )
    {
        [self selectDevice];
    }
    else
    {
        // clear data from server
//        NSArray *mediaListArray = [_communicationsController listMediaFromServer:deviceId];
//        for ( NSDictionary *mediaDictionary in mediaListArray )
//        {
//            // remove items
//            [_communicationsController removeMediaItemFromServer:[mediaDictionary safeObjectForKey:@"mediaGUID"] withDeviceToken:deviceId];
//            
//        }
        
//        NSArray *mediaPlayList = [_communicationsController mediaPlayListFromServer:deviceId];
//        for ( NSDictionary *mediaDictionary in mediaPlayList )
//        {
//            // remove items
//            [ _communicationsController mediaPlayRemoveFromServer:[mediaDictionary safeObjectForKey:@"mediaGUID"] withDeviceToken:deviceId];
//            
//        }
        
        // remove playlist items from database
        self.loadingView.hidden = NO;
        
        NSArray *mediaArray = [Media mediaPlayList:_managedObjectContext];
        
        for ( Media *media in mediaArray )
        {
            [_managedObjectContext deleteObject:media];
        }
        
        // remove playlist items from server
        mediaArray = [_communicationsController mediaPlayListFromServer:[[NSUserDefaults standardUserDefaults] objectForKey:CURRENT_DEVICE_KEY]];
        
        for ( NSDictionary *mediaDictionary in mediaArray )
        {
            [_communicationsController mediaPlayRemoveFromServer:[mediaDictionary objectForKey:@"mediaGUID"] withDeviceToken:[[NSUserDefaults standardUserDefaults] objectForKey:CURRENT_DEVICE_KEY]];
        }

        // remove device media items from device
        mediaArray = [Media mediaOnDevice:YES inManagedObjectContext:_managedObjectContext];
        
        for ( Media *media in mediaArray )
        {
            [_managedObjectContext deleteObject:media];
        }

        // remove device media items from device
        mediaArray = [_communicationsController listMediaFromServer:[[NSUserDefaults standardUserDefaults] objectForKey:CURRENT_DEVICE_KEY ]];
        
        for ( NSDictionary *mediaDictionary in mediaArray )
        {
            [_communicationsController removeMediaItemFromServer:[mediaDictionary objectForKey:@"mediaGUID"] withDeviceToken:[[NSUserDefaults standardUserDefaults] objectForKey:CURRENT_DEVICE_KEY ]];
        }

        NSError *error;
        [_managedObjectContext save:&error];
    
        // reload data from server
        [self performSelectorOnMainThread:@selector(startServerLoad) withObject:nil waitUntilDone:NO];
//        [self startServerLoad];
        self.loadingView.hidden = YES;

    }
}

- (void)startServerLoad
{
    [_communicationsController startWebPollingTimer];
}

- (void)playMedia
{
    self.playingMedia = YES;
    NSArray *playListArray = [Media mediaOnDevice:NO inManagedObjectContext:_managedObjectContext];
    for ( Media *media in playListArray )
    {
        NSLog(@"\nPLAY MEDIA       media playlist:%@", media.playQueue);
    }
//    NSArray *playListArray = [Media mediaPlayList:_managedObjectContext];
    if ( [playListArray count] > 0 )
    {
        Media *media = [playListArray objectAtIndex:0];
        
//        if ( [media.type isEqualToString:@"Photo"] )
//        {
        NSLog(@"Just before web view - Media=%@", media);
        KXWebViewerViewController *webVC = [[KXWebViewerViewController alloc] initWithURL:media.path];
        webVC.delegate = self;
        [self presentViewController:webVC animated:YES completion:nil];
//        }
//        else if ( [media.type isEqualToString:@])
//        {
//            KXContentQLViewController *contentVC = [[KXContentQLViewController alloc] initWithMedia:media withContentPreviewDelegate:self];
//            
//            //    KXWebViewerViewController *webVC = [[KXWebViewerViewController alloc] initWithURL:[NSURL URLWithString:media.path]];
//            NSLog(@"media path to play=%@", media.path);
//            //    [self.navigationController pushViewController:webVC animated:YES];
//            [self presentViewController:contentVC animated:YES completion:nil];
//        }
    }
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

//- (NSManagedObject *)insertNewObject:(id)sender
//{
//    NSManagedObject *newManagedObject = [NSEntityDescription insertNewObjectForEntityForName:@"Media" inManagedObjectContext:_managedObjectContext];
//    
//    // If appropriate, configure the new managed object.
//    // Normally you should use accessor methods, but using KVC here avoids the need to add a custom class to the template.
////    [newManagedObject setValue:[NSDate date] forKey:@"timeStamp"];
//    
//    // Save the context.
//    NSError *error = nil;
//    if (![_managedObjectContext save:&error]) {
//         // Replace this implementation with code to handle the error appropriately.
//         // abort() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development. 
//        NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
//        abort();
//    }
//    return newManagedObject;
//}

#pragma mark - Table View

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;//[[self.fetchedResultsController sections] count];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
//    id <NSFetchedResultsSectionInfo> sectionInfo = [self.fetchedResultsController sections][section];
    if ( DEMO_MODE && [self.deviceListArray count] > 0 )
    {
        self.tableView.hidden = NO;
        return [self.deviceListArray count];
    }
    else if ( !DEMO_MODE )
    {
        return NUM_MEDIA_TYPES;//[sectionInfo numberOfObjects];
    }
    
    return 0;
}

// Customize the appearance of table view cells.
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"Cell";
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
        if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPhone) {
            cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
        }
    }

    [self configureCell:cell atIndexPath:indexPath];
    return cell;
}

//- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath
//{
//    // Return NO if you do not want the specified item to be editable.
//    return YES;
//}
//
//- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
//{
//    if (editingStyle == UITableViewCellEditingStyleDelete) {
//        NSManagedObjectContext *context = [self.fetchedResultsController managedObjectContext];
//        [context deleteObject:[self.fetchedResultsController objectAtIndexPath:indexPath]];
//        
//        NSError *error = nil;
//        if (![context save:&error]) {
//             // Replace this implementation with code to handle the error appropriately.
//             // abort() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development. 
//            NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
//            abort();
//        }
//    }   
//}

- (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath
{
    // The table view should not be re-orderable.
    return NO;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    if ( [_deviceListArray count] > 0 )
    {
        NSDictionary *deviceDict = [_deviceListArray objectAtIndex:indexPath.row];
        
        [[NSUserDefaults standardUserDefaults] setObject:deviceDict forKey:CURRENT_DEVICE_KEY];
        [[NSUserDefaults standardUserDefaults] synchronize];
    }
    else
    {
        switch (indexPath.row) {
            case MEDIA_PHOTO:{
                self.mediaType = MEDIA_PHOTO;
                KXMediaPhotoListViewController *photoListVC = [[KXMediaPhotoListViewController alloc] initWithManagedObjectContext:self.managedObjectContext];
                [self.navigationController pushViewController:photoListVC animated:YES];}
                break;
            case MEDIA_MUSIC:{
                self.mediaType = MEDIA_MUSIC;
                KXMediaMusicListViewController *musicListVC = [[KXMediaMusicListViewController alloc] initWithManagedObjectContext:self.managedObjectContext];
                [self.navigationController pushViewController:musicListVC animated:YES];}
                break;
            case MEDIA_VIDEO:
                self.mediaType = MEDIA_VIDEO;{
                KXMediaVideoListViewController *videoListVC = [[KXMediaVideoListViewController alloc] initWithManagedObjectContext:self.managedObjectContext];
                    [self.navigationController pushViewController:videoListVC animated:YES];}
                break;
            case MEDIA_SHARED_WITH_ME:
                self.mediaType = MEDIA_SHARED_WITH_ME;{
                KXMediaSharedListViewController *sharedListVC = [[KXMediaSharedListViewController alloc] initWithManagedObjectContext:self.managedObjectContext];
                    [self.navigationController pushViewController:sharedListVC animated:YES];}
                break;
            case MEDIA_PLAY_LIST:
                self.mediaType = MEDIA_PLAY_LIST;{
                KXMediaPlayListViewController *playListVC = [[KXMediaPlayListViewController alloc] initWithManagedObjectContext:self.managedObjectContext];
                    [self.navigationController pushViewController:playListVC  animated:YES];}
        }
    }
    
//    NSManagedObject *object = [[self fetchedResultsController] objectAtIndexPath:indexPath];
//    if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPhone) {
//	    if (!self.detailViewController) {
//	        self.detailViewController = [[KXDetailViewController alloc] initWithNibName:@"KXDetailViewController_iPhone" bundle:nil];
//	    }
//        self.detailViewController.detailItem = object;
//        [self.navigationController pushViewController:self.detailViewController animated:YES];
//    } else {
//        self.detailViewController.detailItem = object;
//    }
}


- (void)configureCell:(UITableViewCell *)cell atIndexPath:(NSIndexPath *)indexPath
{
//    NSManagedObject *object = [self.fetchedResultsController objectAtIndexPath:indexPath];
    
    NSString *titleString = nil;

    if ( [_deviceListArray count] > 0 )
    {
        NSDictionary *deviceDictionary = [_deviceListArray objectAtIndex:indexPath.row];
        titleString = [deviceDictionary safeObjectForKey:@"mciDeviceName"];
    }
    else
    {
        switch (indexPath.row) {
            case MEDIA_PHOTO:
                titleString = MEDIA_PHOTO_TITLE;
                break;
            case MEDIA_MUSIC:
                titleString = MEDIA_MUSIC_TITLE;
                break;
            case MEDIA_VIDEO:
                titleString = MEDIA_VIDEO_TITLE;
                break;
            case MEDIA_SHARED_WITH_ME:
                titleString = MEDIA_SHARED_WITH_ME_TITLE;
                break;
            case MEDIA_PLAY_LIST:
                titleString = MEDIA_PLAY_LIST_TITLE;
                break;
                
            default:
                break;
        }
    }
    [cell setAccessoryType:UITableViewCellAccessoryDisclosureIndicator];
    
    cell.textLabel.text = titleString;
}


- (void)getPhotoVideoAssets
{
    NSLog(@"GETPHOTOSVIDEOASSETS");
    if ( _loadingLocalMedia )
    {
        return;
    }
    
    self.loadingLocalMedia = YES;
    
    KXAppDelegate *appDelegate = (KXAppDelegate*)[[UIApplication sharedApplication] delegate];
    NSManagedObjectContext *threadManagedObjectContext = [appDelegate threadManagedObjectContext];
    NSString *toLocalServerBaseURL = nil;
    NSString *mediaType = nil;
    NSString *toLocalServerBaseFilePath = nil;
    
    self.photoItems = [NSMutableArray arrayWithCapacity:0];
    self.videoItems = [NSMutableArray arrayWithCapacity:0];
    __block NSMutableDictionary *mediaDictionary;
    
    NSString* webPath = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) objectAtIndex:0];
    switch (_mediaType) {
        case MEDIA_PHOTO:
//            self.title = MEDIA_PHOTO_TITLE;
            toLocalServerBaseURL = [NSString stringWithFormat:@"http://%@:%@/%@", [[NSUserDefaults standardUserDefaults] objectForKey:CURRENT_IP_ADDRESS], [[NSUserDefaults standardUserDefaults] objectForKey:PORT_NUMBER], PHOTO_DIRECTORY];
            toLocalServerBaseFilePath = [NSString stringWithFormat:@"%@/%@/%@", webPath, ROOT_WEB_DIRECTORY, PHOTO_DIRECTORY];
            mediaType = MEDIA_PHOTO_TYPE;
            break;
        case MEDIA_MUSIC:
//            self.title = MEDIA_MUSIC_TITLE;
            toLocalServerBaseURL = [NSString stringWithFormat:@"http://%@:%@/%@", [[NSUserDefaults standardUserDefaults] objectForKey:CURRENT_IP_ADDRESS], [[NSUserDefaults standardUserDefaults] objectForKey:PORT_NUMBER], AUDIO_DIRECTORY];
            toLocalServerBaseFilePath = [NSString stringWithFormat:@"%@/%@/%@", webPath, ROOT_WEB_DIRECTORY, AUDIO_DIRECTORY];
            mediaType = MEDIA_MUSIC_TYPE;
            break;
        case MEDIA_VIDEO:
//            self.title = MEDIA_VIDEO_TITLE;
            toLocalServerBaseURL = [NSString stringWithFormat:@"http://%@:%@/%@", [[NSUserDefaults standardUserDefaults] objectForKey:CURRENT_IP_ADDRESS], [[NSUserDefaults standardUserDefaults] objectForKey:PORT_NUMBER], VIDEO_DIRECTORY];
            toLocalServerBaseFilePath = [NSString stringWithFormat:@"%@/%@/%@", webPath, ROOT_WEB_DIRECTORY, VIDEO_DIRECTORY];
            mediaType = MEDIA_VIDEO_TYPE;
            break;
        case MEDIA_SHARED_WITH_ME:
//            self.title = MEDIA_SHARED_WITH_ME_TITLE;
            break;
            
        default:
            break;
    }
    
    [_assetLibrary enumerateGroupsWithTypes:ALAssetsGroupAll usingBlock:^(ALAssetsGroup *group, BOOL *stop)
     {
         if (group)
         {
             switch (_mediaType) {
                 case MEDIA_PHOTO:
                     [group setAssetsFilter:[ALAssetsFilter allPhotos]];
                     break;
                 case MEDIA_VIDEO:
                     [group setAssetsFilter:[ALAssetsFilter allVideos]];
                     break;
                     
                 default:
                     break;
             }
             
             
            // [group setAssetsFilter:[ALAssetsFilter allAssets]];
             __block NSInteger count = 0;
             [group enumerateAssetsUsingBlock:^(ALAsset *asset, NSUInteger index, BOOL *stop)
              {
                  count++;
                  if ( count >5 )
                      *stop = YES;
                  NSLog(@"count=%d", count);
                  if ( asset != nil )
                  {
                      ALAssetRepresentation *defaultRepresentation = [asset defaultRepresentation];
                      NSString *uti = [defaultRepresentation UTI];
                      
                      NSString *videoURL = [[asset valueForProperty:ALAssetPropertyURLs] valueForKey:uti];
                      NSString *mediaId = [self idFromURL:[videoURL description]];
                      NSString *extension = [self extensionFromURL:[videoURL description]];
                      
                      if ( ![Media mediaItemExist:mediaId inManagedObjectContext:_managedObjectContext] )
                      {
                          Media *mediaItem = [Media newMediaInManagedObjectContext:_managedObjectContext];
                          
                          // save thumbnail image to server directory
                          NSError *error;
                          NSString *toLocalServerFullURL = [NSString stringWithFormat:@"%@/%@_thumb.%@", toLocalServerBaseURL, mediaId, extension];
                          NSString *toLocalServerFullFilePath = [NSString stringWithFormat:@"%@/%@_thumb.%@", toLocalServerBaseFilePath, mediaId, extension];
                          UIImage *uiImage = [UIImage imageWithCGImage:[asset thumbnail]];
                          NSData *jpgData = UIImageJPEGRepresentation(uiImage, 0.9f);
                          if ([[NSFileManager defaultManager] fileExistsAtPath:toLocalServerFullFilePath] == YES) {
                              [[NSFileManager defaultManager] removeItemAtPath:toLocalServerFullFilePath error:&error];
                          }
                          [jpgData writeToFile:toLocalServerFullFilePath atomically:NO];
                          //NSLog(@"filePath=%@", filePath);
                          mediaItem.coverArtPath = toLocalServerFullURL;
                          
                          // save media item to server directory
                          toLocalServerFullURL = [NSString stringWithFormat:@"%@/%@_asset.%@", toLocalServerBaseURL, mediaId, extension];
                          toLocalServerFullFilePath = [NSString stringWithFormat:@"%@/%@_asset.%@", toLocalServerBaseFilePath, mediaId, extension];
                          // copy media file from its sourse to the media server directory
                          if ([[NSFileManager defaultManager] fileExistsAtPath:toLocalServerFullFilePath] == YES) {
                              [[NSFileManager defaultManager] removeItemAtPath:toLocalServerFullFilePath error:&error];
                          }
                          mediaItem.path = mediaItem.coverArtPath;//[videoURL description];
//                          mediaItem.path = toLocalServerFullURL;//[videoURL description];
                          
                          // copy the asset to the server directory
//                          [[NSFileManager defaultManager] copyItemAtPath:mediaItem.path toPath:filePath error:&error];
                          
                          UIImage *currentImage = [UIImage imageWithCGImage:[[asset defaultRepresentation] fullResolutionImage]];
                          NSData *currentImageData = UIImageJPEGRepresentation(currentImage, 0.9f);
//                          NSData *currentImageData = UIImagePNGRepresentation(currentImage);
                          [currentImageData writeToFile:toLocalServerFullFilePath atomically:YES];
                          
                          // this should be faster
//                          long long sizeOfRawDataInBytes = [[asset defaultRepresentation] size];
//                          NSMutableData* rawData = [[NSMutableData alloc]initWithCapacity:sizeOfRawDataInBytes];
//                          void* bufferPointer = [rawData mutableBytes];
//                          error=nil;
//                          [[asset defaultRepresentation] getBytes:bufferPointer fromOffset:0 length:sizeOfRawDataInBytes error:&error];
//                          if (error) {
//                              NSLog(@"Getting bytes failed with error: %@",error);
//                          }
//                          else {
//                              [rawData writeToFile: filePath atomically:YES];
//                              NSLog(@"saving image to file");
//                          }
                          

                          mediaItem.guid = mediaId;
                          mediaItem.type = mediaType;
                          mediaItem.title = [NSString stringWithFormat:@"%@ %i", NSLocalizedString(@"Video", nil), [mediaDictionary count]+1];

                          if ( [mediaType isEqualToString:@"Photo"] )
                          {
                              mediaItem.title = [NSString stringWithFormat:@"%@ %i", mediaType, [_photoItems count]+1];
                          }
                          else if ( [mediaType isEqualToString:@"Video"] )
                          {
                              mediaItem.title = [NSString stringWithFormat:@"%@ %i", mediaType, [_videoItems count]+1];
                          }
                          
                          mediaItem.fromDevice = [NSNumber numberWithBool:YES];
                          
                          error = nil;
                          //[_appDelegate saveContextW]
                          [_managedObjectContext save:&error];
//                          [threadManagedObjectContext save:&error];
                          if ( error )
                          {
                              NSLog(@"Unable to save: %@", [mediaItem description]);
                          }
//                          NSLog(@"mediaItem=%@", [mediaItem description]);
                          
                          if ( [mediaType isEqualToString:@"Photo"] )
                          {
                              [self.photoItems addObject:mediaItem];
                          }
                          else if ( [mediaType isEqualToString:@"Video"] )
                          {
                              [self.videoItems addObject:mediaItem];
                          }
                          
                       }
                      
                      //NSString *assetId = asset
                      
//                      [mediaDictionary setValue:title forKey:@"title"];
//                      [mediaDictionary setValue:videoURL forKey:@"url"];
//                      [self.assetItems addObject:mediaDictionary];
                      
                  }
//                  NSLog(@"Values of dictonary==>%@", self.assetItems);
                  
//                  [self savePhotoVideoAssets:_assetItems toManagedObjectContext:threadManagedObjectContext];
                  
                  //NSLog(@"assetItems:%@",assetItems);
//                  NSLog(@"Videos Are:%@", _assetItems);
              } ];
         }
         // group == nil signals we are done iterating
         if ( group == nil )
         {
             if ( [[NSUserDefaults standardUserDefaults] objectForKey:CURRENT_DEVICE_KEY] )
             {
//                 dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^
//                                {
                 NSUInteger cnt = 0;
                                    for ( Media *mediaItem in _photoItems )
                                    {
                                        [_communicationsController addMediaItemToServer:mediaItem withDeviceToken:[[NSUserDefaults standardUserDefaults] objectForKey:CURRENT_DEVICE_KEY]];
                                        cnt++;
                                        if ( cnt > 4 )
                                        {
                                            break;
                                        }
                                    }
//                                });
                 
//                 dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^
//                                {
                cnt = 0;

                                    for ( Media *mediaItem in _videoItems )
                                    {
                                        [_communicationsController addMediaItemToServer:mediaItem withDeviceToken:[[NSUserDefaults standardUserDefaults] objectForKey:CURRENT_DEVICE_KEY]];
                                        cnt++;
                                        if ( cnt > 4 )
                                        {
                                            break;
                                        }
                                    }
//                                });
             }
             [[NSUserDefaults standardUserDefaults] setObject:[NSNumber numberWithBool:YES] forKey:LOCAL_MEDIA_SAVED_TO_DB];
             [[NSUserDefaults standardUserDefaults] setObject:[NSNumber numberWithBool:YES] forKey:LOCAL_MEDIA_SAVED_TO_SERVER];
             self.loadingLocalMedia = NO;
         }
    }
     
     
    failureBlock:^(NSError *error)
     {
         [[NSUserDefaults standardUserDefaults] setObject:[NSNumber numberWithBool:NO] forKey:LOCAL_MEDIA_SAVED_TO_DB];
         [[NSUserDefaults standardUserDefaults] setObject:[NSNumber numberWithBool:NO] forKey:LOCAL_MEDIA_SAVED_TO_SERVER];
         self.loadingLocalMedia = NO;
         NSLog(@"error enumerating AssetLibrary groups %@\n", error);
     }];
}

- (void)savePhotoVideoAssets:(NSArray *)assetArray toManagedObjectContext:(NSManagedObjectContext *)context
{
    for ( NSDictionary *mediaDictionary in assetArray )
    {
        [Media insertObjectFromDictionary:mediaDictionary forPlayList:[NSNumber numberWithBool:NO] fromDevice:[NSNumber numberWithBool:YES] shared:[NSNumber numberWithBool:NO] intoManagedObjectContext:context];
    }
}

- (NSString *)idFromURL:(NSString *)assetURL
{
    NSRange range = [assetURL rangeOfString:@"id="];
    NSString *intermediateString = [assetURL substringFromIndex:range.location + 3];
    range = [intermediateString rangeOfString:@"&"];
    return [intermediateString substringToIndex:range.location];
}

- (NSString *)extensionFromURL:(NSString *)assetURL
{
    NSRange range = [assetURL rangeOfString:@"ext="];
    return [assetURL substringFromIndex:range.location + 4];
}

#pragma mark KXMediaListViewControllerDelegate
- (void)selectedDevice:(NSString *)deviceId
{
    if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPad)
    {
        [self.devicePickerPopover dismissPopoverAnimated:YES];
    }
    else
    {
        [self.navigationController popToRootViewControllerAnimated:YES];
    }
    
    [[NSUserDefaults standardUserDefaults] setObject:deviceId forKey:CURRENT_DEVICE_KEY];
    [[NSUserDefaults standardUserDefaults] synchronize];
    
//    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^
//    {
//        [self clearAndReloadData];
//    });

    self.loadingView.hidden = NO;
    dispatch_async(dispatch_get_main_queue(), ^{
        [self clearAndReloadData];
        [self getPhotoVideoAssets];
    });
}

#pragma mark KXMediaListViewControllerDelegate
- (void)playTheList
{
    NSLog(@"playTheList");
    if ( !_playingMedia )
    {
        self.playingMedia = YES;
        UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"Play List" message:[NSString stringWithFormat:@"You have an item on your playlist. Would you like to play them now?"] completionBlock:^(NSUInteger buttonIndex) {
            if ( buttonIndex == 1 )
            {
                NSLog(@"tapped Yes to play");
                [self performSelectorOnMainThread:@selector(playMedia) withObject:nil waitUntilDone:YES];
//                [self playMedia:playlist];
            }
        } cancelButtonTitle:@"No" otherButtonTitles:@"Yes", nil];
        
        [alertView show];
//        [[NSOperationQueue mainQueue] addOperationWithBlock:^{
//            [alertView show];
//        }];
    }
}

//- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
//{
//    if ( buttonIndex == 1 )
//    {
//        [self playMedia];
//    }
//}

- (IBAction)loadCamera
{
    KXCameraViewController *cameraVC = [[KXCameraViewController alloc] initWithNibName:nil bundle:nil];
    [self presentViewController:cameraVC animated:YES completion:nil];
}

- (void)webPreviewComplete:(NSString *)url
{
    Media *media = [Media mediaWithURL:url inManagedObjectContext:_managedObjectContext];
    
    [_communicationsController mediaPlayRemoveFromServer:media.guid withDeviceToken:[[NSUserDefaults standardUserDefaults] objectForKey:CURRENT_DEVICE_KEY]];
    [_managedObjectContext deleteObject:media];
    NSError *error = nil;
    [_managedObjectContext save:&error];
    if ( error )
    {
        NSLog(@"error deleting media object");
    }
    self.playingMedia = NO;
}

- (BOOL)isPlayingMedia
{
    return _playingMedia;
}

- (void)cameraActionComplete:(BOOL)withMediaItem
{
    [self getPhotoVideoAssets];
}


#pragma mark - Notification handlers

- (void) handleAssetChangedNotifiation:(NSNotification *)notification
{
    NSLog(@"notification: %@", notification);
    
    if ([notification userInfo]) {
        NSSet *insertedGroupURLs = [[notification userInfo] objectForKey:ALAssetLibraryInsertedAssetGroupsKey];
        NSSet *deletedGroupURLs = [[notification userInfo] objectForKey:ALAssetLibraryDeletedAssetGroupsKey];
        NSSet *updatedGroupURLs = [[notification userInfo] objectForKey:ALAssetLibraryUpdatedAssetGroupsKey];
        NSSet *updatedAssetURLs = [[notification userInfo] objectForKey:ALAssetLibraryUpdatedAssetsKey];
        NSURL *assetURL = [insertedGroupURLs anyObject];
        NSLog(@"assetURL=%@", assetURL);
//        if (assetURL) {
//            [_assetLibrary groupForURL:assetURL resultBlock:^(ALAssetsGroup *group) {
//                self.currentAssetGroup = group;
//            } failureBlock:^(NSError *error) {
//                
//            }];
//        }
    }
    
}

- (void) dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self name:ALAssetsLibraryChangedNotification object:nil];
}

@end
