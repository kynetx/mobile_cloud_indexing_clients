//
//  UIAlertView+Block.h
//  MyLab/Mastering Mobile Dashboard
//
//  Created by Lynn Shepherd on 2/5/13.
//  Copyright (c) 2013 Pearson. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface UIAlertView (BlockExtensions) <UIAlertViewDelegate>

- (id)initWithTitle:(NSString *)title message:(NSString *)message completionBlock:(void (^)(NSUInteger buttonIndex))block cancelButtonTitle:(NSString *)cancelButtonTitle otherButtonTitles:(NSString *)otherButtonTitles, ...;

@end
