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
//  FPPresenter.m
//  MDFPresenter
//
//  Created by Mark DiFranco on 2013-02-27.
//
//

#import "MDFPresenter.h"

//==========================================================
// - MDFPresentingObject
//==========================================================

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

@end

//==========================================================
// - MDFPresenter
//==========================================================

@interface MDFPresenter() {
   BOOL isPresenting;
}

@property (nonatomic, retain) NSMutableArray *presentationQueue; //A queue of presenting objects which contain view controllers to display

@end

@implementation MDFPresenter

#pragma mark - Constructors/Destructors

+ (MDFPresenter *)instance {
   static MDFPresenter *_instance = nil;
   static dispatch_once_t onceToken = 0;
   dispatch_once(&onceToken, ^{
      _instance = [[MDFPresenter alloc] init];
   });
   return _instance;
}

- (id)init {
   self = [super init];
   if(self) {
      self.presentationQueue = [NSMutableArray array];
   }
   return self;
}

- (void)dealloc {
   // This object lives for the entire life of the application.
   NSAssert(NO, @"Should not have deallocated a singleton");
   [super dealloc];
}

#pragma mark - Class Methods

+ (BOOL)hasModalOpen {
   UIViewController *rootViewController = [[[UIApplication sharedApplication] keyWindow] rootViewController];
   BOOL modalOpen = NO;
   
   if([rootViewController respondsToSelector:@selector(presentedViewController)]) {
      modalOpen = (rootViewController.presentedViewController != nil);
   }
   
   return modalOpen;
}

+ (UIView*)topView {
   UIView *view = [[MDFPresenter topModalViewController] view];
   while (view.superview != nil) {
      view = view.superview;
   }
   return view;
}

+ (UIViewController*)topModalViewController {
   
   UIViewController *topViewController = [MDFPresenter rootModalViewController];
   
   while(nil != topViewController.presentedViewController) {
      topViewController = topViewController.presentedViewController;
   }
   
   return topViewController;
}

+ (UIViewController*)rootModalViewController {
   UIWindow *topWindow = [[UIApplication sharedApplication] keyWindow];
   if (topWindow.windowLevel != UIWindowLevelNormal) {
      NSArray *windows = [[UIApplication sharedApplication] windows];
      for(topWindow in windows) {
         if (topWindow.windowLevel == UIWindowLevelNormal)
            break;
      }
   }
   return [topWindow rootViewController];
}

+ (void)presentModalViewControllerInNavigationController:(UIViewController *)viewController animated:(BOOL)aniamted completion:(BasicBlock)completion {
   UINavigationController *navigationController = [[[UINavigationController alloc] initWithRootViewController:viewController] autorelease];
   [MDFPresenter presentModalViewController:navigationController animated:aniamted completion:completion];
}

+ (void)presentModalViewController:(UIViewController *)viewController animated:(BOOL)animated completion:(BasicBlock)completion {
   MDFPresentingObject *object = [MDFPresentingObject objectWithViewController:viewController animation:animated presentationStyle:FPPresentationStylePresentModal completion:completion];
   [[MDFPresenter instance] presentObject:object];
}

+ (void)dismissModalViewControllerAnimated:(BOOL)animated completion:(BasicBlock)completion {
   
   MDFPresentingObject *object = [MDFPresentingObject objectWithViewController:nil animation:animated presentationStyle:FPPresentationStyleDismiss completion:completion];
   [[MDFPresenter instance] presentObject:object];
}

+ (void)dismissAllModalViewControllersAnimated:(BOOL)animated completion:(BasicBlock)completion {
   
   MDFPresentingObject *object = [MDFPresentingObject objectWithViewController:nil animation:animated presentationStyle:FPPresentationStyleDismissAll completion:completion];
   [[MDFPresenter instance] presentObject:object];
}

#pragma mark - Instance Methods

#pragma mark Private

- (void)presentObject:(MDFPresentingObject*)object {
   [self.presentationQueue addObject:object];
   [self executePresentationQueue];
}

//This will start the presentation ball rolling if it's not presenting anything, otherwise its already going, so do nothing
- (void)executePresentationQueue {
   
   if(![NSThread isMainThread]) {
      [self performSelectorOnMainThread:@selector(executePresentationQueue) withObject:nil waitUntilDone:NO];
      return;
   }

   if(!isPresenting && self.presentationQueue.count > 0) {
      
      isPresenting = YES;
      MDFPresentingObject *object = [self.presentationQueue objectAtIndex:0];
      
      UIViewController *topViewController = [MDFPresenter topModalViewController];
      
      //End actions
      void (^endBlock)(void) = ^(void) {
         object.completion ? object.completion() : nil;
         
         [[[MDFPresenter instance] presentationQueue] removeObject:object];
         
         isPresenting = NO;
         
         //Recursively call to make sure the queue gets emptied.
         [[MDFPresenter instance] executePresentationQueue];
      };

      //Switch based on presentation style
      switch (object.presentationStyle) {
         case FPPresentationStylePresentModal:
            if(object.viewController != nil) {
               [topViewController presentViewController:object.viewController animated:object.animated completion:endBlock];
            }
            break;
         case FPPresentationStylePresentFade:
            if(object.viewController != nil) {
               object.viewController.modalTransitionStyle = UIModalTransitionStyleCrossDissolve;
               [topViewController presentViewController:object.viewController animated:object.animated completion:endBlock];
            }
            break;
         case FPPresentationStyleDismiss:
            if(topViewController.presentingViewController != nil) {
               [topViewController dismissViewControllerAnimated:object.animated completion:endBlock];//Automatically gets forwarded to the presenting VC
            } else {
               endBlock(); //completion does not get called if there is no presentingViewController
            }
            break;
         case FPPresentationStyleDismissAll: {
               UIViewController *rootModalViewController = [MDFPresenter rootModalViewController];
               if([rootModalViewController presentedViewController] != nil) {
                  [rootModalViewController dismissViewControllerAnimated:object.animated completion:endBlock];
               } else {
                  endBlock(); //completion does not get called if there is no presentedViewController
               }
               break;
            }
            
         default:
            break;
      }
   }
}

@end
