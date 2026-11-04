package com.calltotodo.call_to_todo.capture

import android.app.Notification
import android.service.notification.NotificationListenerService
import android.service.notification.StatusBarNotification
import android.util.Log
import androidx.core.app.NotificationCompat
import com.calltotodo.call_to_todo.CaptureSource
import com.calltotodo.call_to_todo.CapturedMessage

/**
 * 허용 앱(카카오톡·메시지·전화 앱 등)의 알림 텍스트를 읽어 [CaptureDispatcher] 큐에 넣는다.
 *
 * 읽는 것: 제목, 본문, bigText, MessagingStyle 메시지(보낸 사람·본문), InboxStyle 줄.
 * 읽지 않는 것: 첨부 이미지, 액션, 다른 앱의 알림(허용 목록 밖), 진행 중/그룹 요약 알림.
 * 본문 기준 중복 제거는 Dart 쪽 [MessageDeduper] 가 담당한다 (누적 MessagingStyle 갱신 대응).
 */
class CaptureNotificationListenerService : NotificationListenerService() {

    private lateinit var prefs: CapturePrefs

    override fun onCreate() {
        super.onCreate()
        prefs = CapturePrefs(this)
    }

    override fun onListenerConnected() {
        super.onListenerConnected()
        Log.i(TAG, "listener connected")
        // 프로세스가 살아 있는 동안 SMS 옵저버도 함께 유지한다 (Foreground Service 가 꺼져도).
        SmsCaptureController.sync(this)
    }

    override fun onNotificationPosted(sbn: StatusBarNotification) {
        if (!prefs.captureEnabled || !prefs.notificationsEnabled) return
        val packageName = sbn.packageName ?: return
        if (packageName == this.packageName || !prefs.isPackageAllowed(packageName)) return

        val notification = sbn.notification ?: return
        if (notification.flags and Notification.FLAG_GROUP_SUMMARY != 0) return
        if (notification.flags and Notification.FLAG_ONGOING_EVENT != 0) return

        val extracted = extract(notification) ?: return
        CaptureDispatcher.enqueue(
            this,
            CapturedMessage(
                sourceApp = packageName,
                sender = extracted.sender,
                text = extracted.text,
                timestampMillis = sbn.postTime,
                source = CaptureSource.NOTIFICATION,
            ),
        )
    }

    private data class Extracted(val sender: String?, val text: String)

    private fun extract(notification: Notification): Extracted? {
        val extras = notification.extras
        val title = extras.getCharSequence(Notification.EXTRA_TITLE)?.toString()?.trim()?.takeIf { it.isNotEmpty() }
        val conversationTitle =
            extras.getCharSequence(Notification.EXTRA_CONVERSATION_TITLE)?.toString()?.trim()?.takeIf { it.isNotEmpty() }

        val messages = messagingStyleLines(notification)
        if (messages.isNotEmpty()) {
            val senders = messages.mapNotNull { it.first }.distinct()
            val sender = conversationTitle ?: title ?: senders.singleOrNull()
            // 1:1 대화면 보낸 사람 접두어 없이, 단체방이면 "이름: 본문" 으로 남긴다.
            val lines = if (senders.size > 1) {
                messages.map { (who, body) -> if (who != null) "$who: $body" else body }
            } else {
                messages.map { it.second }
            }
            return Extracted(sender, lines.joinToString("\n"))
        }

        val inboxLines = extras.getCharSequenceArray(Notification.EXTRA_TEXT_LINES)
            ?.mapNotNull { it?.toString()?.trim()?.takeIf(String::isNotEmpty) }
            .orEmpty()
        if (inboxLines.isNotEmpty()) {
            return Extracted(conversationTitle ?: title, inboxLines.joinToString("\n"))
        }

        val bigText = extras.getCharSequence(Notification.EXTRA_BIG_TEXT)?.toString()?.trim()
        val text = extras.getCharSequence(Notification.EXTRA_TEXT)?.toString()?.trim()
        val body = listOfNotNull(bigText, text).firstOrNull { it.isNotEmpty() } ?: return null
        return Extracted(conversationTitle ?: title, body)
    }

    /** MessagingStyle 메시지를 (보낸 사람, 본문) 순서대로. 보낸 사람이 없으면 null. */
    private fun messagingStyleLines(notification: Notification): List<Pair<String?, String>> {
        val style = NotificationCompat.MessagingStyle.extractMessagingStyleFromNotification(notification)
            ?: return emptyList()
        return style.messages.mapNotNull { message ->
            val body = message.text?.toString()?.trim()?.takeIf { it.isNotEmpty() } ?: return@mapNotNull null
            val sender = message.person?.name?.toString()?.trim()?.takeIf { it.isNotEmpty() }
            sender to body
        }
    }

    companion object {
        private const val TAG = "CaptureListener"
    }
}
