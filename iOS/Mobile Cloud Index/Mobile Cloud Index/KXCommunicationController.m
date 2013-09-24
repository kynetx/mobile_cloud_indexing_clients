//
//  KXCommunicationController.m
//  Mobile Cloud Index
//
//  Created by Lynn Shepherd on 8/31/13.
//  Copyright (c) 2013 Kynetx. All rights reserved.
//

#import "KXAppDelegate.h"
#import "KXCommunicationController.h"
#import "JSONKit.h"
#import "Media+Accessors.h"
#import "Devices+Accessors.h"
#import "KXAppDelegate.h"
#import "UIAlertView+BlockExtensions.h"

#define ADD_MEDIA_ITEM_BASE_URL @"https://cs.kobj.net/sky/event"
#define ADD_MEDIA_ITEM_ADDITIONAL_URL @"web/submit/?_rids=a169x727&element=mciAddMedia.post"

#define MEDIA_PLAY_ADD_ITEM_BASE_URL @"https://cs.kobj.net/sky/event"
#define MEDIA_PLAY_ADD_ITEM_ADDITIONAL_URL @"web/submit/?_rids=a169x727&element=mciMediaPlayAdd.post"

#define REMOVE_MEDIA_ITEM_BASE_URL @"https://cs.kobj.net/sky/event"
#define REMOVE_MEDIA_ITEM_ADDITIONAL_URL @"cloudos/mciRemoveMedia/?_rids=a169x727"

#define MEDIA_PLAY_REMOVE_ITEM_BASE_URL @"https://cs.kobj.net/sky/event"
#define MEDIA_PLAY_REMOVE_ITEM_ADDITIONAL_URL @"cloudos/mciMediaPlayRemove/?_rids=a169x727"

#define LIST_MEDIA_URL @"https://cs.kobj.net/sky/cloud/a169x727/mciListMedia"
#define MEDIA_PLAY_LIST_URL @"https://cs.kobj.net/sky/cloud/a169x727/mciMediaPlayList"

#define LIST_DEVICE_URL @"https://cs.kobj.net/sky/cloud/a169x727/mciMediaDevicesList"

#define EID @"51236986"

static const NSTimeInterval SERVER_POLLING_INTERVAL = 10.0;

//#define ADD_MEDIA_ITEM_URL @"www.kynetix.com"

@interface KXCommunicationController ()

@property (strong, nonatomic) NSTimer *timer;
@property (strong, nonatomic) NSManagedObjectContext *managedObjectContext;

@end

@implementation KXCommunicationController

- (id)initWithManagedObjectContext:(NSManagedObjectContext *)context
{
    self = [super init];
    if ( self )
    {
        self.managedObjectContext = context;
    }
    return self;
}

- (void)startWebPollingTimer
{
    self.timer = [NSTimer scheduledTimerWithTimeInterval:SERVER_POLLING_INTERVAL target:self selector:@selector(checkServer) userInfo:nil repeats:YES];
}

- (void)stopWebPollingTimer
{
    [_timer invalidate];
    self.timer = nil;
}

- (void)checkServer
{
    if ( ![_delegate isPlayingMedia] )
    {
        NSLog(@"checking server");
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
            NSString *deviceId = [[NSUserDefaults standardUserDefaults] objectForKey:CURRENT_DEVICE_KEY];
            if ( deviceId )
            {
    //            KXAppDelegate *appDelegate = (KXAppDelegate *)[[UIApplication sharedApplication] delegate];
                
    //            [Media addMedia:[self listMediaFromServer:deviceId] fromPlayList:[NSNumber numberWithBool:NO] shared:[NSNumber numberWithBool:YES] intoManagedObjectContext:appDelegate.threadManagedObjectContext];
    //            [Media addMedia:[self mediaPlayListFromServer:deviceId] fromPlayList:[NSNumber numberWithBool:YES] shared:[NSNumber numberWithBool:YES] intoManagedObjectContext:appDelegate.threadManagedObjectContext];
                
    //              why do we need this media?
    //            [Media addMedia:[self listMediaFromServer:deviceId] fromPlayList:[NSNumber numberWithBool:NO] shared:[NSNumber numberWithBool:YES] intoManagedObjectContext:_managedObjectContext];
                
                NSArray *playList = [self mediaPlayListFromServer:deviceId];
                
                if ( !playList )
                {
                    // remove playlist items from database
                    NSArray *mediaArray = [Media mediaPlayList:_managedObjectContext];
                    
                    for ( Media *media in mediaArray )
                    {
                        [_managedObjectContext deleteObject:media];
                    }
                }
                else if ( [playList count] > 0 )
                {
                    [Media addMedia:playList fromPlayList:[NSNumber numberWithBool:YES] shared:[NSNumber numberWithBool:YES] intoManagedObjectContext:_managedObjectContext];
                    [self performSelectorOnMainThread:@selector(playTheList) withObject:nil waitUntilDone:NO];
                }
            }
        });
    }
    
