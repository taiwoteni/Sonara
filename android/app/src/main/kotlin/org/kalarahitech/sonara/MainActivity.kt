package org.kalarahitech.sonara

import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import com.ryanheise.audioservice.AudioServiceActivity
import org.kalarahitech.sonara.plugins.AudioFilePlugin

class MainActivity : AudioServiceActivity() {
    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)
        // Register the AudioFilePlugin
        AudioFilePlugin(context).registerWith(flutterEngine.dartExecutor.binaryMessenger)
    }
}
