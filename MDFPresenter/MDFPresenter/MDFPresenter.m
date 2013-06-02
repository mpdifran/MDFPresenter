//
//  FPPresenter.m
//  iFreePhone
//
//  Created by Mark DiFranco on 2013-02-27.
//
//

#import "MDFPresenter.h"
#import "MDFPresentingObject.h"

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

#pragma mark - Instance Methods

#pragma mark Public

- (UIView*)topView {
   UIView *view = [[self topModalViewController] view];
   while (view.superview != nil) {
      view = view.superview;
   }
   return view;
}

- (UIViewController*)topModalViewController {
   
   UIViewController *topViewController = [self rootModalViewController];
   
   while(nil != topViewController.presentedViewController) {
      topViewController = topViewController.presentedViewController;
   }
   
   return topViewController;
}

- (UIViewController*)rootModalViewController {
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

- (void)presentModalViewControllerInNavigationController:(UIViewController *)viewController animated:(BOOL)aniamted completion:(BasicBlock)completion {
   UINavigationController *navigationController = [[[UINavigationController alloc] initWithRootViewController:viewController] autorelease];
   [self presentModalViewController:navigationController animated:aniamted completion:completion];
}

- (void)presentModalViewController:(UIViewController *)viewController animated:(BOOL)animated completion:(BasicBlock)completion {
   MDFPresentingObject *object = [MDFPresentingObject objectWithViewController:viewController animation:animated presentationStyle:FPPresentationStylePresentModal completion:completion];
   [self presentObject:object];
}

- (void)dismissModalViewControllerAnimated:(BOOL)animated completion:(BasicBlock)completion {
   
   MDFPresentingObject *object = [MDFPresentingObject objectWithViewController:nil animation:animated presentationStyle:FPPresentationStyleDismiss completion:completion];
   [self presentObject:object];
}

- (void)dismissAllModalViewControllersAnimated:(BOOL)animated completion:(BasicBlock)completion {
   
   MDFPresentingObject *object = [MDFPresentingObject objectWithViewController:nil animation:animated presentationStyle:FPPresentationStyleDismissAll completion:completion];
   [self presentObject:object];
}

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
      
      UIViewController *topViewController = [self topModalViewController];
      
      //End actions
      void (^endBlock)(void) = ^(void) {
         [object executeCompletion];
         
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
               UIViewController *rootModalViewController = [self rootModalViewController];
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
