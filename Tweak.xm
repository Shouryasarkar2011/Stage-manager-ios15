#import <UIKit/UIKit.h>

// Interfaces for interaction
@interface SBMainWorkspace : NSObject
+(id)sharedInstance;
-(void)activateApplication:(id)arg1;
@end

@interface SpringBoard : UIApplication
+(id)_applicationWithBundleIdentifier:(NSString *)bundleID;
@end

// Ghost window to allow clicks to pass through
@interface PassThroughWindow : UIWindow
@end

@implementation PassThroughWindow
- (UIView *)hitTest:(CGPoint)point withEvent:(UIEvent *)event {
    UIView *hitView = [super hitTest:point withEvent:event];
    return (hitView == self) ? nil : hitView;
}
@end

static PassThroughWindow *miniDockWindow = nil;
static BOOL isDockHidden = NO;

// Helper to check for Landscape on iOS 15
static BOOL isCurrentlyLandscape() {
    return UIDeviceOrientationIsLandscape([[UIDevice currentDevice] orientation]);
}

static void updateDockVisibility() {
    if (!miniDockWindow) return;
    // Only show if in landscape AND not manually hidden
    miniDockWindow.hidden = !isCurrentlyLandscape() || isDockHidden;
}

%hook SpringBoard

-(void)applicationDidFinishLaunching:(id)application {
    %orig;

    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, 3 * NSEC_PER_SEC), dispatch_get_main_queue(), ^{
        CGRect screen = [UIScreen mainScreen].bounds;
        
        miniDockWindow = [[PassThroughWindow alloc] initWithFrame:CGRectMake(0, 0, screen.size.width * 0.10, screen.size.height)];
        miniDockWindow.windowLevel = UIWindowLevelStatusBar + 100;
        miniDockWindow.hidden = !isCurrentlyLandscape();
        miniDockWindow.backgroundColor = [UIColor colorWithWhite:0.0 alpha:0.4];

        // 1. App Snapshot Button
        UIButton *btn = [UIButton buttonWithType:UIButtonTypeCustom];
        btn.frame = CGRectMake(10, 100, 50, 50);
        btn.backgroundColor = [UIColor blueColor];
        [btn setTitle:@"App" forState:UIControlStateNormal];
        [btn addTarget:self action:@selector(bringAppBack:) forControlEvents:UIControlEventTouchUpInside];
        [miniDockWindow addSubview:btn];

        // 2. Hide/Show Button
        UIButton *hideBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        hideBtn.frame = CGRectMake(10, 200, 50, 30);
        hideBtn.backgroundColor = [UIColor redColor];
        [hideBtn setTitle:@"Hide" forState:UIControlStateNormal];
        [hideBtn addTarget:self action:@selector(toggleDock) forControlEvents:UIControlEventTouchUpInside];
        [miniDockWindow addSubview:hideBtn];
        
        // Listen for orientation changes
        [[NSNotificationCenter defaultCenter] addObserverForName:UIDeviceOrientationDidChangeNotification 
                                                          object:nil queue:[NSOperationQueue mainQueue] 
                                                      usingBlock:^(NSNotification *note) {
            updateDockVisibility();
        }];
    });
}

%new
-(void)toggleDock {
    isDockHidden = !isDockHidden;
    updateDockVisibility();
}

%new
-(void)bringAppBack:(id)sender {
    NSString *bundleID = @"com.apple.Preferences";
    id app = [%c(SpringBoard) _applicationWithBundleIdentifier:bundleID];
    if (app) {
        [[%c(SBMainWorkspace) sharedInstance] activateApplication:app];
    }
}

%end
