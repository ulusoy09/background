import 'dart:isolate';
import 'package:flutter/material.dart';
void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: MyHomePage(),
    );
  }
}

class MyHomePage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Background Worker'),
      ),
      body: Center(
        child: ElevatedButton(
          onPressed: () {
            // Butona tıklandığında arka plan işçisini başlat
            startBackgroundWorker();
          },
          child: Text('Başlat'),
        ),
      ),
    );
  }

  void startBackgroundWorker() async {
    // Isolate oluşturulması ve çalıştırılması
    final ReceivePort receivePort = ReceivePort();
    final isolate = await Isolate.spawn(backgroundTask, receivePort.sendPort);

    // Isolatenin mesajlarını dinlemek için bir stream oluşturulması
    final Stream subscription = receivePort.asBroadcastStream();

    // Arka planda yapılan işlemleri dinlemek ve sonuçları almak için stream'i dinleyelim
    subscription.listen((message) {
      if (message is int) {
        print('Toplam: $message');
      } else if (message == 'completed') {
        print('Arka plan işçisi tamamlandı.');
        // Isolate'ı sonlandıralım
        isolate.kill(priority: Isolate.immediate);
      }
    });
  }

  void backgroundTask(SendPort sendPort) {
    // Arka planda çalışacak kodları burada yürütelim
    int sum = 0;
    for (int i = 1; i <= 100000; i++) {
      sum += i;
    }

    // Sonuçları ana iş parçacığına gönderelim
    sendPort.send(sum);

    // İşlem tamamlandı mesajı gönderelim
    sendPort.send('completed');
  }
}
