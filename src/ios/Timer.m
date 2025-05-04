#import "Timer.h"

@implementation Timer

// Called once when plugin is initialized
- (void)pluginInitialize {
    [super pluginInitialize];
    mInterval   = 1.0;
    mMaxRuntime = 0.0;
    isRunning   = NO;

    // Listen for app background/foreground
    [[NSNotificationCenter defaultCenter]
        addObserver:self
           selector:@selector(onAppPause)
               name:UIApplicationDidEnterBackgroundNotification
             object:nil];
    [[NSNotificationCenter defaultCenter]
        addObserver:self
           selector:@selector(onAppResume)
               name:UIApplicationWillEnterForegroundNotification
             object:nil];
}

- (void)onAppPause {
    NSLog(@"[Timer] App did enter background – auto-starting");
    [self startTimerInternal];
}

- (void)onAppResume {
    NSLog(@"[Timer] App will enter foreground – auto-stopping");
    [self stopTimerInternal];
}

- (void)start:(CDVInvokedUrlCommand*)command {
    // read interval and maxRuntime (minutes → seconds)
    NSNumber *intervalNum   = [command.arguments objectAtIndex:0];
    NSNumber *maxRunNum     = [command.arguments objectAtIndex:1];
    mInterval   = intervalNum ? [intervalNum doubleValue] : 1.0;
    mMaxRuntime = maxRunNum   ? [maxRunNum doubleValue] * 60.0 : 0.0;

    [self startTimerInternal];
    CDVPluginResult *res = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK];
    [self.commandDelegate sendPluginResult:res callbackId:command.callbackId];
}

- (void)startTimerInternal {
    if (isRunning) {
        NSLog(@"[Timer] Already running – skipping start");
        return;
    }
    isRunning = YES;
    NSLog(@"[Timer] Starting: interval=%f s, maxRuntime=%f s", mInterval, mMaxRuntime);

    // Invalidate any existing timers
    [timer invalidate];
    [stopTimer invalidate];

    // Main ticker
    timer = [NSTimer timerWithTimeInterval:mInterval
                                    target:self
                                  selector:@selector(fireTimer:)
                                  userInfo:nil
                                   repeats:YES];
    [[NSRunLoop mainRunLoop] addTimer:timer forMode:NSRunLoopCommonModes];

    // Auto-stop after maxRuntime
    if (mMaxRuntime > 0) {
        stopTimer = [NSTimer scheduledTimerWithTimeInterval:mMaxRuntime
                                                     target:self
                                                   selector:@selector(onMaxRuntime)
                                                   userInfo:nil
                                                    repeats:NO];
    }
}

- (void)fireTimer:(NSTimer*)unused {
    dispatch_async(dispatch_get_main_queue(), ^{
        [self.commandDelegate evalJs:@"benkesmith.plugins.timer.onTick();"];
    });
}

- (void)onMaxRuntime {
    NSLog(@"[Timer] Max runtime reached – stopping");
    [self stopTimerInternal];
}

- (void)stop:(CDVInvokedUrlCommand*)command {
    [self stopTimerInternal];
    CDVPluginResult *res = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK];
    [self.commandDelegate sendPluginResult:res callbackId:command.callbackId];
}

- (void)stopTimerInternal {
    if (!isRunning) {
        NSLog(@"[Timer] Not running – skipping stop");
        return;
    }
    isRunning = NO;
    NSLog(@"[Timer] Stopping");

    [timer invalidate];     timer = nil;
    [stopTimer invalidate]; stopTimer = nil;
}

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

@end
