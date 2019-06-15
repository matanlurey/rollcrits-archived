import 'package:angular/angular.dart';
import 'package:angular/meta.dart';
import 'package:swlegion/swlegion.dart';

@Component(
  selector: 'rc-attack-side',
  directives: [
    NgIf,
  ],
  templateUrl: 'attack_side.html',
)
class RCAttackSide {
  @Input()
  var side = AttackDiceSide.blank;

  @visibleForTemplate
  bool get isBlank => side == AttackDiceSide.blank;

  @visibleForTemplate
  String get name {
    switch (side) {
      case AttackDiceSide.hit:
        return 'hit';
      case AttackDiceSide.criticalHit:
        return 'crit';
      case AttackDiceSide.surge:
        return 'surge';
      default:
        assert(false, 'Should never occur');
        return '';
    }
  }
}
