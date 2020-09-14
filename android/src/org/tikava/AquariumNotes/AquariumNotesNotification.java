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

    public static void notify(Context context, String title, String message, String details)
    {
        try {

            NotificationCompat.Builder mBuilder = new NotificationCompat.Builder(context)
                                    .setSmallIcon(R.drawable.icon)
                                    .setContentTitle(title)
                                    .setContentText(message)
                                    .setStyle(new NotificationCompat.BigTextStyle()
                                             .bigText(details));

            NotificationManager mNotificationManager = (NotificationManager) context.getSystemService(Context.NOTIFICATION_SERVICE);
            // mId allows you to update the notification later on.
            mNotificationManager.notify(0, mBuilder.build());


            /*
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
                    .setContentText(message)
                    .setDefaults(Notification.DEFAULT_SOUND)
                    .setColor(Color.GREEN)
                    .setAutoCancel(true);

            m_notificationManager.notify(0, m_builder.build());
            */
        } catch (Exception e) {
            e.printStackTrace();
        }
    }
}
