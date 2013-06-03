//
//  FPPresentingObject.m
//  MDFPresenter
//
//  Created by Mark DiFranco on 2013-02-27.
//
//

#import "MDFPresentingObject.h"

@implementation MDFPresentingObject

#pragma mark - Class Methods

+ (MDFPresentingObject*)objectWithViewController:(UIViewController*)viewController animation:(BOOL)animation presentationStyle:(FPPresentationStyle)style completion:(BasicBlock)completion {
   MDFPresentingObject *object = [[[MDFPresentingObject alloc] init] autorelease];
   object.viewController = viewController;
   object.animated = animation;
   object.presentationStyle = style;
   object.completion = completion;
   
   return object;
}

- (void)dealloc {
   [_viewController release];
   [_completion release];
   [super dealloc];
}

#pragma mark - Instance Methods

- (void)setCompletion:(BasicBlock)completionBlock {
	[_completion release];
	_completion = [completionBlock copy];
}

- (void)executeCompletion {
   self.completion ? self.completion() : nil;
}

@end
