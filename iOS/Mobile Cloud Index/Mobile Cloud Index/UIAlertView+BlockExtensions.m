//
//  UIAlertView+Block.m
//  MyLab/Mastering Mobile Dashboard
//
//  Created by Lynn Shepherd on 2/5/13.
//  Copyright (c) 2013 Pearson All rights reserved.
//
// example of how to use the extension
//[[[[UIAlertView alloc] initWithTitle:nil
//                             message:NSLocalizedString(@"error_database_upgrade_failed_reinstall", nil)
//                     completionBlock:^(NSUInteger buttonIndex){
//                         
//                         [self finishAppStartup];
//                     }
//                   cancelButtonTitle:@"Cancel" otherButtonTitles:nil] autorelease] show];

#import "UIAlertView+BlockExtensions.h"
#import <objc/runtime.h>

@implementation UIAlertView (BlockExtensions)

- (id)initWithTitle:(NSString *)title message:(NSString *)message completionBlock:(void (^)(NSUInteger buttonIndex))block cancelButtonTitle:(NSString *)cancelButtonTitle otherButtonTitles:(NSString *)otherButtonTitles, ... {
    objc_setAssociatedObject(self, "blockCallback", Block_copy(block), OBJC_ASSOCIATION_RETAIN_NONATOMIC);
    if (self = [self initWithTitle:title message:message delegate:self cancelButtonTitle:nil otherButtonTitles:nil]) {
        
        if (cancelButtonTitle) {
            [self addButtonWithTitle:cancelButtonTitle];
            self.cancelButtonIndex = [self numberOfButtons] - 1;
        }
        
        id eachObject;
        va_list argumentList;
        if (otherButtonTitles) {
            [self addButtonWithTitle:otherButtonTitles];
            va_start(argumentList, otherButtonTitles);
            while ((eachObject = va_arg(argumentList, id))) {
                [self addButtonWithTitle:eachObject];
            }
            va_end(argumentList);
        }
    }
    return self;
}


- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex {
    void (^block)(NSUInteger buttonIndex) = objc_getAssociatedObject(self, "blockCallback");
    block(buttonIndex);
    Block_release(block);
}

@end

