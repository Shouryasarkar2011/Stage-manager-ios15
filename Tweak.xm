#import <UIKit/UIKit.h>

// Ghost Window Class
@interface PassThroughWindow : UIWindow
@end

@implementation PassThroughWindow
- (BOOL)pointInside:(CGPoint)point withEvent:(UIEvent *)event {
    // Only capture touches if they hit our buttons
    for (UIView *subview in self.subviews) {
        if ([subview isKindOfClass:[UIButton class]] && CGRectContainsPoint(subview.frame, point)) return YES;
    }
    return NO;
}
@end

static PassThroughWindow *miniDockWindow = nil;
static BOOL isDockHidden = NO;

%hook SpringBoard

-(void)applicationDidFinishLaunching:(id)application {
    %orig;

    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, 5 * NSEC_PER_SEC), dispatch_get_main_queue(), ^{
        CGRect screen = [UIScreen mainScreen].bounds;
        
        // 1. Create fluid window
        miniDockWindow = [[PassThroughWindow alloc] initWithFrame:CGRectMake(0, 0, 80, screen.size.height)];
        miniDockWindow.windowLevel = UIWindowLevelAlert + 1;
        miniDockWindow.backgroundColor = [UIColor colorWithWhite:0.0 alpha:0.4];
        miniDockWindow.hidden = NO;
        
        // Auto-resize handles rotation automatically
        miniDockWindow.autoresizingMask = UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleRightMargin;

        // 2. Launch Button
        UIButton *btn = [UIButton buttonWithType:UIButtonTypeSystem];
        btn.frame = CGRectMake(10, 100, 60, 60);
        [btn setTitle:@"Launch" forState:UIControlStateNormal];
        [btn addTarget:self action:@selector(launchSettings) forControlEvents:UIControlEventTouchUpInside];
        [miniDockWindow addSubview:btn];

        // 3. Toggle/Hide Button
        UIButton *hideBtn = [UIButton buttonWithType:UIButtonTypeSystem];
        hideBtn.frame = CGRectMake(10, 200, 60, 30);
        [hideBtn setTitle:@"Hide" forState:UIControlStateNormal];
        [hideBtn addTarget:self action:@selector(toggleDock) forControlEvents:UIControlEventTouchUpInside];
        [miniDockWindow addSubview:hideBtn];
    });
}

%new
-(void)toggleDock {
    isDockHidden = !isDockHidden;
    [UIView animateWithDuration:0.3 animations:^{
        if (isDockHidden) {
            miniDockWindow.frame = CGRectMake(-60, 0, 80, [UIScreen mainScreen].bounds.size.height);
        } else {
            miniDockWindow.frame = CGRectMake(0, 0, 80, [UIScreen mainScreen].bounds.size.height);
        }
    }];
}

%new
-(void)launchSettings {
    // The ultimate crash-proof way to launch an app
    [[UIApplication sharedApplication] openURL:[NSURL URLWithString:@"prefs:root=General"] 
                                       options:@{} 
                             completionHandler:nil];
}

%end
