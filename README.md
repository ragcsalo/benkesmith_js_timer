## What's this plugin for?

I've created this plugin (using ChatGPT-4o) to keep the Javascript code "awake" when the Cordova app runs in the background.

I've had this issue for many years: basically as soon as the app goes to the background, Javascript timers stop working... Lately I've discovered that if there's an incoming signal from an external BLE device, or from the native code, the Javascript timers wake up for a few seconds.

So this plugin sends a "tick" to the Javascript code at a regular time interval (like 1 second), which wakes the timers up temporarily.
<br><br>

## Multi-platform support
The plugin was tested and should work fine on iOS 18 Beta and Android 14.
You can report platform incompatibilities in the Issues section.
<br><br>

## Installing the plugin

`cordova plugin add https://github.com/ragcsalo/benkesmith_js_timer`
<br><br>

## Deleting the plugin

`cordova plugin remove com.benkesmith.js_timer`
<br><br>

## Usage Example in JavaScript

Here's how you can use the plugin with the `interval` and `maxRuntime` parameters from the JavaScript side:

```javascript
document.addEventListener('deviceready', function () {
    // Define the onTick function to be called by the native timer
    benkesmith.plugins.timer.onTick = function() {
        console.log('Timer ticked');
        // Your periodic task code here
    };

    // Start the native timer with a custom interval (e.g., every 1 seconds) and max runtime (e.g., 15 minutes)
    var interval = 1.0; // interval in seconds
    var maxRuntime = 15; // max runtime in minutes, 0 means never stop
    benkesmith.plugins.timer.start(interval, maxRuntime, function() {
        console.log('Timer started with interval: ' + interval + ' seconds and max runtime: ' + maxRuntime + ' minutes');
    }, function(error) {
        console.error('Error starting timer: ', error);
    });

    // Optionally, stop the timer after a certain period
    setTimeout(function() {
        benkesmith.plugins.timer.stop(function() {
            console.log('Timer stopped');
        }, function(error) {
            console.error('Error stopping timer: ', error);
        });
    }, 60000); // Stop after 60 seconds (1 minute)
}, false);
```
