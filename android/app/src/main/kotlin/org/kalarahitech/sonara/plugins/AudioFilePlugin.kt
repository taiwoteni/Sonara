package org.kalarahitech.sonara.plugins

import android.content.Context
import android.database.Cursor
import android.provider.MediaStore
import android.util.Log
import io.flutter.plugin.common.BinaryMessenger
import io.flutter.plugin.common.MethodCall
import io.flutter.plugin.common.MethodChannel
import io.flutter.plugin.common.MethodChannel.MethodCallHandler
import io.flutter.plugin.common.MethodChannel.Result

class AudioFilePlugin(private val context: Context) : MethodCallHandler {
    private val TAG = "AudioFilePlugin"
    private val CHANNEL_NAME = "com.sonara.audio_files"

    fun registerWith(messenger: BinaryMessenger) {
        val channel = MethodChannel(messenger, CHANNEL_NAME)
        channel.setMethodCallHandler(this)
    }

    override fun onMethodCall(call: MethodCall, result: Result) {
        when (call.method) {
            "listAudioFiles" -> listAudioFiles(result)
            else -> result.notImplemented()
        }
    }

    private fun listAudioFiles(result: Result) {
        try {
            val audioFiles = mutableListOf<Map<String, Any>>()
            
            // Define the columns we want to retrieve
            val projection = arrayOf(
                MediaStore.Audio.Media._ID,
                MediaStore.Audio.Media.TITLE,
                MediaStore.Audio.Media.ARTIST,
                MediaStore.Audio.Media.ALBUM,
                MediaStore.Audio.Media.DATA,
                MediaStore.Audio.Media.DURATION
            )
            
            // Query only audio files
            val selection = "${MediaStore.Audio.Media.IS_MUSIC} != 0"
            
            // Sort by title
            val sortOrder = "${MediaStore.Audio.Media.TITLE} ASC"
            
            // Query the MediaStore
            val cursor: Cursor? = context.contentResolver.query(
                MediaStore.Audio.Media.EXTERNAL_CONTENT_URI,
                projection,
                selection,
                null,
                sortOrder
            )
            
            cursor?.use { c ->
                // Get column indices
                val idColumn = c.getColumnIndexOrThrow(MediaStore.Audio.Media._ID)
                val titleColumn = c.getColumnIndexOrThrow(MediaStore.Audio.Media.TITLE)
                val artistColumn = c.getColumnIndexOrThrow(MediaStore.Audio.Media.ARTIST)
                val albumColumn = c.getColumnIndexOrThrow(MediaStore.Audio.Media.ALBUM)
                val pathColumn = c.getColumnIndexOrThrow(MediaStore.Audio.Media.DATA)
                val durationColumn = c.getColumnIndexOrThrow(MediaStore.Audio.Media.DURATION)
                
                // Iterate through all rows
                while (c.moveToNext()) {
                    val id = c.getString(idColumn)
                    val title = c.getString(titleColumn)
                    val artist = c.getString(artistColumn)
                    val album = c.getString(albumColumn)
                    val path = c.getString(pathColumn)
                    val duration = c.getLong(durationColumn)
                    
                    // Create a map for this audio file
                    val audioFile = mapOf(
                        "id" to id,
                        "title" to title,
                        "artist" to artist,
                        "album" to album,
                        "path" to path,
                        "duration" to duration
                    )
                    
                    audioFiles.add(audioFile)
                }
            }
            
            // Return the list of audio files
            result.success(audioFiles)
        } catch (e: Exception) {
            Log.e(TAG, "Error listing audio files", e)
            result.error("ERROR", "Failed to list audio files: ${e.message}", null)
        }
    }
}
