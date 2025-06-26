package org.kalarahitech.sonara.plugins

import android.content.ContentUris
import android.content.Context
import android.database.Cursor
import android.graphics.Bitmap
import android.graphics.BitmapFactory
import android.provider.MediaStore
import android.util.Base64
import android.util.Log
import android.util.Size
import io.flutter.plugin.common.BinaryMessenger
import io.flutter.plugin.common.MethodCall
import io.flutter.plugin.common.MethodChannel
import io.flutter.plugin.common.MethodChannel.MethodCallHandler
import io.flutter.plugin.common.MethodChannel.Result
import java.io.ByteArrayOutputStream

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
            "getHighQualityArtwork" -> getHighQualityArtwork(call, result)
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
                MediaStore.Audio.Media.DURATION,
                MediaStore.Audio.Media.ALBUM_ID
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
                val albumIdColumn = c.getColumnIndexOrThrow(MediaStore.Audio.Media.ALBUM_ID)
                
                // Iterate through all rows
                while (c.moveToNext()) {
                    val id = c.getString(idColumn)
                    val title = c.getString(titleColumn)
                    val artist = c.getString(artistColumn)
                    val album = c.getString(albumColumn)
                    val path = c.getString(pathColumn)
                    val duration = c.getLong(durationColumn)
                    val albumId = c.getLong(albumIdColumn)
                    
                    // Get low-resolution thumbnail for album art
                    var thumbnailData = ""
                    try {
                        Log.d(TAG, "Fetching thumbnail for album ID: $albumId, Song: $title")
                        val thumbnailByteArray = getAlbumArt(albumId, thumbnailSize = true)
                        if (thumbnailByteArray != null) {
                            thumbnailData = Base64.encodeToString(thumbnailByteArray, Base64.NO_WRAP)
                            Log.d(TAG, "Thumbnail fetched successfully for $title, Data length: ${thumbnailData.length}")
                            // Log a snippet of the base64 string for debugging
                            if (thumbnailData.length > 50) {
                                Log.d(TAG, "Base64 snippet: ${thumbnailData.substring(0, 50)}...");
                            } else {
                                Log.d(TAG, "Base64 snippet: $thumbnailData");
                            }
                        } else {
                            Log.d(TAG, "No thumbnail found for $title")
                        }
                    } catch (e: Exception) {
                        Log.e(TAG, "Error getting thumbnail for album $album, Song: $title", e)
                    }
                    
                    // Create a map for this audio file
                    val audioFile = mapOf(
                        "id" to id,
                        "title" to title,
                        "artist" to artist,
                        "album" to album,
                        "path" to path,
                        "duration" to duration,
                        "thumbnailData" to thumbnailData
                    )
                    
                    audioFiles.add(audioFile)
                }
            }
            cursor?.close()
            
            // Return the list of audio files
            result.success(audioFiles)
        } catch (e: Exception) {
            Log.e(TAG, "Error listing audio files", e)
            result.error("ERROR", "Failed to list audio files: ${e.message}", null)
        }
    }
    
    private fun getHighQualityArtwork(call: MethodCall, result: Result) {
        try {
            val arguments = call.arguments as? Map<*, *>
            val songId = arguments?.get("id") as? String
            if (songId == null) {
                result.error("INVALID_ARGUMENT", "Song ID is required", null)
                return
            }
            
            var artworkData = ""
            // Query for the specific song to get album ID
            val projection = arrayOf(
                MediaStore.Audio.Media.ALBUM_ID
            )
            val selection = "${MediaStore.Audio.Media._ID}=?"
            val selectionArgs = arrayOf(songId)
            
            val cursor: Cursor? = context.contentResolver.query(
                MediaStore.Audio.Media.EXTERNAL_CONTENT_URI,
                projection,
                selection,
                selectionArgs,
                null
            )
            
            cursor?.use { c ->
                if (c.moveToFirst()) {
                    val albumIdColumn = c.getColumnIndexOrThrow(MediaStore.Audio.Media.ALBUM_ID)
                    val albumId = c.getLong(albumIdColumn)
                    
                    Log.d(TAG, "Fetching high-quality artwork for song ID: $songId, album ID: $albumId")
                    val artworkByteArray = getAlbumArt(albumId, thumbnailSize = false)
                    if (artworkByteArray != null) {
                        artworkData = Base64.encodeToString(artworkByteArray, Base64.NO_WRAP)
                        Log.d(TAG, "High-quality artwork fetched successfully for song ID: $songId, Data length: ${artworkData.length}")
                        // Log a snippet of the base64 string for debugging
                        if (artworkData.length > 50) {
                            Log.d(TAG, "Base64 snippet: ${artworkData.substring(0, 50)}...")
                        }
                    } else {
                        Log.d(TAG, "No high-quality artwork found for song ID: $songId")
                    }
                } else {
                    Log.d(TAG, "Song not found with ID: $songId")
                }
            }
            cursor?.close()
            
            result.success(mapOf("artworkData" to artworkData))
        } catch (e: Exception) {
            Log.e(TAG, "Error getting high-quality artwork", e)
            result.error("ERROR", "Failed to get high-quality artwork: ${e.message}", null)
        }
    }
    
    private fun getAlbumArt(albumId: Long, thumbnailSize: Boolean): ByteArray? {
        return try {
            val albumUri = ContentUris.withAppendedId(
                MediaStore.Audio.Albums.EXTERNAL_CONTENT_URI,
                albumId
            )
            
            // For Android 10+ (API 29+)
            if (android.os.Build.VERSION.SDK_INT >= android.os.Build.VERSION_CODES.Q) {
                val size = if (thumbnailSize) Size(100, 100) else Size(500, 500)
                Log.d(TAG, "Using loadThumbnail for album ID: $albumId, Size: ${size.width}x${size.height}")
                val bitmap = context.contentResolver.loadThumbnail(albumUri, size, null)
                bitmapToByteArray(bitmap, thumbnailSize)
            } else {
                // For older versions, try to get album art through legacy method
                Log.d(TAG, "Using legacy method for album ID: $albumId")
                getAlbumArtLegacy(albumId, thumbnailSize)
            }
        } catch (e: Exception) {
            Log.e(TAG, "Exception in getAlbumArt for album ID: $albumId", e)
            null
        }
    }
    
    private fun getAlbumArtLegacy(albumId: Long, thumbnailSize: Boolean): ByteArray? {
        val projection = arrayOf(MediaStore.Audio.Albums.ALBUM_ART)
        val cursor = context.contentResolver.query(
            MediaStore.Audio.Albums.EXTERNAL_CONTENT_URI,
            projection,
            "${MediaStore.Audio.Albums._ID}=?",
            arrayOf(albumId.toString()),
            null
        )
        
        cursor?.use {
            if (it.moveToFirst()) {
                val albumArtPathColumn = it.getColumnIndex(MediaStore.Audio.Albums.ALBUM_ART)
                if (albumArtPathColumn >= 0) {
                    val albumArtPath = it.getString(albumArtPathColumn)
                    if (!albumArtPath.isNullOrEmpty()) {
                        Log.d(TAG, "Legacy method found album art path for album ID: $albumId")
                        // Decode the image, optionally resizing for thumbnail
                        val options = BitmapFactory.Options()
                        if (thumbnailSize) {
                            options.inJustDecodeBounds = true
                            BitmapFactory.decodeFile(albumArtPath, options)
                            options.inSampleSize = calculateInSampleSize(options, 100, 100)
                            options.inJustDecodeBounds = false
                        }
                        val bitmap = BitmapFactory.decodeFile(albumArtPath, if (thumbnailSize) options else null)
                        return bitmapToByteArray(bitmap, thumbnailSize)
                    } else {
                        Log.d(TAG, "Legacy method: Album art path is null or empty for album ID: $albumId")
                    }
                }
            } else {
                Log.d(TAG, "Legacy method: No album found with ID: $albumId")
            }
        }
        cursor?.close()
        return null
    }
    
    private fun bitmapToByteArray(bitmap: Bitmap?, thumbnailSize: Boolean): ByteArray? {
        if (bitmap == null) {
            Log.d(TAG, "Bitmap is null, no data to return")
            return null
        }
        val stream = ByteArrayOutputStream()
        bitmap.compress(Bitmap.CompressFormat.JPEG, if (thumbnailSize) 50 else 80, stream)
        val byteArray = stream.toByteArray()
        Log.d(TAG, "Bitmap converted to byte array, length: ${byteArray.size}, Thumbnail: $thumbnailSize")
        bitmap.recycle()
        return byteArray
    }
    
    // Helper function to calculate inSampleSize for bitmap resizing
    private fun calculateInSampleSize(options: BitmapFactory.Options, reqWidth: Int, reqHeight: Int): Int {
        val height = options.outHeight
        val width = options.outWidth
        var inSampleSize = 1
        
        if (height > reqHeight || width > reqWidth) {
            val halfHeight = height / 2
            val halfWidth = width / 2
            
            while ((halfHeight / inSampleSize) >= reqHeight && (halfWidth / inSampleSize) >= reqWidth) {
                inSampleSize *= 2
            }
        }
        return inSampleSize
    }
}
