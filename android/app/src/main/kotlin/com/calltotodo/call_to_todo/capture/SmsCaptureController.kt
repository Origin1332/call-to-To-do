package com.calltotodo.call_to_todo.capture

import android.content.Context
import android.database.ContentObserver
import android.net.Uri
import android.os.Handler
import android.os.Looper
import android.provider.Telephony
import android.util.Log
import com.calltotodo.call_to_todo.CaptureSource
import com.calltotodo.call_to_todo.CapturedMessage

/**
 * `content://sms` 변경을 지켜보다 **수신함(inbox)** 에 새로 들어온 문자만 읽어 큐에 넣는다.
 *
 * 프로세스 단위 싱글턴이다. Foreground Service, 알림 리스너, 부팅 리시버가 모두 [sync] 를
 * 불러 "설정이 켜져 있고 READ_SMS 가 있으면 등록, 아니면 해제" 상태로 맞춘다.
 * 마지막으로 본 `_id` 를 저장해 두므로 옵저버가 여러 번 깨어나도 같은 문자를 두 번 읽지 않고,
 * 처음 등록할 때는 현재 최대 `_id` 로 맞춰 과거 문자를 처리하지 않는다.
 *
 * 읽는 컬럼: `_id`, `address`(보낸 번호), `body`, `date`. 보낸 문자(sent)나 MMS 본문은 읽지 않는다.
 */
object SmsCaptureController {

    private const val TAG = "SmsCapture"
    private val smsUri: Uri = Telephony.Sms.CONTENT_URI
    private val inboxUri: Uri = Telephony.Sms.Inbox.CONTENT_URI

    private var observer: ContentObserver? = null

    @Synchronized
    fun sync(context: Context) {
        val appContext = context.applicationContext
        val prefs = CapturePrefs(appContext)
        val shouldObserve = prefs.captureEnabled && prefs.smsEnabled && CaptureHostApiImpl.hasSmsPermission(appContext)
        if (shouldObserve) register(appContext, prefs) else unregister(appContext)
    }

    @Synchronized
    fun unregister(context: Context) {
        val current = observer ?: return
        context.applicationContext.contentResolver.unregisterContentObserver(current)
        observer = null
        Log.i(TAG, "observer unregistered")
    }

    private fun register(appContext: Context, prefs: CapturePrefs) {
        if (observer != null) return
        if (prefs.lastSmsId < 0) prefs.lastSmsId = currentMaxId(appContext)

        val newObserver = object : ContentObserver(Handler(Looper.getMainLooper())) {
            override fun onChange(selfChange: Boolean, uri: Uri?) {
                drainNewInboxMessages(appContext, prefs)
            }
        }
        appContext.contentResolver.registerContentObserver(smsUri, true, newObserver)
        observer = newObserver
        Log.i(TAG, "observer registered (lastSmsId=${prefs.lastSmsId})")
    }

    private fun currentMaxId(context: Context): Long {
        context.contentResolver.query(inboxUri, arrayOf("MAX(${Telephony.Sms._ID})"), null, null, null)?.use { c ->
            if (c.moveToFirst() && !c.isNull(0)) return c.getLong(0)
        }
        return 0L
    }

    @Synchronized
    private fun drainNewInboxMessages(context: Context, prefs: CapturePrefs) {
        if (!CaptureHostApiImpl.hasSmsPermission(context)) return
        val projection = arrayOf(Telephony.Sms._ID, Telephony.Sms.ADDRESS, Telephony.Sms.BODY, Telephony.Sms.DATE)
        val selection = "${Telephony.Sms._ID} > ?"
        val args = arrayOf(prefs.lastSmsId.toString())
        var maxSeen = prefs.lastSmsId
        try {
            context.contentResolver.query(inboxUri, projection, selection, args, "${Telephony.Sms._ID} ASC")?.use { c ->
                while (c.moveToNext()) {
                    val id = c.getLong(0)
                    maxSeen = maxOf(maxSeen, id)
                    val body = c.getString(2)?.trim().orEmpty()
                    if (body.isEmpty()) continue
                    CaptureDispatcher.enqueue(
                        context,
                        CapturedMessage(
                            sourceApp = SOURCE_APP,
                            sender = c.getString(1),
                            text = body,
                            timestampMillis = c.getLong(3).takeIf { it > 0 } ?: System.currentTimeMillis(),
                            source = CaptureSource.SMS,
                        ),
                    )
                }
            }
        } catch (e: SecurityException) {
            Log.w(TAG, "READ_SMS revoked", e)
        }
        if (maxSeen != prefs.lastSmsId) prefs.lastSmsId = maxSeen
    }

    /** Dart 쪽 `CaptureSources.smsObserverSourceApp` 과 같다. */
    const val SOURCE_APP = "sms"
}
