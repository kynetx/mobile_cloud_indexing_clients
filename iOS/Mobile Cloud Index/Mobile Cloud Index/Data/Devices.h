//
//  Devices.h
//  Mobile Cloud Index
//
//  Created by Lynn Shepherd on 9/10/13.
//  Copyright (c) 2013 Kynetx. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>


@interface Devices : NSManagedObject

@property (nonatomic, retain) NSString * deviceChannel;
@property (nonatomic, retain) NSString * deviceIcon;
@property (nonatomic, retain) NSString * deviceName;
@property (nonatomic, retain) NSNumber * currentDevice;

@end
