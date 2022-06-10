import 'dart:convert';
import 'dart:async';
import 'dart:io';

//var rs={"token":{"accountSid":"ACe93194010fc37ca85f852c288123f6db","dateCreated":"2022-06-07T11:05:12.000Z","dateUpdated":"2022-06-07T11:05:12.000Z","iceServers":[{"url":"stun:global.stun.twilio.com:3478?transport=udp","urls":"stun:global.stun.twilio.com:3478?transport=udp"},{"url":"turn:global.turn.twilio.com:3478?transport=udp","username":"bf1c8e7aef57bb3212aceaae45a75b16791067209e2104ca2f8677702cad1b6c","urls":"turn:global.turn.twilio.com:3478?transport=udp","credential":"FhGQQk5QylFjVrLZjlU6xo+xIzskHeKjB5nwUn2XwMA="},{"url":"turn:global.turn.twilio.com:3478?transport=tcp","username":"bf1c8e7aef57bb3212aceaae45a75b16791067209e2104ca2f8677702cad1b6c","urls":"turn:global.turn.twilio.com:3478?transport=tcp","credential":"FhGQQk5QylFjVrLZjlU6xo+xIzskHeKjB5nwUn2XwMA="},{"url":"turn:global.turn.twilio.com:443?transport=tcp","username":"bf1c8e7aef57bb3212aceaae45a75b16791067209e2104ca2f8677702cad1b6c","urls":"turn:global.turn.twilio.com:443?transport=tcp","credential":"FhGQQk5QylFjVrLZjlU6xo+xIzskHeKjB5nwUn2XwMA="}],"password":"FhGQQk5QylFjVrLZjlU6xo+xIzskHeKjB5nwUn2XwMA=","ttl":"86400","username":"bf1c8e7aef57bb3212aceaae45a75b16791067209e2104ca2f8677702cad1b6c"}};

Future<Map> getTurnCredential(String host, int port) async {
 /* Map<String, dynamic> _iceServers =  {
    "username": "zktor_user_0023e73823d136d3e29a",
    "password": "zktor_pass_XgxhwUJL2Rhw",
    "ttl": 86400,
    "uris": ["turn:88.119.176.58:3478?transport=udp"]
  };*/
    HttpClient client = HttpClient(context: SecurityContext());
    client.badCertificateCallback =
        (X509Certificate cert, String host, int port) {
      print('getTurnCredential: Allow self-signed certificate => $host:$port. ');
      return true;
    };
    var url = 'https://zktor.com:5002/api/get-turn-credentials';
    var request = await client.getUrl(Uri.parse(url));
    var response = await request.close();
    print('getTurnCredential:response => $response');
    var responseBody = await response.transform(Utf8Decoder()).join();
    print('getTurnCredential:response => $responseBody.');
    Map data = JsonDecoder().convert(responseBody);
    return data;
  }
