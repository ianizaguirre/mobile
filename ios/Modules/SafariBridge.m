#import "SafariBridge.h"
#import <ReactNativeNavigation/ReactNativeNavigation.h>
#import "RNNRootViewController.h"
#import "RNNElementFinder.h"
#import "RNNElementView.h"
@import SafariServices;

@implementation SafariBridge
RCT_EXPORT_MODULE();

+(BOOL)requiresMainQueueSetup {
  return NO;
}

RCT_EXPORT_METHOD(open:(NSString *)componentId options:(NSDictionary *)options) {
  
  NSString* url = [options valueForKey:@"url"];
  NSNumber* readerMode = [options valueForKey:@"readerMode"];
  NSNumber* reactTag = [options valueForKey:@"reactTag"];
  NSNumber* preferredBarTintColor = [options valueForKey:@"preferredBarTintColor"];
  NSNumber* preferredControlTintColor = [options valueForKey:@"preferredControlTintColor"];
  
  UIViewController *vc = [ReactNativeNavigation findViewController:componentId];
  
  SFSafariViewController *safariViewController = [[SFSafariViewController alloc] initWithURL:[[NSURL alloc] initWithString:url] entersReaderIfAvailable:[readerMode boolValue]];
  
  if (preferredBarTintColor) {
    safariViewController.preferredBarTintColor = [RCTConvert UIColor:preferredBarTintColor];
  }
  
  if (preferredControlTintColor) {
    safariViewController.preferredControlTintColor = [RCTConvert UIColor:preferredControlTintColor];
  }
  
  if (@available(iOS 11.0, *)) {
    safariViewController.dismissButtonStyle = SFSafariViewControllerDismissButtonStyleDone;
  }
  
  (void)safariViewController.view;
  
  if ([reactTag intValue] >= 0) {
    if ([vc isKindOfClass:[RNNRootViewController class]]) {
      RNNRootViewController* rootVc = (RNNRootViewController*)vc;
      rootVc.previewController = safariViewController;
      rootVc.previewCallback = ^(UIViewController *vc) {
        RNNRootViewController* theVc = (RNNRootViewController*)vc;
        [vc.navigationController presentViewController:safariViewController animated:NO completion:nil];
        [theVc.eventEmitter sendComponentDidAppear:theVc.layoutInfo.componentId componentName:@"SAFARI_VIEW"];
      };
      RCTExecuteOnMainQueue(^{
        UIView *view = [[ReactNativeNavigation getBridge].uiManager viewForReactTag:reactTag];
        [rootVc registerForPreviewingWithDelegate:(id)rootVc sourceView:view];
      });
    }
  } else {
    dispatch_async( dispatch_get_main_queue(), ^{
      [vc.navigationController presentViewController:safariViewController animated:YES completion:nil];
      if ([vc isKindOfClass:[RNNRootViewController class]]) {
        RNNRootViewController* rootVc = (RNNRootViewController*)vc;
        [rootVc.eventEmitter sendComponentDidAppear:rootVc.layoutInfo.componentId componentName:@"SAFARI_VIEW"];
      }
    });
  }
}

@end
