import 'dart:async';
import 'package:flutter/material.dart';
import '../service/image_service.dart';
import '../models/image_data_model.dart';
import 'package:url_launcher/url_launcher.dart';

class ImageListScreen extends StatefulWidget {
  @override
  _ImageListScreenState createState() => _ImageListScreenState();
}

class _ImageListScreenState extends State<ImageListScreen> {
  List<ImageData> currentImages = [];
  late Timer _timer;
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    fetchImages();
    _timer = Timer.periodic(Duration(seconds: 1), (timer) => fetchNewImages());
  }

  @override
  void dispose() {
    _timer.cancel();
    _scrollController.dispose();
    super.dispose();
  }

  Future<void> fetchImages() async {
    try {
      currentImages = await ApiService().fetchImages();
      setState(() {});
    } catch (error) {
      print('Error fetching images: $error');
    }
  }

  Future<void> fetchNewImages() async {
    if (currentImages.isNotEmpty) {
      final lastImageId = currentImages.last.id;
      try {
        final newImages = await ApiService().fetchNewImages(lastImageId);
        setState(() {
          currentImages.addAll(newImages.where((newImage) =>
              !currentImages.any((image) => image.id == newImage.id)));
        });
      } catch (error) {
        print('Error fetching new images: $error');
      }
    } else {
      fetchImages();
    }
  }

  Future<void> deleteImage(String id) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Confirm Delete'),
        content: Text('Are you sure you want to delete this image?'),
        actions: [
          TextButton(
            child: Text('Cancel', style: TextStyle(color: Colors.blue)),
            onPressed: () => Navigator.of(context).pop(false),
          ),
          TextButton(
            child: Text('Yes', style: TextStyle(color: Colors.red)),
            onPressed: () => Navigator.of(context).pop(true),
          ),
        ],
      ),
    );

    if (confirm == true) {
      try {
        await ApiService().deleteImage(id);
        showCenterNotification('Image deleted successfully!');
        fetchImages();
      } catch (error) {
        print('Error deleting image: $error');
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
              content: Text('Failed to delete image: $error'),
              backgroundColor: Colors.red),
        );
      }
    }
  }

  void showCenterNotification(String message,
      {Color backgroundColor = Colors.green}) {
    final overlay = Overlay.of(context);
    final overlayEntry = OverlayEntry(
      builder: (context) => Center(
        child: Material(
          elevation: 4,
          borderRadius: BorderRadius.circular(8),
          child: Container(
            decoration: BoxDecoration(
                color: backgroundColor, borderRadius: BorderRadius.circular(8)),
            padding: EdgeInsets.symmetric(vertical: 10, horizontal: 20),
            child: Text(message,
                style: TextStyle(color: Colors.white, fontSize: 16),
                textAlign: TextAlign.center),
          ),
        ),
      ),
    );

    overlay.insert(overlayEntry);
    Future.delayed(Duration(seconds: 2), overlayEntry.remove);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('รูปในระบบ',
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20)),
        centerTitle: true,
      ),
      body: currentImages.isEmpty
          ? Center(child: CircularProgressIndicator())
          : ListView.separated(
              controller: _scrollController,
              itemCount: currentImages.length,
              separatorBuilder: (context, index) => Divider(height: 1),
              itemBuilder: (context, index) {
                final image = currentImages[index];
                return Card(
                  margin: EdgeInsets.symmetric(vertical: 8, horizontal: 10),
                  elevation: 4,
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(15)),
                  child: ListTile(
                    contentPadding: EdgeInsets.all(16),
                    title: Text(image.fileName,
                        style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 18,
                            color: Colors.blueGrey[800])),
                    subtitle: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        SizedBox(height: 5),
                        Text(image.text,
                            style:
                                TextStyle(fontSize: 16, color: Colors.black87)),
                        SizedBox(height: 5),
                        Text('วันที่: ${image.createdDate}',
                            style: TextStyle(color: Colors.black54)),
                        Text('เวลา: ${image.createdTime}',
                            style: TextStyle(color: Colors.black54)),
                      ],
                    ),
                    trailing: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        ElevatedButton(
                          onPressed: () async {
                            final url =
                                'http://192.168.100.221/image_esp32cam/uploads/${image.fileName}';
                            if (await canLaunch(url)) {
                              await launch(url); // เปิด URL ในเบราว์เซอร์
                            } else {
                              throw 'ไม่สามารถเปิด $url';
                            }
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor:
                                Colors.blueAccent, // สีพื้นหลังของปุ่ม
                            foregroundColor: Colors.white, // สีตัวอักษร
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12), // ขอบมุม
                            ),
                            padding: EdgeInsets.symmetric(
                                horizontal: 20, vertical: 10), // ขนาดของปุ่ม
                            elevation: 5, // เงาของปุ่ม
                          ),
                          child: Text(
                            'View',
                            style: TextStyle(
                              fontSize: 16, // ขนาดตัวอักษร
                              fontWeight: FontWeight.bold, // ตัวหนา
                            ),
                          ),
                        ),
                        IconButton(
                          icon: Icon(Icons.delete, color: Colors.red),
                          onPressed: () => deleteImage(image.id),
                        ),
                      ],
                    ),
                    onTap: () {
                      _scrollController.animateTo(index * 80.0,
                          duration: Duration(milliseconds: 300),
                          curve: Curves.easeInOut);
                    },
                  ),
                );
              },
            ),
    );
  }
}
