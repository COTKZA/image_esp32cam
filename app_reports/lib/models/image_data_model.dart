class ImageData {
  final String id;
  final String fileName;
  final String filePath;
  final String text;
  final String createdDate;
  final String createdTime;

  ImageData({
    required this.id,
    required this.fileName,
    required this.filePath,
    required this.text,
    required this.createdDate,
    required this.createdTime,
  });

  factory ImageData.fromJson(Map<String, dynamic> json) {
    return ImageData(
      id: json['id'],
      fileName: json['file_name'],
      filePath: json['filepath'],
      text: json['text'],
      createdDate: json['created_date'],
      createdTime: json['created_time'],
    );
  }
}
