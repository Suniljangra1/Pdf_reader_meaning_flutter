import 'package:flutter/material.dart';
import '../../data/static_data.dart';
import '../widgets/pdf_card.dart';

class HistoryScreen extends StatelessWidget {
  const HistoryScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('History'),
        centerTitle: true,
        elevation: 0,
      ),
      body: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: StaticData.historyList.length,
        itemBuilder: (context, index) {
          final pdf = StaticData.historyList[index];
          return PDFCard(
            pdfModel: pdf,
            onTap: () {
              // Handle tap
            },
          );
        },
      ),
    );
  }
}