//    [Devices addDevice:[self listDevicesFromServer] intoManagedObjectContext:_managedObjectContext];
}

- (void)playTheList
{
    [_delegate playTheList];
}

- (void)addMediaItemToServer:(Media *)media withDeviceToken:(NSString *)deviceToken
{
    NSLog(@"addMediaItemToServer");
    NSMutableString *postString = [[NSMutableString alloc] init];
    [postString appendFormat:@"{\"mediaCoverArt\":\"%@\",\"mediaGUID\":\"%@\",\"mediaType\": \"%@\",\"mediaURL\":\"%@\",\"mediaTitle\": \"%@\",\"mediaDescription\":\"%@\"}", media.coverArtPath, media.guid, media.type, media.path, media.title, media.itemDescription];
//    NSLog(@"\n\nbody=%@", postString);
    NSMutableString *urlString = [[NSMutableString alloc] init];;
    [urlString appendString:[[NSMutableString alloc] initWithString:ADD_MEDIA_ITEM_BASE_URL]];
    [urlString appendFormat:@"/%@/%@/%@", deviceToken, EID, ADD_MEDIA_ITEM_ADDITIONAL_URL];
//    NSLog(@"\n\n urlString=%@", urlString);
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:urlString]
                                                           cachePolicy:NSURLRequestReloadIgnoringLocalAndRemoteCacheData
                                                       timeoutInterval:10];
    
    NSData *postData = [postString dataUsingEncoding:NSASCIIStringEncoding allowLossyConversion:YES];
    
    NSString *postLength = [NSString stringWithFormat:@"%d", [postData length]];
    
    [request setValue:[NSString stringWithFormat:@"%@", deviceToken] forHTTPHeaderField:@"Kobj-Session"];
    [request setURL:[NSURL URLWithString:urlString]];
    [request setHTTPMethod:@"POST"];
    [request setValue:postLength forHTTPHeaderField:@"Content-Length"];
    [request setValue:@"application/json" forHTTPHeaderField:@"Content-Type"];
    [request setHTTPBody:postData];
//    NSLog(@"request:%@", [request description]);
    NSError *requestError;
    NSURLResponse *urlResponse = nil;
    
    NSData *response1 = [NSURLConnection sendSynchronousRequest:request returningResponse:&urlResponse error:&requestError];
    
    if ( response1 )
    {

        NSString *responseString = [[NSString alloc] initWithData:response1 encoding:NSUTF8StringEncoding];
//        NSLog(@"server response=%@", responseString);
//    JSONDecoder* decoder = [[JSONDecoder alloc] init];
//    NSDictionary *resultsDictionary = [decoder objectWithData:response1];
    
//    NSLog(@"resultsDictionary=%@", resultsDictionary);
    }
    else
    {
        UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"Server Error" message:@"Please check your Internet Connection and try again" delegate:nil cancelButtonTitle:@"Continue" otherButtonTitles:nil];
        [alertView show];
//        return nil;
    }
}

- (void)removeMediaItemFromServer:(NSString *)mediaId withDeviceToken:(NSString *)deviceToken
{
//    NSLog(@"removeMediaItemFromServer");
    NSMutableString *postString = [[NSMutableString alloc] init];
    [postString appendFormat:@"{\"mediaGUID\":\"%@\"}", mediaId];
//    NSLog(@"\n\nbody=%@", postString);
    NSMutableString *urlString = [[NSMutableString alloc] init];;
    [urlString appendString:[[NSMutableString alloc] initWithString:REMOVE_MEDIA_ITEM_BASE_URL]];
    [urlString appendFormat:@"/%@/%@/%@", deviceToken, EID, REMOVE_MEDIA_ITEM_ADDITIONAL_URL];
//    NSLog(@"\n\n urlString=%@", urlString);
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:urlString]
                                                           cachePolicy:NSURLRequestReloadIgnoringLocalAndRemoteCacheData
                                                       timeoutInterval:10];
    
    NSData *postData = [postString dataUsingEncoding:NSASCIIStringEncoding allowLossyConversion:YES];
