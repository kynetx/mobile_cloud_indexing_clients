//
//  KXMediaSharedListViewController.m
//  Mobile Cloud Index
//
//  Created by Lynn Shepherd on 8/28/13.
//  Copyright (c) 2013 Kynetx. All rights reserved.
//

#import "KXMediaSharedListViewController.h"

@interface KXMediaSharedListViewController ()

@property (nonatomic, assign) NSUInteger mediaType;
@property (strong, nonatomic) NSMutableArray *assetItems;

@end

@implementation KXMediaSharedListViewController

- (id)initWithManagedObjectContext:(NSManagedObjectContext *)context
{
    self = [super init];
    if ( self )
    {
        self.managedObjectContext = context;
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];

//    self.title = @"Shared";
	self.navigationItem.title = @"Shared";

    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
 
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
    
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (NSArray *)getSortDescriptors
{
    NSSortDescriptor *sortDescriptor = [[NSSortDescriptor alloc] initWithKey:@"title" ascending:YES];
    return @[sortDescriptor];
}

- (NSString *)getEntityName
{
    return @"Media";
}

- (NSPredicate *)getPredicate
{
    return [NSPredicate predicateWithFormat:@"(%K == %@ && %K == %@) OR %K == %@", @"fromDevice", [NSNumber numberWithBool:YES], @"shared", [NSNumber numberWithBool:YES], @"fromDevice", [NSNumber numberWithBool:NO]];
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
    Media *media = [self.fetchedResultsController objectAtIndexPath:indexPath];
    
    [cell setAccessoryType:UITableViewCellAccessoryDisclosureIndicator];
    
    UIImageView *thumbnailView = [[UIImageView alloc] initWithFrame:CGRectMake(10.0, 10.0, 30.0, 30.0)];
    thumbnailView.contentMode = UIViewContentModeScaleAspectFit;
    [[thumbnailView layer] setBorderWidth:1.0];
    [thumbnailView setClipsToBounds:YES];
    //    thumbnailView.backgroundColor = [UIColor redColor];
    
    if ( [media.coverArtPath length] > 0 )
    {
        thumbnailView.image = [UIImage imageWithData:[NSData dataWithContentsOfURL:[NSURL URLWithString:media.coverArtPath]]];
    }
    else
    {
        thumbnailView.image = [UIImage imageNamed:@"56-cloud.png"];
    }
    
    [cell.contentView addSubview:thumbnailView];
    
    UILabel *titleLabel = [[UILabel alloc] initWithFrame:CGRectMake(50.0, 15.0, 200.0, 20.0)];
    titleLabel.backgroundColor = [UIColor clearColor];
    titleLabel.text = media.title;
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

//- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
//{
//    // Navigation logic may go here. Create and push another view controller.
//    /*
//     <#DetailViewController#> *detailViewController = [[<#DetailViewController#> alloc] initWithNibName:@"<#Nib name#>" bundle:nil];
//     // ...
//     // Pass the selected object to the new view controller.
//     [self.navigationController pushViewController:detailViewController animated:YES];
//     */
//}

@end
