import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_webrtc/flutter_webrtc.dart';

class Signaling {
  // Add this method to the Signaling class
  Future<void> joinConnection(String callCode) async {
    try {
      // Retrieve the offer from Firestore using the callCode
      final snapshot = await _firestore
          .collection('calls')
          .where('callCode', isEqualTo: callCode)
          .orderBy('timestamp')
          .limit(1)
          .get();

      if (snapshot.docs.isNotEmpty) {
        final document = snapshot.docs.first;
        final data = document.data();

        if (data['offer'] != null) {
          await handleOffer(data['offer']);
        }

        // Handle ICE candidates if needed
        _firestore.collection('calls').snapshots().listen((snapshot) {
          snapshot.docChanges.forEach((change) async {
            if (change.type == DocumentChangeType.added) {
              final data = change.doc.data();
              if (data?['candidate'] != null) {
                await handleCandidate(data?['candidate']);
              }
            }
          });
        });

      } else {
        print('No offer found for the provided call code.');
      }
    } catch (e) {
      print('Error in joinConnection: $e');
    }
  }
  Future<void> hangUp() async {
    if (_peerConnection != null) {
      await _peerConnection!.close();
      _peerConnection = null;
    }
  }
  RTCPeerConnection? _peerConnection;
  MediaStream? _localStream;
  MediaStream? _remoteStream;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Callback functions to update UI with streams
  Function(MediaStream)? onLocalStream;
  Function(MediaStream)? onAddRemoteStream;

  // Method to create a new peer connection
  Future<void> createConnection() async {
    try {
      print("Creating connection...");

      // ICE server configuration
      final configuration = <String, dynamic>{
        'iceServers': [
          {'urls': 'stun:stun.l.google.com:19302'},
        ]
      };

      _peerConnection = await createPeerConnection(configuration);

      // Getting the local media stream (video and audio)
      _localStream = await navigator.mediaDevices
          .getUserMedia({'video': true, 'audio': true});

      // Adding tracks from local stream to the peer connection
      _localStream!.getTracks().forEach((track) {
        _peerConnection!.addTrack(track, _localStream!);
      });
      onLocalStream?.call(_localStream!);

      // Handling the remote stream when received
      _peerConnection!.onTrack = (event) {
        if (event.streams.isNotEmpty) {
          _remoteStream = event.streams[0];
          onAddRemoteStream?.call(_remoteStream!);
          print("Remote stream added.");
        }
      };

      // Handling ICE candidates
      _peerConnection!.onIceCandidate = (candidate) {
        print("Sending ICE candidate...");
        _firestore.collection('calls').add({
          'candidate': candidate.toMap(),
          'timestamp': FieldValue.serverTimestamp(),
        });
      };

      // Creating an offer and sending it via Firestore
      RTCSessionDescription offer = await _peerConnection!.createOffer();
      await _peerConnection!.setLocalDescription(offer);

      _firestore.collection('calls').add({
        'offer': offer.toMap(),
        'timestamp': FieldValue.serverTimestamp(),
      });

      print("Offer sent.");
    } catch (e) {
      print('Error in createConnection: $e');
    }
  }

  // Method to handle an offer received from the remote peer
  Future<void> handleOffer(Map<String, dynamic> offer) async {
    try {
      final offerDescription = RTCSessionDescription(offer['sdp'], offer['type']);
      await _peerConnection!.setRemoteDescription(offerDescription);

      RTCSessionDescription answer = await _peerConnection!.createAnswer();
      await _peerConnection!.setLocalDescription(answer);

      _firestore.collection('calls').add({
        'answer': answer.toMap(),
        'timestamp': FieldValue.serverTimestamp(),
      });
    } catch (e) {
      print('Error in handleOffer: $e');
    }
  }

  // Method to handle an answer received from the remote peer
  Future<void> handleAnswer(Map<String, dynamic> answer) async {
    try {
      final answerDescription = RTCSessionDescription(answer['sdp'], answer['type']);
      await _peerConnection!.setRemoteDescription(answerDescription);
    } catch (e) {
      print('Error in handleAnswer: $e');
    }
  }

  // Method to handle ICE candidates received from the remote peer
  Future<void> handleCandidate(Map<String, dynamic> candidate) async {
    try {
      final iceCandidate = RTCIceCandidate(
        candidate['candidate'],
        candidate['sdpMid'],
        candidate['sdpMLineIndex'],
      );
      await _peerConnection!.addCandidate(iceCandidate);
    } catch (e) {
      print('Error in handleCandidate: $e');
    }
  }

  // Method to retrieve the offer from Firestore
  Future<void> getOfferFromFirestore() async {
    try {
      final snapshot = await _firestore.collection('calls').orderBy('timestamp').limit(1).get();
      if (snapshot.docs.isNotEmpty) {
        final document = snapshot.docs.first;
        final data = document.data();
        if (data['offer'] != null) {
          await handleOffer(data['offer']);
        }
      }
    } catch (e) {
      print('Error in getOfferFromFirestore: $e');
    }
  }

  // Disposing the peer connection
  void dispose() {
    _peerConnection?.close();
    _peerConnection = null;
  }
}
