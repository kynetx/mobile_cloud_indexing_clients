//
//  KXVameraiewController.h
//  Mobile Cloud Index
//
//  Created by Lynn Shepherd on 8/31/13.
//  Copyright (c) 2013 Kynetx. All rights reserved.
//


#import <UIKit/UIKit.h>
#import <MobileCoreServices/MobileCoreServices.h>

@protocol KXCameraViewControllerDelegate <NSObject>

- (void)cameraActionComplete:(BOOL)withMediaItem;

@end


@interface KXCameraViewController : UIViewController <UIImagePickerControllerDelegate,
UINavigationControllerDelegate>

@property BOOL newMedia;
@property (strong, nonatomic) IBOutlet UIImageView *imageView;
@property (weak, nonatomic) id<KXCameraViewControllerDelegate> delegate;

- (IBAction)useCamera:(id)sender;
- (IBAction)useCameraRoll:(id)sender;

@end

