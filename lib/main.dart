import 'dart:io';
import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:vts_maps/maps_view.dart';

void main() {
  // String message = "Hello, this is a UDP message!";
  // RawDatagramSocket.bind(InternetAddress.anyIPv6, 0)
  //     .then((RawDatagramSocket socket) {
  //   print('UDP socket ready to send messages.');
  //   socket.send(message.codeUnits, InternetAddress('127.0.0.1'), 56906);
  //   print('Message sent: $message');
  //   socket.close();
  // });

  // RawDatagramSocket.bind(InternetAddress.anyIPv6, 56906)
  //     .then((RawDatagramSocket socket) {
  //   print('UDP socket ready to receive messages.');
  //   socket.listen((RawSocketEvent event) {
  //     if (event == RawSocketEvent.read) {
  //       Datagram? datagram = socket.receive();
  //       if (datagram != null) {
  //         String message = String.fromCharCodes(datagram.data);
  //         print('Received message: $message');
  //       }
  //     }
  //   });
  // });

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'VTS Maps',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      scrollBehavior: MaterialScrollBehavior().copyWith(
        dragDevices: {PointerDeviceKind.mouse, PointerDeviceKind.touch, PointerDeviceKind.stylus, PointerDeviceKind.unknown},
      ),
      home: HomePage(),
    );
  }
}
