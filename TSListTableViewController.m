//
//  TSListTableViewController.m
//  TSCategories
//
//  Created by Awais Hussain on 7/25/13.
//  Copyright (c) 2013 TimeStamp. All rights reserved.
//

#import "TSListTableViewController.h"
#import "TSListTableViewCell.h"
#import "TSCategoryStore.h"
#import "TSCategory.h"
#import "TSSlidableCell.h"
#import "MyAlertViewDelegate.h"

@interface TSListTableViewController ()

@end

@implementation TSListTableViewController

- (id)initWithStyle:(UITableViewStyle)style
{
    self = [super initWithStyle:style];
    if (self) {
        // Custom initialization
        self.tableView.showsVerticalScrollIndicator = NO;
    }
    return self;
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    
//    self.tableView.frame = CGRectMake(95, 0, 130, self.view.frame.size.height);
//    NSLog(@"Table View frame: (%f,%f,%f,%f)", self.view.frame.origin.x, self.view.frame.origin.y, self.view.frame.size.width, self.view.frame.size.height);
}

- (void)viewDidLoad
{
    [super viewDidLoad];

	/*
     Populate array.
	 */
	if (categoryArray == nil) {
		categoryArray = [[[TSCategoryStore instance] data] mutableCopy];
	}
    
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

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    // Return the number of sections.
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    // Return the number of rows in the section.
    return categoryArray.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Configure the table view
//    tableView.backgroundColor = [UIColor clearColor];
    
    return [self configuredCellatIndexPath:indexPath];
}

// should be identical to cell returned in -tableView:cellForRowAtIndexPath:
- (UITableViewCell *)cellIdenticalToCellAtIndexPath:(NSIndexPath *)indexPath forDragTableViewController:(ATSDragToReorderTableViewController *)dragTableViewController {
	
	return [self configuredCellatIndexPath:indexPath];
}

- (TSListTableViewCell *)configuredCellatIndexPath:(NSIndexPath *)indexPath {
    
    /*
     NOTE: Really, we should be reusing cells. However, since the table is likely
     to be very small (<20 cells) we're going to create each cell fresh. When I try to reuse
     cells, they don't display correctly. I think there's a problem with the 'reset' process,
     old views are left over when the cell is reused.
     */
    static NSString *CellIdentifier = @"Cell";
    TSListTableViewCell *cell = [[TSListTableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];

    CGRect cellFrame = CGRectMake(cell.frame.origin.x, cell.frame.origin.y, cell.frame.size.width, BOX_HEIGHT);
    
    // Load Data
    TSCategory *category = [categoryArray objectAtIndex:indexPath.row];
    
    // Configure the cell...
    cell.delegate = self;
    cell.textLabel.text = category.title;
    cell.contentView.backgroundColor = category.color;
    cell.textLabel.textColor = [UIColor whiteColor];
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    
//    UIView *background = [[UIView alloc] initWithFrame:cellFrame];
//    background.backgroundColor = [UIColor greenColor];
//    cell.backgroundView = background;
    
    // Set the background color for when cell is selected
    UIView *purpleBackground = [[UIView alloc] initWithFrame:cellFrame];
    purpleBackground.backgroundColor = [UIColor purpleColor];
    cell.selectedBackgroundView = purpleBackground;
    
    // Set the view that appears when the cell is slid out the way
    UIView *orangeBackground = [[UIView alloc] initWithFrame:cellFrame];
    orangeBackground.backgroundColor = [UIColor orangeColor];
    cell.slideToLeftView = orangeBackground;
    
    UIView *redBackground = [[UIView alloc] initWithFrame:cellFrame];
    redBackground.backgroundColor = [UIColor redColor];
    cell.slideToLeftHighlightedView = redBackground;
    
    return cell;
}

/*
// Override to support conditional editing of the table view.
- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Return NO if you do not want the specified item to be editable.
    BOOL edit = (indexPath.row == 0) ? YES : NO;
    return edit;
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

#pragma mark - Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Navigation logic may go here. Create and push another view controller.
    /*
     <#DetailViewController#> *detailViewController = [[<#DetailViewController#> alloc] initWithNibName:@"<#Nib name#>" bundle:nil];
     // ...
     // Pass the selected object to the new view controller.
     [self.navigationController pushViewController:detailViewController animated:YES];
     */
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return BOX_HEIGHT;
}

/*
 Required for drag tableview controller
 */
- (void)tableView:(UITableView *)tableView moveRowAtIndexPath:(NSIndexPath *)fromIndexPath toIndexPath:(NSIndexPath *)toIndexPath {
	
	NSString *itemToMove = [categoryArray objectAtIndex:fromIndexPath.row];
	[categoryArray removeObjectAtIndex:fromIndexPath.row];
	[categoryArray insertObject:itemToMove atIndex:toIndexPath.row];
    
}

#pragma mark - TSSlideToDeleteDelegate
- (void)respondToCellSlidLeft:(TSSlidableCell *)cell {
    NSString *prompt = @"Are you sure you want to delete this activity?";
    NSString *info = @"This won't delete any of your calendar events";
    
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:prompt message:info delegate:self cancelButtonTitle:@"Cancel" otherButtonTitles:@"Delete", nil];
    
    [MyAlertViewDelegate showAlertView:alert withCallback:^(NSInteger buttonIndex) {
        // code to take action depending on the value of buttonIndex
        NSLog(@"Alert view button pushed");
        if (buttonIndex == 1) {
            // Delete button pushed
            NSIndexPath *indexPath = [self.tableView indexPathForCell:cell];
            // Call model to delete cell.
            [categoryArray removeObjectAtIndex:indexPath.row];
            [self.tableView deleteRowsAtIndexPaths:[NSArray arrayWithObject:indexPath] withRowAnimation:UITableViewRowAnimationTop];
        } else {
            // Reset the cell. Re-animate it back on scree
        }
    }];
}

- (IBAction)addNewCategory:(id)sender {
}

@end
