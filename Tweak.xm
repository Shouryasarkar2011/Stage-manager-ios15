#import <UIKit/UIKit.h>

// Interfaces
@interface SBMainWorkspace : NSObject
+(id)sharedInstance;
-(void)activateApplication:(id)arg1;
@end

@interface SpringBoard : UIApplication
+(id)_applicationWithBundleIdentifier:(NSString *)bundleID;
@end

static UIWindow *miniDockWindow = nil;
static BOOL isDockHidden = NO;

// Helper to check if we are in landscape
static BOOL isLandscape() {
    UIInterfaceOrientation orientation = [UIApplication sharedApplication].statusBarOrientation;
    return UIInterfaceOrientationIsLandscape(orientation);
}

static void updateDockVisibility() {
    if (!miniDockWindow) return;
    
    // If NOT landscape, hide the window completely
    if (!isLandscape()) {
        miniDockWindow.hidden = YES;
    } else {
        miniDockWindow.hidden = isDockHidden;
    }
}

%hook SpringBoard

-(void)applicationDidFinishLaunching:(id)application {
    %orig;

    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, 3 * NSEC_PER_SEC), dispatch_get_main_queue(), ^{
        CGRect screen = [UIScreen mainScreen].bounds;
        
        miniDockWindow = [[UIWindow alloc] initWithFrame:CGRectMake(0, 0, screen.size.width * 0.10, screen.size.height)];
        miniDockWindow.windowLevel = UIWindowLevelStatusBar + 100;
        miniDockWindow.hidden = !isLandscape(); // Only show if currently landscape
        miniDockWindow.backgroundColor = [UIColor colorWithWhite:0.0 alpha:0.5];

        // Toggle Button
        UIButton *toggleBtn = [UIButton buttonWithType:UIButtonTypeSystem];
        toggleBtn.frame = CGRectMake(0, 0, screen.size.width * 0.10, 40);
        [toggleBtn setTitle:@"||" forState:UIControlStateNormal];
        [toggleBtn addTarget:self action:@selector(toggleDock) forControlEvents:UIControlEventTouchUpInside];
        [miniDockWindow addSubview:toggleBtn];

        // Monitor Orientation
        [[NSNotificationCenter defaultCenter] addObserverForName:UIApplicationDidChangeStatusBarOrientationNotification 
                                                          object:nil queue:[NSOperationQueue mainQueue] 
                                                      usingBlock:^(NSNotification *note) {
            updateDockVisibility();
        }];
    });
}

%new
-(void)toggleDock {
    isDockHidden = !isDockHidden;
    miniDockWindow.hidden = isDockHidden;
}

%end
