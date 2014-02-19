//
//  MRVDetailViewController.m
//  RandomLunchPlaceSelector
//
//  Created by M. Randall VandenHoek on 6/22/13.
//  Copyright (c) 2013 RFR. All rights reserved.
//

#import "MRVDetailViewController.h"
#import <sqlite3.h>

@interface MRVDetailViewController ()
- (void)configureView;
@end

@implementation MRVDetailViewController

#pragma mark - Managing the detail item

- (void)setDetailItem:(id)newDetailItem
{
    if (_detailItem != newDetailItem) {
        _detailItem = newDetailItem;
    }
}

-(NSString *)dataFilePath
{
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory,
                                                         NSUserDomainMask,
                                                         YES);
    NSString *documentsDirectory = [paths objectAtIndex:0];
    return [documentsDirectory stringByAppendingPathComponent:@"data.sqlite"];
}
 
- (void)configureView
{
    // Update the user interface for the detail item.
    if ([self.detailItem integerValue] > 0) {
        sqlite3 *database;
        
        if (sqlite3_open([[self dataFilePath] UTF8String], &database)
            != SQLITE_OK) {
            sqlite3_close(database);
            NSAssert(0, @"1: Failed to open database");
        }
        
        NSString *query = @"SELECT ROWID, FIELD_DATA FROM PLACES WHERE ROWID = " ;
        
        query = [query stringByAppendingString:self.detailItem];
        //NSLog(@"The query %@", query);
        
        sqlite3_stmt *statement;
        
        if (sqlite3_prepare_v2(database, [query UTF8String],
                               -1, &statement, nil) == SQLITE_OK)
        {
            while  (sqlite3_step(statement) == SQLITE_ROW)
            {
                //int row = sqlite3_column_int(statement, 0) ;
                char *rowData = (char *)sqlite3_column_text(statement, 1);
                
                NSString *fieldValue = [[NSString alloc]
                                        initWithUTF8String:rowData];
                self.detailDescription.text = fieldValue;
            }
        } else {
           self.detailDescription.text = nil;
        }
    sqlite3_close(database);
    } else {
        self.detailDescription.text = nil;
    }
}

- (void)viewDidLoad
{
    [super viewDidLoad];
 

    
	// Do any additional setup after loading the view, typically from a nib.
    
    [self configureView];
    
    if ([self.detailItem integerValue] > 0) {
        [self.deleteButton setHidden:NO];
        self.navigationBarTitle.title = @"Update";
       
    }
    else
    {
        [self.deleteButton setHidden:YES];
        self.navigationBarTitle.title = @"Add";
    }
    
    
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void)updatePressed:(UIButton *)sender
{
    if (_detailDescription.text.length != 0)
    {
        [self insertUpdate];
    }
    
    if ([self.detailItem integerValue] > 0)
    {
    UINavigationController *navController = self.navigationController;
    [navController popViewControllerAnimated:YES];
    }
}

-(void)insertUpdate
{
    sqlite3 *database;
    if (sqlite3_open([[self dataFilePath] UTF8String], &database)
        != SQLITE_OK) {
        sqlite3_close(database);
        NSAssert(0, @"2: Failed to open database");
    }
    
    if ([self.detailItem integerValue]  == 0)
    {
        char *insertStmt = "INSERT INTO PLACES (FIELD_DATA) VALUES (?);";
        char *errorMsg = NULL;
        sqlite3_stmt *stmt ;
        if (sqlite3_prepare_v2(database, insertStmt, -1, &stmt, nil) == SQLITE_OK) {
            sqlite3_bind_text (stmt, 1, [_detailDescription.text UTF8String], -1, NULL);
            if (sqlite3_step(stmt) != SQLITE_DONE)
                NSAssert (0, @"5: Error updating table: %s", errorMsg);
        }
        
        
        NSString *addMsg = [NSString stringWithFormat:@"%@ \nhas been added to your list", _detailDescription.text];
        
        UIAlertView *alert =[[UIAlertView alloc]
                             initWithTitle:@"Lunch Place Added"
                             message:addMsg
                             delegate:self
                             cancelButtonTitle:@"OK"
                             otherButtonTitles:nil];
        [alert show];
        _detailDescription.text = nil;
    }
    else
    {
        char *updateStmt = "UPDATE PLACES SET FIELD_DATA = ? WHERE ROWID = ? ";
        char *errorMsg = NULL;
        sqlite3_stmt *updStmt;
        if (sqlite3_prepare_v2(database, updateStmt, -1, &updStmt, nil) == SQLITE_OK) {
            int theRow = [_detailItem integerValue];
            //NSLog(@"the id: %d", theRow);
            sqlite3_bind_text (updStmt, 1, [_detailDescription.text UTF8String], -1, NULL);
            //NSLog(@"the descrip %@", _detailDescription.text);
            sqlite3_bind_int(updStmt, 2, theRow);
            if (sqlite3_step(updStmt) != SQLITE_DONE)
                NSAssert (0, @"7: Error updating places table: %s", errorMsg);
        }
    }
    
    sqlite3_close(database);
}


-(IBAction)deletePressed:(UIButton *)sender
{
    sqlite3 *database;
    if (sqlite3_open([[self dataFilePath] UTF8String], &database)
        != SQLITE_OK) {
        sqlite3_close(database);
        NSAssert(0, @"2: Failed to open database");
    }
    
    char *deleteStmt = "DELETE FROM PLACES WHERE ROWID = ? ";
    char *errorMsg = NULL;
    sqlite3_stmt *dltStmt;
    if (sqlite3_prepare_v2(database, deleteStmt, -1, &dltStmt, nil) == SQLITE_OK) {
        int theRow = [_detailItem integerValue];
        //NSLog(@"the id: %d", theRow);
        sqlite3_bind_int(dltStmt, 1, theRow);
        if (sqlite3_step(dltStmt) != SQLITE_DONE)
            NSAssert (0, @"9: Error updating places table: %s", errorMsg);
        sqlite3_finalize(dltStmt);
    }

    
//this code drops table in order to change it or start over.
//    char *theDrop = "DROP TABLE IF EXISTS PLACES";
//    char *errorMsg = NULL;
//    sqlite3_stmt *stmt ;
//    if (sqlite3_prepare_v2(database, theDrop, -1, &stmt, nil) == SQLITE_OK) {
//        if (sqlite3_step(stmt) != SQLITE_DONE)
//            NSAssert (0, @"Error Dropping table: %s", errorMsg);
//    }

    sqlite3_close(database);
    
    UINavigationController *navController = self.navigationController;
    [navController popViewControllerAnimated:YES];
}


-(IBAction)clearPressed:(UIButton *)sender
{
    _detailItem = @"0";
    _detailDescription.text = nil;
    self.navigationBarTitle.title = @"Add";
    [self.deleteButton setHidden:YES];
}



@end
