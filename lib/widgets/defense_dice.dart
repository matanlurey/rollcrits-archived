import 'package:angular/angular.dart';
import 'package:swlegion/swlegion.dart';

@Component(
  selector: 'rc-defense-dice',
  templateUrl: 'defense_dice.html',
)
class RCDefenseDice {
  @Input()
  var color = DefenseDice.white;
}
