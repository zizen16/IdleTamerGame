import 'dart:async';

import 'package:flutter/material.dart';
import 'package:idletamergame/loginsingleton.dart';
import 'package:idletamergame/models/creaturemodel.dart';
import 'package:idletamergame/models/login.dart';
import 'package:idletamergame/monstercatch.dart';
import 'package:idletamergame/monsterscreen.dart';

class Habitat extends StatefulWidget {
  const Habitat({super.key, required this.login});

  final Login login;

  @override
  State<Habitat> createState() => _HabitatState();
}

class _HabitatState extends State<Habitat> {
  Timer? _goldTimer;
  DateTime _lastGoldUpdate = DateTime.now();

  @override
  void initState() {
    super.initState();
    _lastGoldUpdate = DateTime.now();
    _goldTimer = Timer.periodic(const Duration(seconds: 1), (_) {
      final now = DateTime.now();
      final elapsed = now.difference(_lastGoldUpdate);
      _lastGoldUpdate = now;

      final earnedGold = widget.login.accrueIdleGold(elapsed);
      if (earnedGold > 0) {
        LoginSingleton().updateLogin(widget.login);
        LoginSingleton().saveLogin();
      }
      if (mounted) {
        setState(() {});
      }
    });
  }

  @override
  void dispose() {
    _goldTimer?.cancel();
    super.dispose();
  }

  Widget creatureCard(CreatureModel creatuerModelCard , int index) {
    return GestureDetector(
      onTap: () {
        print('tapped on ${creatuerModelCard.name}, index: $index');
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => MonsterScreen(creatureModel: creatuerModelCard)),
        );
      },
      child: Card(
        child: Container(
          width: 200,
          height: 250,
          padding: const EdgeInsets.all(8),
          margin: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: Colors.grey[300],
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: Colors.black, width: 3),
          ),
          child: LayoutBuilder(
            builder: (context, constraints) {
              final avatarRadius = (constraints.maxWidth * 0.2).clamp(0.1, 38.0);

              return Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  CircleAvatar(
                    radius: avatarRadius,
                    backgroundColor: Colors.green.shade200,
                    child: CircleAvatar(
                      radius: avatarRadius - 4,
                      backgroundImage: AssetImage(creatuerModelCard.avatar), // Replace with your image path
                    ),
                  ),
                  const SizedBox(height: 5),
                  Text(
                    creatuerModelCard.name,
                    textAlign: TextAlign.center,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  Text(
                    'Rarity: ${creatuerModelCard.rarity}',
                    textAlign: TextAlign.center,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              );
            },
          ),
        ),
      ),
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

  Widget LocationCard(String locationImage, String locationName){
    return GestureDetector(
      onTap: () async {
        print('tapped on location');
        await Navigator.push<void>(
          context,
          MaterialPageRoute<void>(builder: (context) => const CaptureScreen()),
        );
        if (!mounted) return;
        setState(() {});
      },
    child: Card(
      child: Container(
        width: 200,
        height: 250,
        child: Column(
        spacing: 20,
        mainAxisAlignment: .center,
        children: [
          CircleAvatar(
            radius: 40,
            backgroundImage: AssetImage(locationImage),
          ),
          Text(locationName)
        ],
      ),
      )
    )
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Dashboard')),
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
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(6),
          child: Column(
            children: [
              reusableInfoBox(child:
                Column(//widget column text
                  crossAxisAlignment: .start,
                  children: [
                    Text(
                      'Hello! ${widget.login.name ?? widget.login.email.split('@').first}',
                      style: const TextStyle(fontSize: 30, fontWeight: FontWeight.bold),
                    ),
                    Row(
                      spacing: 5,
                      mainAxisAlignment: .spaceBetween,
                      children: [
                        Text("Level ${widget.login.level ?? 1}",  style: TextStyle(fontSize: 18)),
                        Text("Tapping Power ${widget.login.power ?? 0}",  style: TextStyle(fontSize: 18)),
                      ],
                    ),
                    Row(
                      mainAxisAlignment: .spaceBetween,
                      children: [
                        Text("Monster Collected: ${widget.login.creatures.length}", style: TextStyle(fontSize: 18)),
                        Text("Gold: ${widget.login.gold ?? 0}", style: TextStyle(fontSize: 18)),
                      ],
                    ),
                    Text(
                      "Idle Income: +${widget.login.goldPerInterval} gold / 30 sec",
                      style: TextStyle(fontSize: 18),
                    ),
                    Text(
                      "Next payout in ${widget.login.secondsUntilGold}s",
                      style: TextStyle(fontSize: 16),
                    ),
                  ],
                ),
              ),
              reusableInfoBox(child: 
                Column(
                  mainAxisAlignment: .center,
                  children: [
                    const Text( 'Habitat', style: TextStyle(fontSize: 26, fontWeight: FontWeight.bold)),
                    const SizedBox(height: 20),
                    SizedBox(
                      height: 420,
                      child: GridView.count(
                        crossAxisCount: 2,
                        crossAxisSpacing: 3,
                        mainAxisSpacing: 3,
                        childAspectRatio: 0.78,
                        physics: const BouncingScrollPhysics(),
                        children: [
                          for (var creature in widget.login.creatures)
                            creatureCard(creature, widget.login.creatures.indexOf(creature)),
                        ],
                      ),
                    ),
                  ],
                )
              ),
              reusableInfoBox(child: 
                Column(
                  mainAxisAlignment: .center,
                  children: [
                    Text("Catch a Monster", style: TextStyle( fontSize: 26, fontWeight: .bold)),
                    SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      child: Row(
                      children: [
                        LocationCard("Plains.png", "Plains"),
                        LocationCard("Forest.png", "Forest"),
                        
                      ],
                    ),
                    )
                  ],
                )
              )
            ],
          ),
        ),
      ),
    );
  }
}