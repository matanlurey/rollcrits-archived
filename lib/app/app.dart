import 'package:angular/angular.dart';
import 'package:angular/meta.dart';
import 'package:angular_components/material_button/material_button.dart';
import 'package:angular_components/material_input/material_input.dart';
import 'package:angular_components/material_input/material_number_accessor.dart';
import 'package:angular_components/material_radio/material_radio.dart';
import 'package:angular_components/material_radio/material_radio_group.dart';
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
  static final _simulator = Simulator(Holodeck());
  static final _iterations = 20000;

  @visibleForTemplate
  var attackDice = <AttackDice>[];

  @visibleForTemplate
  var attackSurge = AttackDiceSide.surge;

  @visibleForTemplate
  var pierce = 0;

  @visibleForTemplate
  void addAttackDice(AttackDice color) {
    attackDice = ([...attackDice, color]..sort()).reversed.toList();
    calculateResults();
  }

  @visibleForTemplate
  void resetAttackDice() {
    attackDice = [];
    attackSurge = AttackDiceSide.surge;
    pierce = 0;
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
  num averageBlocks;

  @visibleForTemplate
  num averageWounds;

  @visibleForTemplate
  num averageSuppression;

  @visibleForTemplate
  BarChartData chartData;

  @visibleForTemplate
  static final chartProps = BarChartProperties()
    ..xAxis.title.text = 'Wounds'
    ..yAxis.title.text = 'Results (of $_iterations)';

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
      attack: attackDice,
      attackSurge: _attackToSurge[attackSurge],
      pierce: pierce,
      defense: defenseDice,
      defenseSurge: defenseSurge == DefenseDiceSide.block,
      cover: cover,
    );
    final distribution = List<int>.filled(attackDice.length + 1, 0);

    var sumHits = 0;
    var sumCrits = 0;
    var sumBlocks = 0;
    var sumWounds = 0;
    var sumSuppression = 0;

    for (var i = 0; i < _iterations; i++) {
      final result = results[i] = _simulator.simulate(simulation);
      distribution[result.wounds]++;

      sumHits += result.hits;
      sumCrits += result.crits;
      sumBlocks += result.blocks;
      sumWounds += result.wounds;

      if (result.hits > 0 || result.crits > 0) {
        sumSuppression++;
      }
    }

    averageHits = sumHits / _iterations;
    averageCrits = sumCrits / _iterations;
    averageBlocks = sumBlocks / _iterations;
    averageWounds = sumWounds / _iterations;
    averageSuppression = sumSuppression / _iterations;

    final data = <BarChartColumnData>[];
    for (var i = 0; i < distribution.length; i++) {
      data.add(BarChartColumnData('$i', [distribution[i].toDouble()]));
    }
    chartData = BarChartData(['Wounds'], data);
  }
}
