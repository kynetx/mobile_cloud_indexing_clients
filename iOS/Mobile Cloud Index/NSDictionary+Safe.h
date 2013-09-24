//
//  NSDictionary+Safe.h
//  Mobile Cloud Index
//
//  Created by Lynn Shepherd on 9/15/13.
//  Copyright (c) 2013 Kynetx. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSDictionary (Safe)

- (id)safeObjectForKey:(NSString *)keyValue;

@end
