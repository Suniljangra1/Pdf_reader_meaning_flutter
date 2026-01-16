import 'package:flutter/material.dart';
import '../models/pdf_model.dart';
import '../data/static_data.dart';

class DownloadedController extends ChangeNotifier {
  List<PDFModel> get downloadedList => StaticData.downloadedList;

  void refreshDownloaded() {
    notifyListeners();
  }

  void deleteDownloadedItem(String id) {
    StaticData.downloadedList.removeWhere((item) => item.id == id);
    notifyListeners();
  }

  void openPDF(String id) {
    // Logic to open PDF
    print('Opening PDF with id: $id');
  }
}