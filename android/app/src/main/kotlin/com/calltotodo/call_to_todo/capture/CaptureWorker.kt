package com.calltotodo.call_to_todo.capture

import android.content.Context
import android.util.Log
import androidx.work.CoroutineWorker
import androidx.work.WorkerParameters

/**
 * 큐에서 메시지 하나를 꺼내 백그라운드 Flutter 엔진의 Dart 파이프라인에 넘긴다.
 *
 * Dart 가 응답(`processed`/`duplicate`/…)을 주면 성공. 엔진 기동 실패 같은 일시 오류는
 * 세 번까지 지수 백오프로 재시도하고 그 뒤에는 버린다 (알림 텍스트는 다시 오지 않으므로
 * 영원히 재시도할 이유가 없다).
 */
class CaptureWorker(context: Context, params: WorkerParameters) : CoroutineWorker(context, params) {

    override suspend fun doWork(): Result {
        val message = CaptureDispatcher.fromData(inputData) ?: return Result.failure()
        return try {
            val result = CaptureEngineHolder.process(applicationContext, message)
            Log.i(TAG, "processed source=${message.sourceApp} status=${result.status} candidates=${result.candidateCount}")
            Result.success()
        } catch (e: Exception) {
            Log.w(TAG, "capture processing failed (attempt ${runAttemptCount + 1})", e)
            if (runAttemptCount < MAX_ATTEMPTS - 1) Result.retry() else Result.failure()
        }
    }

    companion object {
        private const val TAG = "CaptureWorker"
        private const val MAX_ATTEMPTS = 3
    }
}
