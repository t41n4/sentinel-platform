import 'package:validatorless/validatorless.dart';

final phoneValidator = Validatorless.multiple([
  Validatorless.required('This field is required'),
  Validatorless.number('Must be a number'),
  Validatorless.min(9, 'Must be at least 10 digits'),
  Validatorless.max(15, 'Must be at most 15 digits'),
]);
