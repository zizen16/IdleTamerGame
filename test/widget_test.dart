// This is a basic Flutter widget test.
//
// To perform an interaction with a widget in your test, use the WidgetTester
// utility in the flutter_test package. For example, you can send tap and scroll
// gestures. You can also use WidgetTester to find child widgets in the widget
// tree, read text, and verify that the values of widget properties are correct.

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:idletamergame/loginsingleton.dart';
import 'package:idletamergame/models/creaturemodel.dart';
import 'package:idletamergame/models/login.dart';
import 'package:idletamergame/monstercatch.dart';
import 'package:idletamergame/monsterslib.dart';

void main() {
  test('idle gold is paid in integer amounts every 30 seconds', () {
    final login = Login(
      email: 'player@example.com',
      password: 'secret',
      gold: 4,
      creatures: [
        CreatureModel(
          name: 'Mossling',
          rarity: 'Common',
          description: 'A small forest creature',
          avatar: 'assets/Slime.png',
          goldGen: 2,
          hunger: 10,
        ),
        CreatureModel(
          name: 'Ember',
          rarity: 'Rare',
          description: 'A tiny fire spirit',
          avatar: 'assets/Ember.png',
          goldGen: 1,
          hunger: 10,
        ),
      ],
    );

    expect(login.goldPerInterval, 3);
    expect(login.accrueIdleGold(const Duration(seconds: 29)), 0);
    expect(login.gold, 4);
    expect(login.secondsUntilGold, 1);
    expect(login.accrueIdleGold(const Duration(seconds: 1)), 3);
    expect(login.gold, 7);
    expect(login.accrueIdleGold(const Duration(seconds: 65)), 6);
    expect(login.gold, 13);
    expect(login.secondsUntilGold, 25);
  });

  test('idle gold stops when creatures run out of hunger', () {
    final creature = CreatureModel(
      name: 'Mossling',
      rarity: 'Common',
      description: 'A small forest creature',
      avatar: 'assets/Slime.png',
      goldGen: 2,
      hunger: 1,
    );
    final login = Login(
      email: 'player@example.com',
      password: 'secret',
      creatures: [creature],
    );

    expect(login.accrueIdleGold(const Duration(minutes: 1)), 2);
    expect(login.gold, 2);
    expect(creature.hunger, 0);
    expect(login.goldPerInterval, 0);
    expect(login.accrueIdleGold(const Duration(minutes: 1)), 0);
  });

  test('creature hunger decreases once per elapsed minute', () {
    final creature = CreatureModel(
      name: 'Mossling',
      rarity: 'Common',
      description: 'A small forest creature',
      avatar: 'assets/Slime.png',
      hunger: 2,
    );

    creature.advanceHunger(const Duration(seconds: 59));
    expect(creature.hunger, 2);
    creature.advanceHunger(const Duration(seconds: 1));
    expect(creature.hunger, 1);
    creature.advanceHunger(const Duration(minutes: 1));
    expect(creature.hunger, 0);
  });

  test('creature stats increase with rarity', () {
    final creatures = MonsterLib().creatures;
    final common = creatures.firstWhere((creature) => creature.rarity == 'Common');
    final rare = creatures.firstWhere((creature) => creature.rarity == 'Rare');
    final epic = creatures.firstWhere((creature) => creature.rarity == 'Epic');

    expect(common.power, lessThan(rare.power!));
    expect(rare.power, lessThan(epic.power!));
    expect(common.exp, lessThan(rare.exp!));
    expect(rare.exp, lessThan(epic.exp!));
    expect(common.goldGen, lessThan(rare.goldGen!));
    expect(rare.goldGen, lessThan(epic.goldGen!));
  });

  test('login singleton adds a creature to the active login', () {
    final login = Login(email: 'player@example.com', password: 'secret');
    final creature = CreatureModel(
      name: 'Mossling',
      rarity: 'common',
      description: 'A small forest creature',
      avatar: 'assets/Slime.png',
    );
    final singleton = LoginSingleton()..setLogin(login);

    singleton.addCreature(creature);

    expect(singleton.getLogin().creatures, contains(creature));
  });

  test('login data includes monsters, currency, and profile fields', () {
    final creature = CreatureModel(
      name: 'Mossling',
      rarity: 'Common',
      description: 'A small forest creature',
      avatar: 'assets/Slime.png',
      power: 10,
      exp: 20,
      level: 3,
      goldGen: 5,
      hunger: 80,
    );
    final login = Login(
      email: 'player@example.com',
      password: 'secret',
      name: 'Player',
      level: 4,
      power: 25,
      gold: 150,
      creatures: [creature],
    );

    expect(login.toJson(), {
      'email': 'player@example.com',
      'password': 'secret',
      'name': 'Player',
      'level': 4,
      'power': 25,
      'gold': 150,
      'creatures': [
        {
          'name': 'Mossling',
          'rarity': 'Common',
          'description': 'A small forest creature',
          'avatar': 'assets/Slime.png',
          'power': 10,
          'exp': 20,
          'level': 3,
          'goldGen': 5,
          'hunger': 80.0,
        },
      ],
    });
  });

  testWidgets('capture progress rises on rapid taps and declines when idle', (WidgetTester tester) async {
    await tester.pumpWidget(const MaterialApp(home: CaptureScreen()));
    await tester.pump(const Duration(seconds: 5));

    final avatarFinder = find.byKey(const ValueKey('capture_avatar'));
    expect(avatarFinder, findsOneWidget);

    final progressBeforeTap = tester.widget<LinearProgressIndicator>(find.byType(LinearProgressIndicator)).value;
    expect(progressBeforeTap, 0.0);

    await tester.tap(avatarFinder);
    await tester.pump();

    final progressAfterTap = tester.widget<LinearProgressIndicator>(find.byType(LinearProgressIndicator)).value;
    expect(progressAfterTap, greaterThan(0.0));

    await tester.pump(const Duration(milliseconds: 800));
    final progressAfterDecay = tester.widget<LinearProgressIndicator>(find.byType(LinearProgressIndicator)).value;
    expect(progressAfterDecay, lessThan(progressAfterTap as Object));
  });
}
