import 'package:angular/angular.dart';
import 'package:angular/meta.dart';
import 'package:angular_components/material_button/material_button.dart';
import 'package:rollcrits/widgets.dart';
import 'package:swlegion/swlegion.dart';

@Component(
  selector: 'rc-app',
  directives: [
    MaterialButtonComponent,
    NgFor,
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
  @visibleForTemplate
  var attackDice = <AttackDice>[];

  @visibleForTemplate
  var attackSurge = AttackDiceSide.surge;

  @visibleForTemplate
  void addAttackDice(AttackDice color) {
    attackDice = ([...attackDice, color]..sort()).reversed.toList();
  }

  @visibleForTemplate
  void clearAttackDice() {
    attackDice = [];
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
}
