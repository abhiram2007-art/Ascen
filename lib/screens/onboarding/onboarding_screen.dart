import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../../providers/auth_provider.dart';
import '../../providers/player_provider.dart';

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({Key? key}) : super(key: key);

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  final PageController _pageController = PageController();
  int _currentStep = 0;
  final int _totalSteps = 4;

  // Step 1 Data
  final TextEditingController _nameController = TextEditingController();

  // Step 2 Data
  final List<String> _availableCategories = [
    'Coding', 'Fitness', 'Study', 'Reading', 'Meditation', 
    'Writing', 'Languages', 'Art', 'Music', 'Career'
  ];
  final Set<String> _selectedCategories = {};

  // Step 3 Data
  double _dailyHours = 4;
  String _preferredStartTime = 'Morning';
  final List<String> _timeOptions = ['Morning', 'Afternoon', 'Evening'];

  // Step 4 Data
  String _selectedDifficulty = '';

  void _nextStep() {
    if (_currentStep == 0 && _nameController.text.trim().isEmpty) {
      _showError('Please enter your player name');
      return;
    }
    if (_currentStep == 1 && _selectedCategories.isEmpty) {
      _showError('Select at least one quest category');
      return;
    }
    if (_currentStep == 3) {
      if (_selectedDifficulty.isEmpty) {
        _showError('Please choose a difficulty level');
        return;
      }
      // Finish onboarding
      final auth = Provider.of<AuthProvider>(context, listen: false);
      final playerProv = Provider.of<PlayerProvider>(context, listen: false);
      if (auth.user != null) {
        playerProv.updatePreferences(auth.user!.uid, {
          'name': _nameController.text.trim(),
          'categories': _selectedCategories.toList(),
          'dailyHours': _dailyHours,
          'preferredStartTime': _preferredStartTime,
          'difficulty': _selectedDifficulty,
        });
      }
      Navigator.pushReplacementNamed(context, '/home');
      return;
    }

    _pageController.nextPage(
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeInOut,
    );
  }

  void _previousStep() {
    _pageController.previousPage(
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeInOut,
    );
  }

  void _showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          message,
          style: GoogleFonts.inter(color: Colors.white),
        ),
        backgroundColor: Colors.redAccent.withOpacity(0.8),
        duration: const Duration(seconds: 2),
      ),
    );
  }

  @override
  void dispose() {
    _pageController.dispose();
    _nameController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0A0A0F),
      body: Stack(
        children: [
          // Background Gradient
          Positioned.fill(
            child: Container(
              decoration: const BoxDecoration(
                gradient: RadialGradient(
                  center: Alignment.center,
                  radius: 1.5,
                  colors: [
                    Color(0xFF0F172A),
                    Color(0xFF0A0A0F),
                  ],
                ),
              ),
            ),
          ),
          
          SafeArea(
            child: Column(
              children: [
                _buildHeader(),
                Expanded(
                  child: PageView(
                    controller: _pageController,
                    physics: const NeverScrollableScrollPhysics(),
                    onPageChanged: (index) {
                      setState(() {
                        _currentStep = index;
                      });
                    },
                    children: [
                      _buildStep1(),
                      _buildStep2(),
                      _buildStep3(),
                      _buildStep4(),
                    ],
                  ),
                ),
                _buildFooter(),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHeader() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 20.0),
      child: Column(
        children: [
          Text(
            'SYSTEM CONFIGURATION',
            style: GoogleFonts.orbitron(
              color: const Color(0xFF00D4FF),
              fontSize: 20,
              fontWeight: FontWeight.bold,
              letterSpacing: 2,
              shadows: [
                Shadow(
                  color: const Color(0xFF00D4FF).withOpacity(0.5),
                  blurRadius: 10,
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          // Step indicators
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: List.generate(
              _totalSteps,
              (index) => Container(
                margin: const EdgeInsets.symmetric(horizontal: 4),
                width: _currentStep == index ? 30 : 15,
                height: 4,
                decoration: BoxDecoration(
                  color: _currentStep == index
                      ? const Color(0xFF00D4FF)
                      : Colors.white.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(2),
                  boxShadow: _currentStep == index
                      ? [
                          BoxShadow(
                            color: const Color(0xFF00D4FF).withOpacity(0.5),
                            blurRadius: 4,
                          )
                        ]
                      : null,
                ),
              ),
            ),
          ),
          const SizedBox(height: 12),
          Text(
            'STEP ${_currentStep + 1} OF $_totalSteps',
            style: GoogleFonts.rajdhani(
              color: Colors.white70,
              fontSize: 16,
              fontWeight: FontWeight.w600,
              letterSpacing: 1.5,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildGlassCard({required Widget child}) {
    return Padding(
      padding: const EdgeInsets.all(24.0),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(16),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
          child: Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: Colors.black.withOpacity(0.4),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: const Color(0xFF00D4FF).withOpacity(0.3),
                width: 1.5,
              ),
              boxShadow: [
                BoxShadow(
                  color: const Color(0xFF00D4FF).withOpacity(0.1),
                  blurRadius: 20,
                  spreadRadius: -5,
                ),
              ],
            ),
            child: child,
          ),
        ),
      ),
    );
  }

  Widget _buildStep1() {
    return _buildGlassCard(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            'ENTER YOUR PLAYER NAME',
            style: GoogleFonts.rajdhani(
              color: Colors.white,
              fontSize: 24,
              fontWeight: FontWeight.bold,
              letterSpacing: 1.2,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 32),
          TextField(
            controller: _nameController,
            style: GoogleFonts.inter(color: Colors.white, fontSize: 18),
            decoration: InputDecoration(
              filled: true,
              fillColor: Colors.white.withOpacity(0.05),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide: BorderSide(color: Colors.white.withOpacity(0.2)),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide: const BorderSide(color: Color(0xFF00D4FF)),
              ),
              hintText: 'Sung Jin-Woo',
              hintStyle: GoogleFonts.inter(color: Colors.white30),
              prefixIcon: const Icon(Icons.person_outline, color: Color(0xFF00D4FF)),
            ),
          ),
          const SizedBox(height: 16),
          Text(
            'This name will be displayed on your profile',
            style: GoogleFonts.inter(
              color: Colors.white54,
              fontSize: 14,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildStep2() {
    return _buildGlassCard(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            'SELECT YOUR QUEST CATEGORIES',
            style: GoogleFonts.rajdhani(
              color: Colors.white,
              fontSize: 24,
              fontWeight: FontWeight.bold,
              letterSpacing: 1.2,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 24),
          Expanded(
            child: GridView.builder(
              itemCount: _availableCategories.length,
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                childAspectRatio: 2.5,
                crossAxisSpacing: 12,
                mainAxisSpacing: 12,
              ),
              itemBuilder: (context, index) {
                final category = _availableCategories[index];
                final isSelected = _selectedCategories.contains(category);
                return GestureDetector(
                  onTap: () {
                    setState(() {
                      if (isSelected) {
                        _selectedCategories.remove(category);
                      } else {
                        _selectedCategories.add(category);
                      }
                    });
                  },
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    decoration: BoxDecoration(
                      color: isSelected
                          ? const Color(0xFF00D4FF).withOpacity(0.2)
                          : Colors.white.withOpacity(0.05),
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(
                        color: isSelected
                            ? const Color(0xFF00D4FF)
                            : Colors.white.withOpacity(0.1),
                        width: 1,
                      ),
                      boxShadow: isSelected
                          ? [
                              BoxShadow(
                                color: const Color(0xFF00D4FF).withOpacity(0.3),
                                blurRadius: 8,
                              )
                            ]
                          : [],
                    ),
                    alignment: Alignment.center,
                    child: Text(
                      category,
                      style: GoogleFonts.inter(
                        color: isSelected ? const Color(0xFF00D4FF) : Colors.white70,
                        fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStep3() {
    return _buildGlassCard(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            'SET YOUR DAILY AVAILABILITY',
            style: GoogleFonts.rajdhani(
              color: Colors.white,
              fontSize: 24,
              fontWeight: FontWeight.bold,
              letterSpacing: 1.2,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 40),
          Text(
            'Daily Hours Dedicated: ${_dailyHours.toInt()}h',
            style: GoogleFonts.inter(
              color: const Color(0xFF00D4FF),
              fontSize: 18,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 16),
          SliderTheme(
            data: SliderThemeData(
              activeTrackColor: const Color(0xFF00D4FF),
              inactiveTrackColor: Colors.white.withOpacity(0.2),
              thumbColor: Colors.white,
              overlayColor: const Color(0xFF00D4FF).withOpacity(0.2),
            ),
            child: Slider(
              value: _dailyHours,
              min: 1,
              max: 16,
              divisions: 15,
              onChanged: (value) {
                setState(() {
                  _dailyHours = value;
                });
              },
            ),
          ),
          const SizedBox(height: 32),
          Text(
            'Preferred Start Time',
            style: GoogleFonts.inter(
              color: Colors.white70,
              fontSize: 16,
            ),
          ),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: _timeOptions.map((time) {
              final isSelected = _preferredStartTime == time;
              return GestureDetector(
                onTap: () {
                  setState(() {
                    _preferredStartTime = time;
                  });
                },
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  decoration: BoxDecoration(
                    color: isSelected
                        ? const Color(0xFF00D4FF).withOpacity(0.2)
                        : Colors.white.withOpacity(0.05),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(
                      color: isSelected
                          ? const Color(0xFF00D4FF)
                          : Colors.white.withOpacity(0.1),
                    ),
                  ),
                  child: Text(
                    time,
                    style: GoogleFonts.inter(
                      color: isSelected ? const Color(0xFF00D4FF) : Colors.white,
                      fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                    ),
                  ),
                ),
              );
            }).toList(),
          ),
        ],
      ),
    );
  }

  Widget _buildStep4() {
    return _buildGlassCard(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            'CHOOSE YOUR DIFFICULTY',
            style: GoogleFonts.rajdhani(
              color: Colors.white,
              fontSize: 24,
              fontWeight: FontWeight.bold,
              letterSpacing: 1.2,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 24),
          _buildDifficultyCard(
            title: 'CASUAL',
            description: 'Relaxed pace, fewer daily quests',
            accentColor: Colors.greenAccent,
          ),
          const SizedBox(height: 16),
          _buildDifficultyCard(
            title: 'DEDICATED',
            description: 'Balanced challenge, moderate quests',
            accentColor: const Color(0xFF00D4FF),
          ),
          const SizedBox(height: 16),
          _buildDifficultyCard(
            title: 'HARDCORE',
            description: 'Maximum challenge, many quests',
            accentColor: Colors.redAccent,
          ),
          const SizedBox(height: 24),
          if (_selectedDifficulty.isNotEmpty)
            AnimatedOpacity(
              opacity: 1.0,
              duration: const Duration(milliseconds: 500),
              child: Text(
                'SYSTEM CONFIGURED',
                style: GoogleFonts.orbitron(
                  color: const Color(0xFF00D4FF),
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 2,
                  shadows: [
                    Shadow(
                      color: const Color(0xFF00D4FF).withOpacity(0.5),
                      blurRadius: 10,
                    ),
                  ],
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildDifficultyCard({
    required String title,
    required String description,
    required Color accentColor,
  }) {
    final isSelected = _selectedDifficulty == title;
    return GestureDetector(
      onTap: () {
        setState(() {
          _selectedDifficulty = title;
        });
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        width: double.infinity,
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: isSelected ? accentColor.withOpacity(0.1) : Colors.white.withOpacity(0.05),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isSelected ? accentColor : Colors.white.withOpacity(0.1),
            width: isSelected ? 2 : 1,
          ),
          boxShadow: isSelected
              ? [
                  BoxShadow(
                    color: accentColor.withOpacity(0.3),
                    blurRadius: 12,
                    spreadRadius: 2,
                  )
                ]
              : [],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: GoogleFonts.orbitron(
                color: isSelected ? accentColor : Colors.white,
                fontSize: 18,
                fontWeight: FontWeight.bold,
                letterSpacing: 1.5,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              description,
              style: GoogleFonts.inter(
                color: Colors.white70,
                fontSize: 14,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFooter() {
    return Padding(
      padding: const EdgeInsets.all(24.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          if (_currentStep > 0)
            TextButton(
              onPressed: _previousStep,
              child: Text(
                'BACK',
                style: GoogleFonts.rajdhani(
                  color: Colors.white54,
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
            )
          else
            const SizedBox(width: 60),
            
          ElevatedButton(
            onPressed: _nextStep,
            style: ElevatedButton.styleFrom(
              backgroundColor: _currentStep == _totalSteps - 1 
                  ? const Color(0xFF7B2FFF) 
                  : const Color(0xFF00D4FF).withOpacity(0.2),
              foregroundColor: _currentStep == _totalSteps - 1 
                  ? Colors.white 
                  : const Color(0xFF00D4FF),
              side: BorderSide(
                color: _currentStep == _totalSteps - 1 
                    ? const Color(0xFF7B2FFF) 
                    : const Color(0xFF00D4FF),
              ),
              padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
              elevation: _currentStep == _totalSteps - 1 ? 8 : 0,
              shadowColor: const Color(0xFF7B2FFF).withOpacity(0.5),
            ),
            child: Text(
              _currentStep == _totalSteps - 1 ? 'BEGIN YOUR ASCENT' : 'NEXT',
              style: GoogleFonts.rajdhani(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                letterSpacing: 1.2,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
