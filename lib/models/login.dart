import 'package:idletamergame/models/creaturemodel.dart';

class Login {
  Login({
    required this.email,
    required this.password,
    this.name,
    this.level,
    this.power,
    this.gold,
    List<CreatureModel>? creatures,
  }) : creatures = creatures ?? <CreatureModel>[];

  final String email;
  final String password;
  final String? name;
  final int? level;
  final int? power;
  int? gold;
  final List<CreatureModel> creatures;
  static const Duration goldGenerationInterval = Duration(seconds: 30);
  Duration _elapsedGoldTime = Duration.zero;
  //final CreatureModel creatures;

  int get goldPerInterval => creatures.fold<int>(0, (total, creature) {
        if ((creature.hunger ?? 0) <= 0) return total;
        return total + (creature.goldGen ?? 0);
      });

  int get secondsUntilGold =>
      (goldGenerationInterval.inSeconds - _elapsedGoldTime.inSeconds)
          .clamp(1, goldGenerationInterval.inSeconds)
          .toInt();

  Map<String, dynamic> toJson() => {
        'email': email,
        'password': password,
        'name': name,
        'level': level ?? 1,
        'power': power ?? 0,
        'gold': gold ?? 0,
        'creatures': creatures.map((creature) => creature.toJson()).toList(),
      };

  int accrueIdleGold(Duration elapsed) {
    if (elapsed.isNegative) return 0;

    var remaining = elapsed;
    var earnedGold = 0;

    while (remaining > Duration.zero) {
      final income = goldPerInterval;
      final nextHungerDecay = creatures
          .map((creature) => creature.timeUntilHungerDecay)
          .whereType<Duration>()
          .fold<Duration?>(null, (soonest, decay) {
        if (soonest == null || decay < soonest) return decay;
        return soonest;
      });
      final nextGoldPayout = income > 0
          ? goldGenerationInterval - _elapsedGoldTime
          : null;

      var step = remaining;
      if (nextHungerDecay != null && nextHungerDecay < step) {
        step = nextHungerDecay;
      }
      if (nextGoldPayout != null && nextGoldPayout < step) {
        step = nextGoldPayout;
      }

      for (final creature in creatures) {
        creature.advanceHunger(step);
      }
      remaining -= step;

      if (income > 0) {
        _elapsedGoldTime += step;
      } else {
        _elapsedGoldTime = Duration.zero;
      }

      if (goldPerInterval == 0) {
        _elapsedGoldTime = Duration.zero;
      } else if (_elapsedGoldTime >= goldGenerationInterval) {
        final payout = goldPerInterval;
        earnedGold += payout;
        gold = (gold ?? 0) + payout;
        _elapsedGoldTime -= goldGenerationInterval;
      }
    }

    return earnedGold;
  }
}