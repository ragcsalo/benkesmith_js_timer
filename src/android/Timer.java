package com.benkesmith.js_timer;

import android.app.Activity;
import android.app.Application;
import android.os.Bundle;
import android.os.Handler;
import android.util.Log;

import org.apache.cordova.CallbackContext;
import org.apache.cordova.CordovaInterface;
import org.apache.cordova.CordovaPlugin;
import org.apache.cordova.CordovaWebView;
import org.apache.cordova.PluginResult;
import org.json.JSONArray;
import org.json.JSONException;

public class Timer extends CordovaPlugin {
    private Handler       handler      = new Handler();
    private Runnable      tickerRunnable, stopRunnable;
    private double        mInterval    = 1.0;   // seconds
    private double        mMaxRuntime  = 0.0;   // seconds (0 = no limit)
    private boolean       isRunning    = false;
    private Application   application;
    private Application.ActivityLifecycleCallbacks lifecycleCallbacks;

    @Override
    public void initialize(CordovaInterface cordova, CordovaWebView webView) {
        super.initialize(cordova, webView);
        // grab the Application so we can watch its lifecycle
        application = cordova.getActivity().getApplication();
        // keep a reference so we can unregister
        lifecycleCallbacks = new Application.ActivityLifecycleCallbacks() {
            @Override public void onActivityPaused(Activity activity) {
                if (activity == cordova.getActivity()) {
                    Log.d("Timer", "Activity paused ⇒ auto-start");
                    startTimerInternal();
                }
            }
            @Override public void onActivityResumed(Activity activity) {
                if (activity == cordova.getActivity()) {
                    Log.d("Timer", "Activity resumed ⇒ auto-stop");
                    stopTimerInternal();
                }
            }
            // unused:
            @Override public void onActivityCreated(Activity a, Bundle b) {}
            @Override public void onActivityStarted(Activity a) {}
            @Override public void onActivityStopped(Activity a) {}
            @Override public void onActivitySaveInstanceState(Activity a, Bundle b) {}
            @Override public void onActivityDestroyed(Activity a) {}
        };
    }

    @Override
    public boolean execute(String action, JSONArray args, CallbackContext cb) throws JSONException {
        if ("start".equals(action)) {
            mInterval   = args.optDouble(0, 1.0);
            mMaxRuntime = args.optDouble(1, 0.0) * 60.0;
            startTimerInternal();
            cb.sendPluginResult(new PluginResult(PluginResult.Status.OK));
            return true;
        }
        if ("stop".equals(action)) {
            stopTimerInternal();
            cb.sendPluginResult(new PluginResult(PluginResult.Status.OK));
            return true;
        }
        return false;
    }

    private void startTimerInternal() {
        if (isRunning) {
            Log.d("Timer", "Already running, skip start");
            return;
        }
        isRunning = true;
        Log.d("Timer", "Starting: interval=" + mInterval + "s, maxRuntime=" + mMaxRuntime + "s");

        // Tick runnable
        tickerRunnable = () -> {
            cordova.getActivity().runOnUiThread(() ->
                    webView.getEngine().evaluateJavascript(
                            "benkesmith.plugins.timer.onTick();", null
                    )
            );
            // schedule next tick
            handler.postDelayed(tickerRunnable, (long)(mInterval * 1000));
        };
        handler.post(tickerRunnable);

        // Max-runtime stopper
        if (mMaxRuntime > 0) {
            stopRunnable = () -> {
                Log.d("Timer", "Max runtime reached ⇒ stopping");
                stopTimerInternal();
            };
            handler.postDelayed(stopRunnable, (long)(mMaxRuntime * 1000));
        }
    }

    private void stopTimerInternal() {
        if (!isRunning) {
            Log.d("Timer", "Not running, skip stop");
            return;
        }
        isRunning = false;
        Log.d("Timer", "Stopping");
        handler.removeCallbacks(tickerRunnable);
        handler.removeCallbacks(stopRunnable);
        tickerRunnable = stopRunnable = null;
    }

    @Override
    public void onDestroy() {
        super.onDestroy();
        // clean up
        stopTimerInternal();
        if (application != null && lifecycleCallbacks != null) {
            application.unregisterActivityLifecycleCallbacks(lifecycleCallbacks);
        }
    }
}
