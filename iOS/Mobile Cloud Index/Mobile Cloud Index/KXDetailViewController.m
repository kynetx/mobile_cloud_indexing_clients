//
//  KXDetailViewController.m
//  Mobile Cloud Index
//
//  Created by Lynn Shepherd on 8/26/13.
//  Copyright (c) 2013 Kynetx. All rights reserved.
//

#import "KXDetailViewController.h"
#import <QuartzCore/QuartzCore.h>
#import "KXAppDelegate.h"
#import "HTTPServer.h"
#import "KXCameraViewController.h"

@interface KXDetailViewController ()
@property (strong, nonatomic) UIPopoverController *masterPopoverController;

- (void)configureView;
- (IBAction)loadCamera;

@end

@implementation KXDetailViewController

#pragma mark - Managing the detail item

- (void)setDetailItem:(id)newDetailItem
{
    if (_detailItem != newDetailItem) {
        _detailItem = newDetailItem;
        
        // Update the view.
        [self configureView];
    }

    if (self.masterPopoverController != nil) {
        [self.masterPopoverController dismissPopoverAnimated:YES];
    }        
}

- (void)configureView
{
    // Update the user interface for the detail item.

    if (self.detailItem) {
        self.detailDescriptionLabel.text = [[self.detailItem valueForKey:@"timeStamp"] description];
        
    }
}

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view, typically from a nib.

    [self configureView];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        self.title = NSLocalizedString(@"Viewer", @"Viewer");
    }
    return self;
}

- (IBAction)loadCamera
{
    KXCameraViewController *cameraVC = [[KXCameraViewController alloc] initWithNibName:nil bundle:nil];
    [self presentViewController:cameraVC animated:YES completion:nil];
}

#pragma mark - Split view

- (void)splitViewController:(UISplitViewController *)splitController willHideViewController:(UIViewController *)viewController withBarButtonItem:(UIBarButtonItem *)barButtonItem forPopoverController:(UIPopoverController *)popoverController
{
    barButtonItem.title = NSLocalizedString(@"Media", @"Media");
    [self.navigationItem setLeftBarButtonItem:barButtonItem animated:YES];
    self.masterPopoverController = popoverController;
    
    UIBarButtonItem *cameraBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"Camera" style:UIBarButtonItemStyleBordered target:self action:@selector(loadCamera)];
    [self.navigationItem setRightBarButtonItem:cameraBarButtonItem];

    
//    UIView *serverStatusView = [[UIView alloc] initWithFrame:CGRectMake(50.0, 0.0, 100.0, 50.0)];
//    UILabel *serverLabel = [[UILabel alloc] initWithFrame:CGRectMake(5.0, 5.0, 100.0, 20.0)];
//    serverLabel.backgroundColor = [UIColor clearColor];
//    serverLabel.text = @"Server Status";
//    serverLabel.font = [UIFont systemFontOfSize:12.0];
//    [serverStatusView addSubview:serverLabel];
//    
//    UIImageView *statusImageView = [[UIImageView alloc] initWithFrame:CGRectMake(80.0, 8.0, 16.0, 16.0)];
//    [[statusImageView layer] setCornerRadius:8.0];
//    statusImageView.backgroundColor = [UIColor lightGrayColor];
//    [serverStatusView addSubview:statusImageView];
    
//    KXAppDelegate *appDelegate = (KXAppDelegate *)[[UIApplication sharedApplication] delegate];
//    if ( [appDelegate.httpServer numberOfHTTPConnections] > 0 )
//    {
//        statusImageView.backgroundColor = [UIColor greenColor];
//    }
//    else
//    {
//        statusImageView.backgroundColor = [UIColor redColor];
//    }
    
//    UIBarButtonItem *serverStatusBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:serverStatusView];
//    [self.navigationItem setRightBarButtonItem:serverStatusBarButtonItem];
//    [self.navigationItem setRightBarButtonItem:serverStatusBarButtonItem];

}

- (void)splitViewController:(UISplitViewController *)splitController willShowViewController:(UIViewController *)viewController invalidatingBarButtonItem:(UIBarButtonItem *)barButtonItem
{
    // Called when the view is shown again in the split view, invalidating the button and popover controller.
    [self.navigationItem setLeftBarButtonItem:nil animated:YES];
    self.masterPopoverController = nil;
}

@end
