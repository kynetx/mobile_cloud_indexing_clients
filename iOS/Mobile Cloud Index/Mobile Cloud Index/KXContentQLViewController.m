//
//  KXContentQLViewController.m
//  Mobile Cloud Index
//
//  Created by Lynn Shepherd on 9/9/13.
//  Copyright (c) 2013 Kynetx. All rights reserved.
//

#import "KXContentQLViewController.h"

@interface KXContentQLViewController ()

@property (strong, nonatomic) Media *media;
@property (nonatomic, assign) BOOL previewSuccess;

@end

@implementation KXContentQLViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (id)initWithMedia:(Media *)media withContentPreviewDelegate:(id)delegate
{
    self = [super init];
    if ( self )
    {
        self.dataSource = self;
        self.delegate = self;
        
        self.media = media;
        self.contentPreviewDelegate = delegate;
    }
    return (self);
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    [[UINavigationBar appearance] setTintColor:[UIColor grayColor]];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)viewDidUnload {
    [self.contentPreviewDelegate contentPreviewComplete];
    [super viewDidUnload];
}

#pragma mark - QLPreviewControllerDataSource methods.

- (NSInteger) numberOfPreviewItemsInPreviewController: (QLPreviewController *) controller
{
	return 1;
}

- (id <QLPreviewItem>) previewController: (QLPreviewController *) controller previewItemAtIndex: (NSInteger) index
{    
    ContentPreviewItem* contentPreviewItem = [[ContentPreviewItem alloc] init];
    
    if([_media.path length] > 0)
    {
        contentPreviewItem.url = [NSURL URLWithString:_media.path];
        
        if( self.previewSuccess )
        {
            contentPreviewItem.title = _media.title;
        } else {
            contentPreviewItem.title = @"Cannot present media.";
        }
        return contentPreviewItem;
    }
    // Ok to return a null NSURL
    return nil;
}


#pragma mark - QLPreviewControllerDelegate methods

- (BOOL)previewController:(QLPreviewController *)controller
            shouldOpenURL:(NSURL *)url
           forPreviewItem:(id<QLPreviewItem>)item
{
	return YES;
}

- (void)previewControllerWillDismiss:(QLPreviewController *)controller
{
    [self.contentPreviewDelegate contentPreviewComplete];
}

- (void)previewControllerDidDismiss:(QLPreviewController *)controller{
    
}

#pragma mark - UIDocumentInteractionControllerDelegate

- (UIViewController *)documentInteractionControllerViewControllerForPreview:(UIDocumentInteractionController *)interactionController
{
    return [self parentViewController];
}

- (BOOL)shouldAutorotate
{
    return YES;
}

- (NSUInteger)supportedInterfaceOrientations
{
    return UIInterfaceOrientationMaskAll;
}


@end

//
// Implementation of the ContentPreviewItem that is passed into the ContentQLViewController.
// This object is like an extension of the QLPreviewItem object. It allows us to set the proeprties dynamically.
//
@implementation ContentPreviewItem

@synthesize url;
@synthesize title;

- (NSURL*)previewItemURL
{
    return self.url;
}

- (NSString*)previewItemTitle
{
    return self.title;
}


@end
