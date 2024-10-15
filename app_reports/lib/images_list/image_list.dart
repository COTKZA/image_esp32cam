import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:url_launcher/url_launcher.dart';

// ฟังก์ชันเพื่อดึงข้อมูลจาก API
Future<List<ImageData>> fetchImages() async {
  final response = await http
      .get(Uri.parse('http://127.0.0.1/image_esp32cam/api/api_esp32.php'));

  if (response.statusCode == 200) {
    print('Response body: ${response.body}'); // Debug: Print response
    List jsonResponse = json.decode(response.body);
    return jsonResponse.map((data) => ImageData.fromJson(data)).toList();
  } else {
    throw Exception('Failed to load images');
  }
}

// โมเดลข้อมูล
class ImageData {
  final String filename;
  final String filepath;
  final String text; // เพิ่ม field สำหรับ text
  final String date;
  final String time;
  final int id;

  ImageData({
    required this.filename,
    required this.filepath,
    required this.text, // เพิ่ม parameter ใน constructor
    required this.date,
    required this.time,
    required this.id,
  });

  factory ImageData.fromJson(Map<String, dynamic> json) {
    return ImageData(
      filename: json['filename'],
      filepath: json['filepath'],
      text: json['text'], // รับค่า text จาก JSON
      date: json['date'],
      time: json['time'],
      id: int.parse(json['id'].toString()),
    );
  }
}

// ฟังก์ชันเพื่อทำการลบข้อมูล
Future<void> deleteImage(int id) async {
  final response = await http.delete(
    Uri.parse('http://192.168.100.221/image_esp32cam/api/api_esp32.php?id=$id'),
  );

  if (response.statusCode != 200) {
    throw Exception('Failed to delete image');
  }
}

// หน้าจอสำหรับแสดงรายการภาพ
class ImageList extends StatefulWidget {
  @override
  _ImageListState createState() => _ImageListState();
}

class _ImageListState extends State<ImageList> {
  late Future<List<ImageData>> futureImages;

  @override
  void initState() {
    super.initState();
    futureImages = fetchImages(); // ดึงข้อมูลตั้งแต่เริ่ม
  }

  void refreshImages() {
    setState(() {
      futureImages = fetchImages(); // รีเฟรชข้อมูล
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Image List'), // ชื่อหน้า
      ),
      body: FutureBuilder<List<ImageData>>(
        future: futureImages,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return Center(child: Text('No images found.'));
          } else {
            return ListView.builder(
              itemCount: snapshot.data!.length,
              itemBuilder: (context, index) {
                final image = snapshot.data![index];
                return Card(
                  margin: EdgeInsets.all(8.0),
                  child: ListTile(
                    title: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(image.filename),
                        Text(
                          image.text, // แสดง text ที่รับมาจาก API
                          style: TextStyle(color: Colors.grey), // สไตล์สีเทา
                        ),
                      ],
                    ),
                    subtitle: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Date: ${image.date}'),
                        Text('Time: ${image.time}'),
                      ],
                    ),
                    trailing: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        ElevatedButton(
                          onPressed: () async {
                            final url =
                                'http://192.168.100.221/image_esp32cam/uploads/${image.filename}';
                            if (await canLaunch(url)) {
                              await launch(url); // เปิด URL ในเบราว์เซอร์
                            } else {
                              throw 'Could not launch $url';
                            }
                          },
                          child: Text('View'), // ปุ่ม "View"
                        ),
                        SizedBox(width: 8), // เว้นระยะห่างระหว่างปุ่ม
                        ElevatedButton(
                          onPressed: () {
                            showDeleteConfirmationDialog(
                                context, image.id, refreshImages);
                          },
                          child: Text('Delete'), // ปุ่ม "Delete"
                        ),
                      ],
                    ),
                  ),
                );
              },
            );
          }
        },
      ),
    );
  }
}

// แสดง Dialog ยืนยันการลบ
Future<void> showDeleteConfirmationDialog(
    BuildContext context, int id, Function refresh) async {
  return showDialog<void>(
    context: context,
    barrierDismissible: false,
    builder: (BuildContext context) {
      return AlertDialog(
        title: const Text('Confirm Delete'),
        content: const Text('Are you sure you want to delete this image?'),
        actions: <Widget>[
          TextButton(
            child: const Text('Cancel'),
            onPressed: () {
              Navigator.of(context).pop();
            },
          ),
          TextButton(
            child: const Text('Yes'),
            onPressed: () async {
              await deleteImage(id);
              Navigator.of(context).pop();
              refresh(); // รีเฟรชข้อมูลในหน้าจอ
            },
          ),
        ],
      );
    },
  );
}
