//
//  MRVMasterViewController.m
//  RandomLunchPlaceSelector
//
//  Created by M. Randall VandenHoek on 6/22/13.
//  Copyright (c) 2013 RFR. All rights reserved.
//

#import "MRVMasterViewController.h"

#import "MRVDetailViewController.h"

#import <sqlite3.h>

@interface MRVMasterViewController () {
    NSMutableArray *_objects;
    NSMutableArray *_lunchPlaceID;
    
    NSMutableDictionary  *_lunchPlaceSelect;
}
@end

@implementation MRVMasterViewController


-(NSString *)dataFilePath
{
    NSArray *paths = NSSearchPathForDirectoriesInDomains(
                                                         NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documentsDirectory = [paths objectAtIndex:0];
    return [documentsDirectory stringByAppendingPathComponent:@"data.sqlite"];
}



- (void)awakeFromNib
{
    [super awakeFromNib];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
}


-(void)configureView
{
    sqlite3 *database;
    
    if (sqlite3_open([[self dataFilePath] UTF8String], &database)
        != SQLITE_OK) {
        sqlite3_close(database);
        NSAssert(0, @"Failed to open database");
    }
    
    _objects = [[NSMutableArray alloc] init];
    _lunchPlaceID = [[NSMutableArray alloc] init];
    
    NSString *createSQL = @"CREATE TABLE IF NOT EXISTS PLACES "
                           "(ROWID INTEGER PRIMARY KEY, FIELD_DATA TEXT)";
    char *errorMsg;
    if (sqlite3_exec(database, [createSQL UTF8String] ,
                     NULL, NULL, &errorMsg) != SQLITE_OK) {
        sqlite3_close(database);
        NSAssert(0, @"Error creating table: %s", errorMsg);
    }

    NSString *query = @"SELECT ROWID, FIELD_DATA FROM PLACES ";
    sqlite3_stmt *statement;
    if (sqlite3_prepare_v2(database, [query UTF8String],
                           -1, &statement, nil) == SQLITE_OK)
    {
        while  (sqlite3_step(statement) == SQLITE_ROW)
        {
            int row = sqlite3_column_int(statement, 0) ;
            char *rowData = (char *)sqlite3_column_text(statement, 1);
            NSString *fieldValue = [[NSString alloc]
                                    initWithUTF8String:rowData];
            NSString *theId = [NSString stringWithFormat:@"%d",row];
            [_lunchPlaceID addObject:theId];
            [_objects addObject:fieldValue];
            //NSLog(@"Lunch Id %@", theId);
            //NSLog(@"Lunch Place %@", fieldValue);
        }
    }
    sqlite3_close(database);
   
    _lunchPlaceSelect = [[NSMutableDictionary alloc] init];
    
    //[_lunchPlaceSelect initWithObjects:_objects forKeys:_lunchPlaceID];
    
    NSUInteger placeCount = [_objects count];
    
    for (NSUInteger IIIII = 0; IIIII < placeCount; IIIII++){
        //NSLog(@"Place Name %@", [_objects objectAtIndex:IIIII]);
        NSString *strIIIII = [NSString stringWithFormat:@"%d", IIIII];
        [_lunchPlaceSelect setObject:[_objects objectAtIndex:IIIII] forKey:strIIIII];
    }
}


-(void)viewWillAppear:(BOOL)animated{
    [self configureView];
    
    [[self tableView] reloadData];
}


- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


#pragma mark - Table View

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return _objects.count;
}


- (UITableViewCell *)tableView:(UITableView *)tableView
         cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"Cell"
                                                            forIndexPath:indexPath];
    cell.textLabel.text = [_objects objectAtIndex:indexPath.row];
    return cell;
}

- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Return NO if you do not want the specified item to be editable.
    return NO;
}


- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if ([[segue identifier] isEqualToString:@"showDetail"]) {
        NSIndexPath *indexPath = [self.tableView indexPathForSelectedRow];
        NSString *placeId = _lunchPlaceID[indexPath.row];
       // NSLog(@"The place is %@", placeName);
       // NSLog(@"The ID is %@", placeId);
        [[segue destinationViewController] setDetailItem:placeId];
    }
    
    if ([[segue identifier] isEqualToString:@"newDetail"]) {
        [[segue destinationViewController] setDetailItem:@"0"];
    }
}

- (IBAction)selectRandom:(UIBarButtonItem *)sender
{
    if ([_lunchPlaceSelect count ] > 0)
    {
    int newValue = random() % [_lunchPlaceSelect count];

    NSString *selected = [_lunchPlaceSelect objectForKey:[NSString stringWithFormat:@"%d", newValue]];
    UIAlertView *alert =[[UIAlertView alloc]
                         initWithTitle:@"The selected lunch place is: "
                         message:selected
                         delegate:self
                         cancelButtonTitle:@"OK"
                         otherButtonTitles:nil];
    [alert show];
    } else {
        UIAlertView *noEntry = [[UIAlertView alloc]
                                initWithTitle:@"No places in list"
                                message:@"You need to enter some lunch places"
                                delegate:self
                                cancelButtonTitle:@"OK"
                                otherButtonTitles: nil];
        [noEntry show];
    }
}


@end
