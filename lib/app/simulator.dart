import 'dart:math' as math;

import 'package:meta/meta.dart';
import 'package:swlegion/swlegion.dart';
import 'package:swlegion_simulator/swlegion_simulator.dart' as swlegion;

class Simulator {
  final swlegion.Simulator _simulator;

  const Simulator(this._simulator);

  Results simulate(Simulation simulation) {
    var attack = _simulator.rollAttack(
      dice: simulation.attack,
      surgeTo: simulation.attackSurge,
      surgeTokens: simulation.attackSurgeTokens,
      criticalX: simulation.criticalX,
    );
    var aimTokens = simulation.aimTokens;

    while (aimTokens > 0) {
      attack = _simulator.rerollAttack(
        attack,
        aimTokens: simulation.aimTokens,
        preciseX: simulation.precise,
        surgeTo: simulation.attackSurge,
        preferCrits: simulation.reRollForCrits,
      );
      aimTokens--;
    }

    final hits = attack.hitsRolled.length;
    final crits = attack.critsRolled.length;
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
    final defense = _simulator.rollDefense(
      dice: List.filled(
        success + (simulation.impervious ? simulation.pierce : 0),
        simulation.defense,
      ),
      hasDefenseSurge: simulation.defenseSurge,
      surgeTokens: simulation.defensiveSurgeTokens,
    );
    final blocks = defense.blocksRolled.length;
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

  /// Tokens to convert surge to hit (or crit if [criticalX]).
  final int attackSurgeTokens;

  /// Convert X surge to crits for the attack pool.
  final int criticalX;

  /// How much pierce may be in the pool.
  final int pierce;

  /// What [DefenseDice] the defending unit will utilize.
  final DefenseDice defense;

  /// Whether the defending unit surges to block.
  final bool defenseSurge;

  /// How much static defenses are available.
  final int coverOrDodgeOrGuardian;

  /// Tokens to convert surge to block.
  final int defensiveSurgeTokens;

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
    @required this.criticalX,
    @required this.attackSurgeTokens,
    @required this.pierce,
    @required this.defense,
    @required this.defenseSurge,
    @required this.coverOrDodgeOrGuardian,
    @required this.defensiveSurgeTokens,
    @required this.armor,
    @required this.impact,
    @required this.impervious,
    @required this.reRollForCrits,
  });
}

class Results {
  final swlegion.AttackResult attack;
  final swlegion.DefenseResult defense;

  /// Total number of wound results after.
  final int wounds;

  const Results({
    @required this.attack,
    @required this.defense,
    @required this.wounds,
  });

  /// Total number of "hit" results.
  int get hits => attack.hitsRolled.length;

  /// Total number of "crit" results.
  int get crits => attack.critsRolled.length;

  /// Total number of "block" results.
  int get blocks => defense.blocksRolled.length;

  /// Total number of defensive dice rolled.
  int get savesAttempted => defense.blocksRolled.length + defense.blanksRolled.length;
}
