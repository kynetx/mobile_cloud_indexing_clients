//
//  KXDetailViewController.h
//  Mobile Cloud Index
//
//  Created by Lynn Shepherd on 8/26/13.
//  Copyright (c) 2013 Kynetx. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface KXDetailViewController : UIViewController <UISplitViewControllerDelegate>

@property (strong, nonatomic) id detailItem;

@property (weak, nonatomic) IBOutlet UILabel *detailDescriptionLabel;
@end
