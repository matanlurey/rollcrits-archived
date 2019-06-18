import 'dart:math' as math;

import 'package:meta/meta.dart';
import 'package:swlegion/holodeck.dart';
import 'package:swlegion/swlegion.dart';

class Simulator {
  final Holodeck _holodeck;

  const Simulator(this._holodeck);

  Results simulate(Simulation simulation) {
    final attack = _holodeck.rollAttacks(
      simulation.attack,
      simulation.attackSurge,
    );
    final hits = attack.hits.length;
    final crits = attack.crits.length;
    final success = math.max(0, hits - simulation.cover) + crits;
    final defense = _holodeck.rollDefenses(
      simulation.defense,
      success,
      surge: simulation.defenseSurge,
    );
    final blocks = defense.blocks;
    final wounds = success - math.max<int>(0, blocks - simulation.pierce);
    return Results(
      attack: attack,
      defense: defense,
      wounds: wounds,
    );
  }
}

class Simulation {
  /// What [AttackDice] will be present in the attack pool.
  final List<AttackDice> attack;

  /// What the unit or weapon's surge should convert to.
  final AttackSurge attackSurge;

  /// How much pierce may be in the pool.
  final int pierce;

  /// What [DefenseDice] the defending unit will utilize.
  final DefenseDice defense;

  /// Whether the defending unit surges to block.
  final bool defenseSurge;

  /// How much static cover is available.
  final int cover;

  const Simulation({
    @required this.attack,
    @required this.attackSurge,
    @required this.pierce,
    @required this.defense,
    @required this.defenseSurge,
    @required this.cover,
  });
}

class Results {
  final Attack attack;
  final Defense defense;

  /// Total number of wound results after.
  final int wounds;

  const Results({
    @required this.attack,
    @required this.defense,
    @required this.wounds,
  });

  /// Total number of "hit" results.
  int get hits => attack.hits.length;

  /// Total number of "crit" results.
  int get crits => attack.crits.length;

  /// Total number of "block" results.
  int get blocks => defense.blocks;
}
