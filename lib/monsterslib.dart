import 'dart:math';

import 'package:idletamergame/models/creaturemodel.dart';

class MonsterLib{
  MonsterLib._internal();

  static final MonsterLib _instance = MonsterLib._internal();

  factory MonsterLib(){
    return _instance;
  }

  final List<CreatureModel> creatures = [
    CreatureModel(name: 'Slime', rarity: 'Common', description: 'A friendly forest creature', avatar:'assets/Slime.png', power: 1, exp: 0, level: 1, goldGen: 1, hunger: 1),
    CreatureModel(name: 'Ember', rarity: 'Rare', description: 'A tiny fire spirit', avatar:'assets/Ember.png', power: 3, exp: 0, level: 1, goldGen: 5, hunger: 2),
    CreatureModel(name: 'Crystal', rarity: 'Epic', description: 'A curious crystal creature', avatar:'assets/Crystal.png', power: 6, exp: 0, level: 10, goldGen: 6, hunger: 3),
    CreatureModel(name: 'Blip', rarity: 'Common', description: 'A playful helper', avatar:'assets/Blip.png', power: 1, exp: 0, level: 1, goldGen: 1, hunger: 1),
  ];

  var creature;

  void CreatureAppear()
  {
    final int randomIndex=Random().nextInt(creatures.length);
    final randomCreature = creatures[randomIndex];
    creature = randomCreature.copy();
    print('A wild ${creature.name} has appeared!');
  }

  CreatureModel getCreature()=> creature;
}