import 'package:flutter/material.dart';

import 'print/bluetooth_print_page.dart';
import 'print/connect_bluetooth_printer.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

void main() {
  runApp(const ProviderScope(
    child: MaterialApp(
      home: MyWidget(),
    ),
  ));
}

class MyWidget extends StatelessWidget {
  const MyWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Bluetooth Print'),
      ),
      body: Center(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            OutlinedButton(
              onPressed: () {
                push(context, const ConnectBluetoothPrinter());
              },
              child: const Text("Bluetooth Print"),
            ),
            OutlinedButton(
              onPressed: () {
                push(context, const BluetoothPrintPage());
              },
              child: const Text("Print"),
            ),
          ],
        ),
      ),
    );
  }

  void push(BuildContext context, Widget page) {
    Navigator.of(context).push(MaterialPageRoute(
      builder: (context) => page,
    ));
  }
}
