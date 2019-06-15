import 'package:angular/angular.dart';
import 'package:angular/meta.dart';
import 'package:swlegion/swlegion.dart';

@Component(
  selector: 'rc-defense-side',
  directives: [
    NgIf,
  ],
  templateUrl: 'defense_side.html',
)
class RCDefenseSide {
  @Input()
  var side = DefenseDiceSide.blank;

  @visibleForTemplate
  bool get isBlank => side == DefenseDiceSide.blank;

  @visibleForTemplate
  String get name {
    switch (side) {
      case DefenseDiceSide.surge:
        return 'surge';
      case DefenseDiceSide.block:
        return 'block';
      default:
        assert(false, 'Should never occur');
        return '';
    }
  }
}
