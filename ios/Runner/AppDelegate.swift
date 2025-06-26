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
      case "getHighQualityArtwork":
        self.getHighQualityArtwork(call, result)
      default:
        result(FlutterMethodNotImplemented)
      }
    }
    
    GeneratedPluginRegistrant.register(with: self)
    return super.application(application, didFinishLaunchingWithOptions: launchOptions)
  }
  
  // List audio files from the device with low-resolution thumbnails
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
        
        // Get low-resolution thumbnail artwork
        var thumbnailData: String = ""
        if let artwork = song.artwork {
          // Request a small thumbnail size to save memory (e.g., 100x100)
          let thumbnailSize = CGSize(width: 100, height: 100)
          if let thumbnailImage = artwork.image(at: thumbnailSize) {
            if let imageData = thumbnailImage.jpegData(compressionQuality: 0.5) {
              thumbnailData = imageData.base64EncodedString()
            }
          }
        }
        
        // Create a dictionary for this song
        let audioFile: [String: Any] = [
          "id": id,
          "title": title,
          "artist": artist,
          "album": album,
          "path": path,
          "duration": Int(duration * 1000), // Convert to milliseconds to match Android
          "thumbnailData": thumbnailData
        ]
        
        audioFiles.append(audioFile)
      }
      
      // Return the list of audio files
      DispatchQueue.main.async {
        result(audioFiles)
      }
    }
  }
  
  // Fetch high-quality artwork for a specific song
  private func getHighQualityArtwork(_ call: FlutterMethodCall, _ result: @escaping FlutterResult) {
    guard let args = call.arguments as? [String: Any],
          let songId = args["id"] as? String else {
      result(FlutterError(code: "INVALID_ARGUMENT", message: "Song ID is required", details: nil))
      return
    }
    
    // Request authorization for media library access
    MPMediaLibrary.requestAuthorization { status in
      if status != .authorized {
        DispatchQueue.main.async {
          result(FlutterError(code: "UNAUTHORIZED", message: "Media library access not authorized", details: nil))
        }
        return
      }
      
      // Create a query for the specific song by persistent ID
      let predicate = MPMediaPropertyPredicate(value: songId, forProperty: MPMediaItemPropertyPersistentID)
      let query = MPMediaQuery()
      query.addFilterPredicate(predicate)
      
      // Get the song
      guard let songs = query.items, let song = songs.first else {
        DispatchQueue.main.async {
          result(FlutterError(code: "NOT_FOUND", message: "Song not found", details: nil))
        }
        return
      }
      
      // Get high-quality artwork
      var artworkData: String = ""
      if let artwork = song.artwork {
        // Request the full-size image
        if let fullImage = artwork.image(at: artwork.bounds.size) {
          if let imageData = fullImage.jpegData(compressionQuality: 0.8) {
            artworkData = imageData.base64EncodedString()
          }
        }
      }
      
      // Return the artwork data
      DispatchQueue.main.async {
        result(["artworkData": artworkData])
      }
    }
  }
}
