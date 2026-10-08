class CreatureModel {
  CreatureModel({
    required this.name, 
    required this.rarity, 
    required this.description, 
    required this.avatar,
    this.power,
    this.exp,
    this.level,
    this.goldGen,
    double? hunger,
  }) : hunger = hunger;
  
  final String name;
  final String rarity;
  final String description;
  final String avatar;

  final double? power;
  final double? exp;
  int? level;
  int? goldGen;
  static const Duration hungerDecayInterval = Duration(minutes: 1);

  double? hunger;
  Duration _elapsedHungerTime = Duration.zero;

  Duration? get timeUntilHungerDecay {
    if ((hunger ?? 0) <= 0) return null;
    return hungerDecayInterval - _elapsedHungerTime;
  }

  void advanceHunger(Duration elapsed) {
    if (elapsed.isNegative || (hunger ?? 0) <= 0) {
      if ((hunger ?? 0) <= 0) _elapsedHungerTime = Duration.zero;
      return;
    }

    _elapsedHungerTime += elapsed;
    final decayedPoints =
        _elapsedHungerTime.inMicroseconds ~/ hungerDecayInterval.inMicroseconds;
    if (decayedPoints == 0) return;

    hunger = ((hunger ?? 0) - decayedPoints)
      .clamp(0.0, double.infinity)
      .toDouble();
    _elapsedHungerTime -= hungerDecayInterval * decayedPoints;
    if ((hunger ?? 0) <= 0) _elapsedHungerTime = Duration.zero;
  }

  CreatureModel copy() => CreatureModel(
        name: name,
        rarity: rarity,
        description: description,
        avatar: avatar,
        power: power,
        exp: exp,
        level: level,
        goldGen: goldGen,
        hunger: hunger,
      );

  Map<String, dynamic> toJson() => {
        'name': name,
        'rarity': rarity,
        'description': description,
        'avatar': avatar,
        'power': power,
        'exp': exp,
        'level': level,
        'goldGen': goldGen,
        'hunger': hunger,
      };
}