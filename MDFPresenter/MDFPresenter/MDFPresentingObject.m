/*
 The MIT License (MIT)
 
 Copyright (c) 2013 Mark DiFranco
 
 Permission is hereby granted, free of charge, to any person obtaining a copy
 of this software and associated documentation files (the "Software"), to deal
 in the Software without restriction, including without limitation the rights
 to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
 copies of the Software, and to permit persons to whom the Software is
 furnished to do so, subject to the following conditions:
 
 The above copyright notice and this permission notice shall be included in
 all copies or substantial portions of the Software.
 
 THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
 IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
 FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
 AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
 LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
 OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
 THE SOFTWARE.
 */

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
