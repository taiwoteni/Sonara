import Flutter
import UIKit
import MediaPlayer

@main
@objc class AppDelegate: FlutterAppDelegate {
  override func application(
    _ application: UIApplication,
    didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
  ) -> Bool {
    let controller = window?.rootViewController as! FlutterViewController
    
    // Register the audio files method channel directly
    let audioChannel = FlutterMethodChannel(
      name: "com.sonara.audio_files",
      binaryMessenger: controller.binaryMessenger)
    
    // Set up the method call handler
    audioChannel.setMethodCallHandler { [weak self] (call, result) in
      guard let self = self else { return }
      
      switch call.method {
      case "listAudioFiles":
        self.listAudioFiles(result)
      default:
        result(FlutterMethodNotImplemented)
      }
    }
    
    GeneratedPluginRegistrant.register(with: self)
    return super.application(application, didFinishLaunchingWithOptions: launchOptions)
  }
  
  // List audio files from the device
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
