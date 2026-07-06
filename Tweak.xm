#import <UIKit/UIKit.h>

// Interfaces for interaction
@interface SBMainWorkspace : NSObject
+(id)sharedInstance;
-(void)activateApplication:(id)arg1;
@end

@interface SpringBoard : UIApplication
+(id)_applicationWithBundleIdentifier:(NSString *)bundleID;
@end

static UIWindow *miniDockWindow = nil;
static BOOL isDockHidden = NO;

%hook SpringBoard

-(void)applicationDidFinishLaunching:(id)application {
    %orig;

    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, 3 * NSEC_PER_SEC), dispatch_get_main_queue(), ^{
        CGRect screen = [UIScreen mainScreen].bounds;
        miniDockWindow = [[UIWindow alloc] initWithFrame:CGRectMake(0, 0, screen.size.width * 0.10, screen.size.height)];
        miniDockWindow.windowLevel = UIWindowLevelStatusBar + 100;
        miniDockWindow.hidden = NO;
        miniDockWindow.backgroundColor = [UIColor colorWithWhite:0.0 alpha:0.5];

        // 1. Add "Handle" to show/hide
        UIButton *toggleBtn = [UIButton buttonWithType:UIButtonTypeSystem];
        toggleBtn.frame = CGRectMake(0, 0, screen.size.width * 0.10, 40);
        [toggleBtn setTitle:@"||" forState:UIControlStateNormal];
        [toggleBtn addTarget:self action:@selector(toggleDock) forControlEvents:UIControlEventTouchUpInside];
        [miniDockWindow addSubview:toggleBtn];

        // 2. Add App Snapshot Placeholder
        // NOTE: In the future, replace this with a UIImageView using [app snapshot]
        UIButton *appSnap = [UIButton buttonWithType:UIButtonTypeCustom];
        appSnap.frame = CGRectMake(10, 60, 50, 80);
        appSnap.backgroundColor = [UIColor grayColor]; 
        [appSnap setTitle:@"App" forState:UIControlStateNormal];
        [appSnap addTarget:self action:@selector(bringAppBack:) forControlEvents:UIControlEventTouchUpInside];
        [miniDockWindow addSubview:appSnap];

        // 3. Orientation Listener
        [[NSNotificationCenter defaultCenter] addObserverForName:UIDeviceOrientationDidChangeNotification 
                                                          object:nil queue:[NSOperationQueue mainQueue] 
                                                      usingBlock:^(NSNotification *note) {
            [self adjustDockForRotation];
        }];
    });
}

%new
-(void)toggleDock {
    isDockHidden = !isDockHidden;
    [UIView animateWithDuration:0.3 animations:^{
        miniDockWindow.frame = isDockHidden ? CGRectMake(-(miniDockWindow.frame.size.width - 20), 0, miniDockWindow.frame.size.width, miniDockWindow.frame.size.height) 
                                            : CGRectMake(0, 0, miniDockWindow.frame.size.width, miniDockWindow.frame.size.height);
    }];
}

%new
-(void)adjustDockForRotation {
    CGRect screen = [UIScreen mainScreen].bounds;
    miniDockWindow.frame = CGRectMake(isDockHidden ? -(screen.size.width * 0.10 - 20) : 0, 0, screen.size.width * 0.10, screen.size.height);
}

%new
-(void)bringAppBack:(id)sender {
    id app = [%c(SpringBoard) _applicationWithBundleIdentifier:@"com.apple.Preferences"];
    [[%c(SBMainWorkspace) sharedInstance] activateApplication:app];
}

%end
