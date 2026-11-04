package com.calltotodo.call_to_todo.capture

import android.content.Context
import android.os.Handler
import android.os.Looper
import android.util.Log
import com.calltotodo.call_to_todo.CaptureFlutterApi
import com.calltotodo.call_to_todo.CaptureHostApi
import com.calltotodo.call_to_todo.CaptureProcessResult
import com.calltotodo.call_to_todo.CapturedMessage
import io.flutter.FlutterInjector
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.embedding.engine.dart.DartExecutor
import kotlinx.coroutines.CompletableDeferred
import kotlinx.coroutines.Dispatchers
import kotlinx.coroutines.sync.Mutex
import kotlinx.coroutines.sync.withLock
import kotlinx.coroutines.withContext
import kotlinx.coroutines.withTimeout

/**
 * 헤드리스(UI 없는) Flutter 엔진 하나를 지연 생성해 유지한다.
 *
 * 엔진은 `lib/features/capture/capture_background.dart` 의 `captureMain` 진입점을 실행한다.
 * Dart 가 [CaptureFlutterApi] 핸들러를 등록하고 [CaptureHostApi.signalDartReady] 를 부르면
 * 준비 완료. 이후 [process] 가 메시지를 하나씩 순서대로 넘긴다.
 *
 * 앱이 완전히 종료돼 있어도(액티비티 없음) 알림 리스너 → WorkManager → 이 엔진 경로로
 * 규칙 파서 → (Gemini) → 확인 알림까지 동작한다. 일정 시간 쓰이지 않으면 메모리 절약을 위해 내린다.
 */
object CaptureEngineHolder {

    private const val TAG = "CaptureEngine"
    private const val ENTRYPOINT = "captureMain"
    private const val READY_TIMEOUT_MS = 30_000L
    private const val PROCESS_TIMEOUT_MS = 90_000L
    private const val IDLE_SHUTDOWN_MS = 3 * 60_000L

    private val mainHandler = Handler(Looper.getMainLooper())
    private val mutex = Mutex()

    private var engine: FlutterEngine? = null
    private var flutterApi: CaptureFlutterApi? = null
    private var ready: CompletableDeferred<Unit>? = null
    private val idleShutdown = Runnable { shutdown() }

    suspend fun process(context: Context, message: CapturedMessage): CaptureProcessResult =
        mutex.withLock {
            val api = withContext(Dispatchers.Main) { ensureEngine(context.applicationContext) }
            try {
                withTimeout(PROCESS_TIMEOUT_MS) { api.processMessage(message) }
            } finally {
                withContext(Dispatchers.Main) { scheduleIdleShutdown() }
            }
        }

    /** 메인 스레드에서만 호출. */
    private suspend fun ensureEngine(appContext: Context): CaptureFlutterApi {
        mainHandler.removeCallbacks(idleShutdown)
        flutterApi?.let { api ->
            ready?.let { withTimeout(READY_TIMEOUT_MS) { it.await() } }
            return api
        }

        Log.i(TAG, "starting headless Flutter engine")
        val readySignal = CompletableDeferred<Unit>()
        ready = readySignal

        val loader = FlutterInjector.instance().flutterLoader()
        loader.startInitialization(appContext)
        loader.ensureInitializationComplete(appContext, null)

        val newEngine = FlutterEngine(appContext)
        val messenger = newEngine.dartExecutor.binaryMessenger
        CaptureHostApi.setUp(
            messenger,
            CaptureHostApiImpl(appContext, activity = null, onDartReady = { readySignal.complete(Unit) }),
        )
        newEngine.dartExecutor.executeDartEntrypoint(
            DartExecutor.DartEntrypoint(loader.findAppBundlePath(), ENTRYPOINT),
        )
        engine = newEngine
        val api = CaptureFlutterApi(messenger)
        flutterApi = api

        try {
            withTimeout(READY_TIMEOUT_MS) { readySignal.await() }
        } catch (e: Exception) {
            shutdown()
            throw IllegalStateException("백그라운드 Dart 엔진이 준비되지 않았습니다.", e)
        }
        return api
    }

    private fun scheduleIdleShutdown() {
        mainHandler.removeCallbacks(idleShutdown)
        mainHandler.postDelayed(idleShutdown, IDLE_SHUTDOWN_MS)
    }

    private fun shutdown() {
        val current = engine ?: return
        Log.i(TAG, "shutting down headless Flutter engine")
        CaptureHostApi.setUp(current.dartExecutor.binaryMessenger, null)
        current.destroy()
        engine = null
        flutterApi = null
        ready = null
    }
}
