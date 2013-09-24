//
//  KXWebViewerViewController.h
//  Mobile Cloud Index
//
//  Created by Lynn Shepherd on 9/9/13.
//  Copyright (c) 2013 Kynetx. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol KXWebViewerViewControllerDelegate <NSObject>

- (void)webPreviewComplete:(NSString *)url;

@end

@interface KXWebViewerViewController : UIViewController

@property (weak, nonatomic) id<KXWebViewerViewControllerDelegate> delegate;

- (id)initWithURL:(NSString *)url;

@end
