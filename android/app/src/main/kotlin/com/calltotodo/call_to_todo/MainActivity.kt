package com.calltotodo.call_to_todo

import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine

class MainActivity : FlutterActivity() {

    private var calendarApi: CalendarHostApiImpl? = null

    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)
        val api = CalendarHostApiImpl(this)
        calendarApi = api
        CalendarHostApi.setUp(flutterEngine.dartExecutor.binaryMessenger, api)
    }

    override fun cleanUpFlutterEngine(flutterEngine: FlutterEngine) {
        CalendarHostApi.setUp(flutterEngine.dartExecutor.binaryMessenger, null)
        calendarApi = null
        super.cleanUpFlutterEngine(flutterEngine)
    }

    override fun onRequestPermissionsResult(
        requestCode: Int,
        permissions: Array<out String>,
        grantResults: IntArray,
    ) {
        if (calendarApi?.onRequestPermissionsResult(requestCode, grantResults) == true) return
        super.onRequestPermissionsResult(requestCode, permissions, grantResults)
    }
}
