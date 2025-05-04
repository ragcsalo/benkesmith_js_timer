var exec = require('cordova/exec');

// Plugin name matches plugin.xml's js-module name
var PLUGIN_NAME = 'Timer';

// Internal storage for auto-start config
var _autoInterval = 1.0;
var _autoMaxRuntime = 0;
var _autoEnabled = false;

// Exposed API
var timer = {
    /**
     * Called by native code on each tick.
     * Override this in your app code:
     * benkesmith.plugins.timer.onTick = function() { ... };
     */
    onTick: function() {},

    /**
     * Initialize auto background/foreground behavior.
     * @param {number} interval    Tick interval in seconds
     * @param {number} maxRuntime  Max runtime in minutes (0 = no limit)
     */
    init: function(interval, maxRuntime) {
        _autoInterval = interval;
        _autoMaxRuntime = maxRuntime;
        if (!_autoEnabled) {
            document.addEventListener('pause', timer._onPause, false);
            document.addEventListener('resume', timer._onResume, false);
            _autoEnabled = true;
        }
    },

    /**
     * Start the native ticker manually
     * @param {number} interval    Interval between ticks in seconds
     * @param {number} maxRuntime  Max runtime in minutes (0 = no limit)
     * @param {function} success   Called once when timer starts
     * @param {function} error     Called on error
     */
    start: function(interval, maxRuntime, success, error) {
        exec(success, error, PLUGIN_NAME, 'start', [interval, maxRuntime]);
    },

    /**
     * Stop the native ticker manually
     * @param {function} success   Called once when timer stops
     * @param {function} error     Called on error
     */
    stop: function(success, error) {
        exec(success, error, PLUGIN_NAME, 'stop', []);
    },

    /**
     * Internal handler: triggered on Cordova pause event
     * Auto-starts the ticker if init() was called.
     */
    _onPause: function() {
        if (_autoEnabled) {
            exec(function() {}, function() {}, PLUGIN_NAME, 'start', [_autoInterval, _autoMaxRuntime]);
        }
    },

    /**
     * Internal handler: triggered on Cordova resume event
     * Auto-stops the ticker if init() was called.
     */
    _onResume: function() {
        if (_autoEnabled) {
            exec(function() {}, function() {}, PLUGIN_NAME, 'stop', []);
        }
    }
};

module.exports = timer;
