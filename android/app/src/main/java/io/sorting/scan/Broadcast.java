package io.sorting.scan;

import android.content.Context;
import android.content.Intent;

public class Broadcast {
    private Context mContext;
    public static Broadcast bc = null;
    private static final String KAICOM_DISABLE_CONTINUE_SCANNER = "com.kaicom.disable.continue.scanner";
    private static final String KAICOM_SCANNER_CALLBACK_TYPE = "com.kaicom.scanner.result.callbacktype";

    public Broadcast() {
    }

    private Broadcast(Context mContext) {
        this.mContext = mContext;
    }

    public static Broadcast getInstance(Context mContext) {
        if (bc == null) {
            bc = new Broadcast(mContext);
        }
        return bc;

    }

    public void TurnOnOffScanMessageTone(boolean set) {
        Intent intent = new Intent("com.android.service_settings");
        intent.putExtra("scanner_sound_play", set);
        if (mContext != null)
            mContext.sendBroadcast(intent);
    }

    public void TurnOnOffScanMessageVibrator(boolean set) {
        Intent intent = new Intent("com.android.service_settings");
        intent.putExtra("scanner_vibrate", set);
        if (mContext != null)
            mContext.sendBroadcast(intent);
    }

    public void sendContinueConfig(boolean paramBoolean) {
        Intent intent = new Intent("com.android.service_settings");
        intent.putExtra("scanner_scan_continue", paramBoolean);
        mContext.sendBroadcast(intent);
//        Intent intent = new Intent("com.kaicom.scanner.continue.settings");
//        intent.putExtra("scan_continue", paramBoolean);
//        mContext.sendBroadcast(intent);
    }

    public void sendIntervalConfig(int paramInt) {
        Intent intent = new Intent("com.android.service_settings");
        intent.putExtra("scanner_interval", paramInt);
        mContext.sendBroadcast(intent);

    }

    public void sendPrefixConfig(String paramString) {
        Intent intent = new Intent("com.android.service_settings");
        intent.putExtra("scanner_prefix", paramString);
        mContext.sendBroadcast(intent);
    }

    public void sendSuffixConfig(String paramString) {
        Intent intent = new Intent("com.android.service_settings");
        intent.putExtra("scanner_suffix", paramString);
        mContext.sendBroadcast(intent);
    }

    public void setPdaSn(String paramString) {
        Intent intent = new Intent("com.android.service_settings");
        intent.putExtra("pda_sn", paramString);
        mContext.sendBroadcast(intent);
    }

    public void setPdaSystime(String paramString) {
        Intent intent = new Intent("com.android.service_settings");
        intent.putExtra("pda_systime", paramString);
        mContext.sendBroadcast(intent);
    }

    public void setPdaStatusbar(String set) {
        Intent intent = new Intent("com.android.service_settings");
        intent.putExtra("pda_statusbar", set);
        mContext.sendBroadcast(intent);
    }

}
