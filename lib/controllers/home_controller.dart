import 'package:flutter/material.dart';

class HomeController extends ChangeNotifier {
  String? selectedPDFPath;
  String? selectedWordListPath;
  bool isProcessing = false;

  void selectPDF(String path) {
    selectedPDFPath = path;
    notifyListeners();
  }

  void selectWordList(String path) {
    selectedWordListPath = path;
    notifyListeners();
  }

  Future<void> processPDF() async {
    isProcessing = true;
    notifyListeners();

    // Simulate processing
    await Future.delayed(const Duration(seconds: 2));

    isProcessing = false;
    notifyListeners();
  }

  void reset() {
    selectedPDFPath = null;
    selectedWordListPath = null;
    isProcessing = false;
    notifyListeners();
  }
}