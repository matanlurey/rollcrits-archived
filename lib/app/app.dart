import 'package:angular/angular.dart';
import 'package:angular/meta.dart';
import 'package:angular_components/laminate/popup/module.dart';
import 'package:angular_components/material_button/material_button.dart';
import 'package:angular_components/material_checkbox/material_checkbox.dart';
import 'package:angular_components/material_input/material_input.dart';
import 'package:angular_components/material_input/material_number_accessor.dart';
import 'package:angular_components/material_radio/material_radio.dart';
import 'package:angular_components/material_radio/material_radio_group.dart';
import 'package:angular_components/material_select/material_dropdown_select.dart';
import 'package:angular_modern_charts/angular_modern_charts.dart';
import 'package:rollcrits/widgets.dart';
import 'package:swlegion/holodeck.dart';
import 'package:swlegion/swlegion.dart';

import 'simulator.dart';

@Component(
  selector: 'rc-app',
  directives: [
    BarChartComponent,
    MaterialButtonComponent,
    MaterialCheckboxComponent,
    MaterialDropdownSelectComponent,
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
  providers: [
    popupBindings,
  ],
  exports: [
    AttackDice,
  ],
  styleUrls: [
    'app.css',
  ],
)
class RCApp {
  static final _simulator = Simulator(Holodeck());
  static final _iterations = 20000;

  @visibleForTemplate
  var attackDice = <AttackDice>[];

  @visibleForTemplate
  var attackSurge = AttackDiceSide.surge;

  @visibleForTemplate
  var pierce = 0;

  @visibleForTemplate
  void setPierce(int amount) {
    pierce = amount;
    calculateResults();
  }

  @visibleForTemplate
  var impact = 0;

  @visibleForTemplate
  void setImpact(int amount) {
    impact = amount;
    calculateResults();
  }

  @visibleForTemplate
  var aimTokens = 0;

  @visibleForTemplate
  void setAimTokens(int amount) {
    aimTokens = amount;
    calculateResults();
  }

  @visibleForTemplate
  var precise = 0;

  @visibleForTemplate
  void setPrecise(int amount) {
    precise = amount;
    calculateResults();
  }

  @visibleForTemplate
  var reRollForCrits = false;

  @visibleForTemplate
  void setReRollForCrits(bool value) {
    reRollForCrits = value;
    calculateResults();
  }

  @visibleForTemplate
  var criticalX = 0;

  @visibleForTemplate
  void setCriticalX(int amount) {
    criticalX = amount;
    calculateResults();
  }

  @visibleForTemplate
  var surgeTokens = 0;

  @visibleForTemplate
  void setSurgeTokens(int amount) {
    surgeTokens = amount;
    calculateResults();
  }

  @visibleForTemplate
  void addAttackDice(AttackDice color) {
    attackDice = ([...attackDice, color]..sort()).reversed.toList();
    calculateResults();
  }

  @visibleForTemplate
  void resetAttackDice() {
    attackDice = [];
    attackSurge = AttackDiceSide.surge;
    pierce = aimTokens = 0;
    reRollForCrits = false;
    calculateResults();
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
    calculateResults();
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
      calculateResults();
    }
  }

  @visibleForTemplate
  var dodge = 0;

  @visibleForTemplate
  void setDodge(int amount) {
    dodge = amount;
    calculateResults();
  }

  @visibleForTemplate
  var guardian = 0;

  @visibleForTemplate
  void setGuardian(int amount) {
    guardian = amount;
    calculateResults();
  }

  @visibleForTemplate
  var impervious = false;

  @visibleForTemplate
  void setImpervious(bool value) {
    impervious = value;
    calculateResults();
  }

  @visibleForTemplate
  var defensiveSurgeTokens = 0;

  @visibleForTemplate
  void setDefensiveSurgeTokens(int amount) {
    defensiveSurgeTokens = amount;
    calculateResults();
  }

  @visibleForTemplate
  var armor = 0;

  @visibleForTemplate
  void setArmor(int amount) {
    armor = amount;
    calculateResults();
  }

  @visibleForTemplate
  static const armorValues = [0, 1, 2, 3, 4, 5];

  @visibleForTemplate
  String get armorLabel => renderArmor(armor);

  @visibleForTemplate
  static String renderArmor(Object armor) {
    if (armor == armorValues.first) {
      return 'No Armor';
    }
    if (armor == armorValues.last) {
      return 'Armor: ∞';
    }
    return 'Armor: $armor';
  }

  @visibleForTemplate
  void toggleDefenseDice() {
    if (defenseDice == DefenseDice.white) {
      defenseDice = DefenseDice.red;
    } else {
      defenseDice = DefenseDice.white;
    }
    calculateResults();
  }

  @visibleForTemplate
  void resetDefenseDice() {
    defenseSurge = DefenseDiceSide.surge;
    defenseDice = DefenseDice.white;
    cover = 0;
    dodge = 0;
    calculateResults();
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
    calculateResults();
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
  num averageSaves;

  @visibleForTemplate
  num averageBlocks;

  @visibleForTemplate
  num averageWounds;

  @visibleForTemplate
  num averageSuppression;

  @visibleForTemplate
  BarChartData chartData;

  @visibleForTemplate
  static final chartProps = BarChartProperties()
    ..xAxis.title.text = 'Result'
    ..yAxis.title.text = 'Distribution (out of $_iterations)';

  @visibleForTemplate
  static String formatResults(num result) {
    return result.toStringAsFixed(2);
  }

  @visibleForTemplate
  bool get resultsCalculated => averageHits != null && attackDice.isNotEmpty;

  @visibleForTemplate
  void calculateResults() {
    final results = List<Results>.filled(_iterations, null);
    final simulation = Simulation(
      aimTokens: aimTokens,
      armor: armor,
      impact: impact,
      precise: precise,
      attack: attackDice,
      attackSurge: _attackToSurge[attackSurge],
      attackSurgeTokens: surgeTokens,
      criticalX: criticalX,
      pierce: pierce,
      defense: defenseDice,
      defenseSurge: defenseSurge == DefenseDiceSide.block,
      coverOrDodgeOrGuardian: cover + dodge + guardian,
      defensiveSurgeTokens: defensiveSurgeTokens,
      impervious: impervious,
      reRollForCrits: reRollForCrits,
    );

    final savesPerDice = List<int>.filled(attackDice.length + 1, 0);
    final woundsPerDice = savesPerDice.toList();

    var sumHits = 0;
    var sumCrits = 0;
    var sumSaves = 0;
    var sumBlocks = 0;
    var sumWounds = 0;
    var sumSuppression = 0;

    for (var i = 0; i < _iterations; i++) {
      final result = results[i] = _simulator.simulate(simulation);
      final savesRolled = result.defense.blanks + result.defense.blocks;
      final woundsTaken = result.wounds;

      savesPerDice[savesRolled]++;
      woundsPerDice[woundsTaken]++;

      sumHits += result.hits;
      sumCrits += result.crits;
      sumSaves += savesRolled;
      sumBlocks += result.blocks;
      sumWounds += result.wounds;

      if (result.hits > 0 || result.crits > 0) {
        sumSuppression++;
      }
    }

    averageHits = sumHits / _iterations;
    averageCrits = sumCrits / _iterations;
    averageSaves = sumSaves / _iterations;
    averageBlocks = sumBlocks / _iterations;
    averageWounds = sumWounds / _iterations;
    averageSuppression = sumSuppression / _iterations;

    final data = <BarChartColumnData>[];
    for (var i = 0; i < savesPerDice.length; i++) {
      data.add(BarChartColumnData(
          '$i', [savesPerDice[i].toDouble(), woundsPerDice[i].toDouble()]));
    }
    chartData = BarChartData(['Hits Through', 'Wounds'], data);
  }
}
