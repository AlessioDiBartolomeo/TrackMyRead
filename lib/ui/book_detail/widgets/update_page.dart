import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'update_button.dart';

class UpdatePage extends StatelessWidget {
  final int currentPage;
  final int totalPages;
  final void Function(int) onPageUpdated;

  const UpdatePage({
    super.key,
    required this.currentPage,
    required this.totalPages,
    required this.onPageUpdated,
  });

  @override
  Widget build(BuildContext context) {
    int tempPage = currentPage;
    bool usePicker = true; // true = swipe picker, false = manual input

    return Padding(
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom + 16,
        top: 16,
        left: 16,
        right: 16,
      ),
      child: StatefulBuilder(
        builder: (context, setState) {
          return Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                "Set Current Page",
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Colors.deepPurple[800],
                ),
              ),
              const SizedBox(height: 16),

              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  ChoiceChip(
                    label: const Text("Scorrimento"),
                    selected: usePicker,
                    onSelected: (_) => setState(() => usePicker = true),
                  ),
                  const SizedBox(width: 16),
                  ChoiceChip(
                    label: const Text("Inserisci Numero Pagina"),
                    selected: !usePicker,
                    onSelected: (_) => setState(() => usePicker = false),
                  ),
                ],
              ),
              const SizedBox(height: 16),

              if (usePicker)
                SizedBox(
                  height: 150,
                  child: CupertinoPicker(
                    itemExtent: 40,
                    scrollController:
                        FixedExtentScrollController(initialItem: tempPage),
                    onSelectedItemChanged: (index) {
                      setState(() {
                        tempPage = index;
                      });
                    },
                    children: List.generate(
                      totalPages + 1,
                      (index) => Center(child: Text("$index")),
                    ),
                  ),
                )
              else
                TextField(
                  keyboardType: TextInputType.number,
                  decoration: InputDecoration(
                    labelText: "Enter page number",
                    border:
                        OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                  onChanged: (value) {
                    int? page = int.tryParse(value);
                    if (page != null && page >= 0 && page <= totalPages) {
                      tempPage = page;
                    }
                  },
                ),

              const SizedBox(height: 16),

              UpdateButton(
                text: "Update",
                onTap: () => Navigator.pop(context, tempPage),
              ),
              const SizedBox(height: 16),
            ],
          );
        },
      ),
    );
  }
}
