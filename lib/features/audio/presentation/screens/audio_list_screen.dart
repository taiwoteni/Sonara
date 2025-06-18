import 'package:flutter/material.dart';
import 'package:sonara/core/di/service_locator.dart';
import 'package:sonara/features/audio/domain/entities/audio_file.dart';
import 'package:sonara/features/audio/domain/usecases/list_audio_files_usecase.dart';

/// Screen that displays a list of audio files from the device
class AudioListScreen extends StatefulWidget {
  const AudioListScreen({Key? key}) : super(key: key);

  @override
  State<AudioListScreen> createState() => _AudioListScreenState();
}

class _AudioListScreenState extends State<AudioListScreen> {
  final _listAudioFilesUseCase = getIt<ListAudioFilesUseCase>();
  List<AudioFile> _audioFiles = [];
  bool _isLoading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _loadAudioFiles();
  }

  /// Load audio files from the device
  Future<void> _loadAudioFiles() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      final audioFiles = await _listAudioFilesUseCase.execute();
      setState(() {
        _audioFiles = audioFiles;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _error = e.toString();
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Audio Files'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _loadAudioFiles,
          ),
        ],
      ),
      body: _buildBody(),
    );
  }

  Widget _buildBody() {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (_error != null) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              'Error loading audio files',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 8),
            Text(_error!),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: _loadAudioFiles,
              child: const Text('Retry'),
            ),
          ],
        ),
      );
    }

    if (_audioFiles.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              'No audio files found',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 16),
            const Text(
              'Make sure you have granted permission to access your audio files.',
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      itemCount: _audioFiles.length,
      itemBuilder: (context, index) {
        final audio = _audioFiles[index];
        return ListTile(
          title: Text(
            audio.title,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
          subtitle: Text(
            '${audio.artist} • ${audio.album}',
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
          leading: const CircleAvatar(child: Icon(Icons.music_note)),
          onTap: () {
            // Handle audio selection
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text('Selected: ${audio.title}'),
                duration: const Duration(seconds: 1),
              ),
            );
          },
        );
      },
    );
  }
}
