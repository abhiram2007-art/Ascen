import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../../models/quest_model.dart';
import '../../providers/auth_provider.dart';
import '../../providers/quest_provider.dart';
import '../../config/constants.dart';

class AddQuestScreen extends StatefulWidget {
  const AddQuestScreen({Key? key}) : super(key: key);

  @override
  State<AddQuestScreen> createState() => _AddQuestScreenState();
}

class _AddQuestScreenState extends State<AddQuestScreen> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();

  String _selectedType = 'Daily';
  String _selectedCategory = 'Coding';
  int _selectedDifficulty = 1; // 1 to 5
  String _selectedStat = 'Strength';
  DateTime? _dueDate;
  bool _isLoading = false;

  final List<String> _questTypes = ['Daily', 'Main', 'Side', 'Habit', 'Challenge'];
  final List<String> _categories = ['Coding', 'Fitness', 'Study', 'Reading', 'Other'];
  final List<String> _stats = ['Strength', 'Intelligence', 'Vitality', 'Agility', 'Perception'];

  // Difficulty colors and XP
  final List<Map<String, dynamic>> _difficulties = [
    {'name': 'Easy', 'color': Colors.green, 'xp': 25}, // Updated to match constants
    {'name': 'Medium', 'color': const Color(0xFF00D4FF), 'xp': 50},
    {'name': 'Hard', 'color': Colors.orange, 'xp': 100},
    {'name': 'Major', 'color': Colors.purple, 'xp': 200},
    {'name': 'Challenge', 'color': Colors.red, 'xp': 500},
  ];

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (_formKey.currentState!.validate()) {
      setState(() => _isLoading = true);
      
      try {
        final authProvider = Provider.of<AuthProvider>(context, listen: false);
        final userId = authProvider.user?.uid;
        
        if (userId == null) {
          throw Exception('User not logged in');
        }
        
        final questProvider = Provider.of<QuestProvider>(context, listen: false);
        
        // Find corresponding enums
        final typeEnum = QuestType.values.firstWhere(
          (e) => e.name.toLowerCase() == _selectedType.toLowerCase(), 
          orElse: () => QuestType.daily
        );
        
        final diffEnum = QuestDifficulty.values[_selectedDifficulty - 1];
        
        final newQuest = QuestModel(
          id: '', // Empty, Firestore will assign
          title: _titleController.text.trim(),
          description: _descriptionController.text.trim(),
          type: typeEnum,
          category: _selectedCategory,
          difficulty: diffEnum,
          statType: _selectedStat.toLowerCase(),
          xpReward: diffEnum.xpReward,
          createdAt: DateTime.now(),
          dueDate: _dueDate,
        );
        
        await questProvider.createQuest(userId, newQuest);
        
        if (mounted) {
          Navigator.pop(context); // Go back to home
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Error creating quest: $e'), backgroundColor: Colors.red),
          );
        }
      } finally {
        if (mounted) setState(() => _isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0A0A0F),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: Text(
          'NEW QUEST',
          style: GoogleFonts.orbitron(
            color: const Color(0xFF00D4FF),
            fontWeight: FontWeight.bold,
          ),
        ),
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: _isLoading 
        ? const Center(child: CircularProgressIndicator(color: Color(0xFF00D4FF)))
        : SingleChildScrollView(
            padding: const EdgeInsets.all(16.0),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  _buildGlassCard(
                    child: Column(
                      children: [
                        TextFormField(
                          controller: _titleController,
                          style: const TextStyle(color: Colors.white),
                          decoration: _inputDecoration('Quest Title'),
                          validator: (value) => value == null || value.isEmpty ? 'Title is required' : null,
                        ),
                        const SizedBox(height: 16),
                        TextFormField(
                          controller: _descriptionController,
                          style: const TextStyle(color: Colors.white),
                          maxLines: 3,
                          decoration: _inputDecoration('Description (Optional)'),
                        ),
                        const SizedBox(height: 16),
                        DropdownButtonFormField<String>(
                          value: _selectedType,
                          dropdownColor: const Color(0xFF1A1A24),
                          style: const TextStyle(color: Colors.white),
                          decoration: _inputDecoration('Quest Type'),
                          items: _questTypes.map((type) => DropdownMenuItem(value: type, child: Text(type))).toList(),
                          onChanged: (value) => setState(() => _selectedType = value!),
                        ),
                        const SizedBox(height: 16),
                        DropdownButtonFormField<String>(
                          value: _selectedCategory,
                          dropdownColor: const Color(0xFF1A1A24),
                          style: const TextStyle(color: Colors.white),
                          decoration: _inputDecoration('Category'),
                          items: _categories.map((cat) => DropdownMenuItem(value: cat, child: Text(cat))).toList(),
                          onChanged: (value) => setState(() => _selectedCategory = value!),
                        ),
                        const SizedBox(height: 16),
                        DropdownButtonFormField<String>(
                          value: _selectedStat,
                          dropdownColor: const Color(0xFF1A1A24),
                          style: const TextStyle(color: Colors.white),
                          decoration: _inputDecoration('Stat Type'),
                          items: _stats.map((stat) => DropdownMenuItem(value: stat, child: Text(stat))).toList(),
                          onChanged: (value) => setState(() => _selectedStat = value!),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 24),
                  Text(
                    'DIFFICULTY',
                    style: GoogleFonts.rajdhani(color: const Color(0xFF00D4FF), fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 8),
                  SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: Row(
                      children: List.generate(_difficulties.length, (index) {
                        final difficulty = _difficulties[index];
                        final isSelected = _selectedDifficulty == index + 1;
                        return Padding(
                          padding: const EdgeInsets.only(right: 8.0),
                          child: GestureDetector(
                            onTap: () => setState(() => _selectedDifficulty = index + 1),
                            child: Container(
                              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                              decoration: BoxDecoration(
                                color: isSelected ? difficulty['color'].withOpacity(0.2) : Colors.transparent,
                                border: Border.all(
                                  color: isSelected ? difficulty['color'] : Colors.white24,
                                ),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Column(
                                children: [
                                  Text(
                                    difficulty['name'],
                                    style: TextStyle(color: isSelected ? difficulty['color'] : Colors.white70),
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    '+${difficulty['xp']} XP',
                                    style: GoogleFonts.rajdhani(color: const Color(0xFFFFD700), fontWeight: FontWeight.bold),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        );
                      }),
                    ),
                  ),
                  const SizedBox(height: 24),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text('Reward Preview:', style: TextStyle(color: Colors.white70)),
                      Text(
                        '+${_difficulties[_selectedDifficulty - 1]['xp']} XP',
                        style: GoogleFonts.orbitron(color: const Color(0xFFFFD700), fontSize: 20, fontWeight: FontWeight.bold),
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),
                  ElevatedButton(
                    onPressed: _submit,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF00D4FF).withOpacity(0.2),
                      side: const BorderSide(color: Color(0xFF00D4FF)),
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                    ),
                    child: Text(
                      'CREATE QUEST',
                      style: GoogleFonts.orbitron(color: const Color(0xFF00D4FF), fontWeight: FontWeight.bold, fontSize: 16),
                    ),
                  ),
                ],
              ),
            ),
          ),
    );
  }

  Widget _buildGlassCard({required Widget child}) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.05),
        border: Border.all(color: const Color(0xFF00D4FF).withOpacity(0.3)),
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF00D4FF).withOpacity(0.1),
            blurRadius: 10,
            spreadRadius: 1,
          ),
        ],
      ),
      child: child,
    );
  }

  InputDecoration _inputDecoration(String label) {
    return InputDecoration(
      labelText: label,
      labelStyle: const TextStyle(color: Colors.white54),
      enabledBorder: const UnderlineInputBorder(
        borderSide: BorderSide(color: Colors.white24),
      ),
      focusedBorder: const UnderlineInputBorder(
        borderSide: BorderSide(color: Color(0xFF00D4FF)),
      ),
    );
  }
}
