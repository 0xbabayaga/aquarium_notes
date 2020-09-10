package org.tikava.AquariumNotes;

import android.app.Service;
import android.os.IBinder;
import android.content.Intent;
import android.os.Bundle;
import android.os.Handler;
import java.lang.Thread;
import org.qtproject.qt5.android.bindings.QtService;
import android.util.Log;
import android.app.PendingIntent;
import android.app.Activity;
import android.os.CountDownTimer;

public class Background extends QtService
{
    private static native void callbackOnTimer(int callNum);
    static long TIME_LIMIT = 10000;
    CountDownTimer Count;
    private static int cnt = 0;

    public Background() {}

    @Override
    public void onCreate()
    {
        super.onCreate();
    }

    @Override
    public int onStartCommand(Intent intent, int flags, int startId)
    {
        int ret = super.onStartCommand(intent, flags, startId);

        Count = new CountDownTimer(TIME_LIMIT, 1000)
        {
            public void onTick(long millisUntilFinished)
            {
            }

            public void onFinish()
            {
                callbackOnTimer(cnt);
                cnt++;

                Count.start();
            }
        };

        Count.start();

        return ret;
    }

    @Override
    public IBinder onBind(Intent intent)
    {
        return super.onBind(intent);
    }

    @Override
    public boolean onUnbind(Intent intent)
    {
        return super.onUnbind(intent);
    }

    @Override
    public void onRebind(Intent intent)
    {
        super.onRebind(intent);
    }

    @Override
    public void onDestroy()
    {
        super.onDestroy();
    }
}
