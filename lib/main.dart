import 'package:flutter/material.dart';
import 'database_helper.dart';

void main() {
  // Nécessaire pour initialiser les plugins avant runApp ou pour sqflite sur certaines plateformes
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Gestion des Examens',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.blue),
        useMaterial3: true,
      ),
      home: const ExamListPage(),
    );
  }
}

class ExamListPage extends StatefulWidget {
  const ExamListPage({super.key});

  @override
  State<ExamListPage> createState() => _ExamListPageState();
}

class _ExamListPageState extends State<ExamListPage> {
  final DatabaseHelper _dbHelper = DatabaseHelper();
  final TextEditingController _controller = TextEditingController();
  List<Map<String, dynamic>> _exams = [];

  @override
  void initState() {
    super.initState();
    _refreshExams();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _refreshExams() async {
    final data = await _dbHelper.getExams();
    setState(() {
      _exams = data;
    });
  }

  void _addExam() async {
    if (_controller.text.trim().isNotEmpty) {
      await _dbHelper.insertExam(_controller.text.trim());
      _controller.clear();
      _refreshExams();
    }
  }

  void _deleteExam(int id) async {
    await _dbHelper.deleteExam(id);
    _refreshExams();
  }

  void _showEditDialog(int id, String currentName) {
    final TextEditingController editController = TextEditingController(text: currentName);
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Modifier l\'examen'),
        content: TextField(
          controller: editController,
          decoration: const InputDecoration(hintText: "Nouveau nom"),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Annuler'),
          ),
          ElevatedButton(
            onPressed: () async {
              if (editController.text.trim().isNotEmpty) {
                await _dbHelper.updateExam(id, editController.text.trim());
                _refreshExams();
                if (mounted) Navigator.pop(context);
              }
            },
            child: const Text('Enregistrer'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Gestion des Examens'),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _controller,
                    decoration: const InputDecoration(
                      labelText: 'Nom de l\'examen',
                      border: OutlineInputBorder(),
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                ElevatedButton(
                  onPressed: _addExam,
                  child: const Text('Ajouter'),
                ),
              ],
            ),
            const SizedBox(height: 20),
            Expanded(
              child: _exams.isEmpty
                  ? const Center(child: Text('Aucun examen.'))
                  : ListView.builder(
                      itemCount: _exams.length,
                      itemBuilder: (context, index) {
                        final exam = _exams[index];
                        return Card(
                          child: ListTile(
                            title: Text(exam['exam_name']),
                            trailing: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                IconButton(
                                  icon: const Icon(Icons.edit, color: Colors.blue),
                                  onPressed: () => _showEditDialog(exam['id'], exam['exam_name']),
                                ),
                                IconButton(
                                  icon: const Icon(Icons.delete, color: Colors.red),
                                  onPressed: () => _deleteExam(exam['id']),
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                    ),
            ),
          ],
        ),
      ),
    );
  }
}
