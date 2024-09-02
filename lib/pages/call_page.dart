import 'package:flutter/material.dart';
import 'package:flutter_webrtc/flutter_webrtc.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:share/share.dart';
import '../signaling.dart'; // Ensure this path is correct

class CallPage extends StatefulWidget {
  const CallPage({super.key});

  @override
  _CallPageState createState() => _CallPageState();
}

class _CallPageState extends State<CallPage> {
  final Signaling _signaling = Signaling();
  RTCVideoRenderer _localRenderer = RTCVideoRenderer();
  RTCVideoRenderer _remoteRenderer = RTCVideoRenderer();

  bool _isCalling = false;
  String _statusMessage = '';
  String _callCode = '';
  bool _isMuted = false;
  bool _isCameraOff = false;
  bool _isRefreshing = false;

  @override
  void initState() {
    super.initState();
    _requestPermissions().then((_) {
      _initializeRenderers();
    });
  }

  Future<void> _requestPermissions() async {
    await [
      Permission.camera,
      Permission.microphone,
    ].request();
  }

  Future<void> _initializeRenderers() async {
    try {
      await _localRenderer.initialize();
      await _remoteRenderer.initialize();
      setState(() {});
    } catch (e) {
      setState(() {
        _statusMessage = 'Error initializing renderers: $e';
      });
    }
  }

  Future<void> _startCall() async {
    setState(() {
      _isCalling = true;
      _statusMessage = 'Starting call...';
      _callCode = _generateCallCode();
    });

    try {
      await _signaling.createConnection();

      _signaling.onLocalStream = (stream) {
        _localRenderer.srcObject = stream;
        setState(() {});
      };

      _signaling.onAddRemoteStream = (stream) {
        _remoteRenderer.srcObject = stream;
        setState(() {});
      };

      setState(() {
        _statusMessage = 'Call started. Code: $_callCode';
      });

      // Share the code
      await Share.share('Join my call using this code: $_callCode');
    } catch (e) {
      setState(() {
        _statusMessage = 'Error starting call: $e';
      });
    }
  }

  String _generateCallCode() {
    return DateTime.now().millisecondsSinceEpoch.toString();
  }

  Future<void> _toggleMute() async {
    if (_localRenderer.srcObject != null) {
      final audioTracks = _localRenderer.srcObject!.getAudioTracks();
      for (var track in audioTracks) {
        track.enabled = !_isMuted;
      }
      setState(() {
        _isMuted = !_isMuted;
      });
    }
  }

  Future<void> _toggleCamera() async {
    if (_localRenderer.srcObject != null) {
      final videoTracks = _localRenderer.srcObject!.getVideoTracks();
      for (var track in videoTracks) {
        track.enabled = !_isCameraOff;
      }
      setState(() {
        _isCameraOff = !_isCameraOff;
      });
    }
  }

  Future<void> _refreshVideo() async {
    setState(() {
      _isRefreshing = true;
      _statusMessage = 'Refreshing video...';
    });

    try {
      await _signaling.hangUp();
      _localRenderer.srcObject = null;
      _remoteRenderer.srcObject = null;

      await _signaling.createConnection();

      _signaling.onLocalStream = (stream) {
        _localRenderer.srcObject = stream;
      };

      _signaling.onAddRemoteStream = (stream) {
        _remoteRenderer.srcObject = stream;
      };

      setState(() {
        _statusMessage = 'Video refreshed.';
        _isRefreshing = false;
      });
    } catch (e) {
      setState(() {
        _statusMessage = 'Error refreshing video: $e';
        _isRefreshing = false;
      });
    }
  }

  Future<void> _endCall() async {
    await _signaling.hangUp();
    Navigator.pop(context);
  }

  @override
  void dispose() {
    _localRenderer.dispose();
    _remoteRenderer.dispose();
    _signaling.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Video Call'),
        backgroundColor: Colors.teal,
        elevation: 0,
        actions: [
          IconButton(
            icon: Icon(Icons.refresh, color: Colors.white),
            onPressed: _isRefreshing ? null : _refreshVideo,
          ),
        ],
      ),
      backgroundColor: Colors.black,
      body: Stack(
        children: [
          // Remote video (full screen)
          Positioned.fill(
            child: Container(
              margin: EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: Colors.black,
                borderRadius: BorderRadius.circular(10),
              ),
              child: RTCVideoView(
                _remoteRenderer,
                objectFit: RTCVideoViewObjectFit.RTCVideoViewObjectFitCover,
                mirror: false,
              ),
            ),
          ),
          // Local video (small overlay)
          Positioned(
            top: 20,
            right: 20,
            child: Container(
              width: 120,
              height: 160,
              decoration: BoxDecoration(
                color: Colors.black54,
                border: Border.all(color: Colors.teal, width: 2),
                borderRadius: BorderRadius.circular(10),
              ),
              child: RTCVideoView(
                _localRenderer,
                objectFit: RTCVideoViewObjectFit.RTCVideoViewObjectFitCover,
                mirror: true,
              ),
            ),
          ),
          // Status message
          Positioned(
            bottom: 100,
            left: 0,
            right: 0,
            child: Center(
              child: Text(
                _statusMessage,
                style: TextStyle(color: Colors.white, fontSize: 16),
              ),
            ),
          ),
          // Call controls
          Positioned(
            bottom: 20,
            left: 0,
            right: 0,
            child: Container(
              padding: EdgeInsets.symmetric(horizontal: 50),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  // Mute/Unmute
                  IconButton(
                    icon: Icon(
                      _isMuted ? Icons.mic_off : Icons.mic,
                      color: Colors.white,
                      size: 30,
                    ),
                    onPressed: _toggleMute,
                  ),
                  // End Call
                  IconButton(
                    icon: Icon(
                      Icons.call_end,
                      color: Colors.red,
                      size: 40,
                    ),
                    onPressed: _endCall,
                  ),
                  // Camera On/Off
                  IconButton(
                    icon: Icon(
                      _isCameraOff ? Icons.videocam_off : Icons.videocam,
                      color: Colors.white,
                      size: 30,
                    ),
                    onPressed: _toggleCamera,
                  ),
                ],
              ),
            ),
          ),
          // Start Call Button
          if (!_isCalling)
            Positioned(
              bottom: 180,
              left: 0,
              right: 0,
              child: Center(
                child: ElevatedButton.icon(
                  onPressed: _startCall,
                  icon: Icon(Icons.call, color: Colors.white),
                  label: Text('Start Call'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.teal,
                    padding:
                    EdgeInsets.symmetric(horizontal: 30, vertical: 15),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(30),
                    ),
                    textStyle: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}
