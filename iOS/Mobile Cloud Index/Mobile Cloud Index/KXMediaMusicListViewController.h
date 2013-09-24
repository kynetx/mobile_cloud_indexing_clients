//
//  KXMediaMusicListViewController.h
//  Mobile Cloud Index
//
//  Created by Lynn Shepherd on 8/28/13.
//  Copyright (c) 2013 Kynetx. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <AssetsLibrary/AssetsLibrary.h>
#import "KXMediaListViewController.h"

@interface KXMediaMusicListViewController : KXMediaListViewController

- (id)initWithManagedObjectContext:(NSManagedObjectContext *)context;
- (NSPredicate *)getPredicate;
- (NSString *)getEntityName;
- (NSArray *)getSortDescriptors;

@end
