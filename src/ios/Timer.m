#import "Timer.h"

@implementation Timer

- (void)start:(CDVInvokedUrlCommand*)command {
    NSLog(@"[Timer] Starting timer");

    // Get the interval from the command arguments, default to 1.0 if not provided
    NSNumber *intervalNumber = [command.arguments objectAtIndex:0];
    NSTimeInterval interval = (intervalNumber != nil) ? [intervalNumber doubleValue] : 1.0;
    
    // Get the max runtime from the command arguments, default to 0 (no limit) if not provided
    NSNumber *maxRuntimeNumber = [command.arguments objectAtIndex:1];
    NSTimeInterval maxRuntime = (maxRuntimeNumber != nil) ? [maxRuntimeNumber doubleValue] * 60 : 0; // convert minutes to seconds

    [self.commandDelegate runInBackground:^{
        NSLog(@"[Timer] Timer setup in background with interval: %f and max runtime: %f", interval, maxRuntime);
        if (self->timer != nil) {
            [self->timer invalidate];
        }
        self->timer = [NSTimer timerWithTimeInterval:interval
                                              target:self
                                            selector:@selector(fireTimer:)
                                            userInfo:nil
                                             repeats:YES];
        [[NSRunLoop mainRunLoop] addTimer:self->timer forMode:NSRunLoopCommonModes];
        
        NSLog(@"[Timer] Timer scheduled on main run loop with interval: %f", interval);

        // Set a timer to stop after maxRuntime seconds if maxRuntime is not zero
        if (maxRuntime > 0) {
            [self performSelector:@selector(stopTimer) withObject:nil afterDelay:maxRuntime];
        }

        CDVPluginResult *pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK];
        [self.commandDelegate sendPluginResult:pluginResult callbackId:command.callbackId];
    }];
}

- (void)fireTimer:(NSTimer*)timer {
    // Ensure this runs on the main thread
    NSLog(@"[Timer] Timer fired");
    dispatch_async(dispatch_get_main_queue(), ^{
        NSString* js = @"benkesmith.plugins.timer.onTick();";
        [self.commandDelegate evalJs:js];
    });
}

- (void)stop:(CDVInvokedUrlCommand*)command {
    NSLog(@"[Timer] Stopping timer");
    [self.commandDelegate runInBackground:^{
        [self stopTimer];
        CDVPluginResult *pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK];
        [self.commandDelegate sendPluginResult:pluginResult callbackId:command.callbackId];
    }];
}

- (void)stopTimer {
    if (self->timer != nil) {
        [self->timer invalidate];
        self->timer = nil;
        NSLog(@"[Timer] Timer invalidated");
    }
}

@end
