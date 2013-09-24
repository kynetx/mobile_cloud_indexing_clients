//
//  KXWebViewerViewController.m
//  Mobile Cloud Index
//
//  Created by Lynn Shepherd on 9/9/13.
//  Copyright (c) 2013 Kynetx. All rights reserved.
//

#import "KXWebViewerViewController.h"
#import "KXLoadingView.h"

@interface KXWebViewerViewController ()

@property (strong, nonatomic) IBOutlet UIWebView *webView;
@property (strong, nonatomic) NSURL *url;
@property (strong, nonatomic) NSString *urlString;
@property (strong, nonatomic) UIView *loadingView;

- (IBAction)dismissView;

@end

@implementation KXWebViewerViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (id)initWithURL:(NSString *)url
{
    NSLog(@"web view init");
    self = [self initWithNibName:nil bundle:nil];
    if ( self )
    {
        self.url = [NSURL URLWithString:url];
        self.urlString = url;
    }
    return self;
}
- (void)viewDidLoad
{
    [super viewDidLoad];
    self.loadingView = [[KXLoadingView alloc]initWithFrame:CGRectMake(self.view.frame.size.width/2 -50, self.view.frame.size.height/2 - 50, 100, 100)];
    self.loadingView.hidden = YES;
    [self.view addSubview:_loadingView];
    NSLog(@"just before web load request");
    [self.webView loadRequest:[NSURLRequest requestWithURL:_url]];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)dismissView
{
    [_delegate webPreviewComplete:_urlString];
   [self dismissViewControllerAnimated:YES completion:nil];
}

#pragma mark - web view delegates

- (void)webViewDidStartLoad:(UIWebView *)webView
{
    self.loadingView.hidden = NO;
}

- (void)webView:(UIWebView *)webView didFailLoadWithError:(NSError *)error
{
    self.loadingView.hidden = YES;
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Loading Error" message:@"Media Failed to Load" delegate:nil cancelButtonTitle:@"Continue" otherButtonTitles:nil];
    [alert show];
}

- (void)webViewDidFinishLoad:(UIWebView *)webView
{
    self.loadingView.hidden = YES;
}

@end
