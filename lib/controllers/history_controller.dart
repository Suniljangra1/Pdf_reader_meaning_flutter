import 'package:flutter/material.dart';
import '../models/pdf_model.dart';
import '../data/static_data.dart';

class HistoryController extends ChangeNotifier {
  List<PDFModel> get historyList => StaticData.historyList;

  void refreshHistory() {
    notifyListeners();
  }

  void deleteHistoryItem(String id) {
    StaticData.historyList.removeWhere((item) => item.id == id);
    notifyListeners();
  }
}