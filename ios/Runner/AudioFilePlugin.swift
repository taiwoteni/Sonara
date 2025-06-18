import Flutter
import UIKit
import MediaPlayer

@objc public class AudioFilePlugin: NSObject, FlutterPlugin {
    
    @objc public static func register(with registrar: FlutterPluginRegistrar) {
        let channel = FlutterMethodChannel(name: "com.sonara.audio_files", binaryMessenger: registrar.messenger())
        let instance = AudioFilePlugin()
        registrar.addMethodCallDelegate(instance, channel: channel)
    }
    
    public func handle(_ call: FlutterMethodCall, result: @escaping FlutterResult) {
        switch call.method {
        case "listAudioFiles":
            listAudioFiles(result)
        default:
            result(FlutterMethodNotImplemented)
        }
    }
    
    private func listAudioFiles(_ result: @escaping FlutterResult) {
        // Request authorization for media library access
        MPMediaLibrary.requestAuthorization { status in
            if status != .authorized {
                // Not authorized, return empty list
                DispatchQueue.main.async {
                    result([])
                }
                return
            }
            
            // Create a query for all songs
            let query = MPMediaQuery.songs()
            
            // Get all songs
            guard let songs = query.items else {
                DispatchQueue.main.async {
                    result([])
                }
                return
            }
            
            // Convert songs to dictionaries
            var audioFiles: [[String: Any]] = []
            
            for song in songs {
                // Get song properties
                let id = song.persistentID.description
                let title = song.title ?? "Unknown Title"
                let artist = song.artist ?? "Unknown Artist"
                let album = song.albumTitle ?? "Unknown Album"
                let path = "" // iOS doesn't provide direct file paths
                let duration = song.playbackDuration
                
                // Create a dictionary for this song
                let audioFile: [String: Any] = [
                    "id": id,
                    "title": title,
                    "artist": artist,
                    "album": album,
                    "path": path,
                    "duration": Int(duration * 1000) // Convert to milliseconds to match Android
                ]
                
                audioFiles.append(audioFile)
            }
            
            // Return the list of audio files
            DispatchQueue.main.async {
                result(audioFiles)
            }
        }
    }
}
