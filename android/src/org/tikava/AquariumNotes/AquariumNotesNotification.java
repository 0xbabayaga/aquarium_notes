package org.tikava.AquariumNotes;

import android.app.Notification;
import android.app.NotificationManager;
import android.content.Context;
import android.content.Intent;
import android.app.PendingIntent;
import android.graphics.Color;
import android.graphics.BitmapFactory;
import android.app.NotificationChannel;
import android.util.Log;

public class AquariumNotesNotification
{
    private static NotificationManager m_notificationManager;
    private static Notification.Builder m_builder;

    public AquariumNotesNotification() {}

    public static void notify(Context context, String message)
    {
        Log.i("NOTIFY", message);

        try {
            m_notificationManager = (NotificationManager) context.getSystemService(Context.NOTIFICATION_SERVICE);

            if (android.os.Build.VERSION.SDK_INT >= android.os.Build.VERSION_CODES.O) {
                int importance = NotificationManager.IMPORTANCE_DEFAULT;
                NotificationChannel notificationChannel = new NotificationChannel("Qt", "Qt Notifier", importance);
                m_notificationManager.createNotificationChannel(notificationChannel);
                m_builder = new Notification.Builder(context, notificationChannel.getId());
            } else {
                m_builder = new Notification.Builder(context);
            }

            m_builder.setSmallIcon(R.drawable.icon)
                    .setLargeIcon(BitmapFactory.decodeResource(context.getResources(), R.drawable.icon))
                    .setContentTitle("A message from Qt!")
                    .setContentText(message)
                    .setDefaults(Notification.DEFAULT_SOUND)
                    .setColor(Color.GREEN)
                    .setAutoCancel(true);

            m_notificationManager.notify(0, m_builder.build());
        } catch (Exception e) {
            e.printStackTrace();
        }
    }
}
