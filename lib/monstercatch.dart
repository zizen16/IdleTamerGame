import 'dart:async';

import 'package:flutter/material.dart';
import 'package:idletamergame/loginsingleton.dart';
import 'package:idletamergame/models/creaturemodel.dart';
import 'package:idletamergame/monsterslib.dart';

class CaptureScreen extends StatefulWidget {
  const CaptureScreen({super.key});

  @override
  State<CaptureScreen> createState() => _CaptureScreenState();
}

class _CaptureScreenState extends State<CaptureScreen> {
  bool _isWaiting = true;
  double _captureProgress = 0.0;
  double _tapPower = 5; // power of user
  double _monsterPower = 10; // power of monster impacts decay
  DateTime? _lastTapTime;
  Timer? _decayTimer;
  CreatureModel? creature;

  @override
  void initState() {
    super.initState();
    Timer(const Duration(seconds: 3), () {
      if (!mounted) return;

      setState(() {
        _isWaiting = false;
        MonsterLib().CreatureAppear();//call everytime when capturing to set creature
        creature = MonsterLib().getCreature();
      });

      _startDecayTimer();
    });
  }

  @override
  void dispose() {
    _decayTimer?.cancel();
    super.dispose();
  }

  bool get _isCaptured => _captureProgress >= 1.0;

  void _startDecayTimer() {
    _decayTimer?.cancel();
    _decayTimer = Timer.periodic(const Duration(milliseconds: 200), (_) {
      if (_isWaiting || !mounted || _isCaptured) return;

      final now = DateTime.now();
      final idleTime = _lastTapTime == null ? 0 : now.difference(_lastTapTime!).inMilliseconds;
      final baseDecay = 0.02 + (_monsterPower * 0.018);
      final activeDecay = idleTime < 350 ? baseDecay * 0.6 : baseDecay;

      if (_captureProgress > 0) {
        setState(() {
          _captureProgress = (_captureProgress - activeDecay).clamp(0.0, 1.0);
        });
      }
    });
  }

  double _effectiveTapPower() {
    final bonus = _tapPower / _monsterPower;
    return 0.12 + (bonus * 0.12);
  }

  void _handleCaptureTap() {
    if (_isWaiting || _isCaptured) return;

    _lastTapTime = DateTime.now();

    final tapGain = _effectiveTapPower();

    setState(() {
      _captureProgress = (_captureProgress + tapGain).clamp(0.0, 1.0);
    });

    if (_isCaptured) {
      _showCaptureDialog();
    }
  }

  void _showCaptureDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => AlertDialog(
        title: const Text('Monster Captured!'),
        content: const Text('You caught the monster successfully!'),
        actions: [
          TextButton(
            onPressed: () async {
              LoginSingleton().addCreature(creature!);
              await LoginSingleton().saveLogin();
              if (!context.mounted) return;
              Navigator.of(context).pop();
            },
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }

  Widget buildColumnMonsterData(String name, String rarity, String description) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text(
          name,
          style: const TextStyle(fontSize: 25, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 10),
        Text(rarity, style: const TextStyle(fontSize: 15)),
        Text(description, style: const TextStyle(fontSize: 15)),
      ],
    );
  }

  Widget _buildStatRow(String label, double progress, String valueText, Color barColor) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              label,
              style: const TextStyle(fontSize: 18),
            ),
            Text(
              valueText,
              style: const TextStyle(fontSize: 14),
            ),
          ],
        ),
        const SizedBox(height: 6),
        ClipRRect(
          borderRadius: BorderRadius.circular(8),
          child: LinearProgressIndicator(
            value: progress,
            minHeight: 10,
            backgroundColor: const Color.fromARGB(255, 69, 68, 68),
            valueColor: AlwaysStoppedAnimation<Color>(barColor),
          ),
        ),
      ],
    );
  }

  Widget _buildWaitingScreen() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const CircularProgressIndicator(),
          const SizedBox(height: 20),
          const Text(
            'Searching for a creature...',
            style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          Text(
            'Preparing capture area...',
            style: TextStyle(fontSize: 16, color: Colors.grey[800]),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Capture Area"),
      ),
      body: Container(
        width: double.infinity,
        height: double.infinity,
        padding: const EdgeInsets.all(10),
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Color(0xFFFFFFFF),
              Color(0xFF4CFF2D),
            ],
          ),
        ),
        child: _isWaiting
            ? _buildWaitingScreen()
            : Column(
                spacing: 15,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  GestureDetector(
                    key: const ValueKey('capture_avatar'),
                    onTap: _handleCaptureTap,
                    child: CircleAvatar(
                      radius: 150,
                      backgroundImage: AssetImage(MonsterLib().getCreature().avatar),//monster pic
                    ),
                  ),
                  buildColumnMonsterData(MonsterLib().getCreature().name, MonsterLib().getCreature().rarity, MonsterLib().getCreature().description),
                  _buildStatRow(
                    'Capture',
                    _captureProgress,
                    '${(_captureProgress * 100).round()}%',
                    Colors.purple,
                  ),
                  Text(
                    'Tap Power: ${_effectiveTapPower().toStringAsFixed(2)}',
                    style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                  Text(
                    'Monster Power: ${_monsterPower.toStringAsFixed(1)}x',
                    style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                  Text(
                    _isCaptured
                        ? 'Captured!'
                        : 'Tap the creature rapidly to capture!',
                    style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                ],
              ),
      ),
    );
  }
}