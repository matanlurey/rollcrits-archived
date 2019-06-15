import 'package:angular/angular.dart';
import 'package:swlegion/swlegion.dart';

@Component(
  selector: 'rc-attack-dice',
  templateUrl: 'attack_dice.html',
)
class RCAttackDice {
  @Input()
  var color = AttackDice.white;
}
