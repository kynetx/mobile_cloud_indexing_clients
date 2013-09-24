//
//  Media.h
//  Mobile Cloud Index
//
//  Created by Lynn Shepherd on 9/17/13.
//  Copyright (c) 2013 Kynetx. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>


@interface Media : NSManagedObject

@property (nonatomic, retain) NSNumber * addedToServer;
@property (nonatomic, retain) NSString * coverArtPath;
@property (nonatomic, retain) NSNumber * fromDevice;
@property (nonatomic, retain) NSString * guid;
@property (nonatomic, retain) NSString * itemDescription;
@property (nonatomic, retain) NSNumber * mediaViewed;
@property (nonatomic, retain) NSString * path;
@property (nonatomic, retain) NSNumber * playQueue;
@property (nonatomic, retain) NSNumber * shared;
@property (nonatomic, retain) NSString * title;
@property (nonatomic, retain) NSString * type;
@property (nonatomic, retain) NSDate * dateAdded;

@end
