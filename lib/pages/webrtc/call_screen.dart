import 'dart:core';

import 'package:flutter/material.dart';
import 'package:flutter_socket_io/flutter_socket_io.dart';
import 'package:flutter_socket_io/socket_io_manager.dart';
import 'package:flutter_webrtc/webrtc.dart';
import 'package:provider/provider.dart';

import 'signaling.dart';

class CallScreen extends StatelessWidget {
  final String ip;

  const CallScreen({Key key, @required this.ip}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => CallProvider(),
      child: CallBody(ip: ip),
    );
  }
}

class CallBody extends StatefulWidget {
  static String tag = 'call_sample';

  final String ip;

  CallBody({Key key, @required this.ip}) : super(key: key);

  @override
  _CallBodyState createState() => _CallBodyState(serverIP: ip);
}

class _CallBodyState extends State<CallBody> {
  Signaling _signaling;
  var _selfId;
  RTCVideoRenderer _localRenderer = RTCVideoRenderer();
  RTCVideoRenderer _remoteRenderer = RTCVideoRenderer();
  bool _inCalling = false;
  final String serverIP;
  final TextEditingController textEditingController = TextEditingController();

  _CallBodyState({Key key, @required this.serverIP});

  @override
  initState() {
    super.initState();
    initRenderers();
    _connect();

 /// initSocket();

  }
  SocketIO socketIO;

  initSocket() async{

    socketIO = SocketIOManager().createSocketIO(
      'https://zktorwebrtc2.herokuapp.com',
      '/',
    );

/*
    socketIO = SocketIOManager().createSocketIO("https://zktorwebrtc2.herokuapp.com", "/",
        query: "userId=21031", socketStatusCallback: (){});
    */
    //Call init before doing anything with socket
    socketIO.init();
    //Subscribe to an event to listen to
    socketIO.subscribe('receive_message', (jsonData) {
     print("message point 1");
    });
    //Connect to the socket
    socketIO.connect().then((value) {
      print("connection point 2");

    });

  }

  initRenderers() async {
    await _localRenderer.initialize();
    await _remoteRenderer.initialize();
  }

  @override
  deactivate() {
    super.deactivate();
    if (_signaling != null) _signaling.close();
    _localRenderer.dispose();
    _remoteRenderer.dispose();
  }

