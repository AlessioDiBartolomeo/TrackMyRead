import 'package:flutter/material.dart';
import 'package:flutter_library_app/ui/objective/widgets/build_card_objective_screen.dart';
import 'package:flutter_library_app/ui/objective/widgets/edit_objectives.dart';
import 'package:flutter_library_app/ui/objective/widgets/view_objectives.dart';

class ObjectiveScreen extends StatelessWidget {
  const ObjectiveScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Obiettivi"),
        backgroundColor: Colors.deepPurple,
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          buildCardObjectiveScreen(
            context,
            "✏️ Modifica obiettivi",
            "Imposta i tuoi obiettivi di lettura",
            () => Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const EditObjectives()),
            ),
          ),
          const SizedBox(height: 12),
          buildCardObjectiveScreen(
            context,
            "📊 Visualizza obiettivi",
            "Controlla i tuoi progressi",
            () => Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const ViewObjectives()),
            ),
          ),
        ],
      ),
    );
  }
}
