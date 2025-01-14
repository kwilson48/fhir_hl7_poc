package io.kevinwilson.fhir_hl7_poc.util

import java.text.SimpleDateFormat
import java.util.*
import java.time.LocalDate
import java.time.LocalDateTime
import java.time.format.DateTimeFormatter

object DateFormatter {
    private val dateFormat = SimpleDateFormat("MMM d, yyyy", Locale.getDefault())
    private val dateTimeFormat = SimpleDateFormat("MMM d, yyyy 'at' h:mm a", Locale.getDefault())
    private val isoFormat = SimpleDateFormat("yyyy-MM-dd'T'HH:mm:ss'Z'", Locale.getDefault()).apply {
        timeZone = TimeZone.getTimeZone("UTC")
    }

    // New formatters for LocalDate and LocalDateTime
    private val localDateFormatter = DateTimeFormatter.ofPattern("MMM d, yyyy", Locale.getDefault())
    private val localDateTimeFormatter = DateTimeFormatter.ofPattern("MMM d, yyyy 'at' h:mm a", Locale.getDefault())

    fun formatDate(date: Date?): String {
        return if (date != null) dateFormat.format(date) else ""
    }

    fun formatDateTime(date: Date?): String {
        return if (date != null) dateTimeFormat.format(date) else ""
    }

    // Add new method to handle ISO date strings
    fun formatDateTime(isoDateString: String?): String {
        if (isoDateString == null) return ""
        return try {
            val date = isoFormat.parse(isoDateString)
            dateTimeFormat.format(date)
        } catch (e: Exception) {
            ""
        }
    }

    // NEW: format LocalDate
    fun formatDate(localDate: LocalDate?): String {
        return localDate?.format(localDateFormatter) ?: ""
    }

    // NEW: format LocalDateTime
    fun formatDateTime(localDateTime: LocalDateTime?): String {
        return localDateTime?.format(localDateTimeFormatter) ?: ""
    }
} 