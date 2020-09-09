package org.tikava.AquariumNotes;
import android.app.Service;
import android.os.IBinder;
import android.content.Intent;
import android.os.Bundle;
import android.os.Handler;
import java.lang.Thread;
import org.qtproject.qt5.android.bindings.QtService;
import android.util.Log;
import android.content.Context;
import android.view.View;
import android.app.Notification;
import android.app.NotificationManager;
import android.app.NotificationChannel;

import android.app.PendingIntent;
import android.graphics.Color;
import android.graphics.BitmapFactory;
import android.app.Activity;
import android.os.CountDownTimer;

public class ActionTaskBackground extends QtService
{
    private static final String TAG = "ActionTaskBackground";
    private static native void callFromJava(String message);
    private static Context context;
    static long TIME_LIMIT = 10000;
    CountDownTimer Count;

    private static NotificationManager m_notificationManager;
    private static Notification.Builder m_builder;

    public ActionTaskBackground() {}

    @Override
    public void onCreate()
    {
        super.onCreate();
        Log.i("Service", "onCreate()");
    }

    @Override
    public int onStartCommand(Intent intent, int flags, int startId)
    {
        int ret = super.onStartCommand(intent, flags, startId);
        Log.i("Service", "onStartCommand()");
        int cnt = 0;
        context = getApplicationContext();

        callFromJava("Java calling");

        Count = new CountDownTimer(TIME_LIMIT, 1000)
        {
            public void onTick(long millisUntilFinished)
            {
                long seconds = millisUntilFinished / 1000;
                String time = String.format("%02d:%02d", (seconds % 3600) / 60, (seconds % 60));

                //if (seconds % 2 == 0)
                //    callFromJava("Java calling " + time);

                //sendBroadcast(i);
            }

            public void onFinish()
            {
                callFromJava("Java calling fin ");

                stopSelf();
            }
        };

        Count.start();

        try
        {


                callFromJava("End startup");

                //cnt++;
                //Thread.sleep(5000);

        }
        catch (Exception e)
        {
            e.printStackTrace();
        }


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
