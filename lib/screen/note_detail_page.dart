import 'package:flutter/material.dart';
import 'dart:io';
import 'package:audioplayers/audioplayers.dart';

class NoteDetailPage extends StatefulWidget {
  final String subject;
  final Map<String, String> note;

  const NoteDetailPage({Key? key, required this.subject, required this.note})
    : super(key: key);

  @override
  State<NoteDetailPage> createState() => _NoteDetailPageState();
}

class _NoteDetailPageState extends State<NoteDetailPage> {
  AudioPlayer? _audioPlayer;
  bool _isPlaying = false;
  Duration _currentPosition = Duration.zero;
  Duration _totalDuration = Duration.zero;

  @override
  void initState() {
    super.initState();
    if (widget.note["type"] == "voice") {
      _audioPlayer = AudioPlayer();
      _initializeAudioPlayer();
    }
  }

  @override
  void dispose() {
    _audioPlayer?.dispose();
    super.dispose();
  }

  void _initializeAudioPlayer() {
    if (_audioPlayer != null && widget.note["filePath"] != null) {
      _audioPlayer!.onPlayerStateChanged.listen((state) {
        setState(() {
          _isPlaying = state == PlayerState.playing;
        });
      });

      _audioPlayer!.onPositionChanged.listen((position) {
        setState(() {
          _currentPosition = position;
        });
      });

      _audioPlayer!.onDurationChanged.listen((duration) {
        setState(() {
          _totalDuration = duration;
        });
      });
    }
  }

  Future<void> _playPause() async {
    if (_audioPlayer != null && widget.note["filePath"] != null) {
      if (_isPlaying) {
        await _audioPlayer!.pause();
      } else {
        await _audioPlayer!.play(DeviceFileSource(widget.note["filePath"]!));
      }
    }
  }

  String _formatDate(String dateString) {
    try {
      final date = DateTime.parse(dateString);
      return '${date.day}/${date.month}/${date.year} at ${date.hour}:${date.minute.toString().padLeft(2, '0')}';
    } catch (e) {
      return 'Unknown date';
    }
  }

