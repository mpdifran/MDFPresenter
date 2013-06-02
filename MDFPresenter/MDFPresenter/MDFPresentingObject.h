//
//  FPPresentingObject.h
//  iFreePhone
//
//  Created by Mark DiFranco on 2013-02-27.
//
//

#import "MDFPresenter.h"

typedef enum {
   FPPresentationStylePresentFade,
   FPPresentationStylePresentModal,
   FPPresentationStyleDismiss,
   FPPresentationStyleDismissAll
} FPPresentationStyle;

@interface MDFPresentingObject : NSObject

@property (nonatomic, retain) UIViewController *viewController;
@property (nonatomic, readwrite) BOOL animated;
@property (nonatomic, readwrite) FPPresentationStyle presentationStyle;
@property (nonatomic, copy) BasicBlock completion;

+ (MDFPresentingObject*)objectWithViewController:(UIViewController*)viewController animation:(BOOL)animation presentationStyle:(FPPresentationStyle)style completion:(BasicBlock)completion;
- (void)executeCompletion;

@end
