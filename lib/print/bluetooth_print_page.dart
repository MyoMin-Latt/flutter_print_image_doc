import 'package:flutter/material.dart';

class BluetoothPrintPage extends StatefulWidget {
  const BluetoothPrintPage({super.key});

  @override
  State<BluetoothPrintPage> createState() => _BluetoothPrintPageState();
}

class _BluetoothPrintPageState extends State<BluetoothPrintPage> {
  GlobalKey globalKey = GlobalKey();
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Bluetooth'),
      ),
      body: printForm(),
    );
  }

  Widget printForm() => RepaintBoundary(
        key: globalKey,
        child: const Center(
          child: SizedBox(
            width: 200,
            child: SingleChildScrollView(
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
                    style: TextStyle(
                        height: 1.2, fontWeight: FontWeight.bold, fontSize: 14),
                  ),
                  Text(
                    "မြန်မာနိုင်ငံ (အင်္ဂလိပ်: Myanmar သို့မဟုတ် Burma)၊ တရားဝင်အားဖြင့် ပြည်ထောင်စု သမ္မတ မြန်မာနိုင်ငံတော် (Republic of the Union of Myanmar) သည် အရှေ့တောင်အာရှရှိ နိုင်ငံတစ်နိုင်ငံဖြစ်သည်။ အနောက်နှင့် အနောက်မြောက်ဘက်တွင် ဘင်္ဂလားဒေ့ရှ်နိုင်ငံ၊ အိန္ဒိယနိုင်ငံ၊ အရှေ့မြောက်ဘက်တွင် တရုတ်ပြည်သူ့သမ္မတနိုင်ငံ၊ ‌အရှေ့နှင့် အရှေ့တောင်ဘက်တွင် လာအိုနိုင်ငံ၊ ထိုင်းနိုင်ငံတို့နှင့် နယ်နမိတ်ချင်းထိစပ်ပြီး တောင်ဘက်နှင့် အနောက်တောင်ဘက်တွင် ကပ္ပလီပင်လယ်နှင့် ဘင်္ဂလားပင်လယ်အော်တို့ တည်ရှိသည်။ နိုင်ငံ၏မြို့တော်မှာ နေပြည်တော်မြို့ဖြစ်ပြီး အကြီးဆုံးမြို့မှာ ရန်ကုန်မြို့ဖြစ်သည်။",
                    textAlign: TextAlign.justify,
                    style: TextStyle(
                        height: 1.2, fontWeight: FontWeight.bold, fontSize: 14),
                  ),
                ],
              ),
            ),
          ),
        ),
      );
}
