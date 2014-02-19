//
//  MRVDetailViewController.h
//  RandomLunchPlaceSelector
//
//  Created by M. Randall VandenHoek on 6/22/13.
//  Copyright (c) 2013 RFR. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface MRVDetailViewController : UIViewController

@property (strong, nonatomic) id detailItem;



@property (weak, nonatomic) IBOutlet UITextField *detailDescription;

@property (weak, nonatomic) UIButton *updateButton;

@property (weak, nonatomic) IBOutlet UINavigationItem *navigationBarTitle;
@property (weak, nonatomic) IBOutlet UIButton *deleteButton;


-(IBAction)updatePressed:(UIButton *)sender;
-(IBAction)clearPressed:(UIButton *)sender;
-(IBAction)deletePressed:(UIButton *)sender;


@end
