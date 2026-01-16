import '../models/pdf_model.dart';
import '../models/word_model.dart';

class StaticData {
  static List<PDFModel> historyList = [
    PDFModel(
      id: '1',
      name: 'English Grammar Book.pdf',
      date: '2024-01-08 10:30 AM',
      size: '2.5 MB',
      status: 'processed',
    ),
    PDFModel(
      id: '2',
      name: 'Advanced Vocabulary.pdf',
      date: '2024-01-07 03:45 PM',
      size: '1.8 MB',
      status: 'processed',
    ),
    PDFModel(
      id: '3',
      name: 'Technical Terms Guide.pdf',
      date: '2024-01-06 09:15 AM',
      size: '3.2 MB',
      status: 'pending',
    ),
  ];

  static List<PDFModel> downloadedList = [
    PDFModel(
      id: '1',
      name: 'English Grammar Book_processed.pdf',
      date: '2024-01-08 10:35 AM',
      size: '2.8 MB',
      status: 'downloaded',
    ),
    PDFModel(
      id: '2',
      name: 'Advanced Vocabulary_processed.pdf',
      date: '2024-01-07 03:50 PM',
      size: '2.1 MB',
      status: 'downloaded',
    ),
  ];

  static List<WordModel> sampleWords = [
    WordModel(word: 'Ephemeral', meaning: 'Lasting for a very short time'),
    WordModel(word: 'Ubiquitous', meaning: 'Present everywhere'),
    WordModel(word: 'Enigma', meaning: 'A mysterious person or thing'),
  ];
}