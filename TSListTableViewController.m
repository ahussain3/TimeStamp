//
//  TSListTableViewController.m
//  TSCategories
//
//  Created by Awais Hussain on 7/25/13.
//  Copyright (c) 2013 TimeStamp. All rights reserved.
//

#import "TSListTableViewController.h"
#import "TSListTableViewCell.h"
#import "TSAddNewTableViewCell.h"
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
}

- (void)viewDidLoad
{
    [super viewDidLoad];

    // Populate local array
	model = [TSCategoryStore instance];
    [self reloadData];
    
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

- (void)reloadData {
    // Populate local array.
    categoryArray = [[model dataForPath:self.path] mutableCopy];
    NSLog(@"Get category for path: %@", self.path);
    rootCategory = [model categoryForPath:self.path];
    NSLog(@"root category: %@", rootCategory);
    [self.tableView reloadData];
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
    return categoryArray.count + 1;
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
    
    if (indexPath.row == 0) {
        return  [self returnAddTableViewCell];
    }
    
    /*
     NOTE: Really, we should be reusing cells. However, since the table is likely
     to be very small (<20 cells) we're going to create each cell fresh. When I try to reuse
     cells, they don't display correctly. I think there's a problem with the 'reset' process,
     old views are left over when the cell is reused.
     */
    static NSString *CellIdentifier = @"Cell";
    TSListTableViewCell *cell = [[TSListTableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
    
    // Load Data
    TSCategory *category = [categoryArray objectAtIndex:indexPath.row - 1];
    
    // Configure the cell...
    CGRect cellFrame = CGRectMake(cell.frame.origin.x, cell.frame.origin.y, BOX_WIDTH, BOX_HEIGHT);
    
    cell.textLabel.text = category.title;
    cell.contentView.backgroundColor = category.color;
    cell.textLabel.textColor = [UIColor whiteColor];
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    cell.category = category;
    
    // Set the background color for when cell is selected
//    UIView *purpleBackground = [[UIView alloc] initWithFrame:cellFrame];
//    purpleBackground.backgroundColor = [UIColor purpleColor];
//    cell.selectedBackgroundView = purpleBackground;
    
    // Set the view that appears when the cell is slid out the way
//    UIView *orangeBackground = [[UIView alloc] initWithFrame:cellFrame];
//    orangeBackground.backgroundColor = [UIColor orangeColor];
//    cell.slideToLeftView = orangeBackground;
//    UIView *redBackground = [[UIView alloc] initWithFrame:cellFrame];
//    redBackground.backgroundColor = [UIColor redColor];
//    cell.slideToLeftHighlightedView = redBackground;
    
    UIImage *grey_cross = [UIImage imageNamed:@"grey_cross"];
    UIImageView *greyCrossView = [[UIImageView alloc] initWithImage:grey_cross];
    greyCrossView.frame = cellFrame;
    cell.slideToLeftView = greyCrossView;
    
    UIImage *grey_cross_red = [UIImage imageNamed:@"grey_cross_red_glow"];
    UIImageView *greyCrossRedView = [[UIImageView alloc] initWithImage:grey_cross_red];
    greyCrossRedView.frame = cellFrame;
    cell.slideToLeftHighlightedView = greyCrossRedView;
    
    cell.slideToLeftView.hidden = NO;
    cell.slideToLeftHighlightedView.hidden = YES;
    
    cell.deleteDelegate = self;
    
    return cell;
}

- (TSAddNewTableViewCell *)returnAddTableViewCell {
    static NSString *CellID = @"Add Category";
    TSAddNewTableViewCell * cell = [[TSAddNewTableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellID];
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    cell.textLabel.text = @"+Add New";
    cell.addDelegate = self;
    
    if ([self.path isEqualToString:ROOT_CATEGORY_PATH]) {
        cell.contentView.backgroundColor = [UIColor grayColor];
    } else {
        cell.contentView.backgroundColor = rootCategory.color;
    }
    
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
    if (indexPath.row == 0) return;
    
    // Navigation logic may go here. Create and push another view controller.
    UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"MainStoryboard" bundle:nil];
    TSListTableViewController *nextController = [storyboard instantiateViewControllerWithIdentifier:@"ListViewController"];
    
    TSCategory *selectedCategory = [categoryArray objectAtIndex:indexPath.row - 1];
    nextController.path = [self.path stringByAppendingFormat:@":%@",selectedCategory.title];
    nextController.dragDelegate = self.dragDelegate;
    
    [self.navigationController pushViewController:nextController animated:YES];
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return BOX_HEIGHT;
}

/*
 Required for drag tableview controller
 */
- (void)tableView:(UITableView *)tableView moveRowAtIndexPath:(NSIndexPath *)fromIndexPath toIndexPath:(NSIndexPath *)toIndexPath {
	
	[model exchangeCategoryAtIndex:fromIndexPath.row - 1 withIndex:toIndexPath.row - 1 forPath:self.path];
    [self reloadData];
}

#pragma mark - TSSlideToDeleteDelegate
- (void)respondToCellSlidLeft:(TSListTableViewCell *)cell {
//    if (cell.category.subCategories == 0) {
//        [self removeCell:cell];
//    } else {
        NSString *prompt = @"Are you sure you want to delete this activity?";
        NSString *info = @"This will also delete all subcategories. Note: none of your events will be deleted";
        
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:prompt message:info delegate:self cancelButtonTitle:@"Cancel" otherButtonTitles:@"Delete", nil];
        
        [MyAlertViewDelegate showAlertView:alert withCallback:^(NSInteger buttonIndex) {
            // code to take action depending on the value of buttonIndex
            NSLog(@"Alert view button pushed");
            if (buttonIndex == 1) {
                [self removeCell:cell];
            } else {
                // Reset the cell. Re-animate it back on screen
                [cell resetCellToCenter];
            }
        }];        
//    }
}

- (void)removeCell:(TSListTableViewCell *)cell {
    // Delete button pushed
    NSIndexPath *indexPath = [self.tableView indexPathForCell:cell];
    [categoryArray removeObjectAtIndex:indexPath.row - 1];
    [self.tableView deleteRowsAtIndexPaths:[NSArray arrayWithObject:indexPath] withRowAnimation:UITableViewRowAnimationLeft];
    
    // Call model to delete cell.
    [model deleteCategory:cell.category atPath:self.path];
    [self reloadData];
}

- (void)goBack:(id)sender {
    [self.navigationController popViewControllerAnimated:YES];
}

#pragma mark TSAddNewTableViewCellDelegate
- (void)addNewSubcategoryWithString:(NSString *)string {
    NSLog(@"Creating new category: %@", string);
    [[TSCategoryStore instance] addSubcategory:string AtPathLevel:self.path];
    [self reloadData];
}

@end
