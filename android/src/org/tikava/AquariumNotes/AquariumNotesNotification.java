package org.tikava.AquariumNotes;

import org.tikava.AquariumNotes.R;
import android.app.Notification;
import android.app.NotificationManager;
import android.content.Context;
import android.content.Intent;
import android.app.PendingIntent;
import android.graphics.Color;
import android.graphics.BitmapFactory;
import android.app.NotificationChannel;
import android.util.Log;

import android.support.v4.app.NotificationCompat;

public class AquariumNotesNotification
{
    private static NotificationManager m_notificationManager;
    private static Notification.Builder m_builder;
    private static String channelId = "AquariumNotes";
    private static String channelName = "Aquarium Notes notification";

    public AquariumNotesNotification() {}

    public static void notify(Context context, String title, String message)
    {
        try {
            m_notificationManager = (NotificationManager) context.getSystemService(Context.NOTIFICATION_SERVICE);

            if (android.os.Build.VERSION.SDK_INT >= android.os.Build.VERSION_CODES.O) {
                int importance = NotificationManager.IMPORTANCE_DEFAULT;
                NotificationChannel notificationChannel = new NotificationChannel(channelId, channelName, importance);
                m_notificationManager.createNotificationChannel(notificationChannel);
                m_builder = new Notification.Builder(context, notificationChannel.getId());
            } else {
                m_builder = new Notification.Builder(context);
            }

            m_builder.setSmallIcon(R.drawable.icon)
                    .setLargeIcon(BitmapFactory.decodeResource(context.getResources(), R.drawable.icon))
                    .setContentTitle(title)
                    .setDefaults(Notification.DEFAULT_SOUND)
                    .setColor(Color.GREEN)
                    .setAutoCancel(true)
                    .setStyle(new Notification.BigTextStyle().bigText(message));

            m_notificationManager.notify(0, m_builder.build());
        } catch (Exception e) {
            e.printStackTrace();
        }
    }
}
