#import <UIKit/UIKit.h>
#import "../esp/drawing_view/esp.h"

static UIWindow *overlayWindow = nil;
static ESP_View *espView = nil;

static void initOverlay(void) {
    dispatch_async(dispatch_get_main_queue(), ^{
        if (overlayWindow) return;
        
        CGRect bounds = [UIScreen mainScreen].bounds;
        overlayWindow = [[UIWindow alloc] initWithFrame:bounds];
        overlayWindow.windowLevel = UIWindowLevelStatusBar + 1000.0;
        overlayWindow.backgroundColor = [UIColor clearColor];
        overlayWindow.userInteractionEnabled = YES;
        
        UIViewController *vc = [[UIViewController alloc] init];
        vc.view.backgroundColor = [UIColor clearColor];
        vc.view.userInteractionEnabled = YES;
        
        espView = [[ESP_View alloc] initWithFrame:bounds];
        espView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
        espView.userInteractionEnabled = YES;
        
        [vc.view addSubview:espView];
        overlayWindow.rootViewController = vc;
        
        [overlayWindow setHidden:NO];
        [overlayWindow makeKeyAndVisible];
    });
}

__attribute__((constructor))
static void entry(void) {
    dispatch_async(dispatch_get_main_queue(), ^{
        UIApplication *app = [UIApplication sharedApplication];
        if (app && (app.keyWindow || app.windows.count > 0)) {
            dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.5 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                initOverlay();
            });
        } else {
            [[NSNotificationCenter defaultCenter] addObserverForName:UIApplicationDidFinishLaunchingNotification
                                                             object:nil
                                                              queue:[NSOperationQueue mainQueue]
                                                         usingBlock:^(NSNotification * _Nonnull note) {
                dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1.0 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                    initOverlay();
                });
            }];
        }
    });
}
