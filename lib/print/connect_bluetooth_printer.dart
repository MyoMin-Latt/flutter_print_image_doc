import 'dart:async';
import 'dart:developer';
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_pos_printer_platform/esc_pos_utils_platform/src/capability_profile.dart'; // CapabilityProfile
import 'package:flutter_pos_printer_platform/esc_pos_utils_platform/src/enums.dart'; // PaperSize
import 'package:flutter_pos_printer_platform/esc_pos_utils_platform/src/generator.dart'; // Generator
import 'package:flutter_pos_printer_platform/esc_pos_utils_platform/src/pos_styles.dart';
import 'package:flutter_pos_printer_platform/flutter_pos_printer_platform.dart';
import 'dart:ui' as ui;
import 'package:image/image.dart' as img;

final selectBluetoothProvider = StateProvider<BluetoothPrinter?>((ref) {
  return null;
});

final btStatusProvider = StateProvider<BTStatus>((ref) {
  return BTStatus.none;
});

class ConnectBluetoothPrinter extends ConsumerStatefulWidget {
  const ConnectBluetoothPrinter({super.key});

  @override
  ConsumerState<ConsumerStatefulWidget> createState() =>
      _ConnectBluetoothPrinterState();
}

class _ConnectBluetoothPrinterState
    extends ConsumerState<ConnectBluetoothPrinter> {
  GlobalKey globalKey = GlobalKey();
  var printerManager = PrinterManager.instance;
  List<BluetoothPrinter> devices = [];
  StreamSubscription<PrinterDevice>? subscription;
  StreamSubscription<BTStatus>? subscriptionBtStatus;
  @override
  void initState() {
    super.initState();
    _scan();
    // subscription to listen change status of bluetooth connection
    subscriptionBtStatus =
        PrinterManager.instance.stateBluetooth.listen((status) {
      log(' ----------------- status bt $status ------------------ ');
      Future.microtask(
          () => ref.read(btStatusProvider.notifier).update((state) => status));
    });
  }

  void _scan() {
    devices.clear();
    subscription = printerManager
        .discovery(type: PrinterType.bluetooth, isBle: false)
        .listen((device) {
      devices.add(BluetoothPrinter(
        deviceName: device.name,
        address: device.address,
        isBle: false,
        vendorId: device.vendorId,
        productId: device.productId,
        typePrinter: PrinterType.bluetooth,
      ));
      setState(() {});
    });
  }

  Future _printReceiveTest() async {
    List<int> bytes = [];

    final profile = await CapabilityProfile.load(name: 'XP-N160I');
    final generator = Generator(PaperSize.mm58, profile);
    bytes += generator.setGlobalCodeTable('CP1250');
    bytes += generator.text('Test Print',
        styles: const PosStyles(align: PosAlign.left));
    // Widget to Image
    final RenderRepaintBoundary boundary =
        // ignore: use_build_context_synchronously
        globalKey.currentContext!.findRenderObject()! as RenderRepaintBoundary;
    final ui.Image image = await boundary.toImage(pixelRatio: 2);
    final ByteData? byteData =
        await image.toByteData(format: ui.ImageByteFormat.png);
    if (byteData!.lengthInBytes > 0) {
      final Uint8List imageBytes = byteData.buffer.asUint8List();
      // decode the bytes into an image
      final decodedImage = img.decodeImage(imageBytes)!;
      var grayscaleImage = img.grayscale(decodedImage);

      bytes += generator.feed(1);
      bytes += generator.imageRaster(grayscaleImage, align: PosAlign.center);
      bytes += generator.feed(1);
    }
    // end myanmar font test

    _printEscPos(bytes, generator);
  }

  /// print ticket
  Future<void> _printEscPos(List<int> bytes, Generator generator) async {
    if (ref.watch(selectBluetoothProvider) == null) return;
    var bluetoothPrinter = ref.watch(selectBluetoothProvider)!;
    debugPrint('bluetoothPrinter $bluetoothPrinter');
    bytes += generator.cut();
    await printerManager.connect(
        type: bluetoothPrinter.typePrinter,
        model: BluetoothPrinterInput(
            name: bluetoothPrinter.deviceName,
            address: bluetoothPrinter.address!,
            isBle: bluetoothPrinter.isBle ?? false,
            autoConnect: false));

    printerManager.send(type: bluetoothPrinter.typePrinter, bytes: bytes);
  }

  connectDevice() async {
    if (ref.watch(selectBluetoothProvider) == null) return;
    var bluetoothPrinter = ref.watch(selectBluetoothProvider)!;
    debugPrint(bluetoothPrinter.toString());
    await printerManager.connect(
        type: bluetoothPrinter.typePrinter,
        model: BluetoothPrinterInput(
            name: bluetoothPrinter.deviceName,
            address: bluetoothPrinter.address!,
            isBle: bluetoothPrinter.isBle ?? false,
            autoConnect: false));
  }

  disConnectDevice() async {
    await printerManager.disconnect(type: PrinterType.bluetooth);
  }

  @override
  Widget build(BuildContext context) {
    ref.listen(
      btStatusProvider,
      (previous, next) => debugPrint("btStatusProvider : $next"),
    );
    return Scaffold(
      appBar: AppBar(),
      body: SingleChildScrollView(
        child: Column(
          children: [
            Row(
              children: [
                Expanded(
                  flex: 2,
                  child: DropdownButtonFormField<BluetoothPrinter?>(
                    value: null,
                    style: TextStyle(
                      color: ref.watch(btStatusProvider) == BTStatus.connected
                          ? Colors.blueAccent
                          : Colors.black87,
                    ),
                    hint: const Text('Select printer'),
                    decoration: const InputDecoration(
                      prefixIcon: Icon(
                        Icons.print,
                        size: 24,
                      ),
                      focusedBorder: InputBorder.none,
                      enabledBorder: InputBorder.none,
                    ),
                    items: List.generate(
                      devices.length,
                      (index) => DropdownMenuItem(
                        value: devices[index],
                        child: Text(devices[index].deviceName ?? ''),
                      ),
                    ),
                    onTap: () async {
                      disConnectDevice();
                      ref
                          .read(btStatusProvider.notifier)
                          .update((state) => BTStatus.none);
                    },
                    onChanged: (value) async {
                      debugPrint("status : ${value.toString()}");
                      if (value != null) {
                        ref
                            .read(selectBluetoothProvider.notifier)
                            .update((state) => value);
                        connectDevice();
                      }
                    },
                  ),
                ),
                Expanded(
                    child: Row(
                  children: [
                    IconButton(
                        onPressed: () async {
                          disConnectDevice();
                          ref
                              .read(btStatusProvider.notifier)
                              .update((state) => BTStatus.none);
                        },
                        icon: const Icon(
                          Icons.stop,
                          color: Colors.red,
                          size: 30,
                        )),
                    OutlinedButton(
                        onPressed: () {
                          debugPrint(
                              ref.watch(selectBluetoothProvider).toString());
                          _printReceiveTest();
                        },
                        child: const Text('Print')),
                  ],
                ))
              ],
            ),
            printForm(),
          ],
        ),
      ),
    );
  }

  Widget printForm() => RepaintBoundary(
        key: globalKey,
        child: Container(
          color: Colors.white,
          width: 180,
          child: const SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Center(
                  child: Text(
                    'မြန်မာနိုင်ငံ',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                ),
                Text(
                  "မြန်မာနိုင်ငံ (အင်္ဂလိပ်: Myanmar သို့မဟုတ် Burma)၊ တရားဝင်အားဖြင့် ပြည်ထောင်စု သမ္မတ မြန်မာနိုင်ငံတော် (Republic of the Union of Myanmar) သည် အရှေ့တောင်အာရှရှိ နိုင်ငံတစ်နိုင်ငံဖြစ်သည်။ အနောက်နှင့် အနောက်မြောက်ဘက်တွင် ဘင်္ဂလားဒေ့ရှ်နိုင်ငံ၊ အိန္ဒိယနိုင်ငံ၊ အရှေ့မြောက်ဘက်တွင် တရုတ်ပြည်သူ့သမ္မတနိုင်ငံ၊ ‌အရှေ့နှင့် အရှေ့တောင်ဘက်တွင် လာအိုနိုင်ငံ၊ ထိုင်းနိုင်ငံတို့နှင့် နယ်နမိတ်ချင်းထိစပ်ပြီး တောင်ဘက်နှင့် အနောက်တောင်ဘက်တွင် ကပ္ပလီပင်လယ်နှင့် ဘင်္ဂလားပင်လယ်အော်တို့ တည်ရှိသည်။ နိုင်ငံ၏မြို့တော်မှာ နေပြည်တော်မြို့ဖြစ်ပြီး အကြီးဆုံးမြို့မှာ ရန်ကုန်မြို့ဖြစ်သည်။",
                  textAlign: TextAlign.justify,
                  style: TextStyle(height: 1.2, fontSize: 14),
                ),
                Text(
                  "မြန်မာနိုင်ငံ (အင်္ဂလိပ်: Myanmar သို့မဟုတ် Burma)၊ တရားဝင်အားဖြင့် ပြည်ထောင်စု သမ္မတ မြန်မာနိုင်ငံတော် (Republic of the Union of Myanmar) သည် အရှေ့တောင်အာရှရှိ နိုင်ငံတစ်နိုင်ငံဖြစ်သည်။ အနောက်နှင့် အနောက်မြောက်ဘက်တွင် ဘင်္ဂလားဒေ့ရှ်နိုင်ငံ၊ အိန္ဒိယနိုင်ငံ၊ အရှေ့မြောက်ဘက်တွင် တရုတ်ပြည်သူ့သမ္မတနိုင်ငံ၊ ‌အရှေ့နှင့် အရှေ့တောင်ဘက်တွင် လာအိုနိုင်ငံ၊ ထိုင်းနိုင်ငံတို့နှင့် နယ်နမိတ်ချင်းထိစပ်ပြီး တောင်ဘက်နှင့် အနောက်တောင်ဘက်တွင် ကပ္ပလီပင်လယ်နှင့် ဘင်္ဂလားပင်လယ်အော်တို့ တည်ရှိသည်။ နိုင်ငံ၏မြို့တော်မှာ နေပြည်တော်မြို့ဖြစ်ပြီး အကြီးဆုံးမြို့မှာ ရန်ကုန်မြို့ဖြစ်သည်။ XXXXXXXXXXXXXXXX",
                  textAlign: TextAlign.justify,
                  style: TextStyle(height: 1.2, fontSize: 14),
                ),
              ],
            ),
          ),
        ),
      );
}

class BluetoothPrinter {
  int? id;
  String? deviceName;
  String? address;
  String? port;
  String? vendorId;
  String? productId;
  bool? isBle;

  PrinterType typePrinter;
  bool? state;

  BluetoothPrinter(
      {this.deviceName,
      this.address,
      this.port,
      this.state,
      this.vendorId,
      this.productId,
      this.typePrinter = PrinterType.bluetooth,
      this.isBle = false});

  @override
  String toString() {
    return 'BluetoothPrinter(id: $id, deviceName: $deviceName, address: $address, port: $port, vendorId: $vendorId, productId: $productId, isBle: $isBle, typePrinter: $typePrinter, state: $state)';
  }
}
