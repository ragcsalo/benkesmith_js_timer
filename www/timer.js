var exec = require('cordova/exec');

var Timer = {
    start: function(interval, maxRuntime, successCallback, errorCallback) {
        exec(successCallback, errorCallback, 'Timer', 'start', [interval, maxRuntime]);
    },
    stop: function(successCallback, errorCallback) {
        exec(successCallback, errorCallback, 'Timer', 'stop', []);
    }
};

module.exports = Timer;