//    
    NSString *postLength = [NSString stringWithFormat:@"%d", [postData length]];
    [request setValue:@"cs.kobj.net" forHTTPHeaderField:@"Host"];
//    [request setValue:@"json" forHTTPHeaderField:@"content-type"];
    [request setValue:[NSString stringWithFormat:@"%@", deviceToken] forHTTPHeaderField:@"Kobj-Session"];
    [request setURL:[NSURL URLWithString:urlString]];
    [request setHTTPMethod:@"POST"];
    [request setValue:postLength forHTTPHeaderField:@"Content-Length"];
    [request setValue:@"application/json" forHTTPHeaderField:@"Content-Type"];
    [request setHTTPBody:postData];
    NSLog(@"request:%@", [request description]);
    NSError *requestError;
    NSURLResponse *urlResponse = nil;
    
    NSData *response1 = [NSURLConnection sendSynchronousRequest:request returningResponse:&urlResponse error:&requestError];
    
    if ( response1 )
    {

        NSString *responseString = [[NSString alloc] initWithData:response1 encoding:NSUTF8StringEncoding];
//        NSLog(@"server response=%@", responseString);
//        JSONDecoder* decoder = [[JSONDecoder alloc] init];
//        NSDictionary *resultsDictionary = [decoder objectWithData:response1];
        
    //    NSLog(@"resultsDictionary=%@", resultsDictionary);
    }
    else
    {
        UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"Server Error" message:@"Please check your Internet Connection and try again" delegate:nil cancelButtonTitle:@"Continue" otherButtonTitles:nil];
        [alertView show];
    }
}

- (NSArray *)listMediaFromServer:(NSString *)deviceToken
{
    NSLog(@"listMediaFromServer");
    NSString *urlString = [[NSMutableString alloc] initWithString:LIST_MEDIA_URL];
//    NSLog(@"\n\n urlString=%@", urlString);
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:urlString]
                                                           cachePolicy:NSURLRequestReloadIgnoringLocalAndRemoteCacheData
                                                       timeoutInterval:10];
    
    [request setValue:[NSString stringWithFormat:@"%@", deviceToken] forHTTPHeaderField:@"Kobj-Session"];
    [request setHTTPMethod:@"GET"];
//    NSLog(@"request:%@", [request description]);
    NSError *requestError;
    NSURLResponse *urlResponse = nil;
    
    NSData *response1 = [NSURLConnection sendSynchronousRequest:request returningResponse:&urlResponse error:&requestError];
    if ( response1 )
    {
        
        NSString *responseString = [[NSString alloc] initWithData:response1 encoding:NSUTF8StringEncoding];
    //    responseString = @"\"{\"mediaCoverArt\": \"https://s3.amazonaws.com/k-mycloud/a169x672/A709A4EA-F897-11E2-9738-89683970C0C4.img?q=88528\",\"mediaGUID\": \"1DDE8D87-5C60-4B40-AEDB-DDD89B0D2655\",\"mediaType\": \"Video\",\"mediaURL\": \"http://www.youtube.com/watch?v=l-qSATlrlMA\",\"mediaTitle\": \"Kid Rock\",\"mediaDescription\": \" Kid Rock tribute to Johnny Cash\"},{\"mediaCoverArt\": \"https://s3.amazonaws.com/k-mycloud/a169x672/A709A4EA-F897-11E2-9738-89683970C0C4.img?q=88528\",\"mediaGUID\": \"b10c5443-485b-4a8c-a494-4ecad8ae310a\",\"mediaType\": \"Photo\",\"mediaURL\": \"http://192.168.1.7:8080/mci_images/image_3.png\",\"mediaTitle\": \"MCIDemo\",\"mediaDescription\": \"This is for demo only\"}";
//        NSLog(@"server response=%@", responseString);
        JSONDecoder* decoder = [[JSONDecoder alloc] init];
    //    response1 = [responseString dataUsingEncoding:NSUTF8StringEncoding];
    //    NSData *responseData = [responseString dataUsingEncoding:NSUTF8StringEncoding];
        NSArray *resultsArray = [decoder objectWithData:response1];
    //    NSDictionary *resultsDictionary = [decoder objectWithData:responseData];
    //    NSArray *resultsArray = [resultsDictionary objectForKey:@""];
    //    NSLog(@"resultsDictionary=%@", resultsArray);
    //    NSMutableArray *resultArray = [[NSMutableArray alloc] init];
    //    NSLog(@"resultsArray count =%d", [resultsArray count]);
        
        if ( [responseString rangeOfString:@"102"].length > 0 )
        {
            UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"Server Error" message:@"Please check your Internet Connection and try again" delegate:nil cancelButtonTitle:@"Continue" otherButtonTitles:nil];
            [alertView show];
        }
        else
        {
            return  resultsArray;
        }
    }
    else
    {
        UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"Server Error" message:@"Please check your Internet Connection and try again" delegate:nil cancelButtonTitle:@"Continue" otherButtonTitles:nil];
        [alertView show];
    }
    return nil;
}

