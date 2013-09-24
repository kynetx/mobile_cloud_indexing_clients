//
//  KXCommunicationController.h
//  Mobile Cloud Index
//
//  Created by Lynn Shepherd on 8/31/13.
//  Copyright (c) 2013 Kynetx. All rights reserved.
//

@protocol KXCommunicationControllerDelegate <NSObject>

@required

- (void)playTheList;
- (BOOL)isPlayingMedia;

@end

#import <Foundation/Foundation.h>

@class Media;

@interface KXCommunicationController : NSObject

- (id)initWithManagedObjectContext:(NSManagedObjectContext *)context;
- (void)startWebPollingTimer;
- (void)stopWebPollingTimer;
- (void)addMediaItemToServer:(Media *)media withDeviceToken:(NSString *)deviceToken;
- (void)removeMediaItemFromServer:(NSString *)mediaId withDeviceToken:(NSString *)deviceToken;
- (NSArray *)listMediaFromServer:(NSString *)deviceToken;
- (void)mediaPlayAddToServer:(Media *)media withDeviceToken:(NSString *)deviceToken;
- (void)mediaPlayRemoveFromServer:(NSString *)mediaId withDeviceToken:(NSString *)deviceToken;
- (NSArray *)mediaPlayListFromServer:(NSString *)deviceToken;
- (void)checkServer;
- (NSArray *)listDevicesFromServer;

@property (nonatomic, weak) id<KXCommunicationControllerDelegate> delegate;

@end


#define ADD_MEDIA_ITEM_BASE_URL @"https://cs.kobj.net/sky/event"
#define ADD_MEDIA_ITEM_ADDITIONAL_URL @"web/submit/?_rids=a169x727&element=mciAddMedia.post"

#define MEDIA_PLAY_ADD_ITEM_BASE_URL @"https://cs.kobj.net/sky/event"
#define MEDIA_PLAY_ADD_ITEM_ADDITIONAL_URL @"web/submit/?_rids=a169x727&element=mciMediaPlayAdd.post"

#define REMOVE_MEDIA_ITEM_BASE_URL @"https://cs.kobj.net/sky/event"
#define REMOVE_MEDIA_ITEM_ADDITIONAL_URL @"cloudos/mciRemoveMedia/?_rids=a169x727"

#define MEDIA_PLAY_REMOVE_ITEM_BASE_URL @"https://cs.kobj.net/sky/event"
#define MEDIA_PLAY_REMOVE_ITEM_ADDITIONAL_URL @"cloudos/mciMediaPlayRemove/?_rids=a169x727"

#define LIST_MEDIA_URL @"https://cs.kobj.net/sky/cloud/a169x727/mciListMedia"
#define MEDIA_PLAY_LIST_URL @"https://cs.kobj.net/sky/cloud/a169x727/mciMediaPlayList"
