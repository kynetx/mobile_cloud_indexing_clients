//
//  KXInteraction.m
//  KXInteraction
//
//  Created by Alex Olson on 8/3/13.
//  Copyright (c) 2013 Alex Olson. All rights reserved.
//

#import "KXInteraction.h"

@interface KXInteraction()

// private property that stores the oauth code returned from
// cloudOS that is then used to request an ECI
@property (strong, nonatomic) NSString* oauthCode;

// the webview we use to start the oauth handshake and retrieve
// an oauth code
@property (strong, nonatomic) UIWebView* squaretagOAuthView;

// the applications key, which we exchange for an OAuth code
// from CloudOS
@property (strong, nonatomic) NSString* appkey;

// the callback url for this application. We can really disregard this because
// we dont use it for a mobile app but CloudOS throws fits when the callback url
// is not passed in tandem with the app key in every request.
@property (strong, nonatomic) NSURL* callbackURL;

// internal property that holds the initial NSData response from the last
// act in our OAuth Dance.
@property (strong, nonatomic) NSMutableData* oauthLastActResponseRaw;

// private helper method to construct an OAuth code request URL
- (NSURL*) constructOAuthHandshakeDoorbellURL:(NSString*)applicationKey withCallback:(NSURL*)callback;

// private helper method to initiate request to exchange oauth code for an ECI.
- (void) exchangeCodeForECI;

@end

@implementation KXInteraction

@synthesize delegate, evalHost, oauthCode, squaretagOAuthView, appkey, callbackURL, oauthLastActResponseRaw;

- (id) init {
    return [self initWithEvalHost:nil andDelegate:nil];
}

- (id) initWithEvalHost:(NSString*)host andDelegate:(id)del {
    
    if (self = [super init]) {
        self.evalHost = [NSURL URLWithString:host];
        self.delegate = del;
        self.oauthCode = nil;
        self.appkey = nil;
        self.callbackURL = nil;
        self.oauthLastActResponseRaw = nil;
    }
    
    return self;
}

