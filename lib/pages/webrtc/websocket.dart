import 'package:socket_io_client/socket_io_client.dart' as IO;


typedef void OnMessageCallback(String tag, dynamic msg);
typedef void OnCloseCallback(int code, String reason);
typedef void OnOpenCallback();

const CLIENT_ID_EVENT = 'client-id-event';
//const OFFER_EVENT = 'offer-event';
const OFFER_EVENT = 'send_message';
//const ANSWER_EVENT = 'answer-event';
const ANSWER_EVENT = 'receive_message';
const ICE_CANDIDATE_EVENT = 'ice-candidate-event';


/*
class SimpleWebSocket {
  String url;
 // IO.Socket socket;
  OnOpenCallback onOpen;
  OnMessageCallback onMessage;
  OnCloseCallback onClose;

  SimpleWebSocket(this.url);


  IO.Socket socket;

  String su = "";
  String query2 = "";

  /*
  SocketIoManager(
      {@required
      String? serverUrl,
        String nameSpace = '/',
        String ?query,
        Function? socketStatusCallback}) {
    su = serverUrl!;
    query2 = query!;
    /// _socketIO = SocketIOManager().createSocketIO(serverUrl, nameSpace,
    ///  query: query, socketStatusCallback: socketStatusCallback);
  }
  */


  /// Future<void> init() => _socketIO!.init();

  Future<void> init(context) async{

    socket = IO.io(url, <String, dynamic>{
      'transports': ['websocket'],
      'autoConnect': false,
      'query': query2
    });

    /*
    socket!.onReconnectAttempt((data) {
      print("socket reconnect attempt ----------------- 0 ---------- ${data.toString()}");

      print(data);

      OverlayService().addVideosOverlay(
        context,
        NoInternetConnection(),
      );

    });

     */

  }



  /// Future<void> connect() => _socketIO!.connect();

  Future<void> connect() async{

    print("called point 1");
    socket =IO.io("https://flutter-socket-io-chat.herokuapp.com/", <String, dynamic>{
      'transports': ['websocket'],
      'autoConnect': false,
      'query': "chatID=212"
    });

    socket.connect();

    socket.onConnect((data) {
      print("connection success ------");
      print(data.toString());
    });

    socket.onConnectError((data) {
      print("connection error ----");
      print(data.toString());
    });

  }

  ///Future<void> sendMessage(String channel, String message) =>
  /// _socketIO!.sendMessage(channel, message);

  /// Future<void> disconnect() => _socketIO!.disconnect();


  Future<void> disconnect() async{
    socket.disconnect();
  }


  /*
  connect() async {
    try {
      socket = IO.io(url, <String, dynamic>{
        'transports': ['websocket']
      });
      // Dart client
      socket.on('connect', (_) {
        print('connected');
        onOpen();
      });
      socket.on(CLIENT_ID_EVENT, (data) {
        // print('connected client $data');
        onMessage(CLIENT_ID_EVENT, data);
      });
      socket.on(OFFER_EVENT, (data) {
        onMessage(OFFER_EVENT, data);
      });
      socket.on(ANSWER_EVENT, (data) {
        onMessage(ANSWER_EVENT, data);
      });
      socket.on(ICE_CANDIDATE_EVENT, (data) {
        onMessage(ICE_CANDIDATE_EVENT, data);
      });
      socket.on('exception', (e) => print('Exception: $e'));
      socket.on('connect_error', (e) => print('Connect error: $e'));
      socket.on('disconnect', (e) {
        print('disconnect');
        onClose(0, e);
      });
      socket.on('fromServer', (_) => print(_));
    } catch (e) {
      this.onClose(500, e.toString());
    }
  }
  */

  send(event, data) {
    if (socket != null) {
      socket.emit(event, data);
      print('send: $event - $data');
    }
  }

  close() {
    if (socket != null) socket.close();
  }
}
*/


class SimpleWebSocket {
  String url;
  IO.Socket socket;
  OnOpenCallback onOpen;
  OnMessageCallback onMessage;
  OnCloseCallback onClose;

  SimpleWebSocket(this.url);

  connect() async {
    try {
      socket = IO.io("https://newzktor.herokuapp.com/", <String, dynamic>{
        'transports': ['websocket']
      });
      // Dart client
      socket.on('connect', (_) {
        print('connected');
        onOpen();
      });
      socket.on(CLIENT_ID_EVENT, (data) {
       // print('connected client $data');
        onMessage(CLIENT_ID_EVENT, data);
      });
      socket.on(OFFER_EVENT, (data) {
        print("p 167");
        onMessage(OFFER_EVENT, data);

        print(data.toString());
      });
      socket.on(ANSWER_EVENT, (data) {
        onMessage(ANSWER_EVENT, data);
      });
      socket.on(ICE_CANDIDATE_EVENT, (data) {
        onMessage(ICE_CANDIDATE_EVENT, data);
      });
      socket.on('exception', (e) => print('Exception: $e'));
      socket.on('connect_error', (e) => print('Connect error: $e'));
      socket.on('disconnect', (e) {
        print('disconnect');
        onClose(0, e);
      });
      socket.on('fromServer', (_) => print(_));
    } catch (e) {
      this.onClose(500, e.toString());
    }
  }

  send(event, data) {
    if (socket != null) {
      socket.emit(event, data);
      print('send: $event - $data');
    //  onMessage(OFFER_EVENT, data);

    }
  }

  close() {
    if (socket != null) socket.close();
  }
}

