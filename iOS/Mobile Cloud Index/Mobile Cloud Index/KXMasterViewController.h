//
//  KXMasterViewController.h
//  Mobile Cloud Index
//
//  Created by Lynn Shepherd on 8/26/13.
//  Copyright (c) 2013 Kynetx. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Media.h"
#import "KXMediaListViewController.h"
#import "KXCommunicationController.h"
#import "KXWebViewerViewController.h"
#import "KXCameraViewController.h"

@class KXDetailViewController;

#import <CoreData/CoreData.h>

#define MEDIA_PHOTO_TITLE @"Photo"
#define MEDIA_MUSIC_TITLE @"Music"
#define MEDIA_VIDEO_TITLE @"Video"

#define MEDIA_PHOTO_TYPE @"Photo"
#define MEDIA_MUSIC_TYPE @"Music"
#define MEDIA_VIDEO_TYPE @"Video"

#define MEDIA_SHARED_WITH_ME_TITLE @"Media Shared With Me"
#define MEDIA_PLAY_LIST_TITLE @"PlayList"


enum {
    MEDIA_PHOTO = 0,
    MEDIA_MUSIC,
    MEDIA_VIDEO,
    MEDIA_SHARED_WITH_ME,
    MEDIA_PLAY_LIST
};

static const NSInteger NUM_MEDIA_TYPES = 5;

@interface KXMasterViewController : UIViewController <KXMediaListViewControllerDelegate, KXCommunicationControllerDelegate, KXWebViewerViewControllerDelegate, KXCameraViewControllerDelegate , NSFetchedResultsControllerDelegate>

@property (strong, nonatomic) KXDetailViewController *detailViewController;
@property (strong, nonatomic) NSManagedObjectContext *managedObjectContext;

- (void)clearAndReloadData;
- (void)startServerLoad;

@end
