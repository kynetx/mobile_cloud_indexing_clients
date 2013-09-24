//
//  KXMediaListViewController.m
//  Mobile Cloud Index
//
//  Created by Lynn Shepherd on 8/28/13.
//  Copyright (c) 2013 Kynetx. All rights reserved.
//

#import "KXMediaDeviceListViewController.h"
#import "Devices+Accessors.h"

@interface KXMediaDeviceListViewController ()

@property (nonatomic, assign) NSUInteger mediaType;
@property (strong, nonatomic) NSMutableArray *assetItems;
@property (assign, nonatomic) CGSize popoverSize;

@end

@implementation KXMediaDeviceListViewController

- (id)initWithManagedObjectContext:(NSManagedObjectContext *)context withSize:(CGSize)popoverSize andDelegate:(id)delegate
{
    self = [super init];
    if ( self )
    {
        self.managedObjectContext = context;
        self.popoverSize = popoverSize;
        self.delegate = delegate;
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];

//    self.title = @"Device";
	self.navigationItem.title = @"Devices";
    
    if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPhone)
    {
        self.view.backgroundColor = [UIColor whiteColor]; //[UIColor colorWithRed:0.062 green:0.13 blue:0.24 alpha:1.0];
        
        self.navigationController.navigationBar.tintColor = [UIColor colorWithRed:0.062 green:0.13 blue:0.24 alpha:1.0];
        self.tableView.backgroundColor = [UIColor whiteColor];  //[UIColor colorWithRed:0.062 green:0.13 blue:0.24 alpha:1.0];
        [self.tableView setSeparatorStyle:UITableViewCellSeparatorStyleNone];
    }
    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
 
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
    
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    
//    self.tableView.frame = CGRectMake(0.0, 0.0, _popoverSize.width, _popoverSize.height);
//    self.tableView.frame = CGRectMake(0.0, 0.0, 320.0, 480.0);
    if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPad)
    {
        self.contentSizeForViewInPopover = _popoverSize;//CGSizeMake(320.0, 480.0);//_popoverSize;
    }
    self.tableView.scrollEnabled = NO;
    self.tableView.hidden = NO;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (NSArray *)getSortDescriptors
{
    NSSortDescriptor *sortDescriptor = [[NSSortDescriptor alloc] initWithKey:@"deviceName" ascending:YES];
    return @[sortDescriptor];
}

- (NSString *)getEntityName
{
    return @"Devices";
}

- (NSPredicate *)getPredicate
{
    return nil; //[NSPredicate predicateWithFormat:@"%K == %@", @"fromDevice", [NSNumber numberWithBool:YES]];
}

#pragma mark - Table view data source

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"Cell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
    }
    
    [self configureCell:cell atIndexPath:indexPath];
    
    return cell;
}

- (void)configureCell:(UITableViewCell *)cell atIndexPath:(NSIndexPath *)indexPath
{
    Devices *device = [self.fetchedResultsController objectAtIndexPath:indexPath];
    
    UIImageView *checkmarkView = [[UIImageView alloc] initWithFrame:CGRectMake(280.0, 10.0, 30.0, 30.0)];
    checkmarkView.contentMode = UIViewContentModeScaleAspectFit;
    checkmarkView.image = [UIImage imageNamed:@"check3.png"];
    [cell.contentView addSubview:checkmarkView];

    if ( [device.deviceChannel isEqualToString:[[NSUserDefaults standardUserDefaults] objectForKey:CURRENT_DEVICE_KEY]])
    {
        checkmarkView.hidden = NO;
////        [cell setAccessoryType:UITableViewCellAccessoryCheckmark];
////        cell.accessoryView.backgroundColor = [UIColor whiteColor];
//        cell.contentView.backgroundColor = [UIColor whiteColor];
    }
    else
    {
        checkmarkView.hidden = YES;
//        [cell setAccessoryType:UITableViewCellAccessoryNone];
    }
    
    UIImageView *thumbnailView = [[UIImageView alloc] initWithFrame:CGRectMake(10.0, 10.0, 30.0, 30.0)];
    thumbnailView.contentMode = UIViewContentModeScaleAspectFit;
    [[thumbnailView layer] setBorderWidth:1.0];
    [thumbnailView setClipsToBounds:YES];
    //    thumbnailView.backgroundColor = [UIColor redColor];
    
    if ( [device.deviceIcon length] > 0 )
    {
        thumbnailView.image = [UIImage imageWithData:[NSData dataWithContentsOfURL:[NSURL URLWithString:device.deviceIcon]]];
    }
    else
    {
        thumbnailView.image = [UIImage imageNamed:@"32-iphone.png"];
    }
    
    [cell.contentView addSubview:thumbnailView];
    cell.contentView.backgroundColor = [UIColor whiteColor];
    
    UILabel *titleLabel = [[UILabel alloc] initWithFrame:CGRectMake(50.0, 15.0, 200.0, 20.0)];
    titleLabel.backgroundColor = [UIColor clearColor];
    titleLabel.text = device.deviceName;
    [cell.contentView addSubview:titleLabel];
}

/*
// Override to support conditional editing of the table view.
- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Return NO if you do not want the specified item to be editable.
    return YES;
}
*/

/*
// Override to support editing the table view.
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        // Delete the row from the data source
        [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
    }   
    else if (editingStyle == UITableViewCellEditingStyleInsert) {
        // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
    }   
}
*/

/*
// Override to support rearranging the table view.
- (void)tableView:(UITableView *)tableView moveRowAtIndexPath:(NSIndexPath *)fromIndexPath toIndexPath:(NSIndexPath *)toIndexPath
{
}
*/

/*
// Override to support conditional rearranging of the table view.
- (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Return NO if you do not want the item to be re-orderable.
    return YES;
}
*/

#pragma mark - Table view delegate
#pragma mark - Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    // clear checkmarks
    id <NSFetchedResultsSectionInfo> sectionInfo = [[self.fetchedResultsController sections] objectAtIndex:indexPath.section];
	NSInteger numRows = [sectionInfo numberOfObjects];
    
    for ( int i = 0; i < numRows; i++ )
    {
        NSIndexPath *indexPath = [NSIndexPath indexPathForRow:i inSection:0];
        UITableViewCell *cell = [self.tableView cellForRowAtIndexPath:indexPath];
        [cell setAccessoryType:UITableViewCellAccessoryNone];
    }
    
    UITableViewCell *cell = [tableView cellForRowAtIndexPath:indexPath];
    [cell setAccessoryType:UITableViewCellAccessoryCheckmark];
    
    [tableView deselectRowAtIndexPath:indexPath animated:YES];

    Devices *device = [self.fetchedResultsController objectAtIndexPath:indexPath];

    if ( ![device.deviceChannel isEqualToString:[[NSUserDefaults standardUserDefaults] objectForKey:CURRENT_DEVICE_KEY]] )
    {
        [self.delegate selectedDevice:device.deviceChannel];
    }
}

@end
