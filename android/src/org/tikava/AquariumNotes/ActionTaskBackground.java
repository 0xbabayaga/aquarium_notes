package org.tikava.AquariumNotes;
import android.app.Service;
import android.os.IBinder;
import android.content.Intent;
import android.os.Bundle;
import android.os.Handler;
import java.lang.Thread;
import org.qtproject.qt5.android.bindings.QtService;
import android.util.Log;

public class ActionTaskBackground extends QtService
{
    private static final String TAG = "ActionTaskBackground";

    //private static native void callFromJava(String message);

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
/*
        try
        {
            while (true)
            {
                Thread.sleep(5000);
                //callFromJava("Hello from JAVA!");
                Log.i("Service", "waked up");
            }
        }
        catch (InterruptedException e)
        {
            e.printStackTrace();
        }
    */

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
