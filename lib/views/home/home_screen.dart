import 'dart:io';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import 'package:http/http.dart' as http;
import 'package:path_provider/path_provider.dart';
import 'package:flutter/foundation.dart'; // kIsWeb
import '../../utils/colors.dart';
import '../../utils/constants.dart';
import 'package:dio/dio.dart';
// For Web download
import 'dart:html' as html;

class HomeScreen extends StatefulWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  // ================= STATE =================
  String? selectedPDF;
  File? selectedPDFFile;        // Mobile/Desktop
  Uint8List? selectedPDFBytes;  // Web
  String? selectedWordList;
  File? selectedWordListFile;

  bool isProcessing = false;
  double pdfProgress = 0.0; // 0.0 → 1.0
  String statusMessage = ''; // NEW: Status message
  File? processedPdfFile;
  Uint8List? processedPdfBytes; // Web

  // ================= API CALL =================
  Future<void> processPdfApi(BuildContext context) async {
    if (kIsWeb && selectedPDFBytes == null) return;
    if (!kIsWeb && selectedPDFFile == null) return;

    setState(() {
      isProcessing = true;
      pdfProgress = 0.0;
      statusMessage = 'Preparing upload...';
      processedPdfBytes = null;
      processedPdfFile = null;
    });

    try {
      final dio = Dio();
      final uri = kIsWeb
          ? 'http://localhost:9000/upload-pdf/' // web API
          : 'http://10.0.2.2:9000/upload-pdf/'; // mobile API

      FormData formData;

      if (kIsWeb) {
        formData = FormData.fromMap({
          "file": MultipartFile.fromBytes(selectedPDFBytes!, filename: selectedPDF),
        });
      } else {
        formData = FormData.fromMap({
          "file": await MultipartFile.fromFile(selectedPDFFile!.path),
        });
      }

      // Optional: add word list (mobile only)
      if (!kIsWeb && selectedWordListFile != null) {
        formData.files.add(
          MapEntry(
            "word_list",
            await MultipartFile.fromFile(selectedWordListFile!.path),
          ),
        );
      }

      final response = await dio.post(
        uri,
        data: formData,
        onSendProgress: (sent, total) {
          setState(() {
            pdfProgress = sent / total;

            // Update status message based on progress
            if (pdfProgress < 0.3) {
              statusMessage = 'Uploading PDF...';
            } else if (pdfProgress < 0.7) {
              statusMessage = 'Processing document...';
            } else if (pdfProgress < 0.95) {
              statusMessage = 'Finalizing...';
            } else {
              statusMessage = 'Almost done...';
            }
          });
        },
        options: Options(
          responseType: ResponseType.bytes, // get PDF as bytes
        ),
      );

      setState(() {
        statusMessage = 'Saving file...';
      });

      final responseBytes = Uint8List.fromList(response.data);

      // Save processed PDF
      if (kIsWeb) {
        setState(() => processedPdfBytes = responseBytes);
        downloadPdfWeb(responseBytes, 'processed_$selectedPDF');
      } else {
        final dir = await getApplicationDocumentsDirectory();
        final filePath = '${dir.path}/processed_$selectedPDF';
        final file = File(filePath);
        await file.writeAsBytes(responseBytes);
        setState(() => processedPdfFile = file);
      }

      setState(() {
        statusMessage = 'Completed successfully!';
        pdfProgress = 1.0;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('PDF processed successfully'),
          backgroundColor: Colors.green,
        ),
      );

      // Reset status message after 2 seconds
      await Future.delayed(const Duration(seconds: 2));
      if (mounted) {
        setState(() {
          statusMessage = '';
        });
      }
    } catch (e) {
      debugPrint('🔥 API Error: $e');

      setState(() {
        statusMessage = 'Error occurred!';
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error: $e'),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      setState(() {
        isProcessing = false;
      });

      // Reset progress after error
      await Future.delayed(const Duration(seconds: 2));
      if (mounted && pdfProgress != 1.0) {
        setState(() {
          pdfProgress = 0.0;
          statusMessage = '';
        });
      }
    }
  }

  // ================= WEB DOWNLOAD =================
  void downloadPdfWeb(Uint8List bytes, String filename) {
    final blob = html.Blob([bytes], 'application/pdf');
    final url = html.Url.createObjectUrlFromBlob(blob);
    final anchor = html.AnchorElement(href: url)
      ..setAttribute('download', filename)
      ..click();
    html.Url.revokeObjectUrl(url);
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('PDF download started')),
    );
  }

  // ================= MOBILE DOWNLOAD =================
  Future<void> downloadProcessedPdf(BuildContext context) async {
    if (processedPdfFile == null && !kIsWeb) return;
    if (processedPdfBytes == null && kIsWeb) return;

    try {
      if (kIsWeb) {
        downloadPdfWeb(processedPdfBytes!, 'processed_$selectedPDF');
      } else {
        final downloadsDir = Directory('/storage/emulated/0/Download');
        if (!downloadsDir.existsSync()) downloadsDir.createSync(recursive: true);

        final savedFile = File(
            '${downloadsDir.path}/processed_${processedPdfFile!.path.split('/').last}');
        await savedFile.writeAsBytes(await processedPdfFile!.readAsBytes());

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Saved to ${savedFile.path}')),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error saving PDF: $e')),
      );
    }
  }

  // ================= UI =================
  @override
  Widget build(BuildContext context) {
    debugPrint('🔄 build() → selectedPDF: $selectedPDF');

    return Scaffold(
      appBar: AppBar(
        title: const Text('PDF Dictionary'),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // HEADER
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [AppColors.primary, AppColors.secondary],
                ),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Column(
                children: const [
                  Text(
                    'PDF Dictionary Maker',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  SizedBox(height: 8),
                  Text(
                    'Upload your PDF and get meanings',
                    style: TextStyle(color: Colors.white70),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 24),

            // UPLOAD PDF
            _buildUploadCard(
              icon: Icons.picture_as_pdf,
              title: 'Upload PDF Document',
              subtitle: selectedPDF ?? AppConstants.uploadPDFHint,
              isSelected: selectedPDF != null,
              onTap: () async {
                debugPrint('📂 Opening PDF picker...');
                FilePickerResult? result = await FilePicker.platform.pickFiles(
                  type: FileType.custom,
                  allowedExtensions: ['pdf'],
                  withData: true, // Required for Web
                );

                if (result == null) {
                  debugPrint('❌ PDF picker canceled');
                  return;
                }

                final file = result.files.single;

                debugPrint('✅ PDF Selected: ${file.name}');
                debugPrint('📦 Size: ${file.size}');
                debugPrint('🌐 Is Web: $kIsWeb');

                if (kIsWeb) {
                  if (file.bytes == null) return;
                  setState(() {
                    selectedPDF = file.name;
                    selectedPDFBytes = file.bytes;
                  });
                } else {
                  if (file.path == null) return;
                  setState(() {
                    selectedPDF = file.name;
                    selectedPDFFile = File(file.path!);
                  });
                }
              },
            ),

            const SizedBox(height: 16),

            // UPLOAD WORD LIST
            _buildUploadCard(
              icon: Icons.text_snippet,
              title: 'Upload Word List',
              subtitle: selectedWordList ?? AppConstants.uploadWordListHint,
              isSelected: selectedWordList != null,
              onTap: () async {
                FilePickerResult? result = await FilePicker.platform.pickFiles(
                  type: FileType.custom,
                  allowedExtensions: ['txt', 'doc', 'docx'],
                );
                if (result == null) return;
                final file = result.files.single;
                if (file.path == null) return;
                setState(() {
                  selectedWordList = file.name;
                  selectedWordListFile = File(file.path!);
                });
              },
            ),

            const SizedBox(height: 24),

            // PROGRESS BAR SECTION (NEW)
            if (isProcessing) ...[
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: Colors.blue.shade50,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.blue.shade200),
                ),
                child: Column(
                  children: [
                    // Circular Progress
                    SizedBox(
                      width: 100,
                      height: 100,
                      child: Stack(
                        alignment: Alignment.center,
                        children: [
                          SizedBox(
                            width: 100,
                            height: 100,
                            child: CircularProgressIndicator(
                              value: pdfProgress,
                              strokeWidth: 10,
                              backgroundColor: Colors.grey[300],
                              valueColor: AlwaysStoppedAnimation<Color>(
                                pdfProgress == 1.0
                                    ? Colors.green
                                    : AppColors.primary,
                              ),
                            ),
                          ),
                          Text(
                            '${(pdfProgress * 100).toInt()}%',
                            style: const TextStyle(
                              fontSize: 24,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 20),

                    // Status Message
                    Text(
                      statusMessage,
                      style: TextStyle(
                        fontSize: 16,
                        color: Colors.grey[700],
                        fontWeight: FontWeight.w500,
                      ),
                    ),

                    const SizedBox(height: 12),

                    // Linear Progress Bar
                    ClipRRect(
                      borderRadius: BorderRadius.circular(10),
                      child: LinearProgressIndicator(
                        value: pdfProgress,
                        minHeight: 8,
                        backgroundColor: Colors.grey[300],
                        valueColor: AlwaysStoppedAnimation<Color>(
                          pdfProgress == 1.0
                              ? Colors.green
                              : AppColors.primary,
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 24),
            ],

            // PROCESS BUTTON
            ElevatedButton.icon(
              onPressed: selectedPDF != null && !isProcessing
                  ? () async => await processPdfApi(context)
                  : null,
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              icon: Icon(
                isProcessing ? Icons.hourglass_empty : Icons.upload_file,
                color: Colors.white,
              ),
              label: Text(
                isProcessing ? 'Processing...' : 'Process PDF',
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
            ),

            // DOWNLOAD BUTTON
            if ((processedPdfFile != null && !kIsWeb) ||
                (processedPdfBytes != null && kIsWeb)) ...[
              const SizedBox(height: 12),
              OutlinedButton.icon(
                onPressed: () async => await downloadProcessedPdf(context),
                style: OutlinedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  side: const BorderSide(color: AppColors.primary, width: 2),
                ),
                icon: const Icon(Icons.download, color: AppColors.primary),
                label: const Text(
                  'Download Processed PDF',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: AppColors.primary,
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  // ================= UPLOAD CARD =================
  Widget _buildUploadCard({
    required IconData icon,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
    required bool isSelected,
  }) {
    return InkWell(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: AppColors.cardBackground,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isSelected ? Colors.green : Colors.grey.shade300,
            width: 2,
          ),
        ),
        child: Column(
          children: [
            Icon(
              icon,
              size: 48,
              color: isSelected ? Colors.green : AppColors.primary,
            ),
            const SizedBox(height: 12),
            Text(
              title,
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 4),
            Text(
              subtitle,
              textAlign: TextAlign.center,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(fontSize: 14),
            ),
          ],
        ),
      ),
    );
  }
}