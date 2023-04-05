import 'dart:io';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path_provider/path_provider.dart';
import 'package:http/http.dart' as http;

void main() {
  runApp( MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: MyHomePage(),
    );
  }
}

class MyHomePage extends StatefulWidget {
  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  Column _status = Column(
    children: [
      Text('Nhấn Send đi bro'),
    ],
  );

  Future<void> _sendImage() async {
    // Lấy ảnh từ assets
    final ByteData imageData = await rootBundle.load('assets/crack.jpg');
    final Uint8List bytes = imageData.buffer.asUint8List();
    // Lưu ảnh vào thư mục tạm
    final tempDir = await getTemporaryDirectory();
    final file = await File('${tempDir.path}/crack.jpg').writeAsBytes(bytes);
    // Đọc ảnh dưới dạng File
    final imageFile = await file.readAsBytes();

    // Gửi ảnh đến Flask API
    final response = await http.post(
      Uri.parse('http://localhost:5000/image'),
      body: imageFile,
    );
    // Nhận kết quả từ Flask API
    final jsonResponse = jsonDecode(response.body);
    final status = jsonResponse['status'];
    final phantram = jsonResponse['phantram'];
    final mask = jsonResponse['mask'];
    // Lưu ảnh mask vào thư mục assets

    final filePath = 'D:/Flutter/untitled/assets/mask.jpg';
    final maskFile = File(filePath);
    await maskFile.writeAsBytes(base64.decode(mask));

    // Xóa cache của thư mục assets
    ImageCache().clear();

// Tải lại nội dung của thư mục assets
    await precacheImage(AssetImage('assets/mask.jpg'), context);

    setState(() {
      _status = Column(
        children: [
          SizedBox(height: 16),
          Text('$status'),
          SizedBox(height: 16),
          Text('Mức độ nứt: $phantram%'),
          SizedBox(height: 16),
          Image.memory(base64.decode(mask)),
          // Image.asset('assets/mask.jpg'),
        ],
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Flutter Demo'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            ElevatedButton(
              onPressed: _sendImage,
              child: Text('Send Image'),
            ),
            SizedBox(height: 16),
            _status,
          ],
        ),
      ),
    );
  }
}