  showAnswer(peerId) async{

    showDialog(
        context: context,
        builder: (context){
          return Container(
            height: 250,
            width: 200,
            color: Colors.white,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text("You got a video call invitation"),
                ElevatedButton(
                  onPressed: (){

                    print("click 1");
                   print(_signaling.toString());
                   // print(peerId);
                   print(_selfId);
                   print(peerId);
                    if (_signaling != null && peerId != "67890") {

                      _signaling.invite(peerId, 'video', false);
                      Navigator.pop(context);
                    }

                  },
                  child: Text("Accept"),
                ),
              ],
            ),
          );
        }
    );

  }

  void _connect() async {
    if (_signaling == null) {
      _signaling = Signaling(serverIP)..connect(context,_signaling,_selfId);

      _signaling.onStateChange = (SignalingState state) {
        switch (state) {
          case SignalingState.CallStateNew:
            this.setState(() {
              _inCalling = true;
            });
            break;
          case SignalingState.CallStateBye:
            this.setState(() {
              _localRenderer.srcObject = null;
              _remoteRenderer.srcObject = null;
              _inCalling = false;
            });
            break;
          case SignalingState.CallStateInvite:
          case SignalingState.CallStateConnected:
          case SignalingState.CallStateRinging:
          case SignalingState.ConnectionClosed:
          case SignalingState.ConnectionError:
          case SignalingState.ConnectionOpen:
            break;
        }
      };

      _signaling.onEventUpdate = ((event) {
        final clientId = event['clientId'];
        context.read<CallProvider>().updateClientIp(clientId);
      });

      _signaling.onPeersUpdate = ((event) {
        this.setState(() {
          _selfId = event['self'];
        });
      });

      _signaling.onLocalStream = ((stream) {
        _localRenderer.srcObject = stream;
      });

      _signaling.onAddRemoteStream = ((stream) {
        _remoteRenderer.srcObject = stream;
      });

      _signaling.onRemoveRemoteStream = ((stream) {
        _remoteRenderer.srcObject = null;
      });

      _signaling.gettingMessage = ((tag,message){
        print("test 1");
        showAnswer(message["peerId"]);
      });

    }
  }

  _invitePeer(context, peerId, useScreen) async {
    if (_signaling != null && peerId != _selfId) {
      _signaling.invite(peerId, 'video', useScreen);
    }
  }

  _hangUp() {
    if (_signaling != null) {
      _signaling.bye();
    }
  }

  _switchCamera() {
    _signaling.switchCamera();
  }

  _muteMic() {}

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Consumer<CallProvider>(
          builder: (context, provider, child) {
            final clientId = provider.clientId;
            return clientId.isNotEmpty
                ? Text('$clientId')
                : Text('P2P Call Sample');
          },
        ),
        actions: <Widget>[
          IconButton(
            icon: const Icon(Icons.settings),
            onPressed: null,
            tooltip: 'setup',
          ),
        ],
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
      floatingActionButton: _inCalling
          ? SizedBox(
              width: 200.0,
              child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: <Widget>[
                    FloatingActionButton(
                      child: const Icon(Icons.switch_camera),
                      onPressed: _switchCamera,
                    ),
                    FloatingActionButton(
                      onPressed: _hangUp,
                      tooltip: 'Hangup',
                      child: Icon(Icons.call_end),
                      backgroundColor: Colors.pink,
                    ),
                    FloatingActionButton(
                      child: const Icon(Icons.mic_off),
                      onPressed: _muteMic,
                    )
                  ]))
          : null,
      body: _inCalling
          ? OrientationBuilder(builder: (context, orientation) {
              return Container(
                child: Stack(children: <Widget>[
                  Positioned(
                      left: 0.0,
                      right: 0.0,
                      top: 0.0,
                      bottom: 0.0,
                      child: Container(
                        margin: EdgeInsets.fromLTRB(0.0, 0.0, 0.0, 0.0),
                        width: MediaQuery.of(context).size.width,
                        height: MediaQuery.of(context).size.height,
                        child: RTCVideoView(_remoteRenderer),
                        decoration: BoxDecoration(color: Colors.black54),
                      )),
                  Positioned(
                    left: 20.0,
                    top: 20.0,
                    child: Container(
                      width: orientation == Orientation.portrait ? 90.0 : 120.0,
                      height:
                          orientation == Orientation.portrait ? 120.0 : 90.0,
                      child: RTCVideoView(_localRenderer),
                      decoration: BoxDecoration(color: Colors.black54),
                    ),
                  ),
                ]),
              );
            })
          : Container(
              color: Colors.yellow,
              child: Column(
                children: <Widget>[
                  TextField(
                    controller: textEditingController,
                  ),

                  Align(
                    alignment: Alignment.topRight,
                    child: InkWell(
                      onTap: (){

                      },
                      child: Container(
                        margin: EdgeInsets.fromLTRB(0, 100, 10, 0),
                        color: Colors.white,
                        child: Text("Answer"),
                      ),
                    ),
                  ),
                  Align(
                    alignment: Alignment.topRight,
                    child: InkWell(
                      onTap: (){



                      },
                      child: Container(
                        margin: EdgeInsets.fromLTRB(0, 35, 10, 0),
                        color: Colors.white,
                        child: Text("Offer"),
                      ),
                    ),
                  ),

                  FlatButton(
                    child: Text('Call'),
                    color: Colors.green,
                    onPressed: () {
                      _invitePeer(context, textEditingController.text, false);
                    },
                  )
                ],
              ),
            ),
    );
  }
}

class CallProvider with ChangeNotifier {
  String clientId = "12345";

  void updateClientIp(String newClientId) {
    //clientId = newClientId;
    clientId = "12345";
    notifyListeners();
  }
}
