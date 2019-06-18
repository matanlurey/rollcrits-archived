import 'package:angular/angular.dart';
import 'package:angular/meta.dart';
import 'package:angular_components/material_button/material_button.dart';
import 'package:rollcrits/widgets.dart';
import 'package:swlegion/holodeck.dart';
import 'package:swlegion/swlegion.dart';

@Component(
  selector: 'rc-app',
  directives: [
    MaterialButtonComponent,
    NgFor,
    NgIf,
    RCAttackDice,
    RCAttackSide,
    RCDefenseDice,
    RCDefenseSide,
  ],
  templateUrl: 'app.html',
  exports: [
    AttackDice,
  ],
  styleUrls: [
    'app.css',
  ],
)
class RCApp {
  final _holodeck = Holodeck();
  final _iterations = 10000;

  @visibleForTemplate
  var attackDice = <AttackDice>[];

  @visibleForTemplate
  var attackSurge = AttackDiceSide.surge;

  @visibleForTemplate
  void addAttackDice(AttackDice color) {
    attackDice = ([...attackDice, color]..sort()).reversed.toList();
  }

  @visibleForTemplate
  void resetAttackDice() {
    attackDice = [];
    attackSurge = AttackDiceSide.surge;
    _resetResults();
  }

  @visibleForTemplate
  void toggleAttackSurge() {
    switch (attackSurge) {
      case AttackDiceSide.surge:
        attackSurge = AttackDiceSide.hit;
        break;
      case AttackDiceSide.hit:
        attackSurge = AttackDiceSide.criticalHit;
        break;
      default:
        attackSurge = AttackDiceSide.surge;
        break;
    }
  }

  @visibleForTemplate
  var defenseDice = DefenseDice.white;

  @visibleForTemplate
  var defenseSurge = DefenseDiceSide.surge;

  @visibleForTemplate
  void toggleDefenseDice() {
    if (defenseDice == DefenseDice.white) {
      defenseDice = DefenseDice.red;
    } else {
      defenseDice = DefenseDice.white;
    }
  }

  @visibleForTemplate
  void resetDefenseDice() {
    defenseSurge = DefenseDiceSide.surge;
    defenseDice = DefenseDice.white;
    _resetResults();
  }

  @visibleForTemplate
  void toggleDefenseSurge() {
    switch (defenseSurge) {
      case DefenseDiceSide.surge:
        defenseSurge = DefenseDiceSide.block;
        break;
      default:
        defenseSurge = DefenseDiceSide.surge;
        break;
    }
  }

  static const _attackToSurge = {
    AttackDiceSide.surge: null,
    AttackDiceSide.hit: AttackSurge.hit,
    AttackDiceSide.criticalHit: AttackSurge.critical,
  };

  @visibleForTemplate
  num averageHits;

  @visibleForTemplate
  num averageBlocks;

  @visibleForTemplate
  num averageWounds;

  @visibleForTemplate
  static String formatResults(num result) {
    return result.toStringAsPrecision(2);
  }

  void _resetResults() {
    averageHits = averageBlocks = averageWounds = null;
  }

  @visibleForTemplate
  bool get resultsCalculated => averageHits != null;

  @visibleForTemplate
  void calculateResults() {
    var sumTotalHits = 0;
    var sumTotalBlocks = 0;
    var sumTotalWounds = 0;

    for (var i = 0; i < _iterations; i++) {
      final attack = _holodeck.rollAttacks(
        attackDice,
        _attackToSurge[attackSurge],
      );
      sumTotalHits += attack.totalHits;

      final defense = _holodeck.rollDefenses(
        defenseDice,
        attack.totalHits,
        surge: defenseSurge == DefenseDiceSide.block,
      );
      sumTotalBlocks += defense.blocks;
      sumTotalWounds += (attack.totalHits - defense.blocks);
    }

    averageHits = sumTotalHits / _iterations;
    averageBlocks = sumTotalBlocks / _iterations;
    averageWounds = sumTotalWounds / _iterations;
  }
}
