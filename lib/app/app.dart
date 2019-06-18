import 'dart:math';

import 'package:angular/angular.dart';
import 'package:angular/meta.dart';
import 'package:angular_components/material_button/material_button.dart';
import 'package:angular_components/material_input/material_input.dart';
import 'package:angular_components/material_input/material_number_accessor.dart';
import 'package:angular_components/material_radio/material_radio.dart';
import 'package:angular_components/material_radio/material_radio_group.dart';
import 'package:rollcrits/widgets.dart';
import 'package:swlegion/holodeck.dart';
import 'package:swlegion/swlegion.dart';

@Component(
  selector: 'rc-app',
  directives: [
    MaterialButtonComponent,
    MaterialInputComponent,
    MaterialRadioComponent,
    MaterialRadioGroupComponent,
    NgFor,
    NgIf,
    NgModel,
    RCAttackDice,
    RCAttackSide,
    RCDefenseDice,
    RCDefenseSide,
    materialNumberInputDirectives,
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
  final _iterations = 20000;

  @visibleForTemplate
  var attackDice = <AttackDice>[];

  @visibleForTemplate
  var attackSurge = AttackDiceSide.surge;

  @visibleForTemplate
  var pierce = 0;

  @visibleForTemplate
  void addAttackDice(AttackDice color) {
    attackDice = ([...attackDice, color]..sort()).reversed.toList();
  }

  @visibleForTemplate
  void resetAttackDice() {
    attackDice = [];
    attackSurge = AttackDiceSide.surge;
    pierce = 0;
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
  var cover = 0;

  @visibleForTemplate
  void setCover(int amount, bool ifTrue) {
    if (ifTrue) {
      cover = amount;
    }
  }

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
    cover = 0;
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
  num averageCrits;

  @visibleForTemplate
  num averageBlocks;

  @visibleForTemplate
  num averageWounds;

  @visibleForTemplate
  static String formatResults(num result) {
    return result.toStringAsFixed(2);
  }

  void _resetResults() {
    averageHits = averageCrits = averageBlocks = averageWounds = null;
  }

  @visibleForTemplate
  bool get resultsCalculated => averageHits != null;

  @visibleForTemplate
  void calculateResults() {
    var sumTotalHits = 0;
    var sumTotalCrits = 0;
    var sumTotalBlocks = 0;
    var sumTotalWounds = 0;

    for (var i = 0; i < _iterations; i++) {
      final attack = _holodeck.rollAttacks(
        attackDice,
        _attackToSurge[attackSurge],
      );

      final hits = attack.hits.length;
      final crits = attack.crits.length;
      sumTotalHits += hits;
      sumTotalCrits += crits;

      final success = max(0, hits - cover) + crits;
      final defense = _holodeck.rollDefenses(
        defenseDice,
        success,
        surge: defenseSurge == DefenseDiceSide.block,
      );

      final blocks = defense.blocks;
      sumTotalBlocks += blocks;

      final wounds = success - max<int>(0, blocks - pierce);
      sumTotalWounds += wounds;
    }

    averageHits = sumTotalHits / _iterations;
    averageCrits = sumTotalCrits / _iterations;
    averageBlocks = sumTotalBlocks / _iterations;
    averageWounds = sumTotalWounds / _iterations;
  }
}
