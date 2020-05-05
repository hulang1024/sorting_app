package io.sorting.scan;

import android.content.BroadcastReceiver;
import android.content.Context;
import android.content.Intent;
import android.content.IntentFilter;
import androidx.annotation.NonNull;
import io.flutter.embedding.android.FlutterActivity;
import io.flutter.embedding.engine.FlutterEngine;
import io.flutter.plugin.common.BasicMessageChannel;
import io.flutter.plugin.common.StandardMessageCodec;

public class CodeScanner {
    public CodeScanner(@NonNull FlutterEngine flutterEngine, @NonNull FlutterActivity activity) {
        BasicMessageChannel<Object> messageChannel = new BasicMessageChannel<>(
            flutterEngine.getDartExecutor().getBinaryMessenger(),
            "sorting/scan",
            StandardMessageCodec.INSTANCE);
        BroadcastReceiver broadcastReceiver = new BroadcastReceiver() {
            @Override
            public void onReceive(Context context, Intent intent) {
            if ("com.android.receive_scan_action".equals(intent.getAction())) {
                String data = intent.getStringExtra("data");
                messageChannel.send(data);
            }
            }
        };
        activity.registerReceiver(broadcastReceiver, new IntentFilter("com.android.receive_scan_action"));
    }

}
