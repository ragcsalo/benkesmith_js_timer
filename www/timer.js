var exec = require('cordova/exec');

var Timer = {
    start: function(successCallback, errorCallback) {
        exec(successCallback, errorCallback, 'Timer', 'start', []);
    },
    stop: function(successCallback, errorCallback) {
        exec(successCallback, errorCallback, 'Timer', 'stop', []);
    }
};

module.exports = Timer;
