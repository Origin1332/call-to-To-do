package com.calltotodo.call_to_todo

import com.calltotodo.call_to_todo.capture.CaptureHostApiImpl
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine

class MainActivity : FlutterActivity() {

    private var calendarApi: CalendarHostApiImpl? = null
    private var captureApi: CaptureHostApiImpl? = null

    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)
        val messenger = flutterEngine.dartExecutor.binaryMessenger

        val calendar = CalendarHostApiImpl(this)
        calendarApi = calendar
        CalendarHostApi.setUp(messenger, calendar)

        val capture = CaptureHostApiImpl(this, activity = this)
        captureApi = capture
        CaptureHostApi.setUp(messenger, capture)
    }

    override fun cleanUpFlutterEngine(flutterEngine: FlutterEngine) {
        val messenger = flutterEngine.dartExecutor.binaryMessenger
        CalendarHostApi.setUp(messenger, null)
        CaptureHostApi.setUp(messenger, null)
        calendarApi = null
        captureApi = null
        super.cleanUpFlutterEngine(flutterEngine)
    }

    override fun onRequestPermissionsResult(
        requestCode: Int,
        permissions: Array<out String>,
        grantResults: IntArray,
    ) {
        if (calendarApi?.onRequestPermissionsResult(requestCode, grantResults) == true) return
        if (captureApi?.onRequestPermissionsResult(requestCode, grantResults) == true) return
        super.onRequestPermissionsResult(requestCode, permissions, grantResults)
    }
}
