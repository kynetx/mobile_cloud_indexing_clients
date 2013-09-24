//
//  KXContentQLViewController.h
//  Mobile Cloud Index
//
//  Created by Lynn Shepherd on 9/9/13.
//  Copyright (c) 2013 Kynetx. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <QuickLook/QuickLook.h>
#import "Media+Accessors.h"


@protocol ContentPreviewDelegate <NSObject>

- (void)contentPreviewComplete;

@end


@interface KXContentQLViewController : QLPreviewController <QLPreviewControllerDataSource, QLPreviewControllerDelegate, QLPreviewItem, UIDocumentInteractionControllerDelegate>

@property (weak, nonatomic) id<ContentPreviewDelegate> contentPreviewDelegate;

- (id)initWithMedia:(Media *)media withContentPreviewDelegate:(id)delegate;

@end


//
// ContentPreviewItem will be the object passed to the ContentQLPreviewController instead of just a URL.
// ContentPreviewItem uses QLPreviewItem as its protocal. The QLPreviewItem's properties are read only.
// This object allows us to set the properties (especially "title") dynamically before passing the object into the QLPreview.

@interface ContentPreviewItem : NSObject <QLPreviewItem>
{
    
}

@property (strong, nonatomic) NSURL *url;
@property (strong, nonatomic) NSString *title;

@end