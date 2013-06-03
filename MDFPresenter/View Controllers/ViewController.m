//
//  ViewController.m
//  MDFPresenter
//
//  Created by Mark DiFranco on 2013-06-01.
//  Copyright (c) 2013 MDF Projects. All rights reserved.
//

#import "ViewController.h"
#import "NumberViewController.h"
#import "MDFPresenter.h"

@interface ViewController ()

@end

@implementation ViewController

#pragma mark - View Lifecycle

- (void)viewDidLoad {
    [super viewDidLoad];
	// Do any additional setup after loading the view, typically from a nib.
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Instance Methods

- (void)simultaneouslyPresentViewControllers:(NSUInteger)number {
   for(int i = 0; i < number; i++) {
      [MDFPresenter presentModalViewControllerInNavigationController:[NumberViewController controllerWithNumber:i+1] animated:YES completion:nil];
   }
}

#pragma mark - IBActions

- (IBAction)twoButtonPressed:(UIButton *)sender {
   [self simultaneouslyPresentViewControllers:2];
}

- (IBAction)threeButtonPressed:(UIButton *)sender {
   [self simultaneouslyPresentViewControllers:3];
}

- (IBAction)fourButtonPressed:(UIButton *)sender {
   [self simultaneouslyPresentViewControllers:4];
}

@end
