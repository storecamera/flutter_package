import 'package:contract/contract.dart';

class FamilyService extends Service {
  static FamilyService get instance => Service.of<FamilyService>();

  final Map<String, List<String>> _family = {
    'Sells': ['Chris', 'John', 'Tom'],
    'Addams': ['Gomez', 'Morticia', 'Pugsley', 'Wednesday'],
    'Hunting': [
      'Mom',
      'Dad',
      'Will',
      'Marky',
      'Ricky',
      'Danny',
      'Terry',
      'Mikey',
      'Davey'
    ],
  };

  List<String> getFamily() => _family.keys.toList();

  List<String> getPerson(String family) => _family[family]?.toList() ?? [];
}
