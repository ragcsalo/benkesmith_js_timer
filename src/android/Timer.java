package com.benkesmith.js_timer;

import org.apache.cordova.CallbackContext;
import org.apache.cordova.CordovaPlugin;
import org.apache.cordova.PluginResult;
import org.json.JSONArray;
import org.json.JSONException;

import android.os.Handler;
import android.util.Log;

public class Timer extends CordovaPlugin {
    private Handler handler = new Handler();
    private Runnable tickerRunnable;
    private Runnable stopRunnable;

    @Override
    public boolean execute(String action, JSONArray args, final CallbackContext callbackContext) throws JSONException {
        if (action.equals("start")) {
            double interval = args.optDouble(0, 1.0); // Default to 1.0 second if not provided
            double maxRuntime = args.optDouble(1, 0) * 60; // Convert minutes to seconds, 0 means no limit
            start(interval, maxRuntime, callbackContext);
            return true;
        } else if (action.equals("stop")) {
            stop(callbackContext);
            return true;
        }
        return false;
    }

    private void start(final double interval, final double maxRuntime, final CallbackContext callbackContext) {
        stopRunnable = new Runnable() {
            @Override
            public void run() {
                if (tickerRunnable != null) {
                    handler.removeCallbacks(tickerRunnable);
                    tickerRunnable = null;
                }
                callbackContext.success();
                Log.d("Timer", "Max runtime reached, timer stopped.");
            }
        };

        tickerRunnable = new Runnable() {
            @Override
            public void run() {
                if (cordova.getActivity().isFinishing()) return;
                cordova.getActivity().runOnUiThread(new Runnable() {
                    @Override
                    public void run() {
                        String js = "benkesmith.plugins.timer.onTick();";
                        webView.getEngine().evaluateJavascript(js, null);
                    }
                });
                handler.postDelayed(this, (long) (interval * 1000));
            }
        };

        handler.post(tickerRunnable);

        if (maxRuntime > 0) {
            handler.postDelayed(stopRunnable, (long) (maxRuntime * 1000));
        }

        callbackContext.sendPluginResult(new PluginResult(PluginResult.Status.OK));
        Log.d("Timer", "Timer started with interval: " + interval + " seconds and max runtime: " + maxRuntime + " seconds.");
    }

    private void stop(CallbackContext callbackContext) {
        if (tickerRunnable != null) {
            handler.removeCallbacks(tickerRunnable);
            tickerRunnable = null;
        }
        if (stopRunnable != null) {
            handler.removeCallbacks(stopRunnable);
            stopRunnable = null;
        }
        callbackContext.sendPluginResult(new PluginResult(PluginResult.Status.OK));
        Log.d("Timer", "Timer stopped.");
    }
}
