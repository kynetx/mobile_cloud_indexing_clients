//
//  KXPhotoListViewController.h
//  Mobile Cloud Index
//
//  Created by Lynn Shepherd on 8/28/13.
//  Copyright (c) 2013 Kynetx. All rights reserved.
//

@protocol KXMediaListViewControllerDelegate <NSObject>
@required
-(void)selectedDevice:(NSString *)deviceId;
@end

#import <UIKit/UIKit.h>
#import <AssetsLibrary/AssetsLibrary.h>
#import "KXMasterViewController.h"
#import <QuartzCore/QuartzCore.h>
#import "KXAppDelegate.h"

#define MEDIA_TYPE_STRING_MUSIC @"Music"
#define MEDIA_TYPE_STRING_AUDIO @"Audio"
#define MEDIA_TYPE_STRING_PHOTO @"Photo"
#define MEDIA_TYPE_STRING_VIDEO @"Video"

@interface KXMediaListViewController : UITableViewController <NSFetchedResultsControllerDelegate, UITableViewDelegate, UITableViewDataSource>

@property (strong, nonatomic) NSFetchedResultsController *fetchedResultsController;
@property (strong, nonatomic) NSManagedObjectContext *managedObjectContext;
@property (nonatomic, weak) id<KXMediaListViewControllerDelegate> delegate;

- (void)configureCell:(UITableViewCell *)cell atIndexPath:(NSIndexPath *)indexPath;
- (NSPredicate *)getPredicate;
- (NSString *)getEntityName;
- (NSArray *)getSortDescriptors;

@end
