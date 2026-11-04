package com.calltotodo.call_to_todo.capture

import android.content.BroadcastReceiver
import android.content.Context
import android.content.Intent
import android.util.Log

/**
 * 부팅(또는 앱 업데이트) 후 사용자가 수집을 켜 두었으면 Foreground Service 를 다시 띄운다.
 *
 * Android 15 부터 BOOT_COMPLETED 리시버는 dataSync 서비스를 시작할 수 없어 예외가 난다.
 * 그 경우 서비스 없이 SMS 옵저버만 등록하고, 알림 리스너는 시스템이 알아서 다시 바인딩한다.
 * 서비스는 사용자가 앱을 다음에 열 때 [CaptureHostApiImpl.setCaptureConfig] 로 재시작된다.
 */
class BootReceiver : BroadcastReceiver() {

    override fun onReceive(context: Context, intent: Intent) {
        if (intent.action != Intent.ACTION_BOOT_COMPLETED && intent.action != Intent.ACTION_MY_PACKAGE_REPLACED) return
        val prefs = CapturePrefs(context)
        if (!prefs.captureEnabled) return

        val started = CaptureForegroundService.start(context)
        Log.i(TAG, "boot: capture enabled, foreground service started=$started")
        SmsCaptureController.sync(context)
    }

    companion object {
        private const val TAG = "CaptureBoot"
    }
}