  @override
  Widget build(BuildContext context) {
    // Parse color from string (fallback to blue if not available)
    Color noteColor = Colors.blue;
    try {
      if (widget.note["color"] != null) {
        noteColor = Color(int.parse(widget.note["color"]!));
      }
    } catch (e) {
      noteColor = Colors.blue;
    }

    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        title: Text(
          widget.note["title"] ?? widget.subject,
          style: const TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: Colors.black87,
          ),
        ),
        elevation: 0,
        backgroundColor: Colors.grey[50],
        foregroundColor: Colors.black,
        actions: [
          IconButton(
            onPressed: () {
              // TODO: Add edit functionality
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Edit functionality coming soon!'),
                  backgroundColor: Colors.orange,
                ),
              );
            },
            icon: Icon(Icons.edit, color: noteColor),
          ),
          IconButton(
            onPressed: () {
              // TODO: Add delete functionality
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Delete functionality coming soon!'),
                  backgroundColor: Colors.red,
                ),
              );
            },
            icon: const Icon(Icons.delete, color: Colors.red),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Note Header
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [noteColor, noteColor.withOpacity(0.8)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: noteColor.withOpacity(0.3),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.2),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: const Icon(
                          Icons.note_alt,
                          color: Colors.white,
                          size: 28,
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              widget.note["title"] ?? widget.subject,
                              style: const TextStyle(
                                fontSize: 22,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              widget.subject,
                              style: const TextStyle(
                                fontSize: 16,
                                color: Colors.white70,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  if (widget.note["date"] != null) ...[
                    const SizedBox(height: 16),
                    Row(
                      children: [
                        const Icon(
                          Icons.access_time,
                          color: Colors.white70,
                          size: 16,
                        ),
                        const SizedBox(width: 8),
                        Text(
                          _formatDate(widget.note["date"]!),
                          style: const TextStyle(
                            fontSize: 14,
                            color: Colors.white70,
                          ),
                        ),
                      ],
                    ),
                  ],
                ],
              ),
            ),

            const SizedBox(height: 24),

            // Note Content
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.05),
                    blurRadius: 10,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(Icons.description, color: noteColor, size: 20),
                      const SizedBox(width: 8),
                      Text(
                        'Content',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: noteColor,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  Text(
                    widget.note["note"]!,
                    style: const TextStyle(
                      fontSize: 16,
                      color: Colors.black87,
                      height: 1.6,
                    ),
                  ),
                  const SizedBox(height: 16),

                  // Media content based on note type
                  _buildMediaContent(noteColor),
                ],
              ),
            ),

            const SizedBox(height: 24),

            // Note Info
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: noteColor.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: noteColor.withOpacity(0.3), width: 1),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(Icons.info_outline, color: noteColor, size: 20),
                      const SizedBox(width: 8),
                      Text(
                        'Note Information',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: noteColor,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  _buildInfoRow(
                    'Type',
                    widget.note["type"] ?? 'Text',
                    noteColor,
                  ),
                  _buildInfoRow('Subject', widget.subject, noteColor),
                  if (widget.note["title"] != null)
                    _buildInfoRow('Title', widget.note["title"]!, noteColor),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMediaContent(Color noteColor) {
    final String? noteType = widget.note["type"];
    final String? filePath = widget.note["filePath"];

    if (filePath == null || filePath.isEmpty) {
      return const SizedBox.shrink();
    }

    switch (noteType) {
      case "drawing":
        return _buildImageDisplay(filePath, "Drawing", noteColor);

      case "file":
        // Check if it's an image file
        if (_isImageFile(filePath)) {
          return _buildImageDisplay(filePath, "Attached Image", noteColor);
        } else {
          return _buildFileDisplay(filePath, noteColor);
        }

      case "voice":
        return _buildAudioPlayer(filePath, noteColor);

      default:
        return const SizedBox.shrink();
    }
  }

  Widget _buildImageDisplay(String filePath, String title, Color noteColor) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(Icons.image, color: noteColor, size: 20),
            const SizedBox(width: 8),
            Text(
              title,
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: noteColor,
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        Container(
          width: double.infinity,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: noteColor.withOpacity(0.3)),
          ),
          clipBehavior: Clip.antiAlias,
          child: Image.file(
            File(filePath),
            fit: BoxFit.cover,
            errorBuilder: (context, error, stackTrace) {
              return Container(
                height: 100,
                color: Colors.grey[200],
                child: const Center(child: Text('Image not found')),
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildFileDisplay(String filePath, Color noteColor) {
    final fileName = filePath.split('/').last;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(Icons.attach_file, color: noteColor, size: 20),
            const SizedBox(width: 8),
            Text(
              'Attached File',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: noteColor,
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: noteColor.withOpacity(0.1),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: noteColor.withOpacity(0.3)),
          ),
          child: Row(
            children: [
              Icon(Icons.description, color: noteColor),
              const SizedBox(width: 12),
              Expanded(
                child: Text(fileName, style: const TextStyle(fontSize: 14)),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildAudioPlayer(String filePath, Color noteColor) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(Icons.mic, color: noteColor, size: 20),
            const SizedBox(width: 8),
            Text(
              'Voice Note',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: noteColor,
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: noteColor.withOpacity(0.1),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: noteColor.withOpacity(0.3)),
          ),
          child: Row(
            children: [
              IconButton(
                onPressed: _playPause,
                icon: Icon(
                  _isPlaying ? Icons.pause : Icons.play_arrow,
                  color: noteColor,
                ),
              ),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Voice Recording',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                        color: noteColor,
                      ),
                    ),
                    const SizedBox(height: 4),
                    LinearProgressIndicator(
                      value: _totalDuration.inSeconds > 0
                          ? _currentPosition.inSeconds /
                                _totalDuration.inSeconds
                          : 0.0,
                      backgroundColor: Colors.grey[300],
                      valueColor: AlwaysStoppedAnimation<Color>(noteColor),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '${_formatDuration(_currentPosition)} / ${_formatDuration(_totalDuration)}',
                      style: const TextStyle(fontSize: 12, color: Colors.grey),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  bool _isImageFile(String filePath) {
    final extension = filePath.toLowerCase().split('.').last;
    return ['jpg', 'jpeg', 'png', 'gif', 'webp', 'bmp'].contains(extension);
  }

  String _formatDuration(Duration duration) {
    String twoDigits(int n) => n.toString().padLeft(2, '0');
    final minutes = twoDigits(duration.inMinutes.remainder(60));
    final seconds = twoDigits(duration.inSeconds.remainder(60));
    return '$minutes:$seconds';
  }

  Widget _buildInfoRow(String label, String value, Color color) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 80,
            child: Text(
              '$label:',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w500,
                color: color,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(fontSize: 14, color: Colors.black87),
            ),
          ),
        ],
      ),
    );
  }
}
