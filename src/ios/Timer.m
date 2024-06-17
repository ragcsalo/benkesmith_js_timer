#import "Timer.h"

@implementation Timer

- (void)start:(CDVInvokedUrlCommand*)command {
    NSLog(@"[Timer] Starting timer");
    [self.commandDelegate runInBackground:^{
        NSLog(@"[Timer] Timer setup in background");
        if (self->timer != nil) {
            [self->timer invalidate];
        }
        self->timer = [NSTimer timerWithTimeInterval:1.0
                                              target:self
                                            selector:@selector(fireTimer:)
                                            userInfo:nil
                                             repeats:YES];
        [[NSRunLoop mainRunLoop] addTimer:self->timer forMode:NSRunLoopCommonModes];
        
        NSLog(@"[Timer] Timer scheduled on main run loop");

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
        if (self->timer != nil) {
            [self->timer invalidate];
            self->timer = nil;
            NSLog(@"[Timer] Timer invalidated");
        }

        CDVPluginResult *pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK];
        [self.commandDelegate sendPluginResult:pluginResult callbackId:command.callbackId];
    }];
}

@end

