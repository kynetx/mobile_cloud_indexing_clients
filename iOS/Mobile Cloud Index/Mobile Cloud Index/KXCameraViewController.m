//
//  KXCameraiewController.m
//  Mobile Cloud Index
//
//  Created by Lynn Shepherd on 8/31/13.
//  Copyright (c) 2013 Kynetx. All rights reserved.
//

#import "KXCameraViewController.h"

@interface KXCameraViewController ()

@property (strong, nonatomic) UIPopoverController *mediaPopoverController;
@property (assign, nonatomic) BOOL initialLoad;

- (void)showPopover:(UIButton *)sender;
- (IBAction)dismissView;

@end

@implementation KXCameraViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.initialLoad = YES;
    // Do any additional setup after loading the view from its nib.
    
    self.navigationController.navigationBar.tintColor = [UIColor colorWithRed:0.062 green:0.13 blue:0.24 alpha:1.0];

}

//- (void) didMoveToWindow
//{
//    [self useCamera:nil];
//}
//
- (void) viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    
    if ( _initialLoad )
    {
        self.initialLoad = NO;
        [self useCamera:nil];
    }
}

- (void) useCamera:(id)sender
{
    if ([UIImagePickerController isSourceTypeAvailable:
         UIImagePickerControllerSourceTypeCamera])
    {
        UIImagePickerController *imagePicker =
        [[UIImagePickerController alloc] init];
        imagePicker.delegate = self;
        imagePicker.sourceType =
        UIImagePickerControllerSourceTypeCamera;
        imagePicker.mediaTypes = @[(NSString *) kUTTypeImage];
        imagePicker.allowsEditing = NO;
        
        if([[UIDevice currentDevice].model rangeOfString:@"iPhone"].length > 0 )
        {
            [self presentViewController:imagePicker animated:YES completion:nil];
            
        }
        else
        {
            _mediaPopoverController = [[UIPopoverController alloc] initWithContentViewController:imagePicker];
            [self showPopover:nil];
        }

        _newMedia = YES;
    }
    else
    {
        UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"Device Error" message:@"The camera is not accessible on this device." delegate:nil cancelButtonTitle:@"Continue" otherButtonTitles: nil];
        [alertView show];
    }
}

- (void)showPopover:(UIButton *)sender
{
    if ([_mediaPopoverController isPopoverVisible]) {
        [_mediaPopoverController dismissPopoverAnimated:YES];
    } else {
        //the rectangle here is the frame of the object that presents the popover,
        //in this case, the UIButton…
        CGRect popRect = CGRectMake(10.0,
                                    40.0,
                                    30.0,
                                    30.0);
//        CGRect popRect = CGRectMake([self.navigationController.view frame].origin.x,
//                                    [self.navigationController.view frame].origin.y,
//                                    [self.navigationController.view frame].size.width,
//                                    [self.navigationController.view frame].size.height);
        [_mediaPopoverController presentPopoverFromRect:popRect
                                           inView:self.view
                         permittedArrowDirections:UIPopoverArrowDirectionAny
                                         animated:YES];
    }
}

- (void) useCameraRoll:(id)sender
{
    if ([UIImagePickerController isSourceTypeAvailable:
         UIImagePickerControllerSourceTypeSavedPhotosAlbum])
    {
        UIImagePickerController *imagePicker =
        [[UIImagePickerController alloc] init];
        imagePicker.delegate = self;
        imagePicker.sourceType =
        UIImagePickerControllerSourceTypePhotoLibrary;
        imagePicker.mediaTypes = @[(NSString *) kUTTypeImage];
        imagePicker.allowsEditing = NO;
//        NSString *deviceType = [UIDevice currentDevice].model;
        
        if([[UIDevice currentDevice].model rangeOfString:@"iPhone"].length > 0 )
        {
            [self presentViewController:imagePicker animated:YES completion:nil];

        }
        else
        {
            _mediaPopoverController = [[UIPopoverController alloc] initWithContentViewController:imagePicker];
            [self showPopover:nil];
        }

        _newMedia = NO;
    }
}

#pragma mark -
#pragma mark UIImagePickerControllerDelegate

-(void)imagePickerController:(UIImagePickerController *)picker
didFinishPickingMediaWithInfo:(NSDictionary *)info
{
    NSString *mediaType = info[UIImagePickerControllerMediaType];
    
    [self dismissViewControllerAnimated:YES completion:nil];
    
    if ([mediaType isEqualToString:(NSString *)kUTTypeImage]) {
        UIImage *image = info[UIImagePickerControllerOriginalImage];
        
        _imageView.image = image;
        if (_newMedia)
            UIImageWriteToSavedPhotosAlbum(image,
                                           self,
                                           @selector(image:finishedSavingWithError:contextInfo:),
                                           nil);
    }
    else if ([mediaType isEqualToString:(NSString *)kUTTypeMovie])
    {
        // Code here to support video if enabled
    }
}

-(void)image:(UIImage *)image
finishedSavingWithError:(NSError *)error
 contextInfo:(void *)contextInfo
{
    if (error) {
        UIAlertView *alert = [[UIAlertView alloc]
                              initWithTitle: @"Save failed"
                              message: @"Failed to save image"
                              delegate: nil
                              cancelButtonTitle:@"OK"
                              otherButtonTitles:nil];
        [alert show];
    }
    else
    {
        [_delegate cameraActionComplete:YES];
        [self dismissView];
    }
}

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    [self dismissView];
}

- (void)imagePickerControllerDidCancel:(UIImagePickerController *)picker
{
    [self dismissView];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)dismissView
{
    [_mediaPopoverController dismissPopoverAnimated:YES];
//    [_delegate webPreviewComplete:_urlString];
    [self dismissViewControllerAnimated:YES completion:nil];
}


@end
