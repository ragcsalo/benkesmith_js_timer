package com.benkesmith.js_timer;

import org.apache.cordova.CallbackContext;
import org.apache.cordova.CordovaPlugin;
import org.apache.cordova.PluginResult;
import org.json.JSONArray;
import org.json.JSONException;

import android.os.Handler;

public class Timer extends CordovaPlugin {
    private Handler handler = new Handler();
    private Runnable runnable;

    @Override
    public boolean execute(String action, JSONArray args, CallbackContext callbackContext) throws JSONException {
        if (action.equals("start")) {
            start(callbackContext);
            return true;
        } else if (action.equals("stop")) {
            stop(callbackContext);
            return true;
        }
        return false;
    }

    private void start(final CallbackContext callbackContext) {
        runnable = new Runnable() {
            @Override
            public void run() {
                if (cordova.getActivity().isFinishing()) return;
                String js = "benkesmith.plugins.timer.onTick();";
                webView.getEngine().evaluateJavascript(js, null);
                handler.postDelayed(this, 1000);
            }
        };
        handler.postDelayed(runnable, 1000);
        callbackContext.sendPluginResult(new PluginResult(PluginResult.Status.OK));
    }

    private void stop(CallbackContext callbackContext) {
        if (runnable != null) {
            handler.removeCallbacks(runnable);
            runnable = null;
        }
        callbackContext.sendPluginResult(new PluginResult(PluginResult.Status.OK));
    }
}
