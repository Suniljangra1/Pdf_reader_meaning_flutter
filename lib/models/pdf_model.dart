class PDFModel {
  final String id;
  final String name;
  final String date;
  final String size;
  final String status; // 'processed', 'pending', 'downloaded'

  PDFModel({
    required this.id,
    required this.name,
    required this.date,
    required this.size,
    required this.status,
  });
}