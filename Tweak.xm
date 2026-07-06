#import <UIKit/UIKit.h>

// Interface for app activation
@interface SBMainWorkspace : NSObject
+(id)sharedInstance;
-(void)activateApplication:(id)arg1;
@end

@interface SpringBoard : UIApplication
+(id)_applicationWithBundleIdentifier:(NSString *)bundleID;
@end

// PassThroughWindow keeps touches from blocking the rest of the screen
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

// Check orientation
static BOOL isCurrentlyLandscape() {
    return UIDeviceOrientationIsLandscape([[UIDevice currentDevice] orientation]);
}

%hook SpringBoard

-(void)applicationDidFinishLaunching:(id)application {
    %orig;

    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, 3 * NSEC_PER_SEC), dispatch_get_main_queue(), ^{
        CGRect screen = [UIScreen mainScreen].bounds;
        
        // 1. Positioned on LEFT edge, windowLevel Alert forces it above system dock
        miniDockWindow = [[PassThroughWindow alloc] initWithFrame:CGRectMake(0, 0, screen.size.width * 0.10, screen.size.height)];
        miniDockWindow.windowLevel = UIWindowLevelAlert + 1;
        miniDockWindow.hidden = !isCurrentlyLandscape();
        miniDockWindow.backgroundColor = [UIColor colorWithWhite:0.0 alpha:0.4];
        miniDockWindow.layer.cornerRadius = 10;

        // 2. App Snapshot Button
        UIButton *btn = [UIButton buttonWithType:UIButtonTypeCustom];
        btn.frame = CGRectMake(10, 100, 50, 50);
        btn.backgroundColor = [UIColor blueColor];
        [btn setTitle:@"App" forState:UIControlStateNormal];
        [btn addTarget:self action:@selector(bringAppBack:) forControlEvents:UIControlEventTouchUpInside];
        [miniDockWindow addSubview:btn];

        // 3. Hide/Show Button
        UIButton *hideBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        hideBtn.frame = CGRectMake(10, 200, 50, 30);
        hideBtn.backgroundColor = [UIColor redColor];
        [hideBtn setTitle:@"Hide" forState:UIControlStateNormal];
        [hideBtn addTarget:self action:@selector(toggleDock) forControlEvents:UIControlEventTouchUpInside];
        [miniDockWindow addSubview:hideBtn];
        
        [[NSNotificationCenter defaultCenter] addObserverForName:UIDeviceOrientationDidChangeNotification 
                                                          object:nil queue:[NSOperationQueue mainQueue] 
                                                      usingBlock:^(NSNotification *note) {
            miniDockWindow.hidden = !isCurrentlyLandscape();
        }];
    });
}

%new
-(void)toggleDock {
    isDockHidden = !isDockHidden;
    [UIView animateWithDuration:0.3 animations:^{
        if (isDockHidden) {
            // When hidden, leave 20px of the dock visible as a "handle" on the left edge
            miniDockWindow.frame = CGRectMake(-(miniDockWindow.frame.size.width - 20), 0, miniDockWindow.frame.size.width, miniDockWindow.frame.size.height);
        } else {
            // Snap back to full view
            miniDockWindow.frame = CGRectMake(0, 0, miniDockWindow.frame.size.width, miniDockWindow.frame.size.height);
        }
    }];
}

%new
-(void)bringAppBack:(id)sender {
    NSString *bundleID = @"com.apple.Preferences";
    id app = [%c(SpringBoard) _applicationWithBundleIdentifier:bundleID];
    if (app) {
        // Use a tiny delay to ensure SpringBoard handles the transition safely
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, 0.1 * NSEC_PER_SEC), dispatch_get_main_queue(), ^{
            [[%c(SBMainWorkspace) sharedInstance] activateApplication:app];
        });
    }
}

%end
