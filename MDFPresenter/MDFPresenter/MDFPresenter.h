//
//  FPPresenter.h
//  iFreePhone
//
//  Created by Mark DiFranco on 2013-02-27.
//
//

typedef void (^BasicBlock)(void);

@interface MDFPresenter : NSObject

+ (MDFPresenter*)instance;
+ (BOOL)hasModalOpen;

- (UIView*)topView;
- (UIViewController*)topModalViewController;
- (void)presentModalViewControllerInNavigationController:(UIViewController*)viewController animated:(BOOL)aniamted completion:(BasicBlock)completion;
- (void)presentModalViewController:(UIViewController*)viewController animated:(BOOL)animated completion:(BasicBlock)completion;
- (void)dismissModalViewControllerAnimated:(BOOL)animated completion:(BasicBlock)completion;
- (void)dismissAllModalViewControllersAnimated:(BOOL)animated completion:(BasicBlock)completion;


@end
