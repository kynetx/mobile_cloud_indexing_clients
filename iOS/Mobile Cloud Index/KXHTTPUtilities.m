//
//  KXHTTPUtilities.m
//  Mobile Cloud Index
//
//  Created by Lynn Shepherd on 8/29/13.
//  Copyright (c) 2013 Kynetx. All rights reserved.
//

#import "KXHTTPUtilities.h"

@implementation KXHTTPUtilities

#import <ifaddrs.h>
#import <arpa/inet.h>



// Get IP Address
+ (NSString *)getIPAddress {
    NSString *address = @"error";
    struct ifaddrs *interfaces = NULL;
    struct ifaddrs *temp_addr = NULL;
    int success = 0;
    // retrieve the current interfaces - returns 0 on success
    success = getifaddrs(&interfaces);
    if (success == 0) {
        // Loop through linked list of interfaces
        temp_addr = interfaces;
        while(temp_addr != NULL) {
            if(temp_addr->ifa_addr->sa_family == AF_INET) {
                // Check if interface is en0 which is the wifi connection on the iPhone
                NSLog(@"name=%@", [NSString stringWithUTF8String:temp_addr->ifa_name]);
                if([[NSString stringWithUTF8String:temp_addr->ifa_name] isEqualToString:@"en0"] ||
                   [[NSString stringWithUTF8String:temp_addr->ifa_name] isEqualToString:@"en1"])
                {
                    // Get NSString from C String
                    address = [NSString stringWithUTF8String:inet_ntoa(((struct sockaddr_in *)temp_addr->ifa_addr)->sin_addr)];
                    NSLog(@"name=%@   address:%@   type=%d", [NSString stringWithUTF8String:temp_addr->ifa_name], address, temp_addr->ifa_addr->sa_family);
                }
            }
            temp_addr = temp_addr->ifa_next;
        }
    }
    // Free memory
    freeifaddrs(interfaces);
    return address;
    
}


@end
