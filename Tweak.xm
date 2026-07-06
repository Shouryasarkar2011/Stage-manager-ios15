#import <UIKit/UIKit.h>

// --- ZETSU BRIDGE ---
// This class and function allow us to talk to Zetsu directly
@interface ZetsuWindow : UIWindow
@end

// The "Magic" function from your class-dump
extern void _Z10CardShrinkP11ZetsuWindowb(ZetsuWindow *window, bool shrink);

// --- DOCK UI ---
@interface PassThroughWindow : UIWindow
@end

@implementation PassThroughWindow
- (BOOL)pointInside:(CGPoint)point withEvent:(UIEvent *)event {
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
        
        // Setup Dock on the left
        miniDockWindow = [[PassThroughWindow alloc] initWithFrame:CGRectMake(0, 0, 80, screen.size.height)];
        miniDockWindow.windowLevel = UIWindowLevelAlert + 1;
        miniDockWindow.backgroundColor = [UIColor colorWithWhite:0.0 alpha:0.4];
        miniDockWindow.hidden = NO;
        miniDockWindow.autoresizingMask = UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleRightMargin;

        // Launch Button (Connects to Zetsu)
        UIButton *btn = [UIButton buttonWithType:UIButtonTypeSystem];
        btn.frame = CGRectMake(10, 100, 60, 60);
        [btn setTitle:@"Z-Launch" forState:UIControlStateNormal];
        [btn addTarget:self action:@selector(launchInZetsu) forControlEvents:UIControlEventTouchUpInside];
        [miniDockWindow addSubview:btn];

        // Minimize/Hide Button
        UIButton *hideBtn = [UIButton buttonWithType:UIButtonTypeSystem];
        hideBtn.frame = CGRectMake(10, 200, 60, 30);
        [hideBtn setTitle:@"Min" forState:UIControlStateNormal];
        [hideBtn addTarget:self action:@selector(minimizeActiveZetsuWindow) forControlEvents:UIControlEventTouchUpInside];
        [miniDockWindow addSubview:hideBtn];
    });
}

%new
-(void)launchInZetsu {
    // Example: Launches Settings in Zetsu Window Mode
    [[UIApplication sharedApplication] openURL:[NSURL URLWithString:@"prefs:root=General"] options:@{} completionHandler:nil];
}

%new
-(void)minimizeActiveZetsuWindow {
    // Loop through windows to find the Zetsu one and shrink it
    for (UIWindow *window in [UIApplication sharedApplication].windows) {
        if ([window isKindOfClass:NSClassFromString(@"ZetsuWindow")]) {
            _Z10CardShrinkP11ZetsuWindowb((ZetsuWindow *)window, YES); // YES = shrink (minimize)
            break;
        }
    }
}

%new
-(void)toggleDock {
    isDockHidden = !isDockHidden;
    [UIView animateWithDuration:0.3 animations:^{
        miniDockWindow.frame = CGRectMake(isDockHidden ? -60 : 0, 0, 80, [UIScreen mainScreen].bounds.size.height);
    }];
}

%end
