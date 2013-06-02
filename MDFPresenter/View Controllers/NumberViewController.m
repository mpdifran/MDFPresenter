//
//  NumberViewController.m
//  MDFPresenter
//
//  Created by Mark DiFranco on 2013-06-01.
//  Copyright (c) 2013 MDF Projects. All rights reserved.
//

#import "NumberViewController.h"
#import "MDFPresenter.h"

@interface NumberViewController ()

@property (nonatomic, readwrite) NSUInteger number;

@property (retain, nonatomic) IBOutlet UILabel *numberLabel;

@end

@implementation NumberViewController

#pragma mark - Constructors/Destructors

- (id)initWithNumber:(NSUInteger)number {
    self = [super initWithNibName:@"NumberViewController" bundle:nil];
    if (self) {
       self.number = number;
    }
    return self;
}

+ (NumberViewController*)controllerWithNumber:(NSUInteger)number {
   NumberViewController *numberVC = [[[NumberViewController alloc] initWithNumber:number] autorelease];
   return numberVC;
}

- (void)dealloc {
   [_numberLabel release];
   [super dealloc];
}

#pragma mark - View Lifecycle

- (void)viewDidLoad {
   [super viewDidLoad];
   self.numberLabel.text = [NSString stringWithFormat:@"%d", self.number];
   
   UIBarButtonItem *doneButton = [[UIBarButtonItem alloc] initWithTitle:@"Done" style:UIBarButtonItemStyleDone target:self action:@selector(doneClicked)];
   self.navigationItem.rightBarButtonItem = doneButton;
   [doneButton release];
}

#pragma mark - UIButton Methods

- (void)doneClicked {
   [[MDFPresenter instance] dismissAllModalViewControllersAnimated:YES completion:nil];
}

@end
