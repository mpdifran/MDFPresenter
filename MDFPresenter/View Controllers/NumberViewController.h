//
//  NumberViewController.h
//  MDFPresenter
//
//  Created by Mark DiFranco on 2013-06-01.
//  Copyright (c) 2013 MDF Projects. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface NumberViewController : UIViewController

+ (NumberViewController*)controllerWithNumber:(NSUInteger)number;
- (id)initWithNumber:(NSUInteger)number;

@end
