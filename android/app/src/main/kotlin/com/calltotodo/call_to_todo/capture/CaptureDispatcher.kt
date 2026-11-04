package com.calltotodo.call_to_todo.capture

import android.content.Context
import androidx.work.BackoffPolicy
import androidx.work.Data
import androidx.work.ExistingWorkPolicy
import androidx.work.OneTimeWorkRequestBuilder
import androidx.work.OutOfQuotaPolicy
import androidx.work.WorkManager
import androidx.work.workDataOf
import com.calltotodo.call_to_todo.CaptureSource
import com.calltotodo.call_to_todo.CapturedMessage
import java.util.concurrent.TimeUnit

/**
 * 수집기(알림 리스너·SMS 옵저버)와 Dart 파이프라인 사이의 큐.
 *
 * 메시지 하나를 WorkManager 작업 하나로 바꿔 넣는다. WorkManager 가 프로세스 종료 후
 * 재시도·순서 보장을 맡고, [CaptureWorker] 가 백그라운드 Flutter 엔진에서 Dart 를 돌린다.
 * 작업 입력은 10KB 제한이 있어 본문을 [MAX_TEXT_CHARS] 로 자른다 (일정 표현이 들어갈 만큼은 충분하다).
 */
object CaptureDispatcher {

    const val KEY_SOURCE_APP = "sourceApp"
    const val KEY_SENDER = "sender"
    const val KEY_TEXT = "text"
    const val KEY_TIMESTAMP = "timestampMillis"
    const val KEY_SOURCE = "source"

    private const val UNIQUE_QUEUE = "capture_pipeline"
    private const val MAX_TEXT_CHARS = 4000

    fun enqueue(context: Context, message: CapturedMessage) {
        val text = message.text.trim()
        if (text.isEmpty()) return

        val request = OneTimeWorkRequestBuilder<CaptureWorker>()
            .setInputData(toData(message.copy(text = text.take(MAX_TEXT_CHARS))))
            .setExpedited(OutOfQuotaPolicy.RUN_AS_NON_EXPEDITED_WORK_REQUEST)
            .setBackoffCriteria(BackoffPolicy.EXPONENTIAL, 30, TimeUnit.SECONDS)
            .addTag(TAG)
            .build()

        // APPEND_OR_REPLACE: 큐가 하나뿐이므로 Dart 엔진에 메시지가 한 번에 하나씩 들어간다.
        WorkManager.getInstance(context.applicationContext)
            .enqueueUniqueWork(UNIQUE_QUEUE, ExistingWorkPolicy.APPEND_OR_REPLACE, request)
    }

    fun toData(message: CapturedMessage): Data = workDataOf(
        KEY_SOURCE_APP to message.sourceApp,
        KEY_SENDER to message.sender,
        KEY_TEXT to message.text,
        KEY_TIMESTAMP to message.timestampMillis,
        KEY_SOURCE to message.source.name,
    )

    fun fromData(data: Data): CapturedMessage? {
        val text = data.getString(KEY_TEXT) ?: return null
        val sourceApp = data.getString(KEY_SOURCE_APP) ?: return null
        val source = data.getString(KEY_SOURCE)?.let { name ->
            CaptureSource.entries.firstOrNull { it.name == name }
        } ?: CaptureSource.NOTIFICATION
        return CapturedMessage(
            sourceApp = sourceApp,
            sender = data.getString(KEY_SENDER),
            text = text,
            timestampMillis = data.getLong(KEY_TIMESTAMP, System.currentTimeMillis()),
            source = source,
        )
    }

    const val TAG = "capture"
}
