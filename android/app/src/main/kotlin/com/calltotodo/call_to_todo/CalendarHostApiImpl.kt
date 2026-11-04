package com.calltotodo.call_to_todo

import android.Manifest
import android.app.Activity
import android.content.ContentUris
import android.content.ContentValues
import android.content.pm.PackageManager
import android.provider.CalendarContract
import androidx.core.app.ActivityCompat
import androidx.core.content.ContextCompat
import java.util.TimeZone
import kotlin.coroutines.resume
import kotlinx.coroutines.suspendCancellableCoroutine

/**
 * CalendarContract 기반 [CalendarHostApi] 구현.
 *
 * 구글 REST API 를 쓰지 않는다. 기기 캘린더 프로바이더에 쓰면 해당 계정의
 * 동기화 어댑터(구글 캘린더 앱)가 서버로 올린다.
 */
class CalendarHostApiImpl(private val activity: Activity) : CalendarHostApi {

    private var pendingPermission: ((Boolean) -> Unit)? = null

    override fun hasCalendarPermission(): Boolean =
        CALENDAR_PERMISSIONS.all {
            ContextCompat.checkSelfPermission(activity, it) == PackageManager.PERMISSION_GRANTED
        }

    override suspend fun requestCalendarPermission(): Boolean {
        if (hasCalendarPermission()) return true
        return suspendCancellableCoroutine { continuation ->
            pendingPermission?.invoke(false)
            pendingPermission = { granted ->
                pendingPermission = null
                if (continuation.isActive) continuation.resume(granted)
            }
            ActivityCompat.requestPermissions(activity, CALENDAR_PERMISSIONS, PERMISSION_REQUEST_CODE)
        }
    }

    /** MainActivity.onRequestPermissionsResult 에서 호출. 처리했으면 true. */
    fun onRequestPermissionsResult(requestCode: Int, grantResults: IntArray): Boolean {
        if (requestCode != PERMISSION_REQUEST_CODE) return false
        val granted = grantResults.isNotEmpty() && grantResults.all { it == PackageManager.PERMISSION_GRANTED }
        pendingPermission?.invoke(granted)
        return true
    }

    override fun listWritableCalendars(): List<DeviceCalendar> {
        requirePermission()
        val projection = arrayOf(
            CalendarContract.Calendars._ID,
            CalendarContract.Calendars.CALENDAR_DISPLAY_NAME,
            CalendarContract.Calendars.ACCOUNT_NAME,
            CalendarContract.Calendars.ACCOUNT_TYPE,
            CalendarContract.Calendars.CALENDAR_COLOR,
            CalendarContract.Calendars.IS_PRIMARY,
            CalendarContract.Calendars.CALENDAR_ACCESS_LEVEL,
        )
        val selection =
            "${CalendarContract.Calendars.CALENDAR_ACCESS_LEVEL} >= ? AND ${CalendarContract.Calendars.VISIBLE} = 1"
        val args = arrayOf(CalendarContract.Calendars.CAL_ACCESS_CONTRIBUTOR.toString())
        val result = mutableListOf<DeviceCalendar>()
        activity.contentResolver.query(
            CalendarContract.Calendars.CONTENT_URI, projection, selection, args,
            "${CalendarContract.Calendars.IS_PRIMARY} DESC, ${CalendarContract.Calendars.CALENDAR_DISPLAY_NAME} ASC",
        )?.use { cursor ->
            while (cursor.moveToNext()) {
                result.add(
                    DeviceCalendar(
                        id = cursor.getLong(0),
                        displayName = cursor.getString(1) ?: "",
                        accountName = cursor.getString(2) ?: "",
                        accountType = cursor.getString(3) ?: "",
                        color = cursor.getInt(4).toLong(),
                        isPrimary = cursor.getInt(5) == 1,
                    ),
                )
            }
        }
        return result
    }

    override fun insertEvent(event: CalendarEventInput): String {
        requirePermission()
        val values = ContentValues().apply {
            put(CalendarContract.Events.CALENDAR_ID, event.calendarId)
            put(CalendarContract.Events.TITLE, event.title)
            event.description?.let { put(CalendarContract.Events.DESCRIPTION, it) }
            put(CalendarContract.Events.DTSTART, event.startMillis)
            put(CalendarContract.Events.ALL_DAY, if (event.allDay) 1 else 0)
            put(
                CalendarContract.Events.EVENT_TIMEZONE,
                if (event.allDay) TimeZone.getTimeZone("UTC").id else TimeZone.getDefault().id,
            )
            val rrule = event.rrule?.takeIf { it.isNotBlank() }
            if (rrule != null) {
                // 반복 이벤트는 DTEND 대신 DURATION 을 써야 한다 (CalendarContract 규칙).
                put(CalendarContract.Events.RRULE, rrule)
                put(CalendarContract.Events.DURATION, toRfc2445Duration(event))
            } else {
                put(CalendarContract.Events.DTEND, event.endMillis)
            }
        }
        val uri = activity.contentResolver.insert(CalendarContract.Events.CONTENT_URI, values)
            ?: throw IllegalStateException("캘린더 이벤트 삽입에 실패했습니다.")
        return ContentUris.parseId(uri).toString()
    }

    private fun toRfc2445Duration(event: CalendarEventInput): String {
        val seconds = ((event.endMillis - event.startMillis) / 1000).coerceAtLeast(0)
        return if (event.allDay) "P${(seconds / 86_400).coerceAtLeast(1)}D" else "PT${seconds}S"
    }

    private fun requirePermission() {
        if (!hasCalendarPermission()) {
            throw SecurityException("캘린더 권한이 없습니다. requestCalendarPermission() 을 먼저 호출하세요.")
        }
    }

    companion object {
        private const val PERMISSION_REQUEST_CODE = 0xCA1
        private val CALENDAR_PERMISSIONS =
            arrayOf(Manifest.permission.READ_CALENDAR, Manifest.permission.WRITE_CALENDAR)
    }
}
