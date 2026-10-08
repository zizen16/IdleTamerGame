import 'dart:async';
import 'package:flutter/material.dart';

import 'package:idletamergame/loginsingleton.dart';
import 'package:idletamergame/models/creaturemodel.dart';

class MonsterScreen extends StatefulWidget {
  const new({super.key, required this.creatureModel}); //, required this.creatureModel

  final CreatureModel creatureModel;
  @override
  
  State<MonsterScreen> createState() => _MonsterScreenState();
}

class _MonsterScreenState extends State<MonsterScreen> {
  Timer? _refreshTimer;

  @override
  void initState() {
    super.initState();
    _refreshTimer = Timer.periodic(const Duration(seconds: 1), (_) {
      if (mounted) setState(() {});
    });
  }

  @override
  void dispose() {
    _refreshTimer?.cancel();
    super.dispose();
  }
  
  Widget monsterProfileStat() {
    final double experience = widget.creatureModel.exp ?? 0;
    final double hunger = widget.creatureModel.hunger ?? 0;
    final int income = hunger > 0 ? widget.creatureModel.goldGen ?? 0 : 0;

    return reusableInfoBox(child: 
       Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Profile Stats',
            style: TextStyle(
              fontSize: 30,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 14),
            
          _buildStatRow(
            'Experience Points',

            (experience / 100).clamp(0.0, 1.0).toDouble(),
            '${experience.toStringAsFixed(0)}/100 XP',
            Colors.purple,
          ),
          const SizedBox(height: 10),
          _buildStatRow(
            'Hunger',
            (hunger / 100).clamp(0.0, 1.0).toDouble(),
            '${hunger.toStringAsFixed(0)}%',
            Colors.orange,
          ),
          const SizedBox(height: 10),
          _buildStatRow(
            'Income Generation',
            (income / 100).clamp(0.0, 1.0).toDouble(),
            '+$income gold/hr',
            Colors.green,
          ),
        ],
      ),  
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
              style: const TextStyle(fontSize: 18,),
            ),
            Text(
              valueText,
              style: const TextStyle(fontSize: 14,),
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

  Widget reusableInfoBox({
    required Widget child,
    double radius = 15,
    Color color = const Color.fromARGB(255, 98, 251, 149),
  }) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(15),
      margin: const EdgeInsets.all(15),
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(radius),
      ),
      child: child,
    );
  }

  buildColumnMonsterData(String name, String rarity, String description) =>
  Column(
    crossAxisAlignment: .end,
    children: [
      Text(name,style: TextStyle(fontSize: 25, fontWeight: .bold),),
      const SizedBox(height: 10,),
      Text(rarity,style: TextStyle(fontSize: 15),),
      Text(description,style: TextStyle(fontSize: 15),),
    ],
  );

   buildButton(onPressed, labelText, Color color) =>
  Padding(padding: const EdgeInsets.all(8),
  child:
  ElevatedButton(
    onPressed: onPressed,
    style: ElevatedButton.styleFrom(
      backgroundColor: color,
      foregroundColor: Colors.white,

    ),
    child: Text(labelText,style: TextStyle(fontSize: 18),),
  )
  );

  void FeedCreature() {
    final hunger = widget.creatureModel.hunger ?? 0;
    if (hunger >= 100 || !_spendGold(10)) return;

    setState(() {
      widget.creatureModel.hunger = (hunger + 5).clamp(0.0, 100.0).toDouble();
    });
    LoginSingleton().saveLogin();
  }

  void LevelUpCreature() {
    if (!_spendGold(25)) return;

    setState(() {
      widget.creatureModel.level = (widget.creatureModel.level ?? 1) + 1;
      widget.creatureModel.goldGen = (widget.creatureModel.goldGen ?? 0) + 1;
    });
    LoginSingleton().saveLogin();
  }

  bool _spendGold(int amount) {
    final login = LoginSingleton().getLogin();
    final balance = login.gold ?? 0;
    if (balance < amount) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Not enough gold')),
      );
      return false;
    }

    login.gold = balance - amount;
    return true;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Monster Name"),),
      body: Container(
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
        padding: const EdgeInsets.all(6),
        child: Column(
          children: [
            reusableInfoBox(child: 
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,

                children: [
                  CircleAvatar(
                    radius: 50,
                    backgroundImage: AssetImage(widget.creatureModel.avatar),
                  ),
                  Column(
                    children: [
                      buildColumnMonsterData(widget.creatureModel.name, "Rarity: ${widget.creatureModel.rarity}", widget.creatureModel.description)
                    ],
                  )
                ],
              ),
            ),
            monsterProfileStat(),
            Column(
              //buttons row
              children: [
                Row(
                  mainAxisAlignment: .center,
                  children: [
                    buildButton(FeedCreature, "Feed (10 gold)", Colors.black),
                    buildButton(LevelUpCreature, "Level (25 gold)", Colors.black),

                  ],
                ),
                SizedBox(height: 15,),
                buildButton(() async {
                  final login = LoginSingleton().getLogin();
                  login.creatures.remove(widget.creatureModel);
                  await LoginSingleton().saveLogin();
                  if (!mounted) return;
                  Navigator.pop(context);
                },"Release", Colors.red)
              ],
            )
          ],
        ),
      ),
    );
  }
}