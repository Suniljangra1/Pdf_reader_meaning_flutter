import 'package:flutter/material.dart';
import '../../data/static_data.dart';
import '../widgets/pdf_card.dart';

class DownloadedScreen extends StatelessWidget {
  const DownloadedScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Downloaded'),
        centerTitle: true,
        elevation: 0,
      ),
      body: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: StaticData.downloadedList.length,
        itemBuilder: (context, index) {
          final pdf = StaticData.downloadedList[index];
          return PDFCard(
            pdfModel: pdf,
            showDownloadIcon: true,
            onTap: () {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text('Opening ${pdf.name}')),
              );
            },
          );
        },
      ),
    );
  }
}