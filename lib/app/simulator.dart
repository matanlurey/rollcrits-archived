import 'dart:math' as math;

import 'package:meta/meta.dart';
import 'package:swlegion/holodeck.dart';
import 'package:swlegion/swlegion.dart';

class Simulator {
  final Holodeck _holodeck;

  const Simulator(this._holodeck);

  Results simulate(Simulation simulation) {
    var attack = _holodeck.rollAttacks(
      simulation.attack,
      simulation.attackSurge,
    );
    var aimTokens = simulation.aimTokens;

    while (aimTokens > 0) {
      attack = _holodeck.rerollAttack(
        attack,
        surge: simulation.attackSurge,
        rerollForCrits: simulation.reRollForCrits ? attack.hits.length : 0,
        maxDice: 2 + simulation.precise,
      );
      aimTokens--;
    }

    final hits = attack.hits.length;
    final crits = attack.crits.length;
    var notCancelled = math.max(0, hits - simulation.coverOrDodgeOrGuardian);
    if (simulation.armor >= 5) {
      // Unlimited armor: Only impact hits are counted.
      final impactHits = math.min(notCancelled, simulation.impact);
      notCancelled = impactHits;
    } else if (simulation.armor > 0) {
      // Limited armor: First, impact hits are counted.
      final impactHits = math.min(notCancelled, simulation.impact);
      final nonImpactHits = notCancelled - impactHits;

      // Then hits that overwhelm armor are counted.
      final overwhelmed = math.max(0, nonImpactHits - simulation.armor);

      // Combine both numbers. The rest are cancelled.
      notCancelled = impactHits + overwhelmed;
    }
    final success = notCancelled + crits;
    final defense = _holodeck.rollDefenses(
      simulation.defense,
      success + (simulation.impervious ? simulation.pierce : 0),
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

  /// How many aim tokens the attacker hase.
  final int aimTokens;

  /// Precise.
  final int precise;

  /// What the unit or weapon's surge should convert to.
  final AttackSurge attackSurge;

  /// How much pierce may be in the pool.
  final int pierce;

  /// What [DefenseDice] the defending unit will utilize.
  final DefenseDice defense;

  /// Whether the defending unit surges to block.
  final bool defenseSurge;

  /// How much static defenses are available.
  final int coverOrDodgeOrGuardian;

  /// How much armor is available.
  ///
  /// **NOTE**: A value of at least `5` is considered unlimited.
  final int armor;

  /// How much impact is in the pool.
  final int impact;

  /// Whether the defending unit has impervious to pierce.
  final bool impervious;

  /// Whether to re-roll hits as crits.
  final bool reRollForCrits;

  const Simulation({
    @required this.aimTokens,
    @required this.precise,
    @required this.attack,
    @required this.attackSurge,
    @required this.pierce,
    @required this.defense,
    @required this.defenseSurge,
    @required this.coverOrDodgeOrGuardian,
    @required this.armor,
    @required this.impact,
    @required this.impervious,
    @required this.reRollForCrits,
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
