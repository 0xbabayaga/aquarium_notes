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


public class ActionTaskBackground extends QtService
{
    private static final String TAG = "ActionTaskBackground";
    private static native void callFromJava(String message);
    private static Context context;

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

        try
        {
            while(true)
            {
/*
                m_notificationManager = (NotificationManager) context.getSystemService(Context.NOTIFICATION_SERVICE);

                if (android.os.Build.VERSION.SDK_INT >= android.os.Build.VERSION_CODES.O)
                {
                    int importance = NotificationManager.IMPORTANCE_DEFAULT;
                    NotificationChannel notificationChannel = new NotificationChannel("Qt", "Qt Notifier", importance);
                    m_notificationManager.createNotificationChannel(notificationChannel);
                    m_builder = new Notification.Builder(context, notificationChannel.getId());
                }
                else
                {
                    m_builder = new Notification.Builder(context);
                }

                m_builder.setSmallIcon(R.drawable.icon)
                        .setLargeIcon(BitmapFactory.decodeResource(context.getResources(), R.drawable.icon))
                        .setContentTitle("Service message")
                        .setContentText("Counter" + cnt)
                        .setDefaults(Notification.DEFAULT_SOUND)
                        .setColor(Color.GREEN)
                        .setAutoCancel(true);

                m_notificationManager.notify(0, m_builder.build());
                */

                //callFromJava("Java calling");

                //cnt++;
                //Thread.sleep(1000);
            }
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
