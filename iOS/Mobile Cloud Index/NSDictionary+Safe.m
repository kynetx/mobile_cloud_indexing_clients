//
//  NSDictionary+Safe.m
//  Mobile Cloud Index
//
//  Created by Lynn Shepherd on 9/15/13.
//  Copyright (c) 2013 Kynetx. All rights reserved.
//

#import "NSDictionary+Safe.h"

@implementation NSDictionary (Safe)

- (id)safeObjectForKey:(NSString *)keyValue
{
    if ( [self objectForKey:keyValue] == [NSNull null] )
    {
        return nil;
    }
    return [self objectForKey:keyValue];
}

@end