- (void)mediaPlayAddToServer:(Media *)media withDeviceToken:(NSString *)deviceToken
{
    NSLog(@"mediaPlayAddToServer");
    NSMutableString *postString = [[NSMutableString alloc] init];
    [postString appendFormat:@"{\"mediaCoverArt\":\"%@\",\"mediaGUID\":\"%@\",\"mediaType\": \"%@\",\"mediaURL\":\"%@\",\"mediaTitle\": \"%@\",\"mediaDescription\":\"%@\"}", media.coverArtPath, media.guid, media.type, media.path, media.title, media.itemDescription];
//    NSLog(@"\n\nbody=%@", postString);
    NSMutableString *urlString = [[NSMutableString alloc] init];;
    [urlString appendString:[[NSMutableString alloc] initWithString:MEDIA_PLAY_ADD_ITEM_BASE_URL]];
    [urlString appendFormat:@"/%@/%@/%@", deviceToken, EID, MEDIA_PLAY_ADD_ITEM_ADDITIONAL_URL];
//    NSLog(@"\n\n urlString=%@", urlString);
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:urlString]
                                                           cachePolicy:NSURLRequestReloadIgnoringLocalAndRemoteCacheData
                                                       timeoutInterval:10];
    
    NSData *postData = [postString dataUsingEncoding:NSASCIIStringEncoding allowLossyConversion:YES];
    
    NSString *postLength = [NSString stringWithFormat:@"%d", [postData length]];
    
    [request setValue:[NSString stringWithFormat:@"%@", deviceToken] forHTTPHeaderField:@"Kobj-Session"];
    [request setURL:[NSURL URLWithString:urlString]];
    [request setHTTPMethod:@"POST"];
    [request setValue:postLength forHTTPHeaderField:@"Content-Length"];
//    [request setValue:@"application/json" forHTTPHeaderField:@"Content-Type"];
    [request setHTTPBody:postData];
//    NSLog(@"request:%@", [request description]);
    NSError *requestError;
    NSURLResponse *urlResponse = nil;
    
    NSData *response1 = [NSURLConnection sendSynchronousRequest:request returningResponse:&urlResponse error:&requestError];

    if ( response1 )
    {
        NSString *responseString = [[NSString alloc] initWithData:response1 encoding:NSUTF8StringEncoding];
//            NSLog(@"server response=%@", responseString);
//            JSONDecoder* decoder = [[JSONDecoder alloc] init];
        //    NSArray *resultsDictionary = [decoder objectWithData:response1];
            
        //    NSLog(@"resultsDictionary=%@", resultsDictionary);
    }
    else
    {
        UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"Server Error" message:@"Please check your Internet Connection and try again" delegate:nil cancelButtonTitle:@"Continue" otherButtonTitles:nil];
        [alertView show];
    }
}

