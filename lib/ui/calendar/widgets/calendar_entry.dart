import 'dart:io';
import 'package:flutter/material.dart';
import '../../../domain/models/calendar_reading_entry.dart';


class CalendarEntry extends StatelessWidget {
  final CalendarReadingEntry entry;
  final bool showCover;

  const CalendarEntry({super.key, required this.entry, this.showCover = false});

  @override
  Widget build(BuildContext context) {
    return InkWell(

      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Book cover or icon
            entry.imagePath != null && showCover
                ? (entry.imagePath!.startsWith("assets/")
                    ? Image.asset(
                        entry.imagePath!,
                        width: 80,
                        height: 120,
                        fit: BoxFit.fill,
                      )
                    : File(entry.imagePath!).existsSync()
                        ? Image.file(
                            File(entry.imagePath!),
                            width: 80,
                            height: 120,
                            fit: BoxFit.fill,
                          )
                        : const Icon(Icons.book, size: 80, color: Colors.deepPurple))
                : const Icon(Icons.book, size: 80, color: Colors.deepPurple),
            const SizedBox(width: 16),
            // Book info
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    entry.bookName,
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    '${entry.pagesRead} pages',
                    style: const TextStyle(fontSize: 16),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
