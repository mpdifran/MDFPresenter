MDFPresenter
============

A handy presentation singleton which prevents crashes from too many modals being presented at once.

I've included a sample project which displays it's main use. If a modal view controller is presented while another modal view controller is animating, your app will crash. MDFPresenter prevents this from happening by queuing up requests and only executing them one at a time.

MDFPresenter supports the following methods:

/* Embeds the view controller in a Navigation Controller, and then presents that Navigation Controller*/
- (void)presentModalViewControllerInNavigationController:(UIViewController*)viewController animated:(BOOL)aniamted completion:(BasicBlock)completion;

/* Presents a view controller, and executes a completion block upon the View Controllers animation completion */
- (void)presentModalViewController:(UIViewController*)viewController animated:(BOOL)animated completion:(BasicBlock)completion;

/* Dismisses the top View Controller with a completion block to execute when it's done */
- (void)dismissModalViewControllerAnimated:(BOOL)animated completion:(BasicBlock)completion;

/* Dismisses all top View Controllers with a completion block to execute when it's done */
- (void)dismissAllModalViewControllersAnimated:(BOOL)animated completion:(BasicBlock)completion;

/* Can determine if there is a modal View Controller open */
+ (BOOL)hasModalOpen;

/* Gets the top-most full screen view displayed by your app */ 
- (UIView*)topView;

/* gets the top most modal View Controller displayed by your app */
- (UIViewController*)topModalViewController;