- (void)mediaPlayRemoveFromServer:(NSString *)mediaId withDeviceToken:(NSString *)deviceToken
{
    NSLog(@"mediaPlayRemoveFromServer");
    NSMutableString *postString = [[NSMutableString alloc] init];
    [postString appendFormat:@"{\"mediaGUID\":\"%@\"}", mediaId];
//    NSLog(@"\n\nbody=%@", postString);
    NSMutableString *urlString = [[NSMutableString alloc] init];;
    [urlString appendString:[[NSMutableString alloc] initWithString:MEDIA_PLAY_REMOVE_ITEM_BASE_URL]];
    [urlString appendFormat:@"/%@/%@/%@", deviceToken, EID, MEDIA_PLAY_REMOVE_ITEM_ADDITIONAL_URL];
//    NSLog(@"\n\n urlString=%@", urlString);
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:urlString]
                                                           cachePolicy:NSURLRequestReloadIgnoringLocalAndRemoteCacheData
                                                       timeoutInterval:10];
    
    NSData *postData = [postString dataUsingEncoding:NSASCIIStringEncoding allowLossyConversion:YES];
    //
    NSString *postLength = [NSString stringWithFormat:@"%d", [postData length]];
    [request setValue:@"cs.kobj.net" forHTTPHeaderField:@"Host"];
    //    [request setValue:@"json" forHTTPHeaderField:@"content-type"];
    [request setValue:[NSString stringWithFormat:@"%@", deviceToken] forHTTPHeaderField:@"Kobj-Session"];
    [request setURL:[NSURL URLWithString:urlString]];
    [request setHTTPMethod:@"POST"];
    [request setValue:postLength forHTTPHeaderField:@"Content-Length"];
    [request setValue:@"application/json" forHTTPHeaderField:@"Content-Type"];
    [request setHTTPBody:postData];
    NSLog(@"request:%@", [request description]);
    NSError *requestError;
    NSURLResponse *urlResponse = nil;
    
    NSData *response1 = [NSURLConnection sendSynchronousRequest:request returningResponse:&urlResponse error:&requestError];
        
    if ( response1 )
    {
        NSString *responseString = [[NSString alloc] initWithData:response1 encoding:NSUTF8StringEncoding];
//        responseString = @"[{\"mediaCoverArt\": \"https://s3.amazonaws.com/k-mycloud/a169x672/A709A4EA-F897-11E2-9738-89683970C0C4.img?q=88528\",\"mediaGUID\": \"1DDE8D87-5C60-4B40-AEDB-DDD89B0D2655\",\"mediaType\": \"Video\",\"mediaURL\": \"http://www.youtube.com/watch?v=l-qSATlrlMA\",\"mediaTitle\": \"Kid Rock\",\"mediaDescription\": \" Kid Rock tribute to Johnny Cash\"},{\"mediaCoverArt\": \"https://s3.amazonaws.com/k-mycloud/a169x672/A709A4EA-F897-11E2-9738-89683970C0C4.img?q=88528\",\"mediaGUID\": \"b10c5443-485b-4a8c-a494-4ecad8ae310a\",\"mediaType\": \"Photo\",\"mediaURL\": \"http://192.168.1.7:8080/mci_images/image_3.png\",\"mediaTitle\": \"MCIDemo\",\"mediaDescription\": \"This is for demo only\"}]";
//        NSLog(@"server response=%@", responseString);
//        JSONDecoder* decoder = [[JSONDecoder alloc] init];
//        NSDictionary *resultsDictionary = [decoder objectWithData:response1];
        
    //    NSLog(@"resultsDictionary=%@", resultsDictionary);
    }
    else
    {
        UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"Server Error" message:@"Please check your Internet Connection and try again" delegate:nil cancelButtonTitle:@"Continue" otherButtonTitles:nil];
        [alertView show];
    }
}

- (NSArray *)mediaPlayListFromServer:(NSString *)deviceToken
{
    NSLog(@"mediaPlayListFromServer");
    NSString *urlString = [[NSMutableString alloc] initWithString:MEDIA_PLAY_LIST_URL];
//    NSLog(@"\n\n urlString=%@", urlString);
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:urlString]
                                                           cachePolicy:NSURLRequestReloadIgnoringLocalAndRemoteCacheData
                                                       timeoutInterval:10];
    
    [request setValue:[NSString stringWithFormat:@"%@", deviceToken] forHTTPHeaderField:@"Kobj-Session"];
    [request setHTTPMethod:@"GET"];
