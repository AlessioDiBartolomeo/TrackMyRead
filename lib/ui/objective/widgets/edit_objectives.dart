import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class EditObjectives extends StatefulWidget {
  const EditObjectives({super.key});

  @override
  State<EditObjectives> createState() => _EditObjectivesScreenState();
}

class _EditObjectivesScreenState extends State<EditObjectives> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _dailyController = TextEditingController();
  final TextEditingController _monthlyController = TextEditingController();
  final TextEditingController _yearlyController = TextEditingController();
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadObjectives();
  }

  Future<void> _loadObjectives() async {
    final uid = FirebaseAuth.instance.currentUser?.uid;
    if (uid == null) return;

    final doc = await FirebaseFirestore.instance
        .collection('users')
        .doc(uid)
        .collection('objectives')
        .doc('reading')
        .get();

    if (doc.exists) {
      final data = doc.data()!;
      _dailyController.text = (data['daily'] ?? 0).toString();
      _monthlyController.text = (data['monthly'] ?? 0).toString();
      _yearlyController.text = (data['yearly'] ?? 0).toString();
    } else {
      _dailyController.text = "0";
      _monthlyController.text = "0";
      _yearlyController.text = "0";
    }

    setState(() {
      isLoading = false;
    });
  }

  Future<void> _saveObjectives() async {
    if (!_formKey.currentState!.validate()) return;

    final uid = FirebaseAuth.instance.currentUser?.uid;
    if (uid == null) return;

    final daily = int.tryParse(_dailyController.text) ?? 0;
    final monthly = int.tryParse(_monthlyController.text) ?? 0;
    final yearly = int.tryParse(_yearlyController.text) ?? 0;

    await FirebaseFirestore.instance
        .collection('users')
        .doc(uid)
        .collection('objectives')
        .doc('reading')
        .set({
      "daily": daily,
      "monthly": monthly,
      "yearly": yearly,
    });

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Obiettivi aggiornati con successo!")),
      );
      Navigator.pop(context);
    }
  }

  @override
  void dispose() {
    _dailyController.dispose();
    _monthlyController.dispose();
    _yearlyController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text("Modifica Obiettivi"),
        backgroundColor: Colors.deepPurple,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              TextFormField(
                controller: _dailyController,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(
                  labelText: "Obiettivo giornaliero (pagine)",
                  border: OutlineInputBorder(),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) return "Inserisci un valore";
                  if (int.tryParse(value) == null) return "Inserisci un numero valido";
                  return null;
                },
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _monthlyController,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(
                  labelText: "Obiettivo mensile (pagine)",
                  border: OutlineInputBorder(),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) return "Inserisci un valore";
                  if (int.tryParse(value) == null) return "Inserisci un numero valido";
                  return null;
                },
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _yearlyController,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(
                  labelText: "Obiettivo annuale (pagine)",
                  border: OutlineInputBorder(),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) return "Inserisci un valore";
                  if (int.tryParse(value) == null) return "Inserisci un numero valido";
                  return null;
                },
              ),
              const SizedBox(height: 30),
              ElevatedButton(
                onPressed: _saveObjectives,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.deepPurple,
                  padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 14),
                ),
                child: const Text("Salva Obiettivi",
                    style: TextStyle(fontSize: 16, color: Colors.white)),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