- (void) beginOAuthHandshakeWithAppKey:(NSString *)appKey andCallbackURL:(NSString*)cbURL {
    
    NSString* escapedCallbackURL = [cbURL stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
    NSURL* oauthURL = [self constructOAuthHandshakeDoorbellURL:appKey withCallback:[NSURL URLWithString:escapedCallbackURL]];
    NSURLRequest* oauthRequest = [NSURLRequest requestWithURL:oauthURL];
    
    // programatically add UIWebview to handle user approval of OAuthentication.
    // it turns out you've gotta go through some serious sludge to do so! I tried
    // to do this in the most portable way possible. IE add view to the current
    // applications key window, and also frame the UIWebview to the current screens
    // bounds, accomodating the applications status bar height. 
    
    // get current application
    UIApplication* currentApp = [UIApplication sharedApplication];
    
    // get the key window of the current application
    UIWindow* keyWindow = [currentApp keyWindow];
    
    // get the bounds of the current screen
    CGRect currentScreenBounds = [[UIScreen mainScreen] bounds];
    
    // extract the height and width out of the current screens bounds
    CGFloat currentScreenWidth = currentScreenBounds.size.width;
    CGFloat currentScreenHeight = currentScreenBounds.size.height;
    
    // get the height of the application status bar
    CGFloat statusBarHeight = [currentApp statusBarFrame].size.height;
    
    // subtract the status bar height from the current screen height to get a height for our webview
    CGFloat webViewHeight = currentScreenHeight - statusBarHeight;
    
    // make the frame for our webview
    // we have to tell CGRectMake to start drawing below the status bar
    CGRect frame = CGRectMake(0, statusBarHeight, currentScreenWidth, webViewHeight);
    
    // create the webview
    self.squaretagOAuthView = [[UIWebView alloc] initWithFrame:frame];
    
    // YES! We have set the viewport meta tag on squaretag.com but it doesn't
    // appear to always solve our problem, so I tell the webview to scale the pages
    // it displays to conform to the space avaliable.
    self.squaretagOAuthView.scalesPageToFit = YES;
    self.squaretagOAuthView.delegate = self;
    
    // add the webview to the applications window
    [keyWindow addSubview:self.squaretagOAuthView];
    
    // start loading the oauth request in the webview
    // I could preload this through use of preLoad and a delegate method
    // but it doesn't affect the UX too much if the user sees a white screen for
    // about 2 seconds. One improvement would be to add an activity indicator
    // to indicate that stuff is loading.
    [self.squaretagOAuthView loadRequest:oauthRequest];
}

#pragma mark -
#pragma mark private methods
- (NSURL*) constructOAuthHandshakeDoorbellURL:(NSString *)applicationKey withCallback:(NSURL*)callback {
    
    // once we've made it to this private method, we can safely set
    // our appKey and callbackURL for the current instance of KXInteraction
    self.appkey = applicationKey;
    self.callbackURL = callback;
    
    // this random number is passed to the client_state paramater that CloudOS OAuth requires
    // honestly Im not really sure why we need client_state anyway....but oh well. :)
    NSInteger state = arc4random_uniform(10000);
    
    // since this is a mobile app and not a website, I dont really care about a callback (redirect_url),
    // but CloudOS OAuth will throw a tantrum if we dont use the callback url that we used when we registered
    // our client app through the Kynetx Developer Kit.
    NSString* oauthURLFragment = [NSString stringWithFormat:@"oauth/authorize?response_type=code&redirect_uri=%@&client_id=%@&state=%i", self.callbackURL, self.appkey, state];
    
    // combine our oauth url with our evaluation host
    return [NSURL URLWithString:oauthURLFragment relativeToURL:self.evalHost];
}

- (void) exchangeCodeForECI {
    // construct a request for our final act in the CloudOS OAuth Dance
    // we've danced hard and we deserve our reward...the authenticated
    // personal cloud's ECI. Woot!
    NSString* oauthLastDanceFragment = @"oauth/access_token";
    NSURL* oauthLastDanceURL = [NSURL URLWithString:oauthLastDanceFragment relativeToURL:self.evalHost];
    // this is really WHERE THE MAGIC HAPPENS. We set up a POST Body string that will tell CloudOS who we are,
    // flash our credentials, and then hopefully CloudOS gives us the good stuff (the ECI)
    NSString* postDataString = [NSString stringWithFormat:@"grant_type=authorization_code&redirect_url=%@&client_id=%@&code=%@", self.callbackURL, self.appkey, self.oauthCode];
    // setup the request. We POST in order to recieve our long-awaited ECI
    NSMutableURLRequest* oauthLastDanceRequest = [NSMutableURLRequest requestWithURL:oauthLastDanceURL];
    [oauthLastDanceRequest setHTTPMethod:@"POST"];
    [oauthLastDanceRequest setHTTPBody:[postDataString dataUsingEncoding:NSUTF8StringEncoding]];
    
    // inititalize data object that will hold all of our awesome data
    self.oauthLastActResponseRaw = [NSMutableData data];
    // oh boy...here we go...rev up the engines
    NSURLConnection* oauthLastDanceConnection = [NSURLConnection connectionWithRequest:oauthLastDanceRequest delegate:self];
    
    if (oauthLastDanceConnection) {
        [UIApplication sharedApplication].networkActivityIndicatorVisible = YES;
    } else {
        NSLog(@"KXInteraction was unable to establish a connection to CloudOS OAuth Service.");
    }
}

#pragma mark -
#pragma mark NSURLConnection Delegate Methods

- (void) connection:(NSURLConnection *)connection didReceiveResponse:(NSURLResponse *)response {
    // houston, we have a connection
    // set our data length to 0
    [self.oauthLastActResponseRaw setLength:0];
}

- (void) connection:(NSURLConnection *)connection didReceiveData:(NSData *)data {
    // got some data! woot!
    [self.oauthLastActResponseRaw appendData:data];
}

- (void) connectionDidFinishLoading:(NSURLConnection *)connection {
    // we're almost there...hide the network activity indicator
    [UIApplication sharedApplication].networkActivityIndicatorVisible = NO;
    
    NSError* jsonParseError = nil;
    
    NSDictionary* oauthLastActResponseJSON = [NSJSONSerialization JSONObjectWithData:self.oauthLastActResponseRaw options:0 error:&jsonParseError];
    
    [self.delegate oauthHandshakeDidSuccedWithECI:[oauthLastActResponseJSON objectForKey:@"OAUTH_ECI"]];
    
}
    
    

#pragma mark -
#pragma mark UIWebView Delegate Methods

- (BOOL) webView:(UIWebView *)webView shouldStartLoadWithRequest:(NSURLRequest *)request navigationType:(UIWebViewNavigationType)navigationType {
    
    // get the URL that should load as a string
    NSString* urlString = request.URL.absoluteString;
    
    if ([urlString rangeOfString:@"code="].location == NSNotFound) {
        // we dont have the code yet....
        // continue with the load
        return YES;
    } else {
        // we have gotten an OAuth Code...now we just need to extract it
        // I like regex's for this sort of stuff
        // define a pattern string
        NSString* codeRegexPattern = @"code=(.*?)(?:&|$)";
        // make the regex case insensitive
        NSRegularExpressionOptions codeRegexOpts = NSRegularExpressionCaseInsensitive;
        // define an NSError object to hold any possible errors
        NSError* codeRegexError = nil;
        // construct the regex object
        NSRegularExpression* codeRegex = [NSRegularExpression regularExpressionWithPattern:codeRegexPattern options:codeRegexOpts error:&codeRegexError];
        // if an error occured, just log it for now
        if (codeRegexError != nil) {
            NSLog(@"%@", [codeRegexError description]);
        }
        
        // test the string against the regex and get results of the capture group
        // matchesInString returns an array of ranges. Where the range property will give the
        // overall match, and specific capture groups can be retrieved by using objectAtIndex
        NSArray* codeResults = [codeRegex matchesInString:urlString options:0 range:NSMakeRange(0, [urlString length])];
        // woot! set our oauth code to the extracted string
        self.oauthCode = [urlString substringWithRange:[[codeResults objectAtIndex:0] rangeAtIndex:1]];
        
        // NSLog(@"%@", self.oauthCode);
        
        [UIView animateWithDuration:0.5 animations:^{
            self.squaretagOAuthView.alpha = 0;
        } completion:^(BOOL done) {
            [self.squaretagOAuthView removeFromSuperview];
        }];
        
        [self exchangeCodeForECI];
        return NO;
    }
}

- (void) dealloc {
    // GRR!!! Die delegate DIE!!!!
    self.squaretagOAuthView.delegate = nil;
}

@end