//    NSLog(@"request:%@", [request description]);
    NSError *requestError;
    NSURLResponse *urlResponse = nil;
    
    NSData *response1 = [NSURLConnection sendSynchronousRequest:request returningResponse:&urlResponse error:&requestError];
    
    if ( response1 )
    {
        NSString *responseString = [[NSString alloc] initWithData:response1 encoding:NSUTF8StringEncoding];
//        responseString = @"";
        NSLog(@"server response=%@", responseString);

        if ( [responseString rangeOfString:@"Module z169x127"].length > 0 )
        {
            UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"Server Error" message:@"Please check your Internet Connection and try again" delegate:nil cancelButtonTitle:@"Continue" otherButtonTitles:nil];
            [alertView show];
        }
        else
        {
            JSONDecoder* decoder = [[JSONDecoder alloc] init];
            NSArray *resultsArray = [decoder objectWithData:response1];
            //    response1 = [responseString dataUsingEncoding:NSUTF8StringEncoding];
            
            NSLog(@"resultsArrary=%@", resultsArray);
            return resultsArray;
        }
    }
    else
    {
        UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"Server Error" message:@"Please check your Internet Connection and try again" delegate:nil cancelButtonTitle:@"Continue" otherButtonTitles:nil];
        [alertView show];
        return nil;
    }
}

- (NSArray *)listDevicesFromServer
{
    NSLog(@"listDevicesFromServer");
    NSString *urlString = [[NSMutableString alloc] initWithString:LIST_DEVICE_URL];
//    NSLog(@"\n\n urlString=%@", urlString);
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:urlString]
                                                           cachePolicy:NSURLRequestReloadIgnoringLocalAndRemoteCacheData
                                                       timeoutInterval:10];
    
    [request setValue:[NSString stringWithFormat:@"%@", [[NSUserDefaults standardUserDefaults] objectForKey:OWNER_SESSION_TOKEN_KEY]] forHTTPHeaderField:@"Kobj-Session"];
    [request setHTTPMethod:@"GET"];
//    NSLog(@"request:%@", [request description]);
    NSError *requestError;
    NSURLResponse *urlResponse = nil;
    
    NSData *response1 = [NSURLConnection sendSynchronousRequest:request returningResponse:&urlResponse error:&requestError];
    
    if ( response1 )
    {
        NSString *responseString = [[NSString alloc] initWithData:response1 encoding:NSUTF8StringEncoding];
        //    responseString = @"\"{\"mediaCoverArt\": \"https://s3.amazonaws.com/k-mycloud/a169x672/A709A4EA-F897-11E2-9738-89683970C0C4.img?q=88528\",\"mediaGUID\": \"1DDE8D87-5C60-4B40-AEDB-DDD89B0D2655\",\"mediaType\": \"Video\",\"mediaURL\": \"http://www.youtube.com/watch?v=l-qSATlrlMA\",\"mediaTitle\": \"Kid Rock\",\"mediaDescription\": \" Kid Rock tribute to Johnny Cash\"},{\"mediaCoverArt\": \"https://s3.amazonaws.com/k-mycloud/a169x672/A709A4EA-F897-11E2-9738-89683970C0C4.img?q=88528\",\"mediaGUID\": \"b10c5443-485b-4a8c-a494-4ecad8ae310a\",\"mediaType\": \"Photo\",\"mediaURL\": \"http://192.168.1.7:8080/mci_images/image_3.png\",\"mediaTitle\": \"MCIDemo\",\"mediaDescription\": \"This is for demo only\"}";
//        NSLog(@"DEVICE server response=%@", responseString);
        JSONDecoder* decoder = [[JSONDecoder alloc] init];
        //    response1 = [responseString dataUsingEncoding:NSUTF8StringEncoding];
        //    NSData *responseData = [responseString dataUsingEncoding:NSUTF8StringEncoding];
        NSArray *resultsArray = [decoder objectWithData:response1];
        //    NSDictionary *resultsDictionary = [decoder objectWithData:responseData];
        //    NSArray *resultsArray = [resultsDictionary objectForKey:@""];
        //    NSLog(@"resultsDictionary=%@", resultsArray);
        //    NSMutableArray *resultArray = [[NSMutableArray alloc] init];
    //    NSLog(@"resultsArray count =%d", [resultsArray count]);
        if ( [responseString rangeOfString:@"Module a169x727"].length > 0 )
        {
            UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"Server Error" message:@"Please check your Internet Connection and try again" delegate:nil cancelButtonTitle:@"Continue" otherButtonTitles:nil];
            [alertView show];
        }
        else
        {
            return  resultsArray;
        }
    }
    else
    {
        UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"Server Error" message:@"Please check your Internet Connection and try again" delegate:nil cancelButtonTitle:@"Continue" otherButtonTitles:nil];
        [alertView show];
        return nil;
    }
}

@end
