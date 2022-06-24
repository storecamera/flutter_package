typedef ValidatorMessage = String Function();
typedef ValidatorEvaluate = bool Function(dynamic value);

class Validator {
  final ValidatorEvaluate evaluate;
  final String message;

  const Validator({required this.evaluate, required this.message});

  String? validator(dynamic value) {
    if (!evaluate(value)) {
      return message;
    }
    return null;
  }
}

class RegExpValidator extends Validator {
  RegExpValidator({required String regExp, required super.message})
      : super(evaluate: (_) {
          if (_ is String) {
            RegExp regex = RegExp(regExp);
            if (!regex.hasMatch(_)) {
              return false;
            }
          }
          return true;
        });
}

class EmptyValidator extends Validator {
  EmptyValidator({String? message})
      : super(
            evaluate: (_) => _ != null,
            message: message ?? 'The content is empty');
}

class EmailValidator extends RegExpValidator {
  static String regExp = r'^[a-zA-Z0-9.]+@[a-zA-Z0-9]+\.[a-zA-Z]+';

  EmailValidator({String? message})
      : super(regExp: regExp, message: message ?? 'Invalid email format');
}

class PasswordValidator extends RegExpValidator {
  static String regExp = r'^.{6,}$';

  PasswordValidator({String? message})
      : super(regExp: regExp, message: message ?? 'Invalid password format');
}

class NumberValidator extends RegExpValidator {
  static String regExp = r'^\D?(\d{3})\D?\D?(\d{3})\D?(\d{4})$';

  NumberValidator({String? message})
      : super(regExp: regExp, message: message ?? 'Not a number');
}

class AmountValidator extends RegExpValidator {
  static String regExp = r'^\d+$';

  AmountValidator({String? message})
      : super(regExp: regExp, message: message ?? 'Not a number');
}

class MinValidator extends Validator {
  MinValidator({required int min, String? message})
      : super(
            evaluate: (_) {
              int? value;
              if (_ is int) {
                value = _;
              } else if (_ is String) {
                value = int.tryParse(_);
              }

              if (value != null && value < min) {
                return false;
              }
              return true;
            },
            message: message ?? 'Greater than $min');
}

class MinOrMaxValidator extends Validator {
  MinOrMaxValidator({required int min, required int max, String? message})
      : super(
            evaluate: (_) {
              int? value;
              if (_ is int) {
                value = _;
              } else if (_ is String) {
                value = int.tryParse(_);
              }

              if (value != null) {
                return value < min || value > max;
              }
              return true;
            },
            message: message ?? 'Greater than $min and less than $max');
}
